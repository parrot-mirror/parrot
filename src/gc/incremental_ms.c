/*
Copyright (C) 2001-2008, The Perl Foundation.
$Id: gc_it.c 34092 2008-12-19 01:35:50Z Whiteknight $

=head1 NAME

src/gc/gc_it.c - Incremental Tricolor Garbage Collector

=head1 DESCRIPTION

This file implements the majority of the incremental tri-color garbage
collector for Parrot. The interface for this and all collectors is
specified in F<docs/pdds/pdd09_gc.pod>.

=cut

*/

#include "parrot/parrot.h"
#include "parrot/dod.h"

#if PARROT_GC_IT

#  if GC_IT_SERIAL_MODE
#    define gc_it_trace(i) gc_it_trace_normal(i);
#  elif GC_IT_PARALLEL_MODE
#    define gc_it_trace(i) gc_it_trace_threaded(i);
#  endif

/* HEADERIZER HFILE: include/parrot/dod.h */

/* HEADERIZER BEGIN: static */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

static void gc_it_add_arena_to_free_list(PARROT_INTERP,
    ARGMOD(Small_Object_Pool *pool),
    ARGMOD(Small_Object_Arena *new_arena))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*pool)
        FUNC_MODIFIES(*new_arena);

PARROT_INLINE
static void gc_it_enqueue_all_roots(PARROT_INTERP)
        __attribute__nonnull__(1);

static void gc_it_enqueue_next_root(PARROT_INTERP)
        __attribute__nonnull__(1);

static void gc_it_finalize_all_pmc(PARROT_INTERP)
        __attribute__nonnull__(1);

static void gc_it_finalize_arena(PARROT_INTERP,
    ARGMOD(Small_Object_Pool * pool),
    ARGMOD(Small_Object_Arena *arena))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(* pool)
        FUNC_MODIFIES(*arena);

static void gc_it_finalize_PMC_arenas(PARROT_INTERP,
    ARGMOD(Gc_it_data *gc_priv_data),
    ARGMOD(Small_Object_Pool *pool))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*gc_priv_data)
        FUNC_MODIFIES(*pool);

PARROT_INLINE
static void gc_it_mark_PObj_children_grey(PARROT_INTERP,
    ARGMOD(Gc_it_hdr *hdr))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*hdr);

static void gc_it_post_sweep_cleanup(PARROT_INTERP)
        __attribute__nonnull__(1);

static void gc_it_sweep_header_arenas(PARROT_INTERP,
    ARGMOD(Gc_it_data *gc_priv_data),
    ARGMOD(Small_Object_Pool *pool))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*gc_priv_data)
        FUNC_MODIFIES(*pool);

static void gc_it_sweep_PMC_arenas(PARROT_INTERP,
    ARGMOD(Gc_it_data *gc_priv_data),
    ARGMOD(Small_Object_Pool *pool))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*gc_priv_data)
        FUNC_MODIFIES(*pool);

static void gc_it_sweep_pmc_pools(PARROT_INTERP)
        __attribute__nonnull__(1);

static void gc_it_sweep_sized_pools(PARROT_INTERP)
        __attribute__nonnull__(1);

/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: static */

/*

=head1 Functions

=over 4

=item C<void Parrot_gc_it_init>

Initializes the GC, sets the necessary pointers in the interpreter.
We initialize the Gc_it_data structure for the GC, and set the initial
state of the collector.

=cut

*/

PARROT_EXPORT
void
Parrot_gc_it_init(PARROT_INTERP)
{
    Gc_it_data        *gc_priv_data;
    Arenas     * const arena_base  = interp->arena_base;

    /* Create our private data. We might need to initialize some things
    here, depending on the data we include in this structure */
    arena_base->gc_private         = mem_allocate_zeroed_typed(Gc_it_data);
    gc_priv_data                   = (Gc_it_data *)arena_base->gc_private;
    gc_priv_data->state            = GC_IT_READY;

    /* set function hooks according to pdd09 */
    arena_base->do_gc_mark         = Parrot_gc_it_run;
    arena_base->finalize_gc_system = Parrot_gc_it_deinit;
    arena_base->init_pool          = Parrot_gc_it_pool_init;
    {
        /* Let's just test the hell out of this to make sure that things are
           doing what I think they are doing. */
        Gc_it_hdr * hdr = 0;
        UINTVAL h = (UINTVAL)hdr;
        UINTVAL p;
        PObj * pobj = (PObj*)(hdr + 1);
        p = h + sizeof(Gc_it_hdr);
        PARROT_ASSERT(hdr == PObj_to_IT_HDR(IT_HDR_to_PObj(hdr)));
        PARROT_ASSERT(&(hdr[1]) == (hdr + 1));
        PARROT_ASSERT((hdr + 1) == (Gc_it_hdr*)((char*)hdr + sizeof(Gc_it_hdr)));
        PARROT_ASSERT((void*)pobj > (void*)hdr);
        PARROT_ASSERT(p > h);
        PARROT_ASSERT(p == (UINTVAL)pobj);
        PARROT_ASSERT(hdr == PObj_to_IT_HDR(pobj));
        PARROT_ASSERT(pobj == IT_HDR_to_PObj(hdr));
    }
#  if GC_IT_DEBUG
    fprintf(stderr, "GC IT Initialized: %p\n", gc_priv_data);
    fprintf(stderr, "SIZES. Hdr: %d, Data: %d\n", sizeof (Gc_it_hdr),
        sizeof (Gc_it_data));
#  endif
}


