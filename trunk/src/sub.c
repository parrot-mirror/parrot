/*  sub.c
 *  Copyright: (When this is determined...it will go here)
 *  CVS Info
 *     $Id$
 *  Overview:
 *     Sub-routines, co-routines and other fun stuff...
 *  Data Structure and Algorithms:
 *  History:
 *     Initial version by Melvin on 2002/06/6
 *  Notes:
 *  References:
 */

#include "parrot/parrot.h"


void
save_context(struct Parrot_Interp *interp, struct Parrot_Context *ctx)
{
    memcpy(ctx, &interp->ctx, sizeof(*ctx));
    stack_mark_cow(ctx->pad_stack);
    stack_mark_cow(ctx->user_stack);
    stack_mark_cow(ctx->control_stack);
}

void
restore_context(struct Parrot_Interp *interp, struct Parrot_Context *ctx)
{
    memcpy(&interp->ctx, ctx, sizeof(*ctx));
}

struct Parrot_Sub *
new_sub(struct Parrot_Interp *interp, opcode_t *address)
{
    /* Using system memory until I figure out GC issues */
    struct Parrot_Sub *newsub = mem_sys_allocate(sizeof(struct Parrot_Sub));
    newsub->init = address;
    newsub->lex_pad = scratchpad_get_current(interp);
    return newsub;
}

struct Parrot_Coroutine *
new_coroutine(struct Parrot_Interp *interp, opcode_t *address)
{
    /* Using system memory until I figure out GC issues */
    struct Parrot_Coroutine *newco =
        mem_sys_allocate(sizeof(struct Parrot_Coroutine));
    newco->init = address;
    newco->resume = NULL;
    newco->ctx.user_stack = new_stack(interp);
    newco->ctx.control_stack = new_stack(interp);
    newco->lex_pad = scratchpad_get_current(interp);
    return newco;
}

struct Parrot_Continuation *
new_continuation(struct Parrot_Interp *interp, opcode_t *address)
{
    struct Parrot_Continuation *cc =
        mem_sys_allocate(sizeof(struct Parrot_Continuation));
    cc->continuation = address;
    save_context(interp, &cc->ctx);
    return cc;
}

/*
 * Uses scope_index to find and return the appropriate scope.
 */
static struct Parrot_Lexicals *
scratchpad_index(struct Parrot_Interp* interpreter, PMC* pad,
                 INTVAL scope_index)
{
    /* if scope_index is negative we count out from current pad */
    scope_index = scope_index < 0 ?
        pad->cache.int_val + scope_index : scope_index;

    if (scope_index >= pad->cache.int_val || scope_index < 0) {
        internal_exception(-1, "Pad index out of range");
        return NULL;
    }

    return ((struct Parrot_Lexicals **)pad->data)[scope_index];
}

/*
 * Returns a pointer to the current scratchpad.
 */
PMC *
scratchpad_get_current(struct Parrot_Interp * interp)
{
    return (PMC *)stack_peek(interp, interp->ctx.pad_stack, NULL);
}

/*
 * Returns the position of the lexical variable corresponding to
 * name. If such a variable can not be found the length of the list
 * is returned (i.e. the position that this new lexical should be
 * stored in).
 */
static INTVAL
lexicals_get_position(struct Parrot_Interp * interp,
                      struct Parrot_Lexicals *lex, STRING* name)
{
    STRING * cur;
    INTVAL pos;

    for (pos = 0; pos < list_length(interp, lex->names); pos++) {
        cur = *(STRING**)list_get(interp, lex->names, pos, enum_type_STRING);
        if (cur && string_compare(interp, cur, name) == 0) {
            break;
        }
    }

    return pos;
}

/*
 * Returns first lexical scope and position where name is found, or
 * NULL if it can not be found.
 */
static struct Parrot_Lexicals *
scratchpad_find(struct Parrot_Interp* interp, PMC* pad, STRING * name,
                INTVAL * position)
{
    INTVAL i, pos = 0;
    struct Parrot_Lexicals * lex = NULL;

    for (i = pad->cache.int_val - 1; i >= 0; i--) {
        lex = ((struct Parrot_Lexicals **)pad->data)[i];
        pos = lexicals_get_position(interp, lex, name);
        if (pos == list_length(interp, lex->names))
            lex = NULL;
        else
            break;
    }

    *position = pos;
    return lex;
}

