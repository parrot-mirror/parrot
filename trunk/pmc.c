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

/* This segment is made up of the 'fallback' functions -- the
   functions we call if we have no clue as to how to do MMD for a
   vtable function */

void
mmd_fallback_add_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    FLOATVAL result = (VTABLE_get_number(interp, left) +
                       VTABLE_get_number(interp, right));
    VTABLE_set_number_native(interp, dest, result);

}

void
mmd_fallback_subtract_pmc(Parrot_Interp interp,
        PMC *left, PMC *right, PMC *dest)
{
    FLOATVAL result = (VTABLE_get_number(interp, left) -
                       VTABLE_get_number(interp, right));
    VTABLE_set_number_native(interp, dest, result);

}

void
mmd_fallback_multiply_pmc(Parrot_Interp interp,
        PMC *left, PMC *right, PMC *dest)
{
    FLOATVAL result = (VTABLE_get_number(interp, left) *
                       VTABLE_get_number(interp, right));
    VTABLE_set_number_native(interp, dest, result);
}

void
mmd_fallback_divide_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest) {
    FLOATVAL result = (VTABLE_get_number(interp, left) /
                       VTABLE_get_number(interp, right));
    VTABLE_set_number_native(interp, dest, result);

}

void
mmd_fallback_cmod_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    VTABLE_set_number_native(interp, dest,
                             VTABLE_get_integer(interp, left) %
                             VTABLE_get_integer(interp, right));
}

void
mmd_fallback_mod_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    FLOATVAL result = floatval_mod(VTABLE_get_number(interp, left),
                                   VTABLE_get_number(interp, right));
    VTABLE_set_number_native(interp, dest, result);
}

void
mmd_fallback_band_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    VTABLE_set_integer_native(interp, dest,
                              VTABLE_get_integer(interp, left) &
                              VTABLE_get_integer(interp, right));
}

void
mmd_fallback_bor_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    VTABLE_set_integer_native(interp, dest,
                              VTABLE_get_integer(interp, left) |
                              VTABLE_get_integer(interp, right));
}

void
mmd_fallback_bxor_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    VTABLE_set_integer_native(interp, dest,
                              VTABLE_get_integer(interp, left) ^
                              VTABLE_get_integer(interp, right));
}

void
mmd_fallback_bsl_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    VTABLE_set_integer_native(interp, dest,
                              VTABLE_get_integer(interp, left) <<
                              VTABLE_get_integer(interp, right));
}

void
mmd_fallback_bsr_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    VTABLE_set_integer_native(interp, dest,
                              VTABLE_get_integer(interp, left) >>
                              VTABLE_get_integer(interp, right));
}

void
mmd_fallback_concat_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    STRING *left_str, *right_str, *total_string;
    left_str = VTABLE_get_string(interp, left);
    right_str = VTABLE_get_string(interp, right);
    total_string = string_concat(interp, left_str, right_str, 0);
    VTABLE_set_string_native(interp, dest, total_string);

}

void
mmd_fallback_land_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    PMC *truth;
    if (!VTABLE_get_bool(interp, left)) {
        truth = left;
    } else {
        truth = right;
    }
    VTABLE_set_pmc(interp, dest, truth);
}

void
mmd_fallback_lor_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    PMC *truth;
    if (VTABLE_get_bool(interp, left)) {
        truth = left;
    } else {
        truth = right;
    }
    VTABLE_set_pmc(interp, dest, truth);
}

void
mmd_fallback_lxor_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    INTVAL left_truth, right_truth;
    PMC *true;
    left_truth = VTABLE_get_bool(interp, left);
    right_truth = VTABLE_get_bool(interp, left);
    /* Are they both false? That's the easy case */
    if ((left_truth && right_truth) || (!left_truth && !right_truth)) {
        true = constant_pmc_new_noinit(interp, enum_class_PerlUndef);
    } else {
        if (left_truth) {
            true = left;
        } else {
            true = right;
        }
    }
    VTABLE_set_pmc(interp, dest, true);
}

void
mmd_fallback_repeat_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    STRING *base;
    INTVAL count;

    base = VTABLE_get_string(interp, left);
    count = VTABLE_get_integer(interp, right);

    VTABLE_set_string_native(interp, dest,
                             string_repeat(interp, base, count, NULL));
}

void
mmd_fallback_numeq_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    if (VTABLE_get_number(interp, left) == VTABLE_get_number(interp, right)) {
        VTABLE_set_bool(interp, dest, 1);
    } else {
        VTABLE_set_bool(interp, dest, 0);
    }
}

void
mmd_fallback_streq_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    if (string_compare(interp, VTABLE_get_string(interp, left), VTABLE_get_string(interp, right))) {
        VTABLE_set_bool(interp, dest, 1);
    } else {
        VTABLE_set_bool(interp, dest, 0);
    }
}

void
mmd_fallback_numcmp_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    FLOATVAL left_float, right_float;
    INTVAL cmp_val;

    left_float = VTABLE_get_number(interp, left);
    right_float = VTABLE_get_number(interp, right);

    if (left_float == right_float) {
        cmp_val = 0;
    } else {
        if (left_float > right_float) {
            cmp_val = 1;
        } else {
            cmp_val = -1;
        }
    }

    VTABLE_set_integer_native(interp, dest, cmp_val);
}

void
mmd_fallback_strcmp_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    VTABLE_set_integer_native(interp, dest,
                              string_compare(interp, VTABLE_get_string(interp, left), VTABLE_get_string(interp, right)));
}

void
mmd_fallback_stringor_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    VTABLE_set_string_native(interp, dest,
                              string_bitwise_or(interp, VTABLE_get_string(interp, left), VTABLE_get_string(interp, right), NULL));
}

void
mmd_fallback_stringand_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    VTABLE_set_string_native(interp, dest,
                              string_bitwise_and(interp, VTABLE_get_string(interp, left), VTABLE_get_string(interp, right), NULL));
}

void
mmd_fallback_stringxor_pmc(Parrot_Interp interp, PMC *left, PMC *right, PMC *dest)
{
    VTABLE_set_string_native(interp, dest,
                              string_bitwise_xor(interp, VTABLE_get_string(interp, left), VTABLE_get_string(interp, right), NULL));
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
