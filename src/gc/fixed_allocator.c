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
*, size_t size)>

Allocate fixed size memory from Fixed_Allocator.

=item C<void* Parrot_gc_fixed_allocator_free(PARROT_INTERP, Fixed_Allocator *,
void *data, size_t size)>

Free fixed size memory from Fixed_Allocator.

=cut

*/

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
struct Fixed_Allocator*
Parrot_gc_fixed_allocator_new(PARROT_INTERP)
{
    return (struct Fixed_Allocator*) mem_sys_allocate(sizeof (Fixed_Allocator));
}

PARROT_EXPORT
void
Parrot_gc_fixed_allocator_destroy(PARROT_INTERP, ARGFREE_NOTNULL(Fixed_Allocator *allocator))
{
}

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
void*
Parrot_gc_fixed_allocator_allocate(PARROT_INTERP,
        ARGIN(Fixed_Allocator *allocator),
        size_t size)
{
}

PARROT_EXPORT
PARROT_CAN_RETURN_NULL
void*
Parrot_gc_fixed_allocator_free(PARROT_INTERP,
        ARGIN(Fixed_Allocator *allocator),
        ARGFREE_NOTNULL(void *data), size_t size)
{
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