/*

=item C<void Parrot_gc_it_run>

Run the GC. Not sure what it means to "run" yet, might only run one
increment, or one step from many.

Basic Algorithm:
1) Determine which pool/generation to scan
2) Mark root items as being grey
3) For all grey items, mark all children as grey, then mark item as black
4) repeat (3) until there are no grey items in current pool/generation
5) mark all objects grey that appear in IGP lists. Repeat (1) - (4) for these
6) Add all items that are still white to the free list
7) Scan through simple buffers, add white objects to free list
8) reset all flags to white
Only reclaim objects where there are no greys in the current area,
and when a run has completed. Do not reclaim, for instance, any white
objects after a run has completed and all black objects have been turned
back to white (which would free all objects, alive or dead).

Flags and other issues, as I understand them:
GC_trace_normal = run a trace, or a partial trace, but not a sweep.
    set the macro CHECK_IF_WE_BREAK_BEFORE_SWEEP, however we do that,
    to break off the function after the trace phase.
GC_trace_stack_FLAG = we need to trace the C stack and the processor
    registers too. I wouldn't even know how to start doing this.
GC_lazy_FLAG = Appears we run a sweep phase if we have already marked,
    or complete the current mark and then sweep. Or, we find some other
    way to free items that are obviously dead.
GC_finish_FLAG = set all objects to dead, call all finalizers on PMC
    objects. We don't need to mark free items, since everything is going
    to die anyway.

If GC_trace_normal && (GC_IT_FLAG_NEW_MARK || GC_IT_FLAG_RESUME_MARK)
    run a trace or resume the current trace.

if GC_trace_normal && (GC_IT_FLAG_NEW_SWEEP || GC_IT_FLAG_RESUME_SWEEP)
    do nothing

if GC_lazy_FLAG && (GC_IT_FLAG_NEW_SWEEP || GC_IT_FLAG_RESUME_SWEEP)
    run a sweep, possibly to conclusion.

if GC_finish_FLAG
    run a complete sweep of the PMC area calling finalizers only but not
    marking objects or adding objects to the free list

=cut

*/

PARROT_EXPORT
void
Parrot_gc_it_run(PARROT_INTERP, int flags)
{
    const Arenas * const arena_base   = interp->arena_base;
    Gc_it_data   * const gc_priv_data = (Gc_it_data *)(arena_base->gc_private);
    const UINTVAL gc_trace    = flags & (GC_trace_normal | GC_trace_stack_FLAG);
    const UINTVAL gc_lazy     = flags & GC_lazy_FLAG;
    const UINTVAL gc_stack    = (gc_lazy) ? (0) : (flags & GC_trace_stack_FLAG);
    const UINTVAL gc_finish   = flags & GC_finish_FLAG;
    const UINTVAL gc_force    = gc_lazy && interp->arena_base->num_early_DOD_PMCs;

    /* on a lazy run, we only sweep if there are PMCs needing early destruction.
       We don't really cover that now, so we ignore and return. */
    if (gc_lazy && !gc_force)
        return;
    if (gc_finish) {

#  if GC_IT_DEBUG
        fprintf(stderr, "Finalizing GC system\n");
#  endif

        /* If we've gotten the finish flag, the interpreter is closing down.
           go through all items, call finalization on all PMCs, and do
           whatever else we need to do. */
        gc_priv_data->state = GC_IT_RESUME_MARK;

        /* Go through the PMC arena and finalize all PMCs that are still
           alive at this point. */
        gc_it_finalize_all_pmc(interp);
        gc_priv_data->state = GC_IT_FINAL_CLEANUP;
        return;
    }
#  if GC_IT_DEBUG
    //fprintf(stderr, "GC Run. items total: %d, flags: %x, state: %d\n",
    //        (int)gc_priv_data->total_count, flags, gc_priv_data->state);
#  endif

    /* items scanned this run */
    gc_priv_data->item_count = 0;

    switch (gc_priv_data->state) {
        case GC_IT_READY:
            gc_priv_data->state = GC_IT_START_MARK;
            GC_IT_BREAK_AFTER_0;

        case GC_IT_START_MARK:
            gc_priv_data->total_count = 0;
            gc_priv_data->state       = GC_IT_MARK_ROOTS;
            GC_IT_BREAK_AFTER_1;

        case GC_IT_MARK_ROOTS:
            if (Parrot_is_blocked_GC_mark(interp))
                break;
            if (gc_trace && gc_stack)
                Parrot_dod_trace_root(interp, 1);
            else if (gc_stack)
                Parrot_dod_trace_root(interp, 2);
            else if (gc_trace)
                Parrot_dod_trace_root(interp, 0);
            gc_priv_data->state = GC_IT_RESUME_MARK;
            GC_IT_BREAK_AFTER_2;

        case GC_IT_RESUME_MARK:
            if (Parrot_is_blocked_GC_mark(interp))
                break;
#  if GC_IT_INCREMENT_MODE
            /* scan a single tree. Check to ensure we've hit a minimum number
               of items. If not, scan another tree. */
            /*do {
                gc_it_enqueue_next_root(interp);
                gc_it_trace(interp);
            } while (gc_priv_data->item_count < GC_IT_ITEMS_MARKED_MIN
            &&      gc_priv_data->root_queue);*/
            /* We've either scanned the necessary number of items, or we've
               run out of new root items to scan. Check to see if the mark
               is complete, and if so move to the next state. Otherwise,
               stay at the same state so we can come back. */
            if (!gc_priv_data->queue
            &&  !gc_priv_data->root_queue)
                gc_priv_data->state = GC_IT_END_MARK;
            else
                break;
#  elif GC_IT_BATCH_MODE
            /* in batch mode, enqueue all roots, and scan the entire pile */
            gc_it_enqueue_all_roots(interp);
            gc_it_trace(interp);
#  endif
            GC_IT_BREAK_AFTER_3;

        case GC_IT_END_MARK:
            /* Don't know if there is anything to be done here */
            gc_priv_data->state = GC_IT_SWEEP_PMCS;
            GC_IT_BREAK_AFTER_4;

        case GC_IT_SWEEP_PMCS:
            if (Parrot_is_blocked_GC_sweep(interp))
                break;
            //gc_it_sweep_pmc_pools(interp);
            gc_priv_data->state = GC_IT_SWEEP_BUFFERS;
            GC_IT_BREAK_AFTER_5;

        case GC_IT_SWEEP_BUFFERS:
            if (Parrot_is_blocked_GC_sweep(interp))
                break;
            gc_it_sweep_sized_pools(interp);
            gc_priv_data->state = GC_IT_FINAL_CLEANUP;
            GC_IT_BREAK_AFTER_6;

        case GC_IT_FINAL_CLEANUP:
            gc_it_post_sweep_cleanup(interp); /* if any. */
        default:
            gc_priv_data->state = GC_IT_READY;
    }
    return;
}

