/*
Copyright (C) 2001-2009, Parrot Foundation.
$Id: pcc.c 41637 2009-10-03 14:46:07Z jkeenan $

=head1 Arguments and Returns

=head1 Description

Functions in this file handle argument/return value passing to and from
subroutines following the Parrot Calling Conventions.

=head2 Functions

=over 4

=cut

*/

#include "parrot/parrot.h"
#include "parrot/oplib/ops.h"
#include "parrot/runcore_api.h"
#include "args.str"

/* HEADERIZER HFILE: include/parrot/call.h */

/* HEADERIZER BEGIN: static */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

static void dissect_aggregate_arg(PARROT_INTERP,
    ARGMOD(PMC *call_object),
    ARGIN(PMC *aggregate))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*call_object);

static void extract_named_arg_from_op(PARROT_INTERP,
    ARGMOD(PMC *call_object),
    ARGIN(STRING *name),
    ARGIN(PMC * const raw_sig),
    ARGIN(opcode_t * const raw_args),
    INTVAL arg_index)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        __attribute__nonnull__(5)
        FUNC_MODIFIES(*call_object);

PARROT_CAN_RETURN_NULL
static void parse_signature_string(PARROT_INTERP,
    ARGIN(const char *signature),
    ARGMOD(PMC **arg_flags),
    ARGMOD(PMC **return_flags))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        FUNC_MODIFIES(*arg_flags)
        FUNC_MODIFIES(*return_flags);

#define ASSERT_ARGS_dissect_aggregate_arg __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(call_object) \
    , PARROT_ASSERT_ARG(aggregate))
#define ASSERT_ARGS_extract_named_arg_from_op __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(call_object) \
    , PARROT_ASSERT_ARG(name) \
    , PARROT_ASSERT_ARG(raw_sig) \
    , PARROT_ASSERT_ARG(raw_args))
#define ASSERT_ARGS_parse_signature_string __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(signature) \
    , PARROT_ASSERT_ARG(arg_flags) \
    , PARROT_ASSERT_ARG(return_flags))
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: static */

/*

=item C<PMC* Parrot_pcc_build_sig_object_from_op(PARROT_INTERP, PMC *signature,
PMC * const raw_sig, opcode_t * const raw_args)>

Take a raw signature and argument list from a set_args opcode and
convert it to a CallSignature PMC.

=cut

*/

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PMC*
Parrot_pcc_build_sig_object_from_op(PARROT_INTERP, ARGIN_NULLOK(PMC *signature),
        ARGIN(PMC * const raw_sig), ARGIN(opcode_t * const raw_args))
{
    ASSERT_ARGS(Parrot_pcc_build_sig_object_from_op)
    PMC            *call_object;
    INTVAL          arg_index;
    INTVAL          arg_count  = VTABLE_elements(interp, raw_sig);
    PMC            *ctx        = CURRENT_CONTEXT(interp);
    STRING         *string_sig = Parrot_str_new(interp, "", 0);

    if (PMC_IS_NULL(signature)) {
        call_object = pmc_new(interp, enum_class_CallSignature);
        gc_register_pmc(interp, call_object);
    }
    else
        call_object = signature;

    VTABLE_set_attr_str(interp, call_object, CONST_STRING(interp, "arg_flags"), raw_sig);

    for (arg_index = 0; arg_index < arg_count; arg_index++) {
        INTVAL arg_flags = VTABLE_get_integer_keyed_int(interp,
                    raw_sig, arg_index);

        const INTVAL constant  = PARROT_ARG_CONSTANT_ISSET(arg_flags);
        const INTVAL raw_index = raw_args[arg_index + 2];

        switch (PARROT_ARG_TYPE_MASK_MASK(arg_flags)) {
            case PARROT_ARG_INTVAL:
                string_sig = Parrot_str_append(interp, string_sig, CONST_STRING(interp, "I"));
                if (constant)
                    VTABLE_push_integer(interp, call_object, raw_index);
                else {
                    const INTVAL int_value = CTX_REG_INT(ctx, raw_index);
                    VTABLE_push_integer(interp, call_object, int_value);
                }
                break;
            case PARROT_ARG_FLOATVAL:
                string_sig = Parrot_str_append(interp, string_sig, CONST_STRING(interp, "N"));
                if (constant)
                    VTABLE_push_float(interp, call_object,
                            Parrot_pcc_get_num_constant(interp, ctx, raw_index));
                else {
                    const FLOATVAL float_value = CTX_REG_NUM(ctx, raw_index);
                    VTABLE_push_float(interp, call_object, float_value);
                }
                break;
            case PARROT_ARG_STRING:
            {
                STRING *string_value;
                string_sig = Parrot_str_append(interp, string_sig, CONST_STRING(interp, "S"));
                if (constant)
                    /* ensure that callees don't modify constant caller strings */
                    string_value = Parrot_str_new_COW(interp,
                            Parrot_pcc_get_string_constant(interp, ctx, raw_index));
                else
                    string_value = CTX_REG_STR(ctx, raw_index);

                if (arg_flags & PARROT_ARG_NAME) {
                    string_sig = Parrot_str_append(interp, string_sig, CONST_STRING(interp, "n"));
                    arg_index++;
                    extract_named_arg_from_op(interp, call_object, string_value,
                            raw_sig, raw_args, arg_index);
                }
                else
                    VTABLE_push_string(interp, call_object, string_value);

                break;
            }
            case PARROT_ARG_PMC:
            {
                PMC *pmc_value;
                string_sig = Parrot_str_append(interp, string_sig, CONST_STRING(interp, "P"));
                if (constant)
                    pmc_value = Parrot_pcc_get_pmc_constant(interp, ctx, raw_index);
                else
                    pmc_value = CTX_REG_PMC(ctx, raw_index);

                if (arg_flags & PARROT_ARG_FLATTEN) {
                    dissect_aggregate_arg(interp, call_object, pmc_value);
                    string_sig = Parrot_str_append(interp, string_sig, CONST_STRING(interp, "f"));
                }
                else
                    VTABLE_push_pmc(interp, call_object, CTX_REG_PMC(ctx, raw_index));

                break;
            }
            default:
                break;
        }

    }

    VTABLE_set_string_native(interp, call_object, string_sig);
    return call_object;
}

/*

=item C<static void extract_named_arg_from_op(PARROT_INTERP, PMC *call_object,
STRING *name, PMC * const raw_sig, opcode_t * const raw_args, INTVAL arg_index)>

Pulls in the next argument from a set_args opcode, and sets it as the
value of a named argument in the CallSignature PMC.

=cut

*/

