/*
Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
$Id$

=head1 NAME

src/sub.c - Subroutines

=head1 DESCRIPTION

Subroutines, continuations, co-routines and other fun stuff...

=head2 Functions

=over 4

=cut

*/

#include "parrot/parrot.h"
#include "parrot/method_util.h"
#include "parrot/oplib/ops.h"

/*

=item C<void
mark_context(Interp* interpreter, parrot_context_t* ctx)>

Marks the context C<*ctx>.

=cut

*/

void
mark_context(Interp* interpreter, parrot_context_t* ctxp)
{
    PObj *obj;
    parrot_context_t ctx = *ctxp;
    int i, n;
    struct parrot_regs_t *regs;

    mark_stack(interpreter, CONTEXT(ctx)->pad_stack);
    mark_stack(interpreter, CONTEXT(ctx)->user_stack);
    mark_stack(interpreter, CONTEXT(ctx)->control_stack);
    mark_register_stack(interpreter, CONTEXT(ctx)->int_reg_stack);
    mark_register_stack(interpreter, CONTEXT(ctx)->num_reg_stack);
    mark_string_register_stack(interpreter, CONTEXT(ctx)->string_reg_stack);
    mark_pmc_register_stack(interpreter, CONTEXT(ctx)->pmc_reg_stack);
    obj = (PObj*)CONTEXT(ctx)->current_sub;
    if (obj)
        pobject_lives(interpreter, obj);
    obj = (PObj*)CONTEXT(ctx)->current_object;
    if (obj)
        pobject_lives(interpreter, obj);
    /* the current continuation in the interpreter has
     * to be marked too in the call sequence currently
     * as e.g. a MMD search could need resources
     * and GC the continuation
     */
    obj = (PObj*)interpreter->current_cont;
    if (obj && !PObj_live_TEST(obj))
        pobject_lives(interpreter, obj);
    obj = (PObj*)CONTEXT(ctx)->current_cont;
    if (obj && !PObj_live_TEST(obj))
        pobject_lives(interpreter, obj);
    obj = (PObj*)CONTEXT(ctx)->current_method;
    if (obj)
        pobject_lives(interpreter, obj);
    obj = (PObj*)CONTEXT(ctx)->current_package;
    if (obj)
        pobject_lives(interpreter, obj);
    regs = ctx.bp;
    for (i = 0; i < NUM_REGISTERS; ++i) {
        obj = (PObj*) BP_REG_PMC(regs, i);
        if (obj)
            pobject_lives(interpreter, obj);
        obj = (PObj*) BP_REG_STR(regs, i);
        if (obj)
            pobject_lives(interpreter, obj);
    }
}

/*

=item C<static void
prepend_stack( struct Stack_Chunk **interp_stack,
                struct Stack_Chunk **ctx_stack,
                struct Stack_Chunk *saved_stack,
                struct Stack_Chunk *saved_base)>

The final C<ctx_stack> = C<interp_stack> + C<saved_stack>.
C<interp_stack> and C<ctx_stack> are already swapped here.

=cut

*/

static void
prepend_stack( struct Stack_Chunk **interp_stack,
                struct Stack_Chunk **ctx_stack,
                struct Stack_Chunk *saved_stack,
                struct Stack_Chunk *saved_base)
{
    /*
     * new interpreter stack is the saved coroutine stack top
     * with the base pointing to the old top
     */
    saved_base->prev = *ctx_stack;

    *interp_stack = saved_stack;
}

/*

=item C<static void
restore_stack( struct Stack_Chunk **interp_stack,
                struct Stack_Chunk **ctx_stack,
                struct Stack_Chunk **saved_stack,
                struct Stack_Chunk *saved_base)>

Undo C<prepend_stack()>.
C<interp_stack> and C<ctx_stack> are already swapped here.

=cut

*/

static void
restore_stack( struct Stack_Chunk **interp_stack,
                struct Stack_Chunk **ctx_stack,
                struct Stack_Chunk **saved_stack,
                struct Stack_Chunk *saved_base)
{
    *saved_stack = *ctx_stack;
    /*
     * the coroutine stack ends here
     */
    saved_base->prev = saved_base;
}

