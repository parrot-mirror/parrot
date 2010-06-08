/*
Copyright (C) 2001-2010, Parrot Foundation.
$Id$

=head1 NAME

src/gc/fixed_allocator.h - implementation of allocator for small-size objects.

=head1 DESCRIPTION

*/

#ifndef PARROT_GC_FIXED_ALLOCATOR_H_GUARD
#define PARROT_GC_FIXED_ALLOCATOR_H_GUARD

#include "parrot/settings.h"
#include "pool_allocator.h"

typedef struct Fixed_Allocator
{
    Pool_Allocator **pools;
    size_t           num_pools;
} Fixed_Allocator;


/* HEADERIZER BEGIN: src/gc/fixed_allocator.c */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
void* Parrot_gc_fixed_allocator_allocate(PARROT_INTERP,
    ARGIN(Fixed_Allocator *allocator),
    size_t size)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_gc_fixed_allocator_destroy(PARROT_INTERP,
    ARGFREE_NOTNULL(Fixed_Allocator *allocator))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
void Parrot_gc_fixed_allocator_free(PARROT_INTERP,
    ARGIN(Fixed_Allocator *allocator),
    ARGFREE_NOTNULL(void *data),
    size_t size)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
struct Fixed_Allocator* Parrot_gc_fixed_allocator_new(PARROT_INTERP)
        __attribute__nonnull__(1);

#define ASSERT_ARGS_Parrot_gc_fixed_allocator_allocate \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(allocator))
#define ASSERT_ARGS_Parrot_gc_fixed_allocator_destroy \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(allocator))
#define ASSERT_ARGS_Parrot_gc_fixed_allocator_free \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(allocator) \
    , PARROT_ASSERT_ARG(data))
#define ASSERT_ARGS_Parrot_gc_fixed_allocator_new __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: src/gc/fixed_allocator.c */


#endif /* PARROT_GC_FIXED_ALLOCATOR_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
