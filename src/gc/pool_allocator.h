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

typedef struct Pool_Allocator_Free_List {
    struct Pool_Allocator_Free_List * next;
} Pool_Allocator_Free_List;

typedef struct Pool_Allocator_Arena {
    struct Pool_Allocator_Arena * next;
    struct Pool_Allocator_Arena * prev;
} Pool_Allocator_Arena;

typedef struct Pool_Allocator_Pool {
    size_t attr_size;
    size_t total_objects;
    size_t objects_per_alloc;
    size_t num_free_objects;
    Pool_Allocator_Free_List * free_list;
    Pool_Allocator_Arena     * top_arena;
#if GC_USE_LAZY_ALLOCATOR
    Pool_Allocator_Free_List * newfree;
    Pool_Allocator_Free_List * newlast;
#endif
} Pool_Allocator_Pool;

/* HEADERIZER BEGIN: src/gc/pool_allocator.c */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: src/gc/pool_allocator.c */

#endif /* PARROT_GC_POOL_ALLOCATOR_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */

