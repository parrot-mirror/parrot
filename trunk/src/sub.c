/*
Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
$Id$

=head1 NAME

src/sub.c - Subroutines

=head1 DESCRIPTION

Sub-routines, continuations, co-routines and other fun stuff...

=head2 Functions

=over 4

=cut

*/

#include "parrot/parrot.h"
#include "parrot/method_util.h"

/*

=item C<void
save_context(Interp *interp, struct Parrot_Context *ctx)>

Save the current "context" of interpreter.

=cut

*/

void
save_context(Interp *interp, struct Parrot_Context *ctx)
{
    memcpy(ctx, &interp->ctx, sizeof(*ctx));
}

/*

=item C<void
cow_copy_context(Interp *interp,
        struct Parrot_Context *dest, struct Parrot_Context *src)>

Save src context and mark it copy-on-write. We mark
the pads and stacks, not the actual context struct. This is used for
continuations. Stacks are COW marked to delay stack copying until
continuation is activated.

=cut

*/

void
cow_copy_context(Interp *interp,
        struct Parrot_Context *dest, struct Parrot_Context *src)
{
    memcpy(dest, src, sizeof(*src));
    buffer_mark_COW(dest->warns);  /* XXX */
    buffer_mark_COW(dest->errors);
}

/*

=item C<void
restore_context(Interp *interp, struct Parrot_Context *ctx)>

Set context of interpreter from a context buffer.

=cut

*/

void
restore_context(Interp *interp, struct Parrot_Context *ctx)
{
    memcpy(&interp->ctx, ctx, sizeof(*ctx));
}

/*

=item C<void
mark_context(Interp* interpreter, struct Parrot_Context* ctx)>

Marks the context C<*ctx>.

=cut

*/

void
mark_context(Interp* interpreter, struct Parrot_Context* ctx)
{
    mark_stack(interpreter, ctx->pad_stack);
    mark_stack(interpreter, ctx->user_stack);
    mark_stack(interpreter, ctx->control_stack);
    mark_register_stack(interpreter, ctx->int_reg_stack);
    mark_register_stack(interpreter, ctx->num_reg_stack);
    mark_string_register_stack(interpreter, ctx->string_reg_stack);
    mark_pmc_register_stack(interpreter, ctx->pmc_reg_stack);
    pobject_lives(interpreter, ctx->warns);
    pobject_lives(interpreter, ctx->errors);
}

/*

=item C<static void coro_error(Stack_Entry_t *e)>

Coroutine error.

=cut

*/

static void coro_error(Stack_Entry_t *e)
{
    internal_exception(1, "Coroutine popped main stack");
}

/*

=item C<static void
prepend_stack( struct Stack_Chunk **interp_stack,
                struct Stack_Chunk **ctx_stack,
                struct Stack_Chunk *saved_stack,
                struct Stack_Chunk *saved_base)>

The final C<ctx_stack> = C<interp_stack> + C<saved_stack>, which
gets swapped with the C<interp_stack> during the prepend.

=cut

*/

static void
prepend_stack( struct Stack_Chunk **interp_stack,
                struct Stack_Chunk **ctx_stack,
                struct Stack_Chunk *saved_stack,
                struct Stack_Chunk *saved_base)
{
    size_t i;

    /*
     * the coroutines context gets the interpreter stack
     */
    *ctx_stack = *interp_stack;
    /*
     * new interpreter stack is the saved coroutine stack top
     * with the base pointing to the old top
     */
    saved_base->prev = *interp_stack;

    *interp_stack = saved_stack;
}

/*

=item C<static void
restore_stack( struct Stack_Chunk **interp_stack,
                struct Stack_Chunk **ctx_stack,
                struct Stack_Chunk **saved_stack,
                struct Stack_Chunk *saved_base)>

Swap C<**interp_stack> and C<**ctx_stack> and save the coroutine only
parts of the stack in C<**saved_stack>, so effectively undoing
C<prepend_stack()>.

=cut

*/

