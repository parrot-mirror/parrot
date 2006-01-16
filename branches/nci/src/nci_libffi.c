/*
Copyright: 2006 The Perl Foundation.  All Rights Reserved.
$Id$

=head1 NAME

src/nci_libffi.c - NCI Implementation using libffi

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Functions

=over 4

=cut

*/

#include <avcall.h>
#include <callback.h>

#include "parrot/parrot.h"
#include "parrot/method_util.h"
#include "parrot/oplib/ops.h"

#include "parrot/nci.h"
#include "nci_libffi.str"

static void nci_libffi_invoke (Interp * interpreter, PMC *function);

static void
nci_libffi_new (Interp *interpreter, PMC *pmc,
                 STRING *signature, Parrot_csub_t func)
{

}

static void nci_libffi_clone (Interp * interpreter, PMC* pmc1, PMC* pmc2)
{

}


static void nci_libffi_free (Interp *interpreter, PMC *pmc)
{

}


static void nci_libffi_invoke (Interp *interpreter, PMC * pmc)
{
}

struct nci_vtable nci_libffi_vtable =
{
    nci_libffi_new,
    nci_libffi_clone,
    nci_libffi_invoke,
    nci_libffi_free
};


/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
 */
