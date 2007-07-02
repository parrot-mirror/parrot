/*
Copyright (C) 2001-2006, The Perl Foundation.
$Id$

=head1 NAME

src/dynext.c - Dynamic extensions to Parrot

=head1 DESCRIPTION

=head2 Functions

*/

#include "parrot/parrot.h"
#include "parrot/dynext.h"

/* HEADERIZER HFILE: include/parrot/dynext.h */

/* HEADERIZER BEGIN: static */

static STRING * get_path( Interp *interp /*NN*/,
    STRING *lib,
    void **handle /*NN*/,
    STRING *wo_ext,
    STRING *ext )
        __attribute__nonnull__(1)
        __attribute__nonnull__(3);

static PMC* is_loaded( Interp *interp /*NN*/, STRING *path )
        __attribute__nonnull__(1);

static PMC * make_string_pmc( Interp *interp /*NN*/, STRING *string )
        __attribute__nonnull__(1);

static PMC * run_init_lib( Interp *interp,
    void *handle,
    STRING *lib_name /*NN*/,
    STRING *wo_ext )
        __attribute__nonnull__(3);

static void set_cstring_prop(
    Parrot_Interp interp,
    PMC *lib_pmc,
    const char *what /*NN*/,
    STRING *name )
        __attribute__nonnull__(3);

static void store_lib_pmc(
    Parrot_Interp interp,
    PMC* lib_pmc,
    STRING *path,
    STRING *type,
    STRING *lib_name );

/* HEADERIZER END: static */

/* _PARROTLIB is now the default */
/*#define _PARROTLIB not working: "make testr" */

/*

FUNCDOC: set_cstring_prop

Set a property C<name> with value C<what> on the C<ParrotLibrary>
C<lib_pmc>.

*/

static void
set_cstring_prop(Parrot_Interp interp, PMC *lib_pmc, const char *what /*NN*/,
        STRING *name)
{
    STRING *key;

    PMC * const prop = pmc_new(interp, enum_class_String);
    VTABLE_set_string_native(interp, prop, name);
    key = const_string(interp, what);
    VTABLE_setprop(interp, lib_pmc, key, prop);
}

/*

FUNCDOC: store_lib_pmc

Store a C<ParrotLibrary> PMC in the interpreter's C<iglobals>.

*/

static void
store_lib_pmc(Parrot_Interp interp, PMC* lib_pmc, STRING *path,
        STRING *type, STRING *lib_name)
{
    PMC * const iglobals = interp->iglobals;
    PMC * const dyn_libs = VTABLE_get_pmc_keyed_int(interp, iglobals,
            IGLOBALS_DYN_LIBS);

    /*
     * remember path/file in props
     */
    set_cstring_prop(interp, lib_pmc, "_filename", path);  /* XXX */
    set_cstring_prop(interp, lib_pmc, "_type", type);
    set_cstring_prop(interp, lib_pmc, "_lib_name", lib_name);
    VTABLE_set_pmc_keyed_str(interp, dyn_libs, path, lib_pmc);
}

/*

FUNCDOC: is_loaded

Check if a C<ParrotLibrary> PMC with the filename path exists.
If it does, return it. Otherwise, return NULL.

*/

static PMC*
is_loaded(Interp *interp /*NN*/, STRING *path)
{
    PMC * const iglobals = interp->iglobals;
    PMC * const dyn_libs = VTABLE_get_pmc_keyed_int(interp, iglobals,
            IGLOBALS_DYN_LIBS);
    if (!VTABLE_exists_keyed_str(interp, dyn_libs, path))
        return NULL;
    return VTABLE_get_pmc_keyed_str(interp, dyn_libs, path);
}

/*

FUNCDOC: get_path

Return path and handle of a dynamic lib, setting lib_name to just the filestem
(i.e. without path or extension) as a freshly-allocated C string.

*/

