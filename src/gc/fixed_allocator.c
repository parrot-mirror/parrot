/*
Copyright (C) 2010, Parrot Foundation.
$Id$

=head1 NAME

src/gc/fixed_allocator.c - Implementation of allocator for small objects.

=head1 DESCRIPTION

=cut

*/

#include "parrot/parrot.h"
#include "fixed_allocator.h"

/* HEADERIZER HFILE: src/gc/fixed_allocator.h */

/* HEADERIZER BEGIN: static */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: static */

/*

=head1 METHODS

=over 4

=item C<struct Fixed_Allocator* Parrot_gc_fixed_allocator_new(PARROT_INTERP)>

Create new Fixed_Allocator.

=item C<void Parrot_gc_fixed_allocator_destroy(PARROT_INTERP, Fixed_Allocator
*allocator)>

Destroy Fixed_Allocator.

=item C<void* Parrot_gc_fixed_allocator_allocate(PARROT_INTERP, Fixed_Allocator
*allocator, size_t size)>

Allocate fixed size memory from Fixed_Allocator.

=item C<void Parrot_gc_fixed_allocator_free(PARROT_INTERP, Fixed_Allocator
*allocator, void *data, size_t size)>

Free fixed size memory from Fixed_Allocator.

=cut

*/

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
struct Fixed_Allocator*
Parrot_gc_fixed_allocator_new(PARROT_INTERP)
{
    ASSERT_ARGS(Parrot_gc_fixed_allocator_new)

    return mem_internal_allocate_zeroed_typed(Fixed_Allocator);
}

PARROT_EXPORT
void
Parrot_gc_fixed_allocator_destroy(PARROT_INTERP, ARGFREE_NOTNULL(Fixed_Allocator *allocator))
{
    ASSERT_ARGS(Parrot_gc_fixed_allocator_destroy)

}

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
void*
Parrot_gc_fixed_allocator_allocate(PARROT_INTERP,
        ARGIN(Fixed_Allocator *allocator),
        size_t size)
{
    ASSERT_ARGS(Parrot_gc_fixed_allocator_allocate)

    /* We always align size to 4/8 bytes. */
    size_t  index, alloc_size;
    void   *ret;
    PARROT_ASSERT(size);
    index      = (size - 1) / sizeof (void*);
    alloc_size = (index + 1) * sizeof (void *);

    if (index >= allocator->num_pools) {
        size_t new_size = index + 1;
        /* (re)allocate pools */
        if (allocator->num_pools)
            allocator->pools = mem_internal_realloc_n_zeroed_typed(
                                allocator->pools, new_size, allocator->num_pools, Pool_Allocator*);
        else
            allocator->pools = mem_internal_allocate_n_zeroed_typed(new_size, Pool_Allocator*);

        allocator->num_pools = new_size;
    }

    if (allocator->pools[index] == NULL)
        allocator->pools[index] = Parrot_gc_create_pool_allocator(alloc_size);

    ret = Parrot_gc_pool_allocate(interp, allocator->pools[index]);
    //memset(ret, 0, alloc_size);
    return ret;
}

PARROT_EXPORT
void
Parrot_gc_fixed_allocator_free(PARROT_INTERP,
        ARGIN(Fixed_Allocator *allocator),
        ARGFREE_NOTNULL(void *data), size_t size)
{
    ASSERT_ARGS(Parrot_gc_fixed_allocator_free)

    /* We always align size to 4/8 bytes. */
    size_t index = (size - 1) / sizeof (void*);

    PARROT_ASSERT(allocator->pools[index]);

    Parrot_gc_pool_free(allocator->pools[index], data);
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

