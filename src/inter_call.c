/*
Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
$Id$

=head1 NAME

src/inter_call.c - Parrot Interpreter - Argument passing code

=head1 DESCRIPTION

Functions in this file handle argument/return value passing to and from
subroutines.

=head2 Functions

=over 4

=cut

*/


#include <assert.h>
#include "parrot/parrot.h"
#include "parrot/oplib/ops.h"
#include "inter_call.str"

/*
 * argument call helper functions
 *
 * call_set_arg_X ... set passed value in slurp_array (if any) or into
 *                    a register with proper argument conversion
 */
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

/*

=item C<opcode_t * parrot_pass_args(Interp *, struct PackFile_ByteCode *dst_seg struct parrot_regs_t *caller_regs, int what)>

Main argument passing routine.

Prelims: code segments aren't yet switched, so that the current
constants are still that of the caller.  The destination context is
already created and set, C<caller_regs> point to the caller's
registers. C<dst_seg> has the constants of the destination.

C<what> is either C<PARROT_OP_get_params_pc> or C<PARROT_OP_get_results_pc>.
With the former arguments are passed from the caller into a subroutine,
the latter handles return values and yields.

=cut

*/


#ifdef PREMATURE_OPT

#undef VTABLE_elements
#define VTABLE_elements(i, ar) PMC_int_val(ar)
#undef VTABLE_get_integer_keyed_int
#define VTABLE_get_integer_keyed_int(i, ar, idx) ((INTVAL*)PMC_data(ar))[idx]

#endif

