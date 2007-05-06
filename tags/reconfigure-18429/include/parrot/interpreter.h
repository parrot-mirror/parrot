/* interpreter.h
 *  Copyright (C) 2001-2006, The Perl Foundation.
 *  SVN Info
 *     $Id$
 *  Overview:
 *     The interpreter api handles running the operations
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#ifndef PARROT_INTERPRETER_H_GUARD
#define PARROT_INTERPRETER_H_GUARD

/* These should be visible to embedders. */

/* General flags */
/* &gen_from_enum(interpflags.pasm) */
typedef enum {
    PARROT_NO_FLAGS         = 0x00,
    PARROT_BOUNDS_FLAG      = 0x04,  /* We're tracking byte code bounds */
    PARROT_PROFILE_FLAG     = 0x08,  /* gathering profile information */
    PARROT_GC_DEBUG_FLAG    = 0x10,  /* debugging memory management */

    PARROT_EXTERN_CODE_FLAG = 0x100, /* reusing another interp's code */
    PARROT_DESTROY_FLAG     = 0x200, /* the last interpreter shall cleanup */

    PARROT_IS_THREAD        = 0x1000, /* interpreter is a thread */
    PARROT_THR_COPY_INTERP  = 0x2000, /* thread start copies interp state */
    PARROT_THR_THREAD_POOL  = 0x4000, /* type3 threads */

    PARROT_THR_TYPE_1       = PARROT_IS_THREAD,
    PARROT_THR_TYPE_2       = PARROT_IS_THREAD | PARROT_THR_COPY_INTERP,
    PARROT_THR_TYPE_3       = PARROT_IS_THREAD | PARROT_THR_COPY_INTERP |
                              PARROT_THR_THREAD_POOL

} Parrot_Interp_flag;
/* &end_gen */

/* &gen_from_enum(interpdebug.pasm) */
typedef enum {
    PARROT_NO_DEBUG                 = 0x00,
    PARROT_MEM_STAT_DEBUG_FLAG      = 0x01,  /* memory usage summary */
    PARROT_BACKTRACE_DEBUG_FLAG     = 0x02,  /* print bt in exception */
    PARROT_JIT_DEBUG_FLAG           = 0x04,  /* create jit stabs file */
    PARROT_START_DEBUG_FLAG         = 0x08,
    PARROT_THREAD_DEBUG_FLAG        = 0x10,
    PARROT_EVAL_DEBUG_FLAG          = 0x20,  /* create EVAL_n file */
    PARROT_REG_DEBUG_FLAG           = 0x40,  /* fill I,N with garbage */
    PARROT_CTX_DESTROY_DEBUG_FLAG   = 0x80,  /* ctx of a sub is gone */
    PARROT_ALL_DEBUG_FLAGS          = 0xffff
} Parrot_debug_flags;
/* &end_gen */

/* &gen_from_enum(interptrace.pasm) */
typedef enum {
    PARROT_NO_TRACE                 = 0x00,
    PARROT_TRACE_OPS_FLAG           = 0x01,  /* op execution trace */
    PARROT_TRACE_FIND_METH_FLAG     = 0x02,  /* find_method */
    PARROT_TRACE_SUB_CALL_FLAG      = 0x04,  /* invoke/retcc */
    PARROT_ALL_TRACE_FLAGS          = 0xffff
} Parrot_trace_flags;
/* &end_gen */

/* &gen_from_enum(interpcores.pasm) */
typedef enum {
    PARROT_SLOW_CORE,                         /* slow bounds/trace/profile core */
    PARROT_FUNCTION_CORE = PARROT_SLOW_CORE,
    PARROT_FAST_CORE      = 0x01,             /* fast DO_OP core */
    PARROT_SWITCH_CORE    = 0x02,             /*   P   = prederef   */
    PARROT_CGP_CORE       = 0x06,             /*  CP                */
    PARROT_CGOTO_CORE     = 0x04,             /*  C    = cgoto      */
    PARROT_JIT_CORE       = 0x10,             /* J     = JIT        */
    PARROT_CGP_JIT_CORE   = 0x16,             /* JCP                */
    PARROT_SWITCH_JIT_CORE  = 0x12,           /* J P                */
    PARROT_EXEC_CORE      = 0x20          /* TODO Parrot_exec_run variants */
} Parrot_Run_core_t;
/* &end_gen */

