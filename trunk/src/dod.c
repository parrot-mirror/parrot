/*
Copyright: 2001-2005 The Perl Foundation.  All Rights Reserved.
$Id$

=head1 NAME

src/dod.c - Dead object destruction of the various headers

=head1 DESCRIPTION

This file implements I<dead object destruction>. This is documented in
PDD 9 with supplementary notes in F<docs/dev/dod.dev>.

It's possible to turn on/off the checking of the system stack and
processor registers. The actual checking is implemented in F<src/cpu_dep.c>.

There's also a verbose mode for garbage collection.

=head2 Functions

=over 4

=cut

*/

#define DOD_C_SOURCE
#include "parrot/parrot.h"
#include <assert.h>

/* Set this to 1 to see if unanchored objects are found in system areas.
 * Please note: these objects might be bogus
 */
#define GC_VERBOSE 0

#if ! DISABLE_GC_DEBUG
/* Set when walking the system stack */
int CONSERVATIVE_POINTER_CHASING = 0;
#endif

static size_t find_common_mask(size_t val1, size_t val2);

/*

=item C<static void
mark_special(Parrot_Interp interpreter, PMC* obj)>

Mark a special PMC. If it has a C<PMC_EXT> structure, append or prepend
the C<next_for_GC> pointer; otherwise, do the custom mark directly.

This should really be inline, so if inline isn't available, it would
be better if it was a macro.

=cut

*/

static void
mark_special(Parrot_Interp interpreter, PMC* obj)
{
    int hi_prio;
    struct Arenas *arena_base;

    /*
     * If the object is shared, we have to use the arena and dod
     * pointers of the originating interpreter.
     *
     * We are possibly changing other interpreter's data here, so
     * the mark phase of DOD must run only on one interpreter of a pool
     * at a time. However, freeing of unused objects can be done in
     * parallel.
     * And: to be sure that a shared object is dead, we have to finish
     * the mark phase of all interpreters in a pool that might reference
     * the object.
     */
    if (PObj_is_PMC_shared_TEST(obj)) {
        interpreter = PMC_sync(obj)->owner;
        assert(interpreter);
    }
    arena_base = interpreter->arena_base;

    if (PObj_needs_early_DOD_TEST(obj))
        ++arena_base->num_early_PMCs_seen;
    if (PObj_high_priority_DOD_TEST(obj) && arena_base->dod_trace_ptr) {
        /* set obj's parent to high priority */
        PObj_high_priority_DOD_SET(arena_base->dod_trace_ptr);
        hi_prio = 1;
    }
    else
        hi_prio = 0;

    if (obj->pmc_ext) {
        PMC* tptr = arena_base->dod_trace_ptr;

        ++arena_base->num_extended_PMCs;
        /*
         * XXX this basically invalidates the high-priority marking
         *     of PMCs by putting all PMCs onto the front of the list.
         *     The reason for this is the by far better cache locality
         *     when aggregates and their contents are marked "together".
         *
         *     To enable high priority marking again we should probably
         *     use a second pointer chain, which is, when not empty,
         *     processed first.
         */
        if (tptr || hi_prio) {
            if (PMC_next_for_GC(tptr) == tptr) {
                PMC_next_for_GC(obj) = obj;
            }
            else {
                /* put it at the head of the list */
                PMC_next_for_GC(obj) = PMC_next_for_GC(tptr);
            }
            PMC_next_for_GC(tptr) = (PMC*)obj;
        }
        else {
            /* put it on the end of the list */
            PMC_next_for_GC(arena_base->dod_mark_ptr) = obj;

            /* Explicitly make the tail of the linked list be
             * self-referential */
            arena_base->dod_mark_ptr = PMC_next_for_GC(obj) = obj;
        }
    }
    else if (PObj_custom_mark_TEST(obj)) {
        PObj_get_FLAGS(obj) |= PObj_custom_GC_FLAG;
        VTABLE_mark(interpreter, obj);
    }
}

#if !PARROT_GC_GMS
#  if ARENA_DOD_FLAGS

