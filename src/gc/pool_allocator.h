/*
Copyright (C) 2010, Parrot Foundation.
$Id$

=head1 NAME

src/gc/pool_allocator.h - PoolAllocator for Parrot.

=head1 DESCRIPTION



*/

#ifndef PARROT_GC_POOL_ALLOCATOR_H_GUARD
#define PARROT_GC_POOL_ALLOCATOR_H_GUARD

#include "parrot/settings.h"

/* these values are used for the attribute allocator */
#define GC_ATTRIB_POOLS_HEADROOM 8
#define GC_FIXED_SIZE_POOL_SIZE 4096

/* Use the lazy allocator. Since it amortizes arena allocation costs, turn
   this on at the same time that you increase the size of allocated arenas.
   increase *_HEADERS_PER_ALLOC and GC_FIXED_SIZE_POOL_SIZE to be large
   enough to satisfy most startup costs. */

typedef struct Pool_Allocator_Free_List {
    struct Pool_Allocator_Free_List * next;
} Pool_Allocator_Free_List;

typedef struct Pool_Allocator_Arena {
    struct Pool_Allocator_Arena * next;
    struct Pool_Allocator_Arena * prev;
} Pool_Allocator_Arena;

typedef struct Pool_Allocator {
    size_t object_size;
    size_t total_objects;
    size_t objects_per_alloc;
    size_t num_free_objects;
    Pool_Allocator_Free_List * free_list;
    Pool_Allocator_Arena     * top_arena;
    Pool_Allocator_Free_List * newfree;
    Pool_Allocator_Free_List * newlast;

    /* Pointers of arena bounds. Used in .is_owned check */
    void *lo_arena_ptr;
    void *hi_arena_ptr;
} Pool_Allocator;


/* HEADERIZER BEGIN: src/gc/pool_allocator.c */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

PARROT_EXPORT
void Parrot_gc_destroy_pool_alloctor(PARROT_INTERP,
    ARGMOD(Pool_Allocator *pool))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*pool);

PARROT_CANNOT_RETURN_NULL
PARROT_EXPORT
void * Parrot_gc_pool_allocate(PARROT_INTERP, ARGMOD(Pool_Allocator * pool))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(* pool);

PARROT_EXPORT
void Parrot_gc_pool_free(ARGMOD(Pool_Allocator *pool), ARGMOD(void *data))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*pool)
        FUNC_MODIFIES(*data);

PARROT_EXPORT
int Parrot_gc_pool_is_owned(ARGMOD(Pool_Allocator *pool), ARGMOD(void *ptr))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*pool)
        FUNC_MODIFIES(*ptr);

PARROT_CANNOT_RETURN_NULL
PARROT_MALLOC
Pool_Allocator * Parrot_gc_create_pool_allocator(size_t object_size);

#define ASSERT_ARGS_Parrot_gc_destroy_pool_alloctor \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(pool))
#define ASSERT_ARGS_Parrot_gc_pool_allocate __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(pool))
#define ASSERT_ARGS_Parrot_gc_pool_free __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(pool) \
    , PARROT_ASSERT_ARG(data))
#define ASSERT_ARGS_Parrot_gc_pool_is_owned __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(pool) \
    , PARROT_ASSERT_ARG(ptr))
#define ASSERT_ARGS_Parrot_gc_create_pool_allocator \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (0)
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: src/gc/pool_allocator.c */

#endif /* PARROT_GC_POOL_ALLOCATOR_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */

