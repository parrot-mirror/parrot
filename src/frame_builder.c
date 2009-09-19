/*
Copyright (C) 2008-2009, Parrot Foundation.
$Id$
*/

/* HEADERIZER HFILE: none */
/* HEADERIZER STOP */

#include "parrot/parrot.h"
#include "pmc/pmc_fixedintegerarray.h"
#include "pmc/pmc_unmanagedstruct.h"
#include "pmc/pmc_managedstruct.h"
#include "frame_builder.h"

/*

=over 4

=item C<void Parrot_jit_free_buffer(PARROT_INTERP, void *ptr, void *priv)>

This is a callback to implement the proper freeing semantics.  It is called by
the ManagedStruct PMC as it is garbage collected.

=cut

*/

void
Parrot_jit_free_buffer(PARROT_INTERP, void *ptr, void *priv)
{
    const struct jit_buffer_private_data * const jit = (struct jit_buffer_private_data*)priv;
    mem_free_executable(ptr, jit->size);
    free(priv);
}

/*

=item C<PMC *Parrot_jit_clone_buffer(PARROT_INTERP, PMC *pmc, void *priv)>

This is a callback to implement the proper cloning semantics for jit buffers.
It is called by the ManagedStruct PMC's clone() function.

=back

=cut

*/

PMC *
Parrot_jit_clone_buffer(PARROT_INTERP, PMC *pmc, void *priv)
{
    PMC * const rv = pmc_new(interp, pmc->vtable->base_type);

    VTABLE_init(interp, rv);
    /* copy the attributes */
    {
        void (*tmpfreefunc)(PARROT_INTERP, void*, void*);
        GETATTR_ManagedStruct_custom_free_func(interp, pmc, tmpfreefunc);
        SETATTR_ManagedStruct_custom_free_func(interp, rv , tmpfreefunc);
    }
    {
        PMC* (*tmpclonefunc)(PARROT_INTERP, PMC*, void*);
        GETATTR_ManagedStruct_custom_clone_func(interp, pmc, tmpclonefunc);
        SETATTR_ManagedStruct_custom_clone_func(interp, rv , tmpclonefunc);
    }

    {
        void *freepriv, *clonepriv;
        GETATTR_ManagedStruct_custom_free_priv(interp , pmc, freepriv);
        GETATTR_ManagedStruct_custom_clone_priv(interp, pmc, clonepriv);
        if (freepriv) {
            void *tmp = mem_sys_allocate(sizeof (struct jit_buffer_private_data));
            memcpy(tmp, freepriv, sizeof (struct jit_buffer_private_data));
            SETATTR_ManagedStruct_custom_free_priv(interp, rv , tmp);
            if (clonepriv == freepriv) {
                /* clonepriv is a copy of freepriv, make it a copy in the clone too. */
                SETATTR_ManagedStruct_custom_clone_priv(interp, rv , tmp);
                clonepriv = NULL; /* disable the clonepriv copying below */
            }
        }
        if (clonepriv) {
            void *tmp = mem_sys_allocate(sizeof (struct jit_buffer_private_data));
            memcpy(tmp, clonepriv, sizeof (struct jit_buffer_private_data));
            SETATTR_ManagedStruct_custom_clone_priv(interp, rv , tmp);
        }
    }

    /* copy the execmem buffer */
    if (PARROT_MANAGEDSTRUCT(pmc)->ptr) {
        struct jit_buffer_private_data *jit = (struct jit_buffer_private_data*)priv;
        void *ptr = PARROT_MANAGEDSTRUCT(pmc)->ptr;
        void *newptr = mem_alloc_executable(jit->size);
        if (!newptr)
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_JIT_ERROR,
                    "Cannot allocate executable memory");
        memcpy(newptr, ptr, jit->size);
        PARROT_MANAGEDSTRUCT(rv)->ptr = newptr;
    }

    return rv;
}


void
Parrot_jit_newfixup(Parrot_jit_info_t *jit_info)
{
    Parrot_jit_fixup_t *fixup;

    fixup = mem_allocate_zeroed_typed(Parrot_jit_fixup_t);

    /* Insert fixup at the head of the list */
    fixup->next = jit_info->arena.fixups;
    jit_info->arena.fixups = fixup;

    /* Fill in the native code offset */
    fixup->native_offset =
        (ptrdiff_t)(jit_info->native_ptr - jit_info->arena.start);
}

