/*
Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
$Id$

=head1 NAME

src/inter_run.c - Parrot Interpreter - Run Ops and Methods

=head1 DESCRIPTION

Various functions that call the run loop.

=head2 Functions

=over 4

=cut

*/


#include <assert.h>
#include "parrot/parrot.h"
#include "parrot/oplib/ops.h"

/*

=item C<void
runops(Interp *interpreter, size_t offset)>

Run parrot ops. Set exception handler and/or resume after exception.

=cut

*/

#define STACKED_EXCEPTIONS 1

void
runops(Interp *interpreter, size_t offs)
{
    volatile size_t offset = offs;

    CONTEXT(interpreter->ctx)->runloop_level++;
    /*
     * STACKED_EXCEPTIONS are necessary to catch exceptions in reentered
     * run loops, e.g. if a delegate methods throws an exception
     */
#if ! STACKED_EXCEPTIONS
    if (!interpreter->exceptions)
#endif
    {
        new_internal_exception(interpreter);
        interpreter->exceptions->runloop_level =
            CONTEXT(interpreter->ctx)->runloop_level;
        if (setjmp(interpreter->exceptions->destination)) {
            /* an exception was thrown */
            offset = handle_exception(interpreter);
            /* update profile for exception execution time */
            if (interpreter->profile &&
                    Interp_flags_TEST(interpreter, PARROT_PROFILE_FLAG)) {
                RunProfile *profile = interpreter->profile;
                if (profile->cur_op == PARROT_PROF_EXCEPTION) {
                    profile->data[PARROT_PROF_EXCEPTION].time +=
                        Parrot_floatval_time() - profile->starttime;
                }
            }
        }
    }

    /*
     * XXX this is broken
     *  - the runloop_level has to be in the interpreter struct
     *  - the exception loop level must be part of the exception
     *    handler
     */
    if (1 || interpreter->exceptions->runloop_level ==
            CONTEXT(interpreter->ctx)->runloop_level) {
        /* if we are coming from an exception and it was thrown deeper
         * in a nested run loop, we just leave this loop
         */
        runops_int(interpreter, offset);
    }
    /*
     * pop off exception and put it onto the free list
     * s. above
     */
    if (STACKED_EXCEPTIONS) {
        free_internal_exception(interpreter);
    }
    CONTEXT(interpreter->ctx)->runloop_level--;
    /*
     * not yet - this needs classifying of exceptions and handlers
     * so that only an exit handler does catch this exception
     */
#if 0
    do_exception(interpreter, EXCEPT_exit, 0);
#endif
}

/*

=item C<struct parrot_regs_t *
Parrot_runops_fromc(Parrot_Interp interpreter, PMC *sub)>

Runs the Parrot ops, called from C code. The function arguments are
already setup according to Parrot calling conventions, the C<sub> argument
is an invocable C<Sub> PMC.

=cut

*/

struct parrot_regs_t *
Parrot_runops_fromc(Parrot_Interp interpreter, PMC *sub)
{
    PMC *ret_c;
    opcode_t offset, *dest;
    struct parrot_regs_t *bp;

    /* we need one return continuation with a NULL offset */
    interpreter->current_cont = ret_c =
        new_ret_continuation_pmc(interpreter, NULL);
#if GC_VERBOSE
    PObj_report_SET(ret_c);     /* s. also dod.c */
#endif
    /* invoke the sub, which places the context of the sub in the
     * interpreter, and switches code segments if needed
     * Passing a dummy true destination copies registers
     */
    dest = VTABLE_invoke(interpreter, sub, (void*) 1);
    if (!dest)
        internal_exception(1, "Subroutine returned a NULL address");
    bp = interpreter->ctx.bp;
    offset = dest - interpreter->code->base.data;
    runops(interpreter, offset);
    return bp;
}