/* &gen_from_enum(cloneflags.pasm) */
typedef enum {
    PARROT_CLONE_CODE = 0x1,        /* active code segments
                                     * XXX interaction with lexicals
                                     */
    PARROT_CLONE_GLOBALS = 0x2,     /* global stash */
    PARROT_CLONE_RUNOPS = 0x4,      /* runops choice */
    PARROT_CLONE_INTERP_FLAGS = 0x8,/* bounds checking and
                                     * debugging flags */
    PARROT_CLONE_HLL = 0x10,        /* clone HLL setting */
    PARROT_CLONE_CLASSES = 0x20,    /* clone usermade classes */
    PARROT_CLONE_LIBRARIES = 0x40,  /* clone loaded library set */
    /* flags that won't be initially implemented */
    PARROT_CLONE_CC = 0x80,         /* clone current continuation --
                                     * fork()-like cloning (requires
                                     * cloned code segments); probably
                                     * would only work if runloop_level is 1
                                     */

    /* combinations of flags */
    PARROT_CLONE_DEFAULT = 0x7f /* everything but CC */
} Parrot_clone_flags;
/* &end_gen */

struct parrot_interp_t;

#if defined(PARROT_IN_CORE)

#define Parrot_String   STRING *
#define Parrot_PMC      PMC *
#define Parrot_Language Parrot_Int
#define Parrot_Vtable struct _vtable*

typedef struct parrot_interp_t *Parrot_Interp;

typedef Parrot_Interp_flag Interp_flags;
typedef Parrot_Run_core_t Run_Cores;

#define Interp_flags_SET(interp, flag)   ((interp)->flags |= (flag))
#define Interp_flags_CLEAR(interp, flag) ((interp)->flags &= ~(flag))
#define Interp_flags_TEST(interp, flag)  ((interp)->flags & (flag))

#define Interp_debug_SET(interp, flag)   ((interp)->debug_flags |= (flag))
#define Interp_debug_CLEAR(interp, flag) ((interp)->debug_flags &= ~(flag))
#define Interp_debug_TEST(interp, flag)  ((interp)->debug_flags & (flag))

#define Interp_trace_SET(interp, flag)   (CONTEXT((interp)->ctx)->trace_flags |= (flag))
#define Interp_trace_CLEAR(interp, flag) (CONTEXT((interp)->ctx)->trace_flags &= ~(flag))
#define Interp_trace_TEST(interp, flag)  (CONTEXT((interp)->ctx)->trace_flags & (flag))

#define Interp_core_SET(interp, core)   ((interp)->run_core = (core))
#define Interp_core_TEST(interp, core)  ((interp)->run_core == (core))

#include "parrot/register.h"
#include "parrot/parrot.h"
#include "parrot/warnings.h"

#include "parrot/op.h"
#include "parrot/oplib.h"

#include "parrot/debug.h"
#include "parrot/mmd.h"

typedef struct warnings_t {
    Warnings_classes classes;
} *Warnings;

/*
 * ProfData have these extra items in front followed by
 * one entry per op at (op + extra)
 */

typedef enum {
     PARROT_PROF_DOD_p1,        /* pass 1 mark root set */
     PARROT_PROF_DOD_p2,        /* pass 2 mark next_for_GC */
     PARROT_PROF_DOD_cp,        /* collect PMCs */
     PARROT_PROF_DOD_cb,        /* collect buffers */
     /* DOD must be 0..3 */
     PARROT_PROF_GC,
     PARROT_PROF_EXCEPTION,
     PARROT_PROF_EXTRA
} profile_extra_enum;

/*
 * data[op_count] is time spent for exception handling
 */
typedef struct ProfData {
    int op;
    UINTVAL numcalls;
    FLOATVAL time;
} ProfData;

typedef struct _RunProfile {
    FLOATVAL starttime;
    FLOATVAL dod_time;
    opcode_t cur_op;
    ProfData *data;
} RunProfile;

/* Forward declaration for imc_info_t -- the actual struct is
 * defined in imcc/imc.h
 */
