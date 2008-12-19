
#include "parrot/parrot.h"
#include "parrot/smallobject.h"

/* HEADERIZER HFILE: include/parrot/smallobject.h */

/* HEADERIZER BEGIN: static */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

static void clear_live_bits(ARGIN(const Small_Object_Pool *pool))
        __attribute__nonnull__(1);


static void gc_ms_add_free_object(SHIM_INTERP,
    ARGMOD(Small_Object_Pool *pool),
    ARGIN(void *to_add))
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*pool);

static void gc_ms_add_free_pmc_ext(SHIM_INTERP,
    ARGMOD(Small_Object_Pool *pool),
    ARGIN(void *to_add))
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*pool);

static void gc_ms_alloc_objects(PARROT_INTERP,
    ARGMOD(Small_Object_Pool *pool))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*pool);

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static void * gc_ms_get_free_object(PARROT_INTERP,
    ARGMOD(Small_Object_Pool *pool))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*pool);

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static void * gc_ms_get_free_pmc_ext(PARROT_INTERP,
    ARGMOD(Small_Object_Pool *pool))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*pool);

static void gc_ms_pool_init(SHIM_INTERP, ARGMOD(Small_Object_Pool *pool))
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*pool);

static void more_traceable_objects(PARROT_INTERP,
    ARGMOD(Small_Object_Pool *pool))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*pool);

static int sweep_cb(PARROT_INTERP,
    ARGMOD(Small_Object_Pool *pool),
    int flag,
    ARGMOD(void *arg))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(4)
        FUNC_MODIFIES(*pool)
        FUNC_MODIFIES(*arg);

static int trace_active_PMCs(PARROT_INTERP, int trace_stack)
        __attribute__nonnull__(1);

/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: static */

static int sweep_cb(PARROT_INTERP,
    ARGMOD(Small_Object_Pool *pool),
    int flag,
    ARGMOD(void *arg))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(4)
        FUNC_MODIFIES(*pool)
        FUNC_MODIFIES(*arg);


static void gc_ms_add_free_object(SHIM_INTERP,
    ARGMOD(Small_Object_Pool *pool),
    ARGIN(void *to_add))
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*pool);

static void gc_ms_add_free_pmc_ext(SHIM_INTERP,
    ARGMOD(Small_Object_Pool *pool),
    ARGIN(void *to_add))
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*pool);

static void gc_ms_alloc_objects(PARROT_INTERP,
    ARGMOD(Small_Object_Pool *pool))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*pool);

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static void * gc_ms_get_free_object(PARROT_INTERP,
    ARGMOD(Small_Object_Pool *pool))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*pool);

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static void * gc_ms_get_free_pmc_ext(PARROT_INTERP,
    ARGMOD(Small_Object_Pool *pool))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*pool);

static void gc_ms_pool_init(SHIM_INTERP, ARGMOD(Small_Object_Pool *pool))
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*pool);

static void more_traceable_objects(PARROT_INTERP,
    ARGMOD(Small_Object_Pool *pool))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*pool);


/*

=item C<void Parrot_dod_ms_run_init>

Prepares the collector for a mark & sweep DOD run. This is the
initializer function for the MS garbage collector.

=cut

*/

void
Parrot_dod_ms_run_init(PARROT_INTERP)
{
    Arenas * const arena_base       = interp->arena_base;

    arena_base->dod_trace_ptr       = NULL;
    arena_base->dod_mark_start      = NULL;
    arena_base->num_early_PMCs_seen = 0;
    arena_base->num_extended_PMCs   = 0;
}

/*

=item C<static int sweep_cb>

Sweeps the given pool for the MS collector. This function also ends
the profiling timer, if profiling is enabled. Returns the total number
of objects freed.

=cut

*/

static int
sweep_cb(PARROT_INTERP, ARGMOD(Small_Object_Pool *pool), int flag,
    ARGMOD(void *arg))
{
    int * const total_free = (int *) arg;

#ifdef GC_IS_MALLOC
    if (flag & POOL_BUFFER)
        used_cow(interp, pool, 0);
#endif

    Parrot_dod_sweep(interp, pool);

#ifdef GC_IS_MALLOC
    if (flag & POOL_BUFFER)
        clear_cow(interp, pool, 0);
#endif

    if (interp->profile && (flag & POOL_PMC))
        Parrot_dod_profile_end(interp, PARROT_PROF_DOD_cp);

    *total_free += pool->num_free_objects;

    return 0;
}

