%{
/*
 * imcc.y
 *
 * Intermediate Code Compiler for Parrot.
 *
 * Copyright (C) 2002 Melvin Smith <melvin.smith@mindspring.com>
 *
 * Grammar for the parser.
 *
 */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#define _PARSER
#define MAIN
#include "imc.h"
#include "pbc.h"
#include "parser.h"

#define YYDEBUG 1
#define YYERROR_VERBOSE 1

/*
 * we use a pure parser wtih the interpreter as a parameter
 * this still doesn't make the parser reentrant, there are too
 * many globals around.
 * These globals should go into one structure, which could be
 * attached to the interpreter
 */

#define YYPARSE_PARAM interp
#define YYLEX_PARAM interp
/*
 * Choosing instructions for Parrot is pretty easy since
 * many are polymorphic.
 */


static SymReg *keys[IMCC_MAX_REGS];
static int nkeys = 0;

static SymReg ** RR(int n, ...)
{
    va_list ap;
    int i = 0;

    va_start(ap, n);
    while (n--) {
	regs[i++] = va_arg(ap, SymReg *);
    }
    va_end(ap);
    while (i < IMCC_MAX_REGS)
	regs[i++] = 0;
    return regs;
}

/* macros for registers */
#define R0() 		RR(nargs=0)
#define R1(r0) 		RR(nargs=1,r0)
#define R2(r0,r1) 	RR(nargs=2,r0,r1)
#define R3(r0,r1,r2) 	RR(nargs=3,r0,r1,r2)
#define R4(r0,r1,r2,r3) RR(nargs=4,r0,r1,r2,r3)


/*
 * MK_I: build and emitb instruction by iANY
 *
 * fmt may contain:
 *   op %s, %s # comment
 * or just
 *   op
 *
 */
static
Instruction *
MK_I(struct Parrot_Interp *interpreter, const char * fmt, SymReg ** r)
{
    char opname[64];
    char *p;
    const char *q;
    for (p = opname, q = fmt; *q && *q != ' '; )
	*p++ = *q++;
    *p = 0;
    if (!*q)
	fmt = 0;
    else
	fmt = ++q;
#if OPDEBUG
    fprintf(stderr, "op '%s' format '%s' (%d)\n", opname, fmt?:"",nargs);
#endif
    return iANY(interpreter, opname, fmt, r, 1);
}

/*
 * special instructions
 *
 * labels and such
 */


static void clear_state(void)
{
    nargs = 0;
    keyvec = 0;
    memset(regs, 0, sizeof(regs));
}


Instruction * INS_LABEL(SymReg * r0, int emit)
{
    Instruction *i = _mk_instruction("","%s:", R1(r0), 0);
    i->type = ITLABEL;
    if (emit)
        emitb(i);
    return i;
}

static Instruction * iLABEL(SymReg * r0) {
    Instruction *i = _mk_instruction("","%s:", R1(r0), 0);
    i->type = ITLABEL;
    r0->first_ins = i;
    i = emitb(i);
    i->line = line;
    clear_state();
    return i;
}


static Instruction * iSUBROUTINE(SymReg * r0) {
    Instruction *i;
    function = r0->name;
    i =  iLABEL(r0);
    i->line = line - 1;
    if (*r0->name != '_')
        fataly(EX_SOFTWARE, "iSUBROUTINE", line,
        "illegal local label '%s'\n", r0->name);
    return i;
}


/*
 * substr or X = P[key]
 */
static Instruction *
iINDEXFETCH(struct Parrot_Interp *interp, SymReg * r0, SymReg * r1,
    SymReg * r2)
{
    if(r0->set == 'S' && r1->set == 'S' && r2->set == 'I') {
        SymReg * r3 = mk_const(str_dup("1"), 'I');
        return MK_I(interp, "substr %s, %s, %s, 1", R4(r0, r1, r2, r3));
    }
    keyvec |= KEY_BIT(2);
    return MK_I(interp, "set %s, %s[%s]", R3(r0,r1,r2));
}

/*
 * substr or P[key] = X
 */

static Instruction *
iINDEXSET(struct Parrot_Interp *interp, SymReg * r0, SymReg * r1, SymReg * r2)
{
    if(r0->set == 'S' && r1->set == 'I' && r2->set == 'S') {
        SymReg * r3 = mk_const(str_dup("1"), 'I');
        MK_I(interp, "substr %s, %s, %s, %s", R4(r0, r1,r3, r2));
    }
    else if (r0->set == 'P') {
        keyvec |= KEY_BIT(1);
	MK_I(interp, "set %s[%s], %s", R3(r0,r1,r2));
    }
    else {
        fataly(EX_SOFTWARE, "iINDEXSET", line,"unsupported indexed set op\n");
    }
    return 0;
}

static Instruction *
multi_keyed(struct Parrot_Interp *interpreter,char *name,
SymReg ** r, int nr, int emit)
{
    int i, keyf, kv, n;
    char buf[16];
    static int p = 0;
    SymReg *preg[IMCC_MAX_REGS];    /* px,py,pz */
    SymReg *nreg[IMCC_MAX_REGS];
    Instruction *ins = 0;

    /* count keys in keyvec */
    kv = keyvec;
    for (i = keyf = 0; i < nr; i++, kv >>= 1)
        if (kv & 1)
            keyf++;
    if (keyf <= 1)
        return 0;
    /* XXX what to do, if we don't emit instruction? */
    assert(emit);
    /* OP  _p_k    _p_k_p_k =>
     * set      py, p_k
     * set      pz,     p_k
     * new px, .PerlUndef
     * OP  px, py, pz
     * set _p_k_px
     */

    kv = keyvec;
    for (i = n = 0; i < nr; i++, kv >>= 1, n++) {
        if (kv & 1) {
            fataly(EX_SOFTWARE, "multi_keyed", line,"illegal key operand\n");
        }
        /* make a new P symbol */
        while (1) {
            sprintf(buf, "$P%d", ++p);
            if (get_sym(buf) == 0)
                break;
        }
        preg[n] = mk_symreg(str_dup(buf), 'P');
        kv >>= 1;
        if (kv & 1) {
            /* we have a keyed operand */
            if (r[i]->set != 'P') {
                fataly(EX_SOFTWARE, "multi_keyed", line,"not an aggregate\n");
            }
            nargs = 3;
            /* don't emit LHS yet */
            if (i == 0) {
                keyvec = 1 << 1;
                nreg[0] = r[i];
                nreg[1] = r[i+1];
                nreg[2] = preg[n];
                /* set p_k px */
                ins = iANY(interpreter, str_dup("set"), 0, nreg, 0);
            }
            else {
                keyvec = 1 << 2;
                nreg[0] = preg[n];
                nreg[1] = r[i];
                nreg[2] = r[i+1];
                /* set py|z p_k */
                iANY(interpreter, str_dup("set"), 0, nreg, 1);
            }
            i++;
        }
        /* non keyed */
        else {
            nargs = 2;
            keyvec = 0;
            if (i == 0) {
                nreg[0] = r[i];
                nreg[1] = preg[n];
                /* set n, px */
                ins = iANY(interpreter, str_dup("set"), 0, nreg, 0);
            }
            else {
                nreg[0] = preg[n];
                nreg[1] = r[i];
                /* set px, n */
                iANY(interpreter, str_dup("set"), 0, nreg, 1);
            }
        }
    }
    /* make a new undef */
    iNEW(interpreter, preg[0], str_dup("PerlUndef"), NULL, 1);
    /* emit the operand */
    nargs = 3;
    keyvec = 0;
    iANY(interpreter, name, 0, preg, 1);
    /* emit the LHS op */
    emitb(ins);
    return ins;
}

Instruction *
iANY(struct Parrot_Interp *interpreter, char * name,
    const char *fmt, SymReg **r, int emit)
{
    char fullname[64];
    int i;
    int dirs = 0;
    int op;
    Instruction * ins;

#if 1
    ins = multi_keyed(interpreter, name, r, nargs, emit);
    if (ins)
        return ins;
#endif
    op_fullname(fullname, name, r, nargs);
    op = interpreter->op_lib->op_code(fullname, 1);
    if (op < 0)         /* maybe we got a fullname */
        op = interpreter->op_lib->op_code(name, 1);
    if (op >= 0) {
        op_info_t * op_info = &interpreter->op_info_table[op];
	char format[128];
	int len;

        *format = '\0';
        /* info->arg_count is offset by one, first is opcode
         * build instruction format
         * set LV_in / out flags */
        for (i = 0; i < op_info->arg_count-1; i++) {
            switch (op_info->dirs[i+1]) {
                case PARROT_ARGDIR_INOUT:
                    dirs |= 1 << (16 + i);
                    /* goon */
                case PARROT_ARGDIR_IN:
                    dirs |= 1 << i ;
                    break;

                case PARROT_ARGDIR_OUT:
                    dirs |= 1 << (16 + i);
                    break;

                default:
                    assert(0);
            };
            if (keyvec & KEY_BIT(i)) {
                len = strlen(format);
                len -= 2;
                format[len] = '\0';
                strcat(format, "[%s], ");
	}
            else
                strcat(format, "%s, ");
	}
	len = strlen(format);
	if (len >= 2)
	    len -= 2;
	format[len] = '\0';
        if (fmt && *fmt)
            strcpy(format, fmt);
        memset(r + nargs, 0, sizeof(*r) * (IMCC_MAX_REGS - nargs));
#if 1
        debug(DEBUG_PARSER,"%s %s\t%s\n", name, format, fullname);
#endif
        /* make the instruction */

        ins = _mk_instruction(name, format, r, dirs);
        ins->keys |= keyvec;
        /* fill iin oplib's info */
        ins->opnum = op;
        ins->opsize = op_info->arg_count;
        /* mark end as absolute branch */
        if (!strcmp(name, "end")) {
            ins->type |= ITBRANCH | IF_goto;
        }
        /* set up branch flags */
        if (op_info->jump) {

            /* XXX: assume the jump is relative and to the last arg.
             * usually true.
             */
            if (op_info->jump & PARROT_JUMP_RESTART)
                ins->type = ITBRANCH;
            else
                ins->type = ITBRANCH | (1 << (nargs-1));
            if (!strcmp(name, "branch"))
                ins->type |= IF_goto;
            if (!strcmp(fullname, "jump_i") ||
                    !strcmp(fullname, "jsr_i") ||
                    !strcmp(fullname, "branch_i") ||
                    !strcmp(fullname, "bsr_i"))
                dont_optimize = 1;
        }
        else if (!strcmp(name, "set") && nargs == 2) {
            /* set Px, Py: both PMCs have the same address */
            if (r[0]->set == 'P' && r[1]->set == 'P')
                ins->type |= ITALIAS;
        }
        else if (!strcmp(name, "set_addr")) {
            /* mark this as branch, because it needs fixup */
            ins->type = ITADDR | IF_r1_branch | ITBRANCH;
        }
        else if (!strcmp(name, "newsub")) {
            if (ins->opsize == 4)
                ins->type = ITADDR | IF_r2_branch | ITBRANCH;
            else
                ins->type = ITADDR | IF_r2_branch | IF_r3_branch | ITBRANCH;
        }
        else if (!strcmp(name, "compile"))
            ++has_compile;

        if (emit)
             emitb(ins);
    } else {
        fataly(EX_SOFTWARE, "iANY", line,"op not found '%s' (%s<%d>)\n",
                fullname, name, nargs);
    }
    return ins;
}

%}

