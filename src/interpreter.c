/* interpreter.c
 *  Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
 *  CVS Info
 *     $Id$
 *  Overview:
 *     The interpreter api handles running the operations
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#include <assert.h>
#include "parrot/parrot.h"
#include "parrot/interp_guts.h"
#include "parrot/oplib/core_ops.h"
#include "parrot/oplib/core_ops_prederef.h"
#include "parrot/oplib/core_ops_switch.h"
#include "parrot/runops_cores.h"
#if JIT_CAPABLE
#  include "parrot/exec.h"
#  include "parrot/jit.h"
#endif
#ifdef HAVE_COMPUTED_GOTO
#  include "parrot/oplib/core_ops_cg.h"
#  include "parrot/oplib/core_ops_cgp.h"
#endif
#include "parrot/method_util.h"

#define ATEXIT_DESTROY

#if EXEC_CAPABLE
struct Parrot_Interp interpre;
#endif

static void setup_default_compreg(Parrot_Interp interpreter);

/*=for api interpreter prederef
 *
 * Predereference the current opcode.
 *
 * The prederef code chunk is pre-initialized with opcode function
 * pointers (or addresses or opnumbers) of the prederef__ opcode.
 * This opcode call the do_prederef function, which fills in the
 * real function (address/op number)
 *
 * Since the prederef__ opcode returns the
 * same pc_prederef it was passed, the runops loop will re-execute
 * the same location, which will then have the pointer to the real
 * prederef opfunc and prederef args.
 *
 * The initial few lines of pointer arithmetic are used to determine
 * the index into the bytecode corresponding to the currect pc_prederef.
 * The bytecode and prederef arrays have the same number of elements
 * since there is a one-to-one mapping.
 */

static void
prederef_args(void **pc_prederef, struct Parrot_Interp *interpreter,
        opcode_t *pc)
{
    op_info_t *opinfo;
    struct PackFile_ConstTable * const_table = interpreter->code->const_table;
    int i;

    opinfo = &interpreter->op_info_table[*pc];
    for (i = 1; i < opinfo->arg_count; i++) {
        opcode_t arg = pc[i];

        switch (opinfo->types[i]) {

        case PARROT_ARG_KI:
        case PARROT_ARG_I:
            if (arg < 0 || arg >= NUM_REGISTERS)
                internal_exception(INTERP_ERROR, "Illegal register number");
            pc_prederef[i] = (void *)&interpreter->int_reg.registers[arg];
            break;

        case PARROT_ARG_N:
            if (arg < 0 || arg >= NUM_REGISTERS)
                internal_exception(INTERP_ERROR, "Illegal register number");
            pc_prederef[i] = (void *)&interpreter->num_reg.registers[arg];
            break;

        case PARROT_ARG_K:
        case PARROT_ARG_P:
            if (arg < 0 || arg >= NUM_REGISTERS)
                internal_exception(INTERP_ERROR, "Illegal register number");
            pc_prederef[i] = (void *)&interpreter->pmc_reg.registers[arg];
            break;

        case PARROT_ARG_S:
            if (arg < 0 || arg >= NUM_REGISTERS)
                internal_exception(INTERP_ERROR, "Illegal register number");
            pc_prederef[i] = (void *)&interpreter->string_reg.registers[arg];
            break;

        case PARROT_ARG_KIC:
        case PARROT_ARG_IC:
            pc_prederef[i] = (void *)&pc[i];
            break;

        case PARROT_ARG_NC:
            if (arg < 0 || arg >= const_table->const_count)
                internal_exception(INTERP_ERROR, "Illegal constant number");
            pc_prederef[i] = (void *) &const_table->constants[arg]->u.number;
            break;

        case PARROT_ARG_PC:
            if (arg < 0 || arg >= const_table->const_count)
                internal_exception(INTERP_ERROR, "Illegal constant number");
/*        pc_prederef[i] = (void *)
                 &const_table->constants[arg]->pmc; */
            internal_exception(ARG_OP_NOT_HANDLED,
                               "PMC constants not yet supported!\n");
            break;

        case PARROT_ARG_SC:
            if (arg < 0 || arg >= const_table->const_count)
                internal_exception(INTERP_ERROR, "Illegal constant number");
            pc_prederef[i] = (void *)
                &const_table->constants[arg]->u.string;
            break;

        case PARROT_ARG_KC:
            if (arg < 0 || arg >= const_table->const_count)
                internal_exception(INTERP_ERROR, "Illegal constant number");
            pc_prederef[i] = (void *)
                &const_table->constants[arg]->u.key;
            break;
        default:
            internal_exception(ARG_OP_NOT_HANDLED,
                               "Unhandled argtype %d\n",opinfo->types[i]);
            break;
        }

        if (pc_prederef[i] == 0) {
            /* switched core has no func_table, so a NULL op is ok */
            internal_exception(INTERP_ERROR,
                    "Prederef generated a NULL pointer for arg of type %d!\n",
                    opinfo->types[i]);
        }
    }
}

