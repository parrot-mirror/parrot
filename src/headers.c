/*
Copyright (C) 2001-2008, The Perl Foundation.
$Id$

=head1 NAME

src/headers.c - Header management functions

=head1 DESCRIPTION

Handles getting of various headers, and pool creation.

=cut

*/

#include "parrot/parrot.h"
#include "parrot/headers.h"

/* HEADERIZER HFILE: include/parrot/headers.h */

/* HEADERIZER BEGIN: static */

static void fix_pmc_syncs(
    ARGMOD(Interp *dest_interp),
    ARGIN(Small_Object_Pool *pool))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*dest_interp);

static void free_pool(ARGMOD(Small_Object_Pool *pool))
        __attribute__nonnull__(1)
        FUNC_MODIFIES(*pool);

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static void * get_free_buffer(PARROT_INTERP, ARGIN(Small_Object_Pool *pool))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static PMC_EXT * new_pmc_ext(PARROT_INTERP)
        __attribute__nonnull__(1);

#ifdef GC_IS_MALLOC
static int sweep_cb_buf(PARROT_INTERP,
    ARGMOD(Small_Object_Pool *pool),
    SHIM(int flag),
    ARGIN(void *arg))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*pool);
#else
static int sweep_cb_buf(PARROT_INTERP,
    ARGMOD(Small_Object_Pool *pool),
    SHIM(int flag),
    SHIM(void *arg))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*pool);
#endif

static int sweep_cb_pmc(PARROT_INTERP,
    ARGMOD(Small_Object_Pool *pool),
    SHIM(int flag),
    SHIM(void *arg))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*pool);

/* HEADERIZER END: static */


#ifndef GC_IS_MALLOC
#  define PMC_HEADERS_PER_ALLOC    10240 / sizeof (PMC)
#  define BUFFER_HEADERS_PER_ALLOC  5120 / sizeof (Buffer)
#  define STRING_HEADERS_PER_ALLOC  5120 / sizeof (STRING)
#else /* GC_IS_MALLOC */
#  define PMC_HEADERS_PER_ALLOC    10240 / sizeof (PMC)
#  define BUFFER_HEADERS_PER_ALLOC 10240 / sizeof (Buffer)
#  define STRING_HEADERS_PER_ALLOC 10240 / sizeof (STRING)
#endif /* GC_IS_MALLOC */

#  define CONSTANT_PMC_HEADERS_PER_ALLOC 64

/*

=head2 Buffer Header Functions for small-object lookup table

=over 4

=item C<static void * get_free_buffer>

Gets a free C<Buffer> from C<pool> and returns it. Memory is cleared.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static void *
get_free_buffer(PARROT_INTERP, ARGIN(Small_Object_Pool *pool))
{
    PObj * const buffer = (PObj *)pool->get_free_object(interp, pool);

    /* don't mess around with flags */
    PObj_bufstart(buffer) = NULL;
    PObj_buflen(buffer) = 0;

    if (pool->object_size - GC_HEADER_SIZE > sizeof (PObj))
        memset(buffer + 1, 0,
                pool->object_size - sizeof (PObj) - GC_HEADER_SIZE);
    return buffer;
}