INTVAL
get_nci_I(PARROT_INTERP, ARGMOD(call_state *st), int n)
{
    if (n >= st->src.n)
        Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
            "too few arguments passed to NCI function");

    Parrot_fetch_arg_nci(interp, st);

    return UVal_int(st->val);
}

FLOATVAL
get_nci_N(PARROT_INTERP, ARGMOD(call_state *st), int n)
{
    if (n >= st->src.n)
        Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
            "too few arguments passed to NCI function");

    Parrot_fetch_arg_nci(interp, st);

    return UVal_num(st->val);
}

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
STRING*
get_nci_S(PARROT_INTERP, ARGMOD(call_state *st), int n)
{
    /* TODO or act like below? */
    if (n >= st->src.n)
        Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION,
            "too few arguments passed to NCI function");

    Parrot_fetch_arg_nci(interp, st);

    return UVal_str(st->val);
}

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PMC*
get_nci_P(PARROT_INTERP, ARGMOD(call_state *st), int n)
{
    /*
     * excessive args are passed as NULL
     * used by e.g. MMD infix like __add
     */
    if (n < st->src.n)
        Parrot_fetch_arg_nci(interp, st);
    else
        UVal_pmc(st->val) = PMCNULL;

    return UVal_pmc(st->val);
}

/*
 * set return value
 */
void
set_nci_I(PARROT_INTERP, ARGOUT(call_state *st), INTVAL val)
{
    Parrot_init_ret_nci(interp, st, "I");
    if (st->dest.i < st->dest.n) {
        UVal_int(st->val) = val;
        Parrot_convert_arg(interp, st);
        Parrot_store_arg(interp, st);
    }
}

void
set_nci_N(PARROT_INTERP, ARGOUT(call_state *st), FLOATVAL val)
{
    Parrot_init_ret_nci(interp, st, "N");
    if (st->dest.i < st->dest.n) {
        UVal_num(st->val) = val;
        Parrot_convert_arg(interp, st);
        Parrot_store_arg(interp, st);
    }
}

void
set_nci_S(PARROT_INTERP, ARGOUT(call_state *st), STRING *val)
{
    Parrot_init_ret_nci(interp, st, "S");
    if (st->dest.i < st->dest.n) {
        UVal_str(st->val) = val;
        Parrot_convert_arg(interp, st);
        Parrot_store_arg(interp, st);
    }
}

void
set_nci_P(PARROT_INTERP, ARGOUT(call_state *st), PMC* val)
{
    Parrot_init_ret_nci(interp, st, "P");
    if (st->dest.i < st->dest.n) {
        UVal_pmc(st->val) = val;
        Parrot_convert_arg(interp, st);
        Parrot_store_arg(interp, st);
    }
}

int
emit_is8bit(long disp)
{
    return disp >= -128 && disp <= 127;
}

char *
emit_disp8_32(char *pc, int disp)
{
    if (emit_is8bit(disp)) {
        *(pc++) = (char)disp;
        return pc;
    }
    else {
        *(long *)pc = disp;
        return pc + 4;
    }
}

void
emit_sib(PARROT_INTERP, char *pc, int scale, int i, int base)
{
    int scale_byte;

    switch (scale) {
        case 1:
            scale_byte = emit_Scale_1;
            break;
        case 2:
            scale_byte = emit_Scale_2;
            break;
        case 4:
            scale_byte = emit_Scale_4;
            break;
        case 8:
            scale_byte = emit_Scale_8;
            break;
        default:
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_JIT_ERROR,
                "Invalid scale factor %d\n", scale);
            return;
    }

    *pc = (char)(scale_byte | (i == emit_None ? emit_Index_None : emit_reg_Index(i)) |
            emit_reg_Base(base));
}