static void
call_set_arg_I(Interp *interpreter, INTVAL i_arg, PMC *slurp_ar,
        int dst_typ, int d_reg)
{
    PMC *d;

    if (slurp_ar) {
        VTABLE_push_integer(interpreter, slurp_ar, i_arg);
        return;
    }

    switch (dst_typ) {
        case PARROT_ARG_INTVAL:
            REG_INT(d_reg) = i_arg;
            break;
        case PARROT_ARG_FLOATVAL:
            REG_NUM(d_reg) = (FLOATVAL)i_arg;
            break;
        case PARROT_ARG_STRING:
            REG_STR(d_reg) = string_from_int(interpreter, i_arg);
            break;
        case PARROT_ARG_PMC:
            d = pmc_new(interpreter,
                    Parrot_get_ctx_HLL_type(interpreter, enum_class_Integer));
            VTABLE_set_integer_native(interpreter, d, i_arg);
            REG_PMC(d_reg) = d;
            break;
    }
}

static void
call_set_arg_S(Interp *interpreter, STRING* s_arg, PMC *slurp_ar,
        int dst_typ, int d_reg)
{
    PMC *d;

    if (slurp_ar) {
        VTABLE_push_string(interpreter, slurp_ar, s_arg);
        return;
    }
    switch (dst_typ) {
        case PARROT_ARG_INTVAL:
            REG_INT(d_reg) = string_to_int(interpreter, s_arg);
            break;
        case PARROT_ARG_FLOATVAL:
            REG_NUM(d_reg) = string_to_num(interpreter, s_arg);
            break;
        case PARROT_ARG_STRING:
            REG_STR(d_reg) = s_arg;
            break;
        case PARROT_ARG_PMC:
            d = pmc_new(interpreter,
                    Parrot_get_ctx_HLL_type(interpreter,
                        enum_class_String));
            VTABLE_set_string_native(interpreter, d, s_arg);
            REG_PMC(d_reg) = d;
            break;
    }
}

static void
call_set_arg_N(Interp *interpreter, FLOATVAL f_arg, PMC *slurp_ar,
        int dst_typ, int d_reg)
{
    PMC *d;

    if (slurp_ar) {
        VTABLE_push_float(interpreter, slurp_ar, f_arg);
        return;
    }
    switch (dst_typ) {
        case PARROT_ARG_INTVAL:
            REG_INT(d_reg) = (INTVAL)f_arg;
            break;
        case PARROT_ARG_FLOATVAL:
            REG_NUM(d_reg) = f_arg;
            break;
        case PARROT_ARG_STRING:
            REG_STR(d_reg) = string_from_num(interpreter, f_arg);
            break;
        case PARROT_ARG_PMC:
            d = pmc_new(interpreter,
                    Parrot_get_ctx_HLL_type(interpreter,
                        enum_class_Float));
            VTABLE_set_number_native(interpreter, d, f_arg);
            REG_PMC(d_reg) = d;
            break;
    }
}