/*

=back

=head2 Header Pool Creation Functions

=over 4

=item C<Small_Object_Pool * new_pmc_pool>

Creates an new pool for PMCs and returns it.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
Small_Object_Pool *
new_pmc_pool(PARROT_INTERP)
{
    const int num_headers = PMC_HEADERS_PER_ALLOC;
    Small_Object_Pool * const pmc_pool =
        new_small_object_pool(sizeof (PMC), num_headers);

    pmc_pool->mem_pool   = NULL;
    pmc_pool->dod_object = Parrot_dod_free_pmc;

    (interp->arena_base->init_pool)(interp, pmc_pool);
    return pmc_pool;
}

/*

=item C<Small_Object_Pool * new_bufferlike_pool>

Creates a new pool for buffer-like structures. Usually you would need
C<make_bufferlike_pool()>.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
Small_Object_Pool *
new_bufferlike_pool(PARROT_INTERP, size_t actual_buffer_size)
{
    const int num_headers          = BUFFER_HEADERS_PER_ALLOC;
    const size_t buffer_size       =
            (actual_buffer_size + sizeof (void *) - 1) & ~(sizeof (void *) - 1);
    Small_Object_Pool * const pool =
            new_small_object_pool(buffer_size, num_headers);

    pool->dod_object = Parrot_dod_free_sysmem;
    pool->mem_pool   = interp->arena_base->memory_pool;
    (interp->arena_base->init_pool)(interp, pool);
    return pool;
}

/*

=item C<Small_Object_Pool * new_buffer_pool>

Non-constant strings and plain Buffers are in the sized header pools.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
Small_Object_Pool *
new_buffer_pool(PARROT_INTERP)
{
    Small_Object_Pool * const pool = make_bufferlike_pool(interp, sizeof (Buffer));

#ifdef GC_IS_MALLOC
    pool->dod_object = Parrot_dod_free_buffer_malloc;
#else
    pool->dod_object = Parrot_dod_free_buffer;
#endif

    return pool;
}

/*

=item C<Small_Object_Pool * new_string_pool>

Creates a new pool for C<STRINGS> and returns it.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
Small_Object_Pool *
new_string_pool(PARROT_INTERP, INTVAL constant)
{
    Small_Object_Pool *pool;
    if (constant) {
        pool           = new_bufferlike_pool(interp, sizeof (STRING));
        pool->mem_pool = interp->arena_base->constant_string_pool;
    }
    else
        pool = make_bufferlike_pool(interp, sizeof (STRING));

    pool->objects_per_alloc = STRING_HEADERS_PER_ALLOC;

    return pool;
}

/*

=item C<Small_Object_Pool * make_bufferlike_pool>

Make and return a bufferlike header pool.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
Small_Object_Pool *
make_bufferlike_pool(PARROT_INTERP, size_t buffer_size)
{
    const UINTVAL num_old = interp->arena_base->num_sized;
    Small_Object_Pool **sized_pools =
            interp->arena_base->sized_header_pools;

    const UINTVAL idx = (buffer_size - sizeof (Buffer)) / sizeof (void *);

    /* Expand the array of sized resource pools, if necessary */
    if (num_old <= idx) {
        const UINTVAL num_new = idx + 1;
        sized_pools = (Small_Object_Pool **)mem_internal_realloc(sized_pools,
                                           num_new * sizeof (void *));
        memset(sized_pools + num_old, 0, sizeof (void *) * (num_new - num_old));

        interp->arena_base->sized_header_pools = sized_pools;
        interp->arena_base->num_sized = num_new;
    }

    if (sized_pools[idx] == NULL) {
        sized_pools[idx] = new_bufferlike_pool(interp, buffer_size);
    }

    return sized_pools[idx];
}

/*

=item C<Small_Object_Pool * get_bufferlike_pool>

Return a bufferlike header pool, it must exist.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
Small_Object_Pool *
get_bufferlike_pool(PARROT_INTERP, size_t buffer_size)
{
    Small_Object_Pool ** const sized_pools =
            interp->arena_base->sized_header_pools;

    return sized_pools[ (buffer_size - sizeof (Buffer)) / sizeof (void *) ];
}

/*

=item C<PMC * new_pmc_header>

Get a header.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PMC *
new_pmc_header(PARROT_INTERP, UINTVAL flags)
{
    Small_Object_Pool * const pool =
        flags & PObj_constant_FLAG
            ? interp->arena_base->constant_pmc_pool
            : interp->arena_base->pmc_pool;
    PMC * const pmc = (PMC *)pool->get_free_object(interp, pool);

    if (!pmc)
        real_exception(interp, NULL, ALLOCATION_ERROR,
            "Parrot VM: PMC allocation failed!\n");

    /* clear flags, set is_PMC_FLAG */
    if (flags & PObj_is_PMC_EXT_FLAG) {
        flags |= PObj_is_special_PMC_FLAG;
        pmc->pmc_ext = new_pmc_ext(interp);

        if (flags & PObj_is_PMC_shared_FLAG)
            add_pmc_sync(interp, pmc);
    }
    else
        pmc->pmc_ext = NULL;
    PObj_get_FLAGS(pmc) = PObj_is_PMC_FLAG|flags;
    pmc->vtable = NULL;