/*
 * this is called from inside the run cores
 */
void
do_prederef(void **pc_prederef, Parrot_Interp interpreter, int type)
{
    size_t offset = pc_prederef - interpreter->prederef_code;
    opcode_t *pc = ((opcode_t *)interpreter->code->byte_code) + offset;
    op_func_t *prederef_op_func = interpreter->op_lib->op_func_table;

    if (*pc < 0 || *pc >= (opcode_t)interpreter->op_count)
        internal_exception(INTERP_ERROR, "Illegal opcode");
    switch (type) {
        case PARROT_SWITCH_CORE:
            *pc_prederef = (void**) *pc;
            break;
        case PARROT_PREDEREF_CORE:
        case PARROT_CGP_CORE:
            *pc_prederef = ((void**)(prederef_op_func)) [*pc];
            break;
        default:
            internal_exception(1, "Tried to prederef wrong core");
            break;
    }
    /* and arguments */
    prederef_args(pc_prederef, interpreter, pc);
}

/*=for api interpreter get_op_lib_init
 *
 * return an  opcode's library op_lib init func
 */

static oplib_init_f
get_op_lib_init(int core_op, int which, PMC *lib)
{
    oplib_init_f init_func = (oplib_init_f)NULL;
    if (core_op) {
        switch (which) {
            case PARROT_SWITCH_CORE:
                init_func = PARROT_CORE_SWITCH_OPLIB_INIT;
                break;
            case PARROT_PREDEREF_CORE:
                init_func = PARROT_CORE_PREDEREF_OPLIB_INIT;
                break;
#ifdef HAVE_COMPUTED_GOTO
            case PARROT_CGP_CORE:
                init_func = PARROT_CORE_CGP_OPLIB_INIT;
                break;
            case PARROT_CGOTO_CORE:
                init_func = PARROT_CORE_CG_OPLIB_INIT;
                break;
#endif
            case PARROT_SLOW_CORE:      /* normal func core */
            case PARROT_FAST_CORE:      /* normal func core */
                init_func = PARROT_CORE_OPLIB_INIT;
                break;
        }
        if (!init_func)
            internal_exception(1, "Couldn't find init_func");
        return init_func;
    }
    return lib->cache.struct_val;
}

/*=for api interpreter load_prederef
 *
 * interpreter->op_lib = prederefed oplib
 *
 */
static void
load_prederef(struct Parrot_Interp *interpreter, int which)
{
    oplib_init_f init_func = get_op_lib_init(1, which, NULL);
    int (*get_op)(const char * name, int full);

    get_op = interpreter->op_lib->op_code;
    interpreter->op_lib = init_func(1);
    /* preserve the get_op function */
    interpreter->op_lib->op_code = get_op;
    if (interpreter->op_lib->op_count != interpreter->op_count)
        internal_exception(PREDEREF_LOAD_ERROR,
                "Illegal op count (%d) in prederef oplib\n",
                (int)interpreter->op_lib->op_count);
}

/*=for api interpreter init_prederef
 *
 * initialize: load prederef func_table, file prederef_code
 *
 */
static void
init_prederef(struct Parrot_Interp *interpreter, int which)
{
    load_prederef(interpreter, which);
    if (!interpreter->prederef_code) {
        size_t N = interpreter->code->cur_cs->base.size;
        size_t i;
        void *pred_func;
/* Parrot_memalign_if_possible in OpenBSD allocates 256 if you ask for 312 */
#if 1
        void **temp = (void **)mem_sys_allocate_zeroed(N * sizeof(void *));
#else
        void **temp = (void **)Parrot_memalign_if_possible(256,
                N * sizeof(void *));
#endif

        /* fill with the prederef__ opcode function */
        if (which == PARROT_SWITCH_CORE)
            pred_func = (void*) 6;
        else
            pred_func = ((void **) interpreter->op_lib->op_func_table)[6];
        for (i = 0; i < N; i++) {
            temp[i] = pred_func;
        }

        interpreter->prederef_code = temp;
        interpreter->code->cur_cs->prederef_code = temp;

    }
}

/*=for api interpreter stop_prederef
 *
 * Unload the prederef oplib.
 */

static void
stop_prederef(struct Parrot_Interp *interpreter)
{
    (void) PARROT_CORE_PREDEREF_OPLIB_INIT(0);
}

#if EXEC_CAPABLE
/*=for api interpreter exec_init_prederef
 *
 * interpreter->op_lib = prederefed oplib
 *
 * the "normal" op_lib has a copy in the interpreter structure
 * - but get the op_code lookup function from standard core
 *   prederef has no op_info_table
 */
void
exec_init_prederef(struct Parrot_Interp *interpreter, void *prederef_arena)
{
    load_prederef(interpreter, PARROT_CGP_CORE);

    if (!interpreter->prederef_code) {
        size_t N = interpreter->code->cur_cs->base.size;
        size_t i;
        size_t n;
        void **temp = prederef_arena;
        opcode_t *pc = interpreter->code->cur_cs->base.data;

        interpreter->prederef_code = temp;
        interpreter->code->cur_cs->prederef_code = temp;
        /* TODO */
    }
}
#endif