static void
call_set_arg_P(Interp *interpreter, PMC* p_arg, PMC *slurp_ar,
        int dst_typ, int d_reg, parrot_context_t *old_ctxp)
{
    parrot_context_t old_ctx = *old_ctxp;
    /*
     * If this is a Key PMC with registers, we have to clone
     * the key.
     *
     * XXX make a distinct 'K' signature ?
     */
    if (p_arg->vtable->base_type == enum_class_Key) {
        PMC *key;
        INTVAL any_registers;

        for (any_registers = 0, key = p_arg; key; ) {
            if (PObj_get_FLAGS(key) & KEY_register_FLAG) {
                any_registers = 1;
                break;
            }
            key = key_next(interpreter, key);
        }

        if (any_registers) {
            parrot_context_t new_ctx = interpreter->ctx;
            /* need old context */
            interpreter->ctx = old_ctx;
            /* clone sets key values according to refered
             * register items
             */
            p_arg = VTABLE_clone(interpreter, p_arg);
            interpreter->ctx = new_ctx;
        }
    }
    if (slurp_ar) {
        VTABLE_push_pmc(interpreter, slurp_ar, p_arg);
        return;
    }
    switch (dst_typ) {
        case PARROT_ARG_INTVAL:
            REG_INT(d_reg) = VTABLE_get_integer(interpreter, p_arg);
            break;
        case PARROT_ARG_FLOATVAL:
            REG_NUM(d_reg) = VTABLE_get_number(interpreter, p_arg);
            break;
        case PARROT_ARG_STRING:
            REG_STR(d_reg) = VTABLE_get_string(interpreter, p_arg);
            break;
        case PARROT_ARG_PMC:
            REG_PMC(d_reg) = p_arg;
            break;
    }
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
    parrot_context_t old_ctx;

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
                call_set_arg_I(interpreter, i_arg, slurp_ar, dst_typ,
                        dst_pc[dst_i]);
                break;
            case PARROT_ARG_STRING:
                i_arg = src_pc[src_i];
                if ((src_sig & PARROT_ARG_CONSTANT)) {
                    s_arg = constants[i_arg]->u.string;
                }
                else {
                    s_arg = BP_REG_STR(caller_regs, i_arg);
                }
                call_set_arg_S(interpreter, s_arg, slurp_ar, dst_typ,
                        dst_pc[dst_i]);
                break;
            case PARROT_ARG_FLOATVAL:
                i_arg = src_pc[src_i];
                if ((src_sig & PARROT_ARG_CONSTANT)) {
                    f_arg = constants[i_arg]->u.number;
                }
                else {
                    f_arg = BP_REG_NUM(caller_regs, i_arg);
                }
                call_set_arg_N(interpreter, f_arg, slurp_ar, dst_typ,
                        dst_pc[dst_i]);
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
                    old_ctx.bp = caller_regs;
                    call_set_arg_P(interpreter, p_arg, slurp_ar, dst_typ,
                            dst_pc[dst_i], &old_ctx);
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
    interpreter->current_argc = dst_i; /* FIXME */
    /* skip the get_params opcode - all done here */
    return dst_pc + dst_n;
}


