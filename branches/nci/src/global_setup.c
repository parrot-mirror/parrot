/*
Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
$Id$

=head1 NAME

src/global_setup.c - Global setup

=head1 DESCRIPTION

Performs all the global setting up of things. This includes the (very
few) global variables that Parrot totes around.

I<What are these global variables?>

=head2 Functions

=over 4

=cut

*/

#define INSIDE_GLOBAL_SETUP
#include "parrot/parrot.h"
#include "global_setup.str"

/* These functions are defined in the auto-generated file core_pmcs.c */
extern void Parrot_initialize_core_pmcs(Interp *interp);

static const unsigned char* parrot_config_stored = NULL;
static unsigned int parrot_config_size_stored = 0;


/*

=item C<void
Parrot_set_config_hash_internal (const unsigned char* parrot_config,
                                 unsigned int parrot_config_size)>

Called by Parrot_set_config_hash with the serialised hash which
will be used in subsequently created Interpreters

=cut

*/

void
Parrot_set_config_hash_internal (const unsigned char* parrot_config,
                                 unsigned int parrot_config_size)
{
    parrot_config_stored      = parrot_config;
    parrot_config_size_stored = parrot_config_size;
}

/*

=item C<void parrot_set_config_hash_interpreter (Interp* interpreter)>


Used internally to associate the config hash with an Interpreter
using the last registered config data.

=cut

*/

static void parrot_set_config_hash_interpreter (Interp* interpreter)
{
    PMC *iglobals = interpreter->iglobals;

    PMC *config_hash = NULL;

    if (parrot_config_size_stored > 1)
    {
        STRING *config_string =
            string_make_direct(interpreter,
                               parrot_config_stored, parrot_config_size_stored,
                               PARROT_DEFAULT_ENCODING, PARROT_DEFAULT_CHARSET,
                               PObj_external_FLAG|PObj_constant_FLAG);

        config_hash = Parrot_thaw(interpreter, config_string);
    }
    else
    {
        config_hash = pmc_new(interpreter, enum_class_Hash);
    }

    VTABLE_set_pmc_keyed_int(interpreter, iglobals,
                             (INTVAL) IGLOBALS_CONFIG_HASH, config_hash);
}


/*

=item C<void init_world(Interp *interpreter)>

This is the actual initialization code called by C<Parrot_init()>.

It sets up the Parrot system, running any platform-specific init code if
necessary, then initializing the string subsystem, and setting up the
base vtables and core PMCs.

C<interpreter> should be the root interpreter returned by
C<Parrot_new(NULL)>.

=cut

*/

void
init_world(Interp *interpreter)
{
    PMC *iglobals;
    PMC *self, *pmc;

#ifdef PARROT_HAS_PLATFORM_INIT_CODE
    Parrot_platform_init_code();
#endif

    /*
     * TODO allocate core vtable table only once - or per interpreter
     *      divide globals into real globals and per interpreter
     */
    if (!Parrot_base_vtables) {
        Parrot_base_vtables =
            mem_sys_allocate_zeroed(sizeof(VTABLE *) * PARROT_MAX_CLASSES);
        enum_class_max = enum_class_core_max;
        class_table_size = PARROT_MAX_CLASSES;
    }

    /* Call base vtable class constructor methods */
    Parrot_initialize_core_pmcs(interpreter);

    iglobals = interpreter->iglobals;
    VTABLE_set_pmc_keyed_int(interpreter, iglobals,
            (INTVAL)IGLOBALS_CLASSNAME_HASH, interpreter->class_hash);
    self = pmc_new_noinit(interpreter, enum_class_ParrotInterpreter);
    PMC_data(self) = interpreter;
    VTABLE_set_pmc_keyed_int(interpreter, iglobals,
            (INTVAL) IGLOBALS_INTERPRETER, self);

    parrot_set_config_hash_interpreter(interpreter);

    /*
     * HLL support
     */
    if (interpreter->parent_interpreter)
        interpreter->HLL_info = interpreter->parent_interpreter->HLL_info;
    else {
        STRING *parrot = CONST_STRING(interpreter, "parrot");
        interpreter->HLL_info = constant_pmc_new(interpreter,
                enum_class_ResizablePMCArray);
        Parrot_register_HLL(interpreter, parrot, NULL);
    }
    /*
     * lib search paths
     */
    parrot_init_library_paths(interpreter);
    /*
     * load_bytecode and dynlib loaded hash
     */
    pmc = pmc_new(interpreter, enum_class_Hash);
    VTABLE_set_pmc_keyed_int(interpreter, iglobals,
            IGLOBALS_PBC_LIBS, pmc);
    pmc = pmc_new(interpreter, enum_class_Hash);
    VTABLE_set_pmc_keyed_int(interpreter, iglobals,
            IGLOBALS_DYN_LIBS, pmc);
}


/*

=back

=head1 SEE ALSO

F<include/parrot/global_setup.h>.

=cut

*/

/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
*/
