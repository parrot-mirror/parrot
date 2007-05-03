/*
Copyright (C) 2001-2006, The Perl Foundation.
$Id$

=head1 NAME

src/interpreter.c - Parrot Interpreter

=head1 DESCRIPTION

The interpreter API handles running the operations.

The predereferenced code chunk is pre-initialized with the opcode
function pointers, addresses, or opnumbers of the C<prederef__>
opcode. This opcode then calls the C<do_prederef()> function, which then
fills in the real function, address or op number.

Because the C<prederef__> opcode returns the same C<pc_prederef> it was
passed, the runops loop will re-execute the same location, which will
then have the pointer to the real C<prederef> opfunc and C<prederef>
args.

Pointer arithmetic is used to determine the index into the bytecode
corresponding to the currect opcode. The bytecode and prederef arrays
have the same number of elements because there is a one-to-one mapping.

=head2 Functions

=over 4

=cut

*/

#include <assert.h>
#include "parrot/parrot.h"
#include "interp_guts.h"
#include "parrot/oplib/core_ops.h"
#include "parrot/oplib/core_ops_switch.h"
#include "parrot/oplib/ops.h"
#include "runops_cores.h"
#if JIT_CAPABLE
#  include "parrot/exec.h"
#  include "jit.h"
#endif
#ifdef HAVE_COMPUTED_GOTO
#  include "parrot/oplib/core_ops_cg.h"
#  include "parrot/oplib/core_ops_cgp.h"
#endif
#include "parrot/dynext.h"


void Parrot_setup_event_func_ptrs(Parrot_Interp interp);

/*

=item C<static void
prederef_args(void **pc_prederef, Interp *interp,
        opcode_t *pc, op_info_t *opinfo)>

Called from C<do_prederef()> to deal with any arguments.

C<pc_prederef> is the current opcode.

=cut

*/

static void
prederef_args(void **pc_prederef, Interp *interp,
        opcode_t *pc, op_info_t *opinfo)
{
    PackFile_ConstTable * const_table = interp->code->const_table;
    int i, n, m, regs_n, regs_i, regs_p, regs_s;
    PMC *sig = NULL;

    regs_n = CONTEXT(interp->ctx)->n_regs_used[REGNO_NUM];
    regs_i = CONTEXT(interp->ctx)->n_regs_used[REGNO_INT];
    regs_p = CONTEXT(interp->ctx)->n_regs_used[REGNO_PMC];
    regs_s = CONTEXT(interp->ctx)->n_regs_used[REGNO_STR];
    /* prederef var part too */
    n = m = opinfo->op_count;
    ADD_OP_VAR_PART(interp, interp->code, pc, n);
    for (i = 1; i < n; i++) {
        opcode_t arg = pc[i];
        int type;
        if (i >= m) {
            sig = (PMC*) pc_prederef[1];
            type = SIG_ITEM(sig, i - m);
            type &= (PARROT_ARG_TYPE_MASK | PARROT_ARG_CONSTANT);
        }
        else
            type = opinfo->types[i - 1];

        switch (type) {

        case PARROT_ARG_KI:
        case PARROT_ARG_I:
            if (arg < 0 || arg >= regs_i)
                internal_exception(INTERP_ERROR, "Illegal register number");
            pc_prederef[i] = (void *)REG_OFFS_INT(arg);
            break;

        case PARROT_ARG_N:
            if (arg < 0 || arg >= regs_n)
                internal_exception(INTERP_ERROR, "Illegal register number");
            pc_prederef[i] = (void *)REG_OFFS_NUM(arg);
            break;

        case PARROT_ARG_K:
        case PARROT_ARG_P:
            if (arg < 0 || arg >= regs_p)
                internal_exception(INTERP_ERROR, "Illegal register number");
            pc_prederef[i] = (void *)REG_OFFS_PMC(arg);
            break;

        case PARROT_ARG_S:
            if (arg < 0 || arg >= regs_s)
                internal_exception(INTERP_ERROR, "Illegal register number");
            pc_prederef[i] = (void *)REG_OFFS_STR(arg);
            break;

        case PARROT_ARG_KIC:
        case PARROT_ARG_IC:
            pc_prederef[i] = (void *)pc[i];
            break;

        case PARROT_ARG_NC:
            if (arg < 0 || arg >= const_table->const_count)
                internal_exception(INTERP_ERROR, "Illegal constant number");
            pc_prederef[i] = (void *) &const_table->constants[arg]->u.number;
            break;

        case PARROT_ARG_SC:
            if (arg < 0 || arg >= const_table->const_count)
                internal_exception(INTERP_ERROR, "Illegal constant number");
            pc_prederef[i] = (void *)const_table->constants[arg]->u.string;
            break;

        case PARROT_ARG_PC:
        case PARROT_ARG_KC:
            if (arg < 0 || arg >= const_table->const_count)
                internal_exception(INTERP_ERROR, "Illegal constant number");
            pc_prederef[i] = (void *)const_table->constants[arg]->u.key;
            break;
        default:
            internal_exception(ARG_OP_NOT_HANDLED,
                               "Unhandled argtype 0x%x\n", type);
            break;
        }
    }
}