static struct parrot_regs_t *
runops_args(Parrot_Interp interpreter, PMC *sub, PMC *obj,
        STRING *meth, const char* sig, va_list ap)
{
    opcode_t offset, *dest;
    struct parrot_regs_t *bp;
    int i;
    PMC *ret_c, *param_signature, *slurp_ar;
    parrot_context_t old_ctx;
    struct PackFile_Constant **constants;
    INTVAL src_n, dst_i, dst_n, dst_typ, dst_sig;
    opcode_t *dst_pc;
    INTVAL i_arg;
    FLOATVAL f_arg;
    PMC *p_arg;
    STRING *s_arg;

    old_ctx = interpreter->ctx;
    ret_c = new_ret_continuation_pmc(interpreter, NULL);
    interpreter->current_object = obj;
    dest = VTABLE_invoke(interpreter, sub, NULL);
    CONTEXT(interpreter->ctx)->current_cont = ret_c;
    if (!dest)
        internal_exception(1, "Subroutine returned a NULL address");
    src_n = strlen(sig) - 1;
    if (!src_n) {
        goto go;
    }

    if (dest[0] != PARROT_OP_get_params_pc) {
        real_exception(interpreter, NULL, E_ValueError,
                "no get_params in sub");
    }

    constants = interpreter->code->const_table->constants;
    dst_pc = dest;
    param_signature = constants[dst_pc[1]]->u.key;
    assert(PObj_is_PMC_TEST(param_signature));
    assert(param_signature->vtable->base_type == enum_class_FixedIntegerArray);
    dst_n = VTABLE_elements(interpreter, param_signature);

    slurp_ar = NULL;
    dst_pc += 2;

    for (++sig, dst_i = 0; *sig && dst_i < dst_n; ++sig, ++dst_i) {
        if (!slurp_ar) {
            /* TODO create some means to reuse a user-provided
             *      result array
             */
            dst_sig = VTABLE_get_integer_keyed_int(interpreter,
                    param_signature, dst_i);
            dst_typ = dst_sig & PARROT_ARG_TYPE_MASK;
            if (dst_sig & PARROT_ARG_SLURPY_ARRAY) {
                /* create array */
                slurp_ar = pmc_new(interpreter,
                        Parrot_get_ctx_HLL_type(interpreter,
                            enum_class_ResizablePMCArray));
                REG_PMC(dst_pc[dst_i]) = slurp_ar;
            }
        }
        switch (*sig) {
            case 'v':       /* void func, no params */
                break;
            case 'I':       /* REG_INT */
                i_arg = va_arg(ap, INTVAL);
                call_set_arg_I(interpreter, i_arg, slurp_ar, dst_typ,
                        dst_pc[dst_i]);
                break;
            case 'S':       /* REG_STR */
                s_arg = va_arg(ap, STRING*);
                call_set_arg_S(interpreter, s_arg, slurp_ar, dst_typ,
                        dst_pc[dst_i]);
                break;
            case 'N':       /* REG_NUM */
                f_arg = va_arg(ap, FLOATVAL);
                call_set_arg_N(interpreter, f_arg, slurp_ar, dst_typ,
                        dst_pc[dst_i]);
                break;
            case 'P':       /* REG_PMC */
                p_arg = va_arg(ap, PMC*);
                call_set_arg_P(interpreter, p_arg, slurp_ar, dst_typ,
                        dst_pc[dst_i], &old_ctx);
                break;
            default:
                internal_exception(1,
                        "unhandle signature '%c' in Parrot_runops_fromc_args",
                        *sig);
        }
    }
    /*
     * check for arg count mismatch
     */
    if (*sig) {
        real_exception(interpreter, NULL, E_ValueError,
                "too many arguments passed (%d) - %d params expected",
                src_n, dst_n);
    }
    else if (dst_i != dst_n) {
        dst_sig = VTABLE_get_integer_keyed_int(interpreter,
                param_signature, dst_i);
        if (!(dst_sig & (PARROT_ARG_OPTIONAL|PARROT_ARG_SLURPY_ARRAY))) {
            real_exception(interpreter, NULL, E_ValueError,
                    "too few arguments passed (%d) - %d params expected",
                    src_n, dst_n);
        }
    }
go:
    bp = interpreter->ctx.bp;
    offset = dest - interpreter->code->base.data;
    runops(interpreter, offset);
    return bp;
}

static void*
set_retval(Parrot_Interp interpreter, int sig_ret,
        struct PackFile_ByteCode *seg, struct parrot_regs_t *bp)
{
    opcode_t *src_pc;
    PMC *signature;
    struct PackFile_Constant **constants;
    INTVAL argc;
    INTVAL src_sig, src_typ, i;
    STRING *s_arg;
    PMC *p_arg;

    if (!sig_ret || sig_ret == 'v')
        return NULL;
    src_pc = interpreter->current_returns;
    if (src_pc[0] != PARROT_OP_set_returns_pc)
        real_exception(interpreter, NULL, E_ValueError,
                "no set_returns in sub");
    constants = seg->const_table->constants;
    signature = constants[src_pc[1]]->u.key;
    if ( (argc = VTABLE_elements(interpreter, signature)) != 1)
            real_exception(interpreter, NULL, E_ValueError,
                    "return value count mismatch (%d) - 1 value expected",
                    argc);
    src_sig = VTABLE_get_integer_keyed_int(interpreter, signature, 0);
    switch (src_sig & PARROT_ARG_TYPE_MASK) {
        case PARROT_ARG_STRING:
            i = src_pc[2];
            if ((src_sig & PARROT_ARG_CONSTANT)) {
                s_arg = constants[i]->u.string;
            }
            else {
                s_arg = BP_REG_STR(bp, i);
            }
            if (sig_ret == 'S')
                return s_arg;
            else if (sig_ret == 'P') {
                PMC *d = pmc_new(interpreter,
                        Parrot_get_ctx_HLL_type(interpreter,
                            enum_class_String));
                VTABLE_set_string_native(interpreter, d, s_arg);
                return d;
            }
            break;
        case PARROT_ARG_PMC:
            i = src_pc[2];
            if ((src_sig & PARROT_ARG_CONSTANT)) {
                p_arg = constants[i]->u.key;
            }
            else {
                p_arg = BP_REG_PMC(bp, i);
            }
            switch (sig_ret) {
                case 'P' : return p_arg;
                case 'S':  return VTABLE_get_string(interpreter, p_arg);
                default:
                           real_exception(interpreter, NULL, E_ValueError,
                                   "argument type mismatch");
            }
            break;
        default:
            real_exception(interpreter, NULL, E_ValueError,
                    "argument type mismatch");

    }
    return NULL;
}