static void
extract_named_arg_from_op(PARROT_INTERP, ARGMOD(PMC *call_object), ARGIN(STRING *name),
        ARGIN(PMC * const raw_sig), ARGIN(opcode_t * const raw_args),
        INTVAL arg_index)
{
    ASSERT_ARGS(extract_named_arg_from_op)
    PMC   *ctx       = CURRENT_CONTEXT(interp);
    INTVAL arg_flags = VTABLE_get_integer_keyed_int(interp,
                    raw_sig, arg_index);

    const INTVAL constant  = PARROT_ARG_CONSTANT_ISSET(arg_flags);
    const INTVAL raw_index = raw_args[arg_index + 2];
    STRING      *string_sig = VTABLE_get_string(interp, call_object);

    switch (PARROT_ARG_TYPE_MASK_MASK(arg_flags)) {
        case PARROT_ARG_INTVAL:
            string_sig = Parrot_str_append(interp, string_sig, CONST_STRING(interp, "I"));
            if (constant)
                VTABLE_set_integer_keyed_str(interp, call_object, name, raw_index);
            else
                VTABLE_set_integer_keyed_str(interp, call_object, name,
                        CTX_REG_INT(ctx, raw_index));
            break;
        case PARROT_ARG_FLOATVAL:
            string_sig = Parrot_str_append(interp, string_sig, CONST_STRING(interp, "N"));
            if (constant)
                VTABLE_set_number_keyed_str(interp, call_object, name,
                        Parrot_pcc_get_num_constant(interp, ctx, raw_index));
            else
                VTABLE_set_number_keyed_str(interp, call_object, name,
                        CTX_REG_NUM(ctx, raw_index));
            break;
        case PARROT_ARG_STRING:
            string_sig = Parrot_str_append(interp, string_sig, CONST_STRING(interp, "S"));
            if (constant)
                /* ensure that callees don't modify constant caller strings */
                VTABLE_set_string_keyed_str(interp, call_object, name,
                        Parrot_str_new_COW(interp,
                                Parrot_pcc_get_string_constant(interp, ctx, raw_index)));
            else
                VTABLE_set_string_keyed_str(interp, call_object, name,
                        CTX_REG_STR(ctx, raw_index));
            break;
        case PARROT_ARG_PMC:
            string_sig = Parrot_str_append(interp, string_sig, CONST_STRING(interp, "P"));
            if (constant)
                VTABLE_set_pmc_keyed_str(interp, call_object, name,
                        Parrot_pcc_get_pmc_constant(interp, ctx, raw_index));
            else
                VTABLE_set_pmc_keyed_str(interp, call_object, name,
                        CTX_REG_PMC(ctx, raw_index));
            break;
        default:
            break;
    }

    VTABLE_set_string_native(interp, call_object, string_sig);
}

/*

=item C<static void dissect_aggregate_arg(PARROT_INTERP, PMC *call_object, PMC
*aggregate)>

Takes an aggregate PMC and splits it up into individual arguments,
adding each one to the CallSignature PMC. If the aggregate is an array,
its elements are added as positional arguments. If the aggregate is a
hash, its key/value pairs are added as named arguments.

=cut

*/

static void
dissect_aggregate_arg(PARROT_INTERP, ARGMOD(PMC *call_object), ARGIN(PMC *aggregate))
{
    ASSERT_ARGS(dissect_aggregate_arg)

    if (VTABLE_does(interp, aggregate, CONST_STRING(interp, "array"))) {
        INTVAL elements = VTABLE_elements(interp, aggregate);
        INTVAL index;
        for (index = 0; index < elements; index++) {
            VTABLE_push_pmc(interp, call_object,
                    VTABLE_get_pmc_keyed_int(interp, aggregate, index));
        }
    }
    else if (VTABLE_does(interp, aggregate, CONST_STRING(interp, "hash"))) {
        INTVAL elements = VTABLE_elements(interp, aggregate);
        INTVAL index;
        PMC *key = pmc_new(interp, enum_class_Key);
        VTABLE_set_integer_native(interp, key, 0);
        SETATTR_Key_next_key(interp, key, (PMC *)INITBucketIndex);

        /* Low-level hash iteration. */
        for (index = 0; index < elements; index++) {
            if (!PMC_IS_NULL(key)) {
                STRING *name = (STRING *)parrot_hash_get_idx(interp,
                                (Hash *)VTABLE_get_pointer(interp, aggregate), key);
                PARROT_ASSERT(name);
                VTABLE_set_pmc_keyed_str(interp, call_object, name,
                    VTABLE_get_pmc_keyed_str(interp, aggregate, name));
            }
        }
    }
    else {
        Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
                "flattened parameters must be a hash or array");
    }

}