/*

=item C<void
swap_context(Interp *interp, struct PMC *sub)>

Swaps the context.

=cut

*/

void
swap_context(Interp *interpreter, struct PMC *sub)
{
    struct Parrot_coro* co = PMC_coro(sub);
    parrot_context_t ctx;

    ctx = interpreter->ctx;

    if (!co->ctx.bp) {
        PMC *pad;
        /*
         * first time set current sub, cont, object
         */
        Parrot_alloc_context(interpreter);
        co->ctx = interpreter->ctx;
        pad = scratchpad_get_current(interpreter);
        if (pad) {
            stack_push(interpreter, &CONTEXT(co->ctx)->pad_stack, pad,
                    STACK_ENTRY_PMC, STACK_CLEANUP_NULL);
        }
        CONTEXT(co->ctx)->current_sub = sub;
        CONTEXT(co->ctx)->current_cont = interpreter->current_cont;
        CONTEXT(co->ctx)->current_object = NULL;
        interpreter->current_object = NULL;

        PObj_get_FLAGS(sub) |= SUB_FLAG_CORO_FF;
        /* copy args from interpreter */
        copy_regs(interpreter, ctx.bp);
        /* some code still needs this */
        REG_PMC(0) = BP_REG_PMC(ctx.bp, 0);
    }
    /* if calling the coroutine */
    else if (!(PObj_get_FLAGS(sub) & SUB_FLAG_CORO_FF)) {
        PObj_get_FLAGS(sub) |= SUB_FLAG_CORO_FF;
        interpreter->ctx = co->ctx;
    }
    else {
        PObj_get_FLAGS(sub) &= ~SUB_FLAG_CORO_FF;
        ctx.rctx = CONTEXT(ctx)->prev;
        interpreter->ctx = ctx;
        /* yield values */
        copy_regs(interpreter, co->ctx.bp);
    }
}

/*

=item C<struct Parrot_sub *
new_sub(Interp *interp)>

Returns a new C<Parrot_sub>.

=cut

*/

struct Parrot_sub *
new_sub(Interp *interp)
{
    /* Using system memory until I figure out GC issues */
    struct Parrot_sub *newsub =
        mem_sys_allocate_zeroed(sizeof(struct Parrot_sub));
    newsub->seg = interp->code;
    return newsub;
}

/*

=item C<struct Parrot_sub *
new_closure(Interp *interp)>

Returns a new C<Parrot_sub> with its own sctatchpad.

XXX: Need to document semantics in detail.

=cut

*/

struct Parrot_sub *
new_closure(Interp *interp)
{
    struct Parrot_sub *newsub = new_sub(interp);
    PMC * pad = scratchpad_get_current(interp);
    newsub->pad_stack = new_stack(interp, "Pad");
    if (pad) {
        /* put the correct pad in place */
        stack_push(interp, &newsub->pad_stack, pad,
                STACK_ENTRY_PMC, STACK_CLEANUP_NULL);
    }
    return newsub;
}
/*

=item C<struct Parrot_cont *
new_continuation(Interp *interp)>

Returns a new C<Parrot_cont> with its own copy of the current
context.

=cut

*/


struct Parrot_cont *
new_continuation(Interp *interp)
{
    struct Parrot_cont *cc = mem_sys_allocate(sizeof(struct Parrot_cont));
    cc->ctx = interp->ctx;
    Parrot_set_context_threshold(interp, &interp->ctx);
    cc->seg = interp->code;
    cc->address = NULL;
    return cc;
}

/*

=item C<struct Parrot_cont *
new_ret_continuation(Interp *interp)>

Returns a new C<Parrot_cont> with its own copy of the current context.

=cut

*/

struct Parrot_cont *
new_ret_continuation(Interp *interp)
{
    struct Parrot_cont *cc = mem_sys_allocate(sizeof(struct Parrot_cont));
    cc->ctx = interp->ctx;
    cc->seg = interp->code;
    cc->address = NULL;
    return cc;
}