/*

=item C<void
do_prederef(void **pc_prederef, Parrot_Interp interp, int type)>

This is called from within the run cores to predereference the current
opcode.

C<pc_prederef> is the current opcode, and C<type> is the run core type.

=cut

*/

void
do_prederef(void **pc_prederef, Parrot_Interp interp, int type)
{
    size_t offset = pc_prederef - interp->code->prederef.code;
    opcode_t *pc = ((opcode_t *)interp->code->base.data) + offset;
    op_func_t *prederef_op_func = interp->op_lib->op_func_table;
    op_info_t *opinfo;
    size_t n;

    if (*pc < 0 || *pc >= (opcode_t)interp->op_count)
        internal_exception(INTERP_ERROR, "Illegal opcode");
    opinfo = &interp->op_info_table[*pc];
    /* first arguments - PIC needs it */
    prederef_args(pc_prederef, interp, pc, opinfo);
    switch (type) {
        case PARROT_SWITCH_CORE:
        case PARROT_SWITCH_JIT_CORE:
        case PARROT_CGP_CORE:
        case PARROT_CGP_JIT_CORE:
            parrot_PIC_prederef(interp, *pc, pc_prederef, type);
            break;
        default:
            internal_exception(1, "Tried to prederef wrong core");
            break;
    }
    /*
     * now remember backward branches, invoke and similar opcodes
     */
    n = opinfo->op_count;
    if (((opinfo->jump & PARROT_JUMP_RELATIVE) &&
            opinfo->types[n - 2] == PARROT_ARG_IC &&
            pc[n - 1] < 0) ||   /* relative backward branch */
            (opinfo->jump & PARROT_JUMP_ADDRESS)) {
        Prederef *pi = &interp->code->prederef;
        /*
         * first time prederef.branches == NULL:
         * estimate size to 1/16th of opcodes
         */
        if (!pi->branches) {
            size_t nb = interp->code->base.size / 16;
            if (nb < 8)
                nb = (size_t)8;
            pi->branches = (Prederef_branch *)mem_sys_allocate(
                               sizeof (Prederef_branch) * nb);
            pi->n_allocated = nb;
            pi->n_branches = 0;
        }
        else if (pi->n_branches >= pi->n_allocated) {
            pi->n_allocated = (size_t) (pi->n_allocated * 1.5);
            pi->branches = (Prederef_branch *)mem_sys_realloc(pi->branches,
                    sizeof (Prederef_branch) * pi->n_allocated);
        }
        pi->branches[pi->n_branches].offs = offset;
        pi->branches[pi->n_branches].op = *pc_prederef;
        ++pi->n_branches;
    }
}

/*

=item C<static void
turn_ev_check(Parrot_Interp interp, int on)>

Turn on or off event checking for prederefed cores.

Fills in the C<event_checker> opcode, or restores original ops in all
branch locations of the opcode stream.

Note that when C<on> is true, this is being called from the event
handler thread.

=cut

*/

static void
turn_ev_check(Parrot_Interp interp, int on)
{
    Prederef *pi = &interp->code->prederef;
    size_t i, offs;

    if (!pi->branches)
        return;
    for (i = 0; i < pi->n_branches; ++i) {
        offs = pi->branches[i].offs;
        if (on) {
            interp->code->prederef.code[offs] =
                ((void **)interp->op_lib->op_func_table)
                            [CORE_OPS_check_events__];
        }
        else
            interp->code->prederef.code[offs] = pi->branches[i].op;
    }
}