/*

=item C<void gc_it_trace_normal>

Perform a "normal" (i.e. not "threaded") trace. We run through the entire
queue, and continue to scan until the queue is empty. The secret to the
incremental behavior of the collector is careful limiting of what objects
are added to the queue in the first place. We store root objects on the
separate C<root_queue>, and add them one-at-a-time to the queue before
we call this function. This algorithm is probably best called "tree at a
time", because we scan a single tree from the root all the way through to
it's children.

=cut

*/

void
gc_it_trace_normal(PARROT_INTERP)
{
    /* trace through the entire queue until it is empty. */
    Gc_it_hdr         *hdr;
    Gc_it_data * const gc_priv_data =
        (Gc_it_data *)interp->arena_base->gc_private;

    if (!gc_priv_data->queue)
        /* The queue is empty, don't try to trace because it won't work. */
        return;

#    if GC_IT_DEBUG
    fprintf(stderr, "Tracing queue, starting with %p\n", gc_priv_data->queue);
#    endif

    for (hdr = gc_priv_data->queue; hdr; hdr = gc_priv_data->queue) {
        /* for each item, add all chidren to the queue, and then mark the item
           black. Once black, the item can be removed from the queue */
        PARROT_ASSERT(hdr);
        gc_it_mark_PObj_children_grey(interp, hdr);
        gc_it_set_card_mark(hdr, GC_IT_CARD_BLACK);
        gc_priv_data->queue = hdr->next;

        /* Items that have been marked are put into a "marked" list to keep
           them from being marked twice in the same mark phase. */
        hdr->next = gc_priv_data->marked;
        gc_priv_data->marked = hdr->next;

        /* total items since beginning of scan */
        gc_priv_data->total_count++;

        /* number of items this increment */
        gc_priv_data->item_count++;
    }
#    if GC_IT_DEBUG
    fprintf(stderr, "Trace complete: %d\n", (gc_priv_data->queue == NULL));
#    endif
    PARROT_ASSERT(gc_priv_data->queue == NULL);
}


/*

=item C<static void gc_it_sweep_pmc_pools>

Sweeps through pools that are not part of the sized header pools, such as the
string header pool and the PMC pool. Does not sweep through related pools,
such as the constant string header pool or the constant PMC pool because those
should not be swept. Frees dead objects and returns them to the pool free lists.

=cut

*/

static void
gc_it_sweep_pmc_pools(PARROT_INTERP)
{
    const Arenas * const arena_base   = interp->arena_base;
    Gc_it_data   * const gc_priv_data = (Gc_it_data *)arena_base->gc_private;

    /* If the queue has stuff on it, trace that first */
    if (gc_priv_data->queue)
        gc_it_trace(interp);
    gc_it_sweep_PMC_arenas(interp, gc_priv_data, arena_base->pmc_pool);
}


/*

=item C<static void gc_it_finalize_all_pmc>

Performs the final GC run, sweeping through the pmc pool and calling any custom
destroy VTABLE entries.

=cut

*/

static void
gc_it_finalize_all_pmc(PARROT_INTERP)
{
    const Arenas * const arena_base   = interp->arena_base;
    Gc_it_data   * const gc_priv_data = (Gc_it_data *)arena_base->gc_private;
    register UINTVAL i;

    /* PMCs need to be handled differently from other types of pools.  Set
       up lists of our pools here, and handle different types differently. */
    gc_it_finalize_PMC_arenas(interp, gc_priv_data, arena_base->pmc_pool);
}


/*

=item C<static void gc_it_finalize_PMC_arenas>

In a particular PMC pool, runs through all arenas and call custom finalization
methods of all live PMCs, if any.

I need to rework this whole function, but it's a good placeholder for now

=cut

*/

static void
gc_it_finalize_PMC_arenas(PARROT_INTERP, ARGMOD(Gc_it_data *gc_priv_data),
    ARGMOD(Small_Object_Pool *pool))
{
    Small_Object_Arena *arena;

    /* walking backwards helps avoid incorrect order-of-destruction bugs */
    for (arena = pool->last_Arena; arena; arena = arena->prev) {
        gc_it_finalize_arena(interp, pool, arena);
    }
}