#if ! PMC_DATA_IN_EXT
    PMC_data(pmc) = NULL;
#endif
    return pmc;
}

/*

=item C<static PMC_EXT * new_pmc_ext>

Creates a new C<PMC_EXT> and returns it.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static PMC_EXT *
new_pmc_ext(PARROT_INTERP)
{
    Small_Object_Pool * const pool = interp->arena_base->pmc_ext_pool;
    return pool->get_free_object(interp, pool);
}

/*

=item C<void add_pmc_ext>

Adds a new C<PMC_EXT> to C<pmc>.

=cut

*/

void
add_pmc_ext(PARROT_INTERP, ARGMOD(PMC *pmc))
{
    pmc->pmc_ext = new_pmc_ext(interp);
    PObj_is_PMC_EXT_SET(pmc);
#ifdef PARROT_GC_IMS
    /*
     * preserve DDD color: a simple PMC  live = black
     *                     an aggregate  live = grey
     * set'em black
     */
    if (PObj_live_TEST(pmc))
        PObj_get_FLAGS(pmc) |= PObj_custom_GC_FLAG;
#endif
    PMC_next_for_GC(pmc) = PMCNULL;
}

/*

=item C<void add_pmc_sync>

Adds a PMC_sync field to C<pmc>.

=cut

*/

void
add_pmc_sync(PARROT_INTERP, ARGMOD(PMC *pmc))
{
    if (!PObj_is_PMC_EXT_TEST(pmc)) {
        add_pmc_ext(interp, pmc);
    }
    PMC_sync(pmc) = (Sync *)mem_internal_allocate(sizeof (*PMC_sync(pmc)));
    PMC_sync(pmc)->owner = interp;
    MUTEX_INIT(PMC_sync(pmc)->pmc_lock);
}

/*

=item C<STRING * new_string_header>

Returns a new C<STRING> header.

=cut

*/

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
STRING *
new_string_header(PARROT_INTERP, UINTVAL flags)
{
    STRING * const string = (STRING *)get_free_buffer(interp,
        (flags & PObj_constant_FLAG)
            ? interp->arena_base->constant_string_header_pool
            : interp->arena_base->string_header_pool);

    PObj_get_FLAGS(string) |=
        flags | PObj_is_string_FLAG | PObj_is_COWable_FLAG | PObj_live_FLAG;

    string->strstart        = NULL;

    return string;
}

/*

=item C<Buffer * new_buffer_header>

Creates and returns a new C<Buffer>.

=cut

*/

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
Buffer *
new_buffer_header(PARROT_INTERP)
{
    return (Buffer *)get_free_buffer(interp,
            interp->arena_base->buffer_header_pool);
}


/*

=item C<void * new_bufferlike_header>

Creates and returns a new buffer-like header.

=cut

*/

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
void *
new_bufferlike_header(PARROT_INTERP, size_t size)
{
    Small_Object_Pool * const pool = get_bufferlike_pool(interp, size);

    return get_free_buffer(interp, pool);
}

/*

=item C<size_t get_max_buffer_address>

Calculates the maximum buffer address and returns it.

=cut

*/

PARROT_WARN_UNUSED_RESULT
size_t
get_max_buffer_address(PARROT_INTERP)
{
    UINTVAL i;
    size_t max = 0;
    Arenas * const arena_base = interp->arena_base;

    for (i = 0; i < arena_base->num_sized; i++) {
        if (arena_base->sized_header_pools[i]) {
            if (arena_base-> sized_header_pools[i]->end_arena_memory > max)
                max = arena_base->sized_header_pools[i]->end_arena_memory;
        }
    }

    return max;
}

/*

=item C<size_t get_min_buffer_address>

Calculates the minimum buffer address and returns it.

=cut

*/

PARROT_WARN_UNUSED_RESULT
size_t
get_min_buffer_address(PARROT_INTERP)
{
    UINTVAL i;
    Arenas * const arena_base = interp->arena_base;
    size_t min = (size_t) -1;

    for (i = 0; i < arena_base->num_sized; i++) {
        if (arena_base->sized_header_pools[i] &&
            arena_base->sized_header_pools[i]->start_arena_memory) {
            if (arena_base->sized_header_pools[i]->start_arena_memory < min)
                min = arena_base->sized_header_pools[i]->start_arena_memory;
        }
    }
    return min;
}