void *
init_jit(struct Parrot_Interp *interpreter, opcode_t *pc)
{
#if JIT_CAPABLE
    opcode_t *code_start;
    UINTVAL code_size;          /* in opcodes */
    opcode_t *code_end;
    jit_f jit_code;
    if (interpreter->jit_info)
        return (jit_f)D2FPTR(
                ((Parrot_jit_info_t *)interpreter->jit_info)->arena.start);

    code_start = interpreter->code->byte_code;
    code_size = interpreter->code->cur_cs->base.size;
    code_end = interpreter->code->byte_code + code_size;
#  if defined HAVE_COMPUTED_GOTO && defined USE_CGP
#    ifdef __GNUC__
#      ifdef PARROT_I386
    init_prederef(interpreter, PARROT_CGP_CORE);
#      endif
#    endif
#  endif

    jit_code = build_asm(interpreter, pc, code_start, code_end, NULL);
    interpreter->code->cur_cs->jit_info = interpreter->jit_info;
    return jit_code;
#else
    return NULL;
#endif
}

void
prepare_for_run(Parrot_Interp interpreter)
{
    switch (interpreter->run_core) {
        case PARROT_JIT_CORE:
            (void) init_jit(interpreter, interpreter->code->byte_code);
            break;
        case PARROT_PREDEREF_CORE:
        case PARROT_SWITCH_CORE:
        case PARROT_CGP_CORE:
            init_prederef(interpreter, interpreter->run_core);
            break;
        default:
            break;
    }
}

static opcode_t *
runops_jit(struct Parrot_Interp *interpreter, opcode_t *pc)
{
#if JIT_CAPABLE
    jit_f jit_code = init_jit(interpreter, pc);
    (jit_code) (interpreter, pc);
#endif
    return NULL;
}

static opcode_t *
runops_exec(struct Parrot_Interp *interpreter, opcode_t *pc)
{
#if EXEC_CAPABLE
    opcode_t *code_start;
    UINTVAL code_size;          /* in opcodes */
    opcode_t *code_end;
    extern int Parrot_exec_run;

    code_start = interpreter->code->byte_code;
    code_size = interpreter->code->cur_cs->base.size;
    code_end = interpreter->code->byte_code + code_size;
#  if defined HAVE_COMPUTED_GOTO && defined USE_CGP
#    ifdef __GNUC__
#      ifdef PARROT_I386
    init_prederef(interpreter, PARROT_CGP_CORE);
#      endif
#    endif
#  endif
    if (Parrot_exec_run == 2) {
        Parrot_exec_run = 0;
        Interp_core_SET(interpreter, PARROT_JIT_CORE);
        runops_jit(interpreter, pc);
        Interp_core_SET(interpreter, PARROT_EXEC_CORE);
    }
    else if (Parrot_exec_run == 1) {
        Parrot_exec(interpreter, pc, code_start, code_end);
    }
    else
        run_native(interpreter, pc, code_start);

#endif
    return NULL;
}


/*=for api interpreter runops_prederef
 *
 * This runops core is used when we are in prederef mode. It works
 * just like the basic fast core, except it uses pc_prederef instead
 * of pc, and calls prederef opfuncs instead of regular opfuncs.
 *
 * There is code after the main while loop to resynchronize pc with
 * pc_prederef in case we have exited the loop under restart
 * conditions (such as with interpreter flag changing ops).
 *
 * TODO: The calls to init_prederef() and stop_prederef() would be
 * best placed elsewhere, since we would re-pay the costs of loading
 * the prederef oplib every time we dropped out of and back into
 * this core. For now, however, this implementation should do fine.
 * Since dropping out of and back into cores is expected to be rare
 * (at the time of implementation that only occurs for interpreter
 * flag changing ops).
 */
static opcode_t *
runops_prederef(struct Parrot_Interp *interpreter, opcode_t *pc)
{
    opcode_t *code_start = (opcode_t *)interpreter->code->byte_code;
    void **pc_prederef;

    init_prederef(interpreter, PARROT_PREDEREF_CORE);
    pc_prederef = interpreter->prederef_code + (pc - code_start);

    while (pc_prederef) {
        pc_prederef =
            ((op_func_prederef_t)(ptrcast_t)*pc_prederef) (pc_prederef,
                                                           interpreter);
    }

    stop_prederef(interpreter);
    return 0;
}

static opcode_t *
runops_cgp(struct Parrot_Interp *interpreter, opcode_t *pc)
{
#ifdef HAVE_COMPUTED_GOTO
    opcode_t *code_start = (opcode_t *)interpreter->code->byte_code;
    void **pc_prederef;
    init_prederef(interpreter, PARROT_CGP_CORE);
    pc_prederef = interpreter->prederef_code + (pc - code_start);
    pc = cgp_core((opcode_t*)pc_prederef, interpreter);
    return pc;
#else
    PIO_eprintf(interpreter,
            "Computed goto unavailable in this configuration.\n");
    Parrot_exit(1);
    return NULL;
#endif
}

static opcode_t *
runops_switch(struct Parrot_Interp *interpreter, opcode_t *pc)
{
    opcode_t *code_start = (opcode_t *)interpreter->code->byte_code;
    void **pc_prederef;
    init_prederef(interpreter, PARROT_SWITCH_CORE);
    pc_prederef = interpreter->prederef_code + (pc - code_start);
    pc = switch_core((opcode_t*)pc_prederef, interpreter);
    return pc;
}

/*=for api interpreter runops
 * run parrot operations of loaded code segment until an end opcode is reached
 * run core is selected depending on the Interp_flags
 * when a restart opcode is encountered a different core my be selected
 * and evaluation of opcode continues
 */
void
runops_int(struct Parrot_Interp *interpreter, size_t offset)
{
    int lo_var_ptr;
    opcode_t *(*core) (struct Parrot_Interp *, opcode_t *);

    interpreter->resume_offset = offset;
    interpreter->resume_flag = 1;

    while (interpreter->resume_flag & 1) {
        unsigned int slow;
        opcode_t *pc = (opcode_t *)
            interpreter->code->byte_code + interpreter->resume_offset;

        interpreter->lo_var_ptr = (void *)&lo_var_ptr;
        interpreter->resume_offset = 0;
        interpreter->resume_flag = 0;
        switch (interpreter->run_core) {
            case PARROT_SLOW_CORE:

                core = runops_slow_core;

                if (Interp_flags_TEST(interpreter, PARROT_PROFILE_FLAG)) {
                    if (interpreter->profile == NULL) {
                        interpreter->profile = (RunProfile *)
                            mem_sys_allocate(sizeof(RunProfile));
                        interpreter->profile->data = (ProfData *)
                            mem_sys_allocate_zeroed((interpreter->op_count +
                                        PARROT_PROF_EXTRA) * sizeof(ProfData));
                    }
                }
                break;
            case PARROT_FAST_CORE:
                core = runops_fast_core;
                break;
            case PARROT_CGOTO_CORE:
#ifdef HAVE_COMPUTED_GOTO
                /* clear stacktop, it gets set in runops_cgoto_core beyond the
                 * opfunc table again, if the compiler supports nested funcs
                 */
                /* #ifdef HAVE_NESTED_FUNC */
#  ifdef __GNUC__
                interpreter->lo_var_ptr = 0;
#  endif
                core = runops_cgoto_core;
#else
                internal_exception(1, "Error: PARROT_CGOTO_CORE not available");
#endif
                break;
            case PARROT_CGP_CORE:
#ifdef HAVE_COMPUTED_GOTO
                core = runops_cgp;
#else
                internal_exception(1, "Error: PARROT_CGP_CORE not available");
#endif
                break;
            case PARROT_SWITCH_CORE:
                core = runops_switch;
                break;
            case PARROT_PREDEREF_CORE:
                core = runops_prederef;
                break;
            case PARROT_JIT_CORE:
#if !JIT_CAPABLE
                internal_exception(JIT_UNAVAILABLE,
                        "Error: PARROT_JIT_FLAG is set, "
                        "but interpreter is not JIT_CAPABLE!\n");
#endif
                core = runops_jit;
                break;
            case PARROT_EXEC_CORE:
#if !EXEC_CAPABLE
                internal_exception(EXEC_UNAVAILABLE,
                        "Error: PARROT_EXEC_FLAG is set, "
                        "but interpreter is not EXEC_CAPABLE!\n");
#endif
                core = runops_exec;
                break;
        }


        /* run it finally */
        core(interpreter, pc);
        /* if we have fallen out with resume and we were running CGOTO, set
         * the stacktop again to a sane value, so that restarting the runloop
         * is ok.
         */
        interpreter->lo_var_ptr = (void *)&lo_var_ptr;
        if ((interpreter->resume_flag & 1) &&
                (int)interpreter->resume_offset < 0)
                internal_exception(1, "branch_cs: illegal resume offset");
    }
}

static void
runops_ex(struct Parrot_Interp *interpreter, size_t offset)
{
    interpreter->resume_flag = 2;

    while (interpreter->resume_flag & 2) {
        interpreter->resume_flag = 0;
        runops_int(interpreter, offset);

        if (interpreter->resume_flag & 2) {
            /* inter segment jump
             * resume_offset = entry of name in current const_table
             */
            struct PackFile_Constant * c;
            struct PackFile_FixupEntry *fe;
            struct PackFile *pf = interpreter->code;
            char *s;

            if ((int)interpreter->resume_offset >= PF_NCONST(pf) ||
                (int)interpreter->resume_offset < 0)
                internal_exception(1, "branch_cs: illegal resume offset");
            c = PF_CONST(pf, interpreter->resume_offset);
            if (c->type != PFC_STRING)
                internal_exception(1, "branch_cs: not a string\n");
            s = c->u.string->strstart;
            fe = PackFile_find_fixup_entry(interpreter, enum_fixup_label, s);
            if (!fe)
                internal_exception(1, "branch_cs: fixup not found\n");
            offset = fe->offset;
            Parrot_switch_to_cs(interpreter, fe->seg);
            if (Interp_flags_TEST(interpreter, PARROT_TRACE_FLAG)) {
                PIO_eprintf(interpreter, "*** Resume at seg %s ofs %d\n",
                        fe->seg->base.name, (int)offset);
            }
        }
    }
}