/*

=item C<void pobject_lives(Interp *interpreter, PObj *obj)>

Tag C<obj> as alive.

Used by the GC system when tracing the root set, and used by the PMC GC
handling routines to tag their individual pieces if they have private
ones.

=cut

*/
void
pobject_lives(Interp *interpreter, PObj *obj)
{

    struct Small_Object_Arena *arena = GET_ARENA(obj);
    size_t n = GET_OBJ_N(arena, obj);
    size_t ns = n >> ARENA_FLAG_SHIFT;
    UINTVAL nm = (n & ARENA_FLAG_MASK) << 2;
    UINTVAL *dod_flags = arena->dod_flags + ns;
    if (*dod_flags & ((PObj_on_free_list_FLAG | PObj_live_FLAG) << nm))
        return;

#ifdef DEBUG_DOD_CONSTS
    if (PObj_is_PMC_TEST(obj) &&
            ((PMC*)obj)->vtable->base_type != enum_class_SArray &&
            ((PMC*)obj)->vtable->base_type != enum_class_Null
            )
        assert(!PObj_constant_TEST(obj));
#endif

    ++arena->live_objects;
    *dod_flags |= PObj_live_FLAG << nm;

#if GC_VERBOSE
        if (PObj_report_TEST(obj)) {
            fprintf(stderr, "GC: PMC %p live\n", obj);
        }
#endif
    if (*dod_flags & (PObj_is_special_PMC_FLAG << nm)) {
        /* All PMCs that need special treatment are handled here.
         * For normal PMCs, we don't touch the PMC memory itself
         * so that caches stay clean.
         */
#if GC_VERBOSE
        if (PObj_report_TEST(obj)) {
            fprintf(stderr, "GC: PMC %p special\n", obj);
        }
#endif
        mark_special(interpreter, (PMC*) obj);
    }
}

#  else

void pobject_lives(Interp *interpreter, PObj *obj)
{
    /* if object is live or on free list return */
    if (PObj_is_live_or_free_TESTALL(obj)) {
        return;
    }
#if ! DISABLE_GC_DEBUG
#  if GC_VERBOSE
    if (CONSERVATIVE_POINTER_CHASING) {
        fprintf(stderr, "GC Warning! Unanchored %s %p version " INTVAL_FMT
                " found in system areas \n",
                PObj_is_PMC_TEST(obj) ? "PMC" : "Buffer",
                obj, PObj_version(obj));
    }
#  endif
#endif
    /* mark it live */
    PObj_live_SET(obj);

    /* if object is a PMC and contains buffers or PMCs, then attach
     * the PMC to the chained mark list.
     */
    if (PObj_is_special_PMC_TEST(obj)) {
        mark_special(interpreter, (PMC*) obj);
    }
#ifndef NDEBUG
    else {
        if (PObj_is_PMC_TEST(obj)) {
            PMC *p = (PMC*)obj;
            if (p->pmc_ext && PMC_metadata(p)) {
                fprintf(stderr, "GC: error obj %p (%s) has properties\n",
                        p, (char*)p->vtable->whoami->strstart);
            }
        }
    }
#endif
#if GC_VERBOSE
    /* buffer GC_DEBUG stuff */
    if (! GC_DEBUG(interpreter))
        return;

    if (PObj_report_TEST(obj)) {
        fprintf(stderr, "GC: buffer %p pointing to %p marked live\n",
                obj, PObj_bufstart((Buffer*) obj));
    }
#endif
}

#  endif
#endif  /* PARROT_GC_GMS */

/*

=item C<static int
trace_active_PMCs(Interp *interpreter, int trace_stack)>

Do a full trace run and mark all the PMCs as active if they are. Returns
whether the run wasn't aborted; i.e. whether it's safe to proceed with
GC.

=item C<int
Parrot_dod_trace_root(Interp *interpreter, int trace_stack)>

Trace the root set. Returns 0 if its a lazy DOD run and all objects
that need timely destruction were found.

C<trace_stack> can have these values:

 0 ... trace normal roots, no system areas
 1 ... trace whole root set
 2 ... trace system areas only

=cut

*/

