/* mmd.h
 *  Copyright (C) 2003-2007, The Perl Foundation.
 *  SVN Info
 *     $Id$
 *  Overview:
 *     This is the API header for the mmd subsystem
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#ifndef PARROT_MMD_H_GUARD
#define PARROT_MMD_H_GUARD

#include "parrot/config.h"
#include "parrot/compiler.h"
#include "parrot/parrot.h"

/* function typedefs */
typedef PMC*    (*mmd_f_p_ppp)(PARROT_INTERP, PMC *, PMC *, PMC *);
typedef PMC*    (*mmd_f_p_pip)(PARROT_INTERP, PMC *, INTVAL, PMC *);
typedef PMC*    (*mmd_f_p_pnp)(PARROT_INTERP, PMC *, FLOATVAL, PMC *);
typedef PMC*    (*mmd_f_p_psp)(PARROT_INTERP, PMC *, STRING *, PMC *);

typedef void (*mmd_f_v_pp)(PARROT_INTERP, PMC *, PMC *);
typedef void (*mmd_f_v_pi)(PARROT_INTERP, PMC *, INTVAL);
typedef void (*mmd_f_v_pn)(PARROT_INTERP, PMC *, FLOATVAL);
typedef void (*mmd_f_v_ps)(PARROT_INTERP, PMC *, STRING *);

typedef INTVAL (*mmd_f_i_pp)(PARROT_INTERP, PMC *, PMC *);

typedef struct _MMD_init {
        INTVAL func_nr;
        INTVAL left, right;
        funcptr_t func_ptr;
} MMD_init;

typedef struct _MMD_table {
    funcptr_t *mmd_funcs;     /* The functions for the MMD table */
    UINTVAL x;               /* The x coord for each table */
    UINTVAL y;               /* The y coord for each table */
} MMD_table;


/* HEADERIZER BEGIN: src/mmd.c */

PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
funcptr_t get_mmd_dispatch_type(PARROT_INTERP,
    INTVAL func_nr,
    INTVAL left_type,
    INTVAL right_type,
    NOTNULL(int *is_pmc))
        __attribute__nonnull__(1)
        __attribute__nonnull__(5);

PARROT_API
void mmd_add_by_class(PARROT_INTERP,
    INTVAL functype,
    NOTNULL(STRING *left_class),
    NOTNULL(STRING *right_class),
    NULLOK(funcptr_t funcptr))
        __attribute__nonnull__(1)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4);

PARROT_API
void mmd_add_function(PARROT_INTERP,
    INTVAL func_nr,
    NULLOK(funcptr_t function))
        __attribute__nonnull__(1);

PARROT_API
void mmd_destroy(PARROT_INTERP)
        __attribute__nonnull__(1);

PARROT_API
INTVAL mmd_dispatch_i_pp(PARROT_INTERP,
    NOTNULL(PMC *left),
    NOTNULL(PMC *right),
    INTVAL func_nr)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_API
PARROT_CAN_RETURN_NULL
PMC* mmd_dispatch_p_pip(PARROT_INTERP,
    NOTNULL(PMC *left),
    INTVAL right,
    NULLOK(PMC *dest),
    INTVAL func_nr)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_API
PARROT_CAN_RETURN_NULL
PMC* mmd_dispatch_p_pnp(PARROT_INTERP,
    NOTNULL(PMC *left),
    FLOATVAL right,
    NULLOK(PMC *dest),
    INTVAL func_nr)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PMC* mmd_dispatch_p_ppp(PARROT_INTERP,
    NOTNULL(PMC *left),
    NOTNULL(PMC *right),
    NULLOK(PMC *dest),
    INTVAL func_nr)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_API
PARROT_CAN_RETURN_NULL
PMC* mmd_dispatch_p_psp(PARROT_INTERP,
    NOTNULL(PMC *left),
    NOTNULL(STRING *right),
    NULLOK(PMC *dest),
    INTVAL func_nr)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_API
void mmd_dispatch_v_pi(PARROT_INTERP,
    NOTNULL(PMC *left),
    INTVAL right,
    INTVAL func_nr)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_API
void mmd_dispatch_v_pn(PARROT_INTERP,
    NOTNULL(PMC *left),
    FLOATVAL right,
    INTVAL func_nr)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_API
void mmd_dispatch_v_pp(PARROT_INTERP,
    NOTNULL(PMC *left),
    NOTNULL(PMC *right),
    INTVAL func_nr)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_API
void mmd_dispatch_v_ps(PARROT_INTERP,
    NOTNULL(PMC *left),
    NOTNULL(STRING *right),
    INTVAL func_nr)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_API
void mmd_register(PARROT_INTERP,
    INTVAL func_nr,
    INTVAL left_type,
    INTVAL right_type,
    NULLOK(funcptr_t funcptr))
        __attribute__nonnull__(1);

PARROT_API
void mmd_register_sub(PARROT_INTERP,
    INTVAL func_nr,
    INTVAL left_type,
    INTVAL right_type,
    NOTNULL(PMC *sub))
        __attribute__nonnull__(1)
        __attribute__nonnull__(5);

PARROT_API
PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
PMC * mmd_vtfind(PARROT_INTERP, INTVAL func_nr, INTVAL left, INTVAL right)
        __attribute__nonnull__(1);

PARROT_API
void Parrot_mmd_rebuild_table(PARROT_INTERP, INTVAL type, INTVAL func_nr)
        __attribute__nonnull__(1);

PARROT_API
void Parrot_mmd_register_table(PARROT_INTERP,
    INTVAL type,
    ARGIN(const MMD_init *mmd_table),
    INTVAL n)
        __attribute__nonnull__(1)
        __attribute__nonnull__(3);

PARROT_API
PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
PMC * Parrot_MMD_search_default_infix(PARROT_INTERP,
    NOTNULL(STRING *meth),
    INTVAL left_type,
    INTVAL right_type)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_API
PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
PMC * Parrot_mmd_sort_candidate_list(PARROT_INTERP,
    NOTNULL(PMC *candidates))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

void mmd_create_builtin_multi_stub(PARROT_INTERP,
    NOTNULL(PMC *ns),
    INTVAL func_nr)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

/* HEADERIZER END: src/mmd.c */


#endif /* PARROT_MMD_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
