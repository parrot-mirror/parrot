/*
Copyright (C) 2001-2008, Parrot Foundation.
$Id$

=head1 NAME

src/dynext.c - Dynamic extensions to Parrot

=head1 DESCRIPTION

Functions for loading and initializing dynamic link libraries.

=head2 Functions

=over 4

=cut

*/

#include "parrot/parrot.h"
#include "parrot/dynext.h"
#include "dynext.str"
#include "pmc/pmc_parrotlibrary.h"
#include "pmc/pmc_callcontext.h"

/* HEADERIZER HFILE: include/parrot/dynext.h */

/* HEADERIZER BEGIN: static */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static STRING * clone_string_into(
    ARGMOD(Interp *d),
    ARGIN(Interp *s),
    ARGIN(PMC *value))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*d);

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static void * dlopen_string(PARROT_INTERP,
    Parrot_dlopen_flags flags,
    ARGIN(STRING *path))
        __attribute__nonnull__(1)
        __attribute__nonnull__(3);

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static STRING * get_path(PARROT_INTERP,
    ARGMOD_NULLOK(STRING *lib),
    Parrot_dlopen_flags flags,
    ARGOUT(void **handle),
    ARGIN(STRING *wo_ext),
    ARGIN_NULLOK(STRING *ext))
        __attribute__nonnull__(1)
        __attribute__nonnull__(4)
        __attribute__nonnull__(5)
        FUNC_MODIFIES(*lib)
        FUNC_MODIFIES(*handle);

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static PMC* is_loaded(PARROT_INTERP, ARGIN(STRING *path))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static PMC * make_string_pmc(PARROT_INTERP, ARGIN(STRING *string))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_CANNOT_RETURN_NULL
static PMC * run_init_lib(PARROT_INTERP,
    ARGIN(void *handle),
    ARGIN_NULLOK(STRING *lib_name),
    ARGIN(STRING *wo_ext))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(4);

static void set_cstring_prop(PARROT_INTERP,
    ARGMOD(PMC *lib_pmc),
    ARGIN(const char *what),
    ARGIN(STRING *name))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        FUNC_MODIFIES(*lib_pmc);

static void store_lib_pmc(PARROT_INTERP,
    ARGIN(PMC *lib_pmc),
    ARGIN(STRING *path),
    ARGIN(STRING *type),
    ARGIN_NULLOK(STRING *lib_name))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4);

#define ASSERT_ARGS_clone_string_into __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(d) \
    , PARROT_ASSERT_ARG(s) \
    , PARROT_ASSERT_ARG(value))
#define ASSERT_ARGS_dlopen_string __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(path))
#define ASSERT_ARGS_get_path __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(handle) \
    , PARROT_ASSERT_ARG(wo_ext))
#define ASSERT_ARGS_is_loaded __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(path))
#define ASSERT_ARGS_make_string_pmc __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(string))
#define ASSERT_ARGS_run_init_lib __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(handle) \
    , PARROT_ASSERT_ARG(wo_ext))
#define ASSERT_ARGS_set_cstring_prop __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(lib_pmc) \
    , PARROT_ASSERT_ARG(what) \
    , PARROT_ASSERT_ARG(name))
#define ASSERT_ARGS_store_lib_pmc __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(lib_pmc) \
    , PARROT_ASSERT_ARG(path) \
    , PARROT_ASSERT_ARG(type))
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: static */

/* _PARROTLIB is now the default */
/*#define _PARROTLIB not working: "make testr" */

/*

=item C<static void set_cstring_prop(PARROT_INTERP, PMC *lib_pmc, const char
*what, STRING *name)>

Set a property C<name> with value C<what> on the C<ParrotLibrary>
C<lib_pmc>.

=cut

*/

static void
set_cstring_prop(PARROT_INTERP, ARGMOD(PMC *lib_pmc), ARGIN(const char *what),
        ARGIN(STRING *name))
{
    ASSERT_ARGS(set_cstring_prop)
    STRING * const key  = Parrot_str_new_constant(interp, what);
    PMC    * const prop = Parrot_pmc_new_constant(interp, enum_class_String);

    VTABLE_set_string_native(interp, prop, name);
    VTABLE_setprop(interp, lib_pmc, key, prop);
}