/*

=item C<static oplib_init_f
get_op_lib_init(int core_op, int which, PMC *lib)>

Returns an opcode's library C<op_lib> init function.

C<core_op> indicates whether the opcode represents a core Parrot operation.

C<which> is the run core type.

For dynamic oplibs C<core_op> will be 0 and C<lib> will be a
C<ParrotLibrary> PMC.

=cut

*/

static oplib_init_f
get_op_lib_init(int core_op, int which, PMC *lib)
{
    oplib_init_f init_func = (oplib_init_f)NULL;
    if (core_op) {
        switch (which) {
            case PARROT_SWITCH_CORE:
            case PARROT_SWITCH_JIT_CORE:
                init_func = PARROT_CORE_SWITCH_OPLIB_INIT;
                break;
#ifdef HAVE_COMPUTED_GOTO
            case PARROT_CGP_CORE:
            case PARROT_CGP_JIT_CORE:
                init_func = PARROT_CORE_CGP_OPLIB_INIT;
                break;
            case PARROT_CGOTO_CORE:
                init_func = PARROT_CORE_CG_OPLIB_INIT;
                break;
#endif
            case PARROT_EXEC_CORE:      /* normal func core */
            case PARROT_JIT_CORE:      /* normal func core */
            case PARROT_SLOW_CORE:      /* normal func core */
            case PARROT_FAST_CORE:      /* normal func core */
                init_func = PARROT_CORE_OPLIB_INIT;
                break;
        }
        if (!init_func)
            internal_exception(1, "Couldn't find init_func for core %d", which);
        return init_func;
    }
    return (oplib_init_f) D2FPTR(PMC_struct_val(lib));
}

/*

=item C<static void
load_prederef(Interp *interp, int which)>

C<< interp->op_lib >> = prederefed oplib.

=cut

*/

static void
load_prederef(Interp *interp, int which)
{
    oplib_init_f init_func = get_op_lib_init(1, which, NULL);
    int (*get_op)(const char * name, int full);

    get_op = interp->op_lib->op_code;
    interp->op_lib = init_func(1);
    /* preserve the get_op function */
    interp->op_lib->op_code = get_op;
    if (interp->op_lib->op_count != interp->op_count)
        internal_exception(PREDEREF_LOAD_ERROR,
                "Illegal op count (%d) in prederef oplib\n",
                (int)interp->op_lib->op_count);
}

/*

=item C<static void
init_prederef(Interp *interp, int which)>

Initialize: load prederef C<func_table>, file prederef.code.

=cut

*/

static void
init_prederef(Interp *interp, int which)
{
    load_prederef(interp, which);
    if (!interp->code->prederef.code) {
        size_t N = interp->code->base.size;
        opcode_t *pc = interp->code->base.data;
        size_t i, n, n_pics;
        void *pred_func;
        op_info_t *opinfo;
/* Parrot_memalign_if_possible in OpenBSD allocates 256 if you ask for 312
   -- Need to verify this, it may have been a bug elsewhere. If it works now,
   we can remove the mem_sys_allocate_zeroed line below. */
#if 0
        void **temp = (void **)mem_sys_allocate_zeroed(N * sizeof (void *));
#else
        void **temp = (void **)Parrot_memalign_if_possible(256,
                N * sizeof (void *));
#endif
        /*
         * calc and remember pred_offset
         */
        CONTEXT(interp->ctx)->pred_offset = pc - (opcode_t*)temp;

        /* fill with the prederef__ opcode function */
        if (which == PARROT_SWITCH_CORE || which == PARROT_SWITCH_JIT_CORE)
            pred_func = (void*) CORE_OPS_prederef__;
        else
            pred_func = ((void **)
                    interp->op_lib->op_func_table)[CORE_OPS_prederef__];
        for (i = n_pics = 0; i < N;) {
            opinfo = &interp->op_info_table[*pc];
            temp[i] = pred_func;
            n = opinfo->op_count;
            ADD_OP_VAR_PART(interp, interp->code, pc, n);
            /* count ops that need a PIC */
            if (parrot_PIC_op_is_cached(interp, *pc))
                n_pics++;
            pc += n;
            i += n;
        }

        interp->code->prederef.code = temp;
        /* allocate pic store */
        if (n_pics) {
            /* pic_index is starting from 1 */
            parrot_PIC_alloc_store(interp, interp->code, n_pics + 1);
        }
    }
}