#ifdef PARROT_HAS_HEADER_SETJMP
/* XXX s. exception.c */
extern Parrot_exception the_exception;
#endif
void
runops(struct Parrot_Interp *interpreter, size_t offset)
{
#ifdef PARROT_HAS_HEADER_SETJMP
    if (setjmp(the_exception.destination)) {
        /* an exception was thrown */
        offset = handle_exception(interpreter);
    }
    if (interpreter->profile &&
            interpreter->cur_pc == (opcode_t*)&interpreter->op_count &&
            Interp_flags_TEST(interpreter, PARROT_PROFILE_FLAG)) {
        interpreter->profile->data[*interpreter->cur_pc].time +=
            Parrot_floatval_time() - interpreter->profile->starttime;
    }
#endif
    runops_ex(interpreter, offset);
    /*
     * not yet - this needs classifying of exceptions and handlers
     * so that only an exit handler does catch this exception
     */
#if 0
    do_exception(EXCEPT_exit, 0);
#endif
}

static int
is_env_var_set(const char* var)
{
    int free_it, retval;
    char* value = Parrot_getenv(var, &free_it);
    if (value == NULL)
        retval = 0;
    else if (*value == '\0')
        retval = 0;
    else
        retval = ! (strcmp(value, "0") == 0);
    if (free_it)
        mem_sys_free(value);
    return retval;
}

void Parrot_really_destroy(int exit_code, void *interpreter);

/*=for api interpreter make_interpreter
 *  Create the Parrot interpreter.  Allocate memory and clear the registers.
 */