/*

=item C<PMC* Parrot_pcc_build_sig_object_returns_from_op(PARROT_INTERP, PMC
*signature, PMC *raw_sig, opcode_t *raw_args)>

Take a raw signature and argument list from a set_results opcode and
convert it to a CallSignature PMC. Uses an existing CallSignature PMC if
one was already created for set_args. Otherwise, creates a new one.

=cut

*/

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
PMC*
Parrot_pcc_build_sig_object_returns_from_op(PARROT_INTERP, ARGIN_NULLOK(PMC *signature),
        ARGIN(PMC *raw_sig), ARGIN(opcode_t *raw_args))
{
    ASSERT_ARGS(Parrot_pcc_build_sig_object_returns_from_op)
    PMC            *call_object;
    STRING         *string_sig;
    INTVAL          arg_index;
    INTVAL          arg_count = VTABLE_elements(interp, raw_sig);
    PMC            *ctx       = CURRENT_CONTEXT(interp);
    PMC            *returns   = pmc_new(interp, enum_class_ResizablePMCArray);

    if (PMC_IS_NULL(signature)) {
        call_object = pmc_new(interp, enum_class_CallSignature);
        gc_register_pmc(interp, call_object);
    }
    else
        call_object = signature;

    string_sig = VTABLE_get_string(interp, call_object);

    /* A hack to support 'get_results' as the way of fetching the
     * exception object inside an exception handler. The first argument
     * in the call object is the exception, stick it directly into the
     * destination register. */
    if (CALLSIGNATURE_is_exception_TEST(call_object)) {
        const INTVAL raw_index = raw_args[2];
        CTX_REG_PMC(ctx, raw_index) =
                VTABLE_get_pmc_keyed_int(interp, call_object, 0);
        return NULL;
    }

    VTABLE_set_attr_str(interp, call_object, CONST_STRING(interp, "return_flags"), raw_sig);
    VTABLE_set_attr_str(interp, call_object, CONST_STRING(interp, "returns"), returns);
    string_sig = Parrot_str_append(interp, string_sig, CONST_STRING(interp, "->"));

    for (arg_index = 0; arg_index < arg_count; arg_index++) {
        STRING * const signature = CONST_STRING(interp, "signature");
        INTVAL arg_flags = VTABLE_get_integer_keyed_int(interp,
                    raw_sig, arg_index);
        const INTVAL raw_index = raw_args[arg_index + 2];

        /* Returns store a pointer to the register, so they can pass
         * the result back to the caller. */
        PMC * const val_pointer = pmc_new(interp, enum_class_CPointer);
        VTABLE_push_pmc(interp, returns, val_pointer);

        switch (PARROT_ARG_TYPE_MASK_MASK(arg_flags)) {
            case PARROT_ARG_INTVAL:
                string_sig = Parrot_str_append(interp, string_sig, CONST_STRING(interp, "I"));
                VTABLE_set_pointer(interp, val_pointer, (void *) &(CTX_REG_INT(ctx, raw_index)));
                VTABLE_set_string_keyed_str(interp, val_pointer, signature, CONST_STRING(interp, "I"));
                break;
            case PARROT_ARG_FLOATVAL:
                string_sig = Parrot_str_append(interp, string_sig, CONST_STRING(interp, "N"));
                VTABLE_set_pointer(interp, val_pointer, (void *) &(CTX_REG_NUM(ctx, raw_index)));
                VTABLE_set_string_keyed_str(interp, val_pointer, signature, CONST_STRING(interp, "N"));
                break;
            case PARROT_ARG_STRING:
                string_sig = Parrot_str_append(interp, string_sig, CONST_STRING(interp, "S"));
                VTABLE_set_pointer(interp, val_pointer, (void *) &(CTX_REG_STR(ctx, raw_index)));
                VTABLE_set_string_keyed_str(interp, val_pointer, signature, CONST_STRING(interp, "S"));
                break;
            case PARROT_ARG_PMC:
                string_sig = Parrot_str_append(interp, string_sig, CONST_STRING(interp, "P"));
                VTABLE_set_pointer(interp, val_pointer, (void *) &(CTX_REG_PMC(ctx, raw_index)));
                VTABLE_set_string_keyed_str(interp, val_pointer, signature, CONST_STRING(interp, "P"));
                break;
            default:
                break;
        }

    }

    VTABLE_set_string_native(interp, call_object, string_sig);
    return call_object;
}

/*

=item C<PMC* Parrot_pcc_build_sig_object_from_varargs(PARROT_INTERP, PMC *obj,
const char *sig, va_list args)>

Converts a varargs list into a CallSignature PMC. The CallSignature stores the
original short signature string and an array of integer types to pass on to the
multiple dispatch search.

=cut

*/

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PMC*
Parrot_pcc_build_sig_object_from_varargs(PARROT_INTERP, ARGIN_NULLOK(PMC *obj),
        ARGIN(const char *sig), va_list args)
{
    ASSERT_ARGS(Parrot_pcc_build_sig_object_from_varargs)
    PMC         *type_tuple         = PMCNULL;
    PMC         *returns            = PMCNULL;
    PMC         *arg_flags     = PMCNULL;
    PMC         *return_flags  = PMCNULL;
    PMC         * const call_object = pmc_new(interp, enum_class_CallSignature);
    STRING      *string_sig         = Parrot_str_new_constant(interp, sig);
    const INTVAL sig_len            = Parrot_str_byte_length(interp, string_sig);
    INTVAL       in_return_sig      = 0;
    INTVAL       i;

    if (!sig_len)
        return call_object;

    VTABLE_set_string_native(interp, call_object, string_sig);
    parse_signature_string(interp, sig, &arg_flags, &return_flags);
    VTABLE_set_attr_str(interp, call_object, CONST_STRING(interp, "arg_flags"), arg_flags);
    VTABLE_set_attr_str(interp, call_object, CONST_STRING(interp, "return_flags"), return_flags);

    /* Process the varargs list */
    for (i = 0; i < sig_len; ++i) {
        const INTVAL type = Parrot_str_indexed(interp, string_sig, i);

        /* Only create the returns array if it's needed */
        if (in_return_sig && PMC_IS_NULL(returns)) {
            returns = pmc_new(interp, enum_class_ResizablePMCArray);
            VTABLE_set_attr_str(interp, call_object, CONST_STRING(interp, "returns"), returns);
        }

        if (in_return_sig) {
            STRING * const signature = CONST_STRING(interp, "signature");
            /* Returns store the original passed-in pointer so they can pass
             * the result back to the caller. */
            PMC * const val_pointer = pmc_new(interp, enum_class_CPointer);
            VTABLE_push_pmc(interp, returns, val_pointer);

            switch (type) {
                case 'I':
                    VTABLE_set_pointer(interp, val_pointer, (void *)va_arg(args, INTVAL *));
                    VTABLE_set_string_keyed_str(interp, val_pointer, signature, CONST_STRING(interp, "I"));
                    break;
                case 'N':
                    VTABLE_set_pointer(interp, val_pointer, (void *)va_arg(args, FLOATVAL *));
                    VTABLE_set_string_keyed_str(interp, val_pointer, signature, CONST_STRING(interp, "N"));
                    break;
                case 'S':
                    VTABLE_set_pointer(interp, val_pointer, (void *)va_arg(args, STRING **));
                    VTABLE_set_string_keyed_str(interp, val_pointer, signature, CONST_STRING(interp, "S"));
                    break;
                case 'P':
                    VTABLE_set_pointer(interp, val_pointer, (void *)va_arg(args, PMC **));
                    VTABLE_set_string_keyed_str(interp, val_pointer, signature, CONST_STRING(interp, "P"));
                    break;
                default:
                    Parrot_ex_throw_from_c_args(interp, NULL,
                        EXCEPTION_INVALID_OPERATION,
                        "Dispatch: invalid argument type %c!", type);
             }
        }
        else {
            /* Regular arguments just set the value */
            switch (type) {
                case 'I':
                    VTABLE_push_integer(interp, call_object, va_arg(args, INTVAL));
                    break;
                case 'N':
                    VTABLE_push_float(interp, call_object, va_arg(args, FLOATVAL));
                    break;
                case 'S':
                    VTABLE_push_string(interp, call_object, va_arg(args, STRING *));
                    break;
                case 'P':
                {
                    INTVAL type_lookahead = Parrot_str_indexed(interp, string_sig, (i + 1));
                    PMC * const pmc_arg = va_arg(args, PMC *);
                    VTABLE_push_pmc(interp, call_object, pmc_arg);
                    if (type_lookahead == 'i') {
                        if (i != 0)
                            Parrot_ex_throw_from_c_args(interp, NULL,
                                EXCEPTION_INVALID_OPERATION,
                                "Dispatch: only the first argument can be an invocant");
                        i++; /* skip 'i' */
                    }
                    break;
                }
                case '-':
                    i++; /* skip '>' */
                    in_return_sig = 1;
                    break;
                default:
                    Parrot_ex_throw_from_c_args(interp, NULL,
                        EXCEPTION_INVALID_OPERATION,
                        "Dispatch: invalid argument type %c!", type);
            }
        }
    }

    /* Check if we have an invocant, and add it to the front of the arguments */
    if (!PMC_IS_NULL(obj)) {
        string_sig = Parrot_str_concat(interp, CONST_STRING(interp, "Pi"), string_sig, 0);
        VTABLE_set_string_native(interp, call_object, string_sig);
        VTABLE_unshift_pmc(interp, call_object, obj);
    }

    /* Build a type_tuple for multiple dispatch */
    type_tuple = Parrot_mmd_build_type_tuple_from_sig_obj(interp, call_object);
    VTABLE_set_pmc(interp, call_object, type_tuple);

    return call_object;
}