%union {
    int t;
    char * s;
    SymReg * sr;
    Instruction *i;
}

%token <t> CALL GOTO ARG IF UNLESS NEW END SAVEALL RESTOREALL
%token <t> SUB NAMESPACE ENDNAMESPACE CLASS ENDCLASS SYM LOCAL CONST PARAM
%token <t> INC DEC
%token <t> SHIFT_LEFT SHIFT_RIGHT INTV FLOATV STRINGV DEFINED LOG_XOR
%token <t> RELOP_EQ RELOP_NE RELOP_GT RELOP_GTE RELOP_LT RELOP_LTE
%token <t> GLOBAL ADDR CLONE RESULT RETURN POW SHIFT_RIGHT_U LOG_AND LOG_OR
%token <t> COMMA ESUB
%token <t> PCC_BEGIN PCC_END PCC_CALL PCC_SUB PCC_BEGIN_RETURN PCC_END_RETURN
%token <t> PROTOTYPED NON_PROTOTYPED
%token <s> LABEL
%token <t> EMIT EOM
%token <s> IREG NREG SREG PREG IDENTIFIER STRINGC INTC FLOATC REG MACRO ENDM
%token <s> PARROT_OP
%type <t> type
%type <i> program sub sub_start emit nsub pcc_sub sub_body pcc_ret
%type <s> classname relop
%type <i> labels _labels label statements statement
%type <i> pcc_sub_call
%type <sr> pcc_arg pcc_result pcc_args pcc_results pcc_params pcc_param
%type <sr> pcc_returns pcc_return pcc_call
%type <t> pcc_proto pcc_sub_proto
%type <i> instruction assignment if_statement labeled_inst
%type <sr> target reg const var rc string
%type <sr> key keylist _keylist
%type <sr> vars _vars var_or_i _var_or_i label_op
%type <i> pasmcode pasmline pasm_inst
%type <sr> pasm_args lhs
%token <sr> VAR