struct _imc_info_t;

typedef union {
    PMC         **regs_p;
    STRING      **regs_s;
} Regs_ps;

typedef union {
    FLOATVAL     *regs_n;
    INTVAL       *regs_i;
} Regs_ni;

/* If CTX_LEAK_DEBUG is enabled, then turning on PARROT_CTX_DESTROY_DEBUG_FLAG
   will print tons of detail about when Parrot_Context structures are allocated
   and deallocated to stderr.  If CTX_LEAK_DEBUG is disabled, then all of the
   relevant code is omitted, and PARROT_CTX_DESTROY_DEBUG_FLAG has no effect.
 */
#define CTX_LEAK_DEBUG 1

typedef struct Parrot_Context {
    /* common header with Interp_Context */
    struct Parrot_Context *caller_ctx;  /* caller context */
    Regs_ni                bp;          /* pointers to FLOATVAL & INTVAL */
    Regs_ps                bp_ps;       /* pointers to PMC & STR */
    /* end common header */
    INTVAL *n_regs_used;                /* INSP in PBC points to Sub */
    size_t regs_mem_size;               /* memory occupied by registers */
    int ref_count;                      /* how often refered to */
    struct Stack_Chunk *reg_stack;      /* register stack */

    struct Stack_Chunk *user_stack;     /* Base of the scratch stack */
    PMC      *lex_pad;                  /* LexPad PMC */
    struct Parrot_Context *outer_ctx;   /* outer context, if a closure */
    UINTVAL warns;             /* Keeps track of what warnings
                                * have been activated */
    UINTVAL errors;            /* fatals that can be turned off */
    UINTVAL trace_flags;
    UINTVAL recursion_depth;    /* Sub call recursion depth */
    /*
     * new call scheme and introspective variables
     */
    PMC *current_sub;           /* the Sub we are executing */
    /*
     * for now use a return continuation PMC
     */
    PMC *current_cont;          /* the return continuation PMC */
    PMC *current_object;        /* current object if a method call */
    opcode_t *current_pc;       /* program counter of Sub invocation */
    PMC *current_namespace;     /* The namespace we're currently in */
    INTVAL current_HLL;         /* see also src/hll.c */
    opcode_t *current_results;  /* ptr into code with get_results opcode */
    PMC *results_signature;     /* results signature pmc if it is non-const */
    /* deref the constants - we need it all the time */
    struct PackFile_Constant ** constants;
    /* code->prederefed.code - code->base.data in opcodes
     * to simplify conversio between code ptrs in e.g. invoke
     */
    size_t pred_offset;
} parrot_context_t;

struct _Thread_data;    /* in thread.h */
struct _Caches;         /* caches .h */

typedef struct _Prederef_branch {       /* item for recording branches */
    size_t offs;                        /* offset in code */
    void  *op;                          /* opcode at that position */
} Prederef_branch;

typedef struct _Prederef {
    void **code;                        /* prederefed code */
    Prederef_branch *branches;          /* list of branches in code */
    size_t n_branches;                  /* entries in that list */
    size_t n_allocated;                 /* allocated size of it */
} Prederef;


/*
 * This is an 'inlined' copy of the first 3 Context items for
 * faster access of registers mainly
 * During a context switch a 3 pointers are set
 */
struct Interp_Context {
    /* common header */
    struct Parrot_Context *state;       /* context  */
    Regs_ni                bp;          /* pointers to FLOATVAL & INTVAL */
    Regs_ps                bp_ps;       /* pointers to PMC & STR */
    /* end common header */
};

#define CONTEXT(ctx) ((ctx).state)

#define CHUNKED_CTX_MEM 0           /* no longer works, but will be reinstated
                                     * some day; see src/register.c for details.
                                    */

typedef struct _context_mem {
#if CHUNKED_CTX_MEM
    char *data;                     /* ctx + register store */
    char *free;                     /* free to allocate */
    char *threshold;                /* continuation threshold */
    struct _context_mem *prev;      /* previous allocated area */
#else
    void **free_list;               /* per size free slots */
    int n_free_slots;               /* amount of allocated */
#endif

} context_mem;