opcode_t *
parrot_pass_args(Interp *interpreter, struct PackFile_ByteCode *dst_seg,
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
    int opt_so_far;

    _array = CONST_STRING(interpreter, "array");
    constants = interpreter->code->const_table->constants;
    if (what == PARROT_OP_get_params_pc) {
        dst_pc = interpreter->current_params;
        src_pc = CONTEXT(interpreter->ctx)->current_args;
        interpreter->current_params = NULL;
        args_op = PARROT_OP_set_args_pc;
        action = "params";
    }
    else {
        dst_pc = CONTEXT(interpreter->ctx)->current_results;
        if (!dst_pc)
            return NULL;
        args_op = PARROT_OP_set_returns_pc;
        src_pc = interpreter->current_returns;
        action = "results";
        if (!src_pc) {    /* no returns */
            /* continuation call with args
             *
             * we move current_args into context the first time
             * and use the context var for further get_params
             * so that we can clean current_args and make this
             * less ambiguous
             */
            src_pc = interpreter->current_args;
            if (!src_pc)
                return NULL;
            args_op = PARROT_OP_set_args_pc;
            action = "params";
        }
    }

    assert(*dst_pc == what);
    dst_signature = dst_seg->const_table->constants[dst_pc[1]]->u.key;
    assert(PObj_is_PMC_TEST(dst_signature));
    assert(dst_signature->vtable->base_type == enum_class_FixedIntegerArray);

    /* we point to the set_args opcode */
    if (!src_pc) {    /* no args process optionals */
        src_n = 0;
    }
    else {
        assert(*src_pc == args_op);
        src_signature = constants[src_pc[1]]->u.key;
        assert(PObj_is_PMC_TEST(src_signature));
        assert(src_signature->vtable->base_type == enum_class_FixedIntegerArray);

        src_n = VTABLE_elements(interpreter, src_signature);
    }
    /* never get more then the caller expects */
    dst_n = VTABLE_elements(interpreter, dst_signature);
    slurp_ar = NULL;
    opt_so_far = 0;
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
        if (dst_sig & PARROT_ARG_OPTIONAL) {
            ++opt_so_far;
        }
        else if (dst_sig & PARROT_ARG_OPT_COUNT) {
            --src_i;    /* don't consume an argument */
            if (dst_typ != PARROT_ARG_INTVAL)
                real_exception(interpreter, NULL, E_ValueError,
                        ":opt_count is not an int");
            call_set_arg_I(interpreter, opt_so_far, NULL, dst_typ,
                    dst_pc[dst_i]);
            opt_so_far = 0;
            continue;

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
    for (; dst_i < dst_n; ++dst_i) {
        dst_sig = VTABLE_get_integer_keyed_int(interpreter,
                dst_signature, dst_i);
        dst_typ = dst_sig & PARROT_ARG_TYPE_MASK;
        if (dst_sig & PARROT_ARG_OPT_COUNT) {
            if (dst_typ != PARROT_ARG_INTVAL)
                real_exception(interpreter, NULL, E_ValueError,
                        ":opt_count is not an int");
            call_set_arg_I(interpreter, opt_so_far, NULL, dst_typ,
                    dst_pc[dst_i]);
            opt_so_far = 0;
        }
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
    /* skip the get_params opcode - all done here */
    return dst_pc + dst_n;
}

/*

=item C<opcode_t *parrot_pass_args_fromc(Interp *, const char *sig,
INTVAL src_n, opcode_t *dest, parrot_context_t * ctxp, va_list ap)>

Pass arguments from C code with given signature to a Parrot Sub.
Prerequsits are like above.

=cut

*/
opcode_t *
parrot_pass_args_fromc(Interp *interpreter, const char *sig, INTVAL src_n,
        opcode_t *dest, parrot_context_t * ctxp, va_list ap)
{
    PMC  *dst_signature, *slurp_ar;
    struct PackFile_Constant **constants;
    INTVAL dst_i, dst_n, dst_typ, dst_sig;
    opcode_t *dst_pc;
    INTVAL i_arg;
    FLOATVAL f_arg;
    PMC *p_arg;
    STRING *s_arg;
    int opt_so_far;
    parrot_context_t old_ctx = *ctxp;

    if (dest[0] != PARROT_OP_get_params_pc) {
        real_exception(interpreter, NULL, E_ValueError,
                "no get_params in sub");
    }

    constants = interpreter->code->const_table->constants;
    dst_pc = dest;
    dst_signature = constants[dst_pc[1]]->u.key;
    assert(PObj_is_PMC_TEST(dst_signature));
    assert(dst_signature->vtable->base_type == enum_class_FixedIntegerArray);
    dst_n = VTABLE_elements(interpreter, dst_signature);

    slurp_ar = NULL;
    opt_so_far = 0;
    dst_pc += 2;

    for (dst_i = 0; *sig && dst_i < dst_n; ++sig, ++dst_i) {
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
        if (dst_sig & PARROT_ARG_OPTIONAL) {
            ++opt_so_far;
        }
        else if (dst_sig & PARROT_ARG_OPT_COUNT) {
            --sig;    /* don't consume an argument */
            if (dst_typ != PARROT_ARG_INTVAL)
                real_exception(interpreter, NULL, E_ValueError,
                        ":opt_count is not an int");
            call_set_arg_I(interpreter, opt_so_far, NULL, dst_typ,
                    dst_pc[dst_i]);
            opt_so_far = 0;
            continue;

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
    for (; dst_i < dst_n; ++dst_i) {
        dst_sig = VTABLE_get_integer_keyed_int(interpreter,
                dst_signature, dst_i);
        dst_typ = dst_sig & PARROT_ARG_TYPE_MASK;
        if (dst_sig & PARROT_ARG_OPT_COUNT) {
            if (dst_typ != PARROT_ARG_INTVAL)
                real_exception(interpreter, NULL, E_ValueError,
                        ":opt_count is not an int");
            call_set_arg_I(interpreter, opt_so_far, NULL, dst_typ,
                    dst_pc[dst_i]);
            opt_so_far = 0;
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
                dst_signature, dst_i);
        if (!(dst_sig & (PARROT_ARG_OPTIONAL|PARROT_ARG_SLURPY_ARRAY))) {
            real_exception(interpreter, NULL, E_ValueError,
                    "too few arguments passed (%d) - %d params expected",
                    src_n, dst_n);
        }
    }

    dest += dst_n + 2;
    return dest;
}

/*
 * handle void, and pointer (PMC*, STRING*) return values
 * only conversions to and from PMCs are done
 */
void*
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

    src_pc = interpreter->current_returns;
    interpreter->current_returns = NULL;
    if (!sig_ret || sig_ret == 'v')
        return NULL;
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
            switch (sig_ret) {
                case 'S':  return s_arg;
                case 'P':
                           {
                               PMC *d = pmc_new(interpreter,
                                       Parrot_get_ctx_HLL_type(interpreter,
                                           enum_class_String));
                               VTABLE_set_string_native(interpreter, d, s_arg);
                               return d;
                           }
                default:
                           real_exception(interpreter, NULL, E_ValueError,
                                   "argument type mismatch");
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
                case 'P':  return p_arg;
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

/*
 * handle INTVAL return value
 * only conversions from PMCs are done
 */
INTVAL
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
                "return signature not 'I'");
    }
    src_pc = interpreter->current_returns;
    interpreter->current_returns = NULL;
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

/*
 * handle FLOATVAL return value
 * only conversions from PMCs are done
 */
FLOATVAL
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
                "return signature not 'N'");
    }
    src_pc = interpreter->current_returns;
    interpreter->current_returns = NULL;
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

=back

=head1 SEE ALSO

F<include/parrot/interpreter.h>, F<src/inter_run.c>, F<classes/sub.pmc>.

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