/*

=item C<static void gc_it_finalize_arena>

Finalizes one arena, assuming the objects in it are PMCs.
Loops through the arena and adds all objects in it to a linked list in
reverse order. Then, traverse through this linked list and finalize any
items that are still alive. This isn't perfect, and may create order-
of-destruction bugs when a parent is destroyed before it's children.

=cut

*/

static void
gc_it_finalize_arena(PARROT_INTERP, ARGMOD(Small_Object_Pool * pool),
    ARGMOD(Small_Object_Arena *arena))
{
    UINTVAL i;
    const UINTVAL num_objs = arena->total_objects;
    Gc_it_hdr * hdr = (Gc_it_hdr *)arena->start_objects;
    Gc_it_hdr * list = NULL;

    for (i = 0; i < num_objs; i++) {
        PObj * const obj = IT_HDR_to_PObj(hdr);
        hdr->next = list;
        list = hdr;
        hdr = ((Gc_it_hdr *)((char *)hdr + pool->object_size));
    }
    while ((hdr = list) != NULL) {
        list = hdr->next;
        /* We call Parrot_dod_free_pmc here, when it might be easier
           to just call the finalization methods and not free them. */
        if (gc_it_get_card_mark(hdr) != GC_IT_CARD_FREE)
            Parrot_dod_free_pmc(interp, pool, IT_HDR_to_PObj(hdr));
    }
}

/*

=item C<static void gc_it_sweep_sized_pools>

Sweeps through the sized pools, freeing dead objects.

=cut

*/

static void
gc_it_sweep_sized_pools(PARROT_INTERP)
{
    const Arenas * const arena_base   = interp->arena_base;
    Gc_it_data   * const gc_priv_data = (Gc_it_data *)arena_base->gc_private;
    register INTVAL i;

    if (gc_priv_data->queue)
        gc_it_trace(interp);
    for (i = arena_base->num_sized - 1; i >= 0; i--) {
        Small_Object_Pool * const pool = arena_base->sized_header_pools[i];
        if (pool)
            gc_it_sweep_header_arenas(interp, gc_priv_data, pool);
    }

}


/*

=item C<static void gc_it_sweep_PMC_arenas>

If the pool contains PMCs, we sweep through it. When a dead object is found, we
call C<Parrot_dod_free_pmc> on it. This should, in theory, kill the PMC and
clean up all its dependencies. After the PMC is dead, we add it to the pool's
free list.

=cut

*/

static void
gc_it_sweep_PMC_arenas(PARROT_INTERP, ARGMOD(Gc_it_data *gc_priv_data),
    ARGMOD(Small_Object_Pool *pool))
{
    /* Go through each arena in the pool, free objects marked white,
       set black cards to white, and call finalization routines, if needed. */
    Small_Object_Arena *arena;
    Gc_it_hdr * hdr;

#    if GC_IT_DEBUG
    fprintf(stderr, "Sweeping PMC pool %s (%p)\n", pool->name, pool);
#    endif

    for (arena = pool->last_Arena; arena; arena = arena->prev) {
        INTVAL i         = arena->total_objects;
        Gc_it_hdr *hdr   = (Gc_it_hdr *)arena->start_objects;
        UINTVAL    mark;

        while (i > 0) {
            /* this is a heavily stripped-down version of what it should be.
               Eventually, this is all going to get more efficient:
               1) need to unroll the loop a little bit
               2) Going to handle the cards directly, instead of making all
                  these function calls.
            */
            mark = gc_it_get_card_mark(hdr);
            if (mark == GC_IT_CARD_WHITE) {
                PObj * pobj = IT_HDR_to_PObj(hdr);
                if (PObj_needs_early_DOD_TEST(pobj))
                    --interp->arena_base->num_early_DOD_PMCs;
                if (!PObj_constant_TEST(pobj)) {
                    gc_it_add_free_header(interp, pool, hdr);
                    Parrot_dod_free_pmc(interp, pool, IT_HDR_to_PObj(hdr));
                    ++pool->num_free_objects;
                }
            }
            else if (mark == GC_IT_CARD_BLACK) {
                gc_it_set_card_mark(hdr, GC_IT_CARD_WHITE);
                /* Make sure it's not on the marked list anymore */
                hdr->next = NULL;
            }

            hdr = (Gc_it_hdr*)((char*)hdr + (pool->object_size));
            i--;
        }
    }
}


/*

=item C<static void gc_it_sweep_header_arenas>

Sweeps through the header pool, and frees dead objects. Unlike PMCs, we don't
need to kill the dead object first (that i'm aware of), we just add the header
to the pool's free list.

=cut

*/

static void
gc_it_sweep_header_arenas(PARROT_INTERP, ARGMOD(Gc_it_data *gc_priv_data),
    ARGMOD(Small_Object_Pool *pool))
{
    Small_Object_Arena *arena;

#    if GC_IT_DEBUG
    fprintf(stderr, "Sweeping buffer pool %s (%p)\n", pool->name, pool);
#    endif

    for (arena = pool->last_Arena; arena; arena = arena->prev) {
        INTVAL i                      = arena->total_objects;
        Gc_it_hdr *hdr                = (Gc_it_hdr *)arena->start_objects;
        UINTVAL mark;

        /* Partially unroll the loop with Duff's device: four items at a time.
           I can make some parts of this more efficient, but for now let's
           stick with the basics. */
        while (i > 0) {
            mark = gc_it_get_card_mark(hdr);
            if (mark == GC_IT_CARD_WHITE) {
                gc_it_add_free_header(interp, pool, hdr);
                ++pool->num_free_objects;
            }
            else if (mark == GC_IT_CARD_BLACK) {
                gc_it_set_card_mark(hdr, GC_IT_CARD_WHITE);
                hdr->next = NULL;
            }
            hdr = (Gc_it_hdr*)((char*)hdr + (pool->object_size));
            i--;
        }
    }
}