/*

=item C<size_t get_max_pmc_address>

Calculates the maximum PMC address and returns it.

=cut

*/

PARROT_WARN_UNUSED_RESULT
size_t
get_max_pmc_address(PARROT_INTERP)
{
    return interp->arena_base->pmc_pool->end_arena_memory;
}

/*

=item C<size_t get_min_pmc_address>

Calculates the maximum PMC address and returns it.

=cut

*/

PARROT_WARN_UNUSED_RESULT
size_t
get_min_pmc_address(PARROT_INTERP)
{
    return interp->arena_base->pmc_pool->start_arena_memory;
}

/*

=item C<int is_buffer_ptr>

Checks that C<ptr> is actually a C<Buffer>.

=cut

*/

PARROT_WARN_UNUSED_RESULT
int
is_buffer_ptr(PARROT_INTERP, ARGIN(const void *ptr))
{
    UINTVAL i;
    Arenas * const arena_base = interp->arena_base;

    for (i = 0; i < arena_base->num_sized; i++) {
        if (arena_base->sized_header_pools[i] &&
                contained_in_pool(arena_base->sized_header_pools[i], ptr))
            return 1;
    }

    return 0;
}

/*

=item C<int is_pmc_ptr>

Checks that C<ptr> is actually a PMC.

=cut

*/

PARROT_WARN_UNUSED_RESULT
int
is_pmc_ptr(PARROT_INTERP, ARGIN(const void *ptr))
{
    return contained_in_pool(interp->arena_base->pmc_pool, ptr);
}


/*

=item C<void Parrot_initialize_header_pools>

Initialize the pools for the tracked resources.

=cut

*/

void
Parrot_initialize_header_pools(PARROT_INTERP)
{
    Arenas * const arena_base = interp->arena_base;

    /* Init the constant string header pool */
    arena_base->constant_string_header_pool       = new_string_pool(interp, 1);
    arena_base->constant_string_header_pool->name = "constant_string_header";

    /* Init the buffer header pool
     *
     * note: the buffer_header_pool and the string_header_pool are actually
     * living in the sized_header_pools, this pool pointers are only
     * here for faster access in new_*_header
     */
    arena_base->buffer_header_pool       = new_buffer_pool(interp);
    arena_base->buffer_header_pool->name = "buffer_header";

    /* Init the string header pool */
    arena_base->string_header_pool       = new_string_pool(interp, 0);
    arena_base->string_header_pool->name = "string_header";

    /* Init the PMC header pool */
    arena_base->pmc_pool       = new_pmc_pool(interp);
    arena_base->pmc_pool->name = "pmc";

    /* pmc extension buffer */
    arena_base->pmc_ext_pool =
        new_small_object_pool(sizeof (PMC_EXT), 1024);
    /*
     * pmc_ext isn't a managed item. If a PMC has a pmc_ext structure
     * it is returned to the pool instantly - the structure is never
     * marked.
     * Use GS MS pool functions
     */
    gc_pmc_ext_pool_init(arena_base->pmc_ext_pool);
    arena_base->pmc_ext_pool->name = "pmc_ext";

    /* constant PMCs */
    arena_base->constant_pmc_pool                    = new_pmc_pool(interp);
    arena_base->constant_pmc_pool->name              = "constant_pmc";
    arena_base->constant_pmc_pool->objects_per_alloc =
       CONSTANT_PMC_HEADERS_PER_ALLOC;
}

/*

=item C<int Parrot_forall_header_pools>

Iterate through all header pools by calling the passed function. Returns
zero if the iteration didn't stop or the returned value.

=over 4

=item flag is one of

  POOL_PMC
  POOL_BUFFER
  POOL_CONST
  POOL_ALL

Only matching pools will be used.

=item arg

This argument is passed on to the iteration function.

=item pool_iter_fn

It is called with C<Interp*, Small_Object_Pool *, int flag, void *arg)>
If the function returns a non-zero value iteration will stop.

=back

=cut

*/