/*

=item C<static void store_lib_pmc(PARROT_INTERP, PMC *lib_pmc, STRING *path,
STRING *type, STRING *lib_name)>

Store a C<ParrotLibrary> PMC in the interpreter's C<iglobals>.

=cut

*/

static void
store_lib_pmc(PARROT_INTERP, ARGIN(PMC *lib_pmc), ARGIN(STRING *path),
        ARGIN(STRING *type), ARGIN_NULLOK(STRING *lib_name))
{
    ASSERT_ARGS(store_lib_pmc)
    PMC * const iglobals = interp->iglobals;
    PMC * const dyn_libs = VTABLE_get_pmc_keyed_int(interp, iglobals,
            IGLOBALS_DYN_LIBS);

    /* remember path/file in props */
    set_cstring_prop(interp, lib_pmc, "_filename", path);
    set_cstring_prop(interp, lib_pmc, "_type", type);

    if (lib_name)
        set_cstring_prop(interp, lib_pmc, "_lib_name", lib_name);

    VTABLE_set_pmc_keyed_str(interp, dyn_libs, path, lib_pmc);
}

/*

=item C<static PMC* is_loaded(PARROT_INTERP, STRING *path)>

Check if a C<ParrotLibrary> PMC with the filename path exists.
If it does, return it. Otherwise, return NULL.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static PMC*
is_loaded(PARROT_INTERP, ARGIN(STRING *path))
{
    ASSERT_ARGS(is_loaded)
    PMC * const iglobals = interp->iglobals;
    PMC * const dyn_libs = VTABLE_get_pmc_keyed_int(interp, iglobals,
            IGLOBALS_DYN_LIBS);
    if (!VTABLE_exists_keyed_str(interp, dyn_libs, path))
        return PMCNULL;
    return VTABLE_get_pmc_keyed_str(interp, dyn_libs, path);
}

/*

=item C<static void * dlopen_string(PARROT_INTERP, Parrot_dlopen_flags flags,
STRING *path)>

Call Parrot_dlopen with the Parrot String argument converted to C string.  The
flags argument will be converted into native form and used if applicable.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static void *
dlopen_string(PARROT_INTERP, Parrot_dlopen_flags flags, ARGIN(STRING *path))
{
    ASSERT_ARGS(dlopen_string)

    char * const pathstr = Parrot_str_to_cstring(interp, path);
    void *       handle  = Parrot_dlopen(pathstr, flags);
    Parrot_str_free_cstring(pathstr);
    return handle;
}

/*

=item C<static STRING * get_path(PARROT_INTERP, STRING *lib, Parrot_dlopen_flags
flags, void **handle, STRING *wo_ext, STRING *ext)>

Return path and handle of a dynamic lib, setting lib_name to just the filestem
(i.e. without path or extension) as a freshly-allocated C string.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static STRING *
get_path(PARROT_INTERP, ARGMOD_NULLOK(STRING *lib), Parrot_dlopen_flags flags,
        ARGOUT(void **handle), ARGIN(STRING *wo_ext),
        ARGIN_NULLOK(STRING *ext))
{
    ASSERT_ARGS(get_path)
    STRING *path, *full_name;
    const char *err = NULL;    /* buffer returned from Parrot_dlerror */

    PMC * const iglobals = interp->iglobals;
    PMC * const lib_paths = VTABLE_get_pmc_keyed_int(interp, iglobals,
                                                     IGLOBALS_LIB_PATHS);
    PMC * const share_ext = VTABLE_get_pmc_keyed_int(interp, lib_paths,
                                                     PARROT_LIB_DYN_EXTS);

    if (lib == NULL) {
        *handle = Parrot_dlopen((char *)NULL, flags);
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
            full_name = Parrot_str_concat(interp, wo_ext, ext);
            path = Parrot_locate_runtime_file_str(interp, full_name,
                    PARROT_RUNTIME_FT_DYNEXT);
            if (path) {
                *handle = dlopen_string(interp, flags, path);
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
            *handle = dlopen_string(interp, flags, full_name);
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
        *handle = dlopen_string(interp, flags, full_name);
        if (*handle) {
            return full_name;
        }
    }
    /*
     * and on windows strip a leading "lib"
     * [shouldn't this happen in Parrot_locate_runtime_file instead?]
     */
#ifdef WIN32
    if (!STRING_IS_EMPTY(lib) && memcmp(lib->strstart, "lib", 3) == 0) {
        *handle = Parrot_dlopen((char *)lib->strstart + 3, 0);
        if (*handle) {
            path = Parrot_str_substr(interp, lib, 3, lib->strlen - 3, NULL, 0);
            return path;
        }
    }
#endif

    /* And on cygwin replace a leading "lib" by "cyg". */
#ifdef __CYGWIN__
    if (!STRING_IS_EMPTY(lib) && memcmp(lib->strstart, "lib", 3) == 0) {
        path = Parrot_str_concat(interp, CONST_STRING(interp, "cyg"),
            Parrot_str_substr(interp, lib, 3, lib->strlen - 3, NULL, 0));

        *handle = dlopen_string(interp, flags, path);

        if (*handle)
            return path;
    }
#endif

    /* And after-finally,  let the OS use his own search */
    if (!STRING_IS_EMPTY(lib)) {
        *handle = dlopen_string(interp, flags, lib);
        if (*handle)
            return lib;
    }

    err = Parrot_dlerror();
    Parrot_warn(interp, PARROT_WARNINGS_DYNEXT_FLAG,
                "Couldn't load '%Ss': %s\n",
                lib, err ? err : "unknown reason");
    return NULL;
}