/*

=item C<void Parrot_pcc_fill_params_from_op(PARROT_INTERP, PMC *call_object, PMC
*raw_sig, opcode_t *raw_params)>

Gets args for the current function call and puts them into position.
First it gets the positional non-slurpy parameters, then the positional
slurpy parameters, then the named parameters, and finally the named
slurpy parameters.

=cut

*/

PARROT_EXPORT
void
Parrot_pcc_fill_params_from_op(PARROT_INTERP, ARGMOD_NULLOK(PMC *call_object),
        ARGIN(PMC *raw_sig), ARGIN(opcode_t *raw_params))
{
    ASSERT_ARGS(Parrot_pcc_fill_params_from_op)
    PMC    *ctx = CURRENT_CONTEXT(interp);
    INTVAL  param_count    = VTABLE_elements(interp, raw_sig);
    INTVAL  positional_elements;
    STRING *param_name     = NULL;
    INTVAL  param_index    = 0;
    INTVAL  positional_index = 0;
    INTVAL  named_count    = 0;
    INTVAL  slurpy_count   = 0;
    INTVAL  optional_count = 0;
    INTVAL  err_check      = 0;
    INTVAL  got_optional   = -1;

    /* Check if we should be throwing errors. This is configured separately
     * for parameters and return values. */
    if (PARROT_ERRORS_test(interp, PARROT_ERRORS_PARAM_COUNT_FLAG))
            err_check = 1;

    /* A null call object is fine if there are no arguments and no returns. */
    if (PMC_IS_NULL(call_object)) {
        if (param_count > 0) {
            if (err_check)
                Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
                        "too few arguments: 0 passed, %d expected",
                        param_count);
            else
                return;
        }
    }

    positional_elements = VTABLE_elements(interp, call_object);

    for (param_index = 0; param_index < param_count; param_index++) {
        INTVAL param_flags = VTABLE_get_integer_keyed_int(interp,
                    raw_sig, param_index);

        const INTVAL raw_index = raw_params[param_index + 2];

        /* If it's also optional, set that info */
        if (param_flags & PARROT_ARG_OPTIONAL) {
            got_optional = 1;
            optional_count++;
        }

        /* opt_flag parameter */
        if (param_flags & PARROT_ARG_OPT_FLAG) {
            if (optional_count <= 0)
                Parrot_ex_throw_from_c_args(interp, NULL,
                        EXCEPTION_INVALID_OPERATION,
                        "optional flag with no optional parameter");
            if (got_optional < 0 || got_optional > 1)
                Parrot_ex_throw_from_c_args(interp, NULL,
                        EXCEPTION_INVALID_OPERATION,
                        "unable to determine if optional argument was passed");

            CTX_REG_INT(ctx, raw_index) = got_optional;
            got_optional = -1;
            continue; /* on to next parameter */
        }
        /* Collected ("slurpy") parameter */
        else if (param_flags & PARROT_ARG_SLURPY_ARRAY) {
            /* Collect named arguments into hash */
            if (param_flags & PARROT_ARG_NAME) {
                PMC * const collect_named = pmc_new(interp,
                        Parrot_get_ctx_HLL_type(interp, enum_class_Hash));

                CTX_REG_PMC(ctx, raw_index) = collect_named;
                named_count += VTABLE_elements(interp, collect_named);
            }
            /* Collect positional arguments into array */
            else {
                PMC *collect_positional;
                if (named_count > 0)
                    Parrot_ex_throw_from_c_args(interp, NULL,
                            EXCEPTION_INVALID_OPERATION,
                            "named parameters must follow all positional parameters");
                collect_positional = pmc_new(interp,
                        Parrot_get_ctx_HLL_type(interp, enum_class_ResizablePMCArray));
                for (; positional_index < positional_elements; positional_index++) {
                    VTABLE_push_pmc(interp, collect_positional,
                            VTABLE_get_pmc_keyed_int(interp, call_object, positional_index));
                }
                CTX_REG_PMC(ctx, raw_index) = collect_positional;
            }

            continue; /* on to next parameter */
        }
        /* Named non-collected */
        else if (param_flags & PARROT_ARG_NAME) {
            /* Just store the name for now (this parameter is only the
             * name). The next parameter is the actual value. */
            param_name = PARROT_ARG_CONSTANT_ISSET(param_flags)
                               ? Parrot_pcc_get_string_constant(interp, ctx, raw_index)
                               : CTX_REG_STR(ctx, raw_index);

            continue;
        }
        else if (!STRING_IS_NULL(param_name)) {
            /* The previous parameter was a parameter name. Now set the
             * value of the named parameter.*/

            if (VTABLE_exists_keyed_str(interp, call_object, param_name)) {
                named_count++;

                switch (PARROT_ARG_TYPE_MASK_MASK(param_flags)) {
                    case PARROT_ARG_INTVAL:
                        CTX_REG_INT(ctx, raw_index) =
                                VTABLE_get_integer_keyed_str(interp, call_object, param_name);
                        break;
                    case PARROT_ARG_FLOATVAL:
                        CTX_REG_NUM(ctx, raw_index) =
                                VTABLE_get_number_keyed_str(interp, call_object, param_name);
                        break;
                    case PARROT_ARG_STRING:
                        CTX_REG_STR(ctx, raw_index) =
                                VTABLE_get_string_keyed_str(interp, call_object, param_name);
                        break;
                    case PARROT_ARG_PMC:
                        CTX_REG_PMC(ctx, raw_index) =
                                VTABLE_get_pmc_keyed_str(interp, call_object, param_name);
                        break;
                    default:
                        Parrot_ex_throw_from_c_args(interp, NULL,
                                EXCEPTION_INVALID_OPERATION, "invalid parameter type");
                        break;
                }
                param_name = NULL;
                continue; /* on to next parameter */
            }

            /* If the named parameter doesn't have a corresponding named
             * argument, fall through to positional argument handling. */
            param_name = NULL;
        }

        /* Positional non-collected */
        if (named_count > 0)
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
                    "named parameters must follow all positional parameters");
        if (slurpy_count > 0)
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
                    "slurpy parameters must follow ordinary positional parameters");

        /* No more positional arguments available to assign */
        if (positional_index >= positional_elements) {
            if (!(param_flags & PARROT_ARG_OPTIONAL))
                Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
                        "too few positional arguments: %d passed, %d (or more) expected",
                        positional_elements, param_index + 1);

            got_optional = 0;
            optional_count++;
            switch (PARROT_ARG_TYPE_MASK_MASK(param_flags)) {
                case PARROT_ARG_INTVAL:
                    CTX_REG_INT(ctx, raw_index) = 0;
                    break;
                case PARROT_ARG_FLOATVAL:
                    CTX_REG_NUM(ctx, raw_index) = 0.0;
                    break;
                case PARROT_ARG_STRING:
                    CTX_REG_STR(ctx, raw_index) = NULL;
                    break;
                case PARROT_ARG_PMC:
                    CTX_REG_PMC(ctx, raw_index) = PMCNULL;
                    break;
                default:
                    Parrot_ex_throw_from_c_args(interp, NULL,
                            EXCEPTION_INVALID_OPERATION, "invalid parameter type");
                    break;
            }

            continue; /* on to next parameter */
        }

        /* If last argument was an optional, but this arg isn't the
           corresponding opt_flag, reset the flag. */
        if (got_optional && !param_flags & PARROT_ARG_OPTIONAL)
            got_optional = -1;

        /* It's a (possibly optional) positional. Fill it. */
        switch (PARROT_ARG_TYPE_MASK_MASK(param_flags)) {
            case PARROT_ARG_INTVAL:
                CTX_REG_INT(ctx, raw_index) =
                        VTABLE_get_integer_keyed_int(interp, call_object, positional_index);
                positional_index++;
                break;
            case PARROT_ARG_FLOATVAL:
                CTX_REG_NUM(ctx, raw_index) =
                        VTABLE_get_number_keyed_int(interp, call_object, positional_index);
                positional_index++;
                break;
            case PARROT_ARG_STRING:
                CTX_REG_STR(ctx, raw_index) =
                        VTABLE_get_string_keyed_int(interp, call_object, positional_index);
                positional_index++;
                break;
            case PARROT_ARG_PMC:
                CTX_REG_PMC(ctx, raw_index) =
                        VTABLE_get_pmc_keyed_int(interp, call_object, positional_index);
                positional_index++;
                break;
            default:
                Parrot_ex_throw_from_c_args(interp, NULL,
                        EXCEPTION_INVALID_OPERATION, "invalid parameter type");
                break;
        }
    }

    if (err_check && (positional_elements > positional_index))
        Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
                "too many positional arguments: %d passed, %d expected",
                positional_elements, param_count);

}

