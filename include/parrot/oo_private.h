/* oo_private.h
 *  Copyright (C) 2007, The Perl Foundation.
 *  SVN Info
 *     $Id: oo.h 20040 2007-07-20 18:56:25Z petdance $
 *  Overview:
 *     Structs, typedefs and macros for the Class, Object, and PMCProxy PMCs.
 *     This header file is only included by files within the OO subsystem.
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#ifndef PARROT_OO_PRIVATE_H_GUARD
#define PARROT_OO_PRIVATE_H_GUARD

#include "parrot/parrot.h"

/* Class PMC's underlying struct. */
typedef struct Parrot_Class {
    int id;                /* The type number of the PMC. [To be deprecated] */
    STRING *name;          /* The name of the class. */
    PMC *_namespace;       /* The namespace it's linked to, if any. */
    int instantiated;      /* Any instantiations since last modification? */
    PMC *parents;          /* Immediate parent classes. */
    PMC *all_parents;      /* Cached list of ourself and all parents, in MRO order. */
    PMC *roles;            /* An array of roles. */
    PMC *methods;          /* Hash of method names to methods in this class. */
    PMC *vtable_overrides; /* Hash of Parrot v-table methods we override. */
    PMC *attrib_metadata;  /* Hash of attributes in this class to hashes of metadata. */
    PMC *attrib_index;     /* Lookup table for attributes in this and parents. */
    PMC *attrib_cache;     /* Cache of visible attrib names to indexes. */
    PMC *resolve_method;   /* List of method names the class provides to resolve
                            * conflicts with methods from roles. */
} Parrot_Class;

/* Macro to access underlying structure of a Class PMC. */
#define PARROT_CLASS(o) ((Parrot_Class *) PMC_data(o))

/* Object PMC's underlying struct. */
typedef struct Parrot_Object {
    PMC *_class;          /* The class this is an instance of. */
    PMC *attrib_store;   /* The attributes store - a resizable PMC array. */
} Parrot_Object;

/* Macro to access underlying structure of an Object PMC. */
#define PARROT_OBJECT(o) ((Parrot_Object *) PMC_data(o))

/* Fully qualified class name generation; defined in Class, used by Object. */
STRING* Parrot_Class_get_fq_classname(Parrot_Interp interp, Parrot_Class *class_info);

/* We have a flag to mark if the class inherits from anything from a different
 * class universe (for example, a PMC). */
#define PObj_HasAlienParents_FLAG PObj_private0_FLAG
#define PObj_HasAlienParents_TEST(o) PObj_flag_TEST(HasAlienParents, o)
#define PObj_HasAlienParents_SET(o) PObj_flag_SET(HasAlienParents, o)

#endif /* PARROT_OO_PRIVATE_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
