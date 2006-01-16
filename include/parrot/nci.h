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

/* Declare types for the vtable entries */

typedef void (*nci_new_method_t)(Interp* interpreter, PMC* pmc,
                                 STRING* signature, Parrot_csub_t func);
typedef void (*nci_clone_method_t)(Interp* interpreter,  PMC* pmc1, PMC* pmc2);
typedef void (*nci_invoke_method_t)(Interp* interpreter, PMC* pmc);
typedef void (*nci_free_method_t)(Interp* interpreter, PMC *pmc);
typedef void (*nci_new_callback_method_t)(Interp* interpreter,
                                          PMC* pmc,
                                          PMC* sub,
                                          STRING *cb_signature,
                                          PMC* user_data);

/* Declare the NCI vtable structure */

struct nci_vtable {

    /* Used to initialise a new NCI PMC */
    nci_new_method_t    nci_new;
    /* Used to clone an NCI PMC's data */
    nci_clone_method_t  nci_clone;
    /* Used to invoke the NCI call */
    nci_invoke_method_t nci_invoke;
    /* Cleans up the NCI data structures */
    nci_free_method_t   nci_free;
    /* Turn an unmanagedstruct into a callback */
    nci_new_callback_method_t nci_new_callback;

};


/* Pointer to the NCI implementation which is in effect */
extern struct nci_vtable *nci_vtable_ptr;

/* Alternate NCI implementations */
extern struct nci_vtable nci_builtin_vtable;
extern struct nci_vtable nci_ffcall_vtable;
extern struct nci_vtable nci_libffi_vtable;

/* Declare routines for getting and setting arguments */
INTVAL Parrot_get_nci_I(Interp *interpreter, struct call_state *st, int n);
FLOATVAL Parrot_get_nci_N(Interp *interpreter, struct call_state *st, int n);
STRING* Parrot_get_nci_S(Interp *interpreter, struct call_state *st, int n);
PMC* Parrot_get_nci_P(Interp *interpreter, struct call_state *st, int n);

void Parrot_set_nci_I(Interp *interpreter, struct call_state *st, INTVAL val);
void Parrot_set_nci_N(Interp *interpreter, struct call_state *st, FLOATVAL val);
void Parrot_set_nci_S(Interp *interpreter, struct call_state *st, STRING *val);
void Parrot_set_nci_P(Interp *interpreter, struct call_state *st, PMC* val);

char *Parrot_convert_signature (const char *signature);

#define GET_NCI_I(n) Parrot_get_nci_I(interpreter, &st, n)
#define GET_NCI_S(n) Parrot_get_nci_S(interpreter, &st, n)
#define GET_NCI_N(n) Parrot_get_nci_N(interpreter, &st, n)
#define GET_NCI_P(n) Parrot_get_nci_P(interpreter, &st, n)

#define SET_NCI_I(v) Parrot_set_nci_I(interpreter, &st, v)
#define SET_NCI_S(v) Parrot_set_nci_S(interpreter, &st, v)
#define SET_NCI_N(v) Parrot_set_nci_N(interpreter, &st, v)
#define SET_NCI_P(v) Parrot_set_nci_P(interpreter, &st, v)

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
