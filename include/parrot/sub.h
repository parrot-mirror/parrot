/* sub.h
 *  Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
 *  CVS Info
 *     $Id$
 *  Overview:
 *  Data Structure and Algorithms:
 *     Subroutine, coroutine, closure and continuation structures
 *     and related routines.
 *  History:
 *     Initial version by Melvin on on 2002/06/6
 *  Notes:
 *  References:
 */

#if !defined(PARROT_SUB_H_GUARD)
#define PARROT_SUB_H_GUARD

#include "parrot/parrot.h"

/*
 * Subroutine flags
 */
typedef enum {
    SUB_FLAG_CORO_FF      = PObj_private0_FLAG,
    SUB_FLAG_C_HANDLER    = PObj_private0_FLAG,

    SUB_FLAG_FIXUP_DONE   = PObj_private1_FLAG,
    SUB_FLAG_TAILCALL     = PObj_private2_FLAG,
    SUB_FLAG_GENERATOR    = PObj_private3_FLAG,

    /* from packfile */
    SUB_FLAG_PF_ANON      = PObj_private3_FLAG,
    SUB_FLAG_PF_MAIN      = PObj_private4_FLAG,
    SUB_FLAG_PF_LOAD      = PObj_private5_FLAG,
    SUB_FLAG_PF_IMMEDIATE = PObj_private6_FLAG,
    SUB_FLAG_PF_POSTCOMP  = PObj_private7_FLAG,

    SUB_FLAG_PF_MASK      = 0xf8   /* anon ... postcomp */

} sub_flags_enum;

union parrot_context_t;

/*
 * Sub and Closure share a Parrot_sub structure, Closure has additionally
 * a lexical pad stack
 */
typedef struct Parrot_sub {
    struct PackFile_ByteCode *seg;      /* bytecode segment */
    opcode_t *address;          /* start of bytecode, addr to continue */
    opcode_t *end;              /* end of bytecode */

    INTVAL   HLL_id;            /* see src/hll.c XXX or per segment? */
    PMC      *name_space;       /* where this Sub is in */
    STRING   *name;             /* name of the sub */
    PMC      *multi_signature;  /* list of types for MMD */

    PMC      *lexicals;         /* OrderedHash of Lexicals */
    PMC      *enclosing_sub;    /* enclosing subroutine, to find lexicals */

    /* - end common */

    struct Stack_Chunk *pad_stack;      /* only for closure */
} * parrot_sub_t;

#define PMC_sub(pmc) LVALUE_CAST(parrot_sub_t, PMC_struct_val(pmc))

/* the first entries must match Parrot_sub, so we can cast
 * these two to the other type
 */
typedef struct Parrot_coro {
    struct PackFile_ByteCode *seg;      /* bytecode segment */
    opcode_t *address;          /* start of bytecode, addr to continue */
    opcode_t *end;              /* end of bytecode */

    INTVAL   HLL_id;            /* see src/hll.c XXX or per segment? */
    PMC      *name_space;       /* where this Sub is in */
    STRING   *name;             /* name of the sub */
    PMC      *multi_signature;  /* list of types for MMD */

    PMC      *lexicals;         /* OrderedHash of Lexicals */
    PMC      *enclosing_sub;    /* enclosing subroutine, to find lexicals */

    /* - end common */

    parrot_context_t ctx;          /* coroutine context */
    struct PackFile_ByteCode *caller_seg;  /* bytecode segment */
} * parrot_coro_t;

#define PMC_coro(pmc) LVALUE_CAST(parrot_coro_t, PMC_struct_val(pmc))

typedef struct Parrot_cont {
    struct PackFile_ByteCode *seg;      /* bytecode segment */
    opcode_t *address;          /* start of bytecode, addr to continue */
    parrot_context_t ctx;  /* pointer to interpreter context */
    struct Parrot_Context *ctx_copy;   /* full continuation only */
} * parrot_cont_t;

#define PMC_cont(pmc) LVALUE_CAST(parrot_cont_t, PMC_struct_val(pmc))

struct Parrot_Context_info {
    STRING* subname;
    STRING* nsname;
    STRING* fullname;
    int pc;
    const char *file;
    int line;
    opcode_t *address;
};

struct Parrot_sub * new_sub(Interp * interp);
struct Parrot_sub * new_closure(Interp * interp);
struct Parrot_coro * new_coroutine(Interp * interp);
struct Parrot_cont * new_continuation(Interp * interp);
struct Parrot_cont * new_ret_continuation(Interp * interp);

PMC * new_ret_continuation_pmc(Interp *, opcode_t * address);

void mark_context(Interp *, parrot_context_t *);

opcode_t * parrot_pass_args(Interp *, struct Parrot_sub * sub,
        struct parrot_regs_t *caller_regs, int what);

void mark_reg_stack(Interp *, Stack_Chunk_t *);
void invalidate_retc_context(Interp *interpreter, PMC *cont);

STRING* Parrot_full_sub_name(Interp* interpreter, PMC* sub);
int Parrot_Context_info(Interp *interpreter, parrot_context_t *, struct Parrot_Context_info *);
STRING* Parrot_Context_infostr(Interp *interpreter, parrot_context_t *);

#endif /* PARROT_SUB_H_GUARD */

/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
 */