/*

=item C<static void
stop_prederef(Interp *interp)>

Restore the interpreter's op function tables to their initial state.
Also recreate the event function pointers. This is only necessary
for run-core changes, but we don't know the old run core.

=cut

*/

static void
stop_prederef(Interp *interp)
{
    interp->op_func_table = PARROT_CORE_OPLIB_INIT(1)->op_func_table;
    if (interp->evc_func_table) {
        mem_sys_free(interp->evc_func_table);
        interp->evc_func_table = NULL;
    }
    Parrot_setup_event_func_ptrs(interp);
}

#if EXEC_CAPABLE

/*

=item C<void
exec_init_prederef(Interp *interp, void *prederef_arena)>

C<< interp->op_lib >> = prederefed oplib

The "normal" C<op_lib> has a copy in the interpreter structure - but get
the C<op_code> lookup function from standard core prederef has no
C<op_info_table>

=cut

*/

void
exec_init_prederef(Interp *interp, void *prederef_arena)
{
    load_prederef(interp, PARROT_CGP_CORE);

    if (!interp->code->prederef.code) {
        size_t N = interp->code->base.size;
        void **temp = (void **)prederef_arena;
        opcode_t *pc = interp->code->base.data;

        interp->code->prederef.code = temp;
        /* TODO */
    }
}
#endif

/*

=item C<void *
init_jit(Interp *interp, opcode_t *pc)>

Initializes JIT function for the specified opcode and returns it.

=cut

*/

void *
init_jit(Interp *interp, opcode_t *pc)
{
#if JIT_CAPABLE
    opcode_t *code_start;
    UINTVAL code_size;          /* in opcodes */
    opcode_t *code_end;
    Parrot_jit_info_t *jit_info;

    if (interp->code->jit_info)
        return ((Parrot_jit_info_t *)interp->code->jit_info)->arena.start;

    code_start = interp->code->base.data;
    code_size = interp->code->base.size;
    code_end = code_start + code_size;
#  if defined HAVE_COMPUTED_GOTO && PARROT_I386_JIT_CGP
#    ifdef __GNUC__
#      ifdef PARROT_I386
    init_prederef(interp, PARROT_CGP_CORE);
#      endif
#    endif
#  endif

    interp->code->jit_info =
        jit_info = parrot_build_asm(interp, code_start, code_end,
            NULL, JIT_CODE_FILE);
    return jit_info->arena.start;
#else
    return NULL;
#endif
}

/*

=item C<void
prepare_for_run(Parrot_Interp interp)>

Prepares to run the interpreter's run core.

=cut

*/

void
prepare_for_run(Parrot_Interp interp)
{
    switch (interp->run_core) {
        case PARROT_JIT_CORE:
            (void) init_jit(interp, interp->code->base.data);
            break;
        case PARROT_SWITCH_CORE:
        case PARROT_SWITCH_JIT_CORE:
        case PARROT_CGP_CORE:
        case PARROT_CGP_JIT_CORE:
            init_prederef(interp, interp->run_core);
            break;
        default:
            break;
    }
}

#ifdef PARROT_EXEC_OS_AIX
extern void* aix_get_toc();
#endif

/*

=item C<static opcode_t *
runops_jit(Interp *interp, opcode_t *pc)>

Runs the JIT code for the specified opcode.

=cut

*/

static opcode_t *
runops_jit(Interp *interp, opcode_t *pc)
{
#if JIT_CAPABLE
#  ifdef PARROT_EXEC_OS_AIX
    /* AIX calling convention requires that function-call-by-ptr be made
       through the following struct: */
    struct ptrgl_t { jit_f functPtr; void *toc; void *env; } ptrgl_t;
    ptrgl_t.functPtr = (jit_f) D2FPTR(init_jit(interp, pc));
    ptrgl_t.env = NULL;

    /* r2 (TOC) needs to point back here so we can return from non-JIT
       functions */
    ptrgl_t.toc = aix_get_toc();

    ((jit_f) D2FPTR(&ptrgl_t)) (interp, pc);
#  else
    jit_f jit_code = (jit_f) D2FPTR(init_jit(interp, pc));
    (jit_code) (interp, pc);
#  endif
#endif
    return NULL;
}

/*

=item C<static opcode_t *
runops_exec(Interp *interp, opcode_t *pc)>

Runs the native executable version of the specified opcode.

=cut

*/