int
Parrot_dod_trace_root(Interp *interpreter, int trace_stack)
{

    struct Arenas *arena_base = interpreter->arena_base;
    parrot_context_t *ctx;

    /*
     * note: adding locals here did cause increased DOD runs
     */
    unsigned int i = 0;
    struct Stash *stash = 0;

    if (trace_stack == 2) {
        trace_system_areas(interpreter);
        return 0;
    }
    if (interpreter->profile)
        Parrot_dod_profile_start(interpreter);
    /* We have to start somewhere, the interpreter globals is a good place */
    if (!arena_base->dod_mark_start) {
        arena_base->dod_mark_start = arena_base->dod_mark_ptr =
            interpreter->iglobals;
    }

    /* mark it as used  */
    pobject_lives(interpreter, (PObj *)interpreter->iglobals);

    /* mark the current context. */
    ctx = CONTEXT(interpreter->ctx);
    mark_context(interpreter, ctx);

    /*
     * mark vtable->data
     *
     * XXX these PMCs are constant and shouldn't get collected
     * but t/library/dumper* fails w/o this marking.
     *
     * It seems that the Class PMC gets DODed - these should
     * get created as constant PMCs.
     */
    for (i = 1; i < (unsigned int)enum_class_max; i++) {
        VTABLE *vtable;
        /*
         * XXX dynpmc groups have empty slots for abstract objects
         */
        if ( (vtable = Parrot_base_vtables[i])) {
#if 0
            if (vtable->class)
                pobject_lives(interpreter, (PObj *)vtable->class);
#endif
            if (vtable->mro)
                pobject_lives(interpreter, (PObj *)vtable->mro);
        }
    }

    /* mark exception list */
    for (i = 0; i <= E_LAST_PYTHON_E; ++i) {
        pobject_lives(interpreter, (PObj*)interpreter->exception_list[i]);
    }
    /* Walk through the stashes */
    stash = interpreter->globals;
    while (stash) {
        pobject_lives(interpreter, (PObj *)stash->stash_hash);
        stash = stash->parent_stash;
    }
    /* s. packfile.c */
    mark_const_subs(interpreter);

    /* mark caches and freelists */
    mark_object_cache(interpreter);

    /* Now mark the class hash */
    pobject_lives(interpreter, (PObj *)interpreter->class_hash);

    /* Mark the registry if any */
    if (interpreter->DOD_registry)
        pobject_lives(interpreter, (PObj *)interpreter->DOD_registry);


    /* Walk the iodata */
    Parrot_IOData_mark(interpreter, interpreter->piodata);

    /* quick check, if we can already bail out */
    if (arena_base->lazy_dod && arena_base->num_early_PMCs_seen >=
            arena_base->num_early_DOD_PMCs) {
        return 0;
    }

    /* Find important stuff on the system stack */
    if (trace_stack)
        trace_system_areas(interpreter);

    if (interpreter->profile)
        Parrot_dod_profile_end(interpreter, PARROT_PROF_DOD_p1);
    return 1;
}

static int
trace_active_PMCs(Interp *interpreter, int trace_stack)
{
    if (!Parrot_dod_trace_root(interpreter, trace_stack))
        return 0;
    /* Okay, we've marked the whole root set, and should have a good-sized
     * list of things to look at. Run through it */
    return Parrot_dod_trace_children(interpreter, (size_t) -1);
}

/*

=item C<int
Parrot_dod_trace_children(Interp *interpreter, size_t how_many)>

Returns whether the tracing process wasn't aborted.

=cut

*/

int
Parrot_dod_trace_children(Interp *interpreter, size_t how_many)
{
    PMC *next;
    struct Arenas *arena_base = interpreter->arena_base;
    INTVAL i = 0;
    UINTVAL mask = PObj_data_is_PMC_array_FLAG | PObj_custom_mark_FLAG;
    PMC *current = arena_base->dod_mark_start;

    int lazy_dod = arena_base->lazy_dod;

    /*
     * First phase of mark is finished. Now if we are the owner
     * of a shared pool, we must run the mark phase of other
     * interpreters in our pool, so that live shared PMCs in that
     * interpreter are appended to our mark_ptrs chain.
     *
     * If there is a count of shared PMCs and we have already seen
     * all these, we could skip that.
     */
    if (interpreter->profile)
        Parrot_dod_profile_start(interpreter);
    pt_DOD_mark_root_finished(interpreter);

    for (; ; current = next) {
        UINTVAL bits = PObj_get_FLAGS(current) & mask;

        if (lazy_dod && arena_base->num_early_PMCs_seen >=
                arena_base->num_early_DOD_PMCs) {
            return 0;
        }
        arena_base->dod_trace_ptr = current;
        /*
         * short-term hack to color objects black
         */
        PObj_get_FLAGS(current) |= PObj_custom_GC_FLAG;
        /*
         * clearing the flag is much more expensive then testing
         */
        if (!PObj_needs_early_DOD_TEST(current)
#if ARENA_DOD_FLAGS
                && PObj_high_priority_DOD_TEST(current)
#endif
           )
            PObj_high_priority_DOD_CLEAR(current);

        /* mark properties */
        if (PMC_metadata(current)) {
            pobject_lives(interpreter, (PObj *)PMC_metadata(current));
        }
        /* Start by checking if there's anything at all. This assumes that the
         * largest percentage of PMCs won't have anything in their data
         * pointer that we need to trace. */
        if (bits) {
            if (bits == PObj_data_is_PMC_array_FLAG) {
                /* malloced array of PMCs */
                PMC **data = PMC_data(current);

                if (data) {
                    for (i = 0; i < PMC_int_val(current); i++) {
                        if (data[i]) {
                            pobject_lives(interpreter, (PObj *)data[i]);
                        }
                    }
                }
            }
            else {
                /* All that's left is the custom */
                assert(!PObj_on_free_list_TEST(current));
                VTABLE_mark(interpreter, current);
            }
        }

        next = PMC_next_for_GC(current);
        if (next == current)
            break;
        if (--how_many == 0) {
            current = next;
            break;
        }
    }
    arena_base->dod_mark_start = current;
    arena_base->dod_trace_ptr = NULL;
    if (interpreter->profile)
        Parrot_dod_profile_end(interpreter, PARROT_PROF_DOD_p2);
    return 1;
}