%pure_parser

%start program

%%

program:                         { open_comp_unit(); }
    statements  { $$ = 0;
	  allocate(interp);
	  emit_flush(interp);
        }
    ;


pasmcode: pasmline
    | pasmcode pasmline
    ;

pasmline: labels  pasm_inst '\n'  { $$ = 0; }
    | MACRO '\n'                  { $$ = 0; }
    ;

pasm_inst: {clear_state();}
       PARROT_OP pasm_args	        { $$ = iANY(interp, $2,0,regs,1); free($2); }
    | /* none */                               { $$ = 0;}
    ;
pasm_args:
    vars
    ;

emit:
      EMIT                              { open_comp_unit();
                                          function = "(emit)"; }
      pasmcode
      EOM 				{ if (optimizer_level & OPT_PASM)
                                                allocate(interp);
                                          emit_flush(interp); $$=0;}
    ;

nsub:	sub_start
        sub_body
    ;

sub_body:
        statements ESUB
        {
          $$ = 0;
	  allocate(interp);
	  emit_flush(interp);
        }
     ;

sub:    nsub
        | pcc_sub
        | emit
    ;

sub_start: SUB                           { open_comp_unit(); }
           IDENTIFIER '\n'
        { $$ = 0;
          iSUBROUTINE(mk_address($3, U_add_uniq_sub));
        }
    ;
