/*
 * pcc.c
 *
 * A specific calling convention implementation. Called by the generic
 * API for subs (see sub.c).
 *
 * FASTCALL convention can be enabled with:
 * .pragma fastcall
 * at the start of an IMC module.
 *
 * This will allow library developers (or non-Perl languages) to turn
 * on very efficient optimizations and a lightweight calling convention.
 * It could also be used for internal libs that do not callout to PCC
 * routines, but present PCC entry points for the module itself.
 *
 * XXX FIXME: FASTCALL is not currently finished and may not be completely
 * compatible with PCC convention. (ie. you can't mix and match, for now at least)
 *
 * see: docs/pdds/pdd03_calling_conventions.pod
 *
 * PCC Implementation by Leopold Toetsch
 */

#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "imc.h"
#include "parser.h"


/* Local definitions and static data for PCC code emitter.
 * This is more for making the code self-documenting than
 * making it easily configurable.
 */

/* For PCC prototyped subs, the params go in registers
 * 5-15 for each set (P,I,N,S)
 */
#define FIRST_PARAM_REG 5
#define LAST_PARAM_REG 15

#define REG_PROTO_FLAG    0
#define REG_I_PARAM_COUNT 1
#define REG_S_PARAM_COUNT 2
#define REG_P_PARAM_COUNT 3
#define REG_N_PARAM_COUNT 4

#define REGSET_I 0
#define REGSET_S 1
#define REGSET_P 2
#define REGSET_N 3
#define REGSET_MAX 4

static const char regsets[] = "ISPN";

/*
 * Utility instruction routine. Creates and inserts an instruction
 * into the current block in one call.
 */
static Instruction *
insINS(Parrot_Interp interp, IMC_Unit * unit, Instruction *ins,
        char *name, SymReg **regs, int n)
{
    Instruction *tmp = INS(interp, unit, name, NULL, regs, n, 0, 0);
    insert_ins(unit, ins, tmp);
    return tmp;
}

/*
 * get or create the SymReg
 */
SymReg*
get_pasm_reg(Interp* interp, char *name)
{
    SymReg *r;

    if ((r = _get_sym(cur_unit->hash, name)))
        return r;
    return mk_pasm_reg(interp, str_dup(name));
}

SymReg*
get_const(Interp *interp, const char *name, int type)
{
    SymReg *r;

    if ((r = _get_sym(IMCC_INFO(interp)->ghash, name)) && r->set == type)
        return r;
    return mk_const(interp, str_dup(name), type);
}

/*
 * set arguments or return valurs
 * get params or results
 * used by expand_pcc_sub_call and expand_pcc_sub
 */
static Instruction*
pcc_get_args(Parrot_Interp interp, IMC_Unit * unit, Instruction *ins,
        char *op_name, int n, SymReg **args)
{
    int i, l, flags;
    char buf[1024], s[16];
    SymReg **regs, *arg;

    regs = mem_sys_allocate((n + 1) * sizeof(SymReg *));
    strcpy(buf, "\"(");
    for (i = 0; i < n; i++) {
        arg = args[i];
        regs[i + 1] = arg;
        flags = 0;
        if (arg->type & VT_FLAT) {
            flags |= PARROT_ARG_FLATTEN;
        }
        if (arg->type & VT_OPTIONAL) {
            flags |= PARROT_ARG_OPTIONAL;
        }
        sprintf(s, "%d", flags);
        if (i < n - 1)
            strcat(s, ",");
        l = strlen(s);
        strcat(buf, s);         /* XXX check avail len */
    } /* n params */
    strcat(buf, ")\"");
    regs[0] = mk_const(interp, str_dup(buf), 'S');
    ins = insINS(interp, unit, ins, op_name, regs, n + 1);
    mem_sys_free(regs);
    return ins;
}


/*
 * Expand a PCC (Parrot Calling Convention) subroutine
 * by generating the appropriate prologue and epilogue
 * for parameter passing/returning.
 */
