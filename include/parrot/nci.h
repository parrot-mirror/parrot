/* nci.h
 *  Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
 *  CVS Info
 *     $Id$
 *  Overview:
 *     The nci api handles building native call frames
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#if !defined(PARROT_NCI_H_GUARD)
#define PARROT_NCI_H_GUARD

#include "parrot/parrot.h"
#include "parrot/method_util.h"

typedef void (*nci_new_method_t)(Interp* interpreter, PMC* pmc,
                                 STRING* signature, Parrot_csub_t func);
typedef void (*nci_clone_method_t)(Interp* interpreter,  PMC* pmc1, PMC* pmc2);
typedef void (*nci_invoke_method_t)(Interp* interpreter, PMC* pmc);
typedef void (*nci_free_method_t)(Interp* interpreter, PMC *pmc);


struct nci_vtable {

    // Used to initialise a new NCI PMC
    nci_new_method_t    nci_new;
    // Used to clone an NCI PMC
    nci_clone_method_t  nci_clone;
    // Used to invoke the NCI call
    nci_invoke_method_t nci_invoke;
    // Cleans up the NCI data structures
    nci_free_method_t   nci_free;

};

#endif /* PARROT_NCI_H_GUARD */

/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
*/