/*

=item C<static void gc_it_enqueue_all_roots>

"batch mode" is a mode where the GC performs a complete stop-the-world
mark phase, instead of the incremental behaviour which is the default.

Moves all items from the root queue into the ordinary queue. If the queue
is not empty, we run a trace first to mark all items on the queue already.

=cut

*/

#  if GC_IT_BATCH_MODE
PARROT_INLINE
static void
gc_it_enqueue_all_roots(PARROT_INTERP)
{
    Gc_it_data * const gc_priv_data =
        (Gc_it_data *)interp->arena_base->gc_private;

    /* If the queue is not currently empty, trace through it real quick so
       we don't lose anything. This is probably not the right way to go, but
       it should work. */
    if (gc_priv_data->queue) {
#  if GC_IT_DEBUG
        fprintf(stderr, "Objects on queue before root queue. Tracing.\n");
#  endif
        gc_it_trace_normal(interp);
    }

    PARROT_ASSERT(!gc_priv_data->queue);
    /* Move the entire root queue to the queue */
    gc_priv_data->queue       = gc_priv_data->root_queue;
    gc_priv_data->root_queue  = NULL;
#  if GC_IT_DEBUG
    fprintf(stderr, "Root queue added to queue\n");
#  endif
}
#  endif

#  if GC_IT_INCREMENT_MODE
/*

=item C<static void gc_it_enqueue_next_root>

In normal incremental mode, we add a single item from the root queue onto
the ordinary queue. However, we only add aggregate items: non-aggregate
root items are marked immediately and discarded. We don't want to waste
an entire GC increment marking a single item.

=cut

*/

static void
gc_it_enqueue_next_root(PARROT_INTERP)
{
    Gc_it_data * const gc_priv_data =
        (Gc_it_data *)interp->arena_base->gc_private;
    Gc_it_hdr         *hdr          = gc_priv_data->root_queue;

    /* The root queue is empty, nothing for us to do here. We return
       immediately so the GC can move to the next state. */
    if (!hdr)
        return;

    /* Move the hdr off the root queue, and add it to the queue. */
    gc_priv_data->root_queue = hdr->next;
    hdr->next = gc_priv_data->queue;
    gc_priv_data->queue = hdr;
}
#  endif


/*

=item C<static void gc_it_mark_PObj_children_grey>

Marks the children of the current PObj node grey. "Children" can be data, or
metadata, and may be in several places. We need to search around to see
what children there are, and add all of them to the queue.

Places to search (for PMCs):
1) C<PMC_metadata(obj)>
2) C<obj->real_self>
3) C<PMC_next_for_GC(obj)>
4) C<obj->pmc_ext>
5) C<VTABLE_mark(obj)>, if C<PObj_custom_mark_TEST(obj) == 1>
Notice that "special" children of the PMC are marked already using
C<mark_special> in the call to C<pobject_lives>.

For all PObjs:
1) PObj data, if C<PObj_data_is_PMC_array_FLAG>

For strings:
1) Memory pool buffer that contains the actual string data

To mark a child as grey, we do one of two things:
1) If the child is a PMC, we call C<pobject_lives> to ensure that special
   PMCs go through C<mark_special>
2) If the child is a non-PMC PObj, we add it's header to the queue directly,
   and do not need to call C<pobject_lives>.
3) If the child is a non-PObj simple buffer, we mark it black directly and
   do not enqueue it.

=cut

*/

PARROT_INLINE
static void
gc_it_mark_PObj_children_grey(PARROT_INTERP, ARGMOD(Gc_it_hdr *hdr))
{
    /* Add all children of the current node to the queue for processing. */
    PObj * const obj = IT_HDR_to_PObj(hdr);
    PMC  * const pmc = (PMC *)obj;

    PARROT_ASSERT(hdr);
    PARROT_ASSERT(obj);

    if (PObj_is_PMC_TEST(obj)) {
        if (pmc->pmc_ext) {
            const PMC * next_for_gc = PMC_next_for_GC(pmc);
            object_lives(interp, (PObj *)(pmc->pmc_ext));
            if (PMC_metadata(pmc))
                pobject_lives(interp, (PObj *)PMC_metadata(pmc));
            if (next_for_gc != pmc && next_for_gc != NULL)
                pobject_lives(interp, (PObj *)PMC_next_for_GC(pmc));
        }

        if (pmc->real_self != pmc && pmc->real_self != NULL)
            pobject_lives(interp, (PObj *)(pmc->real_self));
    }
    else if (PObj_is_string_TEST(obj)) {
        /* XXX: It's a string or a const-string, or whatever. Deal
                with that here. */
    }

    /* if the PMC is an array of other PMCs, we cycle through those. I'm
       surprised if this isn't covered by VTABLE_mark, but I won't question it
       now. */
    if (obj->flags & PObj_data_is_PMC_array_FLAG)
        Parrot_dod_trace_pmc_data(interp, pmc);

    /* if it's a PMC with a custom mark routine, call that here. The
       custom mark routine will call pobject_lives on the children,
       which will add them to the queue properly. */
    if (PObj_custom_mark_TEST(obj))
        VTABLE_mark(interp, pmc);

    /* If the item is shared, we need to do some magic trickery with it. I
       don't know if I'm going to do said trickery here, or offload it to a
       function like src/gc/dod.c:mark_special (which is where some of the
       other logic in this function originated) */
}


