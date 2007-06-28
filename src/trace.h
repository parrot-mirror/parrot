/* trace.h
 *  Copyright (C) 2001-2007, The Perl Foundation.
 *  SVN Info
 *     $Id$
 *  Overview:
 *     Tracing support for runops_cores.c.
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#ifndef PARROT_TRACE_H_GUARD
#define PARROT_TRACE_H_GUARD

#include "parrot/parrot.h"

/* HEADERIZER BEGIN: src/trace.c */

int trace_key_dump( Interp *interp /*NN*/, const PMC *key /*NN*/ )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

void trace_op( Interp *interp,
    const opcode_t *code_start /*NN*/,
    const opcode_t *code_end /*NN*/,
    const opcode_t *pc /*NULLOK*/ )
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

void trace_op_dump( Interp *interp /*NN*/,
    const opcode_t *code_start /*NN*/,
    const opcode_t *pc /*NN*/ )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

void trace_pmc_dump( Interp *interp /*NN*/, PMC *pmc /*NN*/ )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

/* HEADERIZER END: src/trace.c */


void trace_op(Interp *interp, const opcode_t * code_start,
              const opcode_t * code_end, const opcode_t * pc);

#endif /* PARROT_TRACE_H_GUARD */


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
