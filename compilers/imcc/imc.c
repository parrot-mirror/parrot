/*
 * imc.c
 *
 * Main entry point and top level of IMCC compiler.
 *
 * Moved all register allocation and spill code to reg_alloc.c
 */

#include <string.h>
#include <assert.h>
#include "imc.h"
#include "optimizer.h"

/* HEADERIZER HFILE: compilers/imcc/imc.h */

/* HEADERIZER BEGIN: static */

static void imc_free_unit( Interp *interp /*NN*/, IMC_Unit *unit /*NN*/ )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

static IMC_Unit * imc_new_unit( IMC_Unit_Type t );
/* HEADERIZER END: static */

#define COMPILE_IMMEDIATE 1
/*
extern FILE* yyin;
*/


PARROT_API
void
imc_compile_all_units(Interp *interp /*NN*/)
{
    IMC_Unit *unit;
#if ! COMPILE_IMMEDIATE
    for (unit = IMCC_INFO(interp)->imc_units; unit; ) {
        IMC_Unit * const unit_next = unit->next;
        imc_compile_unit(interp, unit);
        unit = unit_next;
    }
#endif
    emit_close(interp, NULL);
    /* All done with compilation, now free instructions and other structures */

    for (unit = IMCC_INFO(interp)->imc_units; unit;) {
        IMC_Unit * const unit_next = unit->next;
        Instruction *ins;

        for (ins = unit->instructions; ins; ) {
            Instruction * const ins_next = ins->next;
            free_ins(ins);
            ins = ins_next;
        }
        imc_free_unit(interp, unit);
        unit = unit_next;
    }

    IMCC_INFO(interp)->imc_units = NULL;
    IMCC_INFO(interp)->last_unit = NULL;
}

/* imc_compile_unit is the main loop of the IMC compiler for each unit. It
 * operates on a single compilation unit at a time.
 */

PARROT_API
void
imc_compile_unit(Interp *interp /*NN*/, IMC_Unit *unit)
{
    /* Not much here for now except the allocator */
    IMCC_INFO(interp)->cur_unit = unit;

    imc_reg_alloc(interp, unit);
    emit_flush(interp, NULL, unit);
}


/*
 * Any activity required to cleanup the compiler state and be
 * ready for a new compiler invocation goes here.
 */

PARROT_API
void
imc_cleanup(Interp *interp /*NN*/, void *yyscanner)
{
    IMCC_pop_parser_state(interp, yyscanner);
    clear_globals(interp);
    mem_sys_free(IMCC_INFO(interp)->ghash.data);
    IMCC_INFO(interp)->ghash.data = NULL;
}


/*
 * Create a new IMC_Unit.
 */
static IMC_Unit *
imc_new_unit(IMC_Unit_Type t)
{
    IMC_Unit * const unit = (IMC_Unit *)calloc(1, sizeof (IMC_Unit));
    create_symhash(&unit->hash);
    unit->type = t;
    return unit;
}

/*
 * Create a new IMC_Unit and "open" it for construction.
 * This sets the current state of the parser. The unit
 * can be closed later retaining all the current state.
 */

IMC_Unit *
imc_open_unit(Interp *interp /*NN*/, IMC_Unit_Type t)
{
    IMC_Unit * const unit = imc_new_unit(t);
    imc_info_t * const imc_info = IMCC_INFO(interp);

    if (!imc_info->imc_units)
        imc_info->imc_units = unit;
    if (!imc_info->ghash.data)
        create_symhash(&imc_info->ghash);
    unit->prev = imc_info->last_unit;
    if (imc_info->last_unit)
        imc_info->last_unit->next = unit;
    imc_info->last_unit = unit;
    imc_info->n_comp_units++;
    unit->file = imc_info->state->file;
    unit->pasm_file = imc_info->state->pasm_file;

    return unit;
}

/*
 * Close a unit from compilation.
 * Does not destroy the unit, leaves it on the
 * list.
 */
void
imc_close_unit(Interp *interp, IMC_Unit *unit /*NULLOK*/)
{
#if COMPILE_IMMEDIATE
    if (unit) {
        imc_compile_unit(interp, unit);
    }
#endif
    IMCC_INFO(interp)->cur_unit = NULL;
}

static void
imc_free_unit(Interp *interp /*NN*/, IMC_Unit *unit /*NN*/)
{
    imc_info_t * const imc = IMCC_INFO(interp);

#if IMC_TRACE_HIGH
    fprintf(stderr, "imc_free_unit()\n");
#endif

    free_reglist(unit);

    clear_basic_blocks(unit);       /* and cfg ... */
    if (!imc->n_comp_units)
        IMCC_fatal(interp, 1, "imc_free_unit: non existent unit\n");
    imc->n_comp_units--;

    clear_locals(unit);
    free(unit->hash.data);

    free(unit);
}

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