static opcode_t *
runops_exec(Interp *interp, opcode_t *pc)
{
#if EXEC_CAPABLE
    opcode_t *code_start;
    UINTVAL code_size;          /* in opcodes */
    opcode_t *code_end;
    extern int Parrot_exec_run;

    code_start = interp->code->base.data;
    code_size = interp->code->base.size;
    code_end = code_start + code_size;
#  if defined HAVE_COMPUTED_GOTO && defined USE_CGP
#    ifdef __GNUC__
#      ifdef PARROT_I386
    init_prederef(interp, PARROT_CGP_CORE);
#      endif
#    endif
#  endif
    if (Parrot_exec_run == 2) {
        Parrot_exec_run = 0;
        Interp_core_SET(interp, PARROT_JIT_CORE);
        runops_jit(interp, pc);
        Interp_core_SET(interp, PARROT_EXEC_CORE);
    }
    else if (Parrot_exec_run == 1) {
        Parrot_exec(interp, pc, code_start, code_end);
    }
    else
        run_native(interp, pc, code_start);

#endif
    return NULL;
}


/*

=item C<static opcode_t *
runops_cgp(Interp *interp, opcode_t *pc)>

Runs the C C<goto>, predereferenced core.

=cut

*/

static opcode_t *
runops_cgp(Interp *interp, opcode_t *pc)
{
#ifdef HAVE_COMPUTED_GOTO
    opcode_t *code_start = (opcode_t *)interp->code->base.data;
    void **pc_prederef;
    init_prederef(interp, PARROT_CGP_CORE);
    pc_prederef = interp->code->prederef.code + (pc - code_start);
    pc = (opcode_t*) cgp_core(pc_prederef, interp);
    return pc;
#else
    PIO_eprintf(interp,
            "Computed goto unavailable in this configuration.\n");
    Parrot_exit(interp, 1);
    return NULL;
#endif
}

/*

=item C<static opcode_t *
runops_switch(Interp *interp, opcode_t *pc)>

Runs the C<switch> core.

=cut

*/

static opcode_t *
runops_switch(Interp *interp, opcode_t *pc)
{
    opcode_t *code_start = (opcode_t *)interp->code->base.data;
    void **pc_prederef;
    init_prederef(interp, PARROT_SWITCH_CORE);
    pc_prederef = interp->code->prederef.code + (pc - code_start);
    pc = (opcode_t*) switch_core(pc_prederef, interp);
    return pc;
}

/*

=item C<void
runops_int(Interp *interp, size_t offset)>

Run Parrot operations of loaded code segment until an end opcode is
reached.  Run core is selected depending on the C<Interp_flags>.  When a
C<restart> opcode is encountered, a different core may be selected and
evaluation of opcode continues.

=cut

*/

void
runops_int(Interp *interp, size_t offset)
{
    int lo_var_ptr;
    opcode_t *(*core) (Interp *, opcode_t *) =
        (opcode_t *(*) (Interp *, opcode_t *)) 0;

    if (!interp->lo_var_ptr) {
        /*
         * if we are entering the run loop the first time
         */
        interp->lo_var_ptr = (void *)&lo_var_ptr;
    }

    /*
     * setup event function ptrs
     */
    if (!interp->save_func_table) {
        Parrot_setup_event_func_ptrs(interp);
    }

    interp->resume_offset = offset;
    interp->resume_flag |= RESUME_RESTART;

    while (interp->resume_flag & RESUME_RESTART) {
        opcode_t *pc = (opcode_t *)
            interp->code->base.data + interp->resume_offset;

        interp->resume_offset = 0;
        interp->resume_flag &= ~(RESUME_RESTART | RESUME_INITIAL);
        switch (interp->run_core) {
            case PARROT_SLOW_CORE:

                core = runops_slow_core;

                if (Interp_flags_TEST(interp, PARROT_PROFILE_FLAG)) {
                    core = runops_profile_core;
                    if (interp->profile == NULL) {
                        interp->profile = (RunProfile *)
                            mem_sys_allocate_zeroed(sizeof (RunProfile));
                        interp->profile->data = (ProfData *)
                            mem_sys_allocate_zeroed((interp->op_count +
                                        PARROT_PROF_EXTRA) * sizeof (ProfData));
                    }
                }
                break;
            case PARROT_FAST_CORE:
                core = runops_fast_core;
                break;
            case PARROT_CGOTO_CORE:
#ifdef HAVE_COMPUTED_GOTO
                core = runops_cgoto_core;
#else
                internal_exception(1, "Error: PARROT_CGOTO_CORE not available");
#endif
                break;
            case PARROT_CGP_CORE:
            case PARROT_CGP_JIT_CORE:
#ifdef HAVE_COMPUTED_GOTO
                core = runops_cgp;
#else
                internal_exception(1, "Error: PARROT_CGP_CORE not available");
#endif
                break;
            case PARROT_SWITCH_CORE:
            case PARROT_SWITCH_JIT_CORE:
                core = runops_switch;
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
            default:
                internal_exception(UNIMPLEMENTED,
                        "ambigious runcore switch used");
                break;
        }


        /* run it finally */
        core(interp, pc);
        /* if we have fallen out with resume and we were running CGOTO, set
         * the stacktop again to a sane value, so that restarting the runloop
         * is ok.
         */
        if (interp->resume_flag & RESUME_RESTART) {
            if ((int)interp->resume_offset < 0)
                internal_exception(1, "branch_cs: illegal resume offset");
            stop_prederef(interp);
        }
    }
}