char *
emit_r_X(PARROT_INTERP, char *pc, int reg_opcode, int base, int i, int scale, long disp)
{
    if (i && !scale)
        Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_JIT_ERROR,
            "emit_r_X passed invalid scale+index combo\n");

    if (base == emit_EBP) {
    /* modrm disp */
        if (i == emit_None) {
            *(pc++) = (char)((emit_is8bit(disp) ? emit_Mod_b01 : emit_Mod_b10)
                    | reg_opcode | emit_reg_rm(emit_EBP));
            return emit_disp8_32(pc, disp);
        }
        /* modrm sib disp */
        else {
            *(pc++) = (char)((emit_is8bit(disp) ? emit_Mod_b01 : emit_Mod_b10)
                    | reg_opcode | emit_b100);
            emit_sib(interp, pc++, scale, i, base);
            return emit_disp8_32(pc, disp);
        }
    }

    /* modrm sib disp */
    if (base == emit_ESP) {
        *(pc++) = (char)((emit_is8bit(disp) ? emit_Mod_b01 : emit_Mod_b10)
                | reg_opcode | emit_rm_b100);
        emit_sib(interp, pc++, scale, i, emit_ESP);
        return emit_disp8_32(pc, disp);
    }

    /* modrm disp32 */
    if (!base && !(i && scale)) {
        *(pc++) = (char)(emit_Mod_b00 | reg_opcode | emit_rm_b101);
        *(long *)pc = disp;
        return pc + 4;
    }

    /* Ok, everything should be more regular here */
    *(pc++) = (char)((disp == 0 ? emit_Mod_b00 :
              (emit_is8bit(disp) ?
               emit_Mod_b01 : emit_Mod_b10)) |
               reg_opcode |
               (!base || (scale && i) ? emit_rm_b100 : emit_reg_rm(base)));

    if (!base || (scale && i)) {
        emit_sib(interp, pc++, scale, i, base);
    }
    if (disp)
        pc = emit_disp8_32(pc, disp);

    return pc;
}

char *
emit_shift_i_r(PARROT_INTERP, char *pc, int opcode, int imm, int reg)
{
    if (opcode == emit_b000 && imm < 0) {
        opcode = emit_b001;     /* -rol => 32 + ror */
        imm = -imm;
    }

    if (imm == 0) {
        /* noop */
    }
    else if (imm == 1) {
        *(pc++) = (char) 0xd1;
        *(pc++) = (char) emit_alu_X_r(opcode,  reg);
    }
    else if (imm > 1 && imm < 33) {
        *(pc++) = (char) 0xc1;
        *(pc++) = (char) emit_alu_X_r(opcode,  reg);
        *(pc++) = (char)imm;
    }
    else {
        Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_JIT_ERROR,
            "emit_shift_i_r passed invalid shift\n");
    }

    return pc;
}

char *
emit_popl_r(char *pc, int reg)
{
    *(pc++) = (char)(0x58 | (reg - 1));
    return pc;
}

int
intreg_is_used(Parrot_jit_info_t *jit_info, char reg)
{
    int i;
    const jit_arch_regs *reg_info;
    Parrot_jit_register_usage_t *ru = jit_info->optimizer->cur_section->ru;

    reg_info = jit_info->arch_info->regs + jit_info->code_type;

    for (i = 0; i < ru[0].registers_used; ++i) {
        if (reg_info->map_I[i] == reg) {
            return 1;
        }
    }
    return 0;
}

void call_func(Parrot_jit_info_t *jit_info, void (*addr) (void))
{
    Parrot_jit_newfixup(jit_info);
    jit_info->arena.fixups->type = JIT_X86CALL;
    jit_info->arena.fixups->param.fptr = D2FPTR(addr);
    emitm_calll(jit_info->native_ptr, 0xdeafc0de);
}

void jit_emit_real_exception(Parrot_jit_info_t *jit_info)
{
    call_func(jit_info, (void (*) (void)) & Parrot_ex_throw_from_c_args);
}

unsigned char *lastpc;