void
expand_pcc_sub(Parrot_Interp interp, IMC_Unit * unit, Instruction *ins)
{
    SymReg *sub;
    int nargs;
    Instruction *tmp;
    SymReg *i0, *regs[IMCC_MAX_REGS], *label1, *label2;
    char buf[128];

    sub = ins->r[1];

    /* Don't generate any parameter checking code if there
     * are no named arguments.
     */
    if (sub->pcc_sub->nargs) {
        i0 = NULL;
        label1 = label2 = NULL;

        nargs = sub->pcc_sub->nargs;
        ins = pcc_get_args(interp, unit, ins, "get_params", nargs,
                           sub->pcc_sub->args);
    }

    /*
     * if this sub references self, fetch it
     */
    if (unit->type & IMC_HAS_SELF) {
        regs[0] = get_sym("self");
        assert(regs[0]);

        sprintf(buf, "%d", CURRENT_OBJECT);
        regs[1] = get_const(interp, buf, 'I');
        ins = insINS(interp, unit, ins, "interpinfo", regs, 2);
    }

    /*
     * check if there is a return
     */
    if (unit->last_ins->type != (ITPCCSUB|ITLABEL) &&
            strcmp(unit->last_ins->op, "ret") &&
            strcmp(unit->last_ins->op, "exit") &&
            strcmp(unit->last_ins->op, "end")
       ) {
        if (sub->pcc_sub->pragma & P_MAIN) {
            tmp = INS(interp, unit, "end", NULL, regs, 0, 0, 0);
        }
        else {
            tmp = INS(interp, unit, "returncc", NULL, regs, 0, 0, 0);
        }
        IMCC_debug(interp, DEBUG_IMC, "add sub ret - %I\n", tmp);
        insert_ins(unit, unit->last_ins, tmp);
    }

    /*
     * a coroutine (generator) needs a small hook that gets called
     * from the shift_pmc() vtable
     */
    if (sub->pcc_sub->calls_a_sub & ITPCCYIELD) {
        /*
         * set P0, P5
         * invokecc
         * end
         */
        ins = unit->last_ins;
        regs[0] = get_pasm_reg(interp, "P0");
        regs[1] = get_pasm_reg(interp, "P5");
        ins = insINS(interp, unit, ins, "set", regs, 2);
        ins = insINS(interp, unit, ins, "invokecc", regs, 0);
        ins = insINS(interp, unit, ins, "end", regs, 0);
    }

}


/*
 * Expand a PCC sub return directive into its PASM instructions
 */
void
expand_pcc_sub_ret(Parrot_Interp interp, IMC_Unit * unit, Instruction *ins)
{
    SymReg *sub, *regs[IMCC_MAX_REGS];
    int  n, is_yield;

    is_yield = ins->type & ITPCCYIELD;

    /* TODO implement return conventions */
    sub = ins->r[0];
    n = sub->pcc_sub->nret;
    ins = pcc_get_args(interp, unit, ins, "set_returns", n,
                       sub->pcc_sub->ret);

    /*
     * we have a pcc_begin_yield
     */
    if (is_yield) {
        char buf[16];
        /*
         * get current sub
         *
         */
        regs[0] = get_pasm_reg(interp, "P0");
        sprintf(buf, "%d", CURRENT_SUB);
        regs[1] = get_const(interp, buf, 'I');
        ins = insINS(interp, unit, ins, "interpinfo", regs, 2);
        ins = insINS(interp, unit, ins, "invoke", regs, 0);
    }
    else {
        /*
         * insert return invoke
         */
        ins = insINS(interp, unit, ins, "returncc", regs, 0);
    }
    /*
     * move the pcc_sub structure to the invoke
     */
    ins->r[0] = sub;

    /*
     * mark the invoke instruction's PCC sub type
     */
    ins->type |= is_yield ? ITPCCYIELD : (ITPCCRET|ITPCCSUB);
}

