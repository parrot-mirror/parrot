/* call.h
 *  Copyright (C) 2001-2008, Parrot Foundation.
 *  SVN Info
 *  $Id$
 *  Overview:
 *  Data Structure and Algorithms:
 *     Call argument handling.
 *  History:
 *     Initial version by leo on 2005/07/22
 *     Major changes by mdiep in April 2007
 *  Notes:
 *  References:
 *     pdd03 - Calling Conventions
 */

#ifndef PARROT_INTER_CALL_H_GUARD
#define PARROT_INTER_CALL_H_GUARD

#include "parrot/context.h"

/* Wrap the jump buffer in a struct, to make it a linked list. Jump buffers are
 * used to resume execution at a point in the runloop where an exception
 * handler can be run. Ultimately this information should be part of
 * Parrot_Context, but at this point a new context isn't created for every
 * runloop ID, so it still needs to be a separate stack for a while longer. */

typedef struct parrot_runloop_t {
    struct parrot_runloop_t *prev;          /* interpreter's runloop
                                             * jump buffer stack */
    opcode_t                *handler_start; /* Used in exception handling */

    /* let the biggest element cross the cacheline boundary */
    Parrot_jump_buff         resume;        /* jmp_buf */
} parrot_runloop_t;

typedef parrot_runloop_t Parrot_runloop;

typedef enum {
    CALLSIGNATURE_is_exception_FLAG      = PObj_private0_FLAG,
} callsignature_flags_enum;

#define CALLSIGNATURE_get_FLAGS(o) (PObj_get_FLAGS(o))
#define CALLSIGNATURE_flag_TEST(flag, o) (CALLSIGNATURE_get_FLAGS(o) & CALLSIGNATURE_ ## flag ## _FLAG)
#define CALLSIGNATURE_flag_SET(flag, o) (CALLSIGNATURE_get_FLAGS(o) |= CALLSIGNATURE_ ## flag ## _FLAG)
#define CALLSIGNATURE_flag_CLEAR(flag, o) (CALLSIGNATURE_get_FLAGS(o) &= ~(UINTVAL)(CALLSIGNATURE_ ## flag ## _FLAG))

/* Mark if the CallSignature is for an exception handler */
#define CALLSIGNATURE_is_exception_TEST(o)  CALLSIGNATURE_flag_TEST(is_exception, (o))
#define CALLSIGNATURE_is_exception_SET(o)   CALLSIGNATURE_flag_SET(is_exception, (o))
#define CALLSIGNATURE_is_exception_CLEAR(o) CALLSIGNATURE_flag_CLEAR(is_exception, (o))

/* HEADERIZER BEGIN: src/call/pcc.c */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

PARROT_EXPORT
void Parrot_pcc_invoke_from_sig_object(PARROT_INTERP,
    ARGIN(PMC *sub_obj),
    ARGIN(PMC *call_object))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_EXPORT
void Parrot_pcc_invoke_method_from_c_args(PARROT_INTERP,
    ARGIN(PMC* pmc),
    ARGMOD(STRING *method_name),
    ARGIN(const char *signature),
    ...)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        FUNC_MODIFIES(*method_name);

PARROT_EXPORT
void Parrot_pcc_invoke_sub_from_c_args(PARROT_INTERP,
    ARGIN(PMC *sub_obj),
    ARGIN(const char *sig),
    ...)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_EXPORT
void Parrot_PCCINVOKE(PARROT_INTERP,
    ARGIN(PMC* pmc),
    ARGMOD(STRING *method_name),
    ARGIN(const char *signature),
    ...)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        FUNC_MODIFIES(*method_name);

#define ASSERT_ARGS_Parrot_pcc_invoke_from_sig_object \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(sub_obj) \
    , PARROT_ASSERT_ARG(call_object))
#define ASSERT_ARGS_Parrot_pcc_invoke_method_from_c_args \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(pmc) \
    , PARROT_ASSERT_ARG(method_name) \
    , PARROT_ASSERT_ARG(signature))
#define ASSERT_ARGS_Parrot_pcc_invoke_sub_from_c_args \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(sub_obj) \
    , PARROT_ASSERT_ARG(sig))
#define ASSERT_ARGS_Parrot_PCCINVOKE __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(pmc) \
    , PARROT_ASSERT_ARG(method_name) \
    , PARROT_ASSERT_ARG(signature))
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: src/call/pcc.c */

