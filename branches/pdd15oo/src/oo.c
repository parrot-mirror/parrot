/*
Copyright (C) 2007, The Perl Foundation.
$Id: objects.c 21497 2007-09-23 21:40:15Z paultcochrane $

=head1 NAME

oo.c - Class and object

=head1 DESCRIPTION

Handles class and object manipulation.

=head2 Functions

=over 4

=cut

*/

#define PARROT_IN_OO_C
#include "parrot/parrot.h"
#include "parrot/oo.h"

#include "oo.str"

/* HEADERIZER HFILE: include/parrot/oo.h */

PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
PMC *
Parrot_oo_get_class(PARROT_INTERP, NOTNULL(PMC *key))
{
    PMC *hll_ns = VTABLE_get_pmc_keyed_int(interp, interp->HLL_namespace,
            CONTEXT(interp->ctx)->current_HLL);

    PMC *classobj = PMCNULL;
    if (VTABLE_isa(interp, key, CONST_STRING(interp, "Class"))) {
        classobj = key;
    }
    else if (VTABLE_isa(interp, key, CONST_STRING(interp, "NameSpace"))) {
        classobj = VTABLE_get_class(interp, key);
    }
    else if (VTABLE_isa(interp, key, CONST_STRING(interp, "String"))
            || VTABLE_isa(interp, key, CONST_STRING(interp, "Key"))) {
        PMC *parent_ns = Parrot_get_namespace_keyed(interp, hll_ns, key);
        if (!PMC_IS_NULL(parent_ns))
            classobj = VTABLE_get_class(interp, parent_ns);
    }

    if (PMC_IS_NULL(classobj)) {
        /* Look up a low-level class and create a proxy */
        INTVAL type = pmc_type(interp, VTABLE_get_string(interp, key));
        if (type) {
             PMC *type_num = pmc_new(interp, enum_class_Integer);
             VTABLE_set_integer_native(interp, type_num, type);
             classobj = pmc_new_init(interp, enum_class_PMCProxy, type_num);
        }
    }
    PARROT_ASSERT(classobj);
    return classobj;
}

/*

=back

=head1 SEE ALSO

F<include/parrot/objects.h>, F<docs/pdds/pdd15_objects.pod>.

=cut

*/

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