PARROT_IGNORABLE_RESULT
int
Parrot_forall_header_pools(PARROT_INTERP, int flag, ARGIN_NULLOK(void *arg),
        NOTNULL(pool_iter_fn func))
{
    Arenas * const arena_base = interp->arena_base;

    if (flag & POOL_PMC) {
        Small_Object_Pool *pool = flag & POOL_CONST
            ? arena_base->constant_pmc_pool
            : arena_base->pmc_pool;

        const int ret_val = (func)(interp, pool,
            flag & (POOL_PMC | POOL_CONST) , arg);

        if (ret_val)
            return ret_val;
    }


    if (flag & POOL_BUFFER) {
        INTVAL i;

        if (flag & POOL_CONST) {
            const int ret_val = (func)(interp,
                arena_base->constant_string_header_pool,
                POOL_BUFFER | POOL_CONST, arg);

            if (ret_val)
                return ret_val;
        }

        for (i = interp->arena_base->num_sized - 1; i >= 0; --i) {
            Small_Object_Pool * const pool = arena_base->sized_header_pools[i];

            if (pool) {
                const int ret_val = (func)(interp, pool, POOL_BUFFER, arg);
                if (ret_val)
                    return ret_val;
            }
        }
    }

    return 0;
}

/*

=item C<static void free_pool>

Loops backwards through the provided pool, freeing all of its arenas.

=cut

*/

static void
free_pool(ARGMOD(Small_Object_Pool *pool))
{
    Small_Object_Arena *cur_arena;

    for (cur_arena = pool->last_Arena; cur_arena;) {
        Small_Object_Arena * const next = cur_arena->prev;
        mem_internal_free(cur_arena->start_objects);
        mem_internal_free(cur_arena);
        cur_arena = next;
    }
    mem_internal_free(pool);
}

/*

=item C<static int sweep_cb_buf>

Sweeps and frees the provided pool.  Returns 0.

=cut

*/

static int
sweep_cb_buf(PARROT_INTERP, ARGMOD(Small_Object_Pool *pool), SHIM(int flag),
#ifdef GC_IS_MALLOC
        ARGIN(void *arg))
#else
        SHIM(void *arg))
#endif
{
#ifdef GC_IS_MALLOC
    const int pass = (int)(INTVAL)arg;

    if (pass == 0)
        clear_cow(interp, pool, 1);
    else if (pass == 1)
        used_cow(interp, pool, 1);
    else
#endif
    {
        Parrot_dod_sweep(interp, pool);
        free_pool(pool);
    }
    return 0;

}

/*

=item C<static int sweep_cb_pmc>

Sweeps and frees a memory pool.  Returns 0.

=cut

*/

static int
sweep_cb_pmc(PARROT_INTERP, ARGMOD(Small_Object_Pool *pool),
        SHIM(int flag), SHIM(void *arg))
{
    Parrot_dod_sweep(interp, pool);
    free_pool(pool);
    return 0;
}

/*

=item C<void Parrot_destroy_header_pools>

Destroys the header pools.

=cut

*/

void
Parrot_destroy_header_pools(PARROT_INTERP)
{
    INTVAL pass;

    /* const/non const COW strings life in different pools
     * so in first pass
     * COW refcount is done, in 2. refcounting
     * in 3rd freeing
     */
#ifdef GC_IS_MALLOC
    const INTVAL start = 0;
#else
    const INTVAL start = 2;
#endif

    Parrot_forall_header_pools(interp, POOL_PMC, NULL, sweep_cb_pmc);
    Parrot_forall_header_pools(interp, POOL_PMC | POOL_CONST, NULL,
            sweep_cb_pmc);

    for (pass = start; pass <= 2; pass++) {
        Parrot_forall_header_pools(interp, POOL_BUFFER | POOL_CONST,
                (void *)pass, sweep_cb_buf);
    }

    free_pool(interp->arena_base->pmc_ext_pool);
    interp->arena_base->pmc_ext_pool = NULL;

    mem_internal_free(interp->arena_base->sized_header_pools);
    interp->arena_base->sized_header_pools = NULL;
}

/*

=item C<static void fix_pmc_syncs>

Walks through the given arena, looking for all live and shared PMCs,
transferring their sync values to the destionation interpreter.

=cut

*/