static STRING *
get_path(Interp *interp /*NN*/, STRING *lib, void **handle /*NN*/,
                         STRING *wo_ext, STRING *ext)
{
    STRING *path, *full_name;
    const char *err = NULL;    /* buffer returned from Parrot_dlerror */

    PMC * const iglobals = interp->iglobals;
    PMC * const lib_paths = VTABLE_get_pmc_keyed_int(interp, iglobals,
                                                     IGLOBALS_LIB_PATHS);
    PMC * const share_ext = VTABLE_get_pmc_keyed_int(interp, lib_paths,
                                                     PARROT_LIB_DYN_EXTS);

    if (lib == NULL) {
        *handle = Parrot_dlopen((char *)NULL);
        if (*handle) {
            return string_from_literal(interp, "");
        }
        err = Parrot_dlerror();
        Parrot_warn(interp, PARROT_WARNINGS_DYNEXT_FLAG,
                    "Couldn't dlopen(NULL): %s\n",
                    err ? err : "unknown reason");
        return NULL;
    }

    /*
     * first, try to add an extension to the file if it has none.
     */
    if (! ext) {
        const INTVAL n = VTABLE_elements(interp, share_ext);
        INTVAL i;

        for (i = 0; i < n; ++i) {
            ext = VTABLE_get_string_keyed_int(interp, share_ext, i);
            full_name = string_concat(interp, wo_ext, ext, 0);
            path = Parrot_locate_runtime_file_str(interp, full_name,
                    PARROT_RUNTIME_FT_DYNEXT);
            if (path) {
                *handle = Parrot_dlopen(path->strstart);
                if (*handle) {
                    return path;
                }
                err = Parrot_dlerror();
                Parrot_warn(interp, PARROT_WARNINGS_DYNEXT_FLAG,
                            "Couldn't load '%Ss': %s\n",
                        full_name, err ? err : "unknown reason");
                return NULL;
            }

            /*
             * File with extension and prefix was not found,
             * so try file.extension w/o prefix
             */
            *handle = Parrot_dlopen(full_name->strstart);
            if (*handle) {
                return full_name;
            }
        }
    }
    /*
     * finally, try the given file name as is. We still use
     * Parrot_locate_runtime_file so that (a) relative pathnames are searched in
     * the standard locations, and (b) the angle of the slashes are adjusted as
     * required for non-Unix systems.
     */
    full_name = Parrot_locate_runtime_file_str(interp, lib,
            PARROT_RUNTIME_FT_DYNEXT);
    if (full_name) {
        *handle = Parrot_dlopen((char *)full_name->strstart);
        if (*handle) {
            return full_name;
        }
    }
    /*
     * and on windows strip a leading "lib"
     * [shouldn't this happen in Parrot_locate_runtime_file instead?]
     */
#ifdef WIN32
    if (memcmp(lib->strstart, "lib", 3) == 0) {
        *handle = Parrot_dlopen((char*)lib->strstart + 3);
        if (*handle) {
            path = string_substr(interp, lib, 3, lib->strlen - 3, NULL, 0);
            return path;
        }
    }
#endif
    err = Parrot_dlerror();
    Parrot_warn(interp, PARROT_WARNINGS_DYNEXT_FLAG,
                "Couldn't load '%Ss': %s\n",
                lib, err ? err : "unknown reason");
    return NULL;
}

/*

FUNCDOC: Parrot_load_lib

Dynamic library loader.

C<initializer> is currently unused.

Calls C<Parrot_lib_%s_load()> which performs the registration of the lib
once C<Parrot_lib_%s_init()> gets called (if exists) to perform thread
specific setup. In both functions C<%s> is the name of the library.

If Parrot_lib_%s_load() succeeds, it should either return a
ParrotLibrary PMC, which is then used as the handle for this library
or NULL, in which case parrot creates a handle for the library.

If either Parrot_lib_%s_load() or Parrot_lib_%s_init() detects an error
condition, an exception should be thrown.

TODO: fetch Parrot_lib load/init handler exceptions

*/

PARROT_API
PMC *
Parrot_init_lib(Interp *interp,
                PMC *(*load_func)(Interp *) /*NULLOK*/,
                void (*init_func)(Interp *, PMC *) /*NULLOK*/)
{
    PMC *lib_pmc = NULL;

    if (load_func)
        lib_pmc = (*load_func)(interp);

    if (!load_func || !lib_pmc) {
        /* seems to be a native/NCI lib */
        /*
         * this PMC should better be constant, but then all the contents
         * and the metadata have to be constant too
         * s. also tools/build/ops2c.pl and lib/Parrot/Pmc2c.pm
         */
        lib_pmc = pmc_new(interp, enum_class_ParrotLibrary);
    }

    /*
     *  Call init, if it exists
     */
    if (init_func)
        (init_func)(interp, lib_pmc);

    return lib_pmc;
}

static PMC *
run_init_lib(Interp *interp, void *handle,
                         STRING *lib_name /*NN*/, STRING *wo_ext)
{
    STRING *type;
    PMC *(*load_func)(Interp *);
    void (*init_func)(Interp *, PMC *);
    char *cinit_func_name;
    PMC *lib_pmc;

    /*
     * work around gcc 3.3.3 and other problem with dynpmcs
     * something during library loading doesn't stand a DOD run
     */
    Parrot_block_DOD(interp);
    /* get load_func */
    if (lib_name != NULL) {
        STRING * const load_func_name = Parrot_sprintf_c(interp, "Parrot_lib_%Ss_load",
                                          lib_name);
        char * const cload_func_name = string_to_cstring(interp, load_func_name);
        STRING *init_func_name;

        load_func = (PMC * (*)(Interp *))D2FPTR(Parrot_dlsym(handle,
                    cload_func_name));
        string_cstring_free(cload_func_name);
        /* get init_func */
        init_func_name = Parrot_sprintf_c(interp, "Parrot_lib_%Ss_init",
                                          lib_name);
        cinit_func_name = string_to_cstring(interp, init_func_name);
        init_func = (void (*)(Interp *, PMC *))D2FPTR(Parrot_dlsym(handle,
                    cinit_func_name));
        string_cstring_free(cinit_func_name);
    }
    else {
        load_func = NULL;
        init_func = NULL;
    }

    lib_pmc = Parrot_init_lib(interp, load_func, init_func);

    PMC_data(lib_pmc) = handle;
    if (!load_func)
        type = const_string(interp, "NCI");
    else {
        /* we could set a private flag in the PMC header too
         * but currently only ops files have struct_val set
         */
        type = const_string(interp,
                               PMC_struct_val(lib_pmc) ? "Ops" : "PMC");
    }
    /*
     * remember lib_pmc in iglobals
     */
    store_lib_pmc(interp, lib_pmc, wo_ext, type, lib_name);
    /* UNLOCK */
    Parrot_unblock_DOD(interp);

    return lib_pmc;
}