struct Parrot_Interp *
make_interpreter(Interp_flags flags)
{
    struct Parrot_Interp *interpreter;
#if EXEC_CAPABLE
    extern int Parrot_exec_run;
#endif

    /* Get an empty interpreter from system memory */
#if EXEC_CAPABLE
    if (Parrot_exec_run)
        interpreter = &interpre;
    else
#endif
        interpreter = mem_sys_allocate_zeroed(sizeof(struct Parrot_Interp));

    /* must be set after if this is not the first interpreter */
    SET_NULL(interpreter->parent_interpreter);

    interpreter->DOD_block_level = 1;
    interpreter->GC_block_level = 1;

    /* Must initialize flags here so the GC_DEBUG stuff is available before
     * mem_setup_allocator() is called. */
    interpreter->flags = flags;

    /* PANIC will fail until this is done */
    SET_NULL(interpreter->piodata);
    PIO_init(interpreter);

    if (is_env_var_set("PARROT_GC_DEBUG")) {
#if ! DISABLE_GC_DEBUG
        Interp_flags_SET(interpreter, PARROT_GC_DEBUG_FLAG);
#else
        fprintf(stderr, "PARROT_GC_DEBUG is set but the binary was compiled "
                "with DISABLE_GC_DEBUG.\n");
#endif
    }

    /* Set up the memory allocation system */
    mem_setup_allocator(interpreter);

    /* Set up the MMD struct */
    interpreter->binop_mmd_funcs =
        mem_sys_allocate_zeroed(sizeof(struct MMD_table));

    /* Go and init the MMD tables */
    register_fallback_methods(interpreter);

    /* initialize classes - this needs mmd func table */
    Parrot_init(interpreter);

    /* Need an empty stash */
    interpreter->perl_stash = mem_sys_allocate(sizeof(struct Stash));
    interpreter->perl_stash->stash_hash =
        pmc_new(interpreter, enum_class_PerlHash);
    interpreter->perl_stash->parent_stash = NULL;

    /* context data */
    /* Initialize interpreter's flags */
    interpreter->ctx.warns = new_buffer_header(interpreter);
    Parrot_allocate(interpreter, interpreter->ctx.warns,
        sizeof(struct warnings_t));
    PARROT_WARNINGS_off(interpreter, PARROT_WARNINGS_ALL_FLAG);

    /* Set up the initial register chunks */
    interpreter->ctx.int_reg_top =
        mem_sys_allocate_zeroed(sizeof(struct IRegChunk));
    interpreter->ctx.num_reg_top =
        mem_sys_allocate_zeroed(sizeof(struct NRegChunk));
    interpreter->ctx.string_reg_top =
        mem_sys_allocate_zeroed(sizeof(struct SRegChunk));
    interpreter->ctx.pmc_reg_top =
        mem_sys_allocate_zeroed(sizeof(struct PRegChunk));

    /* the SET_NULL macros are only for systems where a NULL pointer
     * isn't represented by zeroes, so don't use these for resetting
     * non-null pointers
     */
    SET_NULL(interpreter->ctx.int_reg_top->next);
    SET_NULL(interpreter->ctx.int_reg_top->prev);
    SET_NULL(interpreter->ctx.num_reg_top->next);
    SET_NULL(interpreter->ctx.num_reg_top->prev);
    SET_NULL(interpreter->ctx.string_reg_top->next);
    SET_NULL(interpreter->ctx.string_reg_top->prev);
    SET_NULL(interpreter->ctx.pmc_reg_top->next);
    SET_NULL(interpreter->ctx.pmc_reg_top->prev);

    Parrot_clear_s(interpreter);
    Parrot_clear_p(interpreter);

    stack_system_init(interpreter);
    /* Stack for lexical pads */
    interpreter->ctx.pad_stack = new_stack(interpreter, "Pad");

    /* Need a user stack */
    interpreter->ctx.user_stack = new_stack(interpreter, "User");

    /* And a control stack */
    interpreter->ctx.control_stack = new_stack(interpreter, "Control");

    /* A regex stack would be nice too. */
    interpreter->ctx.intstack = intstack_new(interpreter);

    /* Load the core op func and info tables */
    interpreter->op_lib = get_op_lib_init(1, 0, NULL)(1);
    interpreter->op_count = interpreter->op_lib->op_count;
    interpreter->op_func_table = interpreter->op_lib->op_func_table;
    interpreter->op_info_table = interpreter->op_lib->op_info_table;
    SET_NULL_P(interpreter->all_op_libs, op_lib_t **);

    /* Set up defaults for line/package/file */
    interpreter->current_file =
        string_make(interpreter, "(unknown file)", 14, NULL, 0, NULL);
    interpreter->current_package =
        string_make(interpreter, "(unknown package)", 18, NULL, 0, NULL);;

    SET_NULL_P(interpreter->code, struct PackFile *);
    SET_NULL_P(interpreter->profile, ProfData *);

    /* next two are pointers to the real thing in the current code seg */
    SET_NULL_P(interpreter->prederef_code, void **);
    SET_NULL(interpreter->jit_info);

    /* register assembler/compilers */
    setup_default_compreg(interpreter);

    /* setup stdio PMCs */
    PIO_init(interpreter);
    /* Done. Return and be done with it */

    /* Add in the class hash. Bit of a hack, probably, as there's
       altogether too much overlap with the PMC classes */
    interpreter->class_hash = pmc_new(interpreter, enum_class_PerlHash);

    /* Okay, we've finished doing anything that might trigger GC.
     * Actually, we could enable DOD/GC earlier, but here all setup is
     * done
     */
    Parrot_unblock_DOD(interpreter);
    Parrot_unblock_GC(interpreter);

    /* all sys running, init the signal stuff */
    Parrot_init_signals();

#ifdef ATEXIT_DESTROY
    Parrot_on_exit(Parrot_really_destroy, (void*)interpreter);
#endif

    return interpreter;
}
void
Parrot_destroy(struct Parrot_Interp *interpreter)
{
#ifdef ATEXIT_DESTROY
    UNUSED(interpreter);
#else
    Parrot_really_destroy(0, (void*) interpreter);
#endif
}

