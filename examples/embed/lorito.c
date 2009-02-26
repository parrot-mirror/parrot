/*
Copyright (C) 2009, Parrot Foundation.
$Id$

A parrot embedding test
'lorito' is 'little parrot' in spanish
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parrot/embed.h"
#include "parrot/extend.h"

/**********************************************************************/

void fail(const char *msg);
unsigned int getuintval(const char *s);
Parrot_Run_core_t getruncore(const char *name);

Parrot_String create_string(Parrot_Interp interp, const char *name);
int lorito_main(Parrot_Interp interp, int argc, char **argv);

/**********************************************************************/

/* Auxiliary generic functions */

void fail(const char *msg)
{
    fprintf(stderr, "lorito failed: %s\n", msg);
    exit(EXIT_FAILURE);
}

unsigned int getuintval(const char *s)
{
    char *aux;
    unsigned long int n = strtoul(s, &aux, 0);
    if (*aux != '\0')
        fail("Invalid number");
    return n;
}

struct runcoreinfo {
    Parrot_Run_core_t id;
    const char *name;
};

Parrot_Run_core_t getruncore(const char *name)
{
    static const struct runcoreinfo cores [] = {
        { PARROT_SLOW_CORE,     "slow" },
        { PARROT_FAST_CORE,     "fast" },
        { PARROT_CGOTO_CORE,    "cgoto" },
        { PARROT_JIT_CORE,      "jit" },
        { PARROT_GC_DEBUG_CORE, "gcdebug" },
        { PARROT_SWITCH_CORE,   "switch" }
    };
    static const unsigned int n = sizeof (cores)/sizeof (struct runcoreinfo);
    unsigned int i;
    for (i= 0; i < n; ++i) {
        if (strcmp(name, cores[i].name) == 0)
            break;
    }
    if (i >= n)
        fail("Invalid runcore");
    return cores[i].id;
}

/**********************************************************************/

/* Auxiliary parrot functions */

Parrot_String create_string(Parrot_Interp interp, const char *name)
{
    return Parrot_new_string(interp, name, strlen(name), (const char *) NULL, 0);
}

/**********************************************************************/

int lorito_main(Parrot_Interp interp, int argc, char **argv)
{
    char *source;
    Parrot_PackFile pf;
    const char *stname = NULL;
    const char *exec = NULL;
    int i;

    /* Incompatible options are not checked yet */
    for (i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--trace") == 0) {
            ++i;
            if (i >= argc)
                fail("Option needs argument");
            Parrot_set_trace(interp, getuintval(argv[i]));
        }
        else if (strcmp(argv[i], "-e") == 0) {
            ++i;
            if (i >= argc)
                fail("Option needs argument");
            exec = argv[i];
        }
        else if (strcmp(argv[i], "--start") == 0) {
            ++i;
            if (i >= argc)
                fail("Option needs argument");
            stname = argv[i];
        }
        else if (strcmp(argv[i], "--runcore") == 0) {
            ++i;
            if (i >= argc)
                fail("Option needs argument");
            Parrot_set_run_core(interp, getruncore(argv[i]));
        }
        else
            break;
    }

    if (exec) {
        Parrot_String compiler = create_string(interp, "PIR");
	Parrot_String errstr;
        Parrot_PMC code = Parrot_compile_string(interp, compiler, exec, &errstr);
        void *discard = Parrot_call_sub(interp, code, "v");
        return 0;
    }

    if (i >= argc)
        fail("No file to load");
    source = argv[i];

    pf = Parrot_pbc_read(interp, source, 0);
    if (! pf)
        fail("Cannot load file");

    Parrot_pbc_load(interp, pf);
    Parrot_pbc_fixup_loaded(interp);

    if (stname) {
        Parrot_PMC rootns = Parrot_get_root_namespace(interp);
        Parrot_String parrotname = create_string(interp, "parrot");
        Parrot_PMC parrotns = Parrot_PMC_get_pmc_strkey(interp, rootns, parrotname);
        Parrot_String name = create_string(interp, stname);
        Parrot_PMC start = Parrot_PMC_get_pmc_strkey(interp, parrotns, name);
        void *discard;
        discard = Parrot_call_sub(interp, start, "v");
    }
    else {
        Parrot_runcode(interp, argc - i, argv + i);
    }

    return 0;
}

int main(int argc, char **argv)
{
    Parrot_Interp interp;
    int r;

    Parrot_set_config_hash();
    interp = Parrot_new(NULL);
    if (! interp)
        fail("Cannot create parrot interpreter");

    Parrot_set_executable_name(interp, create_string(interp, argv[0]));
    Parrot_setwarnings(interp, PARROT_WARNINGS_ALL_FLAG);

    r = lorito_main(interp, argc, argv);

    Parrot_destroy(interp);
    return r;
}

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