#ifdef GC_IS_MALLOC

/*

=item C<void
clear_cow(Interp *interpreter, struct Small_Object_Pool *pool,
        int cleanup)>

Clear the COW ref count.

=cut

*/

void
clear_cow(Interp *interpreter, struct Small_Object_Pool *pool,
        int cleanup)
{
    UINTVAL object_size = pool->object_size;
    struct Small_Object_Arena *cur_arena;
    UINTVAL i;
    Buffer *b;
    INTVAL *refcount;

    /* clear refcount for COWable objects. */
    for (cur_arena = pool->last_Arena;
            NULL != cur_arena; cur_arena = cur_arena->prev) {
        b = cur_arena->start_objects;
        for (i = 0; i < cur_arena->used; i++) {
            if (!PObj_on_free_list_TEST(b)) {
                if (cleanup) {
                    /* clear COWed external FLAG */
                    PObj_external_CLEAR(b);
                    /* the real external flag */
                    if (PObj_bufstart_external_TEST(b))
                        PObj_external_SET(b);
                    /* if cleanup (Parrot_destroy) constants are dead too */
                    PObj_constant_CLEAR(b);
                    PObj_live_CLEAR(b);
                }

                if (PObj_COW_TEST(b) && PObj_bufstart(b) &&
                        !PObj_external_TEST(b)) {
                    refcount = (INTVAL *) PObj_bufstart(b) - 1;
                    *refcount = 0;
                }
            }
            b = (Buffer *)((char *)b + object_size);
        }
    }
}

/*

=item C<void
used_cow(Interp *interpreter, struct Small_Object_Pool *pool,
        int cleanup)>

Find other users of COW's C<bufstart>.

=cut

*/

void
used_cow(Interp *interpreter, struct Small_Object_Pool *pool,
        int cleanup)
{
    UINTVAL object_size = pool->object_size;
    struct Small_Object_Arena *cur_arena;
    UINTVAL i;
    Buffer *b;
    INTVAL *refcount;

    for (cur_arena = pool->last_Arena;
            NULL != cur_arena; cur_arena = cur_arena->prev) {
        b = cur_arena->start_objects;
        for (i = 0; i < cur_arena->used; i++) {
            if (!PObj_on_free_list_TEST(b) &&
                    PObj_COW_TEST(b) &&
                    PObj_bufstart(b) &&
                    !PObj_external_TEST(b)) {
                refcount = (INTVAL *) PObj_bufstart(b) - 1;
                /* mark users of this bufstart by incrementing refcount */
                if (PObj_live_TEST(b))
                    *refcount = 1 << 29;        /* ~infinite usage */
                else
                    (*refcount)++;      /* dead usage */
            }
            b = (Buffer *)((char *)b + object_size);
        }
    }
}
#endif /* GC_IS_MALLOC */

#if ARENA_DOD_FLAGS

/*

=item C<static void
clear_live_counter(Interp *interpreter,
        struct Small_Object_Pool *pool)>

Clear the live counter.

=cut

*/

static void
clear_live_counter(Interp *interpreter,
        struct Small_Object_Pool *pool)
{
    struct Small_Object_Arena *arena;
    for (arena = pool->last_Arena; arena; arena = arena->prev)
        arena->live_objects = 0;
}

# define REDUCE_ARENAS 0

#  if REDUCE_ARENAS
/* -lt:
 * count free objects per arena
 * - if we find more then one totally unused arena
 *   free all but one arena - this is the only possibility to
 *   reduce the amount of free objects.
 *
 * doesn't really work or speed things up - disabled
 */
# define REDUCE_ARENA_DEBUG 0

#if REDUCE_ARENA_DEBUG
#define debug(x) printf x
#else
#define debug(x)
#endif

/*

=item C<static void
reduce_arenas(Interp *interpreter,
        struct Small_Object_Pool *pool, UINTVAL free_arenas)>

Reduce the number of memory arenas by freeing any that have no live
objects.

=cut

*/

static void
reduce_arenas(Interp *interpreter,
        struct Small_Object_Pool *pool, UINTVAL free_arenas)
{
    struct Small_Object_Arena *arena, *next, *prev;
    int i;
    PObj * o;

    /* debugging stuff */
    for (i = 0, arena = pool->last_Arena; arena; arena = arena->prev)
        i++;
    debug(("\ttotal %d arenas - ", i));