void
Parrot_really_destroy(int exit_code, void *vinterp)
{
    int i;
    Interp *interpreter = (Interp*) vinterp;
    struct Stash *stash, *next_stash;

    UNUSED(exit_code);
    /* if something needs destruction (e.g. closing PIOs)
     * we must destroy it now:
     * no DOD run, so everything is considered dead
     */

    /* XXX boe: This hack explicitly marks the piodata, these filehandles
     *          need to be open until PIO_finish is called
     */
    Parrot_IOData_mark(interpreter, interpreter->piodata);

    free_unused_pobjects(interpreter, interpreter->arena_base->pmc_pool);

    /* Now the PIOData gets also cleared */
    PIO_finish(interpreter);

    /* we destroy all child interpreters and the last one too,
     * if the --leak-test commandline was given
     */
    if (! (interpreter->parent_interpreter ||
                Interp_flags_TEST(interpreter, PARROT_DESTROY_FLAG)))
        return;

    /* buffer headers, PMCs */
    Parrot_destroy_header_pools(interpreter);
    /* memory pools in resources */
    Parrot_destroy_memory_pools(interpreter);
    /* mem subsystem is dead now */
    mem_sys_free(interpreter->arena_base);
    /* packfile */

    if (!Interp_flags_TEST(interpreter, PARROT_EXTERN_CODE_FLAG))  {
        struct PackFile *pf = interpreter->code;
        if (pf)
            PackFile_destroy(pf);
    }

    /* walk and free the stash, pmc's are already dead */
    stash = interpreter->perl_stash;
    while (stash) {
        next_stash = stash->parent_stash;
        mem_sys_free(stash);
        stash = next_stash;
    }
    /* free vtables */
    for (i = 1; i < (int)enum_class_max; i++)
        Parrot_destroy_vtable(interpreter, Parrot_base_vtables[i]);

    if (interpreter->profile)
        mem_sys_free(interpreter->profile);

    /* deinit op_lib */
    (void) PARROT_CORE_OPLIB_INIT(0);

    /* XXX move this to register.c */
    {
        struct IRegChunk *stacks[4];
        struct IRegChunk *top, *next;
        stacks[0] = interpreter->ctx.int_reg_top;
        stacks[1] = (struct IRegChunk*) interpreter->ctx.num_reg_top;
        stacks[2] = (struct IRegChunk*) interpreter->ctx.string_reg_top;
        stacks[3] = (struct IRegChunk*) interpreter->ctx.pmc_reg_top;
        for (i = 0; i< 4; i++) {
            top = stacks[i];
            for (; top ; ) {
                next = top->next;
                mem_sys_free(top);
                top = next;
            }
        }
    }

    stack_destroy(interpreter->ctx.pad_stack);
    stack_destroy(interpreter->ctx.user_stack);
    stack_destroy(interpreter->ctx.control_stack);
    /* intstack */
    intstack_free(interpreter, interpreter->ctx.intstack);

    /* chartype, encodings */
    chartype_destroy();
    encoding_destroy();

    mem_sys_free(interpreter);
}

#ifdef GC_IS_MALLOC
#  if 0
struct mallinfo {
    int arena;                  /* non-mmapped space allocated from system */
    int ordblks;                /* number of free chunks */
    int smblks;                 /* number of fastbin blocks */
    int hblks;                  /* number of mmapped regions */
    int hblkhd;                 /* space in mmapped regions */
    int usmblks;                /* maximum total allocated space */
    int fsmblks;                /* space available in freed fastbin blocks */
    int uordblks;               /* total allocated space */
    int fordblks;               /* total free space */
    int keepcost;               /* top-most, releasable (via malloc_trim)
                                 * space */
};
#  endif
extern struct mallinfo mallinfo(void);
#endif /* GC_IS_MALLOC */
INTVAL
interpinfo(struct Parrot_Interp *interpreter, INTVAL what)
{
    INTVAL ret = 0;
    struct Small_Object_Pool *header_pool;
    int j;

    switch (what) {
        case TOTAL_MEM_ALLOC:
#ifdef GC_IS_MALLOC
#if 0
            interpreter->memory_allocated = mallinfo().uordblks;
#endif
#endif
            ret = interpreter->memory_allocated;
            break;
        case DOD_RUNS:
            ret = interpreter->dod_runs;
            break;
        case COLLECT_RUNS:
            ret = interpreter->collect_runs;
            break;
        case ACTIVE_PMCS:
            ret = interpreter->arena_base->pmc_pool->total_objects -
                interpreter->arena_base->pmc_pool->num_free_objects;
            break;
        case ACTIVE_BUFFERS:
            ret = 0;
            for (j = 0; j < (INTVAL)interpreter->arena_base->num_sized; j++) {
                header_pool = interpreter->arena_base->sized_header_pools[j];
                if (header_pool)
                    ret += header_pool->total_objects -
                        header_pool->num_free_objects;
            }
            break;
        case TOTAL_PMCS:
            ret = interpreter->arena_base->pmc_pool->total_objects;
            break;
        case TOTAL_BUFFERS:
            ret = 0;
            for (j = 0; j < (INTVAL)interpreter->arena_base->num_sized; j++) {
                header_pool = interpreter->arena_base->sized_header_pools[j];
                if (header_pool)
                    ret += header_pool->total_objects;
            }
            break;
        case HEADER_ALLOCS_SINCE_COLLECT:
            ret = interpreter->header_allocs_since_last_collect;
            break;
        case MEM_ALLOCS_SINCE_COLLECT:
            ret = interpreter->mem_allocs_since_last_collect;
            break;
        case TOTAL_COPIED:
            ret = interpreter->memory_collected;
            break;
    }
    return ret;
}

/*=for api interpreter Parrot_compreg
 * register a parser/compiler function
 */

void Parrot_compreg(Parrot_Interp interpreter, STRING *type, PMC *func)
{
    PMC* key, *hash, *nci;
    PMC* iglobals = interpreter->iglobals;
    hash = VTABLE_get_pmc_keyed_int(interpreter, interpreter->iglobals,
            IGLOBALS_COMPREG_HASH);
    if (!hash) {
        hash = pmc_new_noinit(interpreter, enum_class_PerlHash);
        VTABLE_init(interpreter, hash);
        VTABLE_set_pmc_keyed_int(interpreter, iglobals,
                (INTVAL)IGLOBALS_COMPREG_HASH, hash);
    }
    nci = pmc_new(interpreter, enum_class_Compiler);
    key = key_new_string(interpreter, type);
    VTABLE_set_pmc_keyed(interpreter, hash, key, nci);
    /* build native call interface fir the C sub in "func" */
    VTABLE_set_string_keyed(interpreter, nci, func,
            string_from_cstring(interpreter, "pIt", 0));
}