/*

=item C<void Parrot_pcc_fill_params_from_c_args(PARROT_INTERP, PMC *call_object,
const char *signature, ...)>

Gets args for the current function call and puts them into position.
First it gets the positional non-slurpy parameters, then the positional
slurpy parameters, then the named parameters, and finally the named
slurpy parameters.

The signature is a string in the format used for
C<Parrot_pcc_invoke_from_sig_object>, but with no return arguments. The
parameters are passed in as a list of references to the destination
variables.

=cut

*/

PARROT_EXPORT
void
Parrot_pcc_fill_params_from_c_args(PARROT_INTERP, ARGMOD(PMC *call_object),
        ARGIN(const char *signature), ...)
{
    ASSERT_ARGS(Parrot_pcc_fill_params_from_c_args)
    va_list args;
    PMC *ctx = CURRENT_CONTEXT(interp);
    INTVAL  positional_elements;
    INTVAL  param_count      = 0;
    STRING *param_name       = NULL;
    INTVAL  param_index      = 0;
    INTVAL  positional_index = 0;
    INTVAL  named_count      = 0;
    INTVAL  slurpy_count     = 0;
    INTVAL  optional_count   = 0;
    INTVAL  err_check        = 0;
    INTVAL  got_optional     = -1;
    PMC    *raw_sig  = PMCNULL;
    PMC    *invalid_sig = PMCNULL;

    parse_signature_string(interp, signature, &raw_sig, &invalid_sig);
    if (!PMC_IS_NULL(invalid_sig))
        Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
                "returns should not be included in the parameter list");
    param_count = VTABLE_elements(interp, raw_sig);

    /* Check if we should be throwing errors. This is configured separately
     * for parameters and return values. */
    if (PARROT_ERRORS_test(interp, PARROT_ERRORS_PARAM_COUNT_FLAG))
            err_check = 1;

    /* A null call object is fine if there are no arguments and no returns. */
    if (PMC_IS_NULL(call_object)) {
        if (param_count > 0) {
            if (err_check)
                Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
                        "too few arguments: 0 passed, %d expected",
                        param_count);
            else
                return;
        }
    }

    positional_elements = VTABLE_elements(interp, call_object);

    va_start(args, signature);
    for (param_index = 0; param_index < param_count; param_index++) {
        INTVAL param_flags = VTABLE_get_integer_keyed_int(interp,
                    raw_sig, param_index);

        if (param_flags & PARROT_ARG_OPTIONAL) {
            got_optional = 1;
            optional_count++;
        }

        /* opt_flag parameter */
        if (param_flags & PARROT_ARG_OPT_FLAG) {
            if (optional_count <= 0)
                Parrot_ex_throw_from_c_args(interp, NULL,
                        EXCEPTION_INVALID_OPERATION,
                        "optional flag with no optional parameter");
            if (got_optional < 0 || got_optional > 1)
                Parrot_ex_throw_from_c_args(interp, NULL,
                        EXCEPTION_INVALID_OPERATION,
                        "unable to determine if optional argument was passed");

            {
                INTVAL * const int_pointer = va_arg(args, INTVAL*);
                *int_pointer = got_optional;
            }
            got_optional = -1;
            continue; /* on to next parameter */
        }
        /* Collected ("slurpy") parameter */
        else if (param_flags & PARROT_ARG_SLURPY_ARRAY) {
            /* Collect named arguments into hash */
            if (param_flags & PARROT_ARG_NAME) {
                PMC * const collect_named = pmc_new(interp,
                        Parrot_get_ctx_HLL_type(interp, enum_class_Hash));

                {
                    PMC ** const pmc_pointer = va_arg(args, PMC**);
                    *pmc_pointer = collect_named;
                }
                named_count += VTABLE_elements(interp, collect_named);
            }
            /* Collect positional arguments into array */
            else {
                PMC *collect_positional;
                if (named_count > 0)
                    Parrot_ex_throw_from_c_args(interp, NULL,
                            EXCEPTION_INVALID_OPERATION,
                            "named parameters must follow all positional parameters");
                collect_positional = pmc_new(interp,
                        Parrot_get_ctx_HLL_type(interp, enum_class_ResizablePMCArray));
                for (; positional_index < positional_elements; positional_index++) {
                    VTABLE_push_pmc(interp, collect_positional,
                            VTABLE_get_pmc_keyed_int(interp, call_object, positional_index));
                }
                {
                    PMC ** const pmc_pointer = va_arg(args, PMC**);
                    *pmc_pointer = collect_positional;
                }
            }

            continue; /* on to next parameter */
        }
        /* Named non-collected */
        else if (param_flags & PARROT_ARG_NAME) {
            /* Just store the name for now (this parameter is only the
             * name). The next parameter is the actual value. */
            STRING ** const string_pointer = va_arg(args, STRING**);
            param_name = *string_pointer;

            continue; /* on to next parameter */
        }
        else if (!STRING_IS_NULL(param_name)) {
            /* The previous parameter was a parameter name. Now set the
             * value of the named parameter. Keep in mind that we have a
             fixed-length list of arguments, and we need to fill a value
             even if we haven't received one from the caller. */
            const int _value_exists = VTABLE_exists_keyed_str(interp, call_object, param_name);
            if (got_optional)
                got_optional = _value_exists;
            named_count++;

            switch (PARROT_ARG_TYPE_MASK_MASK(param_flags)) {
                case PARROT_ARG_INTVAL:
                    {
                        INTVAL * const int_pointer = va_arg(args, INTVAL*);
                        INTVAL int_value = 0;
                        if (_value_exists)
                            int_value = VTABLE_get_integer_keyed_str(
                                interp, call_object, param_name);
                        *int_pointer = int_value;
                    }
                    break;
                case PARROT_ARG_FLOATVAL:
                    {
                        FLOATVAL * const float_pointer = va_arg(args, FLOATVAL*);
                        FLOATVAL float_value = 0.0;
                        if (_value_exists)
                            float_value = VTABLE_get_number_keyed_str(
                                interp, call_object, param_name);
                        *float_pointer = float_value;
                    }
                    break;
                case PARROT_ARG_STRING:
                    {
                        STRING ** const string_pointer = va_arg(args, STRING**);
                        STRING * str_value = NULL;
                        if (_value_exists)
                            str_value = VTABLE_get_string_keyed_str(
                                interp, call_object, param_name);
                        *string_pointer = str_value;
                    }
                    break;
                case PARROT_ARG_PMC:
                    {
                        PMC ** const pmc_pointer = va_arg(args, PMC**);
                        PMC * next_pmc = PMCNULL;
                        if (_value_exists)
                            next_pmc = VTABLE_get_pmc_keyed_str(interp, call_object, param_name);
                        *pmc_pointer = next_pmc;
                    }
                    break;
                default:
                    Parrot_ex_throw_from_c_args(interp, NULL,
                            EXCEPTION_INVALID_OPERATION, "invalid parameter type");
                    break;
            }

            param_name = NULL;
            continue;
        }

        /* Positional non-collected */
        if (named_count > 0)
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
                    "named parameters must follow all positional parameters");
        if (slurpy_count > 0)
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
                    "slurpy parameters must follow ordinary positional parameters");

        /* No more positional arguments available to assign */
        if (positional_index >= positional_elements) {
            if (!param_flags & PARROT_ARG_OPTIONAL)
                Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
                        "too few positional arguments: %d passed, %d (or more) expected",
                        positional_elements, param_index + 1);

            got_optional = 0;
            optional_count++;
            switch (PARROT_ARG_TYPE_MASK_MASK(param_flags)) {
                case PARROT_ARG_INTVAL:
                    {
                        INTVAL * const int_pointer = va_arg(args, INTVAL*);
                        *int_pointer = 0;
                    }
                    break;
                case PARROT_ARG_FLOATVAL:
                    {
                        FLOATVAL * const float_pointer = va_arg(args, FLOATVAL*);
                        *float_pointer = 0.0;
                    }
                    break;
                case PARROT_ARG_STRING:
                    {
                        STRING ** const string_pointer = va_arg(args, STRING**);
                        *string_pointer = NULL;
                    }
                    break;
                case PARROT_ARG_PMC:
                    {
                        PMC ** const pmc_pointer = va_arg(args, PMC**);
                        *pmc_pointer = PMCNULL;
                    }
                    break;
                default:
                    Parrot_ex_throw_from_c_args(interp, NULL,
                            EXCEPTION_INVALID_OPERATION, "invalid parameter type");
                    break;
            }

            continue; /* on to next parameter */
        }

        /* If the last argument was an optional but this one isn't the
           corresponding opt_flag, reset the state info because we won't
           get it. */
        if (got_optional && !(param_flags & PARROT_ARG_OPTIONAL))
            got_optional = -1;

        switch (PARROT_ARG_TYPE_MASK_MASK(param_flags)) {
            case PARROT_ARG_INTVAL:
                {
                    INTVAL * const int_pointer = va_arg(args, INTVAL*);
                    *int_pointer =
                        VTABLE_get_integer_keyed_int(interp, call_object, positional_index);
                }
                positional_index++;
                break;
            case PARROT_ARG_FLOATVAL:
                {
                    FLOATVAL * const float_pointer = va_arg(args, FLOATVAL*);
                    *float_pointer =
                        VTABLE_get_number_keyed_int(interp, call_object, positional_index);
                }
                positional_index++;
                break;
            case PARROT_ARG_STRING:
                {
                    STRING ** const string_pointer = va_arg(args, STRING**);
                    STRING * const str_value =
                        VTABLE_get_string_keyed_int(interp, call_object, positional_index);
                    *string_pointer = str_value;
                }
                positional_index++;
                break;
            case PARROT_ARG_PMC:
                {
                    PMC ** const pmc_pointer = va_arg(args, PMC**);
                    PMC * const pmc_value =
                        VTABLE_get_pmc_keyed_int(interp, call_object, positional_index);
                    *pmc_pointer = pmc_value;
                }
                positional_index++;
                break;
            default:
                Parrot_ex_throw_from_c_args(interp, NULL,
                        EXCEPTION_INVALID_OPERATION, "invalid parameter type");
                break;
        }
    }
    va_end(args);
}

