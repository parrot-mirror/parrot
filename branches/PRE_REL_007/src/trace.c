/* trace.c
 *  Copyright: (When this is determined...it will go here)
 *  CVS Info
 *     $Id$
 *  Overview:
 *     Tracing support for runops_cores.c.
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#include "parrot/trace.h"


/*
 *=for api interpreter trace_op_dump
 * TODO: This isn't really part of the API, but here's its documentation. 
 * Prints the PC, OP and ARGS. Used by trace_op
 */
void
trace_op_dump(struct Parrot_Interp *interpreter, opcode_t *code_start,
              opcode_t *pc)
{
    INTVAL i;
    char *escaped;

    fprintf(stderr, "PC=%ld; OP=%ld (%s)", (long)(pc - code_start), *pc,
            interpreter->op_info_table[*pc].full_name);

    if (interpreter->op_info_table[*pc].arg_count > 1) {
        fprintf(stderr, "; ARGS=(");
        for (i = 1; i < interpreter->op_info_table[*pc].arg_count; i++) {
            if (i > 1) {
                fprintf(stderr, ", ");
            }
            switch (interpreter->op_info_table[*pc].types[i]) {
            case PARROT_ARG_IC:
                fprintf(stderr, "%ld", (long)*(pc + i));
                break;
            case PARROT_ARG_NC:
                fprintf(stderr, "%f", interpreter->code->const_table->
                        constants[*(pc + i)]->number);
                break;
            case PARROT_ARG_PC:
                /* what is a PMC constant look like? */
                fprintf(stderr, "%ld", (long)*(pc + i));
                break;
            case PARROT_ARG_SC:
                escaped = PDB_escape(interpreter->code->const_table->
                                     constants[*(pc + i)]->string->bufstart,
                                     interpreter->code->const_table->
                                     constants[*(pc + i)]->string->strlen);
                fprintf(stderr, "\"%s\"", escaped);
                break;
            case PARROT_ARG_KC:
                /* what will a KEY constant look like? */
                fprintf(stderr, "%ld", (long)*(pc + i));
                break;
            case PARROT_ARG_I:
                fprintf(stderr, "I%ld=%ld", (long)*(pc + i),
                        (long)interpreter->ctx.int_reg.registers[*(pc + i)]);
                break;
            case PARROT_ARG_N:
                fprintf(stderr, "N%ld=%f", (long)*(pc + i),
                        interpreter->ctx.num_reg.registers[*(pc + i)]);
                break;
            case PARROT_ARG_P:
                /* what does a PMC constant look like? */
                fprintf(stderr, "P%ld=%p", (long)*(pc + i),
                        interpreter->ctx.pmc_reg.registers[*(pc + i)]);
                break;
            case PARROT_ARG_S:
                if (interpreter->ctx.string_reg.registers[*(pc + i)]) {
                    escaped = PDB_escape(interpreter->ctx.string_reg.
                                         registers[*(pc + i)]->bufstart,
                                         interpreter->ctx.string_reg.
                                         registers[*(pc + i)]->strlen);
                    fprintf(stderr, "S%ld=\"%s\"", (long)*(pc + i),
                            escaped);
                }
                else {
                    fprintf(stderr, "S%ld=(null)", (long)*(pc + i));
                }
                break;
            case PARROT_ARG_K:
                /* what does a KEY constant look like? */
                fprintf(stderr, "K%ld=%p", (long)*(pc + i),
                        interpreter->ctx.pmc_reg.registers[*(pc + i)]);
                break;
            case PARROT_ARG_OP:
                /* this isn't handled, so at least report the error
                 * instead of silently ignoring the problem */
                internal_exception(ARG_OP_NOT_HANDLED,
                                   "PARROT_ARG_OP in enumeration not handled in switch");
                break;
            default:
                /* -Wall expects us to cover PARROT_ARG_OP somewhere. */
                fprintf(stderr, "?(%i)%ld=???",
                        interpreter->op_info_table[*pc].types[i],
                        (long)*(pc + i));
                break;
            }
        }
        fprintf(stderr, ")");
    }
    fprintf(stderr, "\n");
}



/*
 *=for api interpreter trace_op
 * TODO: This isn't really part of the API, but here's its documentation. 
 * Prints the PC, OP and ARGS. Used by runops_trace.
 *
 * With bounds checking.
 */
void
trace_op(struct Parrot_Interp *interpreter, opcode_t *code_start,
         opcode_t *code_end, opcode_t *pc)
{
    if (!pc) {
        return;
    }

    (void)fflush(NULL);         /* Flush *ALL* output before printing trace info */
    if (pc >= code_start && pc < code_end) {
        trace_op_dump(interpreter, code_start, pc);
    }
    else if (pc) {
        fprintf(stderr, "PC=%ld; OP=<err>\n", (long)(pc - code_start));
    }

    /* Flush *stderr* now that we've output the trace info */
    (void)fflush(stderr);
}


/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil 
 * End:
 *
 * vim: expandtab shiftwidth=4:
*/