/*

=item C<struct Parrot_coro *
new_coroutine(Interp *interp)>

Returns a new C<Parrot_coro>.

XXX: Need to document semantics in detail.

=cut

*/

struct Parrot_coro *
new_coroutine(Interp *interp)
{
    struct Parrot_coro *co =
        mem_sys_allocate_zeroed(sizeof(struct Parrot_coro));

    co->seg = interp->code;
    co->ctx.bp = NULL;
    return co;
}

/*

=item C<PMC *
new_ret_continuation_pmc(Interp * interp, opcode_t * address)>

Returns a new C<RetContinuation> PMC. Uses one from the cache,
if possible; otherwise, creates a new one.

=cut

*/

PMC *
new_ret_continuation_pmc(Interp * interpreter, opcode_t * address)
{
    PMC* continuation;
    continuation = pmc_new(interpreter, enum_class_RetContinuation);
    VTABLE_set_pointer(interpreter, continuation, address);
    return continuation;
}
#undef PREV_RETC

/*

=item C<void copy_regs(Interp *, struct parrot_regs_t *caller_regs)>

Copy function arguments or return values from C<caller_regs> to interpreter.

=cut

*/

void
copy_regs(Interp *interpreter, struct parrot_regs_t *bp)
{
    int i, n, proto, overflow;

    proto = BP_REG_INT(bp, 0);
    overflow = 0;
    if (proto) {
        n = BP_REG_INT(bp, 1);
        overflow = n == 11;
        for (i = 0; i < 5 + n; ++i)
            REG_INT(i) = BP_REG_INT(bp, i);
        n = BP_REG_INT(bp, 2);
        overflow |= n == 11;
        for (i = 0; i < n; ++i)
            REG_STR(i + 5) = BP_REG_STR(bp, i + 5);
        n = BP_REG_INT(bp, 3);
        overflow |= n == 11;
        for (i = 0; i < n; ++i)
            REG_PMC(i + 5) = BP_REG_PMC(bp,i + 5);
        n = BP_REG_INT(bp, 4);
        overflow |= n == 11;
        for (i = 0; i < n; ++i)
            REG_NUM(i + 5) = BP_REG_NUM(bp, i + 5);
    }
    else {
        REG_INT(0) = 0;
        REG_INT(3) = n = BP_REG_INT(bp, 3);
        overflow = n == 11;
        for (i = 0; i < n; ++i)
            REG_PMC(i + 5) = BP_REG_PMC(bp,i + 5);
    }
    if (overflow)
        REG_PMC(3) = BP_REG_PMC(bp,3);
}

INTVAL
Parrot_get_argc(Interp *interpreter, int bits)
{
    INTVAL res = (interpreter->current_argc >> (bits * 8)) & 0xff;
    return res;
}

/* XXX */
#define CONST_STRING(i,s) const_string(i,s)
opcode_t *
parrot_pass_args(Interp *interpreter, struct Parrot_sub * sub,
        struct parrot_regs_t *caller_regs, int what)
{
    PMC *src_signature, *dst_signature;
    INTVAL src_i, dst_i, src_n, dst_n, src_sig, dst_sig, args_op, dst_typ;
    opcode_t *src_pc, *dst_pc;
    struct PackFile_Constant **constants;
    INTVAL i_arg;
    FLOATVAL f_arg;
    PMC *p_arg;
    STRING *s_arg;
    STRING *_array;
    PMC *slurp_ar;
    const char *action;
    INTVAL argcI, argcS, argcP, argcN;