pcc_sub: PCC_SUB   { open_comp_unit(); }
       IDENTIFIER pcc_sub_proto '\n'
        {
          char *name = str_dup($3);
          Instruction *i = iSUBROUTINE(mk_address($3, U_add_uniq_sub));
          i->r[1] = $<sr>$ = mk_pcc_sub(name, 0);
          i->r[1]->pcc_sub->prototyped = $4;
        }
       pcc_params
       sub_body { $$ = 0; }
    ;

pcc_params: /* empty */                   { $$ = 0; }
    | pcc_param '\n'                      { add_pcc_param($<sr>0, $1);}
    | pcc_params pcc_param '\n'           { add_pcc_param($<sr>0, $2);}
    ;

pcc_param: PARAM         { is_def=1; }
         type IDENTIFIER { $$ = mk_ident($4, $3); is_def=0; }
    ;

pcc_sub_call: PCC_BEGIN pcc_proto '\n' {
              char name[128];
              SymReg * r;
              Instruction *i;

              sprintf(name, "#pcc_sub_call_%d", line - 1);
              $<sr>$ = r = mk_pcc_sub(str_dup(name), 0);
              r->pcc_sub->prototyped = $2;
              /* this mid rule action has the semantic value of the
                 sub SymReg.
                 This is used below to append args & results
              */
              i = iLABEL(r);
              i->type = ITPCCSUB;

           }
           pcc_args
           pcc_call
           label '\n'
           pcc_results
           PCC_END  '\n' { $$ = 0; }
    ;