/* HEADERIZER BEGIN: src/call/ops.c */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

PARROT_EXPORT
void free_runloop_jump_point(PARROT_INTERP)
        __attribute__nonnull__(1);

PARROT_EXPORT
void new_runloop_jump_point(PARROT_INTERP)
        __attribute__nonnull__(1);

void destroy_runloop_jump_points(PARROT_INTERP)
        __attribute__nonnull__(1);

void really_destroy_runloop_jump_points(
    ARGIN_NULLOK(Parrot_runloop *jump_point));

void runops(PARROT_INTERP, size_t offs)
        __attribute__nonnull__(1);

#define ASSERT_ARGS_free_runloop_jump_point __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_new_runloop_jump_point __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_destroy_runloop_jump_points __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_really_destroy_runloop_jump_points \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (0)
#define ASSERT_ARGS_runops __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: src/call/ops.c */

/* HEADERIZER BEGIN: src/call/args.c */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PMC* Parrot_pcc_build_sig_object_from_op(PARROT_INTERP,
    ARGIN_NULLOK(PMC *signature),
    ARGIN(PMC * const raw_sig),
    ARGIN(opcode_t * const raw_args))
        __attribute__nonnull__(1)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4);

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PMC* Parrot_pcc_build_sig_object_from_varargs(PARROT_INTERP,
    ARGIN_NULLOK(PMC *obj),
    ARGIN(const char *sig),
    va_list args)
        __attribute__nonnull__(1)
        __attribute__nonnull__(3);

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
PMC* Parrot_pcc_build_sig_object_returns_from_op(PARROT_INTERP,
    ARGIN_NULLOK(PMC *signature),
    ARGIN(PMC *raw_sig),
    ARGIN(opcode_t *raw_args))
        __attribute__nonnull__(1)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4);

PARROT_EXPORT
void Parrot_pcc_fill_params_from_c_args(PARROT_INTERP,
    ARGMOD(PMC *call_object),
    ARGIN(const char *signature),
    ...)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*call_object);

PARROT_EXPORT
void Parrot_pcc_fill_params_from_op(PARROT_INTERP,
    ARGMOD_NULLOK(PMC *call_object),
    ARGIN(PMC *raw_sig),
    ARGIN(opcode_t *raw_params))
        __attribute__nonnull__(1)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        FUNC_MODIFIES(*call_object);

PARROT_EXPORT
void Parrot_pcc_fill_returns_from_c_args(PARROT_INTERP,
    ARGMOD_NULLOK(PMC *call_object),
    ARGIN(const char *signature),
    ...)
        __attribute__nonnull__(1)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*call_object);

PARROT_EXPORT
void Parrot_pcc_fill_returns_from_continuation(PARROT_INTERP,
    ARGMOD_NULLOK(PMC *call_object),
    ARGIN(PMC *raw_sig),
    ARGIN(PMC *from_call_obj))
        __attribute__nonnull__(1)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        FUNC_MODIFIES(*call_object);

PARROT_EXPORT
void Parrot_pcc_fill_returns_from_op(PARROT_INTERP,
    ARGMOD_NULLOK(PMC *call_object),
    ARGIN(PMC *raw_sig),
    ARGIN(opcode_t *raw_returns))
        __attribute__nonnull__(1)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        FUNC_MODIFIES(*call_object);

void Parrot_pcc_merge_signature_for_tailcall(PARROT_INTERP,
    ARGMOD(PMC * parent),
    ARGMOD(PMC * tailcall))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(* parent)
        FUNC_MODIFIES(* tailcall);

PARROT_CAN_RETURN_NULL
void Parrot_pcc_parse_signature_string(PARROT_INTERP,
    ARGIN(STRING *signature),
    ARGMOD(PMC **arg_flags),
    ARGMOD(PMC **return_flags))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        FUNC_MODIFIES(*arg_flags)
        FUNC_MODIFIES(*return_flags);

#define ASSERT_ARGS_Parrot_pcc_build_sig_object_from_op \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(raw_sig) \
    , PARROT_ASSERT_ARG(raw_args))
#define ASSERT_ARGS_Parrot_pcc_build_sig_object_from_varargs \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(sig))
#define ASSERT_ARGS_Parrot_pcc_build_sig_object_returns_from_op \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(raw_sig) \
    , PARROT_ASSERT_ARG(raw_args))