void
jit_emit_jcc(Parrot_jit_info_t *jit_info, int code, opcode_t disp)
{
    long offset;
    opcode_t opcode;

    opcode = jit_info->op_i + disp;

    if (opcode <= jit_info->op_i) {
        offset = jit_info->arena.op_map[opcode].offset -
                (jit_info->native_ptr - jit_info->arena.start);

        /* If we are here, the current section must have a branch_target
           section, I think. */
        if (jit_info->optimizer->cur_section->branch_target ==
            jit_info->optimizer->cur_section)
                offset +=
                    jit_info->optimizer->cur_section->branch_target->load_size;

        if (emit_is8bit(offset - 2)) {
            emitm_jxs(jit_info->native_ptr, code, offset - 2);
        }
        else {
            emitm_jxl(jit_info->native_ptr, code, offset - 6);
        }

        return;
    }

    Parrot_jit_newfixup(jit_info);
    jit_info->arena.fixups->type = JIT_X86BRANCH;
    jit_info->arena.fixups->param.opcode = opcode;
    /* If the branch is to the current section, skip the load instructions. */
    if (jit_info->optimizer->cur_section->branch_target ==
        jit_info->optimizer->cur_section)
            jit_info->arena.fixups->skip =
                (char)jit_info->optimizer->cur_section->branch_target->load_size;

    emitm_jxl(jit_info->native_ptr, code, 0xc0def00d);
}

void
emit_jump(Parrot_jit_info_t *jit_info, opcode_t disp)
{
    long offset;
    opcode_t opcode;

    opcode = jit_info->op_i + disp;

    if (opcode <= jit_info->op_i) {
        offset = jit_info->arena.op_map[opcode].offset -
                                (jit_info->native_ptr - jit_info->arena.start);
        if (emit_is8bit(offset - 2)) {
            emitm_jumps(jit_info->native_ptr, (char)(offset - 2));
        }
        else {
            emitm_jumpl(jit_info->native_ptr, offset - 5);
        }
        return;
    }

    Parrot_jit_newfixup(jit_info);
    jit_info->arena.fixups->type = JIT_X86JUMP;
    jit_info->arena.fixups->param.opcode = opcode;
    /* If the branch is to the current section, skip the load instructions. */
    if (jit_info->optimizer->cur_section->branch_target ==
        jit_info->optimizer->cur_section)
            jit_info->arena.fixups->skip =
                (char)jit_info->optimizer->cur_section->branch_target->load_size;
    emitm_jumpl(jit_info->native_ptr, 0xc0def00d);
}

#  define NATIVECODE jit_info->native_ptr

/*
 * preserve registers around a functioncall
 *
 * all used register around a call (skip >= 0 := return result
 *
 * TODO factor out common code
 *      use jit_emit_mov_RM_{in} functions (load/store base indexed)
 *      and a macro to retrieve sp
 */
int
jit_save_regs_call(Parrot_jit_info_t *jit_info, PARROT_INTERP, int skip)
{
    int i, used_i, used_n;
    const jit_arch_regs *reg_info;

    used_i = Parrot_pcc_get_regs_used(interp, CURRENT_CONTEXT(interp), REGNO_INT);
    used_n = Parrot_pcc_get_regs_used(interp, CURRENT_CONTEXT(interp), REGNO_NUM);
    jit_emit_sub_ri_i(interp, jit_info->native_ptr, emit_ESP,
            (used_i * sizeof (INTVAL) + used_n * sizeof (FLOATVAL)));
    reg_info = &jit_info->arch_info->regs[jit_info->code_type];
    for (i = 0; i < used_i; ++i) {
        /* XXX need 2 skip vars */
        if (reg_info->map_I[i] == skip)
            continue;
        emitm_movl_r_m(interp, NATIVECODE, reg_info->map_I[i], emit_ESP,
                            emit_None, 1,
                            (used_n * sizeof (FLOATVAL) +
                             i      * sizeof (INTVAL)));
    }
    for (i = 0; i < used_n; ++i) {
        if (reg_info->map_F[i] == skip)
            continue;
        emitm_fld(NATIVECODE, reg_info->map_F[i]);
        jit_emit_fstore_mb_n(interp, NATIVECODE, emit_ESP, (i * sizeof (FLOATVAL)));
    }
    return used_n;
}

