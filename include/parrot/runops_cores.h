/* runops_cores.h
 *  Copyright: (When this is determined...it will go here)
 *  CVS Info
 *     $Id$
 *  Overview:
 *     Header for runops cores.
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#if !defined(PARROT_RUNOPS_CORES_H_GUARD)
#define PARROT_RUNOPS_CORES_H_GUARD

#include "parrot/parrot.h"
#include "parrot/op.h"

typedef opcode_t * (*runops_core_f)(struct Parrot_Interp *, opcode_t *);

extern const runops_core_f runops_cores[8];

opcode_t *
runops_t0p0b0_core(struct Parrot_Interp *, opcode_t *);

opcode_t *
runops_t0p0b1_core(struct Parrot_Interp *, opcode_t *);

opcode_t *
runops_t0p1b0_core(struct Parrot_Interp *, opcode_t *);

opcode_t *
runops_t0p1b1_core(struct Parrot_Interp *, opcode_t *);

opcode_t *
runops_t1p0b0_core(struct Parrot_Interp *, opcode_t *);

opcode_t *
runops_t1p0b1_core(struct Parrot_Interp *, opcode_t *);

opcode_t *
runops_t1p1b0_core(struct Parrot_Interp *, opcode_t *);

opcode_t *
runops_t1p1b1_core(struct Parrot_Interp *, opcode_t *);


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