pcc_proto: PROTOTYPED           { $$ = 1; }
         | NON_PROTOTYPED       { $$ = 0; }
    ;

pcc_sub_proto: /* empty */      { $$ = -1; }
         | pcc_proto
    ;

pcc_call: PCC_CALL var COMMA var '\n' {
                  add_pcc_sub($<sr>-1, $2);
                  add_pcc_cc($<sr>-1, $4);
              }
       | PCC_CALL var '\n' {
                  add_pcc_sub($<sr>-1, $2);
              }
     ;

pcc_args: /* empty */                   { $$ = 0; }
    | pcc_arg '\n'                      {  add_pcc_arg($<sr>0, $1);}
    | pcc_args pcc_arg '\n'             {  add_pcc_arg($<sr>0, $2);}
    ;

pcc_arg: ARG var                        { $$ = $2; }
    ;

pcc_results: /* empty */                { $$ = 0; }
    |       pcc_result '\n'             { if($1) add_pcc_result($<sr>-4, $1); }
    | pcc_results pcc_result '\n'       { if($2) add_pcc_result($<sr>-4, $2); }
    ;

pcc_result: RESULT var                  { $$ = $2; }
    |   LOCAL { is_def=1; } type IDENTIFIER { mk_ident($4, $3);is_def=0; $$=0; }
    ;

pcc_ret: PCC_BEGIN_RETURN '\n' {
                Instruction *i, *ins = instructions;
                char name[128];
                if (!ins || !ins->r[1] || ins->r[1]->type != VT_PCC_SUB)
                    fataly(EX_SOFTWARE, "pcc_ret", line,
                        "pcc_return not inside pcc subroutine\n");
                $<sr>$ = ins->r[1];
                sprintf(name, "#pcc_sub_ret_%d:", line - 1);
                i = _mk_instruction("", name, NULL, 0);
                i = emitb(i);
                i->type = ITPCCSUB | ITLABEL;
        }
        pcc_returns
        PCC_END_RETURN '\n'             { $$ = 0; }
    ;

pcc_returns: /* empty */                { $$ = 0; }
    |       pcc_returns '\n'            { if($1) add_pcc_return($<sr>0, $1); }
    | pcc_returns pcc_return '\n'       { if($2) add_pcc_return($<sr>0, $2); }
    ;

pcc_return: RETURN var                  { $$ = $2; }
    ;

statements: statement
    |   statements statement
    ;

statement:  { clear_state(); }
        instruction                   { $$ = $2; }
        | MACRO '\n'                  { $$ = 0; }
        | pcc_sub_call                { $$ = 0; }
        | pcc_ret
    ;

labels:	/* none */         { $$ = NULL; }
    |   _labels
    ;

_labels: _labels label
    |   label
    ;

label:  LABEL		{ $$ = iLABEL(mk_address($1, U_add_uniq_label)); }
    ;

instruction:
	labels  labeled_inst '\n'  { $$ = $2; }
    |  sub
    ;
labeled_inst:
	assignment
    |   if_statement
    |   NAMESPACE IDENTIFIER            { push_namespace($2); }
    |   ENDNAMESPACE IDENTIFIER         { pop_namespace($2); }
    |   LOCAL { is_def=1; } type IDENTIFIER { mk_ident($4, $3);is_def=0; }
    |   CONST { is_def=1; } type IDENTIFIER '=' const
                                    { mk_const_ident($4, $3, $6);is_def=0; }
    |   PARAM { is_def=1; } type IDENTIFIER { $$ = MK_I(interp, "restore",
		                            R1(mk_ident($4, $3)));is_def=0; }
    |   PARAM reg			{ $$ = MK_I(interp, "restore", R1($2)); }
    |   RESULT var			{ $$ = MK_I(interp, "restore", R1($2)); }
    |   ARG var				{ $$ = MK_I(interp, "save", R1($2)); }
    |   RETURN var			{ $$ = MK_I(interp, "save", R1($2)); }
    |   CALL label_op			{ $$ = MK_I(interp, "bsr",  R1($2)); }
    |   GOTO label_op			{ $$ = MK_I(interp, "branch",R1($2)); }
    |   INC var				{ $$ = MK_I(interp, "inc",R1($2)); }
    |   DEC var				{ $$ = MK_I(interp, "dec",R1($2)); }
    |   SAVEALL				{ $$ = MK_I(interp, "saveall" ,R0()); }
    |   RESTOREALL			{ $$ = MK_I(interp, "restoreall" ,R0()); }
    |   END				{ $$ = MK_I(interp, "end" ,R0()); }
    |  PARROT_OP vars                   { $$ = iANY(interp, $1,0,regs, 1); free($1); }
    | /* none */                               { $$ = 0;}
    ;