/*

=item C<void Parrot_dod_ms_run>

Runs the stop-the-world mark & sweep (MS) collector.

=cut

*/

void
Parrot_dod_ms_run(PARROT_INTERP, UINTVAL flags)
{
    Arenas * const arena_base = interp->arena_base;

    /* XXX these should go into the interpreter */
    int total_free     = 0;

    if (arena_base->DOD_block_level)
        return;

    if (interp->debugger) {
        /*
         * if the other interpreter did a DOD run, it can set
         * live bits of shared objects, but these aren't reset, because
         * they are in a different arena. When now such a PMC points to
         * other non-shared object, these wouldn't be marked and hence
         * collected.
         */
        Parrot_dod_clear_live_bits(interp);
    }

    /*
     * the sync sweep is always at the end, so that
     * the live bits are cleared
     */
    if (flags & GC_finish_FLAG) {
        clear_live_bits(interp->arena_base->pmc_pool);
        clear_live_bits(interp->arena_base->constant_pmc_pool);

        /* keep the scheduler and its kids alive for Task-like PMCs to destroy
         * themselves; run a sweep to collect them */
        if (interp->scheduler) {
            pobject_lives(interp, (PObj *)interp->scheduler);
            VTABLE_mark(interp, interp->scheduler);
            Parrot_dod_sweep(interp, interp->arena_base->pmc_pool);
        }

        /* now sweep everything that's left */
        Parrot_dod_sweep(interp, interp->arena_base->pmc_pool);
        Parrot_dod_sweep(interp, interp->arena_base->constant_pmc_pool);

        return;
    }

    ++arena_base->DOD_block_level;
    arena_base->lazy_dod = flags & GC_lazy_FLAG;

    /* tell the threading system that we're doing DOD mark */
    pt_DOD_start_mark(interp);
    Parrot_dod_ms_run_init(interp);

    /* compact STRING pools to collect free headers and allocated buffers */
    Parrot_go_collect(interp);

    /* Now go trace the PMCs */
    if (trace_active_PMCs(interp, (int)(flags & GC_trace_stack_FLAG))) {
        int ignored;

        arena_base->dod_trace_ptr = NULL;
        arena_base->dod_mark_ptr  = NULL;

        /* mark is now finished */
        pt_DOD_stop_mark(interp);

        /* Now put unused PMCs and Buffers on the free list */
        ignored = Parrot_forall_header_pools(interp, POOL_BUFFER | POOL_PMC,
            (void*)&total_free, sweep_cb);
        UNUSED(ignored);

        if (interp->profile)
            Parrot_dod_profile_end(interp, PARROT_PROF_DOD_cb);
    }
    else {
        pt_DOD_stop_mark(interp); /* XXX */

        /* successful lazy DOD count */
        ++arena_base->lazy_dod_runs;

        Parrot_dod_clear_live_bits(interp);
        if (interp->profile)
            Parrot_dod_profile_end(interp, PARROT_PROF_DOD_p2);
    }

    /* Note it */
    arena_base->dod_runs++;
    --arena_base->DOD_block_level;

    return;
}

/*

=item C<void Parrot_dod_sweep>

Puts any buffers/PMCs that are now unused onto the pool's free list. If
C<GC_IS_MALLOC>, bufstart gets freed too, if possible. Avoids buffers that
are immune from collection (i.e. constant).

=cut

*/