void
jit_restore_regs_call(Parrot_jit_info_t *jit_info, PARROT_INTERP,
        int skip)
{

    int i, used_i, used_n;
    const jit_arch_regs *reg_info;

    used_i = Parrot_pcc_get_regs_used(interp, CURRENT_CONTEXT(interp), REGNO_INT);
    used_n = Parrot_pcc_get_regs_used(interp, CURRENT_CONTEXT(interp), REGNO_NUM);
    reg_info = &jit_info->arch_info->regs[jit_info->code_type];

    for (i = 0; i < used_i; ++i) {
        if (reg_info->map_I[i] == skip)
            continue;
        emitm_movl_m_r(interp, NATIVECODE, reg_info->map_I[i], emit_ESP,
                            emit_None, 1,
                            (used_n * sizeof (FLOATVAL) +
                             i      * sizeof (INTVAL)));
    }
    for (i = 0; i < used_n; ++i) {
        if (reg_info->map_F[i] == skip)
            continue;
        jit_emit_fload_mb_n(interp, NATIVECODE, emit_ESP, (i * sizeof (FLOATVAL)));
        emitm_fstp(NATIVECODE, (1+reg_info->map_F[i]));
    }

    jit_emit_add_ri_i(interp, jit_info->native_ptr, emit_ESP,
            (used_i * sizeof (INTVAL) + used_n * sizeof (FLOATVAL)));
}

int control_word = 0x27f;

/*
 * params are put rigth to left on the stack
 * parrot registers are counted left to right
 * so this function returns for a given register type
 * the needed register number
 * TODO handel overflow params
 */

int
count_regs(PARROT_INTERP, char *sig, char *sig_start)
{
    const char *typs[] = {
        "Ilisc",         /* I */
        "StbB",          /* S */
        "pP234",         /* P */
        "Nfd"            /* N */
    };
    int first_reg = 0;
    int i, found;

    /* char at sig is the type to look at */
    for (found = -1, i = 0; i < 4; i++) {
        if (strchr(typs[i], *sig)) {
            found = i;
            break;
        }
    }

    if (found == -1)
        Parrot_ex_throw_from_c_args(interp, NULL, 1,
            "Parrot_jit_build_call_func: sig char not found\n");

    for (--sig; sig > sig_start; --sig) {
        if (strchr(typs[found], *sig)) {
            ++first_reg;
        }
    }
    return first_reg;
}

size_t
calc_signature_needs(const char *sig, int *strings)
{
    size_t stack_size = 0;
    while (*sig) {
        switch (*sig) {
            case 't':
                (*strings)++;
                stack_size +=4;
                break;
            case 'd':
                stack_size +=8;
                break;
            default:
                stack_size +=4;
                break;
        }
        sig++;
    }
    return stack_size;

}

/*
 * The function generated here is called as func(interp, nci_info)
 * interp   ...  8(%ebp)
 * nci_info ... 12(%ebp)
 *
 * The generate function for a specific signature looks quite similar to
 * an optimized compile of src/nci.c:pcf_x_yy(). In case of any troubles
 * just compare the disassembly.
 *
 * If a non-NULL sizeptr is passed, the integer it points to will be written
 * with the size of the allocated execmem buffer.
 */

