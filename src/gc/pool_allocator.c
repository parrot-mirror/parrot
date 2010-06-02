/*
Copyright (C) 2010, Parrot Foundation.
$Id$

=head1 NAME

src/gc/pool_allocator.c - Implementation of PoolAllocator

=head1 DESCRIPTION

This code implements PoolAllocator.

=cut

*/

#include "parrot/parrot.h"
#include "pool_allocator.h"

/* HEADERIZER HFILE: src/gc/pool_allocator.h */

/* HEADERIZER BEGIN: static */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

static void allocate_new_pool_arena(ARGMOD(Pool_Allocator *pool))
        __attribute__nonnull__(1)
        FUNC_MODIFIES(*pool);

static size_t arena_size(ARGIN(const Pool_Allocator *self))
        __attribute__nonnull__(1);

#define ASSERT_ARGS_allocate_new_pool_arena __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(pool))
#define ASSERT_ARGS_arena_size __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(self))
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: static */

/*

=over 4

=item C<static void * Parrot_gc_get_attributes_from_pool(PARROT_INTERP,
Pool_Allocator * pool)>

Get a new fixed-size storage space from the given pool. The pool contains
information on the size of the item to allocate already.

=item C<static void Parrot_gc_allocate_new_attributes_arena(Pool_Allocator
*pool)>

Allocate a new arena of fixed-sized data structures for the given pool.

=item C<static void Parrot_gc_initialize_fixed_size_pools(PARROT_INTERP,
Memory_Pools *mem_pools, size_t init_num_pools)>

Initialize the pools (zeroize)

=item C<static Pool_Allocator * Parrot_gc_get_attribute_pool(PARROT_INTERP,
Memory_Pools *mem_pools, size_t attrib_size)>

Find a fixed-sized data structure pool given the size of the object to
allocate. If the pool does not exist, create it.

=item C<static Pool_Allocator * Parrot_gc_create_attrib_pool(size_t
attrib_idx)>

Create a new pool for fixed-sized data items with the given C<attrib_size>.

=cut

*/

PARROT_CANNOT_RETURN_NULL
PARROT_MALLOC
Pool_Allocator *
Parrot_gc_create_pool_allocator(size_t object_size)
{
    ASSERT_ARGS(Parrot_gc_create_pool_allocator)
    const size_t attrib_size = object_size < sizeof (void *) ? sizeof (void*) : object_size;
    const size_t num_objs_raw =
        (GC_FIXED_SIZE_POOL_SIZE - sizeof (Pool_Allocator_Arena)) / attrib_size;
    const size_t num_objs = (num_objs_raw == 0)?(1):(num_objs_raw);
    Pool_Allocator * const newpool = mem_internal_allocate_typed(Pool_Allocator);

    newpool->object_size       = attrib_size;
    newpool->total_objects     = 0;
    newpool->objects_per_alloc = num_objs;
    newpool->num_free_objects  = 0;
    newpool->free_list         = NULL;
    newpool->top_arena         = NULL;

    return newpool;
}

PARROT_EXPORT
void
Parrot_gc_destroy_pool_alloctor(PARROT_INTERP, ARGMOD(Pool_Allocator *pool))
{
    ASSERT_ARGS(Parrot_gc_destroy_pool_alloctor)

    Pool_Allocator_Arena *arena = pool->top_arena;

    while (arena) {
        Pool_Allocator_Arena *next = arena->next;
        mem_internal_free(arena);
        arena = next;
    }

    mem_internal_free(pool);
}


PARROT_CANNOT_RETURN_NULL
PARROT_EXPORT
void *
Parrot_gc_pool_allocate(PARROT_INTERP, ARGMOD(Pool_Allocator * pool))
{
    ASSERT_ARGS(Parrot_gc_pool_allocate)
    Pool_Allocator_Free_List *item;

    if (pool->free_list) {
        item            = pool->free_list;
        pool->free_list = item->next;
    }
    else if (pool->newfree) {
        item          = pool->newfree;
        pool->newfree = (Pool_Allocator_Free_List *)
                        ((char *)(pool->newfree) + pool->object_size);
        if (pool->newfree >= pool->newlast)
            pool->newfree = NULL;
    }
    else {
        allocate_new_pool_arena(pool);
        return Parrot_gc_pool_allocate(interp, pool);
    }

    --pool->num_free_objects;
    return (void *)item;
}

/*

=item C<static void gc_ms_free_attributes_from_pool(Pool_Allocator_Pool *pool,
void *data)>

Frees a fixed-size data item back to the pool for later reallocation.  Private
to this file.

=cut

*/

PARROT_EXPORT
void
Parrot_gc_pool_free(ARGMOD(Pool_Allocator *pool), ARGMOD(void *data))
{
    ASSERT_ARGS(Parrot_gc_pool_free)
    Pool_Allocator_Free_List * const item = (Pool_Allocator_Free_List *)data;

    PARROT_ASSERT(Parrot_gc_pool_is_owned(pool, data));

    item->next      = pool->free_list;
    pool->free_list = item;

    ++pool->num_free_objects;
}

PARROT_EXPORT
int
Parrot_gc_pool_is_owned(ARGMOD(Pool_Allocator *pool), ARGMOD(void *ptr))
{
    ASSERT_ARGS(Parrot_gc_pool_is_owned)
    Pool_Allocator_Arena *arena = pool->top_arena;
    /* We can cache this value. All arenas are same size */
    size_t                a_size = arena_size(pool);
    while (arena) {
        const ptrdiff_t ptr_diff =
            (ptrdiff_t)ptr - (ptrdiff_t)(arena + 1);

        if (0 <= ptr_diff
              && ptr_diff < a_size
              && ptr_diff % pool->object_size == 0)
            return 1;

        arena = arena->next;
    }

    return 0;
}


static void
allocate_new_pool_arena(ARGMOD(Pool_Allocator *pool))
{
    ASSERT_ARGS(allocate_new_pool_arena)
    Pool_Allocator_Free_List *next;

    const size_t num_items  = pool->objects_per_alloc;
    const size_t item_size  = pool->object_size;
    const size_t item_space = item_size * num_items;

    /* Round up to 4kb */
    Pool_Allocator_Arena * const new_arena = (Pool_Allocator_Arena *)mem_internal_allocate(
                                                arena_size(pool));

    new_arena->prev = NULL;
    new_arena->next = pool->top_arena;
    pool->top_arena = new_arena;
    next            = (Pool_Allocator_Free_List *)(new_arena + 1);

    pool->newfree   = next;
    pool->newlast   = (Pool_Allocator_Free_List *)((char *)next + item_space);

    pool->num_free_objects += num_items;
    pool->total_objects    += num_items;
}

/*

=item C<static size_t arena_size(const Pool_Allocator *self)>

Calculate size of Arena.

=cut

*/
static size_t
arena_size(ARGIN(const Pool_Allocator *self))
{
    ASSERT_ARGS(arena_size)

    const size_t num_items  = self->objects_per_alloc;
    const size_t item_size  = self->object_size;
    const size_t item_space = item_size * num_items;
    size_t total_size = sizeof (Pool_Allocator_Arena) + item_space;

    /* Round up to 4kb */
    return total_size < GC_FIXED_SIZE_POOL_SIZE
                      ? GC_FIXED_SIZE_POOL_SIZE
                      : total_size;
}

/*

=back

=cut

*/

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