/*

=item C<PMC * Parrot_init_lib(PARROT_INTERP, PMC *(*load_func(PARROT_INTERP)),
void (*init_func(PARROT_INTERP, PMC *)))>

Initializes a new library. First, calls C<load_func> to load the library
(if C<load_func> is provided) and then calls C<init_func>. Returns a
ParrotLibrary PMC object that represents the initialized library.

=cut

*/

PARROT_EXPORT
PARROT_CANNOT_RETURN_NULL
PMC *
Parrot_init_lib(PARROT_INTERP,
                ARGIN_NULLOK(PMC *(*load_func)(PARROT_INTERP)),
                ARGIN_NULLOK(void (*init_func)(PARROT_INTERP, ARGIN_NULLOK(PMC *))))
{
    ASSERT_ARGS(Parrot_init_lib)
    PMC *lib_pmc = NULL;

    if (load_func)
        lib_pmc = (*load_func)(interp);

    /* seems to be a native/NCI lib */
    if (!load_func || !lib_pmc)
        lib_pmc = Parrot_pmc_new_constant(interp, enum_class_ParrotLibrary);

    /*  Call init, if it exists */
    if (init_func)
        (init_func)(interp, lib_pmc);

    return lib_pmc;
}

/*

=item C<static PMC * run_init_lib(PARROT_INTERP, void *handle, STRING *lib_name,
STRING *wo_ext)>

Loads and Initializes a new library and returns a ParrotLibrary PMC.
Takes the name of a library C<libname>, that is loaded with handle C<handle>.
Calls the necessary initialization routines, if any.

=cut

*/