    for (next = arena = pool->last_Arena; arena; ) {
        prev = arena->prev;
        if (arena->live_objects == 0) {
            if (--free_arenas <= 0)
                break;
            next->prev = prev;
            pool->total_objects -= arena->used;
#if ! ARENA_DOD_FLAGS
            mem_sys_free(arena->start_objects);
	    arena->start_objects = 0;
#endif
            mem_sys_free(arena);

        }
        else {
            next = arena;
        }
        arena = prev;
    }
    for (i = 0, arena = pool->last_Arena; arena; arena = arena->prev)
        i++;
    debug(("now %d arenas\n", i));

}

#  endif
#endif

/*

=item C<void
Parrot_dod_sweep(Interp *interpreter,
        struct Small_Object_Pool *pool)>

Put any buffers/PMCs that are now unused onto the pool's free list. If
C<GC_IS_MALLOC>, bufstart gets freed too, if possible. Avoid buffers that
are immune from collection (i.e. constant).

=cut

*/

void
Parrot_dod_sweep(Interp *interpreter,
        struct Small_Object_Pool *pool)
{
    struct Arenas *arena_base = interpreter->arena_base;
    struct Small_Object_Arena *cur_arena;
    UINTVAL i, total_used = 0;
    UINTVAL object_size = pool->object_size;
    size_t nm;
#if REDUCE_ARENAS
    UINTVAL free_arenas = 0, old_total_used = 0;
#endif

    /* Run through all the buffer header pools and mark */
    for (cur_arena = pool->last_Arena;
            NULL != cur_arena; cur_arena = cur_arena->prev) {
        Buffer *b = cur_arena->start_objects;

#if ARENA_DOD_FLAGS
        UINTVAL * dod_flags = cur_arena->dod_flags - 1;
#endif
        for (i = nm = 0; i < cur_arena->used; i++) {
#if ARENA_DOD_FLAGS
            if (! (i & ARENA_FLAG_MASK)) {
                /* reset live bits for previous bunch of objects */
                if (i)
                    *dod_flags &= ~ALL_LIVE_MASK;
                ++dod_flags;
                /* if all are on free list, skip one bunch */
                if (*dod_flags == ALL_FREE_MASK) {  /* all on free list */
                    i += ARENA_FLAG_MASK;       /* + 1 in loop */
                    b = (Buffer *)((char *)b + object_size*(ARENA_FLAG_MASK+1));
                    continue;
                }
                nm = 0;
            }
            else
                nm += 4;

            /* If it's not live or on the free list, put it on the free list.
             * Note that it is technically possible to have a Buffer be both
             * on_free_list and live, because of our conservative stack-walk
             * collection. We must be wary of this case. */
            if ((*dod_flags & (PObj_on_free_list_FLAG << nm)))
                ; /* if its on free list, do nothing */
            else if ((*dod_flags & (PObj_live_FLAG << nm)))
#else
            if (PObj_on_free_list_TEST(b))
                ; /* if its on free list, do nothing */
            else if (PObj_live_TEST(b))
#endif
            {
                /* its live */
                total_used++;
#if !ARENA_DOD_FLAGS
                PObj_live_CLEAR(b);
                PObj_get_FLAGS(b) &= ~PObj_custom_GC_FLAG;
#endif
            }
            else {
                /* it must be dead */
#if GC_VERBOSE
                if (GC_DEBUG(interpreter) && PObj_report_TEST(b)) {
                    fprintf(stderr, "Freeing pobject %p\n", b);
                    if (PObj_is_PMC_TEST(b)) {
                        fprintf(stderr, "\t = PMC type %s\n",
                                (char*) ((PMC*)b)->vtable->whoami->strstart);
                    }
                }
#endif
                /* if object is a PMC and needs destroying */
                if (PObj_is_PMC_TEST(b)) {
                    PMC *p = (PMC*)b;
                    /*
                     * XXX
                     * for now don't mess around with shared objects
                     */
                    if (p->vtable->flags & VTABLE_IS_SHARED_FLAG)
                        goto next;

                    /* then destroy it here
                    */
                    if (PObj_needs_early_DOD_TEST(p))
                        --arena_base->num_early_DOD_PMCs;
                    if (PObj_active_destroy_TEST(p))
                        VTABLE_destroy(interpreter, p);

                    if (PObj_is_PMC_EXT_TEST(p) && p->pmc_ext != NULL) {
                        /* if the PMC has a PMC_EXT structure,
                         * return it to the pool/arena
                         */
                        struct Small_Object_Pool *ext_pool =
                            arena_base->pmc_ext_pool;
                        ext_pool->add_free_object(interpreter, ext_pool,
                                p->pmc_ext);
                    }
#ifndef NDEBUG
                    /*
                     * invalidate the PMC
                     */
                    p->vtable = (void*)0xdeadbeef;
                    PMC_pmc_val(p) = (void*)0xdeadbeef;
                    p->pmc_ext = (void*)0xdeadbeef;
#endif
                }
                /* else object is a buffer(like) */
                else if (PObj_sysmem_TEST(b) && PObj_bufstart(b)) {
                    /* has sysmem allocated, e.g. string_pin */
                    mem_sys_free(PObj_bufstart(b));
                    PObj_bufstart(b) = NULL;
                    PObj_buflen(b) = 0;
                }
                else {
#ifdef GC_IS_MALLOC
                    /* free allocated space at (int*)bufstart - 1,
                     * but not if it is used COW or external
                     */
                    if (PObj_bufstart(b) &&
                            !PObj_is_external_or_free_TESTALL(b)) {
                        if (PObj_COW_TEST(b)) {
                            INTVAL *refcount = ((INTVAL *)PObj_bufstart(b) - 1);

                            if (!--(*refcount))
                                free(refcount); /* the actual bufstart */
                        }
                        else
                            free((INTVAL*)PObj_bufstart(b) - 1);
                    }
#else
                    /*
                     * XXX Jarkko did report that on irix pool->mem_pool
                     *     was NULL, which really shouldn't happen
                     */
                    if (pool->mem_pool) {
                        if (!PObj_COW_TEST(b)) {
                            ((struct Memory_Pool *)
                             pool->mem_pool)->guaranteed_reclaimable +=
                                PObj_buflen(b);
                        }
                        ((struct Memory_Pool *)
                         pool->mem_pool)->possibly_reclaimable +=
                            PObj_buflen(b);
                    }
#endif
                    PObj_buflen(b) = 0;
                }
#if ARENA_DOD_FLAGS
                *dod_flags |= PObj_on_free_list_FLAG << nm;
                if (pool->object_size >= sizeof(Dead_PObj)) {
                    ((Dead_PObj*)b)->arena_dod_flag_ptr = dod_flags;
                    ((Dead_PObj*)b)->flag_shift = nm;
                }
#else
                PObj_flags_SETTO((PObj *)b, PObj_on_free_list_FLAG);
#endif
                pool->add_free_object(interpreter, pool, b);
            }
next:
            b = (Buffer *)((char *)b + object_size);
        }
#if ARENA_DOD_FLAGS
        /* reset live bits on last bunch of objects */
        *dod_flags &= ~ALL_LIVE_MASK;
#  if REDUCE_ARENAS
        /* not strictly only for ARENA_DOD_FLAGS, but
         * live_objects is only defined there
         */
        if ( (cur_arena->live_objects = total_used - old_total_used) == 0)
            ++free_arenas;
        old_total_used = total_used;
#  endif
#endif
    }
    pool->num_free_objects = pool->total_objects - total_used;
#if ARENA_DOD_FLAGS
#  if REDUCE_ARENAS
#define REPLENISH_LEVEL_FACTOR 0.3
    if (free_arenas > 1) {
        debug(("pool %s: %d free_arenas\n", pool->name, (int)free_arenas));
        pool->replenish_level =
            (size_t)(pool->total_objects * REPLENISH_LEVEL_FACTOR);
        i = 0;
        while (pool->num_free_objects - i * pool->last_Arena->used *
                REPLENISH_LEVEL_FACTOR > pool->replenish_level &&
                i < free_arenas)
            ++i;
        debug(("\t may free %d\n", (int)i));
        reduce_arenas(interpreter, pool, i-1);
        pool->replenish_level =
            (size_t)(pool->total_objects * REPLENISH_LEVEL_FACTOR);
        pool->num_free_objects = pool->total_objects - total_used;
        pool->skip = 0;
    }
#  undef debug
#  endif
#endif
}