/*

=item C<void Parrot_gc_it_deinit>

Kill the GC and reset everything.

1) Free all generation structures
2) Free all GC headers in all pools and arenas, if possible
3) Free any additional memory that i will create in the future

=cut

*/

PARROT_EXPORT
void
Parrot_gc_it_deinit(PARROT_INTERP)
{
    Arenas * const arena_base = interp->arena_base;

    mem_internal_free(arena_base->gc_private);
    arena_base->gc_private        = NULL;

    /* Null-out the function pointers, except the init pointer
       who knows? the interp might want to load us up again. */
    arena_base->do_gc_mark         = NULL;
    arena_base->finalize_gc_system = NULL;
    arena_base->init_pool          = NULL;
}


/*

=item C<void Parrot_gc_it_pool_init>

Initializes a new memory pool by setting the pointers to the necessary
functions, and setting the size of the objects to include the GC header.

=cut

*/

PARROT_EXPORT
void
Parrot_gc_it_pool_init(PARROT_INTERP, ARGMOD(Small_Object_Pool *pool))
{
    /* Set up function pointers for pool. */
    pool->add_free_object = gc_it_add_free_object;
    pool->get_free_object = gc_it_get_free_object;
    pool->alloc_objects   = gc_it_alloc_objects;
    pool->more_objects    = gc_it_more_objects;
    pool->free_list       = NULL;
    pool->last_Arena      = NULL;

    /* Initially, arena allocations are relatively small. Let's not try to
       force a GC run until a few arena's are allocated. This should also
       prevent wasting time in the GC for small one-liner programs. */
    pool->skip            = 2;

    /* Increase allocated space to account for GC header */
    pool->object_size += sizeof (Gc_it_hdr);

#  if GC_IT_DEBUG
    fprintf(stderr, "Initialized pool (%p). Item size: %d\n", pool,
        pool->object_size);
#  endif
}


/*

=item C<void gc_it_add_free_object>

Adds a dead item to the free list. I suppose this is for cases where other
systems are trying to manage their own memory manually.

This forces an unused item to be moved to the free list of it's parent pool.
We only free an object if it's not already on the free list or on the queue.
Ideally, all items should be freed automatically, so this function should
become obsolete. If it's no longer used, I will get rid of it.

=item C<void gc_it_add_free_header>

Takes a Gc_it_hdr object and adds it's corresponding object to the pool's
free list.

=cut

*/

PARROT_EXPORT
void
gc_it_add_free_object(PARROT_INTERP, ARGMOD(struct Small_Object_Pool *pool),
    ARGMOD(void *to_add))
{
    PObj * p = (PObj*)to_add;
    Gc_it_hdr * const hdr = PObj_to_IT_HDR(p);
    PARROT_ASSERT(IT_HDR_to_PObj(hdr) == p);
    PARROT_ASSERT(contained_in_pool(pool, p));
    gc_it_add_free_header(interp, pool, hdr);
}

PARROT_INLINE
void
gc_it_add_free_header(SHIM_INTERP, ARGMOD(struct Small_Object_Pool * pool),
    ARGMOD(Gc_it_hdr * hdr))
{
    /* If the item is already on the free list, short-circuit and return. If
       it's in the queue, we can't free it or we lose all the free objects
       in the queue after this one. So, in either case, we short circuit
       here and don't free the object manually. */
    if (hdr->next)
       return;

#  if GC_IT_DEBUG
    /* This check is costly but helpful. */
    {
        const PObj * const p = IT_HDR_to_PObj(hdr);
        PARROT_ASSERT(contained_in_pool(pool, p));
    }
#  endif

    ++pool->num_free_objects;

    hdr->next       = (Gc_it_hdr *)pool->free_list;
    pool->free_list = hdr;

    gc_it_set_card_mark(hdr, GC_IT_CARD_FREE);
}


/*

=item C<void * gc_it_get_free_object>

Gets an object from the pool's free list and return a pointer to it. If
no objects are on the free list, allocate a new arena of objects. The item
allocated is immediately marked black so any concurrent GC action doesn't
snatch it up.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PARROT_EXPORT
void *
gc_it_get_free_object(PARROT_INTERP, ARGMOD(struct Small_Object_Pool *pool))
{
    Gc_it_hdr * hdr;
    const Gc_it_data * const gc_priv_data = (Gc_it_data *)interp->arena_base->gc_private;
    const Gc_it_state state = gc_priv_data->state;

    /* If there are no objects, allocate a new arena */
    if (!pool->free_list)
        (pool->more_objects)(interp, pool);
    PARROT_ASSERT(pool->free_list);

    /* pull the first header off the free list */
    hdr = (Gc_it_hdr *)pool->free_list;
    pool->free_list = (void *)hdr->next;
    hdr->next = NULL;
    --pool->num_free_objects;

    PARROT_ASSERT(hdr);

    /* Depending where we are in the GC run, we can set the mark accordingly */
    switch (state) {
        case GC_IT_READY:
        case GC_IT_START_MARK:
        case GC_IT_MARK_ROOTS:
        case GC_IT_FINAL_CLEANUP:
            gc_it_set_card_mark(hdr, GC_IT_CARD_WHITE);
            break;
        case GC_IT_RESUME_MARK:
            gc_it_set_card_mark(hdr, GC_IT_CARD_BLACK);
            break;
        case GC_IT_END_MARK:
        case GC_IT_SWEEP_PMCS:
        case GC_IT_SWEEP_BUFFERS:
            gc_it_set_card_mark(hdr, GC_IT_CARD_BLACK);
            break;
        default:
            /* we shouldn't ever be here, but the compiler spits out a
               warning if we don't have a default, so I jam it in. */
            break;
    }

    /* clear the aggregate flag, in case it hasn't been done yet */
    hdr->data.agg = 0;

