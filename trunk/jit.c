/*
 * jit.c
 *
 * $Id$
 */

#include <parrot/parrot.h>
#include "parrot/jit.h"
#define JIT_EMIT 0
#include "parrot/jit_emit.h"

#ifdef __GNUC__
void Parrot_jit_debug(struct Parrot_Interp* interpreter);
#endif

/*
 * optimize_jit()
 */

Parrot_jit_optimizer_t *
optimize_jit(struct Parrot_Interp *interpreter, opcode_t *cur_op,
             opcode_t *code_start, opcode_t *code_end)
{
    Parrot_jit_optimizer_t *optimizer;
    Parrot_jit_optimizer_section_ptr cur_section, t_section;
    opcode_t section_begin, section_end, *next_op;
    op_info_t *op_info = &interpreter->op_info_table[*cur_op];
    char *branch, *map;
    int i, j, k, argn, section_size, op_arg;

    /* Allocate space for the optimizer */
    optimizer = (Parrot_jit_optimizer_t *)
        mem_sys_allocate_zeroed(sizeof(Parrot_jit_optimizer_t));

    /* Allocate space for the branch information and register map */
    optimizer->map_branch = map = branch =
        (char *)mem_sys_allocate_zeroed((size_t)(code_end - code_start));

    /* Allocate space for the branch list */
    optimizer->branch_list = (opcode_t **)
        mem_sys_allocate_zeroed(
                (size_t)(code_end - code_start) * sizeof(opcode_t *));

    while (cur_op < code_end) {
        /* If the opcode jumps we may:
         *
         * PARROT_JUMP_RELATIVE:
         *      The op jumps to an address relative to the current position,
         *      thus we mark the branch target and the branch source.
         *
         * PARROT_JUMP_ADDRESS:
         *      The op jumps to an absolute address,thus we mark the branch
         *      target.
         *
         * PARROT_JUMP_POP:
         *      The op pops the address to jump to,thus we don't mark the
         *      branch target, anyway it may probably use expr(NEXT)
         *
         * PARROT_JUMP_ENEXT:
         *      The op does something with expr(NEXT),
         *      XXX I'll assume that it's stored in the control stack for
         *          later returning since that's the only way it's used now
         *          but this should go away by the time we add some metadata
         *          to the ops.
         *      So we will mark the branch target.
         *
         * PARROT_JUMP_GNEXT:
         *      Means the opcode does some other kind of jump, and also
         *      might goto(NEXT)
         *
         * PARROT_JUMP_UNPREDICTABLE:
         *      The branch target is unpredictable.
         *      Things get a little tricky since it's not 100% true that the
         *      target is unpredictable because of the set_addr opcode, we
         *      need to find a solution for this, in the mean time, we will
         *      make each section have it's own arena and try to avoid
         *      going in and out from them as much as posible.
         */

        /* Predereference the opcode information table for this opcode
         * early since it's going to be used many times */
        op_info = &interpreter->op_info_table[*cur_op];

        /* if op_info->jump is not 0 this opcode may jump,
         * so mark this opcode as a branch source */
        if (op_info->jump)
            branch[cur_op - code_start] |= JIT_BRANCH_SOURCE;
        /* If it's not a constant, no joy */
        if (op_info->types[op_info->arg_count - 1] == PARROT_ARG_IC) {
            /* The branch target is relative, the offset is in last argument */
            if (op_info->jump & PARROT_JUMP_RELATIVE) {
                /* Set the branch target */
                optimizer->branch_list[cur_op - code_start] =
                    cur_op + cur_op[op_info->arg_count - 1];
                branch[cur_op - code_start + cur_op[op_info->arg_count - 1]] |=
                    JIT_BRANCH_TARGET;
            }
            /* The branch target is absolute, the address is in last argument */
            if (op_info->jump & PARROT_JUMP_ADDRESS) {
                /* Set the branch target */
                optimizer->branch_list[cur_op - code_start] =
                    cur_op + cur_op[op_info->arg_count - 1];
                branch[cur_op[op_info->arg_count - 1]] |= JIT_BRANCH_TARGET;
            }
        }
        /* The address of the next opcode */
        if ((op_info->jump & PARROT_JUMP_ENEXT) ||
            (op_info->jump & PARROT_JUMP_GNEXT))
            branch[cur_op + op_info->arg_count - code_start] |=
                JIT_BRANCH_TARGET;
        if (op_info->jump & PARROT_JUMP_UNPREDICTABLE)
            optimizer->has_unpredictable_jump = 1;
        /* Move to the next opcode */
        cur_op += op_info->arg_count;
    }

    /* ok, let's loop again and generate the sections */

    /* Allocate the first section */
    cur_section = optimizer->sections = (Parrot_jit_optimizer_section_t *)
        mem_sys_allocate_zeroed(sizeof(Parrot_jit_optimizer_section_t));
    cur_section->begin = code_start;
    /* Init the register usage */
    for (i = 1; i < NUM_REGISTERS; i++) {
        cur_section->int_reg_usage[i] = i;
#if FLOAT_REGISTERS_TO_MAP
        cur_section->float_reg_usage[i] = i;
#endif
    }

    cur_op = code_start;
    while (cur_section) {
        /* Predereference the opcode information for this opcode
         * early since it's going to be used many times */
        op_info = &interpreter->op_info_table[*cur_op];

        /* Calculate the next pc */
        next_op = cur_op + op_info->arg_count;

        /* Update op_count */
        cur_section->op_count++;

        /* If the opcode is jitted and calls a C function or it's not jitted
         * at all, we will not count it. */
        if (!op_jit[*cur_op].extcall) {
            cur_section->jit_op_count++;
            /* For each argument that has the opcode increment the usage count,
             * right now, we are only ckecking integer registers.
             * We move from the end since we need to check if the first opcode
             * using the register will read or write it. */
            for (argn = op_info->arg_count - 1; argn > 0; argn--) {
                if (op_info->types[argn] == PARROT_ARG_I ||
                    op_info->types[argn] == PARROT_ARG_KI ) {
                    /* keyed OPs are currently not JITed, so this code
                     * is not reached and will not harm, but ...
                     */
                    if ((!cur_section->int_reg_count[*(cur_op + argn)]++) &&
                        (op_info->dirs[argn] & PARROT_ARGDIR_IN))
                        cur_section->int_reg_dir[*(cur_op + argn)] |=
                            PARROT_ARGDIR_IN;
                    if (op_info->dirs[argn] & PARROT_ARGDIR_OUT)
                        cur_section->int_reg_dir[*(cur_op + argn)] |=
                            PARROT_ARGDIR_OUT;
                }
                /* key constants may have register keys */
                else if (op_info->types[argn] == PARROT_ARG_KC) {
                    PMC *key = interpreter->code->const_table->constants[
                        *(cur_op + argn)]->key;
                    while (key) {
                        if ((key->flags & KEY_integer_FLAG) &&
                                (key->flags & KEY_register_FLAG)) {
                            INTVAL n = key->cache.int_val;
                            if (!cur_section->int_reg_count[n]++)
                                cur_section->int_reg_dir[n] |=
                                    PARROT_ARGDIR_IN;
                        }
                        key = key_next(interpreter, key);
                    }
                }
#if FLOAT_REGISTERS_TO_MAP
                else if (op_info->types[argn] == PARROT_ARG_N) {
                    if ((!cur_section->float_reg_count[*(cur_op + argn)]++) &&
                        (op_info->dirs[argn] & PARROT_ARGDIR_IN))
                        cur_section->float_reg_dir[*(cur_op + argn)] |=
                            PARROT_ARGDIR_IN;
                    if (op_info->dirs[argn] & PARROT_ARGDIR_OUT)
                        cur_section->float_reg_dir[*(cur_op + argn)] |=
                            PARROT_ARGDIR_OUT;
                }
#endif
            }
            /* If we are here means the current section is jitted, so if the
             * next opcode is not end the section. */
            if (next_op < code_end && op_jit[*next_op].extcall)
                goto END_SECTION;
        }
        else
            /* The current section is not jitted, end it if the next opcode
             * is. */
        if (next_op < code_end && !op_jit[*next_op].extcall)
            goto END_SECTION;

        /* The section ends when the current opcode is a branch source,
         * in other words if the opcode jumps, or if the next opcode is
         * a branch target, allocate a new section only if it's not the
         * last opcode */
        if ((branch[cur_op - code_start] & JIT_BRANCH_SOURCE)
            || (next_op < code_end &&
                (branch[next_op - code_start] & JIT_BRANCH_TARGET))
            || (next_op >= code_end)) {
          END_SECTION:
            /* Set the type, depending on whether the current
             * instruction is external or jitted. */
            cur_section->type = !op_jit[*cur_op].extcall;

            /* Save the address where the section ends */
            cur_section->end = cur_op;

            if (next_op < code_end) {
                /* Allocate a new section */
                t_section = (Parrot_jit_optimizer_section_t *)
                    mem_sys_allocate_zeroed(
                            sizeof(Parrot_jit_optimizer_section_t));
                /* Add it to the double linked list */
                cur_section->next = t_section;
                t_section->prev = cur_section;
                /* Make the new section be the current one */
                cur_section = t_section;
                /* Save the address where the section begins */
                cur_section->begin = next_op;
                /* Init the register usage */
                for (i = 1; i < NUM_REGISTERS; i++) {
                    cur_section->int_reg_usage[i] = i;
#if FLOAT_REGISTERS_TO_MAP
                    cur_section->float_reg_usage[i] = i;
#endif
                }
            }
            else {
                cur_section = NULL;
            }
        }

        /* Move to the next opcode */
        cur_op = next_op;
    }

    /* This is where we start deciding which Parrot registers get
     * mapped to a hardware one in each different section. */

    /* Start from the first section */
    cur_section = optimizer->sections;

    /* While there is section */
    while (cur_section) {
        /* Test register 0 first */
        if (cur_section->int_reg_count[0])
            cur_section->int_registers_used = 1;
#if FLOAT_REGISTERS_TO_MAP
        if (cur_section->float_reg_count[0])
            cur_section->float_registers_used = 1;
#endif
        /* Sort the registers by the usage,
         * Start from the register number 1 since we compare it with the
         * previous one */
        for (i = 1; i < NUM_REGISTERS; i++) {
            /* If the register is not used continue to the next one */
            if (!cur_section->int_reg_count[i] &&
                !cur_section->float_reg_count[i])
                continue;
            /* Count the number of hardware registers that is going to be
             * used in this section */
            if (cur_section->int_registers_used < INT_REGISTERS_TO_MAP)
                cur_section->int_registers_used++;
#if FLOAT_REGISTERS_TO_MAP
            if (cur_section->float_registers_used < FLOAT_REGISTERS_TO_MAP)
                cur_section->float_registers_used++;
#endif

            /* Any register before this one */
            for (j = 0; j < i; j++) {
                /* If the usage of this register is greater than the usage
                 * of the register in the j'th position of the list */
                if (cur_section->int_reg_count[i] >
                    cur_section->int_reg_count[cur_section->int_reg_usage[j]])
                {
                    /* Move all the registers from the j'th position to
                     * the next one */
                    for (k = i; k > j; k--)
                        cur_section->int_reg_usage[k] =
                            cur_section->int_reg_usage[k - 1];

                    /* Update the position of the register */
                    cur_section->int_reg_usage[j] = i;
                    /* Continue with the next register */
                    break;
                }
#if FLOAT_REGISTERS_TO_MAP
                if (cur_section->float_reg_count[i] >
                    cur_section->float_reg_count[cur_section->
                                                 float_reg_usage[j]]) {
                    /* Move all the registers from the j'th position to
                     * the next one */
                    for (k = i; k > j; k--)
                        cur_section->float_reg_usage[k] =
                            cur_section->float_reg_usage[k - 1];

                    /* Update the position of the register */
                    cur_section->float_reg_usage[j] = i;
                    /* Continue with the next register */
                    break;
                }
#endif
            }
        }
        /* Set the branch target of this section, that is the section where
         * the program execution continues, if it ends in a branch source we
         * use the branch target and not the next section. */
        if (optimizer->branch_list[cur_section->end - code_start]) {
            /* If the branch target is to a section before the current one
             * move from the start, otherwise from the current section */
            if (optimizer->branch_list[cur_section->end - code_start] <
                cur_section->begin)
                t_section = optimizer->sections;
            else
                t_section = cur_section;

            while (t_section) {
                /* If we find the section attach it to the current one. */
                if (t_section->begin ==
                    optimizer->branch_list[cur_section->end - code_start]) {
                    cur_section->branch_target = t_section;
                    break;
                }
                /* If not move to the next. */
                t_section = t_section->next;
            }

        }

        /* Assign registers */
        /* For each opcode in this section */
        cur_op = cur_section->begin;
        while (cur_op <= cur_section->end) {
            op_info = &interpreter->op_info_table[*cur_op];
            /* For each argument of the current opcode */
            for (op_arg = 1; op_arg < op_info->arg_count; op_arg++) {
                /* If the argument is an integer register */
                if (op_info->types[op_arg] == PARROT_ARG_I) {
                    /* If the argument is in most used list */
                    for (i = 0; i < INT_REGISTERS_TO_MAP; i++)
                        if (cur_op[op_arg] ==
                            (opcode_t)cur_section->int_reg_usage[i]) {
                            map[cur_op + op_arg - code_start] = intval_map[i];
                            cur_section->maps++;
                            break;
                        }
                }
#if FLOAT_REGISTERS_TO_MAP
                /* If the argument is a float register */
                if (op_info->types[op_arg] == PARROT_ARG_N) {
                    /* If the argument is in most used list */
                    for (i = 0; i < FLOAT_REGISTERS_TO_MAP; i++)
                        if (cur_op[op_arg] ==
                            (opcode_t)cur_section->float_reg_usage[i]) {
                            map[cur_op + op_arg - code_start] =
                                floatval_map[i];
                            cur_section->maps++;
                            break;
                        }
                }
#endif
            }

            /* Move to the next opcode */
            cur_op += op_info->arg_count;
        }

        /* Move to the next section */
        cur_section = cur_section->next;
    }

#if JIT_DEBUG
    cur_section = optimizer->sections;
    while (cur_section) {
        PIO_eprintf(interpreter, "\nSection:\n");
        PIO_eprintf(interpreter, "%s\n",
                    (cur_section->type) ? "JITTED" : "NOT JITTED");
        for (cur_op = cur_section->begin; cur_op <= cur_section->end;) {
            char instr[256];
            op_info = &interpreter->op_info_table[*cur_op];
            PDB_disassemble_op(interpreter, instr, sizeof(instr),
                               op_info, cur_op, NULL, code_start, 0);
            PIO_eprintf(interpreter, "\t\tOP%vu: %s\n",
                        cur_op - code_start, instr);
            cur_op += op_info->arg_count;
        }
        PIO_eprintf(interpreter, "\tbegin:\t%#p\t(%Ou)\n",
                    cur_section->begin, *cur_section->begin);
        PIO_eprintf(interpreter, "\tend:\t%#p\t(%Ou)\n",
                    cur_section->end, *cur_section->end);
        PIO_eprintf(interpreter, "\tInt register count:\t");
        for (i = 0; i < NUM_REGISTERS; i++)
            PIO_eprintf(interpreter, "%i ", cur_section->int_reg_count[i]);
        PIO_eprintf(interpreter, "\n\tInt register usage:\t");
        for (i = 0; i < NUM_REGISTERS; i++)
            PIO_eprintf(interpreter, "%i ", cur_section->int_reg_usage[i]);
        PIO_eprintf(interpreter, "\n\tInt register direction:\t");
        for (i = 0; i < NUM_REGISTERS; i++)
            PIO_eprintf(interpreter, "%i ", (int)cur_section->int_reg_dir[i]);
        PIO_eprintf(interpreter, "\n\tInt registers used:\t%i\n",
                    cur_section->int_registers_used);
        PIO_eprintf(interpreter, "\tFloat register count:\t");
        for (i = 0; i < NUM_REGISTERS; i++)
            PIO_eprintf(interpreter, "%i ", cur_section->float_reg_count[i]);
        PIO_eprintf(interpreter, "\n\tFloat register usage:\t");
        for (i = 0; i < NUM_REGISTERS; i++)
            PIO_eprintf(interpreter, "%i ", cur_section->float_reg_usage[i]);
        PIO_eprintf(interpreter, "\n\tFloat register direction:\t");
        for (i = 0; i < NUM_REGISTERS; i++)
            PIO_eprintf(interpreter, "%i ",
                        (int)cur_section->float_reg_dir[i]);
        PIO_eprintf(interpreter, "\n\tFloat Registers used:\t%i\n",
                    cur_section->float_registers_used);
        PIO_eprintf(interpreter, "\tJit opcodes:\t%u\n",
                    cur_section->jit_op_count);
        PIO_eprintf(interpreter, "\tTotal opcodes:\t%u\n",
                    cur_section->op_count);
        cur_section = cur_section->next;
    }
#endif

    return optimizer;
}