#ifndef PLATFORM_STACK_WALK

/*

=item C<static size_t find_common_mask(size_t val1, size_t val2)>

Find a mask covering the longest common bit-prefix of C<val1> and
C<val2>.

=cut

*/

static size_t
find_common_mask(size_t val1, size_t val2)
{
    int i;
    int bound = sizeof(size_t) * 8;

    /* Shifting a value by its size (in bits) or larger is undefined behaviour.
       So need an explicit check to return 0 if there is no prefix, rather than
       attempting to rely on (say) 0xFFFFFFFF << 32 being 0.  */
    for (i = 0; i < bound; i++) {
        if (val1 == val2) {
            return ~(size_t)0 << i;
        }
        val1 >>= 1;
        val2 >>= 1;
    }
    if (val1 == val2) {
        assert(i == bound);
        return 0;
    }

    internal_exception(INTERP_ERROR,
            "Unexpected condition in find_common_mask()!\n");
    return 0;
}

/*

=item C<void
trace_mem_block(Interp *interpreter,
                size_t lo_var_ptr, size_t hi_var_ptr)>

Traces the memory block between C<lo_var_ptr> and C<hi_var_ptr>.

=cut

*/

void
trace_mem_block(Interp *interpreter,
                size_t lo_var_ptr, size_t hi_var_ptr)
{
    size_t prefix, tmp_ptr;
    ptrdiff_t cur_var_ptr;

    size_t buffer_min = get_min_buffer_address(interpreter);
    size_t buffer_max = get_max_buffer_address(interpreter);
    size_t pmc_min = get_min_pmc_address(interpreter);
    size_t pmc_max = get_max_pmc_address(interpreter);

    size_t mask = find_common_mask(buffer_min < pmc_min ? buffer_min : pmc_min,
            buffer_max > pmc_max ? buffer_max : pmc_max);

    if (!lo_var_ptr || !hi_var_ptr)
        return;
    if (lo_var_ptr < hi_var_ptr) {
        tmp_ptr = hi_var_ptr;
        hi_var_ptr = lo_var_ptr;
        lo_var_ptr = tmp_ptr;
    }
    /* Get the expected prefix */
    prefix = mask & buffer_min;


    for (cur_var_ptr = hi_var_ptr;
            (ptrdiff_t)cur_var_ptr < (ptrdiff_t)lo_var_ptr;
            cur_var_ptr = (size_t)((ptrdiff_t)cur_var_ptr + sizeof(void *))
            ) {
        size_t ptr = *(size_t *)cur_var_ptr;

        /* Do a quick approximate range check by bit-masking */
        if ((ptr & mask) == prefix || !prefix) {
            /* Note that what we find via the stack or registers are not
             * guaranteed to be live pmcs/buffers, and could very well have
             * had their bufstart/vtable destroyed due to the linked list of
             * free headers... */
            if (pmc_min <= ptr && ptr < pmc_max &&
                    is_pmc_ptr(interpreter, (void *)ptr)) {
                /* ...so ensure that pobject_lives checks PObj_on_free_list_FLAG
                 * before adding it to the next_for_GC list, to have
                 * vtable->mark() called. */
                pobject_lives(interpreter, (PObj *)ptr);
            }
            else if (buffer_min <= ptr && ptr < buffer_max &&
                    is_buffer_ptr(interpreter, (void *)ptr)) {
                /* ...and since pobject_lives doesn't care about bufstart, it
                 * doesn't really matter if it sets a flag */
                pobject_lives(interpreter, (PObj *)ptr);
                            
            }
        }
    }
    return;
}
#endif