struct _handler_node_t; /* forward def - exit.h */
/*
 * The actual interpreter structure
 */
struct parrot_interp_t {
    struct Interp_Context ctx;
    context_mem ctx_mem;                      /* ctx memory managment */

    struct Arenas *arena_base;                /* Pointer to this interpreter's
                                               * arena */

    PMC *class_hash;                          /* Hash of classes */
    VTABLE **vtables;                         /* array of vtable ptrs */
    int    n_vtable_max;                      /* highest used type */
    int    n_vtable_alloced;                  /* alloced vtable space */

    struct _ParrotIOData *piodata;            /* interpreter's IO system */

    op_lib_t  *op_lib;                        /* Opcode library */
    size_t     op_count;                      /* The number of ops */
    op_info_t *op_info_table;                 /* Opcode info table (name, nargs, arg types) */

    op_func_t *op_func_table;                 /* opcode dispatch table (functios, labels,
                                               * or nothing (e.g. switched core), which
                                               * the interpreter is currently running */
    op_func_t *evc_func_table;                /* opcode dispatch for event checking */
    op_func_t *save_func_table;               /* for restoring op_func_table */

    int         n_libs;                       /* count of libs below */
    op_lib_t  **all_op_libs;                  /* all loaded opcode libraries */

    INTVAL flags;                             /* Various interpreter flags that
                                               * signal that runops should do
                                               * something */

    UINTVAL debug_flags;                      /* debug settings */

    INTVAL run_core;                          /* type of core to run the ops */

    /* TODO profile per code segment or global */
    RunProfile *profile;                      /* The structure and array where we keep the
                                               * profile counters */

    INTVAL resume_flag;
    size_t resume_offset;

    struct PackFile_ByteCode *code;           /* The code we are executing */
    struct PackFile *initial_pf;              /* first created PF  */

    struct _imc_info_t *imc_info;             /* imcc data */

    const char* output_file;                  /* The file into which output is written */

    PDB_t *pdb;                               /* Debug system */
    Interp * debugger;                        /* trace / debug interpreter */

    struct Stack_Chunk *dynamic_env;          /* current dynamic environment */

    void *lo_var_ptr;                         /* Pointer to memory on runops system stack */

    Interp * parent_interpreter;

    /* per interpreter global vars */
    INTVAL world_inited;                      /* Parrot_init is done */

    PMC *iglobals;                            /* SArray of PMCs, containing: */
    /* 0:   PMC *Parrot_base_classname_hash; hash containing name->base_type */
    /* 1:   PMC *Parrot_compreg_hash;    hash containing assembler/compilers */
    /* 2:   PMC *Argv;                   list of argv */
    /* 3:   PMC *NCI func hash           hash of NCI funcs */
    /* 4:   PMC *ParrotInterpreter       that's me */
    /* 5:   PMC *Dyn_libs        Array of dynamically loaded ParrotLibrary  */
    /* 6:   PMC *Config_Hash             Hash of config settings  */
    /* 7:   PMC *Lib_Paths               LoL of search paths  */
    /* 8:   PMC *PBC_Libs                Hash of load_bytecode cde */
    /* 9:   PMC *Executable              String PMC with name from argv[0]. */

    PMC* DOD_registry;                        /* registered PMCs added to the root set */

    PMC* HLL_info;                            /* storage for HLL names and types */
    PMC* HLL_namespace;                       /* cache of HLL toplevel ns */

    PMC *root_namespace;                      /* namespace hash */

    MMD_table *binop_mmd_funcs;               /* Table of MMD functions */
    UINTVAL n_binop_mmd_funcs;                /* function count */

    struct _Caches * caches;                  /* s. caches.h */

    STRING **const_cstring_table;             /* CONST_STRING(x) items */

    struct QUEUE* task_queue;                 /* per interpreter queue */
    struct _handler_node_t *exit_handler_list;   /* exit.c */
    int sleeping;                             /* used during sleep in events */

    struct parrot_exception_t *exceptions;    /* internal exception stack */
    struct parrot_exception_t *exc_free_list; /* and free list */
    PMC ** exception_list;                    /* precreated exception objects */

    int current_runloop_level;                /* for reentering run loop */
    int current_runloop_id;