    _array = CONST_STRING(interpreter, "array");
    constants = interpreter->code->const_table->constants;
    if (what == PARROT_OP_get_params_pc) {
        if (CONTEXT(interpreter->ctx)->current_params)
            dst_pc = CONTEXT(interpreter->ctx)->current_params;
        else if (*sub->address != what)
            return sub->address;
        else
            dst_pc = sub->address;
        src_pc = interpreter->current_args;
        if (!src_pc)    /* no args */
            return sub->address;
        args_op = PARROT_OP_set_args_pc;

        CONTEXT(interpreter->ctx)->current_params = dst_pc;
        action = "params";
    }
    else {
        dst_pc = CONTEXT(interpreter->ctx)->current_results;
        args_op = PARROT_OP_set_returns_pc;
        src_pc = interpreter->current_returns;
        if (!src_pc)    /* no returns */
            return NULL;
        CONTEXT(interpreter->ctx)->current_results = NULL;
        action = "results";
    }

    assert(*dst_pc == what);
    dst_signature = sub->seg->const_table->constants[dst_pc[1]]->u.key;
    assert(PObj_is_PMC_TEST(dst_signature));
    assert(dst_signature->vtable->base_type == enum_class_FixedIntegerArray);

    /* we point to the set_args opcode */
    assert(*src_pc == args_op);
    src_signature = constants[src_pc[1]]->u.key;
    assert(PObj_is_PMC_TEST(src_signature));
    assert(src_signature->vtable->base_type == enum_class_FixedIntegerArray);

    src_n = VTABLE_elements(interpreter, src_signature);
    /* never get more then the caller expects */
    dst_n = VTABLE_elements(interpreter, dst_signature);