void *
Parrot_jit_build_call_func(PARROT_INTERP, PMC *pmc_nci, STRING *signature, int *sizeptr)
{
    Parrot_jit_info_t jit_info;
    char     *pc;
    int       i                    = 0;
    int       arg_count            = 0;
    int       string_buffer_count  = 0;
    const int ST_SIZE_OF           = 124;
    const int JIT_ALLOC_SIZE       = 1024;

    char      *signature_str      = Parrot_str_to_cstring(interp, signature);
    /* skip over the result */
    char      *sig                = signature_str + 1;
    size_t     stack_space_needed = calc_signature_needs(sig,
                                        &string_buffer_count);

    int base_offset        = 0;
    int strings_offset     = base_offset - (sizeof (char *) * string_buffer_count);
    int st_offset          = strings_offset - ST_SIZE_OF;
    int args_offset        = st_offset - stack_space_needed;
    int temp_calls_offset  = args_offset - 16;
    int total_stack_needed = -temp_calls_offset;

    /*
     * ESP
     * 0-15, 16 bytes for utility calls
     * stack_space_needed for actual NCI call
     * st
     * STRINGS -> char * holding space
     * EBP
     */

    /* this ought to be enough - the caller of this function
     * should free the function pointer returned here
     */
    pc = jit_info.native_ptr = jit_info.arena.start = (char *)mem_alloc_executable(JIT_ALLOC_SIZE);
    if (! pc)
        Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_JIT_ERROR,
                "Cannot allocate executable memory");


    /* this generated jit function will be called as (INTERP (EBP 8), func_ptr
    * (ESP 12), args signature (ESP 16)) */

    /* make stack frame, preserve %ebx */
    jit_emit_stack_frame_enter(pc);

    emitm_subl_i_r(pc, total_stack_needed, emit_ESP);

    /* Parrot_init_arg_nci(interp, &st, "S"); */
    /* args signature "S" */
    emitm_movl_m_r(interp, pc, emit_EAX, emit_EBP, 0, 1, 16);
    emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 8);

    /*&st*/
    emitm_lea_m_r(interp,  pc, emit_EAX, emit_EBP, 0, 1, st_offset);
    emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 4);

    /*interpreter*/
    emitm_movl_m_r(interp, pc, emit_EAX, emit_EBP, 0, 1, 8);
    emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 0);

    if (sig && *sig)
      emitm_call_cfunc(pc, Parrot_init_arg_nci);

    while (*sig) {
        emitm_movl_i_m(pc, arg_count, emit_EBP, 0, 1, temp_calls_offset + 8);

        switch (*sig) {
            case '0':    /* null ptr or such - doesn't consume a reg */
                jit_emit_bxor_rr_i(interp, pc, emit_EAX, emit_EAX);
                emitm_movl_m_r(interp, pc, emit_EAX, emit_EBP, 0, 1, args_offset);
                break;
            case 'f':
                emitm_call_cfunc(pc, get_nci_N);
                emitm_fstps(interp, pc, emit_EBP, 0, 1, args_offset);
                break;
            case 'N':
            case 'd':
                emitm_call_cfunc(pc, get_nci_N);
                emitm_fstpl(interp, pc, emit_EBP, 0, 1, args_offset);
                args_offset += 4;
                break;
            case 'I':   /* INTVAL */
            case 'l':   /* long */
            case 'i':   /* int */
                emitm_call_cfunc(pc, get_nci_I);
                emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, args_offset);
                break;
            case 't':   /* string, pass a cstring */
                emitm_call_cfunc(pc, get_nci_S);
                emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 4);
                emitm_call_cfunc(pc, string_to_cstring_nullable);

                emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, args_offset);
                /* save off temporary allocation address */
                emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, strings_offset);
                strings_offset += 4;

                /* reset ESP(4) */
                emitm_lea_m_r(interp, pc, emit_EAX, emit_EBP, 0, 1, st_offset);
                emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 4);
                break;
            case 's':   /* short: movswl intreg_o(base), %eax */
                emitm_call_cfunc(pc, get_nci_I);
                emitm_movswl_r_r(pc, emit_EAX, emit_EAX);
                emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, args_offset);
                break;
            case 'c':   /* char: movsbl intreg_o(base), %eax */
                emitm_call_cfunc(pc, get_nci_I);
                emitm_movsbl_r_r(pc, emit_EAX, emit_EAX);
                emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, args_offset);
                break;
            case 'J':   /* interpreter */
                emitm_movl_m_r(interp, pc, emit_EAX, emit_EBP, 0, 1, 8);
                emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, args_offset);
                arg_count--;
                break;
            case 'p':   /* push pmc->data */
                emitm_call_cfunc(pc, get_nci_P);
                /* save off PMC* */
                emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 4);
                /* lookup get_pointer in VTABLE */
                emitm_movl_m_r(interp, pc, emit_EAX, emit_EAX, 0, 1, offsetof(PMC, vtable));
                emitm_movl_m_r(interp, pc, emit_EAX, emit_EAX, 0, 1, offsetof(VTABLE, get_pointer));
                emitm_callr(pc, emit_EAX);
                emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, args_offset);
                /* reset ESP(4) */
                emitm_lea_m_r(interp, pc, emit_EAX, emit_EBP, 0, 1, st_offset);
                emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 4);

                break;
            case 'O':   /* push PMC * object in P2 */
            case 'P':   /* push PMC * */
            case '@':
                emitm_call_cfunc(pc, get_nci_P);
