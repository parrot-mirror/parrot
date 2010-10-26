
#define EMBED_API_CALLIN(i) { jmp_buf _env; \
    if (setjmp(_env)) { \
        interp->api_jmp_buf = NULL; \
        return 0; \
    } else { \
        interp->api_jmp_buf = _env;
#define EMBED_API_CALLOUT(i) \
        return 1; \
    }

PARROT_EXPORT
PARROT_CANNOT_RETURN_NULL
PARROT_MALLOC
Parrot_Interp
Parrot_api_make_interpreter(ARGIN_NULLOK(Interp *parent), INTVAL flags)
{
    ASSERT_ARGS(Parrot_api_make_interpreter)
    Parrot_set_config_hash();
    Interp * const interp = allocate_interpreter(parent, flags);
    return interp;
}

void
Parrot_api_initialize_interpreter(ARGIN(Interp *interp))
{
    ASSERT_ARGS(Parrot_api_initialize_interpreter)
    int stacktop;
    initialize_interpreter(interp, (void*)&stacktop);
}

void
Parrot_api_set_runcore(ARGIN(Interp *interp), Parrot_Run_core_t core, Parrot_Uint trace)
{
    if (trace)
        core = PARROT_SLOW_CORE;
    EMBED_API_CALLIN(interp)
    Parrot_set_trace(interp, (Parrot_trace_flags)trace);
    Parrot_set_run_core(interp, core);
    EMBED_API_CALLOUT(interp)
}

void
Parrot_api_set_executable_name(ARGIN(Interp *interp), ARGIN(Parrot_String) name)
{
    ASSERT_ARGS(Parrot_api_set_executable_name)
    EMBED_API_CALLIN(interp)
    PMC * const name_pmc = Parrot_pmc_new(interp, enum_class_String);
    VTABLE_set_string_native(interp, name_pmc, name);
    VTABLE_set_pmc_keyed_int(interp, interp->iglobals, IGLOBALS_EXECUTABLE,
        name_pmc);
    EMBED_API_CALLOUT(interp)
}

void
Parrot_api_destroy_interpreter(ARGIN(Interp *interp))
{
    Parrot_destroy(interp);
}

/*

=item C<int Parrot_api_load_bytecode_file(PARROT_INTERP, const char *filename)>

Load a bytecode file into the interpreter by name. Returns C<0> on failure,
Success otherwise. Writes error information to the interpreter's error file
stream.

=cut

*/

PARROT_EXPORT
int
Parrot_api_load_bytecode_file(PARROT_INTERP, ARGIN(const char *filename))
{
    PackFile * const pf = Parrot_pbc_read(interp, filename, 0);

    if (!pf)
        return 0;
    Parrot_pbc_load(interp, pf);
    return 1;
}