#define ASSERT_ARGS_Parrot_pcc_fill_params_from_c_args \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(call_object) \
    , PARROT_ASSERT_ARG(signature))
#define ASSERT_ARGS_Parrot_pcc_fill_params_from_op \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(raw_sig) \
    , PARROT_ASSERT_ARG(raw_params))
#define ASSERT_ARGS_Parrot_pcc_fill_returns_from_c_args \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(signature))
#define ASSERT_ARGS_Parrot_pcc_fill_returns_from_continuation \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(raw_sig) \
    , PARROT_ASSERT_ARG(from_call_obj))
#define ASSERT_ARGS_Parrot_pcc_fill_returns_from_op \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(raw_sig) \
    , PARROT_ASSERT_ARG(raw_returns))
#define ASSERT_ARGS_Parrot_pcc_merge_signature_for_tailcall \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(parent) \
    , PARROT_ASSERT_ARG(tailcall))
#define ASSERT_ARGS_Parrot_pcc_parse_signature_string \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(signature) \
    , PARROT_ASSERT_ARG(arg_flags) \
    , PARROT_ASSERT_ARG(return_flags))
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: src/call/args.c */

#define ASSERT_SIG_PMC(sig) do {\
    PARROT_ASSERT(!PMC_IS_NULL(sig)); \
    PARROT_ASSERT(PObj_is_PMC_TEST(sig)); \
    PARROT_ASSERT((sig)->vtable->base_type == enum_class_FixedIntegerArray); \
} while (0)

/* XXX Remove interp from this */
#define ADD_OP_VAR_PART(interp, seg, pc, n) do { \
    if (*(pc) == PARROT_OP_set_args_pc || \
            *(pc) == PARROT_OP_get_results_pc || \
            *(pc) == PARROT_OP_get_params_pc || \
            *(pc) == PARROT_OP_set_returns_pc) { \
        PMC * const sig = (seg)->const_table->constants[(pc)[1]]->u.key; \
        (n) += VTABLE_elements((interp), sig); \
    } \
} while (0)

/* Context manipulating functions */

/* HEADERIZER BEGIN: src/call/context.c */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

PARROT_EXPORT
void Parrot_clear_i(PARROT_INTERP)
        __attribute__nonnull__(1);

PARROT_EXPORT
void Parrot_clear_n(PARROT_INTERP)
        __attribute__nonnull__(1);

PARROT_EXPORT
void Parrot_clear_p(PARROT_INTERP)
        __attribute__nonnull__(1);

PARROT_EXPORT
void Parrot_clear_s(PARROT_INTERP)
        __attribute__nonnull__(1);