static void
restore_stack( struct Stack_Chunk **interp_stack,
                struct Stack_Chunk **ctx_stack,
                struct Stack_Chunk **saved_stack,
                struct Stack_Chunk *saved_base)
{
    /*
     * swap stacks back
     */
    *saved_stack = *interp_stack;
    *interp_stack = *ctx_stack;
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
swap_context(Interp *interp, struct PMC *sub)
{
    struct Stack_Chunk * tmp_stack = NULL;
    Buffer * warns;
    struct Parrot_Coroutine* co = (struct Parrot_Coroutine *)PMC_sub(sub);
    struct Parrot_Context *ctx = &co->ctx;
    Stack_Chunk_t *reg_top;

    /*
     * Swap user stacks and warnings
     */

    tmp_stack = interp->ctx.user_stack;
    interp->ctx.user_stack = ctx->user_stack;
    ctx->user_stack = tmp_stack;

    warns = interp->ctx.warns;
    interp->ctx.warns = ctx->warns;
    ctx->warns = warns;

    warns = interp->ctx.errors;
    interp->ctx.errors = ctx->errors;
    ctx->errors = warns;

    /* swap register frame tops */
    reg_top = interp->ctx.int_reg_stack;
    interp->ctx.int_reg_stack = ctx->int_reg_stack;
    ctx->int_reg_stack = reg_top;
    reg_top = interp->ctx.num_reg_stack;
    interp->ctx.num_reg_stack = ctx->num_reg_stack;
    ctx->num_reg_stack = reg_top;
    reg_top = interp->ctx.string_reg_stack;
    interp->ctx.string_reg_stack = ctx->string_reg_stack;
    ctx->string_reg_stack = reg_top;
    reg_top = interp->ctx.pmc_reg_stack;
    interp->ctx.pmc_reg_stack = ctx->pmc_reg_stack;
    ctx->pmc_reg_stack = reg_top;

    /* if calling the coroutine */
    if (!(PObj_get_FLAGS(sub) & PObj_private0_FLAG)) {
        /*
         * construct stacks that have the interpreter stack
         * at bottom and the coroutine stack at top
         */
        prepend_stack(&interp->ctx.control_stack, &ctx->control_stack,
                co->co_control_stack, co->co_control_base);
        PObj_get_FLAGS(sub) |= PObj_private0_FLAG;
    }
    else {
        PObj_get_FLAGS(sub) &= ~PObj_private0_FLAG;
        restore_stack(&interp->ctx.control_stack, &ctx->control_stack,
                &co->co_control_stack, co->co_control_base);
    }
    /*
     * TODO FIXME swap the pad_stack or act like the control_stack
     */
#if 1
    tmp_stack = interp->ctx.pad_stack;
    interp->ctx.pad_stack = ctx->pad_stack;
    ctx->pad_stack = tmp_stack;
#endif
}

/*

=item C<struct Parrot_Sub *
new_sub(Interp *interp, size_t size)>

Returns a new C<Parrot_Sub>.

=cut

*/

struct Parrot_Sub *
new_sub(Interp *interp, size_t size)
{
    /* Using system memory until I figure out GC issues */
    struct Parrot_Sub *newsub =
        mem_sys_allocate_zeroed(size);
    newsub->ctx.warns = interp->ctx.warns;
    newsub->ctx.errors = interp->ctx.errors;
    buffer_mark_COW(interp->ctx.warns);
    buffer_mark_COW(interp->ctx.errors);
    newsub->seg = interp->code->cur_cs;
    return newsub;
}

/*

=item C<struct Parrot_Sub *
new_closure(Interp *interp)>

Returns a new C<Parrot_Sub> with its own sctatchpad.

XXX: Need to document semantics in detail.

=cut

*/

struct Parrot_Sub *
new_closure(Interp *interp)
{
    struct Parrot_Sub *newsub = new_sub(interp, sizeof(struct Parrot_Sub));
    PMC * pad = scratchpad_get_current(interp);
    newsub->ctx.pad_stack = new_stack(interp, "Pad");
    if (pad) {
        /* put the correct pad in place */
        stack_push(interp, &newsub->ctx.pad_stack, pad,
                STACK_ENTRY_PMC, STACK_CLEANUP_NULL);
    }
    return newsub;
}
/*

=item C<void mark_stack_reusable(Parrot_Interp, struct Parrot_Context *)>

Set continuation context stacks as recyclable.

=cut

*/
void
mark_stack_reusable(Parrot_Interp interpreter, struct Parrot_Context *ctx)
{
    PObj_get_FLAGS(ctx->int_reg_stack) |= PObj_private2_FLAG;
    PObj_get_FLAGS(ctx->num_reg_stack) |= PObj_private2_FLAG;
    PObj_get_FLAGS(ctx->pmc_reg_stack) |= PObj_private2_FLAG;
    PObj_get_FLAGS(ctx->string_reg_stack) |= PObj_private2_FLAG;
}
/*

=item C<struct Parrot_Sub *
new_continuation(Interp *interp)>

Returns a new C<Parrot_Sub> with its own COW version of the current
context.

=cut

*/


struct Parrot_Sub *
new_continuation(Interp *interp)
{
    struct Parrot_Sub *cc = new_sub(interp, sizeof(struct Parrot_Sub));
    cow_copy_context(interp, &cc->ctx, &interp->ctx);
    return cc;
}

/*

=item C<struct Parrot_Sub *
new_ret_continuation(Interp *interp)>

Returns a new C<Parrot_Sub> with its own copy of the current context.

=cut

*/

struct Parrot_Sub *
new_ret_continuation(Interp *interp)
{
    struct Parrot_Sub *cc =
        mem_sys_allocate_zeroed(sizeof(struct Parrot_Sub));
    cc->seg = interp->code->cur_cs;
    save_context(interp, &cc->ctx);
    return cc;
}

/*

=item C<struct Parrot_Sub *
new_coroutine(Interp *interp)>

Returns a new C<Parrot_Coroutine>.

XXX: Need to document semantics in detail.

=cut

*/

struct Parrot_Sub *
new_coroutine(Interp *interp)
{
    PMC * pad;
    struct Parrot_Context *ctx;
    struct Parrot_Coroutine *co =
        mem_sys_allocate_zeroed(sizeof(struct Parrot_Coroutine));

    co->seg = interp->code->cur_cs;
    ctx = &co->ctx;
    save_context(interp, ctx);

    /* we have separate register stacks */
    setup_register_stacks(interp, ctx);

    /* create new (pad ??) and control stacks,
     * when invoking the coroutine the real stacks are
     * constructed in swap_context
     * XXX decide what to do with pad
     */
    co->co_control_base = co->co_control_stack =
        new_stack(interp, "Coro_Control");

    /*
     * XXX probably in swap_context
     */
    pad = scratchpad_get_current(interp);
    if (pad) {
        stack_push(interp, &ctx->pad_stack, pad,
                   STACK_ENTRY_PMC, STACK_CLEANUP_NULL);
    }
    return (struct Parrot_Sub *)co;
}

/*

=item C<PMC *
new_ret_continuation_pmc(Interp * interp, opcode_t * address)>

Returns a new C<RetContinuation> PMC.

=cut

*/

void
add_to_retc_free_list(Parrot_Interp interpreter, PMC *sub)
{
    Caches *mc = interpreter->caches;
    struct Parrot_Sub *cc_self = PMC_sub(sub);
    /* is it created from new_ret_continuation_pmc() i.e.
     * from invokecc or callmethodcc
     */
    if (!(PObj_get_FLAGS(sub) & PObj_private2_FLAG) ||
            DISABLE_RETC_RECYCLING) {
        return;
    }
    /* fprintf(stderr, "** add %p free = %p\n", sub, mc->retc_free_list); */
    PMC_struct_val(sub) = mc->retc_free_list;
    mc->retc_free_list = sub;
    /* don't mark the continuation context
     *  -- don't use PObj_custom_mark_* - too expensive and not necessary
     */
    PObj_flag_CLEAR(custom_mark, sub);
    /*
     * shouldn't be necessary, s. also stack_common.c
     */
    /* PObj_on_free_list_SET(sub); */
    mark_stack_reusable(interpreter, &cc_self->ctx);
}

PMC *
get_retc_from_free_list(Parrot_Interp interpreter)
{
    Caches *mc = interpreter->caches;
    PMC *retc;

    if (!mc->retc_free_list)
        return NULL;
    retc = mc->retc_free_list;
    mc->retc_free_list = PMC_struct_val(retc);
    PObj_flag_SET(custom_mark, retc);
    /* PObj_on_free_list_CLEAR(retc); */
    /* fprintf(stderr, "** get %p free = %p\n", retc, mc->retc_free_list ); */
    return retc;
}

PMC *
new_ret_continuation_pmc(Interp * interp, opcode_t * address)
{
    PMC* continuation;

    continuation = get_retc_from_free_list(interp);
    if (continuation) {
        /* freshen context */
        struct Parrot_Sub *sub = PMC_sub(continuation);
        save_context(interp, &sub->ctx);
        sub->seg = interp->code->cur_cs;
    }
    else {
        continuation = pmc_new(interp, enum_class_RetContinuation);
        PObj_get_FLAGS(continuation) |= (
                PObj_private1_FLAG|PObj_private2_FLAG);
    }
    PMC_struct_val(continuation) = address;
    return continuation;
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