/*

=item C<void Parrot_pcc_fill_returns_from_op(PARROT_INTERP, PMC *call_object,
PMC *raw_sig, opcode_t *raw_returns)>

Sets return values for the current function call. First it sets the
positional returns, then the named returns.

=cut

*/

PARROT_EXPORT
void
Parrot_pcc_fill_returns_from_op(PARROT_INTERP, ARGMOD_NULLOK(PMC *call_object),
        ARGIN(PMC *raw_sig), ARGIN(opcode_t *raw_returns))
{
    ASSERT_ARGS(Parrot_pcc_fill_returns_from_op)
    INTVAL return_list_elements;
    PMC *ctx = CURRENT_CONTEXT(interp);
    PMC *return_list;
    PMC *caller_return_flags;
    INTVAL raw_return_count     = VTABLE_elements(interp, raw_sig);
    INTVAL return_index = 0;
    INTVAL return_list_index = 0;
    INTVAL err_check      = 0;

    /* Check if we should be throwing errors. This is configured separately
     * for parameters and return values. */
    if (PARROT_ERRORS_test(interp, PARROT_ERRORS_RESULT_COUNT_FLAG))
            err_check = 1;

    /* A null call object is fine if there are no arguments and no returns. */
    if (PMC_IS_NULL(call_object)) {
        if (raw_return_count > 0) {
            if (err_check)
                Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
                        "too many return values: %d passed, 0 expected",
                        raw_return_count);
            return;
        }
    }

    return_list = VTABLE_get_attr_str(interp, call_object, CONST_STRING(interp, "returns"));
    if (PMC_IS_NULL(return_list)) {
        if (raw_return_count > 0) {
            if (err_check)
                Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
                        "too many return values: %d passed, 0 expected",
                        raw_return_count);
            return;
        }
    }
    else
        return_list_elements = VTABLE_elements(interp, return_list);

    caller_return_flags = VTABLE_get_attr_str(interp, call_object, CONST_STRING(interp, "return_flags"));


    if (raw_return_count > return_list_elements) {
        if (err_check)
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
                    "too many return values: %d passed, %d expected",
                    raw_return_count, return_list_elements);
    }

    for (return_index = 0; return_index < raw_return_count; return_index++) {
        INTVAL return_flags = VTABLE_get_integer_keyed_int(interp,
                    raw_sig, return_index);
        INTVAL result_flags;

        const INTVAL constant  = PARROT_ARG_CONSTANT_ISSET(return_flags);
        const INTVAL raw_index = raw_returns[return_index + 2];
        PMC *result_item = VTABLE_get_pmc_keyed_int(interp, return_list, return_list_index);
        STRING *item_sig;

        /* Gracefully ignore extra returns when error checking is off. */
        if (PMC_IS_NULL(result_item))
            continue; /* Go on to next return arg. */

        result_flags = VTABLE_get_integer_keyed_int(interp, caller_return_flags, return_list_index);
        item_sig = VTABLE_get_string_keyed_str(interp, result_item, CONST_STRING(interp, ''));

        switch (PARROT_ARG_TYPE_MASK_MASK(return_flags)) {
            case PARROT_ARG_INTVAL:
                if (Parrot_str_equal(interp, item_sig, CONST_STRING(interp, "P"))) {
                    VTABLE_set_pmc(interp, result_item,
                            pmc_new(interp, Parrot_get_ctx_HLL_type(interp, enum_class_Integer)));
                }
                if (constant)
                    VTABLE_set_integer_native(interp, result_item, raw_index);
                else
                    VTABLE_set_integer_native(interp, result_item, CTX_REG_INT(ctx, raw_index));
                return_list_index++;
                break;
            case PARROT_ARG_FLOATVAL:
                if (Parrot_str_equal(interp, item_sig, CONST_STRING(interp, "P"))) {
                    VTABLE_set_pmc(interp, result_item,
                        pmc_new(interp, Parrot_get_ctx_HLL_type(interp, enum_class_Float)));
                }
                if (constant)
                    VTABLE_set_number_native(interp, result_item,
                            Parrot_pcc_get_num_constant(interp, ctx, raw_index));
                else
                    VTABLE_set_number_native(interp, result_item, CTX_REG_NUM(ctx, raw_index));
                return_list_index++;
                break;
            case PARROT_ARG_STRING:
                if (Parrot_str_equal(interp, item_sig, CONST_STRING(interp, "P"))) {
                    VTABLE_set_pmc(interp, result_item,
                            pmc_new(interp, Parrot_get_ctx_HLL_type(interp, enum_class_String)));
                }
                if (constant)
                    VTABLE_set_string_native(interp, result_item, Parrot_str_new_COW(interp,
                            Parrot_pcc_get_string_constant(interp, ctx, raw_index)));
                else
                    VTABLE_set_string_native(interp, result_item, CTX_REG_STR(ctx, raw_index));
                return_list_index++;
                break;
            case PARROT_ARG_PMC:
                if (constant)
                    VTABLE_set_pmc(interp, result_item,
                            Parrot_pcc_get_pmc_constant(interp, ctx, raw_index));
                else
                    VTABLE_set_pmc(interp, result_item, CTX_REG_PMC(ctx, raw_index));
                return_list_index++;
                break;
            default:
                Parrot_ex_throw_from_c_args(interp, NULL,
                        EXCEPTION_INVALID_OPERATION, "invalid parameter type");
                break;
        }
    }
}