static void setup_default_compreg(Parrot_Interp interpreter)
{
    STRING *pasm1 = string_from_cstring(interpreter, "PASM1", 0);

    Parrot_csub_t p = (Parrot_csub_t) PDB_compile;
    /* register the nci ccompiler object */
    Parrot_compreg(interpreter, pasm1, (PMC*)F2DPTR(p));
}

INTVAL
sysinfo_i(Parrot_Interp interpreter, INTVAL info_wanted)
{
    switch (info_wanted) {
    case PARROT_INTSIZE:
        return sizeof(INTVAL);
    case PARROT_FLOATSIZE:
        return sizeof(FLOATVAL);
    case PARROT_POINTERSIZE:
        return sizeof(void *);
    default:
        return -1;
    }
}

STRING *
sysinfo_s(Parrot_Interp interpreter, INTVAL info_wanted)
{
    switch (info_wanted) {
    case PARROT_OS:
        return string_from_cstring(interpreter, BUILD_OS_NAME, 0);
    case PARROT_OS_VERSION:
    case PARROT_OS_VERSION_NUMBER:
    case CPU_ARCH:
    case CPU_TYPE:
    default:
        return string_from_cstring(interpreter, "", 0);
    }
}

/*
 * dynamic loading stuff
 */
#if defined HAVE_COMPUTED_GOTO
static void dynop_register_cg(Parrot_Interp, PMC*, op_lib_t *, op_lib_t *);
#endif

/*=for api interpreter dynop_register
 *
 * register a dynamic oplib
 */

void
dynop_register(Parrot_Interp interpreter, PMC* lib_pmc)
{
    op_lib_t *lib, *core;
    oplib_init_f init_func;
    op_func_t *new_func_table;
    op_info_t *new_info_table;
    size_t i, n_old, n_new;

    interpreter->all_op_libs = mem_sys_realloc(interpreter->all_op_libs,
            sizeof(op_lib_t *) * (interpreter->n_libs + 1));

    init_func = get_op_lib_init(0, 0, lib_pmc);
    lib = init_func(1);

    interpreter->all_op_libs[interpreter->n_libs++] = lib;
    n_old = interpreter->op_count;
    n_new = lib->op_count;

    /*
     * allocate new op_func and info tables
     */
    new_func_table = mem_sys_allocate(sizeof (void *) * (n_old + n_new));
    new_info_table = mem_sys_allocate(sizeof (op_info_t) * (n_old + n_new));
    /* copy old */
    for (i = 0; i < n_old; ++i) {
        new_func_table[i] = interpreter->op_func_table[i];
        new_info_table[i] = interpreter->op_info_table[i];
    }
    /* add new */
    for (i = n_old; i < n_old + n_new; ++i) {
        new_func_table[i] = ((op_func_t*)lib->op_func_table)[i - n_old];
        new_info_table[i] = lib->op_info_table[i - n_old];
    }
    core = PARROT_CORE_OPLIB_INIT(1);
    /*
     * deinit core, so that it gets rehashed
     */
    (void) PARROT_CORE_OPLIB_INIT(0);
    /* set table */
    core->op_func_table = interpreter->op_func_table = new_func_table;
    core->op_info_table = interpreter->op_info_table = new_info_table;
    core->op_count = interpreter->op_count = n_old + n_new;
    /* done for plain core */
#if defined HAVE_COMPUTED_GOTO
    dynop_register_cg(interpreter, lib_pmc, lib, core);
#endif
}

#if defined HAVE_COMPUTED_GOTO
/*
 * register op_lib with CGOTO core
 */
static void
dynop_register_cg(Parrot_Interp interpreter, PMC* lib_pmc,
        op_lib_t *lib, op_lib_t *core)
{
    op_lib_t *cg_lib;
    void **ops_addr;
    size_t i, n_old, n_new;

    n_new = lib->op_count;
    n_old = core->op_count;

    cg_lib = PARROT_CORE_CG_OPLIB_INIT(1);
    /* TODO check if the lib_pmc exists with a _cg flavor */

    /* if not install wrappers */
    ops_addr = mem_sys_allocate(n_old * sizeof(void *));
    n_old -= n_new;
    for (i = 0; i < n_old; ++i)
        ops_addr[i] = ((void **)cg_lib->op_func_table)[i];
    /* fill new entries with the wrapper op */
    for (i = n_old; i < n_old + n_new; ++i)
        ops_addr[i] = ((void **)cg_lib->op_func_table)[5];
    /*
     * tell the cg_core about the new jump table
     */
    PARROT_CORE_CG_OPLIB_INIT((int) ops_addr);
}
#endif

/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
*/