#define CREATE_TAIL_CALLS

#ifdef CREATE_TAIL_CALLS
/*
 * check for a sequence of
 *   .pcc_begin
 *   ... [1]
 *   .pcc_end
 *   .pcc_begin_return
 *   ... [2]
 *   .pcc_end_return
 *   <end>
 * with the results in [1] matching return values in [2]
 */
static int
check_tail_call(Parrot_Interp interp, IMC_Unit * unit, Instruction *ins)
{
    Instruction *tmp, *ret_ins;
    int i, j, matching, nrets;
    struct pcc_sub_t *call, *ret;
    UNUSED(unit);
    /*
     * currently only with -Oc
     */
    if (!(IMCC_INFO(interp)->optimizer_level & OPT_SUB))
        return 0;
    if (!ins->type & ITPCCSUB)
        return 0;
    ret_ins = NULL;
    tmp = ins->next;
    if (!tmp)
        return 0;
    if (tmp->opnum == -1 && (tmp->type & ITPCCSUB) &&
            (tmp->type & ITLABEL)) {
        ret_ins = tmp;
        IMCC_debug(interp, DEBUG_OPT1, "check tail call %I \n", ins);
    }
    /*
     * when a sub ends w/o any return sequence, the code
     * null I0 / null I3 / invoke Px
     * is already inserted, check for this sequence
     */
    else if (!strcmp(tmp->op, "null") &&
            tmp->r[0]->set == 'I' &&
            tmp->r[0]->color == 0) {
        tmp = tmp->next;
        if (!tmp)
            return 0;

        if (!strcmp(tmp->op, "null") &&
                tmp->r[0]->set == 'I' &&
                tmp->r[0]->color == 3) {
            tmp = tmp->next;
            if (!tmp)
                return 0;
        }
        else
            return 0;
        if (strcmp(tmp->op, "returncc"))
            return 0;
        IMCC_debug(interp, DEBUG_OPT1, "check tail call %I \n", tmp);
        nrets = 0;
        goto ok;
    }
    else
        return 0;
    /*
     * now check results vs returns
     */
    ret = ret_ins->r[0]->pcc_sub;
    nrets = ret->nret;
ok:

    call = ins->r[0]->pcc_sub;
    IMCC_debug(interp, DEBUG_OPT1, "\tcall call retvals %d retvals %d\n",
            call->nret, nrets);
    if (call->nret != nrets)
        return 0;
    for (matching = i = 0; i < call->nret; i++) {
        SymReg *c, *r;
        c = call->ret[i];
        for (j = 0; j < nrets; j++) {
            r = ret->ret[i];
            if (!strcmp(c->name, r->name) &&
                    c->set == r->set)
                ++matching;
        }
    }
    if (matching != call->nret)
        return 0;
    /*
     * suppress code generation for return sequence
     */
    if (ret_ins)
        ret_ins->type = 0;
    return 1;
}

static void
insert_tail_call(Parrot_Interp interp, IMC_Unit * unit,
        Instruction *ins, SymReg *sub, int meth_call, SymReg *s0)
{
    SymReg *regs[IMCC_MAX_REGS];

    if (meth_call) {
        s0 = s0 ? s0 : get_pasm_reg(interp, "S0");
        regs[0] = s0;
        ins = insINS(interp, unit, ins, "tailcallmethod", regs, 1);
    }
    else {
        regs[0] = get_pasm_reg(interp, "P0");
        ins = insINS(interp, unit, ins, "tailcall", regs, 1);
    }
    ins->type |= ITPCCSUB;
    ins->r[0]->pcc_sub = sub->pcc_sub;
    sub->pcc_sub = NULL;
}

#endif

static Instruction*
pcc_insert_signature(Parrot_Interp interp, IMC_Unit * unit, Instruction *ins,
        struct pcc_sub_t *pcc_sub)
{
    int i, n, m;
    SymReg *regs[IMCC_MAX_REGS];
    char buffer[20];    /* TODO is there a limit? */