/*

=item C<void Parrot_pcc_fill_returns_from_c_args(PARROT_INTERP, PMC
*call_object, const char *signature, ...)>

Sets return values for the current function call. First it sets the
positional returns, then the named returns.

The signature is a string in the format used for
C<Parrot_pcc_invoke_from_sig_object>, but with only return arguments.
The parameters are passed in as a list of INTVAL, FLOATVAL, STRING *, or
PMC * variables.


=cut

*/

PARROT_EXPORT
void
Parrot_pcc_fill_returns_from_c_args(PARROT_INTERP, ARGMOD(PMC *call_object),
        ARGIN(const char *signature), ...)
{
    ASSERT_ARGS(Parrot_pcc_fill_returns_from_c_args)
    va_list args;
    INTVAL return_list_elements;
    PMC *ctx = CURRENT_CONTEXT(interp);
    PMC * const return_list = VTABLE_get_attr_str(interp, call_object, CONST_STRING(interp, "returns"));
    INTVAL raw_return_count = 0;
    INTVAL return_index = 0;
    INTVAL return_list_index = 0;
    INTVAL err_check      = 0;

    PMC *raw_sig = PMCNULL;
    PMC *invalid_sig = PMCNULL;

    parse_signature_string(interp, signature, &raw_sig, &invalid_sig);
    if (!PMC_IS_NULL(invalid_sig))
        Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
                "parameters should not be included in the return signature");
    raw_return_count = VTABLE_elements(interp, raw_sig);

    /* Check if we should be throwing errors. This is configured separately
     * for parameters and return values. */
    if (PARROT_ERRORS_test(interp, PARROT_ERRORS_RESULT_COUNT_FLAG))
            err_check = 1;

    if (PMC_IS_NULL(return_list)) {
        if (err_check)
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
                    "too many return values: %d passed, 0 expected",
                    raw_return_count, return_list_elements);
        return;
    }
    else
        return_list_elements = VTABLE_elements(interp, return_list);


    if (raw_return_count > return_list_elements) {
        if (err_check)
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
                    "too many return values: %d passed, %d expected",
                    raw_return_count, return_list_elements);
    }

    va_start(args, signature);
    for (return_index = 0; return_index < raw_return_count; return_index++) {
        STRING *item_sig;
        INTVAL return_flags = VTABLE_get_integer_keyed_int(interp,
                    raw_sig, return_index);

        PMC *result_item = VTABLE_get_pmc_keyed_int(interp, return_list, return_list_index);

        /* Gracefully ignore extra returns when error checking is off. */
        if (PMC_IS_NULL(result_item))
            continue; /* Go on to next return arg. */

        item_sig = VTABLE_get_string_keyed_str(interp, result_item, CONST_STRING(interp, ''));

        switch (PARROT_ARG_TYPE_MASK_MASK(return_flags)) {
            case PARROT_ARG_INTVAL:
                if (Parrot_str_equal(interp, item_sig, CONST_STRING(interp, "P"))) {
                    VTABLE_set_pmc(interp, result_item, pmc_new(
                        interp, Parrot_get_ctx_HLL_type(interp, enum_class_Integer)));
                }
                VTABLE_set_integer_native(interp, result_item, va_arg(args, INTVAL));
                return_list_index++;
                break;
            case PARROT_ARG_FLOATVAL:
                if (Parrot_str_equal(interp, item_sig, CONST_STRING(interp, "P"))) {
                    VTABLE_set_pmc(interp, result_item, pmc_new(
                        interp, Parrot_get_ctx_HLL_type(interp, enum_class_Float)));
                }
                VTABLE_set_number_native(interp, result_item, va_arg(args, FLOATVAL));
                return_list_index++;
                break;
            case PARROT_ARG_STRING:
                if (Parrot_str_equal(interp, item_sig, CONST_STRING(interp, "P"))) {
                    VTABLE_set_pmc(interp, result_item, pmc_new(
                        interp, Parrot_get_ctx_HLL_type(interp, enum_class_String)));
                }
                VTABLE_set_string_native(interp, result_item,
                        Parrot_str_new_COW(interp, va_arg(args, STRING *)));
                return_list_index++;
                break;
            case PARROT_ARG_PMC:
                VTABLE_set_pmc(interp, result_item, va_arg(args, PMC *));
                return_list_index++;
                break;
            default:
                Parrot_ex_throw_from_c_args(interp, NULL,
                        EXCEPTION_INVALID_OPERATION, "invalid parameter type");
                break;
        }
    }
    va_end(args);
}