    slurp_ar = NULL;
    argcI = argcS = argcP = argcN = 0;
    for (src_i = dst_i = 0, src_pc += 2, dst_pc += 2;
            src_i < src_n && dst_i < dst_n; ++src_i, ++dst_i) {
        src_sig = VTABLE_get_integer_keyed_int(interpreter,
                src_signature, src_i);
        if (!slurp_ar) {
            /* TODO create some means to reuse a user-provided
             *      result array
             */
            dst_sig = VTABLE_get_integer_keyed_int(interpreter,
                    dst_signature, dst_i);
            dst_typ = dst_sig & PARROT_ARG_TYPE_MASK;
            if (dst_sig & PARROT_ARG_SLURPY_ARRAY) {
                /* create array */
                slurp_ar = pmc_new(interpreter,
                        Parrot_get_ctx_HLL_type(interpreter,
                            enum_class_ResizablePMCArray));
                REG_PMC(dst_pc[dst_i]) = slurp_ar;
                argcP++;
            }
        }
        switch (src_sig & PARROT_ARG_TYPE_MASK) {
            /* TODO verify dst_signature */
            /* XXX pdd03 Type Conversions */
            case PARROT_ARG_INTVAL:
                i_arg = src_pc[src_i];
                if (!(src_sig & PARROT_ARG_CONSTANT)) {
                    i_arg = BP_REG_INT(caller_regs, i_arg);
                }
                if (slurp_ar) {
                    VTABLE_push_integer(interpreter, slurp_ar, i_arg);
                    break;
                }
again_i:
                if (dst_typ == PARROT_ARG_INTVAL) {
                    REG_INT(dst_pc[dst_i]) = i_arg;
                    argcI++;
                }
                else if (dst_typ == PARROT_ARG_PMC) {
                    PMC *d = pmc_new(interpreter,
                            Parrot_get_ctx_HLL_type(interpreter,
                                enum_class_Integer));
                    VTABLE_set_integer_native(interpreter, d, i_arg);
                    REG_PMC(dst_pc[dst_i]) = d;
                    argcP++;
                }
                else if ((dst_sig & PARROT_ARG_OPTIONAL) &&
                        dst_i < dst_n - 1) {
                    dst_i++;
                    dst_sig = VTABLE_get_integer_keyed_int(interpreter,
                            dst_signature, dst_i);
                    dst_typ = dst_sig & PARROT_ARG_TYPE_MASK;
                    goto again_i;
                }
                else {
                    real_exception(interpreter, NULL, E_ValueError,
                            "argument type mismatch");
                }
                break;
            case PARROT_ARG_STRING:
                argcI++;
                i_arg = src_pc[src_i];
                if ((src_sig & PARROT_ARG_CONSTANT)) {
                    s_arg = constants[i_arg]->u.string;
                }
                else {
                    s_arg = BP_REG_STR(caller_regs, i_arg);
                }
                if (slurp_ar) {
                    VTABLE_push_string(interpreter, slurp_ar, s_arg);
                    break;
                }
again_s:
                if (dst_typ == PARROT_ARG_STRING) {
                    REG_STR(dst_pc[dst_i]) = s_arg;
                    argcS++;
                }
                else if (dst_typ == PARROT_ARG_PMC) {
                    PMC *d = pmc_new(interpreter,
                            Parrot_get_ctx_HLL_type(interpreter,
                                enum_class_String));
                    VTABLE_set_string_native(interpreter, d, s_arg);
                    REG_PMC(dst_pc[dst_i]) = d;
                    argcP++;
                }
                else if ((dst_sig & PARROT_ARG_OPTIONAL) &&
                        dst_i < dst_n - 1) {
                    dst_i++;
                    dst_sig = VTABLE_get_integer_keyed_int(interpreter,
                            dst_signature, dst_i);
                    dst_typ = dst_sig & PARROT_ARG_TYPE_MASK;
                    goto again_s;
                }
                else
                    real_exception(interpreter, NULL, E_ValueError,
                            "argument type mismatch");
                break;
            case PARROT_ARG_FLOATVAL:
                i_arg = src_pc[src_i];
                if ((src_sig & PARROT_ARG_CONSTANT)) {
                    f_arg = constants[i_arg]->u.number;
                }
                else {
                    f_arg = BP_REG_NUM(caller_regs, i_arg);
                }
                if (slurp_ar) {
                    VTABLE_push_float(interpreter, slurp_ar, f_arg);
                }
                else if (dst_typ == PARROT_ARG_FLOATVAL) {
                    REG_NUM(dst_pc[dst_i]) = f_arg;
                    argcN++;
                }
                else if (dst_typ == PARROT_ARG_PMC) {
                    PMC *d = pmc_new(interpreter,
                            Parrot_get_ctx_HLL_type(interpreter,
                                enum_class_Float));
                    VTABLE_set_number_native(interpreter, d, f_arg);
                    REG_PMC(dst_pc[dst_i]) = d;
                    argcP++;
                }
                else
                    real_exception(interpreter, NULL, E_ValueError,
                            "argument type mismatch");
                break;
            case PARROT_ARG_PMC:
                i_arg = src_pc[src_i];
                if ((src_sig & PARROT_ARG_CONSTANT)) {
                    p_arg = constants[i_arg]->u.key;
                }
                else {
                    p_arg = BP_REG_PMC(caller_regs, i_arg);
                }
                if ((src_sig & PARROT_ARG_FLATTEN) ||
                        (slurp_ar && (src_sig & PARROT_ARG_MAYBE_FLATTEN))) {
                    INTVAL i, n, is_array;
                    PMC *elem;

                    is_array = VTABLE_does(interpreter, p_arg, _array);
                    if (!is_array) {
                        if (src_sig & PARROT_ARG_FLATTEN) {
                            /* src ought to be an array */
                            real_exception(interpreter, NULL, E_ValueError,
                                    "argument doesn't array");
                        }
                        /* maybe_flatten takes normal PMCs too */
                        goto normal_pmc;
                    }
                    n = VTABLE_elements(interpreter, p_arg);
                    for (i = 0; i < n && dst_i < dst_n; ++i) {
                        if (dst_typ != PARROT_ARG_PMC) {
                            real_exception(interpreter, NULL, E_ValueError,
                                    "param isn't a PMC");
                        }
                        elem = VTABLE_get_pmc_keyed_int(interpreter, p_arg, i);
                        if (slurp_ar)
                            VTABLE_push_pmc(interpreter, slurp_ar, elem);
                        else {
                            REG_PMC(dst_pc[dst_i++]) = elem;
                            argcP++;
                            if (dst_i == dst_n)
                                break;
                            dst_sig = VTABLE_get_integer_keyed_int(interpreter,
                                    dst_signature, dst_i);
                            dst_typ = dst_sig & PARROT_ARG_TYPE_MASK;
                        }
                    }
                    if (!slurp_ar)
                        --dst_i;
                }
                else {
normal_pmc:
                    if (slurp_ar) {
                        VTABLE_push_pmc(interpreter, slurp_ar, p_arg);
                    }
                    else if (dst_typ == PARROT_ARG_PMC) {
                        REG_PMC(dst_pc[dst_i]) = p_arg;
                        argcP++;
                    }
                    else if (dst_typ == PARROT_ARG_INTVAL) {
                        REG_INT(dst_pc[dst_i]) =
                            VTABLE_get_integer(interpreter, p_arg);
                        argcI++;
                    }
                    else if (dst_typ == PARROT_ARG_FLOATVAL) {
                        REG_NUM(dst_pc[dst_i]) =
                            VTABLE_get_number(interpreter, p_arg);
                        argcN++;
                    }
                    else if (dst_typ == PARROT_ARG_STRING) {
                        REG_STR(dst_pc[dst_i]) =
                            VTABLE_get_string(interpreter, p_arg);
                        argcS++;
                    }
                }
                break;
        }
        if (slurp_ar)
            --dst_i;
    }
#if 0
    /*
     * check for arg count mismatch
     *
     * XXX not yet. PGE uses a lot of implicit :optionals
     */
    if (src_i != src_n) {
        /* ingore return value mismatch */
        real_exception(interpreter, NULL, E_ValueError,
                "too many arguments passed (%d) - %d %s expected",
                src_n, dst_n, action);
    }
    else if (dst_i != dst_n) {
        dst_sig = VTABLE_get_integer_keyed_int(interpreter,
                dst_signature, dst_i);
        if (!(dst_sig & (PARROT_ARG_OPTIONAL|PARROT_ARG_SLURPY_ARRAY))) {
            real_exception(interpreter, NULL, E_ValueError,
                    "too few arguments passed (%d) - %d %s expected",
                    src_n, dst_n, action);
        }
    }
#endif
    interpreter->current_argc =
        argcI + (argcS << 8) + (argcP << 16) + (argcS << 24);