type:
        INTV { $$ = 'I'; }
    |   FLOATV { $$ = 'N'; }
    |   STRINGV { $$ = 'S'; }
    |   classname { $$ = 'P'; free($1); }
    ;

classname:
    IDENTIFIER
    ;

assignment:
       target '=' var			{ $$ = MK_I(interp, "set", R2($1, $3)); }
    |  target '=' '!' var		{ $$ = MK_I(interp, "not", R2($1, $4));}
    |  target '=' '-' var		{ $$ = MK_I(interp, "neg", R2($1, $4));}
    |  target '=' '~' var		{ $$ = MK_I(interp, "bnot", R2($1, $4));}
    |  target '=' var '+' var		{ $$ = MK_I(interp, "add", R3($1, $3, $5)); }
    |  target '=' var '-' var		{ $$ = MK_I(interp, "sub", R3($1, $3, $5)); }
    |  target '=' var '*' var		{ $$ = MK_I(interp, "mul", R3($1, $3, $5)); }
    |  target '=' var POW var		{ $$ = MK_I(interp, "pow", R3($1, $3, $5)); }
    |  target '=' var '/' var		{ $$ = MK_I(interp, "div", R3($1, $3, $5)); }
    |  target '=' var '%' var		{ $$ = MK_I(interp, "mod", R3($1, $3, $5)); }
    |  target '=' var '.' var		{ $$ = MK_I(interp, "concat", R3($1,$3,$5)); }
    |  target '=' var SHIFT_LEFT var	{ $$ = MK_I(interp, "shl", R3($1, $3, $5)); }
    |  target '=' var SHIFT_RIGHT var	{ $$ = MK_I(interp, "shr", R3($1, $3, $5)); }
    |  target '=' var SHIFT_RIGHT_U var	{ $$ = MK_I(interp, "lsr", R3($1, $3, $5)); }
    |  target '=' var LOG_AND var	{ $$ = MK_I(interp, "and", R3($1, $3, $5)); }
    |  target '=' var LOG_OR var	{ $$ = MK_I(interp, "or", R3($1, $3, $5)); }
    |  target '=' var LOG_XOR var	{ $$ = MK_I(interp, "xor", R3($1, $3, $5)); }
    |  target '=' var '&' var		{ $$ = MK_I(interp, "band", R3($1, $3, $5)); }
    |  target '=' var '|' var		{ $$ = MK_I(interp, "bor", R3($1, $3, $5)); }
    |  target '=' var '~' var		{ $$ = MK_I(interp, "bxor", R3($1, $3, $5)); }
    |  target '=' var '[' keylist ']'   { $$ = iINDEXFETCH(interp, $1, $3, $5); }
    |  var '[' keylist ']' '=' var	{ $$ = iINDEXSET(interp, $1, $3, $6); }
    |  target '=' NEW classname COMMA var { $$ = iNEW(interp, $1, $4, $6, 1); }
    |  target '=' NEW classname		{ $$ = iNEW(interp, $1, $4, NULL,1); }
    |  target '=' DEFINED var	        { $$ = MK_I(interp, "defined",R2($1,$4)); }
    |  target '=' DEFINED var '[' keylist ']' { keyvec=KEY_BIT(2);
                                     $$ = MK_I(interp, "defined", R3($1, $4, $6));}
    |  target '=' CLONE var		{ $$ = MK_I(interp, "clone",R2($1, $4));
    }
    |  target '=' ADDR IDENTIFIER	{ $$ = MK_I(interp, "set_addr",
                                          R2($1, mk_address($4,U_add_once))); }
    |  target '=' GLOBAL string	{ $$ = MK_I(interp, "find_global",R2($1,$4)); }
    |  GLOBAL string '=' var	{ $$ = MK_I(interp, "store_global",R2($2,$4)); }
    |  NEW                              { expect_pasm = 1; }
          pasm_args	        { $$ = iANY(interp, "new",0,regs,1);  }
    |  DEFINED target COMMA var         { $$ = MK_I(interp, "defined", R2($2, $4)); }
    |  DEFINED target COMMA var '[' keylist ']'  { keyvec=KEY_BIT(2);
                                       $$ = MK_I(interp, "defined", R3($2, $4, $6));}
    |  CLONE target COMMA var           { $$ = MK_I(interp, "clone", R2($2, $4)); }
    ;