/*

=item C<static void Parrot_dod_clear_live_bits(Parrot_Interp interpreter)>

Run through all PMC arenas and clear live bits.

=cut

*/

void Parrot_dod_clear_live_bits(Parrot_Interp interpreter);
void
Parrot_dod_clear_live_bits(Parrot_Interp interpreter)
{
    struct Small_Object_Pool *pool = interpreter->arena_base->pmc_pool;
    struct Small_Object_Arena *arena;
    UINTVAL i;
#if !ARENA_DOD_FLAGS
    UINTVAL object_size = pool->object_size;
#endif

    for (arena = pool->last_Arena; arena; arena = arena->prev) {
#if ARENA_DOD_FLAGS
        UINTVAL * dod_flags = arena->dod_flags;
        for (i = 0; i < arena->used; i += (ARENA_FLAG_MASK+1)) {
            /* reset live bits for a bunch of objects */
            *dod_flags &= ~ALL_LIVE_MASK;
            ++dod_flags;
        }
#else
        Buffer *b = arena->start_objects;
        for (i = 0; i < arena->used; i++) {
            PObj_live_CLEAR(b);
            b = (Buffer *)((char *)b + object_size);
        }
#endif
    }
}

/*

=item C<void
Parrot_dod_profile_start(Parrot_Interp interpreter)>

Records the start time of a DOD run when profiling is enabled.

=cut

*/

void
Parrot_dod_profile_start(Parrot_Interp interpreter)
{
    if (Interp_flags_TEST(interpreter, PARROT_PROFILE_FLAG)) {
        interpreter->profile->dod_time = Parrot_floatval_time();
    }
}

/*

=item C<void
Parrot_dod_profile_end(Parrot_Interp interpreter, int what)>

Records the end time of the DOD part C<what> run when profiling is enabled.
Also record start time of next part.

=cut

*/

void
Parrot_dod_profile_end(Parrot_Interp interpreter, int what)
{
    if (Interp_flags_TEST(interpreter, PARROT_PROFILE_FLAG)) {
        RunProfile *profile = interpreter->profile;
        FLOATVAL now = Parrot_floatval_time();

        profile->data[what].numcalls++;
        profile->data[what].time += now - profile->dod_time;
        /*
         * we've recorded the time of a DOD/GC piece from
         * dod_time til now, so add this to the start of the
         * currently executing opcode, which hasn't run this
         * internval.
         */
        profile->starttime += now - profile->dod_time;
        /* prepare start for next step */
        profile->dod_time = now;
    }
}