    n = pcc_sub->nargs;
    buffer[0] = '"';
    if (pcc_sub->object) {
        buffer[1] = 'O';
        m = 2;
    }
    else
        m = 1;
    for (i = 0; i < n && i < 15; ++i) {
        buffer[m++] = pcc_sub->args[i]->set;
    }
    buffer[m++] = '"';
    buffer[m] = '\0';
    regs[0] = get_pasm_reg(interp, "S1");
    regs[1] = mk_const(interp, str_dup(buffer), 'S');
    ins = insINS(interp, unit, ins, "set", regs, 2);
    return ins;
}

/*
 * Expand a PCC subroutine call (IMC) into its PASM instructions
 * This is the nuts and bolts of pdd03 routine call style
 *
 */
void
expand_pcc_sub_call(Parrot_Interp interp, IMC_Unit * unit, Instruction *ins)
{
    SymReg *arg, *sub, *reg, *regs[IMCC_MAX_REGS];
    int  n;
    int need_cc;
    int tail_call;
    int meth_call = 0;
    SymReg *s0 = NULL;
    Instruction *get_name;

    sub = ins->r[0];
    tail_call = (sub->pcc_sub->flags & isTAIL_CALL);
#ifdef CREATE_TAIL_CALLS
    if (!tail_call) {
        tail_call = check_tail_call(interp, unit, ins);
        if (tail_call)
            IMCC_debug(interp, DEBUG_OPT1, "found tail call %I \n", ins);
    }
#endif

    if (sub->pcc_sub->object)
        meth_call = 1;

    /*
     * See if we need to create a temporary sub object for the short
     * function call syntax _f()
     */
    get_name = NULL;
    if (ins->type & ITCALL) {
        SymReg * the_sub = sub->pcc_sub->sub;
        if (!meth_call && the_sub->type == VTADDRESS) {
            /*
             * sub->pcc_sub->sub is an actual subroutine name,
             * not a variable.
             */
            reg = get_pasm_reg(interp, "P0");
            add_pcc_sub(sub, reg);
            /*
             * insert set_p_pc with the sub as constant
             */
            the_sub = dup_sym(the_sub);
            the_sub->set = 'p';
            the_sub->usage = U_FIXUP;
            the_sub->type = VTCONST;
            regs[0] = reg;
            regs[1] = the_sub;
            /*
             * set_p_pc gets replaced in imcc/pbc.c, if the
             * function can't located in the current namespace
             */
            get_name = INS(interp, unit, "set_p_pc", "", regs, 2, 0, 0);

            ins->type &= ~ITCALL;
        }
        else
            add_pcc_sub(sub, the_sub);
    }


    /*
     * insert get_name after args have been setup, so that
     * a possible MMD call can inspect the passed arguments
     */
    if (get_name) {
        /* for now, put a call signature in S1 */
        ins = pcc_insert_signature(interp, unit, ins, sub->pcc_sub);
        insert_ins(unit, ins, get_name);
        ins = get_name;
    }
    else
        ins = pcc_insert_signature(interp, unit, ins, sub->pcc_sub);


    /*
     * setup P0, and P2, S0 if method
     *
     * Due to implicit call arguments (call opcodes that
     * either take a Sub/P0, method/S2, return continuation/P1,
     * object/P2 or not)
     * this is really a mess
     */
    arg = sub->pcc_sub->sub;
    if (meth_call) {
        /* set S0, meth */
        regs[0] = get_pasm_reg(interp, "S0");;
        if (arg->set != 'P') {
            if ( (arg->type == VTIDENTIFIER ||
                        arg->type == VTPASM ||
                        arg->type == VTREG))
                s0 = arg;
            else
                s0 = mk_const(interp, str_dup(arg->name), 'S');
        }

        /* set P2, obj */
        if (sub->pcc_sub->object->color != 2) {
            regs[0] = get_pasm_reg(interp, "P2");
            regs[1] = sub->pcc_sub->object;
            if (regs[1]->set == 'S')
                ins = insINS(interp, unit, ins, "getclass", regs, 2);
            else
                ins = insINS(interp, unit, ins, "set", regs, 2);
        }
        if ((sub->pcc_sub->flags & isNCI) && (!meth_call || arg->set == 'P'))
            goto move_sub;
    }
    else {
move_sub:
        /* plain sub call */
        if (arg->color != 0) {
            reg = get_pasm_reg(interp, "P0");
            if (reg != arg) {
                regs[0] = reg;
                regs[1] = arg;
                arg->want_regno = 0;
                ins = insINS(interp, unit, ins, "set", regs, 2);
            }
        }
    }

    /*
     * if we have a tail call then
     * insert a tailcall opcode
     */
    if (tail_call) {
        if (!(meth_call && strcmp(s0->name, "\"instantiate\"") == 0)) {
            n = sub->pcc_sub->nargs;
            ins = pcc_get_args(interp, unit, ins, "set_args", n,
                    sub->pcc_sub->args);
            insert_tail_call(interp, unit, ins, sub, meth_call, s0);
            return;
        }
    }
    /*
     * if an explicit return continuation is passed, set it to P1
     */
    arg = sub->pcc_sub->cc;
    need_cc = 0;
    if (arg) {
        if (arg->color != 1) {
            reg = get_pasm_reg(interp, "P1");
            regs[0] = reg;
            regs[1] = arg;
            ins = insINS(interp, unit, ins, "set", regs, 2);
        }
    }
    else if (!(sub->pcc_sub->flags & isNCI))
        need_cc = 1;

    /*
     * insert arguments
     */
    n = sub->pcc_sub->nargs;
    ins = pcc_get_args(interp, unit, ins, "set_args", n,
                       sub->pcc_sub->args);
    /*
     * handle return results
     */
    n = sub->pcc_sub->nret;
    ins = pcc_get_args(interp, unit, ins, "get_results", n,
                       sub->pcc_sub->ret);
    /*
     * special case - instantiate looks like a method call
     * but is actually the instantiate object constructor opcode that
     * takes method-like arguments according to pdd03
     *
     * so convert to opcode and await the returned PMC as P5
     */
    if (meth_call && s0 && strcmp(s0->name, "\"instantiate\"") == 0) {
        SymReg *p5 = get_pasm_reg(interp, "P5");
        regs[0] = p5;
        ins = insINS(interp, unit, ins, "instantiate", regs, 1);
    }
    else {
        /*
         * if we reuse the continuation, update it
         */
        if (!(sub->pcc_sub->flags & isNCI))
            if (!need_cc)
                ins = insINS(interp, unit, ins, "updatecc", regs, 0);
        /* insert the call */
        if (meth_call && sub->pcc_sub->sub->set != 'P') {
            regs[0] = s0;
            n = 0;
            if (s0)
                n = 1;
            ins = insINS(interp, unit, ins,
                    need_cc ? "callmethodcc" : "callmethod", regs, n);
        }
        else
            ins = insINS(interp, unit, ins,
                    need_cc ? "invokecc" : "invoke", regs, 0);
        ins->type |= ITPCCSUB;
        /*
         * move the pcc_sub structure to the invoke
         */
        ins->r[0] = meth_call ? s0 ? s0 : get_pasm_reg(interp, "S0") :
            get_pasm_reg(interp, "P0");
        ins->r[0]->pcc_sub = sub->pcc_sub;
        sub->pcc_sub = NULL;
        sub = ins->r[0];
        /*
         * locate return label, if there is one skip it
         */
        if (sub->pcc_sub->label && ins->next->type == ITLABEL) {
            ins = ins->next;
        }
    }
}