PARROT_EXPORT
PARROT_CANNOT_RETURN_NULL
struct PackFile_Constant ** Parrot_pcc_constants(PARROT_INTERP,
    ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
UINTVAL Parrot_pcc_dec_recursion_depth(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_pcc_errors_off(PARROT_INTERP, ARGIN(PMC *ctx), UINTVAL flags)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_pcc_errors_on(PARROT_INTERP, ARGIN(PMC *ctx), UINTVAL flags)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
UINTVAL Parrot_pcc_errors_test(PARROT_INTERP,
    ARGIN(PMC *ctx),
    UINTVAL flags)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
PMC* Parrot_pcc_get_caller_ctx(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
Parrot_Context* Parrot_pcc_get_context_struct(PARROT_INTERP,
    ARGIN_NULLOK(PMC *ctx))
        __attribute__nonnull__(1);

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
PMC* Parrot_pcc_get_continuation(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CANNOT_RETURN_NULL
FLOATVAL * Parrot_pcc_get_FLOATVAL_reg(PARROT_INTERP,
    ARGIN(PMC *ctx),
    UINTVAL idx)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
PMC* Parrot_pcc_get_handlers(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
INTVAL Parrot_pcc_get_HLL(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
INTVAL Parrot_pcc_get_int_constant(PARROT_INTERP,
    ARGIN(PMC *ctx),
    INTVAL idx)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CANNOT_RETURN_NULL
INTVAL * Parrot_pcc_get_INTVAL_reg(PARROT_INTERP,
    ARGIN(PMC *ctx),
    UINTVAL idx)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CANNOT_RETURN_NULL
PMC* Parrot_pcc_get_lex_pad(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
PMC* Parrot_pcc_get_namespace(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
FLOATVAL Parrot_pcc_get_num_constant(PARROT_INTERP,
    ARGIN(PMC *ctx),
    INTVAL idx)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
PMC* Parrot_pcc_get_object(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
PMC* Parrot_pcc_get_outer_ctx(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
opcode_t* Parrot_pcc_get_pc(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
PMC* Parrot_pcc_get_pmc_constant(PARROT_INTERP, ARGIN(PMC *ctx), INTVAL idx)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CANNOT_RETURN_NULL
PMC ** Parrot_pcc_get_PMC_reg(PARROT_INTERP, ARGIN(PMC *ctx), UINTVAL idx)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
size_t Parrot_pcc_get_pred_offset(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
UINTVAL Parrot_pcc_get_recursion_depth(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CANNOT_RETURN_NULL
Regs_ni* Parrot_pcc_get_regs_ni(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CANNOT_RETURN_NULL
Regs_ps* Parrot_pcc_get_regs_ps(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
UINTVAL Parrot_pcc_get_regs_used(PARROT_INTERP, ARGIN(PMC *ctx), int type)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
opcode_t* Parrot_pcc_get_results(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
PMC* Parrot_pcc_get_results_signature(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
PMC* Parrot_pcc_get_signature(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
STRING* Parrot_pcc_get_string_constant(PARROT_INTERP,
    ARGIN(PMC *ctx),
    INTVAL idx)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CANNOT_RETURN_NULL
STRING ** Parrot_pcc_get_STRING_reg(PARROT_INTERP,
    ARGIN(PMC *ctx),
    UINTVAL idx)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
PMC* Parrot_pcc_get_sub(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
UINTVAL Parrot_pcc_inc_recursion_depth(PARROT_INTERP, ARGIN(PMC *ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_pcc_set_caller_ctx(PARROT_INTERP,
    ARGIN(PMC *ctx),
    ARGIN(PMC *caller_ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
void Parrot_pcc_set_constants(PARROT_INTERP,
    ARGIN(PMC *ctx),
    ARGIN_NULLOK(struct PackFile_Constant **constants))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_pcc_set_continuation(PARROT_INTERP,
    ARGIN(PMC *ctx),
    ARGIN_NULLOK(PMC *_continuation))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_pcc_set_handlers(PARROT_INTERP,
    ARGIN(PMC *ctx),
    ARGIN(PMC *handlers))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_EXPORT
void Parrot_pcc_set_HLL(PARROT_INTERP, ARGIN(PMC *ctx), INTVAL hll)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_pcc_set_lex_pad(PARROT_INTERP,
    ARGIN(PMC *ctx),
    ARGIN(PMC *lex_pad))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_EXPORT
void Parrot_pcc_set_namespace(PARROT_INTERP,
    ARGIN(PMC *ctx),
    ARGIN_NULLOK(PMC *_namespace))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_pcc_set_object(PARROT_INTERP,
    ARGIN(PMC *ctx),
    ARGIN_NULLOK(PMC *object))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_pcc_set_outer_ctx(PARROT_INTERP,
    ARGIN(PMC *ctx),
    ARGIN(PMC *outer_ctx))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_EXPORT
void Parrot_pcc_set_pc(PARROT_INTERP,
    ARGIN(PMC *ctx),
    ARGIN_NULLOK(opcode_t *pc))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_pcc_set_pred_offset(PARROT_INTERP,
    ARGIN(PMC *ctx),
    size_t pred_offset)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
PARROT_CANNOT_RETURN_NULL
void Parrot_pcc_set_regs_ni(PARROT_INTERP,
    ARGIN(PMC *ctx),
    ARGIN(Regs_ni *bp))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_EXPORT
PARROT_CANNOT_RETURN_NULL
void Parrot_pcc_set_regs_ps(PARROT_INTERP,
    ARGIN(PMC *ctx),
    ARGIN(Regs_ps *bp_ps))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_EXPORT
void Parrot_pcc_set_regs_used(PARROT_INTERP,
    ARGIN(PMC *ctx),
    int type,
    INTVAL num)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_pcc_set_results(PARROT_INTERP,
    ARGIN(PMC *ctx),
    ARGIN_NULLOK(opcode_t *pc))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_pcc_set_results_signature(PARROT_INTERP,
    ARGIN(PMC *ctx),
    ARGIN_NULLOK(PMC *sig))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_pcc_set_signature(PARROT_INTERP,
    ARGIN(PMC *ctx),
    ARGIN_NULLOK(PMC *sig_object))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_pcc_set_sub(PARROT_INTERP,
    ARGIN(PMC *ctx),
    ARGIN_NULLOK(PMC *sub))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_pcc_trace_flags_off(PARROT_INTERP,
    ARGIN(PMC *ctx),
    UINTVAL flags)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_pcc_trace_flags_on(PARROT_INTERP,
    ARGIN(PMC *ctx),
    UINTVAL flags)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
UINTVAL Parrot_pcc_trace_flags_test(PARROT_INTERP,
    ARGIN(PMC *ctx),
    UINTVAL flags)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_pcc_warnings_off(PARROT_INTERP, ARGIN(PMC *ctx), UINTVAL flags)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
UINTVAL Parrot_pcc_warnings_on(PARROT_INTERP,
    ARGIN(PMC *ctx),
    UINTVAL flags)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
UINTVAL Parrot_pcc_warnings_test(PARROT_INTERP,
    ARGIN(PMC *ctx),
    UINTVAL flags)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_pop_context(PARROT_INTERP)
        __attribute__nonnull__(1);

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PMC * Parrot_push_context(PARROT_INTERP, ARGIN(const INTVAL *n_regs_used))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

void create_initial_context(PARROT_INTERP)
        __attribute__nonnull__(1);

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
PMC * Parrot_alloc_context(PARROT_INTERP,
    ARGIN(const INTVAL *number_regs_used),
    ARGIN_NULLOK(PMC *old))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

size_t Parrot_pcc_calculate_context_size(SHIM_INTERP,
    ARGIN(const UINTVAL *number_regs_used))
        __attribute__nonnull__(2);

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
PMC * Parrot_set_new_context(PARROT_INTERP,
    ARGIN(const INTVAL *number_regs_used))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

#define ASSERT_ARGS_Parrot_clear_i __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_Parrot_clear_n __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_Parrot_clear_p __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_Parrot_clear_s __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_Parrot_pcc_constants __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_dec_recursion_depth \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_errors_off __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_errors_on __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_errors_test __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_caller_ctx __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_context_struct __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_Parrot_pcc_get_continuation __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_FLOATVAL_reg __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_handlers __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_HLL __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_int_constant __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_INTVAL_reg __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_lex_pad __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_namespace __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_num_constant __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_object __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_outer_ctx __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_pc __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_pmc_constant __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_PMC_reg __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_pred_offset __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_recursion_depth \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_regs_ni __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_regs_ps __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_regs_used __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_results __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_results_signature \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_signature __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_string_constant \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_STRING_reg __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_get_sub __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_inc_recursion_depth \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_set_caller_ctx __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx) \
    , PARROT_ASSERT_ARG(caller_ctx))
#define ASSERT_ARGS_Parrot_pcc_set_constants __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_set_continuation __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_set_handlers __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx) \
    , PARROT_ASSERT_ARG(handlers))
#define ASSERT_ARGS_Parrot_pcc_set_HLL __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_set_lex_pad __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx) \
    , PARROT_ASSERT_ARG(lex_pad))
#define ASSERT_ARGS_Parrot_pcc_set_namespace __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_set_object __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_set_outer_ctx __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx) \
    , PARROT_ASSERT_ARG(outer_ctx))
#define ASSERT_ARGS_Parrot_pcc_set_pc __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_set_pred_offset __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_set_regs_ni __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx) \
    , PARROT_ASSERT_ARG(bp))
#define ASSERT_ARGS_Parrot_pcc_set_regs_ps __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx) \
    , PARROT_ASSERT_ARG(bp_ps))
#define ASSERT_ARGS_Parrot_pcc_set_regs_used __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_set_results __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_set_results_signature \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_set_signature __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_set_sub __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_trace_flags_off __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_trace_flags_on __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_trace_flags_test __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_warnings_off __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_warnings_on __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pcc_warnings_test __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ctx))
#define ASSERT_ARGS_Parrot_pop_context __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_Parrot_push_context __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(n_regs_used))
#define ASSERT_ARGS_create_initial_context __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_Parrot_alloc_context __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(number_regs_used))
#define ASSERT_ARGS_Parrot_pcc_calculate_context_size \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(number_regs_used))
#define ASSERT_ARGS_Parrot_set_new_context __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(number_regs_used))
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: src/call/context.c */

#endif /* PARROT_INTER_CALL_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
