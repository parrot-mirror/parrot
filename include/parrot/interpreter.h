/* interpreter.h
 *  Copyright: (When this is determined...it will go here)
 *  CVS Info
 *     $Id$
 *  Overview:
 *     The interpreter api handles running the operations
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#if !defined(PARROT_INTERPRETER_H_GUARD)
#define PARROT_INTERPRETER_H_GUARD

#include "parrot/parrot.h"

#include "parrot/op.h"
#include "parrot/oplib.h"

struct Parrot_Interp {
    struct IReg *int_reg;            /* Current top of int reg stack */
    struct NReg *num_reg;            /* Current top of the float reg stack */
    struct SReg *string_reg;         /* Current top of the string stack */
    struct PReg *pmc_reg;            /* Current top of the PMC stack */
    struct Stack_Entry *user_stack_top;         /* Current top of the scratch stack */
    struct Stack_Entry *control_stack_top;	/* Current top of the flow control stack */
    struct IRegChunk *int_reg_base;            /* base of the int reg stack */
    struct NRegChunk *num_reg_base;            /* Base of the float reg stack */
    struct SRegChunk *string_reg_base;         /* Base of the string stack */
    struct PRegChunk *pmc_reg_base;            /* Base of the PMC stack */
    struct StackChunk *user_stack_base;             /* Base of the scratch stack */
    struct StackChunk *control_stack_base;          /* Base of the flow control stack */
    struct Stash *perl_stash;             /* Pointer to the global */
                                          /* variable area */
    struct Arenas *arena_base;            /* Pointer to this */
                                          /* interpreter's arena */

    op_lib_t *  op_lib;                   /* Opcode library */
    INTVAL      op_count;                 /* The number of ops */
    op_info_t * op_info_table;            /* Opcode info table (name, nargs, arg types) */
    opcode_t     *(**op_func_table)();    /* Opcode function table */

    STRING_FUNCS *(**string_funcs)();     /* String function table */
    INTVAL flags;				          /* Various interpreter flags
                                             that signal that runops
                                             should do something */
    INTVAL * profile;                     /* The array where we keep the profile counters */

    INTVAL resume_flag;
    size_t resume_offset;

    struct PackFile * code;               /* The code we are executing */
    void ** prederef_code;                /* The predereferenced code */
    INTVAL current_line;                  /* Which line we're executing in the source */
    void *current_file;			/* The file we're currently in */
    void *current_package;              /* The package we're currently in */
};

#define PARROT_DEBUG_FLAG    0x01  /* We're debugging */
#define PARROT_TRACE_FLAG    0x02  /* We're tracing execution */
#define PARROT_BOUNDS_FLAG   0x04  /* We're tracking byte code bounds */
#define PARROT_PROFILE_FLAG  0x08  /* We're gathering profile information */
#define PARROT_PREDEREF_FLAG 0x10  /* We're using the prederef runops */
#define PARROT_JIT_FLAG      0x20  /* We're using the jit runops */

#define PCONST(i) PF_CONST(interpreter->code, (i))
#define PNCONST   PF_NCONST(interpreter->code)

struct Parrot_Interp *
make_interpreter(INTVAL);

void
runops_generic();

void
runops(struct Parrot_Interp *, struct PackFile *, size_t offset);

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