/*
#  if GC_IT_DEBUG
    fprintf(stderr, "Get free object from pool %s (%p): %p (%d left) \n",
            pool->name, pool, hdr, pool->num_free_objects);
#  endif
*/

    /* return pointer to the object from the header */
    return (void *)IT_HDR_to_PObj(hdr);
}


/*

=item C<void gc_it_alloc_objects>

Allocates a new Small_Object_Arena from the OS and sets it up as necessary. The
arena contains enough space to house several objects of the given size, and we
allocate locally from these arenas as needed.

The memory block for the arena is allocated large enough to hold not only the
arena's object, but also the C<Small_Object_Arena> structure itself and the
C<Gc_it_card> array for cardmarking. Here's a layout of how things look in
memory:

[ Small_Object_Arena | Cards | ... Objects ... ]

And each object looks like this:

[ Gc_it_hdr | Data ]

This kind of layout requires a few extra pointer operations, which is
obnoxious, but it saves on fewer allocations and making better use of memory
locality. Once everything gets set up, macros and cached pointers hide all
the initialization nastyness.

=cut

*/

PARROT_EXPORT
void
gc_it_alloc_objects(PARROT_INTERP, ARGMOD(struct Small_Object_Pool *pool))
{
    const size_t object_size       = pool->object_size;
    const size_t objects_per_alloc = pool->objects_per_alloc;

    /* The size of the allocated arena. This is the size of the
       Small_Object_Arena structure, which goes at the front, the card, and
       the objects. */
    const size_t arena_size = (object_size * objects_per_alloc)
                            + sizeof (Small_Object_Arena);
    Small_Object_Arena * const new_arena =
        (Small_Object_Arena *)mem_internal_allocate_zeroed(arena_size);

    new_arena->total_objects = objects_per_alloc;
    new_arena->start_objects = (void *)(((char *)new_arena) + sizeof (Small_Object_Arena));

    /* insert new_arena in pool's arena linked list */
    new_arena->next = NULL;
    new_arena->prev = NULL;
    Parrot_append_arena_in_pool(interp, pool, new_arena,
        object_size * objects_per_alloc);

    /* Add all these new objects we've created into the pool's free list.
       this is where the rest of the messy pointer arithmetic happens. */
    gc_it_add_arena_to_free_list(interp, pool, new_arena);

    /* allocate more next time */
    pool->objects_per_alloc =
        (UINTVAL)objects_per_alloc * UNITS_PER_ALLOC_GROWTH_FACTOR;
    pool->replenish_level   =
        (size_t)(pool->total_objects * REPLENISH_LEVEL_FACTOR);

    if (arena_size > POOL_MAX_BYTES)
        pool->objects_per_alloc = POOL_MAX_BYTES / object_size;
    if (pool->objects_per_alloc > GC_IT_MAX_IN_ARENA)
        pool->objects_per_alloc = GC_IT_MAX_IN_ARENA;
}


/*

=item C<static void gc_it_add_arena_to_free_list>

Adds all of the new objects from a newly allocated arena structure to the
pool's free list. We start at the beginning of the arena's memory block and do
the following steps:

1) add the current object to the free list
2) calculate the address of the next GC header in the arena. This is the part
   that requires pointer dark magic, and is likely the source of bugs.
3) set the C<next> field of the current object to the address of the
   next object, which we've just calculated in #3 above. Update the current
   object pointer to point to the next item.
4) repeat for all items in the arena

=cut

*/

static void
gc_it_add_arena_to_free_list(PARROT_INTERP,
    ARGMOD(Small_Object_Pool *pool), ARGMOD(Small_Object_Arena *new_arena))
{
    Gc_it_hdr       *p        = (Gc_it_hdr *)new_arena->start_objects;
    const size_t     num_objs = new_arena->total_objects;
    register size_t  i;

    PARROT_ASSERT(new_arena == pool->last_Arena);
    PARROT_ASSERT((ptrdiff_t)p - (ptrdiff_t)new_arena->start_objects == 0);
    //PARROT_ASSERT(contained_in_pool(pool, IT_HDR_to_PObj(p)));

    /* Here, we loop over the entire arena, finding the various object
       headers and attaching them to the pool's free list. Each object
       is also marked with a card and flag number to determine where the
       corresponding flag is located. This is done backwards, so the first
       object in the pool has the highest card number and therefore
       corresponds to the last flag on the last card. The very last object
       in contrast corresponds to the very first flag on the first card. */
    for (i = 0; i < num_objs; i++) {
        PObj * pobj = IT_HDR_to_PObj(p);
        Gc_it_hdr *next = (Gc_it_hdr *)((char*)p + pool->object_size);

        /* Add the current item to the free list */
        //PARROT_ASSERT(contained_in_pool(pool, pobj));
        gc_it_add_free_object(interp, pool, pobj);
        p->data.agg = 0;
        p = next;
    }

    pool->num_free_objects += num_objs;
}


/*

=item C<void gc_it_set_card_mark>

Marks the card associated with the given item to the value given by C<flag>.
This is just a simple field access, and could probably be turned into a
macro instead of a function call.

=cut

*/