static STRING *
clone_string_into(Interp *d, Interp *s, PMC *value) {
    STRING * const orig = VTABLE_get_string(s, value);
    char * const raw_str = string_to_cstring(s, orig);
    STRING * const ret =
        string_make_direct(d, raw_str, strlen(raw_str),
            PARROT_DEFAULT_ENCODING, PARROT_DEFAULT_CHARSET,
            PObj_constant_FLAG);
    string_cstring_free(raw_str);
    return ret;
}

static PMC *
make_string_pmc(Interp *interp /*NN*/, STRING *string)
{
    PMC * const ret = VTABLE_new_from_string(interp,
        interp->vtables[enum_class_String]->pmc_class,
        string, PObj_constant_FLAG);
    return ret;
}

PARROT_API
PMC *
Parrot_clone_lib_into(Interp *d, Interp *s, PMC *lib_pmc)
{
    STRING * const wo_ext = clone_string_into(d, s, VTABLE_getprop(s, lib_pmc,
        const_string(s, "_filename")));
    STRING * const lib_name = clone_string_into(d, s, VTABLE_getprop(s, lib_pmc,
        const_string(s, "_lib_name")));
    void * const handle = PMC_data(lib_pmc);
    STRING * const type = VTABLE_get_string(s,
        VTABLE_getprop(s, lib_pmc, const_string(s, "_type")));

    if (0 == string_equal(s, type, const_string(s, "Ops"))) {
        PMC *new_lib_pmc;

        /* we can't clone oplibs in the normal way, since they're actually
         * shared between interpreters dynop_register modifies the (statically
         * allocated) op_lib_t structure from core_ops.c, for example.
         * Anyways, if we hope to share bytecode at runtime, we need to have
         * them have identical opcodes anyways.
         */
        new_lib_pmc = constant_pmc_new(d, enum_class_ParrotLibrary);
        PMC_data(new_lib_pmc) = handle;
        VTABLE_setprop(d, new_lib_pmc, const_string(d, "_filename"),
            make_string_pmc(d, wo_ext));
        VTABLE_setprop(d, new_lib_pmc, const_string(d, "_lib_name"),
            make_string_pmc(d, lib_name));
        VTABLE_setprop(d, new_lib_pmc, const_string(d, "_type"),
            make_string_pmc(d, const_string(d, "Ops")));

        /* fixup d->all_op_libs, if necessary */
        if (d->n_libs != s->n_libs) {
            INTVAL i;
            if (d->all_op_libs)
                d->all_op_libs = (op_lib_t **)mem_sys_realloc(d->all_op_libs,
                    sizeof (op_lib_t *) * s->n_libs);
            else
                d->all_op_libs = (op_lib_t **)mem_sys_allocate(sizeof (op_lib_t *) *
                    s->n_libs);
            for (i = d->n_libs; i < s->n_libs; ++i)
                d->all_op_libs[i] = s->all_op_libs[i];
            d->n_libs = s->n_libs;
        }

        return new_lib_pmc;
    }
    else {
        return run_init_lib(d, handle, lib_name, wo_ext);
    }
}

PARROT_API
PMC *
Parrot_load_lib(Interp *interp /*NN*/, STRING *lib /*NULLOK*/, SHIM(PMC *initializer))
{
    void * handle;
    PMC *lib_pmc;
    STRING *path;
    STRING *lib_name, *wo_ext, *ext;    /* library stem without path
                                         * or extension.  */
    /* Find the pure library name, without path or extension.  */
    /*
     * TODO move the class_count_mutex here
     *
     * LOCK()
     */
    if (lib == NULL) {
        wo_ext   = string_from_literal(interp, "");
        lib_name = NULL;
    }
    else {
        lib_name = parrot_split_path_ext(interp, lib, &wo_ext, &ext);
    }
    lib_pmc = is_loaded(interp, wo_ext);
    if (lib_pmc) {
        /* UNLOCK() */
        return lib_pmc;
    }
    path = get_path(interp, lib, &handle, wo_ext, ext);
    if (!path || !handle) {
        /*
         * XXX internal_exception? return PMCNULL?
         * PMC Undef seems convenient, because it can be queried with get_bool()
         */
        return pmc_new(interp, enum_class_Undef);
    }

    lib_pmc = run_init_lib(interp, handle, lib_name, wo_ext);
    return lib_pmc;
}

/*

=head1 SEE ALSO

F<include/parrot/dynext.h> and F<src/pmc/parrotlibrary.pmc>.

=head1 HISTORY

Initial rev by leo 2003.08.06.

*/


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