#if PARROT_CATCH_NULL
                /* PMCNULL is a global */
                jit_emit_cmp_rm_i(pc, emit_EAX, &PMCNULL);
                emitm_jxs(pc, emitm_jne, 2); /* skip the xor */
                jit_emit_bxor_rr_i(interp, pc, emit_EAX, emit_EAX);
#endif
                emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, args_offset);
                break;
            case 'v':
                break;
            case 'b':   /* buffer (void*) pass Buffer_bufstart(SReg) */
                emitm_call_cfunc(pc, get_nci_S);
                emitm_movl_m_r(interp, pc, emit_EAX, emit_EAX, 0, 1,
                               (size_t) &Buffer_bufstart((STRING *) NULL));
                emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, args_offset);
                break;
            case 'B':   /* buffer (void**) pass &Buffer_bufstart(SReg) */
                emitm_call_cfunc(pc, get_nci_S);
                emitm_lea_m_r(interp, pc, emit_EAX, emit_EAX, 0, 1,
                              (size_t) &Buffer_bufstart((STRING *) NULL));
                emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, args_offset);
                break;
            case 'S':
                emitm_call_cfunc(pc, get_nci_S);
                emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, args_offset);
                break;


            /* I have no idea how to handle these */
            case '2':
            case '3':
            case '4':
            case 'V':
                mem_free_executable(jit_info.native_ptr, JIT_ALLOC_SIZE);
                Parrot_str_free_cstring(signature_str);
                return NULL;
                break;
            default:
                Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_JIT_ERROR,
                    "Unknown arg Signature %c\n", *sig);
                /*
                 * oops unknown signature:
                 * cleanup and try nci.c
                 */
                mem_free_executable(jit_info.native_ptr, JIT_ALLOC_SIZE);
                Parrot_str_free_cstring(signature_str);
                return NULL;
        }
        args_offset +=4;
        arg_count++;
        sig++;
    }

    /* prepare to call VTABLE_get_pointer, set up args */
    /* interpreter - movl 8(%ebp), %eax */
    emitm_movl_m_r(interp, pc, emit_EAX, emit_EBP, 0, 1, 8);
    emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 0);

    /* pmc - movl 12(%ebp), %eax */
    emitm_movl_m_r(interp, pc, emit_EAX, emit_EBP, 0, 1, 12);
    emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 4);

    /* get the get_pointer() pointer from the pmc's vtable */
    emitm_movl_m_r(interp, pc, emit_EAX, emit_EAX, 0, 1, offsetof(PMC, vtable));
    emitm_movl_m_r(interp, pc, emit_EAX, emit_EAX, 0, 1, offsetof(VTABLE, get_pointer));

    /* call get_pointer(), result goes into eax */
    emitm_callr(pc, emit_EAX);
    emitm_addl_i_r(pc, 16, emit_ESP);

    /* call the resulting function pointer */
    emitm_callr(pc, emit_EAX);
    emitm_subl_i_r(pc, 16, emit_ESP);

    /* SAVE OFF EAX */
    emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 8);

    /*&st*/
    emitm_lea_m_r(interp, pc, emit_EAX, emit_EBP, 0, 1, st_offset);
    emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 4);

    /*interpreter*/
    emitm_movl_m_r(interp, pc, emit_EAX, emit_EBP, 0, 1, 8);
    emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 0);

    /* RESTORE BACK EAX */
    emitm_movl_m_r(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 8);

    /* now place return value in registers */
    /* first in signature is the return value */
    sig = signature_str; /* the result */
    switch (*sig) {
        /* I have no idea how to handle these */
        case '2':
        case '3':
        case '4':
            /* get integer from pointer - untested */
            emitm_movl_m_r(interp, pc, emit_EAX, emit_EAX, 0, 1, 0);
            if (*sig == 2)      /* short */
                emitm_movswl_r_r(pc, emit_EAX, emit_EAX);
            emitm_call_cfunc(pc, set_nci_I);
            break;
        case 'f':
        case 'd':
            jit_emit_fstore_mb_n(interp, pc, emit_EBP, temp_calls_offset + 8);
            emitm_call_cfunc(pc, set_nci_N);
            /* pop num from st(0) and mov to reg */
            break;
        case 's':
            /* movswl %ax, %eax */
            emitm_movswl_r_r(pc, emit_EAX, emit_EAX);
            emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 8);
            emitm_call_cfunc(pc, set_nci_I);
            break;
        case 'c':
            /* movsbl %al, %eax */
            emitm_movsbl_r_r(pc, emit_EAX, emit_EAX);
            emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 8);
            emitm_call_cfunc(pc, set_nci_I);
            break;
        case 'I':   /* INTVAL */
        case 'l':
        case 'i':
            emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 8);
            emitm_call_cfunc(pc, set_nci_I);
            break;
        case 'v': /* void - do nothing */
            break;
        case 'P':
            emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 8);
            emitm_call_cfunc(pc, set_nci_P);
            break;
        case 'p':   /* make a new unmanaged struct */
            /* save return value on stack */

            /* save pointer p */
            emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 12);

            /* make new pmc */
            emitm_movl_i_m(pc, enum_class_UnManagedStruct, emit_EBP, 0, 1, temp_calls_offset + 4);
            emitm_call_cfunc(pc, pmc_new);

            /* restore pointer p to EDX */
            emitm_movl_m_r(interp, pc, emit_EDX, emit_EBP, 0, 1, temp_calls_offset + 12);

            /* copy UnManagedStruct to stack for set_nci_P call */
            emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 8);

            /* eax = PMC, get return value into edx */
            /* mov data(%eax), %eax
               mov %edx, ptr(%eax) */
            emitm_movl_m_r(interp, pc, emit_EAX, emit_EAX, 0, 1, offsetof(struct PMC, data));
            emitm_movl_r_m(interp, pc, emit_EDX, emit_EAX, 0, 1,
                           offsetof(struct Parrot_UnManagedStruct_attributes, ptr));

            /* reset EBP(4) */
            emitm_lea_m_r(interp, pc, emit_EAX, emit_EBP, 0, 1, st_offset);
            emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 4);

            emitm_call_cfunc(pc, set_nci_P);
            break;
        case 'S':
            emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 8);
            emitm_call_cfunc(pc, set_nci_S);
            break;
        case 't':   /* string */
            /* EAX is char* */
            emitm_movl_i_m(pc, 0, emit_EBP, 0, 1, temp_calls_offset + 8); /* len */

            /* overwrites address of st in EBP(4) */
            emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 4);

            emitm_call_cfunc(pc, Parrot_str_new);

            emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 8);

            /* reset EBP(4) */
            emitm_lea_m_r(interp, pc, emit_EAX, emit_EBP, 0, 1, st_offset);
            emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 4);

            emitm_call_cfunc(pc, set_nci_S);
            break;
        default:
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_JIT_ERROR,
                "Unknown return Signature %c\n", *sig);
            /*
             * oops unknown signature:
             * cleanup and try nci.c
             */
            Parrot_str_free_cstring(signature_str);
            mem_free_executable(jit_info.native_ptr, JIT_ALLOC_SIZE);
            return NULL;
    }

    /* free temporary strings */
    strings_offset = st_offset + ST_SIZE_OF;
    for (i=0; i<string_buffer_count; i++) {
        emitm_movl_m_r(interp, pc, emit_EAX, emit_EBP, 0, 1, strings_offset);
        emitm_movl_r_m(interp, pc, emit_EAX, emit_EBP, 0, 1, temp_calls_offset + 0);
        emitm_call_cfunc(pc, Parrot_str_free_cstring);
        strings_offset += 4;
    }

    jit_emit_stack_frame_leave(pc);
    emitm_ret(pc);
    PARROT_ASSERT(pc - jit_info.arena.start <= JIT_ALLOC_SIZE);

    /* could shrink arena.start here to used size */

    if (sizeptr)
        *sizeptr = JIT_ALLOC_SIZE;
    Parrot_str_free_cstring(signature_str);
    return (void *)D2FPTR(jit_info.arena.start);
}

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