static INTVAL
set_retval_i(Parrot_Interp interpreter, int sig_ret,
        struct PackFile_ByteCode *seg, struct parrot_regs_t *bp)
{
    opcode_t *src_pc;
    PMC *signature;
    struct PackFile_Constant **constants;
    INTVAL argc;
    INTVAL src_sig, src_typ, i;
    PMC *p_arg;

    if (sig_ret != 'I') {
        real_exception(interpreter, NULL, E_ValueError,
                "argument type mismatch");
    }
    src_pc = interpreter->current_returns;
    if (src_pc[0] != PARROT_OP_set_returns_pc)
        real_exception(interpreter, NULL, E_ValueError,
                "no set_returns in sub");
    constants = seg->const_table->constants;
    signature = constants[src_pc[1]]->u.key;
    if ( (argc = VTABLE_elements(interpreter, signature)) != 1)
        real_exception(interpreter, NULL, E_ValueError,
                "return value count mismatch (%d) - 1 value expected",
                argc);
    src_sig = VTABLE_get_integer_keyed_int(interpreter, signature, 0);
    switch (src_sig & PARROT_ARG_TYPE_MASK) {
        case PARROT_ARG_INTVAL:
            i = src_pc[2];
            if (!(src_sig & PARROT_ARG_CONSTANT)) {
                i = BP_REG_INT(bp, i);
            }
            return i;
        case PARROT_ARG_PMC:
            i = src_pc[2];
            if ((src_sig & PARROT_ARG_CONSTANT)) {
                p_arg = constants[i]->u.key;
            }
            else {
                p_arg = BP_REG_PMC(bp, i);
            }
            return VTABLE_get_integer(interpreter, p_arg);
        default:
            real_exception(interpreter, NULL, E_ValueError,
                    "argument type mismatch");
    }
    return 0;
}

static FLOATVAL
set_retval_f(Parrot_Interp interpreter, int sig_ret,
        struct PackFile_ByteCode *seg, struct parrot_regs_t *bp)
{
    opcode_t *src_pc;
    PMC *signature;
    struct PackFile_Constant **constants;
    INTVAL argc;
    INTVAL src_sig, src_typ, i;
    PMC *p_arg;
    FLOATVAL f_arg;

    if (sig_ret != 'N') {
        real_exception(interpreter, NULL, E_ValueError,
                "argument type mismatch");
    }
    src_pc = interpreter->current_returns;
    if (src_pc[0] != PARROT_OP_set_returns_pc)
        real_exception(interpreter, NULL, E_ValueError,
                "no set_returns in sub");
    constants = seg->const_table->constants;
    signature = constants[src_pc[1]]->u.key;
    if ( (argc = VTABLE_elements(interpreter, signature)) != 1)
        real_exception(interpreter, NULL, E_ValueError,
                "return value count mismatch (%d) - 1 value expected",
                argc);
    src_sig = VTABLE_get_integer_keyed_int(interpreter, signature, 0);
    switch (src_sig & PARROT_ARG_TYPE_MASK) {
        case PARROT_ARG_FLOATVAL:
            i = src_pc[2];
            if ((src_sig & PARROT_ARG_CONSTANT)) {
                f_arg = constants[i]->u.number;
            }
            else {
                f_arg = BP_REG_NUM(bp, i);
            }
            return f_arg;
        case PARROT_ARG_PMC:
            i = src_pc[2];
            if ((src_sig & PARROT_ARG_CONSTANT)) {
                p_arg = constants[i]->u.key;
            }
            else {
                p_arg = BP_REG_PMC(bp, i);
            }
            return VTABLE_get_number(interpreter, p_arg);
        default:
            real_exception(interpreter, NULL, E_ValueError,
                    "argument type mismatch");
    }
    return 0.0;
}

