/* pmc.c
 *  Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
 *  CVS Info
 *     $Id$
 *  Overview:
 *     The base vtable calling functions.
 *  Data Structure and Algorithms:
 *     See include/parrot/vtable.h.
 *  History:
 *     Initial version by Simon on 2001.10.20
 *  Notes:
 *  References:
 *     <5.1.0.14.2.20011008152120.02158148@pop.sidhe.org>
 */

#include "parrot/parrot.h"

/*=for api pmc pmc_new

   Creates a new PMC of type C<base_type> (which is an index into
   the list of PMC types declared in C<Parrot_base_vtables> in
   F<pmc.h>). Once the PMC has been successfully created and
   its vtable pointer initialized, we call its C<init> method to
   perform any other necessary initialization.

=cut
*/

PMC *
pmc_new(struct Parrot_Interp *interpreter, INTVAL base_type)
{
    PMC *pmc = pmc_new_noinit(interpreter, base_type);
    VTABLE_init(interpreter, pmc);
    return pmc;
}

static PMC*
get_new_pmc_header(struct Parrot_Interp *interpreter, INTVAL base_type,
    int constant)
{
    struct Small_Object_Pool *pool;
    PMC *pmc;

    if (Parrot_base_vtables[base_type]->flags & VTABLE_IS_CONST_FLAG) {
        /* put the normal vtable in, so that the pmc can be initialized first
         * parrot or user code has to set the _ro property then,
         * to morph the PMC to the const variant
         */
        constant = 1;
        --base_type;
    }
    pool = constant ?
        interpreter->arena_base->constant_pmc_pool :
        interpreter->arena_base->pmc_pool;

    pmc = get_free_pmc(interpreter, pool);
    if (!pmc) {
        internal_exception(ALLOCATION_ERROR,
                "Parrot VM: PMC allocation failed!\n");
        return NULL;
    }

    if (constant)
        PObj_constant_SET(pmc);
    pmc->vtable = Parrot_base_vtables[base_type];

    if (!pmc->vtable || !pmc->vtable->init) {
        /* This is usually because you either didn't call init_world early
         * enough or you added a new PMC class without adding
         * Parrot_(classname)_class_init to init_world. */
        PANIC("Null vtable used");
        return NULL;
    }

    return pmc;
}

static void
pmc_new_ext(Parrot_Interp interpreter, PMC *pmc, INTVAL base_type)
{
    if (pmc->vtable->flags & VTABLE_PMC_NEEDS_EXT)
        add_pmc_ext(interpreter, pmc);
}

/*=for api pmc pmc_new_noinit

   Creates a new PMC of type C<base_type> (which is an index into the
   list of PMC types declared in C<Parrot_base_vtables> in
   F<pmc.h>). Unlike C<pmc_new>, C<pmc_new_noinit> does not call its
   C<init> method.  This allows separate allocation and initialization
   for continuations.

=cut
*/

PMC *
pmc_new_noinit(struct Parrot_Interp *interpreter, INTVAL base_type)
{
    PMC *pmc;
    /* we only have one global Env object, livin in the interpreter */
    if (base_type == enum_class_Env) {
        pmc = VTABLE_get_pmc_keyed_int(interpreter, interpreter->iglobals,
                (INTVAL)IGLOBALS_ENV_HASH);
        if (!pmc) {
            pmc = get_new_pmc_header(interpreter, base_type, 0);
            VTABLE_set_pmc_keyed_int(interpreter, interpreter->iglobals,
                    (INTVAL)IGLOBALS_ENV_HASH, pmc);
        }
        return pmc;
    }
    pmc = get_new_pmc_header(interpreter, base_type, 0);
    pmc_new_ext(interpreter, pmc, base_type);
    return pmc;
}

/*=for api pmc constant_pmc_new_noinit

   Creates a new constant PMC of type C<base_type>
=cut
*/

PMC *
constant_pmc_new_noinit(struct Parrot_Interp *interpreter, INTVAL base_type)
{
    PMC *pmc = get_new_pmc_header(interpreter, base_type, 1);
    pmc_new_ext(interpreter, pmc, base_type);
    return pmc;
}

/*=for api pmc constant_pmc_new

   Creates a new constant PMC of type C<base_type>, the call C<init>.
=cut
*/

PMC *
constant_pmc_new(struct Parrot_Interp *interpreter, INTVAL base_type)
{
    PMC *pmc = get_new_pmc_header(interpreter, base_type, 1);
    pmc_new_ext(interpreter, pmc, base_type);
    VTABLE_init(interpreter, pmc);
    return pmc;
}
/*=for api pmc pmc_new_init

   As C<pmc_new>, but passes C<init> to the PMC's C<init_pmc> method.

=cut
*/

PMC *
pmc_new_init(struct Parrot_Interp *interpreter, INTVAL base_type, PMC *init)
{
    PMC *pmc = pmc_new_noinit(interpreter, base_type);

    VTABLE_init_pmc(interpreter, pmc, init);

    return pmc;
}

/*=for api pmc constant_pmc_new_init

   As C<constant_pmc_new>, but passes C<init> to the PMC's C<init_pmc> method.

=cut
*/

PMC *
constant_pmc_new_init(struct Parrot_Interp *interpreter, INTVAL base_type,
        PMC *init)
{
    PMC *pmc = get_new_pmc_header(interpreter, base_type, 1);
    pmc_new_ext(interpreter, pmc, base_type);
    VTABLE_init_pmc(interpreter, pmc, init);
    return pmc;
}

/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
 */