PARROT_CANNOT_RETURN_NULL
static PMC *
run_init_lib(PARROT_INTERP, ARGIN(void *handle),
        ARGIN_NULLOK(STRING *lib_name), ARGIN(STRING *wo_ext))
{
    ASSERT_ARGS(run_init_lib)
    STRING *type;
    PMC *(*load_func)(PARROT_INTERP);
    void (*init_func)(PARROT_INTERP, PMC *);
    PMC *lib_pmc;

    UINTVAL regs_used[]     = { 2, 2, 2, 2 }; /* Arbitrary values */
    const int parrot_hll_id = 0;
    PMC * context = Parrot_push_context(interp, regs_used);
    Parrot_pcc_set_HLL(interp, context, parrot_hll_id);
    Parrot_pcc_set_namespace(interp, context,
            Parrot_get_HLL_namespace(interp, parrot_hll_id));

    /*
     * work around gcc 3.3.3 and other problem with dynpmcs
     * something during library loading doesn't stand a GC run
     */
    Parrot_block_GC_mark(interp);

    if (lib_name) {
        STRING * const load_name       = Parrot_sprintf_c(interp,
                                        "Parrot_lib_%Ss_load", lib_name);
        STRING * const init_func_name  = Parrot_sprintf_c(interp,
                                        "Parrot_lib_%Ss_init", lib_name);
        char   * const cload_func_name = Parrot_str_to_cstring(interp, load_name);
        char   * const cinit_func_name = Parrot_str_to_cstring(interp, init_func_name);

        /* get load_func */
        void * dlsymfunc = Parrot_dlsym(handle, cload_func_name);
        load_func = (PMC * (*)(PARROT_INTERP)) D2FPTR(dlsymfunc);
        Parrot_str_free_cstring(cload_func_name);

        /* get init_func */
        dlsymfunc = Parrot_dlsym(handle, cinit_func_name);
        init_func = (void (*)(PARROT_INTERP, PMC *)) D2FPTR(dlsymfunc);
        Parrot_str_free_cstring(cinit_func_name);
    }
    else {
        load_func = NULL;
        init_func = NULL;
    }

    lib_pmc = Parrot_init_lib(interp, load_func, init_func);
    VTABLE_set_pointer(interp, lib_pmc, handle);

    if (!load_func)
        type = CONST_STRING(interp, "NCI");
    else {
        if (((Parrot_ParrotLibrary_attributes *)PMC_data(lib_pmc))->oplib_init)
            type = CONST_STRING(interp, "Ops");
        else
            type = CONST_STRING(interp, "PMC");
    }

    /* remember lib_pmc in iglobals */
    store_lib_pmc(interp, lib_pmc, wo_ext, type, lib_name);

    /* UNLOCK */
    Parrot_unblock_GC_mark(interp);

    Parrot_pop_context(interp);

    return lib_pmc;
}