PARROT_INLINE
void
gc_it_set_card_mark(ARGMOD(Gc_it_hdr *hdr), UINTVAL flag)
{
    /* I'm going to try to mirror the GC flags in the PMC flags field, for
       objects which are marked as being aggregates (and are therefore
       isomorphic with Buffer *.
    */
#  ifdef GC_IT_USE_POBJ_FLAGS
    if(hdr->agg) {
        PObj * const p = IT_HDR_to_PObj(hdr);
        switch (flag) {
            /* This is relatively inefficient. I should be able to create
               constant bitmaps for each condition and perform a logical
               AND or OR to set them in a single operation. That's an
               optimization to pursue later. */
            case GC_IT_FLAG_BLACK:
                PObj_live_SET(p);
                PObj_is_fully_live_SET(p);
                PObj_on_free_list_CLEAR(p);
                break;
            case GC_IT_FLAG_WHITE:
                PObj_live_CLEAR(p);
                PObj_is_fully_live_CLEAR(p);
                PObj_on_free_list_CLEAR(p);
                break;
            case GC_IT_FLAG_GREY:
                PObj_live_SET(p);
                PObj_is_fully_live_CLEAR(p);
                PObj_on_free_list_CLEAR(p);
                break;
            case CG_IT_FLAG_FREE:
                PObj_live_CLEAR(p);
                PObj_is_fully_live_CLEAR(p);
                PObj_on_free_list_SET(p);
        }
    }
#  else
    hdr->data.flag = flag;
#  endif

}

/*

=item C<UINTVAL gc_it_get_card_mark>

Returns the current flag value associated with the given object header.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_INLINE
UINTVAL
gc_it_get_card_mark(ARGMOD(Gc_it_hdr *hdr))
{
#  ifdef GC_IT_USE_POBJ_FLAGS
    /* if defined, GC_IT_USE_POBJ_FLAGS says that we should use the ->flags
       field of the PObj structure to hold the white/grey/black state of
       the object, instead of using the ->data.flag field of the header. */
#  else
    return hdr->data.flag;
#  endif
}

/*

=item C<void gc_it_more_objects>

Tries to allocate new objects. If the mark phase is finished, run a quick
sweep.  If the sweep frees up some objects, return one of those. Otherwise, we
allocate a new arena and return an object from that.

=cut

*/

PARROT_EXPORT
void
gc_it_more_objects(PARROT_INTERP, ARGMOD(Small_Object_Pool *pool))
{
    const Gc_it_data * const gc_priv_data = (Gc_it_data *)interp->arena_base->gc_private;

    /* If the last GC run didn't turn up a lot of new objects, it's probably
       not worthwhile to try it again. We'll skip DOD once and just go
       straight to the new object allocation. */
    if (pool->skip) {
        --pool->skip;
    }
    else if (gc_priv_data->state >= GC_IT_END_MARK) {
        /* If we're after the trace phase in our GC, we'll try to complete the
           run and look for new objects. If the GC run doesn't turn up new
           objects, allocate more. */
        while (gc_priv_data->state >= GC_IT_END_MARK)
            Parrot_gc_it_run(interp, 0);

        /* If we don't turn up enough new objects, this pool is pretty densly
           packed and we should skip the dod attempt next round. */
        if (pool->num_free_objects <= pool->replenish_level)
            ++pool->skip;
        if (pool->free_list)
            return;
    }

    gc_it_alloc_objects(interp, pool);
}


/*

=item C<static void gc_it_post_sweep_cleanup>

Cleans up the GC system after completing an entire mark and sweep.

=cut

*/

static void
gc_it_post_sweep_cleanup(PARROT_INTERP)
{
    Gc_it_hdr * ptr;
    Gc_it_data * const gc_priv_data = (Gc_it_data *)interp->arena_base->gc_private;

    while ((ptr = gc_priv_data->marked) != NULL) {
        gc_priv_data->marked = ptr->next;
        ptr->next = NULL;
    }
    PARROT_ASSERT(gc_priv_data->root_queue == NULL);
    PARROT_ASSERT(gc_priv_data->queue == NULL);
    PARROT_ASSERT(gc_priv_data->marked == NULL);

#  if GC_IT_DEBUG
    fprintf(stderr, "Post-sweep cleanup. Sweep ended\n");
#  endif
}

/*

=item C<void gc_it_ptr_set_aggregate>

Sets whether the given object is a PObj or not. "aggregates" are mostly
PMCs which need to get marked themselves and may also contain pointers
to other data structures which also need to be marked.

This function should be called on all PMC objects when they are allocated.

=item C<UINTVAL gc_it_ptr_get_aggregate>

Returns a boolean value for whether the given object is flagged as an
aggregate object or not.

=cut

*/

void
gc_it_ptr_set_aggregate(ARGMOD(void *ptr), unsigned char flag)
{
    Gc_it_hdr * const hdr = PObj_to_IT_HDR(ptr);
    hdr->data.agg = flag;
}

UINTVAL
gc_it_ptr_get_aggregate(ARGIN(void * const ptr))
{
    const Gc_it_hdr * const hdr = PObj_to_IT_HDR(ptr);
    return (UINTVAL)hdr->data.agg;
}

/*

=item C<gc_it_pmc_dead>

Determines whether a given PMC has been prematurely swept.

=cut

*/

# if GC_IT_DEBUG

UINTVAL
gc_it_pmc_dead(ARGIN(PMC * p))
{
    return(p->pmc_ext     == (PMC_EXT *)0xdeadbeef ||
           p->vtable      == (void *)0xdeadbeef ||
           PMC_pmc_val(p) == (PMC *)0xdeadbeef);
}

#  endif

#endif  /* PARROT_GC_IT */

/*

=back

=head1 HISTORY

Initial version by Whiteknight (2008.05.26)

=cut

*/

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