/*

=item C<void *
Parrot_run_meth_fromc(Parrot_Interp, PMC *sub, PMC *obj, STRING *meth)>

Run a method sub from C. The function arguments are
already setup according to Parrot calling conventions, the C<sub> argument
is an invocable C<Sub> PMC.

If registers a PMC return values, it is returned.

=cut

*/



/*

=item C<void *
Parrot_runops_fromc_args(Parrot_Interp interpreter, PMC *sub,
        const char *sig, ...)>

=item C<INTVAL
Parrot_runops_fromc_args_reti(Parrot_Interp interpreter, PMC *sub,
        const char *sig, ...)>

=item C<FLOATVAL
Parrot_runops_fromc_args_retf(Parrot_Interp interpreter, PMC *sub,
        const char *sig, ...)>

=item C<void *
Parrot_runops_fromc_arglist(Parrot_Interp interpreter, PMC *sub,
        const char *sig, va_list args)>

=item C<void *
Parrot_run_meth_fromc_args(Parrot_Interp interpreter, PMC *sub,
        PMC* obj, STRING* meth, const char *sig, ...)>

=item C<INTVAL
Parrot_run_meth_fromc_args_reti(Parrot_Interp interpreter, PMC *sub,
        PMC* obj, STRING* meth, const char *sig, ...)>

=item C<FLOATVAL
Parrot_run_meth_fromc_args_retf(Parrot_Interp interpreter, PMC *sub,
        PMC* obj, STRING* meth, const char *sig, ...)>

Run parrot ops, called from C code, function arguments are passed as
C<va_args> according to the signature. The C<sub> argument is an
invocable C<Sub> PMC.

Signatures are similar to NCI:

    v ... void return
    I ... INTVAL (not Interpreter)
    N ... NUMVAL
    S ... STRING*
    P ... PMC*

=cut

*/

void *
Parrot_run_meth_fromc(Parrot_Interp interpreter,
        PMC *sub, PMC *obj, STRING *meth)
{
    struct parrot_regs_t *bp;
    opcode_t offset, *dest;

    interpreter->current_cont = new_ret_continuation_pmc(interpreter, NULL);
    interpreter->current_object = obj;
    dest = VTABLE_invoke(interpreter, sub, (void*)1);
    if (!dest)
        internal_exception(1, "Subroutine returned a NULL address");
    bp = interpreter->ctx.bp;
    offset = dest - interpreter->code->base.data;
    runops(interpreter, offset);
    return set_retval(interpreter, 0, PMC_sub(sub)->seg, bp);
}

void *
Parrot_runops_fromc_args(Parrot_Interp interpreter, PMC *sub,
        const char *sig, ...)
{
    va_list args;
    struct parrot_regs_t *bp;

    va_start(args, sig);
    bp = runops_args(interpreter, sub, PMCNULL, NULL, sig, args);
    va_end(args);
    return set_retval(interpreter, *sig, PMC_sub(sub)->seg, bp);
}


INTVAL
Parrot_runops_fromc_args_reti(Parrot_Interp interpreter, PMC *sub,
        const char *sig, ...)
{
    va_list args;
    struct parrot_regs_t *bp;

    va_start(args, sig);
    bp = runops_args(interpreter, sub, PMCNULL, NULL, sig, args);
    va_end(args);
    return set_retval_i(interpreter, *sig, PMC_sub(sub)->seg, bp);
}

FLOATVAL
Parrot_runops_fromc_args_retf(Parrot_Interp interpreter, PMC *sub,
        const char *sig, ...)
{
    va_list args;
    struct parrot_regs_t *bp;

    va_start(args, sig);
    bp = runops_args(interpreter, sub, PMCNULL, NULL, sig, args);
    va_end(args);
    return set_retval_f(interpreter, *sig, PMC_sub(sub)->seg, bp);
}