if_statement:
       IF var relop var GOTO label_op {$$=MK_I(interp, $3,R3($2,$4, $6)); }
    |  IF var GOTO label_op           {$$= MK_I(interp, "if", R2($2, $4)); }
    |  UNLESS var GOTO label_op       {$$= MK_I(interp, "unless",R2($2, $4)); }
    |  IF var COMMA label_op          {$$= MK_I(interp, "if", R2($2, $4)); }
    |  UNLESS var COMMA label_op      {$$= MK_I(interp, "unless", R2($2, $4)); }

    ;

relop:
       RELOP_EQ				{ $$ = "eq"; }
    |  RELOP_NE				{ $$ = "ne"; }
    |  RELOP_GT				{ $$ = "gt"; }
    |  RELOP_GTE			{ $$ = "ge"; }
    |  RELOP_LT				{ $$ = "lt"; }
    |  RELOP_LTE			{ $$ = "le"; }
    ;


target: VAR
    |  reg
    ;
lhs: VAR
    |  reg
    ;

vars:   { $$ = NULL; }
    |  _vars  { $$ = $1; }
    ;

_vars: _vars COMMA _var_or_i		{ $$ = regs[0]; }
    |  _var_or_i
    ;

_var_or_i: var_or_i                     { regs[nargs++] = $1; }
    | lhs '[' keylist ']'               { regs[nargs++] = $1;
                                          keyvec |= KEY_BIT(nargs);
                                          regs[nargs++] = $3; $$ = $1; }
    ;
label_op:
       IDENTIFIER			{ $$ = mk_address($1, U_add_once); }
    |  PARROT_OP                        { $$ = mk_address($1, U_add_once); }
    ;
var_or_i:
       IDENTIFIER			{ $$ = mk_address($1, U_add_once); }
    |  PARROT_OP                        { $$ = mk_address($1, U_add_once); }
    |  var
    ;

var:   VAR
    |  rc
    ;

keylist:                                { nkeys=0; }
       _keylist                         { $$ = link_keys(nkeys, keys); }
    ;

_keylist: key                            { keys[nkeys++] = $1; }
     | _keylist ';' key                  { keys[nkeys++] = $3; $$ =  keys[0]; }
    ;

key:  var
    ;

rc:	reg
    |	const
    ;

reg:   IREG				{ $$ = mk_symreg($1, 'I'); }
    |  NREG				{ $$ = mk_symreg($1, 'N'); }
    |  SREG				{ $$ = mk_symreg($1, 'S'); }
    |  PREG				{ $$ = mk_symreg($1, 'P'); }
    |  REG                              { $$ = mk_pasm_reg($1); }
    ;

const: INTC				{ $$ = mk_const($1, 'I'); }
    |  FLOATC				{ $$ = mk_const($1, 'N'); }
    |  STRINGC				{ $$ = mk_const($1, 'S'); }
    ;

string: SREG				{ $$ = mk_symreg($1, 'S'); }
    |  STRINGC				{ $$ = mk_const($1, 'S'); }
    ;
%%


int yyerror(char * s)
{
    /* fprintf(stderr, "last token = [%s]\n", yylval.s); */
    fprintf(stderr, "(error) line %d: %s\n", line, s );
    fprintf(stderr, "Didn't create output asm.\n" );
    exit(EX_UNAVAILABLE);
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