/*

=item C<void
Parrot_do_dod_run(Interp *interpreter, UINTVAL flags)>

Call the configured garbage collector to reclaim unused headers.

=item C<void
parrot_dod_ms_run(Interp *interpreter, UINTVAL flags)>

Run the stop-the-world mark & sweep collector.


=item C<void
Parrot_dod_ms_run_init(Interp *interpreter, UINTVAL flags)>

Prepare for a mark & sweep DOD run.

=cut

*/

void
Parrot_dod_ms_run_init(Interp *interpreter)
{
    struct Arenas *arena_base = interpreter->arena_base;
#if ARENA_DOD_FLAGS
    int j;
#endif

    arena_base->dod_trace_ptr = NULL;
    arena_base->dod_mark_start = NULL;
    arena_base->num_early_PMCs_seen = 0;
    arena_base->num_extended_PMCs = 0;
#if ARENA_DOD_FLAGS
    clear_live_counter(interpreter, arena_base->pmc_pool);
    for (j = 0; j < (INTVAL)arena_base->num_sized; j++) {
        struct Small_Object_Pool *header_pool =
            arena_base->sized_header_pools[j];
        if (header_pool)
            clear_live_counter(interpreter, header_pool);
    }
#endif
}

static int
sweep_cb(Interp *interpreter, struct Small_Object_Pool *pool, int flag,
        void *arg)
{
    int *total_free = (int *) arg;
#ifdef GC_IS_MALLOC
    if (flag & POOL_BUFFER)
        used_cow(interpreter, pool, 0);
#endif
    Parrot_dod_sweep(interpreter, pool);
#ifdef GC_IS_MALLOC
    if (flag & POOL_BUFFER)
        clear_cow(interpreter, pool, 0);
#endif
    if (interpreter->profile && (flag & POOL_PMC))
        Parrot_dod_profile_end(interpreter, PARROT_PROF_DOD_cp);
    *total_free += pool->num_free_objects;
    return 0;
}

void
Parrot_dod_ms_run(Interp *interpreter, int flags)
{
    struct Arenas *arena_base = interpreter->arena_base;
    /* XXX these should go into the interpreter */
    int total_free = 0;

    if (arena_base->DOD_block_level) {
        return;
    }
    /*
     * the sync sweep is always at the end, so that
     * the live bits are cleared
     */
    if (flags & DOD_finish_FLAG) {
        Parrot_dod_sweep(interpreter, interpreter->arena_base->pmc_pool);
        Parrot_dod_sweep(interpreter, 
		interpreter->arena_base->constant_pmc_pool);
        return;
    }
    ++arena_base->DOD_block_level;
    arena_base->lazy_dod = flags & DOD_lazy_FLAG;
    /*
     * tell the threading system that we gonna DOD mark
     */
    pt_DOD_start_mark(interpreter);
    Parrot_dod_ms_run_init(interpreter);

    /* Now go trace the PMCs */
    if (trace_active_PMCs(interpreter, flags & DOD_trace_stack_FLAG)) {

        arena_base->dod_trace_ptr = NULL;
        arena_base->dod_mark_ptr = NULL;
        /*
         * mark is now finished
         */
        /* pt_DOD_stop_mark(interpreter); */

        /* Now put unused PMCs and Buffers on the free list */
        Parrot_forall_header_pools(interpreter, POOL_BUFFER | POOL_PMC,
            (void*)&total_free, sweep_cb);
        if (interpreter->profile)
            Parrot_dod_profile_end(interpreter, PARROT_PROF_DOD_cb);
    }
    else {
        /*
         * successful lazy DOD count
         */
        ++arena_base->lazy_dod_runs;
        /* it was an aborted lazy dod run - we should clear
         * the live bits, but e.g. t/pmc/timer_7 succeeds w/o this
         */
#if 1
        Parrot_dod_clear_live_bits(interpreter);
#endif
        if (interpreter->profile)
            Parrot_dod_profile_end(interpreter, PARROT_PROF_DOD_p2);
    }
    pt_DOD_stop_mark(interpreter);
    /* Note it */
    arena_base->dod_runs++;
    --arena_base->DOD_block_level;
    return;
}

void
Parrot_do_dod_run(Interp *interpreter, UINTVAL flags)
{
    interpreter->arena_base->do_dod_run(interpreter, flags);
    parrot_gc_context(interpreter);
}

/*

=back

=head1 SEE ALSO

F<include/parrot/dod.h>, F<src/cpu_dep.c>, F<docs/dev/dod.dev> and
F<docs/pdds/pdd09_gc.pod>.

=head1 HISTORY

Initial version by Mike Lambert on 2002.05.27.

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