static void
fix_pmc_syncs(ARGMOD(Interp *dest_interp), ARGIN(Small_Object_Pool *pool))
{
    /* XXX largely copied from dod_sweep */
    Small_Object_Arena *cur_arena;
    const UINTVAL object_size = pool->object_size;

    for (cur_arena = pool->last_Arena; cur_arena; cur_arena = cur_arena->prev) {
        Buffer *b = (Buffer *)cur_arena->start_objects;
        size_t i;

        for (i = 0; i < cur_arena->used; i++) {
            if (PObj_on_free_list_TEST(b))
                ; /* if it's on free list, do nothing */
            else {
                if (PObj_is_PMC_TEST(b)) {
                    PMC * const p = (PMC *)b;
                    if (PObj_is_PMC_shared_TEST(p)) {
                        PMC_sync(p)->owner = dest_interp;
                    }
                    else {
                        /* fprintf(stderr, "BAD PMC: address=%p,
                                   base_type=%d\n",
                                   p, p->vtable->base_type); */
                        PARROT_ASSERT(0);
                    }
                }
            }

            b = (Buffer *)((char *)b + object_size);
        }
    }
}

/*

=item C<void Parrot_merge_header_pools>

Merge the header pools of C<source_interp> into those of C<dest_interp>.
(Used to deal with shared objects left after interpreter destruction.)

=cut

*/

void
Parrot_merge_header_pools(ARGMOD(Interp *dest_interp), ARGIN(Interp *source_interp))
{
    UINTVAL i;

    Arenas * const dest_arena = dest_interp->arena_base;
    Arenas * const source_arena = source_interp->arena_base;

    /* heavily borrowed from forall_header_pools */

    fix_pmc_syncs(dest_interp, source_arena->constant_pmc_pool);
    Parrot_small_object_pool_merge(dest_interp, dest_arena->constant_pmc_pool,
            source_arena->constant_pmc_pool);
    fix_pmc_syncs(dest_interp, source_arena->pmc_pool);
    Parrot_small_object_pool_merge(dest_interp, dest_arena->pmc_pool,
            source_arena->pmc_pool);
    Parrot_small_object_pool_merge(dest_interp,
            dest_arena->constant_string_header_pool,
            source_arena->constant_string_header_pool);
    Parrot_small_object_pool_merge(dest_interp,
            dest_arena->pmc_ext_pool,
            source_arena->pmc_ext_pool);

    for (i = 0; i < source_arena->num_sized; ++i) {
        if (!source_arena->sized_header_pools[i]) {
            continue;
        }

        if (i >= dest_arena->num_sized ||
            !dest_arena->sized_header_pools[i]) {
            Small_Object_Pool *ignored = make_bufferlike_pool(dest_interp,
                    i * sizeof (void *) + sizeof (Buffer));
            UNUSED(ignored);
            PARROT_ASSERT(dest_arena->sized_header_pools[i]);
        }

        Parrot_small_object_pool_merge(dest_interp,
            dest_arena->sized_header_pools[i],
            source_arena->sized_header_pools[i]);
    }
}

#if 0

/*

=item C<void Parrot_initialize_header_pool_names>

If we want these names, they must be added in DOD.

=cut

*/

void
Parrot_initialize_header_pool_names(PARROT_INTERP)
{
    interp->arena_base->string_header_pool->name
            = string_make(interp, "String Pool", strlen("String Pool"),
            0, PObj_constant_FLAG, 0);
    interp->arena_base->pmc_pool->name
            = string_make(interp, "PMC Pool", strlen("PMC Pool"),
            0, PObj_constant_FLAG, 0);
    /* Set up names for each header pool, * now that we have a constant string
     *
     * * pool available to us */
    interp->arena_base->constant_string_header_pool->name
            =
            string_make(interp, "Constant String Pool",
            strlen("Constant String Pool"), 0, PObj_constant_FLAG, 0);
    interp->arena_base->buffer_header_pool->name =
            string_make(interp, "Generic Header Pool",
            strlen("Generic Header Pool"), 0, PObj_constant_FLAG, 0);
}

#endif

/*

=back

=head1 SEE ALSO

F<include/parrot/headers.h>.

=head1 HISTORY

Initial version by Mike Lambert on 2002.05.27.

=cut

*/


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