void
Parrot_dod_sweep(PARROT_INTERP, ARGMOD(Small_Object_Pool *pool))
{
    UINTVAL total_used        = 0;
    const UINTVAL object_size = pool->object_size;

    Small_Object_Arena *cur_arena;
    dod_object_fn_type dod_object = pool->dod_object;

#if GC_VERBOSE
    if (Interp_trace_TEST(interp, 1)) {
        Interp * const tracer = interp->debugger;
        PMC *pio       = Parrot_io_STDERR(interp);

        Parrot_io_flush(interp, pio);

        if (tracer) {
            pio = Parrot_io_STDERR(tracer);
            Parrot_io_flush(tracer, pio);
        }
    }
#endif

    /* Run through all the buffer header pools and mark */
    for (cur_arena = pool->last_Arena; cur_arena; cur_arena = cur_arena->prev) {
        Buffer *b = (Buffer *)cur_arena->start_objects;
        UINTVAL i;

        /* loop only while there are objects in the arena */
        for (i = cur_arena->total_objects; i; i--) {

            if (PObj_on_free_list_TEST(b))
                ; /* if it's on free list, do nothing */
            else if (PObj_live_TEST(b)) {
                total_used++;
                PObj_live_CLEAR(b);
                PObj_get_FLAGS(b) &= ~PObj_custom_GC_FLAG;
            }
            else {
                /* it must be dead */

#if GC_VERBOSE
                if (Interp_trace_TEST(interp, 1)) {
                    fprintf(stderr, "Freeing pobject %p\n", b);
                    if (PObj_is_PMC_TEST(b)) {
                        fprintf(stderr, "\t = PMC type %s\n",
                                (char*) ((PMC*)b)->vtable->whoami->strstart);
                    }
                }
#endif

                if (PObj_is_shared_TEST(b)) {
                    /* only mess with shared objects if we
                     * (and thus everyone) is suspended for
                     * a GC run.
                     * XXX wrong thing to do with "other" GCs
                     */
                    if (!(interp->thread_data &&
                            (interp->thread_data->state &
                            THREAD_STATE_SUSPENDED_GC))) {
                        ++total_used;
                        goto next;
                    }
                }

                dod_object(interp, pool, b);

                pool->add_free_object(interp, pool, b);
            }
next:
            b = (Buffer *)((char *)b + object_size);
        }
    }

    pool->num_free_objects = pool->total_objects - total_used;
}

/*

=item C<static int trace_active_PMCs>

Performs a full trace run and marks all the PMCs as active if they
are. Returns whether the run completed, that is, whether it's safe
to proceed with GC.

=cut

*/

static int
trace_active_PMCs(PARROT_INTERP, int trace_stack)
{
    if (!Parrot_dod_trace_root(interp, trace_stack))
        return 0;

    /* Okay, we've marked the whole root set, and should have a good-sized
     * list of things to look at. Run through it */
    return Parrot_dod_trace_children(interp, (size_t) -1);
}

/*

=item C<int Parrot_dod_trace_children>

Returns whether the tracing process has completed.

=cut

*/

int
Parrot_dod_trace_children(PARROT_INTERP, size_t how_many)
{
    Arenas * const arena_base = interp->arena_base;
    const int      lazy_dod   = arena_base->lazy_dod;
    PMC           *current    = arena_base->dod_mark_start;

    const UINTVAL mask = PObj_data_is_PMC_array_FLAG | PObj_custom_mark_FLAG;

    /*
     * First phase of mark is finished. Now if we are the owner
     * of a shared pool, we must run the mark phase of other
     * interpreters in our pool, so that live shared PMCs in that
     * interpreter are appended to our mark_ptrs chain.
     *
     * If there is a count of shared PMCs and we have already seen
     * all these, we could skip that.
     */
    if (interp->profile)
        Parrot_dod_profile_start(interp);

    pt_DOD_mark_root_finished(interp);

    do {
        const UINTVAL bits = PObj_get_FLAGS(current) & mask;
        PMC *next;

        if (lazy_dod && arena_base->num_early_PMCs_seen >=
                arena_base->num_early_DOD_PMCs) {
            return 0;
        }

        arena_base->dod_trace_ptr = current;

        /* short-term hack to color objects black */
        PObj_get_FLAGS(current) |= PObj_custom_GC_FLAG;

        /* clearing the flag is much more expensive then testing */
        if (!PObj_needs_early_DOD_TEST(current))
            PObj_high_priority_DOD_CLEAR(current);

        /* mark properties */
        if (PMC_metadata(current))
            pobject_lives(interp, (PObj *)PMC_metadata(current));

        /* Start by checking if there's anything at all. This assumes that the
         * largest percentage of PMCs won't have anything in their data
         * pointer that we need to trace. */
        if (bits) {
            if (bits == PObj_data_is_PMC_array_FLAG)
                Parrot_dod_trace_pmc_data(interp, current);
            else {
                /* All that's left is the custom */
                PARROT_ASSERT(!PObj_on_free_list_TEST(current));
                VTABLE_mark(interp, current);
            }
        }

        next = PMC_next_for_GC(current);

        if (!PMC_IS_NULL(next) && next == current)
            break;

        current = next;
    } while (--how_many > 0);

    arena_base->dod_mark_start = current;
    arena_base->dod_trace_ptr  = NULL;

    if (interp->profile)
        Parrot_dod_profile_end(interp, PARROT_PROF_DOD_p2);

    return 1;
}

/*

=item C<static void more_traceable_objects>

We're out of traceable objects. First we try a DOD run to free some up. If
that doesn't work, allocate a new arena.

=cut

*/