    return dst_pc + dst_n;
}

/*

=item C< void invalidate_retc_context(Interp *, struct Parrot_Context *ctx)>

Make true Continuation from all RetContinuations up the call chain.

=cut

*/
void
invalidate_retc_context(Interp *interpreter, parrot_context_t *ctxp)
{
    parrot_context_t ctx;
    PMC *cont;

    ctx = *ctxp;
    Parrot_set_context_threshold(interpreter, ctxp);
    while (1) {
        /*
         * We  stop if we encounter a true continuation, because
         * if one were created, everything up the chain would have been
         * invalidated earlier.
         */
        cont = CONTEXT(ctx)->current_cont;
        if (cont->vtable == Parrot_base_vtables[enum_class_Continuation])
            break;
        cont->vtable = Parrot_base_vtables[enum_class_Continuation];
        ctx.rctx = CONTEXT(ctx)->prev;
        if (!ctx.rctx)
            break;
    }

}

/*

=item C<Parrot_full_sub_name>

Print name and location of subroutine, This should finally use the label
name of the frozen C<Sub> PMC image for now locate the C<Sub> name in
the globals.

=cut

*/

STRING*
Parrot_full_sub_name(Interp* interpreter, PMC* sub)
{
    struct Parrot_sub * s;

    if (!sub || !VTABLE_defined(interpreter, sub))
        return NULL;
    s = PMC_sub(sub);
    if (PMC_IS_NULL(s->name_space)) {
        return s->name;
    } else {
        if (s->name) {
	    STRING* ns = VTABLE_get_string(interpreter, s->name_space);

    	    ns = string_concat(interpreter, ns,
		string_from_cstring(interpreter, " :: ", 4), 0);
	    return string_concat(interpreter, ns, s->name, 0);
        } else {
	    STRING* ns = string_from_cstring(interpreter, "??? :: ", 7);
	    return string_concat(interpreter, ns, s->name, 0);
	}
    }
    return NULL;
}