/*

=item C<static void
Parrot_setup_event_func_ptrs(Parrot_Interp interp)>

Setup a C<func_table> containing pointers (or addresses) of the
C<check_event__> opcode.

TODO: Free it at destroy. Handle run-core changes.

=cut

*/

void
Parrot_setup_event_func_ptrs(Parrot_Interp interp)
{
    size_t i, n = interp->op_count;
    oplib_init_f init_func = get_op_lib_init(1, interp->run_core, NULL);
    op_lib_t *lib = init_func(1);
    /*
     * remember op_func_table
     */
    interp->save_func_table = lib->op_func_table;
    if (!lib->op_func_table)
        return;
    /* function or CG core - prepare func_table */
    if (!interp->evc_func_table) {
        interp->evc_func_table = (op_func_t *)mem_sys_allocate(
                                     sizeof (op_func_t) * n);
        for (i = 0; i < n; ++i)
            interp->evc_func_table[i] = (op_func_t)
                D2FPTR(((void**)lib->op_func_table)[CORE_OPS_check_events__]);
    }
}


/*

=back

=head2 Dynamic Loading Functions

=over 4

=cut

*/

static void dynop_register_xx(Parrot_Interp, PMC*, size_t, size_t,
        oplib_init_f init_func);
static void dynop_register_switch(Parrot_Interp, PMC*, size_t, size_t);

/*

=item C<void
dynop_register(Parrot_Interp interp, PMC* lib_pmc)>

Register a dynamic oplib.

=cut

*/