static void
more_traceable_objects(PARROT_INTERP, ARGMOD(Small_Object_Pool *pool))
{
    if (pool->skip)
        pool->skip = 0;
    else {
        Small_Object_Arena * const arena = pool->last_Arena;
        if (arena) {
            if (arena->used == arena->total_objects)
                Parrot_do_dod_run(interp, GC_trace_stack_FLAG);

            if (pool->num_free_objects <= pool->replenish_level)
                pool->skip = 1;
        }
    }

    /* requires that num_free_objects be updated in Parrot_do_dod_run. If dod
     * is disabled, then we must check the free list directly. */
    if (!pool->free_list)
        (*pool->alloc_objects) (interp, pool);
}

/*

=item C<static void gc_ms_add_free_pmc_ext>

Add a freed PMC_EXT structure to the free list in the PMC_EXT pool. Objects
on the free list can be reused later.

=cut

*/

static void
gc_ms_add_free_pmc_ext(SHIM_INTERP, ARGMOD(Small_Object_Pool *pool), ARGIN(void *to_add))
{
    PMC_EXT *object        = (PMC_EXT *)to_add;
    object->_metadata      = NULL;

    /* yes, this cast is a hack for now, but a pointer is a pointer */
    object->_next_for_GC   = (PMC *)pool->free_list;
    pool->free_list        = object;
}

/*

=item C<static void gc_ms_add_free_object>

Add an unused object back to the pool's free list for later reuse. Set
the PObj flags to indicate that the item is free.

=cut

*/

static void
gc_ms_add_free_object(SHIM_INTERP, ARGMOD(Small_Object_Pool *pool), ARGIN(void *to_add))
{
    PObj *object           = (PObj *)to_add;

    PObj_flags_SETTO(object, PObj_on_free_list_FLAG);

    /* during GC buflen is used to check for objects on the free_list */
    PObj_buflen(object)    = 0;
    PMC_struct_val(object) = pool->free_list;
    pool->free_list        = object;
}

/*

=item C<static void * gc_ms_get_free_object>

Free object allocator for the MS garbage collector system. If there are no
free objects, call C<gc_ms_add_free_object> to either free them up with a
DOD run, or allocate new objects. If there are objects available on the
free list, pop it off and return it.

=cut

*/

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static void *
gc_ms_get_free_object(PARROT_INTERP, ARGMOD(Small_Object_Pool *pool))
{
    PObj *ptr;
    PObj *free_list = (PObj *)pool->free_list;

    /* if we don't have any objects */
    if (!free_list) {
        (*pool->more_objects)(interp, pool);
        free_list = (PObj *)pool->free_list;
    }

    ptr             = free_list;
    pool->free_list = PMC_struct_val(ptr);

    PObj_flags_SETTO(ptr, 0);

    --pool->num_free_objects;

    return ptr;
}

/*

=item C<static void * gc_ms_get_free_pmc_ext>

Get a new PMC_EXT structure from the free pool and return it.

=cut

*/

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static void *
gc_ms_get_free_pmc_ext(PARROT_INTERP, ARGMOD(Small_Object_Pool *pool))
{
    PMC_EXT *ptr;
    PMC_EXT *free_list = (PMC_EXT *)pool->free_list;

    /* if we don't have any objects */
    if (!free_list) {
        (*pool->more_objects)(interp, pool);
        free_list = (PMC_EXT *)pool->free_list;
    }

    ptr               = free_list;
    pool->free_list   = ptr->_next_for_GC;
    ptr->_next_for_GC = NULL;

    --pool->num_free_objects;

    return ptr;
}

/*

=item C<void Parrot_add_to_free_list>

Adds the objects in the newly allocated C<arena> to the free list.

=cut

*/

void
Parrot_add_to_free_list(PARROT_INTERP,
        ARGMOD(Small_Object_Pool  *pool),
        ARGMOD(Small_Object_Arena *arena))
{
    UINTVAL  i;
    void    *object;
    const UINTVAL num_objects = pool->objects_per_alloc;

    pool->total_objects += num_objects;
    arena->used          = num_objects;

    /* Move all the new objects into the free list */
    object = (void *)arena->start_objects;

    for (i = 0; i < num_objects; i++) {
        pool->add_free_object(interp, pool, object);
        object = (void *)((char *)object + pool->object_size);
    }

    pool->num_free_objects += num_objects;
}