/*
** build_asm()
*/

jit_f
build_asm(struct Parrot_Interp *interpreter, opcode_t *pc,
          opcode_t *code_start, opcode_t *code_end)
{
    UINTVAL i;
    char *new_arena;
    void *prev_address;
    /* FIXME allocate this for multiple interpreters */
    static Parrot_jit_info_t jit_info;
    opcode_t cur_opcode_byte;


    /* XXX assume, we restart */
    if (pc != code_start && interpreter->jit_info)
        return (jit_f)D2FPTR(jit_info.arena.start);

    interpreter->jit_info = &jit_info;
    jit_info.optimizer = optimize_jit(interpreter, pc, code_start, code_end);

    /* Attach the register map to the jit_info structure */
    jit_info.intval_map = intval_map;
#if FLOAT_REGISTERS_TO_MAP
    jit_info.floatval_map = floatval_map;
#endif


    /* Byte code size in opcode_t's */
    jit_info.arena.map_size = (code_end - code_start) + 1;
    jit_info.arena.op_map =
        (Parrot_jit_opmap_t *)mem_sys_allocate_zeroed(
            jit_info.arena.map_size * sizeof(* (jit_info.arena.op_map)));

#if REQUIRES_CONSTANT_POOL
    Parrot_jit_init_arenas(&jit_info);
#else
    jit_info.arena.size = 1024;
    jit_info.native_ptr = jit_info.arena.start =
        mem_sys_allocate_zeroed((size_t)jit_info.arena.size);
#endif

    jit_info.op_i = 0;
    jit_info.arena.fixups = NULL;

    /*
     *   op_map holds the offset from arena.start
     *   of the parrot op at the given opcode index
     *
     *  bytecode:       56  1   1   56  1   1
     *  op_map:         3   0   0   15  0   0
     */

    Parrot_jit_begin(&jit_info, interpreter);

    /* Set the offset of the first opcode */
    jit_info.arena.op_map[jit_info.op_i].offset =
        jit_info.native_ptr - jit_info.arena.start;

    /* The first section */
    jit_info.optimizer->cur_section = jit_info.optimizer->sections;

    while (jit_info.optimizer->cur_section) {
        /* Load mapped registers for this section */
        if (jit_info.optimizer->cur_section->type)
            Parrot_jit_load_registers(&jit_info, interpreter);

        /* The first opcode for this section */
        jit_info.cur_op = jit_info.optimizer->cur_section->begin;

        /* The first opcode of each section doesn't have a previous one since
         * it's imposible to be sure which was it */
        jit_info.prev_op = NULL;

        while (jit_info.cur_op <= jit_info.optimizer->cur_section->end) {
            /* Grow the arena early */
            if (jit_info.arena.size <
                (jit_info.arena.op_map[jit_info.op_i].offset + 100)) {
#if REQUIRES_CONSTANT_POOL
                Parrot_jit_extend_arena(&jit_info);
#else
                new_arena = mem_sys_realloc(jit_info.arena.start,
                                            (size_t)jit_info.arena.size * 2);
                jit_info.arena.size *= 2;
                jit_info.native_ptr = new_arena +
                    (jit_info.native_ptr - jit_info.arena.start);
                jit_info.arena.start = new_arena;
#endif
            }

            cur_opcode_byte = *jit_info.cur_op;

            /* Need to save the registers if there is a branch and is not to
             * the same section, I admit I don't like this, and it should be
             * really checking if the target section has the same registers
             * mapped too. */
            if ((jit_info.optimizer->map_branch[jit_info.cur_op - code_start]
                 == JIT_BRANCH_SOURCE) &&
                (jit_info.optimizer->cur_section->branch_target !=
                 jit_info.optimizer->cur_section))
                Parrot_jit_save_registers(&jit_info, interpreter);

            /* Generate native code for current op */
            (op_jit[cur_opcode_byte].fn) (&jit_info, interpreter);

            /* Update the previous opcode */
            jit_info.prev_op = jit_info.cur_op;

            /* update op_i and cur_op accordingly */
            jit_info.op_i +=
                interpreter->op_info_table[cur_opcode_byte].arg_count;
            jit_info.cur_op +=
                interpreter->op_info_table[cur_opcode_byte].arg_count;

            /* set the offset */
            jit_info.arena.op_map[jit_info.op_i].offset =
                jit_info.native_ptr - jit_info.arena.start;
        }

        /* Save mapped registers back to the Parrot registers */
        if (jit_info.optimizer->cur_section->type)
            Parrot_jit_save_registers(&jit_info, interpreter);

        /* update the offset */
        jit_info.arena.op_map[jit_info.op_i].offset =
            jit_info.native_ptr - jit_info.arena.start;

        /* Move to the next section */
        jit_info.optimizer->cur_section =
            jit_info.optimizer->cur_section->next;
    }

    /* Do fixups before converting offsets */
    Parrot_jit_dofixup(&jit_info, interpreter);

    /* Convert offsets to pointers */
    for (i = 0; i < jit_info.arena.map_size; i++) {

        /* Assuming native code chunks contain some initialization code,
         * the first op (and every other op) is at an offset > 0
         */
        if (jit_info.arena.op_map[i].offset) {
            jit_info.arena.op_map[i].ptr = (char *)jit_info.arena.start +
                jit_info.arena.op_map[i].offset;
        }
    }

#ifdef ARM
    arm_sync_d_i_cache(jit_info.arena.start, jit_info.native_ptr);
#endif
#ifdef PPC
    ppc_sync_cache(jit_info.arena.start, jit_info.native_ptr);
#endif

    /* assume gdb is available */
#ifdef __GNUC__
    if (Interp_flags_TEST(interpreter, PARROT_DEBUG_FLAG))
        Parrot_jit_debug(interpreter);
#endif

    return (jit_f)D2FPTR(jit_info.arena.start);
}

/* Remember the current position in the native code for later update */
void
Parrot_jit_newfixup(Parrot_jit_info_t *jit_info)
{
    Parrot_jit_fixup_t *fixup;

    fixup = mem_sys_allocate_zeroed(sizeof(*fixup));

    if (!fixup)
        internal_exception(ALLOCATION_ERROR,
                           "System memory allocation failed\n");

    /* Insert fixup at the head of the list */
    fixup->next = jit_info->arena.fixups;
    jit_info->arena.fixups = fixup;

    /* Fill in the native code offset */
    fixup->native_offset =
        (ptrdiff_t)(jit_info->native_ptr - jit_info->arena.start);
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