/*

=item C<static STRING * clone_string_into(Interp *d, Interp *s, PMC *value)>

Extracts a STRING value from PMC C<value> in interpreter C<s>. Copies that
string into the pool of interpreter C<d> using the default encoding
and charset.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static STRING *
clone_string_into(ARGMOD(Interp *d), ARGIN(Interp *s), ARGIN(PMC *value))
{
    ASSERT_ARGS(clone_string_into)
    STRING * const  orig   = VTABLE_get_string(s, value);
    char   * const raw_str = Parrot_str_to_cstring(s, orig);
    STRING * const   ret   =
        Parrot_str_new_init(d, raw_str, strlen(raw_str),
            PARROT_DEFAULT_ENCODING, PARROT_DEFAULT_CHARSET,
            PObj_constant_FLAG);
    Parrot_str_free_cstring(raw_str);
    return ret;
}

/*

=item C<static PMC * make_string_pmc(PARROT_INTERP, STRING *string)>

Converts a STRING C<string> into a String PMC.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static PMC *
make_string_pmc(PARROT_INTERP, ARGIN(STRING *string))
{
    ASSERT_ARGS(make_string_pmc)
    PMC * const ret = Parrot_pmc_new_constant(interp, enum_class_String);
    VTABLE_set_string_native(interp, ret, string);

    return ret;
}

/*

=item C<PMC * Parrot_clone_lib_into(Interp *d, Interp *s, PMC *lib_pmc)>

Clones a ParrotLibrary PMC C<lib_pmc> from interpreter C<s> into interpreter
C<d>.

=cut

*/

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PMC *
Parrot_clone_lib_into(ARGMOD(Interp *d), ARGMOD(Interp *s), ARGIN(PMC *lib_pmc))
{
    ASSERT_ARGS(Parrot_clone_lib_into)
    STRING * const filename = CONST_STRING(s, "_filename");
    STRING * const libname  = CONST_STRING(s, "_lib_name");
    STRING * const type_str = CONST_STRING(s, "_type");
    STRING * const ops      = CONST_STRING(s, "Ops");

    STRING * const wo_ext = clone_string_into(d, s,
        VTABLE_getprop(s, lib_pmc, filename));
    STRING * const lib_name = clone_string_into(d, s,
        VTABLE_getprop(s, lib_pmc, libname));
    void * const handle = VTABLE_get_pointer(s, lib_pmc);
    STRING * const type =
        VTABLE_get_string(s, VTABLE_getprop(s, lib_pmc, type_str));

    if (Parrot_str_equal(s, type, ops)) {
        /* we can't clone oplibs in the normal way, since they're actually
         * shared between interpreters dynop_register modifies the (statically
         * allocated) op_lib_t structure from core_ops.c, for example.
         * Anyways, if we hope to share bytecode at runtime, we need to have
         * them have identical opcodes anyways.
         */
        PMC * const new_lib_pmc = Parrot_pmc_new_constant(d, enum_class_ParrotLibrary);

        PMC_data(new_lib_pmc) = handle;
        VTABLE_setprop(d, new_lib_pmc, CONST_STRING(s, "_filename"), make_string_pmc(d, wo_ext));
        VTABLE_setprop(d, new_lib_pmc, CONST_STRING(s, "_lib_name"), make_string_pmc(d, lib_name));
        VTABLE_setprop(d, new_lib_pmc, CONST_STRING(s, "_type"), make_string_pmc(d, ops));

        /* fixup d->all_op_libs, if necessary */
        if (d->n_libs != s->n_libs) {
            INTVAL i;
            if (d->all_op_libs)
                d->all_op_libs = (op_lib_t **)mem_internal_realloc(d->all_op_libs,
                    sizeof (op_lib_t *) * s->n_libs);
            else
                d->all_op_libs = (op_lib_t **)mem_internal_allocate(sizeof (op_lib_t *) *
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

/*

=item C<PMC * Parrot_load_lib(PARROT_INTERP, STRING *lib, PMC *parameters)>

Dynamic library loader.

C<parameters>, if not null, points to something which controls library
loading and initialization.  Currently just its integer value is used,
interpreted as C<Parrot_dlopen_flags>.

Calls C<Parrot_lib_%s_load()> which performs the registration of the lib
once C<Parrot_lib_%s_init()> gets called (if exists) to perform thread
specific setup. In both functions C<%s> is the name of the library.

If Parrot_lib_%s_load() succeeds, it should either return a
ParrotLibrary PMC, which is then used as the handle for this library
or NULL, in which case parrot creates a handle for the library.

If either Parrot_lib_%s_load() or Parrot_lib_%s_init() detects an error
condition, an exception should be thrown.

TODO: fetch Parrot_lib load/init handler exceptions

=cut

*/

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PMC *
Parrot_load_lib(PARROT_INTERP, ARGIN_NULLOK(STRING *lib), ARGIN_NULLOK(PMC *parameters))
{
    ASSERT_ARGS(Parrot_load_lib)
    void   *handle;
    PMC    *lib_pmc;
    STRING *path;
    STRING *lib_name, *wo_ext, *ext;    /* library stem without path
                                         * or extension.  */
    int flags = 0;
    /* Find the pure library name, without path or extension.  */
    /*
     * TODO move the class_count_mutex here
     *
     * LOCK()
     */
    if (lib) {
        lib_name = parrot_split_path_ext(interp, lib, &wo_ext, &ext);
    }
    else {
        wo_ext   = string_from_literal(interp, "");
        lib_name = NULL;
        ext      = NULL;
    }

    lib_pmc = is_loaded(interp, wo_ext);
    if (!PMC_IS_NULL(lib_pmc)) {
        /* UNLOCK() */
        return lib_pmc;
    }

    if (!PMC_IS_NULL(parameters)) {
        flags = VTABLE_get_integer(interp, parameters);
    }

    path = get_path(interp, lib, (Parrot_dlopen_flags)flags, &handle, wo_ext, ext);
    if (!path || !handle) {
        /*
         * XXX Parrot_ex_throw_from_c_args? return PMCNULL?
         * PMC Undef seems convenient, because it can be queried with get_bool()
         */
        return Parrot_pmc_new(interp, enum_class_Undef);
    }

    return run_init_lib(interp, handle, lib_name, wo_ext);
}

/*

=back

=head1 SEE ALSO

F<include/parrot/dynext.h> and F<src/pmc/parrotlibrary.pmc>.

=cut

*/


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