void
dynop_register(Parrot_Interp interp, PMC* lib_pmc)
{
    op_lib_t *lib, *core;
    oplib_init_f init_func;
    op_func_t *new_func_table, *new_evc_func_table;
    op_info_t *new_info_table;
    size_t i, n_old, n_new, n_tot;

    if (n_interpreters > 1) {
        /* This is not supported because oplibs are always shared.
         * If we mem_sys_reallocate() the op_func_table while another
         * interpreter is running using that exact op_func_table,
         * this will cause problems
         * Also, the mapping from op name to op number is global even for
         * dynops (!). The mapping is done by get_op in core_ops.c (even for
         * dynops) and uses a global hash as a cache and relies on modifications
         * to the static-scoped core_op_lib data structure to see dynops.
         */
        internal_exception(1, "loading a new dynoplib while more than "
            "one thread is running is not supported.");
    }

    if (!interp->all_op_libs)
        interp->all_op_libs = (op_lib_t **)mem_sys_allocate(
                sizeof (op_lib_t *) * (interp->n_libs + 1));
    else
        interp->all_op_libs = (op_lib_t **)mem_sys_realloc(interp->all_op_libs,
                sizeof (op_lib_t *) * (interp->n_libs + 1));

    init_func = get_op_lib_init(0, 0, lib_pmc);
    lib = init_func(1);

    interp->all_op_libs[interp->n_libs++] = lib;
    /*
     * if we are registering an op_lib variant, called from below
     * the base names of this lib and the previous one are the same
     */
    if (interp->n_libs >= 2 &&
            !strcmp(interp->all_op_libs[interp->n_libs-2]->name,
                lib->name)) {
        /* registering is handled below */
        return;
    }
    /*
     * when called from yyparse, we have to set up the evc_func_table
     */
    Parrot_setup_event_func_ptrs(interp);

    n_old = interp->op_count;
    n_new = lib->op_count;
    n_tot = n_old + n_new;
    core = PARROT_CORE_OPLIB_INIT(1);

    assert(interp->op_count == core->op_count);
    new_evc_func_table = (op_func_t *)mem__sys_realloc(interp->evc_func_table,
            sizeof (op_func_t) * n_tot);
    if (core->flags & OP_FUNC_IS_ALLOCATED) {
        new_func_table = (op_func_t *)mem_sys_realloc(core->op_func_table,
                sizeof (op_func_t) * n_tot);
        new_info_table = (op_info_t *)mem_sys_realloc(core->op_info_table,
                sizeof (op_info_t) * n_tot);
    }
    else {
        /*
         * allocate new op_func and info tables
         */
        new_func_table = (op_func_t *)mem_sys_allocate(sizeof (op_func_t) * n_tot);
        new_info_table = (op_info_t *)mem_sys_allocate(sizeof (op_info_t) * n_tot);
        /* copy old */
        for (i = 0; i < n_old; ++i) {
            new_func_table[i] = interp->op_func_table[i];
            new_info_table[i] = interp->op_info_table[i];
        }
    }
    /* add new */
    for (i = n_old; i < n_tot; ++i) {
        new_func_table[i] = ((op_func_t*)lib->op_func_table)[i - n_old];
        new_info_table[i] = lib->op_info_table[i - n_old];
        /*
         * fill new ops of event checker func table
         * if we are running a different core, entries are
         * changed below
         */
        new_evc_func_table[i] =
            interp->op_func_table[CORE_OPS_check_events__];
    }
    interp->evc_func_table = new_evc_func_table;
    interp->save_func_table = new_func_table;
    /*
     * deinit core, so that it gets rehashed
     */
    (void) PARROT_CORE_OPLIB_INIT(0);
    /* set table */
    core->op_func_table = interp->op_func_table = new_func_table;
    core->op_info_table = interp->op_info_table = new_info_table;
    core->op_count = interp->op_count = n_tot;
    core->flags = OP_FUNC_IS_ALLOCATED | OP_INFO_IS_ALLOCATED;
    /* done for plain core */
#if defined HAVE_COMPUTED_GOTO
    dynop_register_xx(interp, lib_pmc, n_old, n_new,
            PARROT_CORE_CGP_OPLIB_INIT);
    dynop_register_xx(interp, lib_pmc, n_old, n_new,
            PARROT_CORE_CG_OPLIB_INIT);
#endif
    dynop_register_switch(interp, lib_pmc, n_old, n_new);
}

/*

=item C<static void
dynop_register_xx(Parrot_Interp interp, PMC* lib_pmc,
        size_t n_old, size_t n_new, oplib_init_f init_func)>

Register C<op_lib> with other cores.

=cut

*/