    struct _Thread_data *thread_data;         /* thread specific items */

    UINTVAL recursion_limit;                  /* Sub call resursion limit */

    UINTVAL gc_generation;                    /* GC generation number */

    opcode_t *current_args;                   /* ptr into code with set_args opcode */
    opcode_t *current_params;                 /* ptr into code with get_params opcode */
    opcode_t *current_returns;                /* ptr into code with get_returns opcode */
    PMC *args_signature;                      /* args signature pmc if it is non-const */
    PMC *params_signature;                    /* params signature pmc if it is non-const */
    PMC *returns_signature;                   /* returns signature pmc if it is non-const */
    /* during a call sequencer the caller fills these objects
     * inside the invoke these get moved to the context structure
     */
    PMC *current_cont;                        /* the return continuation PMC */
    PMC *current_object;                      /* current object if a method call */
};

/* typedef struct parrot_interp_t Interp;    done in parrot.h so that
                                             interpreter.h's prereq headers can
                                             use 'Interp' */

typedef enum {
    RESUME_NONE         = 0x00,
    RESUME_RESTART      = 0x01,
    RESUME_ISJ          = 0x02,
    RESUME_INITIAL      = 0x04
} resume_flag_enum;

/* &gen_from_enum(iglobals.pasm) */
typedef enum {
    IGLOBALS_CLASSNAME_HASH,
    IGLOBALS_COMPREG_HASH,
    IGLOBALS_ARGV_LIST,
    IGLOBALS_NCI_FUNCS,
    IGLOBALS_INTERPRETER,       /* this interpreter as ParrotInterpreter PMC */
    IGLOBALS_DYN_LIBS,          /* Hash of ParrotLibrary loaded dynamic ext */
    IGLOBALS_CONFIG_HASH,
    IGLOBALS_LIB_PATHS,         /* LoL of search paths and dynamic ext */
    IGLOBALS_PBC_LIBS,          /* Hash of load_bytecode cde */
    IGLOBALS_EXECUTABLE,        /* How Parrot was invoked (from argv[0]) */

    IGLOBALS_SIZE
} iglobals_enum;
/* &end_gen */

#define PCONST(i) PF_CONST(interp->code, (i))
#define PNCONST   PF_NCONST(interp->code)

/* TODO - Make this a config option */
#define PARROT_CATCH_NULL 1

#if PARROT_CATCH_NULL
PARROT_API extern PMC * PMCNULL;   /* Holds single Null PMC */
#  define PMC_IS_NULL(p)  ((p) == PMCNULL || (p) == NULL)
#else
#  define PMCNULL         ((PMC *)NULL)
#  define PMC_IS_NULL(p)  ((p) == PMCNULL)
#endif /* PARROT_CATCH_NULL */


#define STRING_IS_NULL(s) ((s) == NULL)
#define STRING_IS_EMPTY(s) !(int)(s)->strlen

/* &gen_from_def(sysinfo.pasm) prefix(SYSINFO_) */

#define PARROT_INTSIZE               1
#define PARROT_FLOATSIZE             2
#define PARROT_POINTERSIZE           3
#define PARROT_OS                    4
#define PARROT_OS_VERSION            5
#define PARROT_OS_VERSION_NUMBER     6
#define CPU_ARCH                     7
#define CPU_TYPE                     8

/* &end_gen */

PARROT_API Interp *make_interpreter(Interp * parent, INTVAL);
PARROT_API void Parrot_init(Interp *);
PARROT_API void Parrot_destroy(Interp *);

PARROT_API void Parrot_set_config_hash_internal(const unsigned char*, unsigned int);

PARROT_API INTVAL interpinfo(Interp *interp, INTVAL what);
PARROT_API PMC*   interpinfo_p(Interp *interp, INTVAL what);
PARROT_API STRING*interpinfo_s(Interp *interp, INTVAL what);

void runops(Interp *, size_t offset);
void runops_int(Interp *, size_t offset);
PARROT_API parrot_context_t* Parrot_runops_fromc(Interp *, PMC *sub);
PARROT_API PMC* Parrot_runops_fromc_args(Interp *, PMC *sub, const char *sig, ...);
PARROT_API void* Parrot_runops_fromc_args_event(Interp *, PMC *sub, const char *sig, ...);
PARROT_API INTVAL Parrot_runops_fromc_args_reti(Interp *, PMC *, const char *, ...);
PARROT_API FLOATVAL Parrot_runops_fromc_args_retf(Interp *, PMC *, const char *, ...);

