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
#include "parrot/oo_private.h"

#include "oo.str"

/* HEADERIZER HFILE: include/parrot/oo.h */

/*

=item C<Parrot_oo_get_class>

Lookup a class object from a namespace, string, or key PMC.

=cut

*/

PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
PMC *
Parrot_oo_get_class(PARROT_INTERP, NOTNULL(PMC *key))
{
    PMC *classobj = PMCNULL;
    if (VTABLE_isa(interp, key, CONST_STRING(interp, "Class")) 
            || VTABLE_isa(interp, key, CONST_STRING(interp, "PMCProxy"))) {
        classobj = key;
    }
    else if (VTABLE_isa(interp, key, CONST_STRING(interp, "NameSpace"))) {
        classobj = VTABLE_get_class(interp, key);
    }
    else if (VTABLE_isa(interp, key, CONST_STRING(interp, "String"))
            || VTABLE_isa(interp, key, CONST_STRING(interp, "Key"))) {
        PMC *hll_ns = VTABLE_get_pmc_keyed_int(interp, interp->HLL_namespace,
                CONTEXT(interp->ctx)->current_HLL);
        PMC *ns = Parrot_get_namespace_keyed(interp, hll_ns, key);
        if (!PMC_IS_NULL(ns))
            classobj = VTABLE_get_class(interp, ns);
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
    return classobj;
}

/*

=item C<Parrot_oo_get_class_str>

Lookup a class object from a builtin string.

=cut

*/

PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
PMC *
Parrot_oo_get_class_str(PARROT_INTERP, NOTNULL(STRING *name))
{
    PMC *namearg = pmc_new(interp, enum_class_String);
    VTABLE_set_string_native(interp, namearg, name);
    return Parrot_oo_get_class(interp, namearg);
}

/*

=item C<Parrot_oo_newclass_from_str>

Create a new class object from a string name.

=cut

*/

PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
PMC *
Parrot_oo_newclass_from_str(PARROT_INTERP, NOTNULL(STRING *name))
{
    PMC *namearg, *namehash, *classobj;
    namearg = pmc_new(interp, enum_class_String);
    VTABLE_set_string_native(interp, namearg, name);
    namehash = pmc_new(interp, enum_class_Hash);
    VTABLE_set_pmc_keyed_str(interp, namehash,
        string_from_literal(interp, "name"), namearg);
    classobj = pmc_new_init(interp, enum_class_Class, namehash);

    PARROT_ASSERT(classobj);
    return classobj;
}

PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
PMC *
Parrot_oo_find_vtable_override_for_class(PARROT_INTERP, NOTNULL(PMC *classobj), NOTNULL(STRING *name))
{
    if (VTABLE_isa(interp, classobj, string_from_literal(interp, "Class"))) {
        Parrot_Class * const class_info = PARROT_CLASS(classobj);
        if (VTABLE_exists_keyed_str(interp, class_info->vtable_overrides,
                name)) {
            /* Found it. */
            PMC * const meth = VTABLE_get_pmc_keyed_str(interp,
                class_info->vtable_overrides, name);
            return meth;
        }
    }

    return PMCNULL;
}

/*

=back

=head1 SEE ALSO

F<include/parrot/oo.h>, F<include/parrot/oo_private.h>,
F<docs/pdds/pdd15_objects.pod>.

=cut

*/

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
