/* objects.h
 *  Copyright (C) 2007, The Perl Foundation.
 *  SVN Info
 *     $Id: oo.h 20040 2007-07-20 18:56:25Z petdance $
 *  Overview:
 *     Parrot class and object header stuff
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#ifndef PARROT_OO_H_GUARD
#define PARROT_OO_H_GUARD

#include "parrot/parrot.h"

/* HEADERIZER BEGIN: src/oo.c */

PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
PMC * Parrot_oo_get_class( PARROT_INTERP, NOTNULL(PMC *key) )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

/* HEADERIZER END: src/oo.c */

#endif /* PARROT_OO_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