/*
 * special peephole optimizer for code generated mainly by
 * above functions
 */
void
pcc_sub_optimize(Parrot_Interp interp, IMC_Unit * unit)
{
    Instruction *ins, *tmp;
    IMCC_info(interp, 2, "\tpcc_sub_optimize\n");
    for (ins = unit->instructions; ins; ins = ins->next) {
        if (ins->opsize == 3 &&
                ins->r[1]->type == VTCONST &&
                (ins->r[0]->set == 'I' || ins->r[0]->set == 'N') &&
                ins->r[1]->name[1] != 'b' &&
                ins->r[1]->name[1] != 'B' &&
                ins->r[1]->name[1] != 'x' &&
                ins->r[1]->name[1] != 'X' &&
                atof(ins->r[1]->name) == 0.0 &&
                !strcmp(ins->op, "set")) {
            IMCC_debug(interp, DEBUG_OPT1, "opt1 %I => ", ins);
            tmp = INS(interp, unit,"null", NULL, ins->r, 1, 0, 0);
            IMCC_debug(interp, DEBUG_OPT1, "%I\n", tmp);
            subst_ins(unit, ins, tmp, 1);
            ins = tmp;
        }
        else if (ins->opsize == 3 &&
                !strcmp(ins->op, "set")) {
            SymReg *r0 = ins->r[0];
            SymReg *r1 = ins->r[1];
            if (r0->set == r1->set && r0->color == r1->color &&
                    r0->type == r1->type) {
                IMCC_debug(interp, DEBUG_OPT1, "opt1 %I => ", ins);
                ins = delete_ins(unit, ins, 1);
                ins = ins->prev ? ins->prev : unit->instructions;
                IMCC_debug(interp, DEBUG_OPT1, "deleted\n");
                ostat.deleted_ins++;
            }
        }
    }
}

