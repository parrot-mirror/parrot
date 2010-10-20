/*
 * $Id$
 * Copyright (C) 2010, Parrot Foundation.
 */

/*

=head1 NAME

config/gen/platform/generic/sysmem.c

=head1 DESCRIPTION

Get system memory information.

=head2 Functions

=over 4

=cut

*/

#include <unistd.h>

/*

=item C<size_t Parrot_sysmem_amount(PARROT_INTERP)>

Get information about available physycal memory.

=cut

*/

size_t
Parrot_sysmem_amount(PARROT_INTERP)
{
    return sysconf(_SC_AVPHYS_PAGES) * sysconf(_SC_PAGE_SIZE);
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