static void
dynop_register_xx(Parrot_Interp interp, PMC* lib_pmc,
        size_t n_old, size_t n_new, oplib_init_f init_func)
{
    op_lib_t *cg_lib, *new_lib;
    op_func_t *ops_addr = NULL;
    size_t i, n_tot;
#if 0
    /* related to CG and CGP ops issue below */
    STRING *op_variant;
#endif
    oplib_init_f new_init_func;
    PMC *lib_variant;

    n_tot = n_old + n_new;
    cg_lib = init_func(1);

    if (cg_lib->flags & OP_FUNC_IS_ALLOCATED) {
        ops_addr = (op_func_t *)mem_sys_realloc(cg_lib->op_func_table,
                n_tot * sizeof (op_func_t));
    }
    else {
        ops_addr = (op_func_t *)mem_sys_allocate(n_tot * sizeof (op_func_t));
        cg_lib->flags = OP_FUNC_IS_ALLOCATED;
        for (i = 0; i < n_old; ++i)
            ops_addr[i] = cg_lib->op_func_table[i];
    }
    /*
     * XXX running CG and CGP ops currently works only via the wrapper
     *
     * the problem is:
     *  The actual runcores cg_core and cgp_core are very big functions.
     *  The C compiler usually addresses "spilled" registers in the C stack.
     *  The loaded opcode lib is another possibly big function, but with
     *  a likely different stack layout. Directly jumping around between
     *  code locations in these two opcode functions works, but access
     *  to stack-ed (or spilled) variables fails badly.
     *
     *  We would need to prepare the assembly source of the opcode
     *  lib so that all variable access on the stack has the same
     *  layout and compile the prepared assembly to ops_cgp?.o
     *
     *  The switched core is different anyway, as we can't extend the
     *  compiled big switch statement with the new cases. We have
     *  always to use the wrapper__ opcode called from the default case.
     */
#if 0
    /* check if the lib_pmc exists with a _xx flavor */
    new_init_func = get_op_lib_init(0, 0, lib_pmc);
    new_lib = new_init_func(1);
    op_variant = Parrot_sprintf_c(interp, "%s_ops%s",
            new_lib->name, cg_lib->suffix);
    lib_variant = Parrot_load_lib(interp, op_variant, NULL);
#endif
    /*
     * XXX running CG and CGP ops currently works only via the wrapper
     */
    if (0 /*lib_variant */) {
        new_init_func = get_op_lib_init(0, 0, lib_variant);
        new_lib = new_init_func(1);
        for (i = n_old; i < n_tot; ++i)
            ops_addr[i] = (new_lib->op_func_table)[i - n_old];
        new_lib->op_func_table = ops_addr;
        new_lib->op_count = n_tot;
        new_init_func((long) ops_addr);
    }
    else {
        /* if not install wrappers */
        /* fill new entries with the wrapper op */
        for (i = n_old; i < n_tot; ++i)
            ops_addr[i] = (cg_lib->op_func_table)[CORE_OPS_wrapper__];
    }
    /*
     * if we are running this core, update event check ops
     */
    if ((int)interp->run_core == cg_lib->core_type) {
        for (i = n_old; i < n_tot; ++i)
            interp->evc_func_table[i] =
                (op_func_t)ops_addr[CORE_OPS_check_events__];
        interp->save_func_table = ops_addr;
    }
    /*
     * tell the cg_core about the new jump table
     */
    cg_lib->op_func_table = ops_addr;
    cg_lib->op_count = n_tot;
    init_func((long) ops_addr);
}

/*

=item C<static void
dynop_register_switch(Parrot_Interp interp, PMC* lib_pmc,
        size_t n_old, size_t n_new)>

Description.

=cut

*/

static void
dynop_register_switch(Parrot_Interp interp, PMC* lib_pmc,
        size_t n_old, size_t n_new)
{
    op_lib_t *lib = PARROT_CORE_SWITCH_OPLIB_INIT(1);
    lib->op_count = n_old + n_new;
}

/*

=item C<static void
notify_func_table(Parrot_Interp interp, op_func_t* table, int on)>

Tell the interpreter's running core about the new function table.

=cut

*/

static void
notify_func_table(Parrot_Interp interp, op_func_t* table, int on)
{
    oplib_init_f init_func = get_op_lib_init(1, interp->run_core, NULL);
    op_lib_t *lib = init_func(1);
    init_func((long) table);
    switch (interp->run_core) {
        case PARROT_SLOW_CORE:      /* normal func core */
        case PARROT_FAST_CORE:      /* normal func core */
        case PARROT_CGOTO_CORE:      /* cgoto address list  */
            assert(table);
            interp->op_func_table = table;
            break;
        case PARROT_CGP_CORE:
        case PARROT_CGP_JIT_CORE:
            turn_ev_check(interp, on);
            break;
        default:
            break;
    }
}

/*

=item C<void
disable_event_checking(Parrot_Interp interp)>

Restore old function table.

XXX This is only implemented for the function core at present.

=cut

*/

void
disable_event_checking(Parrot_Interp interp)
{
    /*
     * restore func table
     */
    assert(interp->save_func_table);
    notify_func_table(interp, interp->save_func_table, 0);
}

/*

=item C<void
enable_event_checking(Parrot_Interp interp)>

Replace func table with one that does event checking for all opcodes.

NOTE: C<enable_event_checking()> is called async by the event handler
thread. All action done from here has to be async safe.

XXX This is only implemented for the function core at present.

=cut

*/

void
enable_event_checking(Parrot_Interp interp)
{
    /*
     * put table in place
     */
    notify_func_table(interp, interp->evc_func_table, 1);
}


/*

=back

=head1 SEE ALSO

F<include/parrot/interpreter.h>, F<src/inter_cb.c>, F<src/inter_create.c>,
 F<src/inter_misc.c>, F<src/inter_run.c>.

=cut

*/


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