void*
Parrot_run_meth_fromc_args(Parrot_Interp interpreter,
        PMC *sub, PMC *obj, STRING *meth, const char *sig, ...)
{
    va_list args;
    struct parrot_regs_t *bp;

    va_start(args, sig);
    bp = runops_args(interpreter, sub, obj, meth, sig, args);
    va_end(args);
    return set_retval(interpreter, *sig, PMC_sub(sub)->seg, bp);
}

INTVAL
Parrot_run_meth_fromc_args_reti(Parrot_Interp interpreter,
        PMC *sub, PMC *obj, STRING *meth, const char *sig, ...)
{
    va_list args;
    struct parrot_regs_t *bp;

    va_start(args, sig);
    bp = runops_args(interpreter, sub, obj, meth, sig, args);
    va_end(args);
    return set_retval_i(interpreter, *sig, PMC_sub(sub)->seg, bp);
}

FLOATVAL
Parrot_run_meth_fromc_args_retf(Parrot_Interp interpreter,
        PMC *sub, PMC *obj, STRING *meth, const char *sig, ...)
{
    va_list args;
    struct parrot_regs_t *bp;

    va_start(args, sig);
    bp = runops_args(interpreter, sub, obj, meth, sig, args);
    va_end(args);
    return set_retval_f(interpreter, *sig, PMC_sub(sub)->seg, bp);
}

void *
Parrot_runops_fromc_arglist(Parrot_Interp interpreter, PMC *sub,
        const char *sig, va_list args)
{
    struct parrot_regs_t *bp;

    bp = runops_args(interpreter, sub, PMCNULL, NULL, sig, args);
    return set_retval(interpreter, *sig, PMC_sub(sub)->seg, bp);
}

INTVAL
Parrot_runops_fromc_arglist_reti(Parrot_Interp interpreter, PMC *sub,
        const char *sig, va_list args)
{
    struct parrot_regs_t *bp;

    bp = runops_args(interpreter, sub, PMCNULL, NULL, sig, args);
    return set_retval_i(interpreter, *sig, PMC_sub(sub)->seg, bp);
}

FLOATVAL
Parrot_runops_fromc_arglist_retf(Parrot_Interp interpreter, PMC *sub,
        const char *sig, va_list args)
{
    struct parrot_regs_t *bp;

    bp = runops_args(interpreter, sub, PMCNULL, NULL, sig, args);
    return set_retval_f(interpreter, *sig, PMC_sub(sub)->seg, bp);
}

void*
Parrot_run_meth_fromc_arglist(Parrot_Interp interpreter,
        PMC *sub, PMC *obj, STRING *meth, const char *sig, va_list args)
{
    struct parrot_regs_t *bp;

    bp = runops_args(interpreter, sub, obj, meth, sig, args);
    return set_retval(interpreter, *sig, PMC_sub(sub)->seg, bp);
}

INTVAL
Parrot_run_meth_fromc_arglist_reti(Parrot_Interp interpreter,
        PMC *sub, PMC *obj, STRING *meth, const char *sig, va_list args)
{
    struct parrot_regs_t *bp;

    bp = runops_args(interpreter, sub, obj, meth, sig, args);
    return set_retval_i(interpreter, *sig, PMC_sub(sub)->seg, bp);
}

FLOATVAL
Parrot_run_meth_fromc_arglist_retf(Parrot_Interp interpreter,
        PMC *sub, PMC *obj, STRING *meth, const char *sig, va_list args)
{
    struct parrot_regs_t *bp;

    bp = runops_args(interpreter, sub, obj, meth, sig, args);
    return set_retval_f(interpreter, *sig, PMC_sub(sub)->seg, bp);
}

/*

=back

=head1 SEE ALSO

F<include/parrot/interpreter.h>, F<src/interpreter.c>.

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