/*
 * Check argument symbols of a sub and see which are used
 * Return 0 if none are used, 1 if at least 1 symbol is used.
 */
static int
pcc_args(Instruction* ins, SymReg* r)
{
    int i;
    SymReg * sub;
    struct pcc_sub_t * pcc;

    sub = ins->r[0];
    assert(sub && sub->pcc_sub);
    pcc = sub->pcc_sub;
    for (i = 0; i < pcc->nargs; i++)
        if (r == pcc->args[i]->used)
            return 1;
    return 0;
}

/*
 * Check return symbols of a sub and see which are used
 * Return 0 if none are used, 1 if at least 1 symbol is used.
 *
 * TODO this is likely unneeded - all registers in the volatile
 *      range are possible return results and clobbered, so we
 *      can't assign registers in that range
 */
static int
pcc_ret(Instruction* ins, SymReg* r)
{
    int i;
    SymReg * sub;
    struct pcc_sub_t * pcc;

    sub = ins->r[0];
    assert(sub && sub->pcc_sub);
    pcc = sub->pcc_sub;
    for (i = 0; i < pcc->nret; i++)
        if (r == pcc->ret[i]->used)
            return 1;
    return 0;
}

/*
 * See if the sub writes to the symbol, checks args and returns
 */
int
pcc_sub_writes(Instruction* ins, SymReg* r)
{
    if (ins->type & ITPCCRET)
        return 0;
    return pcc_ret(ins, r) || pcc_args(ins, r);
}

/*
 * See if the sub reads the symbol, checks args and returns
 */
int
pcc_sub_reads(Instruction* ins, SymReg* r)
{
    SymReg * sub, *arg;
    struct pcc_sub_t * pcc;

    sub = ins->r[0];
    assert(sub && sub->pcc_sub);
    pcc = sub->pcc_sub;
    if ( (arg = pcc->cc) )
        if (arg == r)
            return 1;
    if (r->set == 'I' && r->color <= 4 && r->color >= 0)
        return 1;
    if (r->set == 'P' && r->color <= 3 && r->color >= 0)
        return 1;
    if (ins->type & ITPCCRET)
        return pcc_ret(ins, r);
    return pcc_args(ins, r);
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