/*

=item C<static void gc_ms_alloc_objects>

New arena allocator function for the MS garbage collector system. Allocates
and initializes a new memory arena in the given pool. Adds all the new
objects to the pool's free list for later allocation.

=cut

*/

static void
gc_ms_alloc_objects(PARROT_INTERP, ARGMOD(Small_Object_Pool *pool))
{
    /* Setup memory for the new objects */
    Small_Object_Arena * const new_arena =
        mem_internal_allocate_typed(Small_Object_Arena);

    const size_t size = pool->object_size * pool->objects_per_alloc;
    size_t alloc_size;

    /* could be mem_internal_allocate too, but calloc is fast */
    new_arena->start_objects = mem_internal_allocate_zeroed(size);

    Parrot_append_arena_in_pool(interp, pool, new_arena, size);

    Parrot_add_to_free_list(interp, pool, new_arena);

    /* Allocate more next time */
    if (GC_DEBUG(interp)) {
        pool->objects_per_alloc *= GC_DEBUG_UNITS_PER_ALLOC_GROWTH_FACTOR;
        pool->replenish_level =
                (size_t)(pool->total_objects *
                GC_DEBUG_REPLENISH_LEVEL_FACTOR);
    }
    else {
        pool->objects_per_alloc = (size_t)(pool->objects_per_alloc *
            UNITS_PER_ALLOC_GROWTH_FACTOR);
        pool->replenish_level   =
                (size_t)(pool->total_objects * REPLENISH_LEVEL_FACTOR);
    }

    /* check alloc size against maximum */
    alloc_size = pool->object_size * pool->objects_per_alloc;

    if (alloc_size > POOL_MAX_BYTES)
        pool->objects_per_alloc = POOL_MAX_BYTES / pool->object_size;
}

/*

=item C<void gc_pmc_ext_pool_init>

Initialize the PMC_EXT pool functions. This is done separately from other
pools.

=cut

*/

void
gc_pmc_ext_pool_init(ARGMOD(Small_Object_Pool *pool))
{
    pool->add_free_object = gc_ms_add_free_pmc_ext;
    pool->get_free_object = gc_ms_get_free_pmc_ext;
    pool->alloc_objects   = gc_ms_alloc_objects;
    pool->more_objects    = gc_ms_alloc_objects;
}

/*

=item C<static void gc_ms_pool_init>

Initialize a memory pool for the MS garbage collector system. Sets the
function pointers necessary to perform basic operations on a pool, such
as object allocation.

=cut

*/

static void
gc_ms_pool_init(SHIM_INTERP, ARGMOD(Small_Object_Pool *pool))
{
    pool->add_free_object = gc_ms_add_free_object;
    pool->get_free_object = gc_ms_get_free_object;
    pool->alloc_objects   = gc_ms_alloc_objects;
    pool->more_objects    = more_traceable_objects;
}

/*

=item C<void Parrot_gc_ms_init>

Initialize the state structures of the gc system. Called immediately before
creation of memory pools. This function must set the function pointers
for C<add_free_object_fn>, C<get_free_object_fn>, C<alloc_object_fn>, and
C<more_object_fn>.

=cut

*/

void
Parrot_gc_ms_init(PARROT_INTERP)
{
    Arenas * const arena_base     = interp->arena_base;

    arena_base->do_gc_mark         = Parrot_dod_ms_run;
    arena_base->finalize_gc_system = NULL;
    arena_base->init_pool          = gc_ms_pool_init;
}

/*

=item C<static void clear_live_bits>

Runs through all PMC arenas and clear live bits. This is used to reset
the GC system after a full system sweep.

=cut

*/

static void
clear_live_bits(ARGIN(const Small_Object_Pool *pool))
{
    Small_Object_Arena *arena;
    const UINTVAL object_size = pool->object_size;

    for (arena = pool->last_Arena; arena; arena = arena->prev) {
        Buffer *b = (Buffer *)arena->start_objects;
        UINTVAL i;

        for (i = 0; i < arena->used; i++) {
            PObj_live_CLEAR(b);
            b = (Buffer *)((char *)b + object_size);
        }
    }

}

/*

=item C<void Parrot_dod_clear_live_bits>

Resets the PMC pool, so all objects are marked as "White". This
is done after a GC run to reset the system and prepare for the
next mark phase.

=cut

*/

void
Parrot_dod_clear_live_bits(PARROT_INTERP)
{
    Small_Object_Pool * const pool = interp->arena_base->pmc_pool;
    clear_live_bits(pool);
}