int
Parrot_Context_info(Interp *interpreter, parrot_context_t *ctxp,
	struct Parrot_Context_info *info)
{
    struct Parrot_sub *sub;
    parrot_context_t ctx = *ctxp;

    /* set file/line/pc defaults */
    info->file = "(unknown file)";
    info->line = -1;
    info->pc = -1;
    info->nsname = NULL;
    info->subname = NULL;
    info->fullname = NULL;

    /* is the current sub of the specified context valid? */
    if (PMC_IS_NULL(CONTEXT(ctx)->current_sub)) {
	info->subname = string_from_cstring(interpreter, "???", 3);
	info->nsname = info->subname;
	info->fullname = string_from_cstring(interpreter, "??? :: ???", 10);
	info->pc = -1;
	return 0;
    }

    /* make sure there is a sub (not always the case, e.g in pasm code) */
    if (CONTEXT(ctx)->current_sub->vtable->base_type == enum_class_Undef ||
	    PMC_sub(CONTEXT(ctx)->current_sub)->address == 0) {
	/* XXX: is this correct? (try with load_bytecode) */
	/* use the current interpreter's bytecode as start address */
	if (CONTEXT(ctx)->current_pc != NULL)
	    info->pc = CONTEXT(ctx)->current_pc - interpreter->code->base.data;
	return 1;
    }

    /* fetch struct Parrot_sub of the current sub in the given context */
    if (!VTABLE_isa(interpreter, CONTEXT(ctx)->current_sub,
                const_string(interpreter, "Sub")))
        return 1;

    sub = PMC_sub(CONTEXT(ctx)->current_sub);
    /* set the sub name */
    info->subname = sub->name;

    /* set the namespace name and fullname of the sub */
    if (PMC_IS_NULL(sub->name_space)) {
	info->nsname = string_from_cstring(interpreter, "", 0);
	info->fullname = info->subname;
    } else {
	info->nsname = VTABLE_get_string(interpreter, sub->name_space);
	info->fullname = string_concat(interpreter, info->nsname,
		string_from_cstring(interpreter, " :: ", 4), 0);
	info->fullname = string_concat(interpreter, info->fullname,
		info->subname, 1);
    }

    /* return here if there is no current pc */
    if (CONTEXT(ctx)->current_pc == NULL)
	return 1;

    /* calculate the current pc */
    info->pc = CONTEXT(ctx)->current_pc - sub->seg->base.data;

    /* determine the current source file/line */
    if (CONTEXT(interpreter->ctx)->current_pc) {
	size_t offs = info->pc;
	size_t i, n;
	/* XXX: interpreter->code->cur_cs is not correct, is it? */
	opcode_t *pc = interpreter->code->base.data;
	struct PackFile_Debug *debug = interpreter->code->debugs;

	/*assert(pc == sub->seg->base.data);*/
	/* set source file */
	info->file = debug->filename;
	for (i = n = 0; n < interpreter->code->base.size; i++) {
	    op_info_t *op_info = &interpreter->op_info_table[*pc];
            if (i >= debug->base.size)
                return 0;
	    if (n >= offs) {
		/* set source line */
		info->line = debug->base.data[i];
		break;
	    }
	    n += op_info->arg_count;
	    pc += op_info->arg_count;
	}
    }
    return 1;
}

STRING*
Parrot_Context_infostr(Interp *interpreter, parrot_context_t *ctx)
{
    struct Parrot_Context_info info;
    const char* msg = (&interpreter->ctx == ctx) ?
	"current instr.:":
	"called from Sub";

    if (Parrot_Context_info(interpreter, ctx, &info)) {
	return Parrot_sprintf_c(interpreter,
		"%s '%Ss' pc %d (%s:%d)\n", msg,
		info.fullname, info.pc, info.file, info.line);
    }
    return NULL;
}

/*

=back

=head1 SEE ALSO

F<include/parrot/sub.h>.

=head1 HISTORY

Initial version by Melvin on 2002/06/6.

=cut

*/

/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
 */