/*
 * Creates and initializes a new Scratchpad PMC.
 */
PMC*
scratchpad_new(struct Parrot_Interp * interp, PMC * base, INTVAL depth)
{
    struct Parrot_Lexicals * lex;
    PMC * pad_pmc = pmc_new(interp, enum_class_Scratchpad);
    pad_pmc->cache.int_val = 0;

    if (base && depth < 0) {
        depth = base->cache.int_val + depth + 1;
    }

    if ((depth < 0)
        || (base && depth > base->cache.int_val)
        || (!base && depth != 0)) {
        internal_exception(-1, "-scratch_pad: too deep\n");
        return NULL;
    }

    /* XXX JPS: should we use a List * here instead? */
    pad_pmc->data = mem_sys_allocate((depth + 1) *
                                     sizeof(struct Parrot_Lexicals));

    if (base) {
        memcpy(pad_pmc->data, base->data, depth *
               sizeof(struct Parrot_Lexicals));
    }

    lex = mem_sys_allocate(sizeof(struct Parrot_Lexicals));
    lex->names = NULL;
    lex->values = NULL;
    /* the list_new below might trigger GC, so anchor the lex structure
     * early
     */
    ((struct Parrot_Lexicals **)pad_pmc->data)[depth] = lex;
    pad_pmc->cache.int_val = depth + 1;
    lex->values = list_new(interp, enum_type_PMC);
    lex->names = list_new(interp, enum_type_STRING);

    return pad_pmc;
}

/*
 * Routines for storing and reading lexicals in Scratchpad's. These
 * take both a name and a position, however in general only one of
 * these will be considered. This is to support both by name access
 * and by position (which is faster). If by position access is intended
 * name should be passed as NULL.
 */

void
scratchpad_store(struct Parrot_Interp * interp, PMC * pad,
                 STRING * name, INTVAL position, PMC* value)
{
    struct Parrot_Lexicals * lex;

    if (name) {
        /* use name to find lex and position */
        lex = scratchpad_find(interp, pad, name, &position);
        if (!lex) internal_exception(-1, "Lexical not found");
    }
    else {
        /* assume current lexical pad */
        lex = scratchpad_index(interp, pad, -1);
    }

    list_assign(interp, lex->values, position, value, enum_type_PMC);
}

void
scratchpad_store_index(struct Parrot_Interp * interp, PMC * pad,
                       INTVAL scope_index, STRING * name, INTVAL position,
                       PMC* value)
{
    struct Parrot_Lexicals * lex;

    lex = scratchpad_index(interp, pad, scope_index);

    if (name) {
        position = lexicals_get_position(interp, lex, name);
    }

    if (position == list_length(interp, lex->names)) {
        if (!name) {
            /* no name for new variable, give it a default name of "" */
            /* XXX JPS: is this the way to make an empty string? */
            name = string_make(interp, "", 9,0,0,0);
        }
        list_assign(interp, lex->names, position, name, enum_type_STRING);
    }

    list_assign(interp, lex->values, position, value, enum_type_PMC);
}

PMC *
scratchpad_get(struct Parrot_Interp * interp, PMC * pad, STRING * name,
               INTVAL position)
{
    struct Parrot_Lexicals * lex = NULL;

    if (name) lex = scratchpad_find(interp, pad, name, &position);
    else lex = scratchpad_index(interp, pad, -1);

    if (!lex) internal_exception(-1, "Lexical not found");

    return *(PMC **)list_get(interp, lex->values, position, enum_type_PMC);
}

PMC *
scratchpad_get_index(struct Parrot_Interp * interp, PMC * pad,
                     INTVAL scope_index, STRING * name, INTVAL position)
{
    struct Parrot_Lexicals * lex = scratchpad_index(interp, pad, scope_index);

    if (name) {
        position = lexicals_get_position(interp, lex, name);
    }

    if (!lex || position < 0 || position >= list_length(interp, lex->values)) {
        internal_exception(-1, "Lexical not found");
    }

    return *(PMC **)list_get(interp, lex->values, position, enum_type_PMC);
}

void
lexicals_mark(struct Parrot_Interp * interp, struct Parrot_Lexicals *lex)
{
    if (lex->names)
        list_mark(interp, lex->names);
    if (lex->values)
        list_mark(interp, lex->values);
}

/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
 */