PARROT_API void* Parrot_runops_fromc_arglist(Interp *, PMC *, const char *sig, va_list);
PARROT_API INTVAL Parrot_runops_fromc_arglist_reti(Interp *, PMC *, const char *, va_list);
PARROT_API FLOATVAL Parrot_runops_fromc_arglist_retf(Interp *, PMC *, const char *,
        va_list);

PARROT_API void* Parrot_run_meth_fromc(Interp *, PMC *sub, PMC* obj, STRING *meth);
PARROT_API void* Parrot_run_meth_fromc_args(Interp *, PMC *sub,
        PMC* obj, STRING *meth, const char *signature, ...);
PARROT_API INTVAL Parrot_run_meth_fromc_args_reti(Interp *, PMC *sub,
        PMC* obj, STRING *meth, const char *signature, ...);
PARROT_API FLOATVAL Parrot_run_meth_fromc_args_retf(Interp *, PMC *sub,
        PMC* obj, STRING *meth, const char *signature, ...);

PARROT_API void* Parrot_run_meth_fromc_arglist(Interp *, PMC *sub,
        PMC* obj, STRING *meth, const char *signature, va_list);
PARROT_API INTVAL Parrot_run_meth_fromc_arglist_reti(Interp *, PMC *sub,
        PMC* obj, STRING *meth, const char *signature, va_list);
PARROT_API FLOATVAL Parrot_run_meth_fromc_arglist_retf(Interp *, PMC *sub,
        PMC* obj, STRING *meth, const char *signature, va_list);

PARROT_API void Parrot_callback_C(char *external_data, PMC *callback_info);
PARROT_API void Parrot_callback_D(PMC *callback_info, char *external_data);
PARROT_API PMC* Parrot_make_cb(Interp *interp, PMC* sub, PMC* user_data,
        STRING* cb_signature);

typedef opcode_t *(*native_func_t)(Interp *interp,
                                   opcode_t * cur_opcode,
                                   opcode_t * start_code);

VAR_SCOPE native_func_t run_native;

typedef PMC *(*Parrot_compiler_func_t)(Parrot_Interp interp,
                                       const char * program );

PARROT_API void Parrot_compreg(Interp *interp, STRING *, Parrot_compiler_func_t func);

PARROT_API PMC *Parrot_compile_string(Parrot_Interp interp,
        STRING *type, char *code, STRING **error);
PARROT_API void *Parrot_compile_file(Parrot_Interp interp,
        char *fullname, String **error);

INTVAL sysinfo_i(Interp *interp, INTVAL info_wanted);
STRING *sysinfo_s(Interp *interp, INTVAL info_wanted);
void exec_init_prederef(Interp *interp,
    void *prederef_arena);

void prepare_for_run(Interp *interp);
void *init_jit(Interp *interp, opcode_t *pc);
PARROT_API void dynop_register(Interp *interp, PMC* op_lib);
void do_prederef(void **pc_prederef, Interp *interp, int type);

void clone_interpreter(Parrot_Interp dest, Parrot_Interp self, INTVAL flags);

PARROT_API void enter_nci_method(Interp *, const int type,
                void *func, const char *name, const char *proto);
PARROT_API void register_nci_method(Interp *, const int type,
                void *func, const char *name, const char *proto);
PARROT_API void register_raw_nci_method_in_ns(Parrot_Interp interp, const int type,
                void *func, const char *name);
PARROT_API void Parrot_mark_method_writes(Interp *, int type, const char *name);

void Parrot_setup_event_func_ptrs(Parrot_Interp interp);

#else

struct Parrot_Interp_;
typedef struct Parrot_Interp_ *Parrot_Interp;

typedef void * *(*native_func_t)(Parrot_Interp interp,
                                 void *cur_opcode,
                                 void *start_code);

#endif   /* PARROT_IN_CORE */
#endif   /* PARROT_INTERPRETER_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