/*

=item C<static void parse_signature_string(PARROT_INTERP, const char *signature,
PMC **arg_flags, PMC **return_flags)>

Parses a signature string and creates call and return signature integer
arrays. The two integer arrays should be passed in as references to a
PMC.

=cut

*/

PARROT_CAN_RETURN_NULL
static void
parse_signature_string(PARROT_INTERP, ARGIN(const char *signature),
        ARGMOD(PMC **arg_flags), ARGMOD(PMC **return_flags))
{
    ASSERT_ARGS(parse_signature_string)
    PMC *current_array;
    const char *x;
    INTVAL flags = 0;
    INTVAL set = 0;

    if (PMC_IS_NULL(*arg_flags))
        *arg_flags = pmc_new(interp, enum_class_ResizableIntegerArray);
    current_array = *arg_flags;

    for (x = signature; *x != '\0'; x++) {

        /* detect -> separator */
        if (*x == '-') {
            /* skip '>' */
            x++;
            /* Switch to the return argument flags. */
            if (PMC_IS_NULL(*return_flags))
                *return_flags = pmc_new(interp, enum_class_ResizableIntegerArray);
            current_array = *return_flags;
        }
        /* parse arg type */
        else if (isupper((unsigned char)*x)) {
            /* Starting a new argument, so store the previous argument,
             * if there was one. */
            if (set) {
                VTABLE_push_integer(interp, current_array, flags);
                set = 0;
            }

            switch (*x) {
                case 'I': flags = PARROT_ARG_INTVAL;   set++; break;
                case 'N': flags = PARROT_ARG_FLOATVAL; set++; break;
                case 'S': flags = PARROT_ARG_STRING;   set++; break;
                case 'P': flags = PARROT_ARG_PMC;      set++; break;
                default:
                  Parrot_ex_throw_from_c_args(interp, NULL,
                    EXCEPTION_INVALID_OPERATION,
                    "invalid signature string element %c!", *x);
            }

        }
        /* parse arg adverbs */
        else if (islower((unsigned char)*x)) {
            switch (*x) {
                case 'c': flags |= PARROT_ARG_CONSTANT;     break;
                case 'f': flags |= PARROT_ARG_FLATTEN;      break;
                case 'i': flags |= PARROT_ARG_INVOCANT;     break;
                case 'l': flags |= PARROT_ARG_LOOKAHEAD;    break;
                case 'n': flags |= PARROT_ARG_NAME;         break;
                case 'o': flags |= PARROT_ARG_OPTIONAL;     break;
                case 'p': flags |= PARROT_ARG_OPT_FLAG;     break;
                case 's': flags |= PARROT_ARG_SLURPY_ARRAY; break;
                default:
                    Parrot_ex_throw_from_c_args(interp, NULL,
                        EXCEPTION_INVALID_OPERATION,
                        "invalid signature string element %c!", *x);
            }
        }
    }

    /* Store the final argument, if there was one. */
    if (set)
        VTABLE_push_integer(interp, current_array, flags);
}

/*

=back

=head1 SEE ALSO

F<include/parrot/call.h>, F<src/call/ops.c>, F<src/call/pcc.c>.

=cut

*/

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
