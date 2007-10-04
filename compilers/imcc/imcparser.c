/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton implementation for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "2.3"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 1

/* Using locations.  */
#define YYLSP_NEEDED 0



/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     LOW_PREC = 258,
     PARAM = 259,
     PRAGMA = 260,
     N_OPERATORS = 261,
     HLL = 262,
     HLL_MAP = 263,
     GOTO = 264,
     ARG = 265,
     IF = 266,
     UNLESS = 267,
     PNULL = 268,
     ADV_FLAT = 269,
     ADV_SLURPY = 270,
     ADV_OPTIONAL = 271,
     ADV_OPT_FLAG = 272,
     ADV_NAMED = 273,
     ADV_ARROW = 274,
     NEW = 275,
     NAMESPACE = 276,
     ENDNAMESPACE = 277,
     DOT_METHOD = 278,
     SUB = 279,
     SYM = 280,
     LOCAL = 281,
     LEXICAL = 282,
     CONST = 283,
     INC = 284,
     DEC = 285,
     GLOBAL_CONST = 286,
     PLUS_ASSIGN = 287,
     MINUS_ASSIGN = 288,
     MUL_ASSIGN = 289,
     DIV_ASSIGN = 290,
     CONCAT_ASSIGN = 291,
     BAND_ASSIGN = 292,
     BOR_ASSIGN = 293,
     BXOR_ASSIGN = 294,
     FDIV = 295,
     FDIV_ASSIGN = 296,
     MOD_ASSIGN = 297,
     SHR_ASSIGN = 298,
     SHL_ASSIGN = 299,
     SHR_U_ASSIGN = 300,
     SHIFT_LEFT = 301,
     SHIFT_RIGHT = 302,
     INTV = 303,
     FLOATV = 304,
     STRINGV = 305,
     PMCV = 306,
     LOG_XOR = 307,
     RELOP_EQ = 308,
     RELOP_NE = 309,
     RELOP_GT = 310,
     RELOP_GTE = 311,
     RELOP_LT = 312,
     RELOP_LTE = 313,
     GLOBAL = 314,
     GLOBALOP = 315,
     ADDR = 316,
     RESULT = 317,
     RETURN = 318,
     YIELDT = 319,
     GET_RESULTS = 320,
     POW = 321,
     SHIFT_RIGHT_U = 322,
     LOG_AND = 323,
     LOG_OR = 324,
     COMMA = 325,
     ESUB = 326,
     DOTDOT = 327,
     PCC_BEGIN = 328,
     PCC_END = 329,
     PCC_CALL = 330,
     PCC_SUB = 331,
     PCC_BEGIN_RETURN = 332,
     PCC_END_RETURN = 333,
     PCC_BEGIN_YIELD = 334,
     PCC_END_YIELD = 335,
     NCI_CALL = 336,
     METH_CALL = 337,
     INVOCANT = 338,
     MAIN = 339,
     LOAD = 340,
     INIT = 341,
     IMMEDIATE = 342,
     POSTCOMP = 343,
     METHOD = 344,
     ANON = 345,
     OUTER = 346,
     NEED_LEX = 347,
     MULTI = 348,
     VTABLE_METHOD = 349,
     LOADLIB = 350,
     UNIQUE_REG = 351,
     LABEL = 352,
     EMIT = 353,
     EOM = 354,
     IREG = 355,
     NREG = 356,
     SREG = 357,
     PREG = 358,
     IDENTIFIER = 359,
     REG = 360,
     MACRO = 361,
     ENDM = 362,
     STRINGC = 363,
     INTC = 364,
     FLOATC = 365,
     USTRINGC = 366,
     PARROT_OP = 367,
     VAR = 368,
     LINECOMMENT = 369,
     FILECOMMENT = 370,
     DOT = 371,
     CONCAT = 372
   };
#endif
/* Tokens.  */
#define LOW_PREC 258
#define PARAM 259
#define PRAGMA 260
#define N_OPERATORS 261
#define HLL 262
#define HLL_MAP 263
#define GOTO 264
#define ARG 265
#define IF 266
#define UNLESS 267
#define PNULL 268
#define ADV_FLAT 269
#define ADV_SLURPY 270
#define ADV_OPTIONAL 271
#define ADV_OPT_FLAG 272
#define ADV_NAMED 273
#define ADV_ARROW 274
#define NEW 275
#define NAMESPACE 276
#define ENDNAMESPACE 277
#define DOT_METHOD 278
#define SUB 279
#define SYM 280
#define LOCAL 281
#define LEXICAL 282
#define CONST 283
#define INC 284
#define DEC 285
#define GLOBAL_CONST 286
#define PLUS_ASSIGN 287
#define MINUS_ASSIGN 288
#define MUL_ASSIGN 289
#define DIV_ASSIGN 290
#define CONCAT_ASSIGN 291
#define BAND_ASSIGN 292
#define BOR_ASSIGN 293
#define BXOR_ASSIGN 294
#define FDIV 295
#define FDIV_ASSIGN 296
#define MOD_ASSIGN 297
#define SHR_ASSIGN 298
#define SHL_ASSIGN 299
#define SHR_U_ASSIGN 300
#define SHIFT_LEFT 301
#define SHIFT_RIGHT 302
#define INTV 303
#define FLOATV 304
#define STRINGV 305
#define PMCV 306
#define LOG_XOR 307
#define RELOP_EQ 308
#define RELOP_NE 309
#define RELOP_GT 310
#define RELOP_GTE 311
#define RELOP_LT 312
#define RELOP_LTE 313
#define GLOBAL 314
#define GLOBALOP 315
#define ADDR 316
#define RESULT 317
#define RETURN 318
#define YIELDT 319
#define GET_RESULTS 320
#define POW 321
#define SHIFT_RIGHT_U 322
#define LOG_AND 323
#define LOG_OR 324
#define COMMA 325
#define ESUB 326
#define DOTDOT 327
#define PCC_BEGIN 328
#define PCC_END 329
#define PCC_CALL 330
#define PCC_SUB 331
#define PCC_BEGIN_RETURN 332
#define PCC_END_RETURN 333
#define PCC_BEGIN_YIELD 334
#define PCC_END_YIELD 335
#define NCI_CALL 336
#define METH_CALL 337
#define INVOCANT 338
#define MAIN 339
#define LOAD 340
#define INIT 341
#define IMMEDIATE 342
#define POSTCOMP 343
#define METHOD 344
#define ANON 345
#define OUTER 346
#define NEED_LEX 347
#define MULTI 348
#define VTABLE_METHOD 349
#define LOADLIB 350
#define UNIQUE_REG 351
#define LABEL 352
#define EMIT 353
#define EOM 354
#define IREG 355
#define NREG 356
#define SREG 357
#define PREG 358
#define IDENTIFIER 359
#define REG 360
#define MACRO 361
#define ENDM 362
#define STRINGC 363
#define INTC 364
#define FLOATC 365
#define USTRINGC 366
#define PARROT_OP 367
#define VAR 368
#define LINECOMMENT 369
#define FILECOMMENT 370
#define DOT 371
#define CONCAT 372




/* Copy the first part of user declarations.  */
#line 1 "compilers/imcc/imcc.y"

/*
 * imcc.y
 *
 * Intermediate Code Compiler for Parrot.
 *
 * Copyright (C) 2002 Melvin Smith <melvin.smith@mindspring.com>
 * Copyright (C) 2002-2007, The Perl Foundation.
 *
 * Grammar for the parser.
 *
 * $Id$
 *
 */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define _PARSER
#define PARSER_MAIN
#include "imc.h"
#include "parrot/dynext.h"
#include "pbc.h"
#include "parser.h"
#include "optimizer.h"

#ifndef YYENABLE_NLS
#  define YYENABLE_NLS 0
#endif

#ifndef YYLTYPE_IS_TRIVIAL
#  define YYLTYPE_IS_TRIVIAL 0
#endif

/* HEADERIZER HFILE: compilers/imcc/imc.h */

/* HEADERIZER BEGIN: static */

static void add_pcc_named_arg(PARROT_INTERP,
    NOTNULL(SymReg *cur_call),
    const char     *name,
    SymReg         *value)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

static void add_pcc_named_param(PARROT_INTERP,
    SymReg     *cur_call,
    const char *name,
    SymReg     *value)
        __attribute__nonnull__(1);

static void add_pcc_named_result(PARROT_INTERP,
    SymReg     *cur_call,
    const char *name,
    SymReg     *value)
        __attribute__nonnull__(1);

static void add_pcc_named_return(PARROT_INTERP,
    SymReg     *cur_call,
    const char *name,
    SymReg     *value)
        __attribute__nonnull__(1);

static void begin_return_or_yield(PARROT_INTERP, int yield)
        __attribute__nonnull__(1);

static void clear_state(PARROT_INTERP)
        __attribute__nonnull__(1);

static void do_loadlib(PARROT_INTERP, NOTNULL(const char *lib))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_WARN_UNUSED_RESULT
static Instruction* func_ins(
    PARROT_INTERP,
    IMC_Unit   *unit,
    SymReg     *lhs,
    const char *op,
    NOTNULL(SymReg **r),
    int n,
    int keyv,
    int emit)
        __attribute__nonnull__(5);

static Instruction * iINDEXFETCH(PARROT_INTERP,
    IMC_Unit *unit,
    SymReg *r0,
    SymReg *r1,
    SymReg *r2)
        __attribute__nonnull__(1);

static Instruction * iINDEXSET(PARROT_INTERP,
    IMC_Unit *unit,
    SymReg *r0,
    SymReg *r1,
    SymReg *r2)
        __attribute__nonnull__(1);

static Instruction * iLABEL(PARROT_INTERP, IMC_Unit *unit, SymReg *r0)
        __attribute__nonnull__(1);

static const char * inv_op(const char *op);
static Instruction * iSUBROUTINE(PARROT_INTERP,
    IMC_Unit *unit,
    NOTNULL(SymReg *r))
        __attribute__nonnull__(1)
        __attribute__nonnull__(3);

static Instruction * MK_I(PARROT_INTERP,
    IMC_Unit *unit,
    NOTNULL(const char *fmt),
    int n,
    ...)
        __attribute__nonnull__(1)
        __attribute__nonnull__(3);

PARROT_WARN_UNUSED_RESULT
static Instruction* mk_pmc_const(PARROT_INTERP,
    IMC_Unit *unit,
    NOTNULL(const char *type),
    NOTNULL(SymReg *left),
    NOTNULL(char *constant))
        __attribute__nonnull__(1)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        __attribute__nonnull__(5);

static SymReg * mk_sub_address_fromc(PARROT_INTERP, char *name)
        __attribute__nonnull__(1);

static SymReg * mk_sub_address_u(PARROT_INTERP, char *name)
        __attribute__nonnull__(1);

static void set_lexical(PARROT_INTERP, NOTNULL(SymReg *r), char *name)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

/* HEADERIZER END: static */


#define YYDEBUG 1
#define YYERROR_VERBOSE 1

/*
 * we use a pure parser with the interpreter as a parameter this still
 * doesn't make the parser reentrant, there are too many globals
 * around.
 */

/*
 * Choosing instructions for Parrot is pretty easy since many are
 * polymorphic.
 */


/*
 * MK_I: build and emitb instruction by INS
 *
 * fmt may contain:
 *   op %s, %s # comment
 * or just
 *   op
 *
 *
 *  NOTE: Most usage of this function is with
 *        IMCC_INFO(interp)->cur_unit, but there are some
 *        exceptions. Thus, we can't easily factorize that piece of
 *        code.
 */
static Instruction *
MK_I(PARROT_INTERP, IMC_Unit *unit, NOTNULL(const char *fmt), int n, ...)
{
    char opname[64];
    char *p;
    const char *q;
    va_list ap;
    SymReg *r[IMCC_MAX_FIX_REGS];
    int i;

    for (p = opname, q = fmt; *q && *q != ' ';)
        *p++ = *q++;
    *p = 0;
    if (!*q)
        fmt = NULL;
    else
        fmt = ++q;
#ifdef OPDEBUG
    fprintf(stderr, "op '%s' format '%s' (%d)\n", opname, fmt?:"",n);
#endif
    va_start(ap, n);
    i = 0;
    for (i = 0; i < n; ++i) {
        r[i] = va_arg(ap, SymReg *);
    }
    va_end(ap);
    return INS(interp, unit, opname, fmt, r, n,
               IMCC_INFO(interp)->keyvec, 1);
}

PARROT_WARN_UNUSED_RESULT
static Instruction*
mk_pmc_const(PARROT_INTERP, IMC_Unit *unit, NOTNULL(const char *type),
             NOTNULL(SymReg *left), NOTNULL(char *constant))
{
    const   int type_enum = atoi(type);
    SymReg *rhs;
    SymReg *r[2];
    char   *name;
    int     ascii;

    if (left->type == VTADDRESS) {      /* IDENTIFIER */
        if (IMCC_INFO(interp)->state->pasm_file) {
            IMCC_fataly(interp, E_SyntaxError,
                        "Ident as PMC constant",
                        " %s\n", left->name);
        }
        left->type = VTIDENTIFIER;
        left->set = 'P';
    }
    r[0] = left;
    ascii = (*constant == '\'' || *constant == '"');
    if (ascii) {
        /* strip delimiters */
        const size_t len  = strlen(constant);
        name              = (char *)mem_sys_allocate(len);
        constant[len - 1] = '\0';

        strcpy(name, constant + 1);
        free(constant);
    }
    else {
        name = constant;
    }
    switch (type_enum) {
    case enum_class_Sub:
    case enum_class_Coroutine:
        rhs = mk_const(interp, name, 'p');
        if (!ascii)
            rhs->type |= VT_ENCODED;
        r[1] = rhs;
        rhs->pmc_type = type_enum;
        rhs->usage = U_FIXUP;
        return INS(interp, unit, "set_p_pc", "", r, 2, 0, 1);
    }
    rhs = mk_const(interp, name, 'P');
    r[1] = rhs;
    rhs->pmc_type = type_enum;
    return INS(interp, unit, "set_p_pc", "", r, 2, 0, 1);
}

PARROT_WARN_UNUSED_RESULT
static Instruction*
func_ins(PARROT_INTERP, IMC_Unit *unit, SymReg *lhs, const char *op,
         SymReg ** r, int n, int keyv, int emit)
{
    int i;
    /* shift regs up by 1 */
    for (i = n - 1; i >= 0; --i)
        r[i+1] = r[i];
    r[0] = lhs;
    /* shift keyvec */
    keyv <<= 1;
    return INS(interp, unit, op, "", r, n+1, keyv, emit);
}
/*
 * special instructions
 *
 * labels and such
 */

static void
clear_state(PARROT_INTERP)
{
    IMCC_INFO(interp) -> nargs = 0;
    IMCC_INFO(interp) -> keyvec = 0;
}

Instruction *
INS_LABEL(PARROT_INTERP, IMC_Unit *unit, SymReg *r0, int emit)
{

    Instruction * const ins = _mk_instruction("","%s:", 1, &r0, 0);
    ins->type               = ITLABEL;
    r0->first_ins           = ins;

    if (emit)
        emitb(interp, unit, ins);

    return ins;
}

static Instruction * iLABEL(PARROT_INTERP, IMC_Unit *unit, SymReg *r0) {
    Instruction * const i = INS_LABEL(interp, unit, r0, 1);
    i->line               = IMCC_INFO(interp)->line;

    clear_state(interp);
    return i;
}

static Instruction *
iSUBROUTINE(PARROT_INTERP, IMC_Unit *unit, NOTNULL(SymReg *r)) {
    Instruction * const i =iLABEL(interp, unit, r);

    r->type    = (r->type & VT_ENCODED) ? VT_PCC_SUB|VT_ENCODED : VT_PCC_SUB;
    r->pcc_sub = (pcc_sub_t*)calloc(1, sizeof (struct pcc_sub_t));

    IMCC_INFO(interp)->cur_call = r;
    i->line                     = IMCC_INFO(interp)->line;

    add_namespace(interp, unit);
    return i;
}

/*
 * substr or X = P[key]
 */
static Instruction *
iINDEXFETCH(PARROT_INTERP, IMC_Unit *unit, SymReg *r0, SymReg *r1, SymReg *r2)
{
    if (r0->set == 'S' && r1->set == 'S' && r2->set == 'I') {
        SymReg * const r3 = mk_const(interp, str_dup("1"), 'I');
        return MK_I(interp, unit, "substr %s, %s, %s, 1", 4, r0, r1, r2, r3);
    }

    IMCC_INFO(interp) -> keyvec |= KEY_BIT(2);
    return MK_I(interp, unit, "set %s, %s[%s]", 3, r0,r1,r2);
}

/*
 * substr or P[key] = X
 */

static Instruction *
iINDEXSET(PARROT_INTERP, IMC_Unit * unit,
          SymReg * r0, SymReg * r1, SymReg * r2)
{
    if (r0->set == 'S' && r1->set == 'I' && r2->set == 'S') {
        SymReg * r3 = mk_const(interp, str_dup("1"), 'I');
        MK_I(interp, unit, "substr %s, %s, %s, %s", 4, r0, r1,r3, r2);
    }
    else if (r0->set == 'P') {
        IMCC_INFO(interp) -> keyvec |= KEY_BIT(1);
        MK_I(interp, unit, "set %s[%s], %s", 3, r0,r1,r2);
    }
    else {
        IMCC_fataly(interp, E_SyntaxError,
            "unsupported indexed set op\n");
    }
    return 0;
}

static const char *
inv_op(const char *op) {
    int n;
    return get_neg_op(op, &n);
}

Instruction *
IMCC_create_itcall_label(PARROT_INTERP)
{
    char name[128];
    SymReg * r;
    Instruction *i;

    sprintf(name, "%cpcc_sub_call_%d", IMCC_INTERNAL_CHAR, IMCC_INFO(interp)->cnr++);
    r = mk_pcc_sub(interp, str_dup(name), 0);
    i = iLABEL(interp, IMCC_INFO(interp)->cur_unit, r);
    IMCC_INFO(interp)->cur_call = r;
    i->type = ITCALL | ITPCCSUB;
    return i;
}


static SymReg *
mk_sub_address_fromc(PARROT_INTERP, char * name)
{
    /* name is a quoted sub name */
    SymReg *r;

    name[strlen(name) - 1] = '\0';
    r = mk_sub_address(interp, str_dup(name + 1));
    mem_sys_free(name);
    return r;
}

static SymReg *
mk_sub_address_u(PARROT_INTERP, char * name)
{
    SymReg * const r = mk_sub_address(interp, name);
    r->type         |= VT_ENCODED;

    return r;
}

void
IMCC_itcall_sub(PARROT_INTERP, SymReg *sub)
{
    IMCC_INFO(interp)->cur_call->pcc_sub->sub = sub;
    if (IMCC_INFO(interp)->cur_obj) {
        if (IMCC_INFO(interp)->cur_obj->set != 'P')
            IMCC_fataly(interp, E_SyntaxError, "object isn't a PMC");
        IMCC_INFO(interp)->cur_call->pcc_sub->object = IMCC_INFO(interp)->cur_obj;
        IMCC_INFO(interp)->cur_obj = NULL;
    }
    if (IMCC_INFO(interp)->cur_call->pcc_sub->sub->pmc_type == enum_class_NCI)
        IMCC_INFO(interp)->cur_call->pcc_sub->flags |= isNCI;
    if (IMCC_INFO(interp)->cur_unit->type == IMC_PCCSUB)
        IMCC_INFO(interp)->cur_unit->instructions->r[0]->pcc_sub->calls_a_sub |= 1;
}

static void
begin_return_or_yield(PARROT_INTERP, int yield)
{
    Instruction *i;
    Instruction * const ins = IMCC_INFO(interp)->cur_unit->instructions;
    char                name[128];

    if (!ins || !ins->r[0] || !(ins->r[0]->type & VT_PCC_SUB))
        IMCC_fataly(interp, E_SyntaxError,
                    "yield or return directive outside pcc subroutine\n");
    if (yield)
       ins->r[0]->pcc_sub->calls_a_sub = 1 | ITPCCYIELD;
    sprintf(name, yield ? "%cpcc_sub_yield_%d" : "%cpcc_sub_ret_%d",
            IMCC_INTERNAL_CHAR, IMCC_INFO(interp)->cnr++);
    interp->imc_info->sr_return = mk_pcc_sub(interp, str_dup(name), 0);
    i = iLABEL(interp, IMCC_INFO(interp)->cur_unit, interp->imc_info->sr_return);
    i->type = yield ? ITPCCSUB | ITLABEL | ITPCCYIELD : ITPCCSUB | ITLABEL ;
    interp->imc_info->asm_state = yield ? AsmInYield : AsmInReturn;
}

static void
set_lexical(PARROT_INTERP, NOTNULL(SymReg *r), char *name)
{
    SymReg *n = mk_const(interp, name, 'S');

    r->usage |= U_LEXICAL;

    if (n == r->reg)
        IMCC_fataly(interp, E_SyntaxError,
            "register %s already declared as lexical %s", r->name, n->name);

    /* chain all names in r->reg */
    n->reg = r->reg;
    r->reg = n;
}

static void
add_pcc_named_arg(PARROT_INTERP, NOTNULL(SymReg *cur_call), const char *name,
                  SymReg *value)
{
    SymReg *r = mk_const(interp, name, 'S');
    r->type  |= VT_NAMED;

    add_pcc_arg(cur_call, r);
    add_pcc_arg(cur_call, value);
}

static void
add_pcc_named_result(PARROT_INTERP, SymReg *cur_call, const char *name,
                     SymReg *value)
{
    SymReg * const r = mk_const(interp, name, 'S');
    r->type         |= VT_NAMED;

    add_pcc_result(cur_call, r);
    add_pcc_result(cur_call, value);
}

static void
add_pcc_named_param(PARROT_INTERP, SymReg *cur_call, const char *name,
                    SymReg *value)
{
    SymReg * const r = mk_const(interp, name, 'S');
    r->type         |= VT_NAMED;

    add_pcc_param(cur_call, r);
    add_pcc_param(cur_call, value);
}

static void
add_pcc_named_return(PARROT_INTERP, SymReg *cur_call, const char *name,
                     SymReg *value)
{
    SymReg * const r = mk_const(interp, name, 'S');
    r->type         |= VT_NAMED;

    add_pcc_return(cur_call, r);
    add_pcc_return(cur_call, value);
}

static void
adv_named_set(PARROT_INTERP, char *name) {
    if (IMCC_INFO(interp)->adv_named_id) {
        IMCC_fataly(interp, E_SyntaxError,
                    "Named parameter with more than one name.\n");
    }
    IMCC_INFO(interp)->adv_named_id = name;
}

static void
do_loadlib(PARROT_INTERP, NOTNULL(const char *lib))
{
    PMC *ignored;
    STRING * const s = string_unescape_cstring(interp, lib + 1, '"', NULL);
    ignored = Parrot_load_lib(interp, s, NULL);
    UNUSED(ignored);
    Parrot_register_HLL_lib(interp, s);
}

/* HEADERIZER STOP */



/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* Enabling the token table.  */
#ifndef YYTOKEN_TABLE
# define YYTOKEN_TABLE 0
#endif

#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 516 "compilers/imcc/imcc.y"
{
    IdList * idlist;
    int t;
    char * s;
    SymReg * sr;
    Instruction *i;
}
/* Line 187 of yacc.c.  */
#line 853 "compilers/imcc/imcparser.c"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



/* Copy the second part of user declarations.  */


/* Line 216 of yacc.c.  */
#line 866 "compilers/imcc/imcparser.c"

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#elif (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
typedef signed char yytype_int8;
#else
typedef short int yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(e) ((void) (e))
#else
# define YYUSE(e) /* empty */
#endif

/* Identity function, used to suppress warnings about constant conditions.  */
#ifndef lint
# define YYID(n) (n)
#else
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static int
YYID (int i)
#else
static int
YYID (i)
    int i;
#endif
{
  return i;
}
#endif

#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#     ifndef _STDLIB_H
#      define _STDLIB_H 1
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (YYID (0))
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined _STDLIB_H \
       && ! ((defined YYMALLOC || defined malloc) \
	     && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef _STDLIB_H
#    define _STDLIB_H 1
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
	 || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss;
  YYSTYPE yyvs;
  };

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  YYSIZE_T yyi;				\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (YYID (0))
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack)					\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack, Stack, yysize);				\
	Stack = &yyptr->Stack;						\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (YYID (0))

#endif

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  32
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   706

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  134
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  121
/* YYNRULES -- Number of rules.  */
#define YYNRULES  339
/* YYNRULES -- Number of states.  */
#define YYNSTATES  547

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   372

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       4,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,   124,     2,     2,     2,   130,   131,     2,
     122,   123,   128,   127,     2,   126,     2,   129,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,   133,
       2,   119,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,   120,     2,   121,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,   132,     2,   125,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     5,
       6,     7,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    41,    42,    43,    44,    45,
      46,    47,    48,    49,    50,    51,    52,    53,    54,    55,
      56,    57,    58,    59,    60,    61,    62,    63,    64,    65,
      66,    67,    68,    69,    70,    71,    72,    73,    74,    75,
      76,    77,    78,    79,    80,    81,    82,    83,    84,    85,
      86,    87,    88,    89,    90,    91,    92,    93,    94,    95,
      96,    97,    98,    99,   100,   101,   102,   103,   104,   105,
     106,   107,   108,   109,   110,   111,   112,   113,   114,   115,
     116,   117,   118
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint16 yyprhs[] =
{
       0,     0,     3,     5,     7,    10,    12,    14,    16,    18,
      21,    23,    25,    29,    32,    36,    39,    44,    49,    54,
      55,    62,    63,    70,    72,    74,    76,    79,    83,    86,
      88,    90,    92,    94,    96,    97,   101,   102,   107,   110,
     115,   116,   118,   119,   124,   125,   127,   131,   135,   136,
     137,   138,   139,   150,   151,   153,   157,   158,   162,   166,
     172,   173,   175,   180,   185,   190,   192,   197,   198,   202,
     204,   206,   208,   210,   212,   214,   216,   220,   221,   223,
     224,   234,   235,   238,   239,   243,   244,   246,   248,   252,
     254,   256,   258,   260,   262,   264,   266,   268,   270,   272,
     274,   280,   284,   288,   292,   296,   302,   308,   309,   313,
     316,   317,   321,   325,   326,   331,   332,   335,   337,   339,
     341,   343,   348,   350,   351,   357,   359,   360,   366,   367,
     370,   374,   378,   379,   385,   387,   389,   390,   392,   396,
     400,   406,   408,   411,   412,   415,   418,   420,   422,   423,
     425,   428,   430,   432,   436,   439,   441,   445,   448,   449,
     451,   453,   455,   458,   461,   462,   467,   472,   473,   480,
     482,   483,   490,   493,   496,   499,   502,   504,   506,   508,
     510,   511,   513,   515,   517,   519,   521,   523,   527,   532,
     538,   545,   552,   559,   567,   572,   577,   584,   591,   599,
     604,   609,   614,   619,   626,   634,   638,   639,   649,   651,
     653,   655,   659,   661,   663,   665,   667,   669,   671,   673,
     675,   677,   679,   681,   683,   685,   687,   689,   691,   693,
     695,   697,   699,   701,   703,   705,   707,   709,   711,   712,
     718,   722,   724,   726,   728,   730,   732,   734,   736,   738,
     740,   742,   744,   746,   748,   753,   755,   757,   759,   761,
     765,   769,   773,   774,   780,   781,   785,   787,   793,   797,
     800,   801,   804,   806,   808,   813,   816,   820,   826,   828,
     832,   833,   835,   837,   844,   850,   855,   860,   867,   873,
     875,   877,   879,   881,   883,   885,   887,   889,   891,   893,
     894,   896,   900,   902,   904,   909,   913,   915,   917,   919,
     921,   923,   925,   927,   929,   931,   933,   935,   936,   939,
     940,   943,   945,   949,   950,   955,   957,   961,   964,   967,
     969,   971,   973,   975,   977,   979,   981,   983,   985,   987
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int16 yyrhs[] =
{
     135,     0,    -1,   136,    -1,   137,    -1,   136,   137,    -1,
     155,    -1,   141,    -1,   157,    -1,   152,    -1,   107,     4,
      -1,   138,    -1,     4,    -1,     6,   139,     4,    -1,   140,
       4,    -1,    96,   109,     4,    -1,     7,   110,    -1,     8,
     109,    71,   109,    -1,     9,   110,    71,   110,    -1,     9,
     109,    71,   109,    -1,    -1,    29,   142,   211,   105,   119,
     253,    -1,    -1,    29,   144,   110,   243,   119,   145,    -1,
     109,    -1,   112,    -1,   147,    -1,   146,   147,    -1,   200,
     148,     4,    -1,   107,     4,    -1,   116,    -1,   115,    -1,
     155,    -1,   143,    -1,   138,    -1,    -1,   149,   113,   151,
      -1,    -1,    77,   150,   176,    98,    -1,    14,   244,    -1,
      28,   109,    71,   106,    -1,    -1,   237,    -1,    -1,    99,
     153,   154,   100,    -1,    -1,   146,    -1,    22,   156,     4,
      -1,   120,   245,   121,    -1,    -1,    -1,    -1,    -1,    25,
     158,   240,   159,   176,     4,   160,   161,   171,    72,    -1,
      -1,     4,    -1,   161,   162,     4,    -1,    -1,     5,   163,
     164,    -1,   211,   105,   185,    -1,   211,   109,    20,   105,
     185,    -1,    -1,    71,    -1,    94,   122,   169,   123,    -1,
      92,   122,   109,   123,    -1,    92,   122,   105,   123,    -1,
      95,    -1,    95,   122,   109,   123,    -1,    -1,   169,    71,
     170,    -1,   170,    -1,    49,    -1,    50,    -1,    52,    -1,
      51,    -1,   105,    -1,   109,    -1,   120,   245,   121,    -1,
      -1,   197,    -1,    -1,    74,     4,   173,   180,   175,   179,
     174,   182,    75,    -1,    -1,   202,     4,    -1,    -1,    84,
     244,     4,    -1,    -1,   177,    -1,   178,    -1,   177,   165,
     178,    -1,    86,    -1,    87,    -1,    85,    -1,    88,    -1,
      89,    -1,    91,    -1,    90,    -1,    93,    -1,   166,    -1,
     167,    -1,   168,    -1,    76,   244,    71,   244,     4,    -1,
      76,   244,     4,    -1,    82,   244,     4,    -1,    83,   236,
       4,    -1,    83,   109,     4,    -1,    83,   236,    71,   244,
       4,    -1,    83,   109,    71,   244,     4,    -1,    -1,   180,
     181,     4,    -1,    11,   226,    -1,    -1,   182,   183,     4,
      -1,    63,   236,   185,    -1,    -1,    27,   184,   211,   205,
      -1,    -1,   185,   186,    -1,    16,    -1,    17,    -1,    18,
      -1,    19,    -1,    19,   122,   109,   123,    -1,    97,    -1,
      -1,    78,     4,   188,   191,    79,    -1,   193,    -1,    -1,
      80,     4,   190,   191,    81,    -1,    -1,   191,     4,    -1,
     191,   192,     4,    -1,    64,   244,   227,    -1,    -1,   195,
     122,   194,   196,   123,    -1,    64,    -1,    65,    -1,    -1,
     226,    -1,   109,    20,   244,    -1,   196,    71,   226,    -1,
     196,    71,   109,    20,   244,    -1,   199,    -1,   197,   199,
      -1,    -1,   198,   203,    -1,   107,     4,    -1,   116,    -1,
     115,    -1,    -1,   201,    -1,   201,   202,    -1,   202,    -1,
      98,    -1,   200,   207,     4,    -1,     1,     4,    -1,   205,
      -1,   204,    71,   205,    -1,   105,   206,    -1,    -1,    97,
      -1,   213,    -1,   231,    -1,    22,   105,    -1,    23,   105,
      -1,    -1,    27,   208,   211,   204,    -1,    28,   109,    71,
     236,    -1,    -1,    29,   209,   211,   105,   119,   253,    -1,
     143,    -1,    -1,    32,   210,   211,   105,   119,   253,    -1,
      64,   223,    -1,    10,   242,    -1,   113,   237,    -1,    14,
     244,    -1,   223,    -1,   172,    -1,   187,    -1,   189,    -1,
      -1,    49,    -1,    50,    -1,    51,    -1,    52,    -1,   212,
      -1,   105,    -1,   236,   119,   244,    -1,   236,   119,   215,
     244,    -1,   236,   119,   244,   216,   244,    -1,   236,   119,
     244,   120,   245,   121,    -1,   236,   120,   245,   121,   119,
     244,    -1,   236,   119,    21,   212,    71,   244,    -1,   236,
     119,    21,   212,   120,   245,   121,    -1,   236,   119,    21,
     212,    -1,   236,   119,    21,   244,    -1,   236,   119,    21,
     120,   245,   121,    -1,   236,   119,    21,   244,    71,   244,
      -1,   236,   119,    21,   244,   120,   245,   121,    -1,   236,
     119,    62,   105,    -1,   236,   119,    61,   254,    -1,    61,
     254,   119,   244,    -1,    21,   236,    71,   244,    -1,    21,
     236,    71,   244,    71,   244,    -1,    21,   236,    71,   244,
     120,   245,   121,    -1,   236,   119,   223,    -1,    -1,   122,
     214,   230,   123,   119,   222,   122,   225,   123,    -1,   217,
      -1,   219,    -1,   221,    -1,   236,   119,    14,    -1,   124,
      -1,   125,    -1,   126,    -1,   126,    -1,   127,    -1,   128,
      -1,   129,    -1,   130,    -1,    41,    -1,    67,    -1,   118,
      -1,    54,    -1,    55,    -1,    56,    -1,    57,    -1,    58,
      -1,    59,    -1,    47,    -1,    48,    -1,    68,    -1,    69,
      -1,    70,    -1,    53,    -1,   131,    -1,   132,    -1,   125,
      -1,    -1,    66,   218,   122,   230,   123,    -1,   236,   220,
     244,    -1,    33,    -1,    34,    -1,    35,    -1,    36,    -1,
      43,    -1,    42,    -1,    37,    -1,    38,    -1,    39,    -1,
      40,    -1,    44,    -1,    45,    -1,    46,    -1,   236,   119,
     113,   151,    -1,   105,    -1,   109,    -1,   112,    -1,   236,
      -1,   236,   117,   241,    -1,   236,   117,   109,    -1,   236,
     117,   236,    -1,    -1,   222,   224,   122,   225,   123,    -1,
      -1,   225,    71,   226,    -1,   226,    -1,   225,    71,   109,
      20,   244,    -1,   109,    20,   244,    -1,   244,   227,    -1,
      -1,   227,   228,    -1,    15,    -1,    19,    -1,    19,   122,
     109,   123,    -1,   236,   185,    -1,   230,    71,   229,    -1,
     230,    71,   109,    20,   236,    -1,   229,    -1,   109,    20,
     236,    -1,    -1,   233,    -1,   232,    -1,    13,   244,   235,
     244,    10,   242,    -1,    13,    14,   244,    10,   242,    -1,
      13,   244,   234,   242,    -1,    12,   244,   234,   242,    -1,
      12,   244,   235,   244,    10,   242,    -1,    12,    14,   244,
      10,   242,    -1,    71,    -1,    10,    -1,    54,    -1,    55,
      -1,    56,    -1,    57,    -1,    58,    -1,    59,    -1,   114,
      -1,   252,    -1,    -1,   238,    -1,   238,    71,   239,    -1,
     239,    -1,   243,    -1,   236,   120,   245,   121,    -1,   120,
     247,   121,    -1,   241,    -1,   109,    -1,   112,    -1,   105,
      -1,   113,    -1,   105,    -1,   113,    -1,   242,    -1,   244,
      -1,   236,    -1,   253,    -1,    -1,   246,   249,    -1,    -1,
     248,   249,    -1,   251,    -1,   249,   133,   251,    -1,    -1,
     249,    71,   250,   251,    -1,   244,    -1,   244,    73,   244,
      -1,    73,   244,    -1,   244,    73,    -1,   101,    -1,   102,
      -1,   103,    -1,   104,    -1,   106,    -1,   110,    -1,   111,
      -1,   109,    -1,   112,    -1,   103,    -1,   109,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   608,   608,   612,   613,   617,   618,   619,   622,   625,
     626,   627,   630,   631,   632,   635,   643,   656,   662,   682,
     682,   687,   687,   691,   692,   696,   697,   701,   702,   703,
     704,   705,   706,   707,   710,   710,   717,   716,   727,   729,
     734,   738,   742,   742,   752,   754,   758,   773,   774,   779,
     783,   786,   778,   792,   793,   794,   805,   805,   809,   814,
     824,   825,   829,   832,   835,   840,   844,   851,   852,   853,
     857,   858,   859,   860,   861,   871,   881,   884,   886,   891,
     890,   923,   924,   928,   929,   934,   935,   939,   940,   944,
     945,   946,   947,   948,   949,   950,   951,   952,   953,   954,
     958,   963,   965,   970,   972,   974,   978,   986,   987,   991,
     996,   997,  1001,  1002,  1002,  1017,  1018,  1022,  1023,  1024,
    1025,  1026,  1027,  1033,  1032,  1037,  1043,  1042,  1050,  1051,
    1054,  1060,  1065,  1064,  1074,  1075,  1079,  1080,  1087,  1089,
    1096,  1102,  1103,  1115,  1119,  1121,  1122,  1123,  1127,  1128,
    1132,  1133,  1137,  1145,  1147,  1156,  1163,  1172,  1182,  1183,
    1188,  1189,  1190,  1191,  1192,  1192,  1209,  1213,  1213,  1215,
    1216,  1216,  1218,  1222,  1223,  1229,  1231,  1232,  1233,  1234,
    1235,  1239,  1240,  1241,  1242,  1243,  1247,  1258,  1260,  1262,
    1264,  1266,  1268,  1270,  1272,  1274,  1276,  1278,  1280,  1282,
    1285,  1287,  1291,  1293,  1295,  1298,  1305,  1304,  1313,  1314,
    1315,  1316,  1321,  1322,  1323,  1327,  1328,  1329,  1330,  1331,
    1332,  1333,  1334,  1335,  1336,  1337,  1338,  1339,  1340,  1341,
    1342,  1343,  1344,  1345,  1346,  1347,  1348,  1349,  1353,  1353,
    1361,  1366,  1367,  1368,  1369,  1370,  1371,  1372,  1373,  1374,
    1375,  1376,  1377,  1378,  1383,  1392,  1393,  1394,  1395,  1400,
    1401,  1402,  1408,  1407,  1417,  1418,  1425,  1432,  1434,  1438,
    1442,  1443,  1447,  1448,  1449,  1452,  1456,  1463,  1465,  1472,
    1473,  1477,  1478,  1482,  1484,  1486,  1491,  1493,  1495,  1500,
    1501,  1505,  1506,  1507,  1508,  1509,  1510,  1514,  1515,  1519,
    1520,  1524,  1525,  1529,  1530,  1537,  1544,  1545,  1546,  1550,
    1551,  1555,  1556,  1560,  1561,  1565,  1566,  1569,  1569,  1576,
    1576,  1584,  1585,  1588,  1588,  1594,  1599,  1604,  1605,  1609,
    1610,  1611,  1612,  1613,  1617,  1618,  1619,  1620,  1624,  1625
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "LOW_PREC", "'\\n'", "PARAM", "PRAGMA",
  "N_OPERATORS", "HLL", "HLL_MAP", "GOTO", "ARG", "IF", "UNLESS", "PNULL",
  "ADV_FLAT", "ADV_SLURPY", "ADV_OPTIONAL", "ADV_OPT_FLAG", "ADV_NAMED",
  "ADV_ARROW", "NEW", "NAMESPACE", "ENDNAMESPACE", "DOT_METHOD", "SUB",
  "SYM", "LOCAL", "LEXICAL", "CONST", "INC", "DEC", "GLOBAL_CONST",
  "PLUS_ASSIGN", "MINUS_ASSIGN", "MUL_ASSIGN", "DIV_ASSIGN",
  "CONCAT_ASSIGN", "BAND_ASSIGN", "BOR_ASSIGN", "BXOR_ASSIGN", "FDIV",
  "FDIV_ASSIGN", "MOD_ASSIGN", "SHR_ASSIGN", "SHL_ASSIGN", "SHR_U_ASSIGN",
  "SHIFT_LEFT", "SHIFT_RIGHT", "INTV", "FLOATV", "STRINGV", "PMCV",
  "LOG_XOR", "RELOP_EQ", "RELOP_NE", "RELOP_GT", "RELOP_GTE", "RELOP_LT",
  "RELOP_LTE", "GLOBAL", "GLOBALOP", "ADDR", "RESULT", "RETURN", "YIELDT",
  "GET_RESULTS", "POW", "SHIFT_RIGHT_U", "LOG_AND", "LOG_OR", "COMMA",
  "ESUB", "DOTDOT", "PCC_BEGIN", "PCC_END", "PCC_CALL", "PCC_SUB",
  "PCC_BEGIN_RETURN", "PCC_END_RETURN", "PCC_BEGIN_YIELD", "PCC_END_YIELD",
  "NCI_CALL", "METH_CALL", "INVOCANT", "MAIN", "LOAD", "INIT", "IMMEDIATE",
  "POSTCOMP", "METHOD", "ANON", "OUTER", "NEED_LEX", "MULTI",
  "VTABLE_METHOD", "LOADLIB", "UNIQUE_REG", "LABEL", "EMIT", "EOM", "IREG",
  "NREG", "SREG", "PREG", "IDENTIFIER", "REG", "MACRO", "ENDM", "STRINGC",
  "INTC", "FLOATC", "USTRINGC", "PARROT_OP", "VAR", "LINECOMMENT",
  "FILECOMMENT", "DOT", "CONCAT", "'='", "'['", "']'", "'('", "')'", "'!'",
  "'~'", "'-'", "'+'", "'*'", "'/'", "'%'", "'&'", "'|'", "';'", "$accept",
  "program", "compilation_units", "compilation_unit", "pragma", "pragma_1",
  "hll_def", "constdef", "@1", "pmc_const", "@2", "any_string", "pasmcode",
  "pasmline", "pasm_inst", "@3", "@4", "pasm_args", "emit", "@5",
  "opt_pasmcode", "class_namespace", "maybe_ns", "sub", "@6", "@7", "@8",
  "sub_params", "sub_param", "@9", "sub_param_type_def", "opt_comma",
  "multi", "outer", "vtable", "multi_types", "multi_type", "sub_body",
  "pcc_sub_call", "@10", "opt_label", "opt_invocant", "sub_proto",
  "sub_proto_list", "proto", "pcc_call", "pcc_args", "pcc_arg",
  "pcc_results", "pcc_result", "@11", "paramtype_list", "paramtype",
  "pcc_ret", "@12", "pcc_yield", "@13", "pcc_returns", "pcc_return",
  "pcc_return_many", "@14", "return_or_yield", "var_returns", "statements",
  "helper_clear_state", "statement", "labels", "_labels", "label",
  "instruction", "id_list", "id_list_id", "opt_unique_reg", "labeled_inst",
  "@15", "@16", "@17", "type", "classname", "assignment", "@18", "un_op",
  "bin_op", "get_results", "@19", "op_assign", "assign_op", "func_assign",
  "the_sub", "sub_call", "@20", "arglist", "arg", "argtype_list",
  "argtype", "result", "targetlist", "conditional_statement",
  "unless_statement", "if_statement", "comma_or_goto", "relop", "target",
  "vars", "_vars", "_var_or_i", "sub_label_op_c", "sub_label_op",
  "label_op", "var_or_i", "var", "keylist", "@21", "keylist_force", "@22",
  "_keylist", "@23", "key", "reg", "const", "string", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,    10,   259,   260,   261,   262,   263,
     264,   265,   266,   267,   268,   269,   270,   271,   272,   273,
     274,   275,   276,   277,   278,   279,   280,   281,   282,   283,
     284,   285,   286,   287,   288,   289,   290,   291,   292,   293,
     294,   295,   296,   297,   298,   299,   300,   301,   302,   303,
     304,   305,   306,   307,   308,   309,   310,   311,   312,   313,
     314,   315,   316,   317,   318,   319,   320,   321,   322,   323,
     324,   325,   326,   327,   328,   329,   330,   331,   332,   333,
     334,   335,   336,   337,   338,   339,   340,   341,   342,   343,
     344,   345,   346,   347,   348,   349,   350,   351,   352,   353,
     354,   355,   356,   357,   358,   359,   360,   361,   362,   363,
     364,   365,   366,   367,   368,   369,   370,   371,   372,    61,
      91,    93,    40,    41,    33,   126,    45,    43,    42,    47,
      37,    38,   124,    59
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,   134,   135,   136,   136,   137,   137,   137,   137,   137,
     137,   137,   138,   138,   138,   139,   140,   140,   140,   142,
     141,   144,   143,   145,   145,   146,   146,   147,   147,   147,
     147,   147,   147,   147,   149,   148,   150,   148,   148,   148,
     148,   151,   153,   152,   154,   154,   155,   156,   156,   158,
     159,   160,   157,   161,   161,   161,   163,   162,   164,   164,
     165,   165,   166,   167,   167,   168,   168,   169,   169,   169,
     170,   170,   170,   170,   170,   170,   170,   171,   171,   173,
     172,   174,   174,   175,   175,   176,   176,   177,   177,   178,
     178,   178,   178,   178,   178,   178,   178,   178,   178,   178,
     179,   179,   179,   179,   179,   179,   179,   180,   180,   181,
     182,   182,   183,   184,   183,   185,   185,   186,   186,   186,
     186,   186,   186,   188,   187,   187,   190,   189,   191,   191,
     191,   192,   194,   193,   195,   195,   196,   196,   196,   196,
     196,   197,   197,   198,   199,   199,   199,   199,   200,   200,
     201,   201,   202,   203,   203,   204,   204,   205,   206,   206,
     207,   207,   207,   207,   208,   207,   207,   209,   207,   207,
     210,   207,   207,   207,   207,   207,   207,   207,   207,   207,
     207,   211,   211,   211,   211,   211,   212,   213,   213,   213,
     213,   213,   213,   213,   213,   213,   213,   213,   213,   213,
     213,   213,   213,   213,   213,   213,   214,   213,   213,   213,
     213,   213,   215,   215,   215,   216,   216,   216,   216,   216,
     216,   216,   216,   216,   216,   216,   216,   216,   216,   216,
     216,   216,   216,   216,   216,   216,   216,   216,   218,   217,
     219,   220,   220,   220,   220,   220,   220,   220,   220,   220,
     220,   220,   220,   220,   221,   222,   222,   222,   222,   222,
     222,   222,   224,   223,   225,   225,   225,   225,   225,   226,
     227,   227,   228,   228,   228,   229,   230,   230,   230,   230,
     230,   231,   231,   232,   232,   232,   233,   233,   233,   234,
     234,   235,   235,   235,   235,   235,   235,   236,   236,   237,
     237,   238,   238,   239,   239,   239,   240,   240,   240,   241,
     241,   242,   242,   243,   243,   244,   244,   246,   245,   248,
     247,   249,   249,   250,   249,   251,   251,   251,   251,   252,
     252,   252,   252,   252,   253,   253,   253,   253,   254,   254
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     1,     1,     2,     1,     1,     1,     1,     2,
       1,     1,     3,     2,     3,     2,     4,     4,     4,     0,
       6,     0,     6,     1,     1,     1,     2,     3,     2,     1,
       1,     1,     1,     1,     0,     3,     0,     4,     2,     4,
       0,     1,     0,     4,     0,     1,     3,     3,     0,     0,
       0,     0,    10,     0,     1,     3,     0,     3,     3,     5,
       0,     1,     4,     4,     4,     1,     4,     0,     3,     1,
       1,     1,     1,     1,     1,     1,     3,     0,     1,     0,
       9,     0,     2,     0,     3,     0,     1,     1,     3,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       5,     3,     3,     3,     3,     5,     5,     0,     3,     2,
       0,     3,     3,     0,     4,     0,     2,     1,     1,     1,
       1,     4,     1,     0,     5,     1,     0,     5,     0,     2,
       3,     3,     0,     5,     1,     1,     0,     1,     3,     3,
       5,     1,     2,     0,     2,     2,     1,     1,     0,     1,
       2,     1,     1,     3,     2,     1,     3,     2,     0,     1,
       1,     1,     2,     2,     0,     4,     4,     0,     6,     1,
       0,     6,     2,     2,     2,     2,     1,     1,     1,     1,
       0,     1,     1,     1,     1,     1,     1,     3,     4,     5,
       6,     6,     6,     7,     4,     4,     6,     6,     7,     4,
       4,     4,     4,     6,     7,     3,     0,     9,     1,     1,
       1,     3,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     0,     5,
       3,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     4,     1,     1,     1,     1,     3,
       3,     3,     0,     5,     0,     3,     1,     5,     3,     2,
       0,     2,     1,     1,     4,     2,     3,     5,     1,     3,
       0,     1,     1,     6,     5,     4,     4,     6,     5,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     0,
       1,     3,     1,     1,     4,     3,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     0,     2,     0,
       2,     1,     3,     0,     4,     1,     3,     2,     2,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint16 yydefact[] =
{
       0,    11,     0,     0,     0,    48,    49,    19,     0,    42,
       0,     0,     2,     3,    10,     0,     6,     8,     5,     7,
       0,     0,     0,     0,     0,   317,     0,     0,     0,     0,
     148,     9,     1,     4,    13,    15,    12,     0,     0,     0,
       0,     0,    46,   309,   307,   308,   310,    50,   306,   181,
     182,   183,   184,   186,     0,   185,    14,    21,   152,     0,
      30,    29,    33,    32,   148,    25,     0,    31,    34,   149,
     151,    16,    18,    17,    47,     0,   329,   330,   331,   332,
     333,   336,   334,   335,   337,   297,   315,   325,   318,   321,
     298,   316,    85,     0,     0,    28,    26,    43,     0,     0,
      36,     0,     0,   150,   327,   328,   323,     0,    91,    89,
      90,    92,    93,    95,    94,     0,    96,     0,    65,    97,
      98,    99,     0,    60,    87,     0,     0,    38,     0,    85,
      27,   299,   326,     0,   322,     0,    67,     0,    51,    61,
       0,    20,   311,   312,   313,     0,   314,     0,     0,   319,
      35,   315,    41,   300,   302,   303,   324,     0,     0,    70,
      71,    73,    72,    74,    75,   317,     0,    69,     0,    53,
      88,     0,    39,    37,     0,     0,   317,     0,    64,    63,
       0,     0,    62,    66,    54,   143,    23,    24,    22,   305,
     320,     0,   301,    76,    68,    56,     0,   147,   146,     0,
       0,   143,     0,   141,   304,     0,   145,    55,    52,   142,
       0,   180,   144,    57,     0,   154,     0,     0,     0,     0,
       0,     0,     0,   164,     0,   167,   170,     0,   134,   135,
     238,     0,     0,     0,   255,   256,   257,   299,   206,   169,
     177,   178,   179,   125,     0,     0,   160,   208,   209,   210,
     262,   176,   161,   282,   281,   258,   115,     0,   173,     0,
       0,     0,     0,   175,     0,   162,   163,     0,     0,     0,
       0,   338,   339,     0,   172,   258,     0,    79,   123,   126,
     174,   280,   132,   153,     0,   241,   242,   243,   244,   247,
     248,   249,   250,   246,   245,   251,   252,   253,     0,     0,
     317,     0,    58,     0,     0,   290,   291,   292,   293,   294,
     295,   296,   289,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   280,   107,   128,   128,     0,   278,
       0,   115,   136,   264,   260,   261,   259,   211,     0,     0,
       0,   336,   337,   299,   212,   213,   214,     0,   205,   315,
     187,     0,   240,   117,   118,   119,   120,   122,   116,   115,
       0,   286,     0,     0,   285,     0,   202,   158,   165,   155,
     166,     0,     0,   201,     0,    83,     0,     0,     0,     0,
       0,   275,   336,     0,   137,   270,   336,     0,   266,   317,
     194,   195,   200,   199,   254,   188,   220,   229,   230,   234,
     223,   224,   225,   226,   227,   228,   221,   231,   232,   233,
     222,   317,   237,   215,   216,   217,   218,   219,   235,   236,
       0,     0,     0,    59,   288,     0,   284,     0,     0,   317,
     159,   157,     0,     0,     0,   239,     0,     0,     0,     0,
     129,     0,   124,     0,   127,   279,     0,   276,     0,     0,
       0,   133,   269,     0,     0,   263,     0,     0,   317,     0,
     317,     0,   189,     0,     0,   287,   283,   203,     0,   156,
     168,   171,   109,     0,     0,     0,     0,    81,   108,   270,
     130,     0,     0,   138,   336,   139,   272,   273,   271,   268,
     336,   265,   196,   192,     0,   197,     0,   190,   191,   121,
     204,    84,     0,     0,     0,     0,   110,     0,   131,   277,
     264,     0,     0,     0,   193,   198,   101,     0,   102,   104,
       0,   103,     0,     0,    82,     0,   140,     0,   267,     0,
       0,     0,   113,     0,    80,     0,   207,   274,   100,   106,
     105,     0,   115,   111,     0,   112,   114
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,    11,    12,    13,    14,    21,    15,    16,    28,    63,
      94,   188,    64,    65,   101,   102,   129,   150,    17,    30,
      66,    18,    26,    19,    27,    92,   169,   185,   199,   205,
     213,   140,   119,   120,   121,   166,   167,   200,   240,   325,
     506,   438,   122,   123,   124,   477,   375,   439,   523,   535,
     541,   302,   358,   241,   326,   242,   327,   376,   443,   243,
     332,   244,   383,   201,   202,   203,    68,    69,    70,   212,
     368,   369,   431,   245,   267,   269,   270,    54,    55,   246,
     281,   347,   420,   247,   276,   248,   301,   249,   250,   251,
     284,   387,   388,   452,   488,   329,   330,   252,   253,   254,
     313,   314,    86,   152,   153,   154,    47,    48,   144,   155,
     385,    40,    41,   174,   175,    88,   133,    89,    90,    91,
     273
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -424
static const yytype_int16 yypact[] =
{
      13,  -424,    34,   -77,    57,   -66,  -424,  -424,   -53,  -424,
      39,    72,    13,  -424,  -424,    71,  -424,  -424,  -424,  -424,
     -23,    94,    29,    67,    77,  -424,   122,    96,    11,   153,
      17,  -424,  -424,  -424,  -424,  -424,  -424,    50,    65,    58,
      54,    78,  -424,  -424,  -424,  -424,  -424,  -424,  -424,  -424,
    -424,  -424,  -424,  -424,    81,  -424,  -424,  -424,  -424,   179,
    -424,  -424,  -424,  -424,   194,  -424,    85,  -424,    16,    95,
    -424,  -424,  -424,  -424,  -424,   326,  -424,  -424,  -424,  -424,
    -424,  -424,  -424,  -424,  -424,  -424,  -424,   131,   -31,  -424,
    -424,  -424,   611,    93,   111,  -424,  -424,  -424,   326,   113,
    -424,   237,   139,  -424,  -424,   326,  -424,    78,  -424,  -424,
    -424,  -424,  -424,  -424,  -424,   132,  -424,   134,   135,  -424,
    -424,  -424,   249,     6,  -424,   121,   502,  -424,   188,   611,
    -424,   440,  -424,    78,  -424,    22,   175,   152,  -424,  -424,
     611,  -424,  -424,  -424,  -424,   149,  -424,   165,   174,  -424,
    -424,   158,  -424,   208,  -424,  -424,  -424,   160,   163,  -424,
    -424,  -424,  -424,  -424,  -424,  -424,   -47,  -424,   164,   277,
    -424,   -38,  -424,  -424,   168,    78,  -424,   440,  -424,  -424,
     170,   175,  -424,  -424,  -424,     7,  -424,  -424,  -424,  -424,
     -31,   172,  -424,  -424,  -424,  -424,   292,  -424,  -424,   295,
     231,    56,   341,  -424,  -424,    11,  -424,  -424,  -424,  -424,
     300,   133,  -424,  -424,   101,  -424,   -58,   214,   274,   326,
     363,   200,   202,  -424,   199,   201,  -424,    55,   289,  -424,
    -424,   310,   317,   318,  -424,  -424,  -424,   440,  -424,  -424,
    -424,  -424,  -424,  -424,   205,   337,  -424,  -424,  -424,  -424,
    -424,  -424,  -424,  -424,  -424,   449,  -424,   324,  -424,   326,
     275,   326,   275,  -424,   278,  -424,  -424,    11,   279,    11,
      11,  -424,  -424,   238,  -424,   239,   236,  -424,  -424,  -424,
    -424,   234,  -424,  -424,   243,  -424,  -424,  -424,  -424,  -424,
    -424,  -424,  -424,  -424,  -424,  -424,  -424,  -424,   161,   396,
    -424,   326,    33,   254,   350,  -424,  -424,  -424,  -424,  -424,
    -424,  -424,  -424,   -58,   326,   351,   -58,   326,   326,   261,
     363,   262,   266,   326,   234,  -424,  -424,  -424,   352,  -424,
     -43,  -424,   516,   530,  -424,  -424,  -424,  -424,   469,    55,
     269,   259,   260,   440,  -424,  -424,  -424,   326,  -424,   126,
     470,   268,  -424,  -424,  -424,  -424,   291,  -424,  -424,  -424,
     -58,  -424,   387,   -58,  -424,   389,   -13,   314,   343,  -424,
    -424,   301,   304,  -424,   -40,     0,     9,    14,   363,   572,
     305,    33,   405,   -34,  -424,  -424,   406,   -26,  -424,  -424,
      -2,    -1,  -424,  -424,  -424,  -424,  -424,  -424,  -424,  -424,
    -424,  -424,  -424,  -424,  -424,  -424,  -424,  -424,  -424,  -424,
    -424,  -424,  -424,  -424,  -424,  -424,  -424,  -424,  -424,  -424,
     326,   312,   332,    33,  -424,   -58,  -424,   -58,   326,  -424,
    -424,  -424,   261,   121,   121,  -424,   326,   326,    59,   444,
    -424,   326,  -424,   445,  -424,  -424,   431,  -424,   289,   326,
     544,  -424,   225,   326,   558,  -424,   331,   326,  -424,   326,
    -424,   335,  -424,   326,   336,  -424,  -424,  -424,   339,  -424,
    -424,  -424,  -424,   457,   326,   326,   581,    95,  -424,  -424,
    -424,   363,   340,  -424,   448,  -424,  -424,   349,  -424,  -424,
     453,  -424,  -424,  -424,   353,  -424,   354,  -424,  -424,  -424,
    -424,  -424,    10,   474,    23,    25,  -424,   476,   225,  -424,
     530,   326,   381,   326,  -424,  -424,  -424,   326,  -424,  -424,
     326,  -424,   326,    74,  -424,   -18,  -424,   373,  -424,   499,
     500,   508,  -424,   363,  -424,   509,  -424,  -424,  -424,  -424,
    -424,    11,  -424,  -424,   261,    33,  -424
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -424,  -424,  -424,   503,    80,  -424,  -424,  -424,  -424,   303,
    -424,  -424,  -424,   452,  -424,  -424,  -424,   176,  -424,  -424,
    -424,   109,  -424,  -424,  -424,  -424,  -424,  -424,  -424,  -424,
    -424,  -424,  -424,  -424,  -424,  -424,   355,  -424,  -424,  -424,
    -424,  -424,   401,  -424,   391,  -424,  -424,  -424,  -424,  -424,
    -424,  -323,  -424,  -424,  -424,  -424,  -424,   206,  -424,  -424,
    -424,  -424,  -424,  -424,  -424,   333,   330,  -424,   -68,  -424,
    -424,  -423,  -424,  -424,  -424,  -424,  -424,  -202,   197,  -424,
    -424,  -424,  -424,  -424,  -424,  -424,  -424,  -424,    99,  -213,
    -424,    38,  -325,    76,  -424,   177,   233,  -424,  -424,  -424,
     296,   297,  -129,   325,  -424,   384,  -424,   265,  -210,   438,
     -41,  -160,  -424,  -424,  -424,   390,  -424,   -74,  -424,  -121,
     228
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -259
static const yytype_int16 yytable[] =
{
      87,   103,   151,   214,   141,   180,   258,   384,   381,   469,
     -86,   436,   195,   440,   516,   274,   191,     1,   440,     2,
     -40,     3,     4,     2,   181,     3,     4,   519,   379,   521,
      98,   379,    22,   134,   104,     5,   423,   450,     6,     5,
     106,    20,     7,    31,    99,   454,    57,   142,   151,   353,
     354,   355,   356,   454,    25,   143,    29,   127,   428,   156,
      49,    50,    51,    52,   132,   319,    87,   321,   322,   457,
     459,   186,    32,   441,   187,    34,   182,   139,   441,   -77,
     380,   517,   255,   435,   437,   146,   348,    35,   442,   451,
     146,   264,    87,   100,   520,   444,   522,   455,    36,   275,
      37,   532,   107,   361,   -86,   536,   364,   429,   151,     8,
      62,   472,     9,     8,   196,    58,    53,   -44,   458,   460,
      10,   546,   197,   198,    59,   485,    42,   157,   -78,   491,
     357,   158,    60,    61,    87,   474,   146,   533,    38,    67,
     351,   475,   476,   216,    62,   217,   218,   219,    39,   534,
     424,    75,   331,   426,   220,   221,   222,    56,   271,    71,
     223,   224,   225,   196,   272,   226,    23,    24,    73,   335,
     349,   197,   198,    67,    72,    74,   260,   262,   263,    76,
      77,    78,    79,    95,    80,    97,    93,    81,    82,    83,
      84,   370,    85,    58,   227,   331,   146,   228,   229,   230,
       2,    43,     3,     4,   105,    44,   256,   231,    45,    46,
     257,   232,   125,   233,   151,   465,     5,   466,   304,   545,
     315,   126,   128,    57,   159,   160,   161,   162,   259,   456,
      81,    82,    83,    84,    76,    77,    78,    79,   234,    80,
     486,   130,   235,   298,   487,   236,   237,    85,  -258,   445,
     331,   461,   131,   138,   135,   238,   136,   137,   350,   147,
     352,   168,    76,    77,    78,    79,    43,    80,   171,   468,
     334,   172,   173,   362,    46,    85,   365,   366,   176,   177,
     163,   184,   373,   178,   164,   305,   179,   183,   261,   189,
       8,   193,    58,   204,   -45,   165,   206,   391,   494,   207,
     496,    59,   146,   208,   215,   265,   395,   266,   268,    60,
      61,   -21,   470,   471,   277,    76,    77,    78,    79,   275,
      80,   278,   279,    81,    82,    83,    84,   282,    85,   306,
     307,   308,   309,   310,   311,    76,    77,    78,    79,   544,
      80,   283,   210,   328,   303,  -148,   312,   505,    85,   318,
     320,  -148,   509,  -148,  -148,  -148,   298,   323,   324,   359,
     360,   363,  -148,  -148,  -148,   333,   367,   371,  -148,  -148,
    -148,   372,   378,  -148,   393,    76,    77,    78,    79,   462,
      80,  -256,  -257,    81,    82,    83,    84,   467,    85,   421,
      76,    77,    78,    79,   234,    80,   473,   425,   235,   427,
     479,   236,  -148,    85,   542,  -148,  -148,  -148,   483,   507,
     337,   430,   489,   422,   432,  -148,   493,   338,   495,  -148,
     433,  -148,   498,   434,   448,   449,   453,    76,    77,    78,
      79,   463,    80,   502,   503,    81,    82,    83,    84,    58,
      85,   464,  -148,  -148,  -148,  -148,  -148,  -148,   478,   480,
    -148,   481,   492,  -148,  -148,  -148,   497,   339,   340,   499,
     500,   501,   510,  -148,    76,    77,    78,    79,   511,    80,
     526,   512,   528,   513,   514,   515,   529,    85,   518,   530,
     524,   531,   285,   286,   287,   288,   289,   290,   291,   292,
     527,   293,   294,   295,   296,   297,   537,    76,    77,    78,
      79,   234,    80,   538,   539,   341,    82,    83,   342,   343,
      85,   396,   540,   543,   239,    33,    96,   397,   398,   394,
     344,   345,   346,   399,   400,   401,   402,   403,   404,   405,
     148,   170,   211,   377,   209,   390,   194,   406,   407,   408,
     409,    76,    77,    78,    79,   142,    80,   482,   525,    81,
      82,    83,    84,   143,    85,   508,   447,   374,   316,   317,
     149,   192,   280,   336,   145,   190,   298,   392,   299,   300,
      76,    77,    78,    79,    53,    80,     0,     0,    81,    82,
      83,    84,     0,    85,     0,     0,     0,     0,   410,   389,
     411,     0,     0,     0,     0,   412,   413,   414,   415,   416,
     417,   418,   419,    76,    77,    78,    79,   142,    80,     0,
       0,    81,    82,    83,    84,   143,    85,    76,    77,    78,
      79,     0,    80,     0,     0,   382,    82,    83,    84,     0,
      85,    76,    77,    78,    79,     0,    80,     0,     0,   386,
      82,    83,    84,     0,    85,    76,    77,    78,    79,     0,
      80,     0,     0,   484,    82,    83,    84,     0,    85,    76,
      77,    78,    79,     0,    80,     0,     0,   490,    82,    83,
      84,     0,    85,    76,    77,    78,    79,     0,    80,     0,
       0,   446,    76,    77,    78,    79,    85,    80,     0,     0,
     504,     0,     0,     0,     0,    85,   108,   109,   110,   111,
     112,   113,   114,   115,   116,   117,   118
};

static const yytype_int16 yycheck[] =
{
      41,    69,   131,   205,   125,   165,   216,   332,   331,   432,
       4,    11,     5,     4,     4,   228,   176,     4,     4,     6,
       4,     8,     9,     6,    71,     8,     9,     4,    71,     4,
      14,    71,   109,   107,    75,    22,   359,    71,    25,    22,
      71,     7,    29,     4,    28,    71,    29,   105,   177,    16,
      17,    18,    19,    71,   120,   113,   109,    98,    71,   133,
      49,    50,    51,    52,   105,   267,   107,   269,   270,    71,
      71,   109,     0,    64,   112,     4,   123,    71,    64,    72,
     123,    71,   211,   123,    84,   126,   299,   110,    79,   123,
     131,   220,   133,    77,    71,    81,    71,   123,     4,   228,
      71,    27,   133,   313,    98,   123,   316,   120,   237,    96,
      30,   436,    99,    96,   107,    98,   105,   100,   120,   120,
     107,   544,   115,   116,   107,   450,     4,   105,    72,   454,
      97,   109,   115,   116,   175,    76,   177,    63,    71,    30,
     300,    82,    83,    10,    64,    12,    13,    14,    71,    75,
     360,    73,   281,   363,    21,    22,    23,     4,   103,   109,
      27,    28,    29,   107,   109,    32,   109,   110,   110,   298,
     299,   115,   116,    64,   109,   121,   217,   218,   219,   101,
     102,   103,   104,     4,   106,   100,   105,   109,   110,   111,
     112,   320,   114,    98,    61,   324,   237,    64,    65,    66,
       6,   105,     8,     9,    73,   109,   105,    74,   112,   113,
     109,    78,   119,    80,   343,   425,    22,   427,   259,   542,
     261,   110,   109,    29,    49,    50,    51,    52,    14,   389,
     109,   110,   111,   112,   101,   102,   103,   104,   105,   106,
      15,     4,   109,   117,    19,   112,   113,   114,   122,   378,
     379,   411,   113,     4,   122,   122,   122,   122,   299,    71,
     301,   109,   101,   102,   103,   104,   105,   106,   119,   429,
     109,   106,    98,   314,   113,   114,   317,   318,   120,    71,
     105,     4,   323,   123,   109,    10,   123,   123,    14,   121,
      96,   121,    98,   121,   100,   120,     4,   338,   458,     4,
     460,   107,   343,    72,     4,   105,   347,   105,   109,   115,
     116,   110,   433,   434,     4,   101,   102,   103,   104,   448,
     106,     4,     4,   109,   110,   111,   112,   122,   114,    54,
      55,    56,    57,    58,    59,   101,   102,   103,   104,   541,
     106,     4,     1,   109,    20,     4,    71,   476,   114,    71,
      71,    10,   481,    12,    13,    14,   117,   119,   122,   105,
      10,    10,    21,    22,    23,   122,   105,   105,    27,    28,
      29,   105,    20,    32,   105,   101,   102,   103,   104,   420,
     106,   122,   122,   109,   110,   111,   112,   428,   114,   121,
     101,   102,   103,   104,   105,   106,   437,    10,   109,    10,
     441,   112,    61,   114,   533,    64,    65,    66,   449,   477,
      14,    97,   453,   122,    71,    74,   457,    21,   459,    78,
     119,    80,   463,   119,   119,    20,    20,   101,   102,   103,
     104,   119,   106,   474,   475,   109,   110,   111,   112,    98,
     114,   109,   101,   102,   103,   104,   105,   106,     4,     4,
     109,    20,   121,   112,   113,   114,   121,    61,    62,   123,
     121,     4,   122,   122,   101,   102,   103,   104,    20,   106,
     511,   122,   513,    20,   121,   121,   517,   114,     4,   520,
       4,   522,    33,    34,    35,    36,    37,    38,    39,    40,
     109,    42,    43,    44,    45,    46,   123,   101,   102,   103,
     104,   105,   106,     4,     4,   109,   110,   111,   112,   113,
     114,    41,     4,     4,   211,    12,    64,    47,    48,   343,
     124,   125,   126,    53,    54,    55,    56,    57,    58,    59,
     129,   140,   202,   327,   201,   338,   181,    67,    68,    69,
      70,   101,   102,   103,   104,   105,   106,   448,   510,   109,
     110,   111,   112,   113,   114,   479,   379,   324,   262,   262,
     120,   177,   237,   298,   126,   175,   117,   339,   119,   120,
     101,   102,   103,   104,   105,   106,    -1,    -1,   109,   110,
     111,   112,    -1,   114,    -1,    -1,    -1,    -1,   118,   120,
     120,    -1,    -1,    -1,    -1,   125,   126,   127,   128,   129,
     130,   131,   132,   101,   102,   103,   104,   105,   106,    -1,
      -1,   109,   110,   111,   112,   113,   114,   101,   102,   103,
     104,    -1,   106,    -1,    -1,   109,   110,   111,   112,    -1,
     114,   101,   102,   103,   104,    -1,   106,    -1,    -1,   109,
     110,   111,   112,    -1,   114,   101,   102,   103,   104,    -1,
     106,    -1,    -1,   109,   110,   111,   112,    -1,   114,   101,
     102,   103,   104,    -1,   106,    -1,    -1,   109,   110,   111,
     112,    -1,   114,   101,   102,   103,   104,    -1,   106,    -1,
      -1,   109,   101,   102,   103,   104,   114,   106,    -1,    -1,
     109,    -1,    -1,    -1,    -1,   114,    85,    86,    87,    88,
      89,    90,    91,    92,    93,    94,    95
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     4,     6,     8,     9,    22,    25,    29,    96,    99,
     107,   135,   136,   137,   138,   140,   141,   152,   155,   157,
       7,   139,   109,   109,   110,   120,   156,   158,   142,   109,
     153,     4,     0,   137,     4,   110,     4,    71,    71,    71,
     245,   246,     4,   105,   109,   112,   113,   240,   241,    49,
      50,    51,    52,   105,   211,   212,     4,    29,    98,   107,
     115,   116,   138,   143,   146,   147,   154,   155,   200,   201,
     202,   109,   109,   110,   121,    73,   101,   102,   103,   104,
     106,   109,   110,   111,   112,   114,   236,   244,   249,   251,
     252,   253,   159,   105,   144,     4,   147,   100,    14,    28,
      77,   148,   149,   202,   244,    73,    71,   133,    85,    86,
      87,    88,    89,    90,    91,    92,    93,    94,    95,   166,
     167,   168,   176,   177,   178,   119,   110,   244,   109,   150,
       4,   113,   244,   250,   251,   122,   122,   122,     4,    71,
     165,   253,   105,   113,   242,   243,   244,    71,   176,   120,
     151,   236,   237,   238,   239,   243,   251,   105,   109,    49,
      50,    51,    52,   105,   109,   120,   169,   170,   109,   160,
     178,   119,   106,    98,   247,   248,   120,    71,   123,   123,
     245,    71,   123,   123,     4,   161,   109,   112,   145,   121,
     249,   245,   239,   121,   170,     5,   107,   115,   116,   162,
     171,   197,   198,   199,   121,   163,     4,     4,    72,   199,
       1,   200,   203,   164,   211,     4,    10,    12,    13,    14,
      21,    22,    23,    27,    28,    29,    32,    61,    64,    65,
      66,    74,    78,    80,   105,   109,   112,   113,   122,   143,
     172,   187,   189,   193,   195,   207,   213,   217,   219,   221,
     222,   223,   231,   232,   233,   236,   105,   109,   242,    14,
     244,    14,   244,   244,   236,   105,   105,   208,   109,   209,
     210,   103,   109,   254,   223,   236,   218,     4,     4,     4,
     237,   214,   122,     4,   224,    33,    34,    35,    36,    37,
      38,    39,    40,    42,    43,    44,    45,    46,   117,   119,
     120,   220,   185,    20,   244,    10,    54,    55,    56,    57,
      58,    59,    71,   234,   235,   244,   234,   235,    71,   211,
      71,   211,   211,   119,   122,   173,   188,   190,   109,   229,
     230,   236,   194,   122,   109,   236,   241,    14,    21,    61,
      62,   109,   112,   113,   124,   125,   126,   215,   223,   236,
     244,   245,   244,    16,    17,    18,    19,    97,   186,   105,
      10,   242,   244,    10,   242,   244,   244,   105,   204,   205,
     236,   105,   105,   244,   230,   180,   191,   191,    20,    71,
     123,   185,   109,   196,   226,   244,   109,   225,   226,   120,
     212,   244,   254,   105,   151,   244,    41,    47,    48,    53,
      54,    55,    56,    57,    58,    59,    67,    68,    69,    70,
     118,   120,   125,   126,   127,   128,   129,   130,   131,   132,
     216,   121,   122,   185,   242,    10,   242,    10,    71,   120,
      97,   206,    71,   119,   119,   123,    11,    84,   175,   181,
       4,    64,    79,   192,    81,   236,   109,   229,   119,    20,
      71,   123,   227,    20,    71,   123,   245,    71,   120,    71,
     120,   245,   244,   119,   109,   242,   242,   244,   245,   205,
     253,   253,   226,   244,    76,    82,    83,   179,     4,   244,
       4,    20,   222,   244,   109,   226,    15,    19,   228,   244,
     109,   226,   121,   244,   245,   244,   245,   121,   244,   123,
     121,     4,   244,   244,   109,   236,   174,   202,   227,   236,
     122,    20,   122,    20,   121,   121,     4,    71,     4,     4,
      71,     4,    71,   182,     4,   225,   244,   109,   244,   244,
     244,   244,    27,    63,    75,   183,   123,   123,     4,     4,
       4,   184,   236,     4,   211,   185,   205
};

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK (1);						\
      goto yybackup;						\
    }								\
  else								\
    {								\
      yyerror (yyscanner, interp, YY_("syntax error: cannot back up")); \
      YYERROR;							\
    }								\
while (YYID (0))


#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#define YYRHSLOC(Rhs, K) ((Rhs)[K])
#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)				\
    do									\
      if (YYID (N))                                                    \
	{								\
	  (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;	\
	  (Current).first_column = YYRHSLOC (Rhs, 1).first_column;	\
	  (Current).last_line    = YYRHSLOC (Rhs, N).last_line;		\
	  (Current).last_column  = YYRHSLOC (Rhs, N).last_column;	\
	}								\
      else								\
	{								\
	  (Current).first_line   = (Current).last_line   =		\
	    YYRHSLOC (Rhs, 0).last_line;				\
	  (Current).first_column = (Current).last_column =		\
	    YYRHSLOC (Rhs, 0).last_column;				\
	}								\
    while (YYID (0))
#endif


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if YYLTYPE_IS_TRIVIAL
#  define YY_LOCATION_PRINT(File, Loc)			\
     fprintf (File, "%d.%d-%d.%d",			\
	      (Loc).first_line, (Loc).first_column,	\
	      (Loc).last_line,  (Loc).last_column)
# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (&yylval, YYLEX_PARAM)
#else
# define YYLEX yylex (&yylval, yyscanner, interp)
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (YYID (0))

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)			  \
do {									  \
  if (yydebug)								  \
    {									  \
      YYFPRINTF (stderr, "%s ", Title);					  \
      yy_symbol_print (stderr,						  \
		  Type, Value, yyscanner, interp); \
      YYFPRINTF (stderr, "\n");						  \
    }									  \
} while (YYID (0))


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, void *yyscanner, Parrot_Interp interp)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep, yyscanner, interp)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
    void *yyscanner;
    Parrot_Interp interp;
#endif
{
  if (!yyvaluep)
    return;
  YYUSE (yyscanner);
  YYUSE (interp);
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# else
  YYUSE (yyoutput);
# endif
  switch (yytype)
    {
      default:
	break;
    }
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, void *yyscanner, Parrot_Interp interp)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep, yyscanner, interp)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
    void *yyscanner;
    Parrot_Interp interp;
#endif
{
  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep, yyscanner, interp);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_stack_print (yytype_int16 *bottom, yytype_int16 *top)
#else
static void
yy_stack_print (bottom, top)
    yytype_int16 *bottom;
    yytype_int16 *top;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (; bottom <= top; ++bottom)
    YYFPRINTF (stderr, " %d", *bottom);
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (YYID (0))


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_reduce_print (YYSTYPE *yyvsp, int yyrule, void *yyscanner, Parrot_Interp interp)
#else
static void
yy_reduce_print (yyvsp, yyrule, yyscanner, interp)
    YYSTYPE *yyvsp;
    int yyrule;
    void *yyscanner;
    Parrot_Interp interp;
#endif
{
  int yynrhs = yyr2[yyrule];
  int yyi;
  unsigned long int yylno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
	     yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      fprintf (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr, yyrhs[yyprhs[yyrule] + yyi],
		       &(yyvsp[(yyi + 1) - (yynrhs)])
		       		       , yyscanner, interp);
      fprintf (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (yyvsp, Rule, yyscanner, interp); \
} while (YYID (0))

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static YYSIZE_T
yystrlen (const char *yystr)
#else
static YYSIZE_T
yystrlen (yystr)
    const char *yystr;
#endif
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static char *
yystpcpy (char *yydest, const char *yysrc)
#else
static char *
yystpcpy (yydest, yysrc)
    char *yydest;
    const char *yysrc;
#endif
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
	switch (*++yyp)
	  {
	  case '\'':
	  case ',':
	    goto do_not_strip_quotes;

	  case '\\':
	    if (*++yyp != '\\')
	      goto do_not_strip_quotes;
	    /* Fall through.  */
	  default:
	    if (yyres)
	      yyres[yyn] = *yyp;
	    yyn++;
	    break;

	  case '"':
	    if (yyres)
	      yyres[yyn] = '\0';
	    return yyn;
	  }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into YYRESULT an error message about the unexpected token
   YYCHAR while in state YYSTATE.  Return the number of bytes copied,
   including the terminating null byte.  If YYRESULT is null, do not
   copy anything; just return the number of bytes that would be
   copied.  As a special case, return 0 if an ordinary "syntax error"
   message will do.  Return YYSIZE_MAXIMUM if overflow occurs during
   size calculation.  */
static YYSIZE_T
yysyntax_error (char *yyresult, int yystate, int yychar)
{
  int yyn = yypact[yystate];

  if (! (YYPACT_NINF < yyn && yyn <= YYLAST))
    return 0;
  else
    {
      int yytype = YYTRANSLATE (yychar);
      YYSIZE_T yysize0 = yytnamerr (0, yytname[yytype]);
      YYSIZE_T yysize = yysize0;
      YYSIZE_T yysize1;
      int yysize_overflow = 0;
      enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
      char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
      int yyx;

# if 0
      /* This is so xgettext sees the translatable formats that are
	 constructed on the fly.  */
      YY_("syntax error, unexpected %s");
      YY_("syntax error, unexpected %s, expecting %s");
      YY_("syntax error, unexpected %s, expecting %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s");
# endif
      char *yyfmt;
      char const *yyf;
      static char const yyunexpected[] = "syntax error, unexpected %s";
      static char const yyexpecting[] = ", expecting %s";
      static char const yyor[] = " or %s";
      char yyformat[sizeof yyunexpected
		    + sizeof yyexpecting - 1
		    + ((YYERROR_VERBOSE_ARGS_MAXIMUM - 2)
		       * (sizeof yyor - 1))];
      char const *yyprefix = yyexpecting;

      /* Start YYX at -YYN if negative to avoid negative indexes in
	 YYCHECK.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;

      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yycount = 1;

      yyarg[0] = yytname[yytype];
      yyfmt = yystpcpy (yyformat, yyunexpected);

      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	  {
	    if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
	      {
		yycount = 1;
		yysize = yysize0;
		yyformat[sizeof yyunexpected - 1] = '\0';
		break;
	      }
	    yyarg[yycount++] = yytname[yyx];
	    yysize1 = yysize + yytnamerr (0, yytname[yyx]);
	    yysize_overflow |= (yysize1 < yysize);
	    yysize = yysize1;
	    yyfmt = yystpcpy (yyfmt, yyprefix);
	    yyprefix = yyor;
	  }

      yyf = YY_(yyformat);
      yysize1 = yysize + yystrlen (yyf);
      yysize_overflow |= (yysize1 < yysize);
      yysize = yysize1;

      if (yysize_overflow)
	return YYSIZE_MAXIMUM;

      if (yyresult)
	{
	  /* Avoid sprintf, as that infringes on the user's name space.
	     Don't have undefined behavior even if the translation
	     produced a string with the wrong number of "%s"s.  */
	  char *yyp = yyresult;
	  int yyi = 0;
	  while ((*yyp = *yyf) != '\0')
	    {
	      if (*yyp == '%' && yyf[1] == 's' && yyi < yycount)
		{
		  yyp += yytnamerr (yyp, yyarg[yyi++]);
		  yyf += 2;
		}
	      else
		{
		  yyp++;
		  yyf++;
		}
	    }
	}
      return yysize;
    }
}
#endif /* YYERROR_VERBOSE */


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep, void *yyscanner, Parrot_Interp interp)
#else
static void
yydestruct (yymsg, yytype, yyvaluep, yyscanner, interp)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
    void *yyscanner;
    Parrot_Interp interp;
#endif
{
  YYUSE (yyvaluep);
  YYUSE (yyscanner);
  YYUSE (interp);

  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  switch (yytype)
    {

      default:
	break;
    }
}


/* Prevent warnings from -Wmissing-prototypes.  */

#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void *yyscanner, Parrot_Interp interp);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */






/*----------.
| yyparse.  |
`----------*/

#ifdef YYPARSE_PARAM
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void *YYPARSE_PARAM)
#else
int
yyparse (YYPARSE_PARAM)
    void *YYPARSE_PARAM;
#endif
#else /* ! YYPARSE_PARAM */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void *yyscanner, Parrot_Interp interp)
#else
int
yyparse (yyscanner, interp)
    void *yyscanner;
    Parrot_Interp interp;
#endif
#endif
{
  /* The look-ahead symbol.  */
int yychar;

/* The semantic value of the look-ahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;

  int yystate;
  int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Look-ahead token as an internal (translated) token number.  */
  int yytoken = 0;
#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack.  */
  yytype_int16 yyssa[YYINITDEPTH];
  yytype_int16 *yyss = yyssa;
  yytype_int16 *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  YYSTYPE *yyvsp;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;


  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss;
  yyvsp = yyvs;

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack.  Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	yytype_int16 *yyss1 = yyss;


	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow (YY_("memory exhausted"),
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),

		    &yystacksize);

	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	yytype_int16 *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyexhaustedlab;
	YYSTACK_RELOCATE (yyss);
	YYSTACK_RELOCATE (yyvs);

#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;


      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     look-ahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to look-ahead token.  */
  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a look-ahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid look-ahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the look-ahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  yystate = yyn;
  *++yyvsp = yylval;

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 2:
#line 608 "compilers/imcc/imcc.y"
    { if (yynerrs) YYABORT; (yyval.i) = 0; ;}
    break;

  case 5:
#line 617 "compilers/imcc/imcc.y"
    { (yyval.i) = (yyvsp[(1) - (1)].i); ;}
    break;

  case 6:
#line 618 "compilers/imcc/imcc.y"
    { (yyval.i) = (yyvsp[(1) - (1)].i); ;}
    break;

  case 7:
#line 619 "compilers/imcc/imcc.y"
    { (yyval.i) = (yyvsp[(1) - (1)].i);
                     imc_close_unit(interp, IMCC_INFO(interp)->cur_unit);
                     IMCC_INFO(interp)->cur_unit = 0; ;}
    break;

  case 8:
#line 622 "compilers/imcc/imcc.y"
    { (yyval.i) = (yyvsp[(1) - (1)].i);
                     imc_close_unit(interp, IMCC_INFO(interp)->cur_unit);
                     IMCC_INFO(interp)->cur_unit = 0; ;}
    break;

  case 9:
#line 625 "compilers/imcc/imcc.y"
    { (yyval.i) = 0; ;}
    break;

  case 10:
#line 626 "compilers/imcc/imcc.y"
    { (yyval.i) = 0; ;}
    break;

  case 11:
#line 627 "compilers/imcc/imcc.y"
    { (yyval.i) = 0; ;}
    break;

  case 12:
#line 630 "compilers/imcc/imcc.y"
    { (yyval.i) = 0; ;}
    break;

  case 13:
#line 631 "compilers/imcc/imcc.y"
    { (yyval.i) = 0; ;}
    break;

  case 14:
#line 632 "compilers/imcc/imcc.y"
    { (yyval.i) = 0; do_loadlib(interp, (yyvsp[(2) - (3)].s)); ;}
    break;

  case 15:
#line 636 "compilers/imcc/imcc.y"
    { if ((yyvsp[(2) - (2)].s))
                          IMCC_INFO(interp)->state->pragmas |= PR_N_OPERATORS;
                      else
                          IMCC_INFO(interp)->state->pragmas &= ~PR_N_OPERATORS;
                    ;}
    break;

  case 16:
#line 644 "compilers/imcc/imcc.y"
    {
            STRING *hll_name = string_unescape_cstring(interp, (yyvsp[(2) - (4)].s) + 1, '"', NULL);
            STRING *hll_lib  = string_unescape_cstring(interp, (yyvsp[(4) - (4)].s) + 1, '"', NULL);
            PMC    *ignored;
            CONTEXT(((Interp*)interp)->ctx)->current_HLL =
                Parrot_register_HLL(interp, hll_name);
            ignored = Parrot_load_lib(interp, hll_lib, NULL);
            UNUSED(ignored);
            Parrot_register_HLL_lib(interp, hll_lib);
            IMCC_INFO(interp)->cur_namespace = NULL;
            (yyval.t) = 0;
         ;}
    break;

  case 17:
#line 657 "compilers/imcc/imcc.y"
    {
             Parrot_register_HLL_type(interp,
                CONTEXT(((Interp*)interp)->ctx)->current_HLL, atoi((yyvsp[(2) - (4)].s)), atoi((yyvsp[(4) - (4)].s)));
             (yyval.t) = 0;
         ;}
    break;

  case 18:
#line 663 "compilers/imcc/imcc.y"
    {
            int built_in_type = 0;
            int language_type = 0;

            STRING *built_in_name = string_unescape_cstring(interp, (yyvsp[(2) - (4)].s) + 1, '"', NULL);
            STRING *language_name = string_unescape_cstring(interp, (yyvsp[(4) - (4)].s) + 1, '"', NULL);
            built_in_type = pmc_type(interp, built_in_name);
            language_type = pmc_type(interp, language_name);

            /*
            fprintf(stderr, "built in type is: %d, language type is: %d\n", built_in_type, language_type);
            */
            Parrot_register_HLL_type(interp,
                 CONTEXT(((Interp *)interp)->ctx)->current_HLL, built_in_type, language_type);
            (yyval.t) = 0;
         ;}
    break;

  case 19:
#line 682 "compilers/imcc/imcc.y"
    { is_def=1; ;}
    break;

  case 20:
#line 683 "compilers/imcc/imcc.y"
    { mk_const_ident(interp, (yyvsp[(4) - (6)].s), (yyvsp[(3) - (6)].t), (yyvsp[(6) - (6)].sr), 1); is_def=0; ;}
    break;

  case 21:
#line 687 "compilers/imcc/imcc.y"
    { is_def=1; ;}
    break;

  case 22:
#line 688 "compilers/imcc/imcc.y"
    { (yyval.i) = mk_pmc_const(interp, IMCC_INFO(interp)->cur_unit, (yyvsp[(3) - (6)].s), (yyvsp[(4) - (6)].sr), (yyvsp[(6) - (6)].s)); is_def=0; ;}
    break;

  case 27:
#line 701 "compilers/imcc/imcc.y"
    { (yyval.i) = 0;  ;}
    break;

  case 28:
#line 702 "compilers/imcc/imcc.y"
    { (yyval.i) = 0;  ;}
    break;

  case 29:
#line 703 "compilers/imcc/imcc.y"
    { (yyval.i) = 0;  ;}
    break;

  case 30:
#line 704 "compilers/imcc/imcc.y"
    { (yyval.i) = 0;  ;}
    break;

  case 31:
#line 705 "compilers/imcc/imcc.y"
    { (yyval.i) = (yyvsp[(1) - (1)].i); ;}
    break;

  case 34:
#line 710 "compilers/imcc/imcc.y"
    { clear_state(interp); ;}
    break;

  case 35:
#line 712 "compilers/imcc/imcc.y"
    { (yyval.i) = INS(interp, IMCC_INFO(interp)->cur_unit,
                              (yyvsp[(2) - (3)].s), 0, IMCC_INFO(interp)->regs,
                              IMCC_INFO(interp)->nargs, IMCC_INFO(interp) -> keyvec, 1);
                     free((yyvsp[(2) - (3)].s)); ;}
    break;

  case 36:
#line 717 "compilers/imcc/imcc.y"
    {
                    imc_close_unit(interp, IMCC_INFO(interp)->cur_unit);
                    IMCC_INFO(interp)->cur_unit = imc_open_unit(interp, IMC_PASM);
                    ;}
    break;

  case 37:
#line 722 "compilers/imcc/imcc.y"
    {
                     (yyval.i) = iSUBROUTINE(interp, IMCC_INFO(interp)->cur_unit,
                                mk_sub_label(interp, (yyvsp[(4) - (4)].s)));
                     IMCC_INFO(interp)->cur_call->pcc_sub->pragma = (yyvsp[(3) - (4)].t);
                   ;}
    break;

  case 38:
#line 728 "compilers/imcc/imcc.y"
    {  (yyval.i) =MK_I(interp, IMCC_INFO(interp)->cur_unit, "null", 1, (yyvsp[(2) - (2)].sr)); ;}
    break;

  case 39:
#line 730 "compilers/imcc/imcc.y"
    {
                       SymReg *r = mk_pasm_reg(interp, (yyvsp[(4) - (4)].s));
                       set_lexical(interp, r, (yyvsp[(2) - (4)].s)); (yyval.i) = 0;
                   ;}
    break;

  case 40:
#line 734 "compilers/imcc/imcc.y"
    { (yyval.i) = 0;;}
    break;

  case 42:
#line 742 "compilers/imcc/imcc.y"
    { IMCC_INFO(interp)->cur_unit = imc_open_unit(interp, IMC_PASM); ;}
    break;

  case 43:
#line 744 "compilers/imcc/imcc.y"
    { /*
                      if (optimizer_level & OPT_PASM)
                         imc_compile_unit(interp, IMCC_INFO(interp)->cur_unit);
                         emit_flush(interp);
                     */
                     (yyval.i)=0; ;}
    break;

  case 46:
#line 759 "compilers/imcc/imcc.y"
    {
                    int re_open = 0;
                    (yyval.i) = 0;
                    if (IMCC_INFO(interp)->state->pasm_file && IMCC_INFO(interp)->cur_namespace) {
                        imc_close_unit(interp, IMCC_INFO(interp)->cur_unit);
                        re_open = 1;
                    }
                    IMCC_INFO(interp)->cur_namespace = (yyvsp[(2) - (3)].sr);
                    if (re_open)
                        IMCC_INFO(interp)->cur_unit = imc_open_unit(interp, IMC_PASM);
                ;}
    break;

  case 47:
#line 773 "compilers/imcc/imcc.y"
    { (yyval.sr) = (yyvsp[(2) - (3)].sr); ;}
    break;

  case 48:
#line 774 "compilers/imcc/imcc.y"
    { (yyval.sr) = NULL; ;}
    break;

  case 49:
#line 779 "compilers/imcc/imcc.y"
    {
           IMCC_INFO(interp)->cur_unit = imc_open_unit(interp, IMC_PCCSUB);
        ;}
    break;

  case 50:
#line 783 "compilers/imcc/imcc.y"
    {
          iSUBROUTINE(interp, IMCC_INFO(interp)->cur_unit, (yyvsp[(3) - (3)].sr));
        ;}
    break;

  case 51:
#line 786 "compilers/imcc/imcc.y"
    { IMCC_INFO(interp)->cur_call->pcc_sub->pragma = (yyvsp[(5) - (6)].t); ;}
    break;

  case 52:
#line 788 "compilers/imcc/imcc.y"
    { (yyval.i) = 0; IMCC_INFO(interp)->cur_call = NULL; ;}
    break;

  case 53:
#line 792 "compilers/imcc/imcc.y"
    { (yyval.sr) = 0; ;}
    break;

  case 54:
#line 793 "compilers/imcc/imcc.y"
    { (yyval.sr) = 0; ;}
    break;

  case 55:
#line 794 "compilers/imcc/imcc.y"
    {
       if (IMCC_INFO(interp)->adv_named_id) {
             add_pcc_named_param(interp,IMCC_INFO(interp)->cur_call,
                                 IMCC_INFO(interp)->adv_named_id,(yyvsp[(2) - (3)].sr));
             IMCC_INFO(interp)->adv_named_id = NULL;
         }
         else add_pcc_param(IMCC_INFO(interp)->cur_call, (yyvsp[(2) - (3)].sr));
   ;}
    break;

  case 56:
#line 805 "compilers/imcc/imcc.y"
    { is_def=1; ;}
    break;

  case 57:
#line 805 "compilers/imcc/imcc.y"
    { (yyval.sr) = (yyvsp[(3) - (3)].sr); is_def=0; ;}
    break;

  case 58:
#line 809 "compilers/imcc/imcc.y"
    { if ((yyvsp[(3) - (3)].t) & VT_UNIQUE_REG)
                                             (yyval.sr) = mk_ident_ur(interp, (yyvsp[(2) - (3)].s), (yyvsp[(1) - (3)].t));
                                         else
                                             (yyval.sr) = mk_ident(interp, (yyvsp[(2) - (3)].s), (yyvsp[(1) - (3)].t));
                                         (yyval.sr)->type |= (yyvsp[(3) - (3)].t); ;}
    break;

  case 59:
#line 814 "compilers/imcc/imcc.y"
    {
                                         if ((yyvsp[(5) - (5)].t) & VT_UNIQUE_REG)
                                             (yyval.sr) = mk_ident_ur(interp, (yyvsp[(4) - (5)].s), (yyvsp[(1) - (5)].t));
                                         else
                                             (yyval.sr) = mk_ident(interp, (yyvsp[(4) - (5)].s), (yyvsp[(1) - (5)].t));
                                         (yyval.sr)->type |= (yyvsp[(5) - (5)].t);
                                         adv_named_set(interp,(yyvsp[(2) - (5)].s));;}
    break;

  case 60:
#line 824 "compilers/imcc/imcc.y"
    { (yyval.t) = 0;  ;}
    break;

  case 61:
#line 825 "compilers/imcc/imcc.y"
    { (yyval.t) = 0; fprintf(stderr, "IMCC Warning: optional comma is deprecated.\n"); ;}
    break;

  case 62:
#line 829 "compilers/imcc/imcc.y"
    { (yyval.t) = 0; ;}
    break;

  case 63:
#line 833 "compilers/imcc/imcc.y"
    { (yyval.t) = 0; IMCC_INFO(interp)->cur_unit->outer =
                     mk_sub_address_fromc(interp, (yyvsp[(3) - (4)].s)); ;}
    break;

  case 64:
#line 836 "compilers/imcc/imcc.y"
    { (yyval.t) = 0; IMCC_INFO(interp)->cur_unit->outer =
                     mk_const(interp, (yyvsp[(3) - (4)].s), 'S'); ;}
    break;

  case 65:
#line 841 "compilers/imcc/imcc.y"
    { (yyval.t) = 0;
                       IMCC_INFO(interp)->cur_unit->vtable_name = NULL;
                       IMCC_INFO(interp)->cur_unit->is_vtable_method = 1; ;}
    break;

  case 66:
#line 845 "compilers/imcc/imcc.y"
    { (yyval.t) = 0;
                       IMCC_INFO(interp)->cur_unit->vtable_name = strdup((yyvsp[(3) - (4)].s));
                       IMCC_INFO(interp)->cur_unit->is_vtable_method = 1; ;}
    break;

  case 67:
#line 851 "compilers/imcc/imcc.y"
    { add_pcc_multi(IMCC_INFO(interp)->cur_call, NULL); ;}
    break;

  case 68:
#line 852 "compilers/imcc/imcc.y"
    { (yyval.t) = 0; add_pcc_multi(IMCC_INFO(interp)->cur_call, (yyvsp[(3) - (3)].sr)); ;}
    break;

  case 69:
#line 853 "compilers/imcc/imcc.y"
    { (yyval.t) = 0;  add_pcc_multi(IMCC_INFO(interp)->cur_call, (yyvsp[(1) - (1)].sr));;}
    break;

  case 70:
#line 857 "compilers/imcc/imcc.y"
    { (yyval.sr) = mk_const(interp, str_dup("INTVAL"), 'S'); ;}
    break;

  case 71:
#line 858 "compilers/imcc/imcc.y"
    { (yyval.sr) = mk_const(interp, str_dup("FLOATVAL"), 'S'); ;}
    break;

  case 72:
#line 859 "compilers/imcc/imcc.y"
    { (yyval.sr) = mk_const(interp, str_dup("PMC"), 'S'); ;}
    break;

  case 73:
#line 860 "compilers/imcc/imcc.y"
    { (yyval.sr) = mk_const(interp, str_dup("STRING"), 'S'); ;}
    break;

  case 74:
#line 861 "compilers/imcc/imcc.y"
    {
                          SymReg *r;
                          if (strcmp((yyvsp[(1) - (1)].s), "_"))
                              r = mk_const(interp, (yyvsp[(1) - (1)].s), 'S');
                          else {
                              free((yyvsp[(1) - (1)].s)),
                              r = mk_const(interp, str_dup("PMC"), 'S');
                           }
                           (yyval.sr) = r;
                      ;}
    break;

  case 75:
#line 871 "compilers/imcc/imcc.y"
    {
                          SymReg *r;
                          if (strcmp((yyvsp[(1) - (1)].s), "_"))
                              r = mk_const(interp, (yyvsp[(1) - (1)].s), 'S');
                          else {
                              free((yyvsp[(1) - (1)].s)),
                              r = mk_const(interp, str_dup("PMC"), 'S');
                           }
                           (yyval.sr) = r;
                      ;}
    break;

  case 76:
#line 881 "compilers/imcc/imcc.y"
    { (yyval.sr) = (yyvsp[(2) - (3)].sr); ;}
    break;

  case 79:
#line 891 "compilers/imcc/imcc.y"
    {
            char name[128];
            SymReg *r, *r1;
            Instruction *i;

            sprintf(name, "%cpcc_sub_call_%d",
                    IMCC_INTERNAL_CHAR, IMCC_INFO(interp)->cnr++);
            (yyval.sr) = r = mk_pcc_sub(interp, str_dup(name), 0);
            /* this mid rule action has the semantic value of the
             * sub SymReg.
             * This is used below to append args & results
             */
            i = iLABEL(interp, IMCC_INFO(interp)->cur_unit, r);
            IMCC_INFO(interp)->cur_call = r;
            i->type = ITPCCSUB;
            /*
             * if we are inside a pcc_sub mark the sub as doing a
             * sub call; the sub is in r[0] of the first ins
             */
            r1 = IMCC_INFO(interp)->cur_unit->instructions->r[0];
            if (r1 && r1->pcc_sub)
                r1->pcc_sub->calls_a_sub |= 1;
         ;}
    break;

  case 80:
#line 919 "compilers/imcc/imcc.y"
    { (yyval.i) = 0; IMCC_INFO(interp)->cur_call = NULL; ;}
    break;

  case 81:
#line 923 "compilers/imcc/imcc.y"
    { (yyval.i) = NULL;  IMCC_INFO(interp)->cur_call->pcc_sub->label = 0; ;}
    break;

  case 82:
#line 924 "compilers/imcc/imcc.y"
    { (yyval.i) = NULL;  IMCC_INFO(interp)->cur_call->pcc_sub->label = 1; ;}
    break;

  case 83:
#line 928 "compilers/imcc/imcc.y"
    { (yyval.i) = NULL; ;}
    break;

  case 84:
#line 930 "compilers/imcc/imcc.y"
    { (yyval.i) = NULL;  IMCC_INFO(interp)->cur_call->pcc_sub->object = (yyvsp[(2) - (3)].sr); ;}
    break;

  case 85:
#line 934 "compilers/imcc/imcc.y"
    { (yyval.t) = 0; ;}
    break;

  case 87:
#line 939 "compilers/imcc/imcc.y"
    { (yyval.t) = (yyvsp[(1) - (1)].t); ;}
    break;

  case 88:
#line 940 "compilers/imcc/imcc.y"
    { (yyval.t) = (yyvsp[(1) - (3)].t) | (yyvsp[(3) - (3)].t); ;}
    break;

  case 89:
#line 944 "compilers/imcc/imcc.y"
    {  (yyval.t) = P_LOAD; ;}
    break;

  case 90:
#line 945 "compilers/imcc/imcc.y"
    {  (yyval.t) = P_INIT; ;}
    break;

  case 91:
#line 946 "compilers/imcc/imcc.y"
    {  (yyval.t) = P_MAIN; ;}
    break;

  case 92:
#line 947 "compilers/imcc/imcc.y"
    {  (yyval.t) = P_IMMEDIATE; ;}
    break;

  case 93:
#line 948 "compilers/imcc/imcc.y"
    {  (yyval.t) = P_POSTCOMP; ;}
    break;

  case 94:
#line 949 "compilers/imcc/imcc.y"
    {  (yyval.t) = P_ANON; ;}
    break;

  case 95:
#line 950 "compilers/imcc/imcc.y"
    {  (yyval.t) = P_METHOD; ;}
    break;

  case 96:
#line 951 "compilers/imcc/imcc.y"
    {  (yyval.t) = P_NEED_LEX; ;}
    break;

  case 100:
#line 959 "compilers/imcc/imcc.y"
    {
            add_pcc_sub(IMCC_INFO(interp)->cur_call, (yyvsp[(2) - (5)].sr));
            add_pcc_cc(IMCC_INFO(interp)->cur_call, (yyvsp[(4) - (5)].sr));
         ;}
    break;

  case 101:
#line 964 "compilers/imcc/imcc.y"
    {  add_pcc_sub(IMCC_INFO(interp)->cur_call, (yyvsp[(2) - (3)].sr)); ;}
    break;

  case 102:
#line 966 "compilers/imcc/imcc.y"
    {
            add_pcc_sub(IMCC_INFO(interp)->cur_call, (yyvsp[(2) - (3)].sr));
            IMCC_INFO(interp)->cur_call->pcc_sub->flags |= isNCI;
         ;}
    break;

  case 103:
#line 971 "compilers/imcc/imcc.y"
    {  add_pcc_sub(IMCC_INFO(interp)->cur_call, (yyvsp[(2) - (3)].sr)); ;}
    break;

  case 104:
#line 973 "compilers/imcc/imcc.y"
    {  add_pcc_sub(IMCC_INFO(interp)->cur_call, mk_const(interp, (yyvsp[(2) - (3)].s),'S')); ;}
    break;

  case 105:
#line 975 "compilers/imcc/imcc.y"
    {  add_pcc_sub(IMCC_INFO(interp)->cur_call, (yyvsp[(2) - (5)].sr));
            add_pcc_cc(IMCC_INFO(interp)->cur_call, (yyvsp[(4) - (5)].sr));
         ;}
    break;

  case 106:
#line 979 "compilers/imcc/imcc.y"
    {  add_pcc_sub(IMCC_INFO(interp)->cur_call, mk_const(interp, (yyvsp[(2) - (5)].s),'S'));
            add_pcc_cc(IMCC_INFO(interp)->cur_call, (yyvsp[(4) - (5)].sr));
         ;}
    break;

  case 107:
#line 986 "compilers/imcc/imcc.y"
    {  (yyval.sr) = 0; ;}
    break;

  case 108:
#line 987 "compilers/imcc/imcc.y"
    {  add_pcc_arg(IMCC_INFO(interp)->cur_call, (yyvsp[(2) - (3)].sr)); ;}
    break;

  case 109:
#line 991 "compilers/imcc/imcc.y"
    {  (yyval.sr) = (yyvsp[(2) - (2)].sr); ;}
    break;

  case 110:
#line 996 "compilers/imcc/imcc.y"
    {  (yyval.sr) = 0; ;}
    break;

  case 111:
#line 997 "compilers/imcc/imcc.y"
    {  if ((yyvsp[(2) - (3)].sr)) add_pcc_result(IMCC_INFO(interp)->cur_call, (yyvsp[(2) - (3)].sr)); ;}
    break;

  case 112:
#line 1001 "compilers/imcc/imcc.y"
    {  (yyval.sr) = (yyvsp[(2) - (3)].sr); (yyval.sr)->type |= (yyvsp[(3) - (3)].t); ;}
    break;

  case 113:
#line 1002 "compilers/imcc/imcc.y"
    { is_def=1; ;}
    break;

  case 114:
#line 1003 "compilers/imcc/imcc.y"
    {
         IdList* l = (yyvsp[(4) - (4)].idlist);
         SymReg *ignored;
         if (l->unique_reg)
                 ignored = mk_ident_ur(interp, l->id, (yyvsp[(3) - (4)].t));
             else
                 ignored = mk_ident(interp, l->id, (yyvsp[(3) - (4)].t));
         UNUSED(ignored);
         is_def=0;
         (yyval.sr)=0;
     ;}
    break;

  case 115:
#line 1017 "compilers/imcc/imcc.y"
    {  (yyval.t) = 0; ;}
    break;

  case 116:
#line 1018 "compilers/imcc/imcc.y"
    {  (yyval.t) = (yyvsp[(1) - (2)].t) | (yyvsp[(2) - (2)].t); ;}
    break;

  case 117:
#line 1022 "compilers/imcc/imcc.y"
    {  (yyval.t) = VT_FLAT;   ;}
    break;

  case 118:
#line 1023 "compilers/imcc/imcc.y"
    {  (yyval.t) = VT_OPTIONAL; ;}
    break;

  case 119:
#line 1024 "compilers/imcc/imcc.y"
    {  (yyval.t) = VT_OPT_FLAG; ;}
    break;

  case 120:
#line 1025 "compilers/imcc/imcc.y"
    {  (yyval.t) = VT_NAMED; ;}
    break;

  case 121:
#line 1026 "compilers/imcc/imcc.y"
    {  adv_named_set(interp,(yyvsp[(3) - (4)].s)); (yyval.t) = 0; ;}
    break;

  case 122:
#line 1027 "compilers/imcc/imcc.y"
    {  (yyval.t) = VT_UNIQUE_REG; ;}
    break;

  case 123:
#line 1033 "compilers/imcc/imcc.y"
    { begin_return_or_yield(interp, 0); ;}
    break;

  case 124:
#line 1036 "compilers/imcc/imcc.y"
    { (yyval.i) = 0;   IMCC_INFO(interp)->asm_state = AsmDefault; ;}
    break;

  case 125:
#line 1037 "compilers/imcc/imcc.y"
    {  IMCC_INFO(interp)->asm_state = AsmDefault; (yyval.i) = 0;  ;}
    break;

  case 126:
#line 1043 "compilers/imcc/imcc.y"
    { begin_return_or_yield(interp, 1); ;}
    break;

  case 127:
#line 1046 "compilers/imcc/imcc.y"
    { (yyval.i) = 0; IMCC_INFO(interp)->asm_state = AsmDefault; ;}
    break;

  case 128:
#line 1050 "compilers/imcc/imcc.y"
    {  (yyval.sr) = 0; ;}
    break;

  case 129:
#line 1051 "compilers/imcc/imcc.y"
    {
       if ((yyvsp[(1) - (2)].sr)) add_pcc_return(IMCC_INFO(interp)->sr_return, (yyvsp[(1) - (2)].sr));
   ;}
    break;

  case 130:
#line 1054 "compilers/imcc/imcc.y"
    {
       if ((yyvsp[(2) - (3)].sr)) add_pcc_return(IMCC_INFO(interp)->sr_return, (yyvsp[(2) - (3)].sr));
   ;}
    break;

  case 131:
#line 1060 "compilers/imcc/imcc.y"
    {  (yyval.sr) = (yyvsp[(2) - (3)].sr); (yyval.sr)->type |= (yyvsp[(3) - (3)].t); ;}
    break;

  case 132:
#line 1065 "compilers/imcc/imcc.y"
    {
            if (IMCC_INFO(interp)->asm_state == AsmDefault)
                begin_return_or_yield(interp, (yyvsp[(1) - (2)].t));
        ;}
    break;

  case 133:
#line 1070 "compilers/imcc/imcc.y"
    {  IMCC_INFO(interp)->asm_state = AsmDefault; (yyval.t) = 0;  ;}
    break;

  case 134:
#line 1074 "compilers/imcc/imcc.y"
    { (yyval.t) = 0; ;}
    break;

  case 135:
#line 1075 "compilers/imcc/imcc.y"
    { (yyval.t) = 1; ;}
    break;

  case 136:
#line 1079 "compilers/imcc/imcc.y"
    { (yyval.i) = 0; ;}
    break;

  case 137:
#line 1080 "compilers/imcc/imcc.y"
    {
      if (IMCC_INFO(interp)->adv_named_id) {
          add_pcc_named_return(interp,IMCC_INFO(interp)->sr_return,
                               IMCC_INFO(interp)->adv_named_id, (yyvsp[(1) - (1)].sr));
          IMCC_INFO(interp)->adv_named_id = NULL;
      }
      else add_pcc_return(IMCC_INFO(interp)->sr_return, (yyvsp[(1) - (1)].sr)); ;}
    break;

  case 138:
#line 1087 "compilers/imcc/imcc.y"
    {
      add_pcc_named_return(interp,IMCC_INFO(interp)->sr_return,(yyvsp[(1) - (3)].s),(yyvsp[(3) - (3)].sr));;}
    break;

  case 139:
#line 1089 "compilers/imcc/imcc.y"
    {
      if (IMCC_INFO(interp)->adv_named_id) {
          add_pcc_named_return(interp,IMCC_INFO(interp)->sr_return,
                               IMCC_INFO(interp)->adv_named_id,(yyvsp[(3) - (3)].sr));
           IMCC_INFO(interp)->adv_named_id = NULL;
      }
      else add_pcc_return(IMCC_INFO(interp)->sr_return, (yyvsp[(3) - (3)].sr));    ;}
    break;

  case 140:
#line 1096 "compilers/imcc/imcc.y"
    {
      add_pcc_named_return(interp,IMCC_INFO(interp)->sr_return,(yyvsp[(3) - (5)].s),(yyvsp[(5) - (5)].sr));;}
    break;

  case 143:
#line 1115 "compilers/imcc/imcc.y"
    { clear_state(interp); ;}
    break;

  case 144:
#line 1120 "compilers/imcc/imcc.y"
    {  (yyval.i) = (yyvsp[(2) - (2)].i); ;}
    break;

  case 145:
#line 1121 "compilers/imcc/imcc.y"
    {  (yyval.i) = 0; ;}
    break;

  case 146:
#line 1122 "compilers/imcc/imcc.y"
    {  (yyval.i) = 0; ;}
    break;

  case 147:
#line 1123 "compilers/imcc/imcc.y"
    {  (yyval.i) = 0; ;}
    break;

  case 148:
#line 1127 "compilers/imcc/imcc.y"
    {  (yyval.i) = NULL; ;}
    break;

  case 152:
#line 1137 "compilers/imcc/imcc.y"
    {
         (yyval.i) = iLABEL(interp, IMCC_INFO(interp)->cur_unit, mk_local_label(interp, (yyvsp[(1) - (1)].s)));
                   ;}
    break;

  case 153:
#line 1146 "compilers/imcc/imcc.y"
    { (yyval.i) = (yyvsp[(2) - (3)].i); ;}
    break;

  case 154:
#line 1148 "compilers/imcc/imcc.y"
    { if (yynerrs >= PARROT_MAX_RECOVER_ERRORS) {
                           IMCC_warning(interp, "Too many errors. Correct some first.\n");
                           YYABORT;
                       }
                       yyerrok; ;}
    break;

  case 155:
#line 1157 "compilers/imcc/imcc.y"
    {
         IdList* l = (yyvsp[(1) - (1)].idlist);
         l->next = NULL;
         (yyval.idlist) = l;
     ;}
    break;

  case 156:
#line 1164 "compilers/imcc/imcc.y"
    {
         IdList* l = (yyvsp[(3) - (3)].idlist);
         l->next = (yyvsp[(1) - (3)].idlist);
         (yyval.idlist) = l;
     ;}
    break;

  case 157:
#line 1173 "compilers/imcc/imcc.y"
    {
         IdList* l = (IdList*)malloc(sizeof (IdList));
         l->id = (yyvsp[(1) - (2)].s);
         l->unique_reg = (yyvsp[(2) - (2)].t);
         (yyval.idlist) = l;
     ;}
    break;

  case 158:
#line 1182 "compilers/imcc/imcc.y"
    { (yyval.t) = 0; ;}
    break;

  case 159:
#line 1183 "compilers/imcc/imcc.y"
    { (yyval.t) = 1; ;}
    break;

  case 162:
#line 1190 "compilers/imcc/imcc.y"
    { push_namespace((yyvsp[(2) - (2)].s)); ;}
    break;

  case 163:
#line 1191 "compilers/imcc/imcc.y"
    { pop_namespace((yyvsp[(2) - (2)].s)); ;}
    break;

  case 164:
#line 1192 "compilers/imcc/imcc.y"
    { is_def=1; ;}
    break;

  case 165:
#line 1193 "compilers/imcc/imcc.y"
    {
         IdList* l = (yyvsp[(4) - (4)].idlist);
         while (l) {
             IdList* l1;
             SymReg *ignored;
             if (l->unique_reg)
                 ignored = mk_ident_ur(interp, l->id, (yyvsp[(3) - (4)].t));
             else
                 ignored = mk_ident(interp, l->id, (yyvsp[(3) - (4)].t));
             UNUSED(ignored);
             l1 = l;
             l = l->next;
             free(l1);
         }
         is_def=0; (yyval.i)=0;
     ;}
    break;

  case 166:
#line 1210 "compilers/imcc/imcc.y"
    {
                       set_lexical(interp, (yyvsp[(4) - (4)].sr), (yyvsp[(2) - (4)].s)); (yyval.i) = 0;
                    ;}
    break;

  case 167:
#line 1213 "compilers/imcc/imcc.y"
    { is_def=1; ;}
    break;

  case 168:
#line 1214 "compilers/imcc/imcc.y"
    { mk_const_ident(interp, (yyvsp[(4) - (6)].s), (yyvsp[(3) - (6)].t), (yyvsp[(6) - (6)].sr), 0);is_def=0; ;}
    break;

  case 170:
#line 1216 "compilers/imcc/imcc.y"
    { is_def=1; ;}
    break;

  case 171:
#line 1217 "compilers/imcc/imcc.y"
    { mk_const_ident(interp, (yyvsp[(4) - (6)].s), (yyvsp[(3) - (6)].t), (yyvsp[(6) - (6)].sr), 1);is_def=0; ;}
    break;

  case 172:
#line 1218 "compilers/imcc/imcc.y"
    { (yyval.i) = NULL;
                           IMCC_INFO(interp)->cur_call->pcc_sub->flags |= isTAIL_CALL;
                           IMCC_INFO(interp)->cur_call = NULL;
                        ;}
    break;

  case 173:
#line 1222 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, "branch",1, (yyvsp[(2) - (2)].sr)); ;}
    break;

  case 174:
#line 1224 "compilers/imcc/imcc.y"
    { (yyval.i) = INS(interp, IMCC_INFO(interp)->cur_unit, (yyvsp[(1) - (2)].s), 0,
                              IMCC_INFO(interp) -> regs,
                              IMCC_INFO(interp) -> nargs,
                              IMCC_INFO(interp) -> keyvec, 1);
                       free((yyvsp[(1) - (2)].s)); ;}
    break;

  case 175:
#line 1230 "compilers/imcc/imcc.y"
    {  (yyval.i) =MK_I(interp, IMCC_INFO(interp)->cur_unit, "null", 1, (yyvsp[(2) - (2)].sr)); ;}
    break;

  case 176:
#line 1231 "compilers/imcc/imcc.y"
    {  (yyval.i) = 0; IMCC_INFO(interp)->cur_call = NULL; ;}
    break;

  case 177:
#line 1232 "compilers/imcc/imcc.y"
    {  (yyval.i) = 0; ;}
    break;

  case 180:
#line 1235 "compilers/imcc/imcc.y"
    { (yyval.i) = 0;;}
    break;

  case 181:
#line 1239 "compilers/imcc/imcc.y"
    { (yyval.t) = 'I'; ;}
    break;

  case 182:
#line 1240 "compilers/imcc/imcc.y"
    { (yyval.t) = 'N'; ;}
    break;

  case 183:
#line 1241 "compilers/imcc/imcc.y"
    { (yyval.t) = 'S'; ;}
    break;

  case 184:
#line 1242 "compilers/imcc/imcc.y"
    { (yyval.t) = 'P'; ;}
    break;

  case 185:
#line 1243 "compilers/imcc/imcc.y"
    { (yyval.t) = 'P'; free((yyvsp[(1) - (1)].s)); ;}
    break;

  case 186:
#line 1248 "compilers/imcc/imcc.y"
    {
             if ((IMCC_INFO(interp)->cur_pmc_type = pmc_type(interp,
                  string_from_cstring(interp, (yyvsp[(1) - (1)].s), 0))) <= 0) {
                IMCC_fataly(interp, E_SyntaxError,
                   "Unknown PMC type '%s'\n", (yyvsp[(1) - (1)].s));
            }
         ;}
    break;

  case 187:
#line 1259 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, "set", 2, (yyvsp[(1) - (3)].sr), (yyvsp[(3) - (3)].sr));  ;}
    break;

  case 188:
#line 1261 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, (yyvsp[(3) - (4)].s), 2, (yyvsp[(1) - (4)].sr), (yyvsp[(4) - (4)].sr));  ;}
    break;

  case 189:
#line 1263 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, (yyvsp[(4) - (5)].s), 3, (yyvsp[(1) - (5)].sr), (yyvsp[(3) - (5)].sr), (yyvsp[(5) - (5)].sr));  ;}
    break;

  case 190:
#line 1265 "compilers/imcc/imcc.y"
    { (yyval.i) = iINDEXFETCH(interp, IMCC_INFO(interp)->cur_unit, (yyvsp[(1) - (6)].sr), (yyvsp[(3) - (6)].sr), (yyvsp[(5) - (6)].sr)); ;}
    break;

  case 191:
#line 1267 "compilers/imcc/imcc.y"
    { (yyval.i) = iINDEXSET(interp, IMCC_INFO(interp)->cur_unit, (yyvsp[(1) - (6)].sr), (yyvsp[(3) - (6)].sr), (yyvsp[(6) - (6)].sr)); ;}
    break;

  case 192:
#line 1269 "compilers/imcc/imcc.y"
    { (yyval.i) = iNEW(interp, IMCC_INFO(interp)->cur_unit, (yyvsp[(1) - (6)].sr), (yyvsp[(4) - (6)].s), (yyvsp[(6) - (6)].sr), 1); ;}
    break;

  case 193:
#line 1271 "compilers/imcc/imcc.y"
    { (yyval.i) = iNEW(interp, IMCC_INFO(interp)->cur_unit, (yyvsp[(1) - (7)].sr), (yyvsp[(4) - (7)].s), (yyvsp[(6) - (7)].sr), 1); ;}
    break;

  case 194:
#line 1273 "compilers/imcc/imcc.y"
    { (yyval.i) = iNEW(interp, IMCC_INFO(interp)->cur_unit, (yyvsp[(1) - (4)].sr), (yyvsp[(4) - (4)].s), NULL, 1); ;}
    break;

  case 195:
#line 1275 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, "new", 2, (yyvsp[(1) - (4)].sr), (yyvsp[(4) - (4)].sr)); ;}
    break;

  case 196:
#line 1277 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, "new", 2, (yyvsp[(1) - (6)].sr), (yyvsp[(5) - (6)].sr)); ;}
    break;

  case 197:
#line 1279 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, "new", 3, (yyvsp[(1) - (6)].sr), (yyvsp[(4) - (6)].sr), (yyvsp[(6) - (6)].sr)); ;}
    break;

  case 198:
#line 1281 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, "new", 3, (yyvsp[(1) - (7)].sr), (yyvsp[(4) - (7)].sr), (yyvsp[(6) - (7)].sr)); ;}
    break;

  case 199:
#line 1283 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, "set_addr",
                        2, (yyvsp[(1) - (4)].sr), mk_label_address(interp, (yyvsp[(4) - (4)].s))); ;}
    break;

  case 200:
#line 1286 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, "find_global",2,(yyvsp[(1) - (4)].sr),(yyvsp[(4) - (4)].sr));;}
    break;

  case 201:
#line 1288 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, "store_global",2, (yyvsp[(2) - (4)].sr),(yyvsp[(4) - (4)].sr)); ;}
    break;

  case 202:
#line 1292 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, "new", 2, (yyvsp[(2) - (4)].sr), (yyvsp[(4) - (4)].sr)); ;}
    break;

  case 203:
#line 1294 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, "new", 3, (yyvsp[(2) - (6)].sr), (yyvsp[(4) - (6)].sr), (yyvsp[(6) - (6)].sr)); ;}
    break;

  case 204:
#line 1296 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, "new", 3, (yyvsp[(2) - (7)].sr), (yyvsp[(4) - (7)].sr), (yyvsp[(6) - (7)].sr)); ;}
    break;

  case 205:
#line 1299 "compilers/imcc/imcc.y"
    {
            add_pcc_result((yyvsp[(3) - (3)].i)->r[0], (yyvsp[(1) - (3)].sr));
            IMCC_INFO(interp)->cur_call = NULL;
            (yyval.i) = 0;
         ;}
    break;

  case 206:
#line 1305 "compilers/imcc/imcc.y"
    {
            (yyval.i) = IMCC_create_itcall_label(interp);
         ;}
    break;

  case 207:
#line 1309 "compilers/imcc/imcc.y"
    {
           IMCC_itcall_sub(interp, (yyvsp[(6) - (9)].sr));
           IMCC_INFO(interp)->cur_call = NULL;
         ;}
    break;

  case 211:
#line 1317 "compilers/imcc/imcc.y"
    {  (yyval.i) =MK_I(interp, IMCC_INFO(interp)->cur_unit, "null", 1, (yyvsp[(1) - (3)].sr)); ;}
    break;

  case 212:
#line 1321 "compilers/imcc/imcc.y"
    { (yyval.s) = "not"; ;}
    break;

  case 213:
#line 1322 "compilers/imcc/imcc.y"
    { (yyval.s) = "bnot"; ;}
    break;

  case 214:
#line 1323 "compilers/imcc/imcc.y"
    { (yyval.s) = "neg"; ;}
    break;

  case 215:
#line 1327 "compilers/imcc/imcc.y"
    { (yyval.s) = "sub"; ;}
    break;

  case 216:
#line 1328 "compilers/imcc/imcc.y"
    { (yyval.s) = "add"; ;}
    break;

  case 217:
#line 1329 "compilers/imcc/imcc.y"
    { (yyval.s) = "mul"; ;}
    break;

  case 218:
#line 1330 "compilers/imcc/imcc.y"
    { (yyval.s) = "div"; ;}
    break;

  case 219:
#line 1331 "compilers/imcc/imcc.y"
    { (yyval.s) = "mod"; ;}
    break;

  case 220:
#line 1332 "compilers/imcc/imcc.y"
    { (yyval.s) = "fdiv"; ;}
    break;

  case 221:
#line 1333 "compilers/imcc/imcc.y"
    { (yyval.s) = "pow"; ;}
    break;

  case 222:
#line 1334 "compilers/imcc/imcc.y"
    { (yyval.s) = "concat"; ;}
    break;

  case 223:
#line 1335 "compilers/imcc/imcc.y"
    {  (yyval.s) = "iseq"; ;}
    break;

  case 224:
#line 1336 "compilers/imcc/imcc.y"
    {  (yyval.s) = "isne"; ;}
    break;

  case 225:
#line 1337 "compilers/imcc/imcc.y"
    {  (yyval.s) = "isgt"; ;}
    break;

  case 226:
#line 1338 "compilers/imcc/imcc.y"
    {  (yyval.s) = "isge"; ;}
    break;

  case 227:
#line 1339 "compilers/imcc/imcc.y"
    {  (yyval.s) = "islt"; ;}
    break;

  case 228:
#line 1340 "compilers/imcc/imcc.y"
    {  (yyval.s) = "isle"; ;}
    break;

  case 229:
#line 1341 "compilers/imcc/imcc.y"
    { (yyval.s) = "shl"; ;}
    break;

  case 230:
#line 1342 "compilers/imcc/imcc.y"
    { (yyval.s) = "shr"; ;}
    break;

  case 231:
#line 1343 "compilers/imcc/imcc.y"
    { (yyval.s) = "lsr"; ;}
    break;

  case 232:
#line 1344 "compilers/imcc/imcc.y"
    { (yyval.s) = "and"; ;}
    break;

  case 233:
#line 1345 "compilers/imcc/imcc.y"
    { (yyval.s) = "xor"; ;}
    break;

  case 234:
#line 1346 "compilers/imcc/imcc.y"
    { (yyval.s) = "xor"; ;}
    break;

  case 235:
#line 1347 "compilers/imcc/imcc.y"
    { (yyval.s) = "band"; ;}
    break;

  case 236:
#line 1348 "compilers/imcc/imcc.y"
    { (yyval.s) = "bor"; ;}
    break;

  case 237:
#line 1349 "compilers/imcc/imcc.y"
    { (yyval.s) = "bxor"; ;}
    break;

  case 238:
#line 1353 "compilers/imcc/imcc.y"
    { (yyval.i) = IMCC_create_itcall_label(interp);
                           (yyval.i)->type &= ~ITCALL; (yyval.i)->type |= ITRESULT; ;}
    break;

  case 239:
#line 1355 "compilers/imcc/imcc.y"
    {  (yyval.i) = 0; ;}
    break;

  case 240:
#line 1362 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, (yyvsp[(2) - (3)].s), 2, (yyvsp[(1) - (3)].sr), (yyvsp[(3) - (3)].sr)); ;}
    break;

  case 241:
#line 1366 "compilers/imcc/imcc.y"
    { (yyval.s) = "add"; ;}
    break;

  case 242:
#line 1367 "compilers/imcc/imcc.y"
    { (yyval.s) = "sub"; ;}
    break;

  case 243:
#line 1368 "compilers/imcc/imcc.y"
    { (yyval.s) = "mul"; ;}
    break;

  case 244:
#line 1369 "compilers/imcc/imcc.y"
    { (yyval.s) = "div"; ;}
    break;

  case 245:
#line 1370 "compilers/imcc/imcc.y"
    { (yyval.s) = "mod"; ;}
    break;

  case 246:
#line 1371 "compilers/imcc/imcc.y"
    { (yyval.s) = "fdiv"; ;}
    break;

  case 247:
#line 1372 "compilers/imcc/imcc.y"
    { (yyval.s) = "concat"; ;}
    break;

  case 248:
#line 1373 "compilers/imcc/imcc.y"
    { (yyval.s) = "band"; ;}
    break;

  case 249:
#line 1374 "compilers/imcc/imcc.y"
    { (yyval.s) = "bor"; ;}
    break;

  case 250:
#line 1375 "compilers/imcc/imcc.y"
    { (yyval.s) = "bxor"; ;}
    break;

  case 251:
#line 1376 "compilers/imcc/imcc.y"
    { (yyval.s) = "shr"; ;}
    break;

  case 252:
#line 1377 "compilers/imcc/imcc.y"
    { (yyval.s) = "shl"; ;}
    break;

  case 253:
#line 1378 "compilers/imcc/imcc.y"
    { (yyval.s) = "lsr"; ;}
    break;

  case 254:
#line 1384 "compilers/imcc/imcc.y"
    { (yyval.i) = func_ins(interp, IMCC_INFO(interp)->cur_unit, (yyvsp[(1) - (4)].sr), (yyvsp[(3) - (4)].s),
                                   IMCC_INFO(interp) -> regs,
                                   IMCC_INFO(interp) -> nargs,
                                   IMCC_INFO(interp) -> keyvec, 1);
                     free((yyvsp[(3) - (4)].s));
                   ;}
    break;

  case 255:
#line 1392 "compilers/imcc/imcc.y"
    { (yyval.sr) = mk_sub_address(interp, (yyvsp[(1) - (1)].s)); ;}
    break;

  case 256:
#line 1393 "compilers/imcc/imcc.y"
    { (yyval.sr) = mk_sub_address_fromc(interp, (yyvsp[(1) - (1)].s)); ;}
    break;

  case 257:
#line 1394 "compilers/imcc/imcc.y"
    { (yyval.sr) = mk_sub_address_u(interp, (yyvsp[(1) - (1)].s)); ;}
    break;

  case 258:
#line 1395 "compilers/imcc/imcc.y"
    { (yyval.sr) = (yyvsp[(1) - (1)].sr);
                       if ((yyvsp[(1) - (1)].sr)->set != 'P')
                            IMCC_fataly(interp, E_SyntaxError,
                                  "Sub isn't a PMC");
                     ;}
    break;

  case 259:
#line 1400 "compilers/imcc/imcc.y"
    { IMCC_INFO(interp)->cur_obj = (yyvsp[(1) - (3)].sr); (yyval.sr) = (yyvsp[(3) - (3)].sr); ;}
    break;

  case 260:
#line 1401 "compilers/imcc/imcc.y"
    { IMCC_INFO(interp)->cur_obj = (yyvsp[(1) - (3)].sr); (yyval.sr) = mk_const(interp, (yyvsp[(3) - (3)].s), 'S'); ;}
    break;

  case 261:
#line 1402 "compilers/imcc/imcc.y"
    { IMCC_INFO(interp)->cur_obj = (yyvsp[(1) - (3)].sr); (yyval.sr) = (yyvsp[(3) - (3)].sr); ;}
    break;

  case 262:
#line 1408 "compilers/imcc/imcc.y"
    {
           (yyval.i) = IMCC_create_itcall_label(interp);
           IMCC_itcall_sub(interp, (yyvsp[(1) - (1)].sr));
        ;}
    break;

  case 263:
#line 1413 "compilers/imcc/imcc.y"
    {  (yyval.i) = (yyvsp[(2) - (5)].i); ;}
    break;

  case 264:
#line 1417 "compilers/imcc/imcc.y"
    {  (yyval.sr) = 0; ;}
    break;

  case 265:
#line 1418 "compilers/imcc/imcc.y"
    {  (yyval.sr) = 0;
       if (IMCC_INFO(interp)->adv_named_id) {
           add_pcc_named_arg(interp, IMCC_INFO(interp)->cur_call, IMCC_INFO(interp)->adv_named_id, (yyvsp[(3) - (3)].sr));
           IMCC_INFO(interp)->adv_named_id = NULL;
       }
       else add_pcc_arg(IMCC_INFO(interp)->cur_call, (yyvsp[(3) - (3)].sr));
   ;}
    break;

  case 266:
#line 1425 "compilers/imcc/imcc.y"
    {  (yyval.sr) = 0;
       if (IMCC_INFO(interp)->adv_named_id) {
           add_pcc_named_arg(interp, IMCC_INFO(interp)->cur_call,IMCC_INFO(interp)->adv_named_id,(yyvsp[(1) - (1)].sr));
           IMCC_INFO(interp)->adv_named_id = NULL;
       }
       else add_pcc_arg(IMCC_INFO(interp)->cur_call, (yyvsp[(1) - (1)].sr));
   ;}
    break;

  case 267:
#line 1432 "compilers/imcc/imcc.y"
    { (yyval.sr) = 0;
                                     add_pcc_named_arg(interp,IMCC_INFO(interp)->cur_call,(yyvsp[(3) - (5)].s),(yyvsp[(5) - (5)].sr));;}
    break;

  case 268:
#line 1434 "compilers/imcc/imcc.y"
    { (yyval.sr) = 0; add_pcc_named_arg(interp,IMCC_INFO(interp)->cur_call,(yyvsp[(1) - (3)].s),(yyvsp[(3) - (3)].sr));;}
    break;

  case 269:
#line 1438 "compilers/imcc/imcc.y"
    {  (yyval.sr) = (yyvsp[(1) - (2)].sr); (yyval.sr)->type |= (yyvsp[(2) - (2)].t); ;}
    break;

  case 270:
#line 1442 "compilers/imcc/imcc.y"
    {  (yyval.t) = 0; ;}
    break;

  case 271:
#line 1443 "compilers/imcc/imcc.y"
    {  (yyval.t) = (yyvsp[(1) - (2)].t) | (yyvsp[(2) - (2)].t); ;}
    break;

  case 272:
#line 1447 "compilers/imcc/imcc.y"
    { (yyval.t) = VT_FLAT; ;}
    break;

  case 273:
#line 1448 "compilers/imcc/imcc.y"
    { (yyval.t) = VT_NAMED; ;}
    break;

  case 274:
#line 1449 "compilers/imcc/imcc.y"
    { adv_named_set(interp,(yyvsp[(3) - (4)].s)); (yyval.t) = 0; ;}
    break;

  case 275:
#line 1452 "compilers/imcc/imcc.y"
    { (yyval.sr) = (yyvsp[(1) - (2)].sr); (yyval.sr)->type |= (yyvsp[(2) - (2)].t); ;}
    break;

  case 276:
#line 1456 "compilers/imcc/imcc.y"
    {
         (yyval.sr) = 0;
         if (IMCC_INFO(interp)->adv_named_id) {
             add_pcc_named_result(interp,IMCC_INFO(interp)->cur_call,IMCC_INFO(interp)->adv_named_id,(yyvsp[(3) - (3)].sr));
             IMCC_INFO(interp)->adv_named_id = NULL;
         }
         else add_pcc_result(IMCC_INFO(interp)->cur_call, (yyvsp[(3) - (3)].sr)); ;}
    break;

  case 277:
#line 1463 "compilers/imcc/imcc.y"
    {
        add_pcc_named_result(interp,IMCC_INFO(interp)->cur_call,(yyvsp[(3) - (5)].s),(yyvsp[(5) - (5)].sr)); ;}
    break;

  case 278:
#line 1465 "compilers/imcc/imcc.y"
    {
       (yyval.sr) = 0;
       if (IMCC_INFO(interp)->adv_named_id) {
           add_pcc_named_result(interp,IMCC_INFO(interp)->cur_call,IMCC_INFO(interp)->adv_named_id,(yyvsp[(1) - (1)].sr));
           IMCC_INFO(interp)->adv_named_id = NULL;
       }
       else add_pcc_result(IMCC_INFO(interp)->cur_call, (yyvsp[(1) - (1)].sr)); ;}
    break;

  case 279:
#line 1472 "compilers/imcc/imcc.y"
    { add_pcc_named_result(interp,IMCC_INFO(interp)->cur_call,(yyvsp[(1) - (3)].s),(yyvsp[(3) - (3)].sr)); ;}
    break;

  case 280:
#line 1473 "compilers/imcc/imcc.y"
    {  (yyval.sr) = 0; ;}
    break;

  case 281:
#line 1477 "compilers/imcc/imcc.y"
    { (yyval.i) = (yyvsp[(1) - (1)].i); ;}
    break;

  case 282:
#line 1478 "compilers/imcc/imcc.y"
    { (yyval.i) = (yyvsp[(1) - (1)].i); ;}
    break;

  case 283:
#line 1483 "compilers/imcc/imcc.y"
    { (yyval.i) =MK_I(interp, IMCC_INFO(interp)->cur_unit, inv_op((yyvsp[(3) - (6)].s)), 3, (yyvsp[(2) - (6)].sr),(yyvsp[(4) - (6)].sr), (yyvsp[(6) - (6)].sr)); ;}
    break;

  case 284:
#line 1485 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, "unless_null", 2, (yyvsp[(3) - (5)].sr), (yyvsp[(5) - (5)].sr)); ;}
    break;

  case 285:
#line 1487 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, "unless",2, (yyvsp[(2) - (4)].sr), (yyvsp[(4) - (4)].sr)); ;}
    break;

  case 286:
#line 1492 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, "if", 2, (yyvsp[(2) - (4)].sr), (yyvsp[(4) - (4)].sr)); ;}
    break;

  case 287:
#line 1494 "compilers/imcc/imcc.y"
    { (yyval.i) =MK_I(interp, IMCC_INFO(interp)->cur_unit, (yyvsp[(3) - (6)].s), 3, (yyvsp[(2) - (6)].sr), (yyvsp[(4) - (6)].sr), (yyvsp[(6) - (6)].sr)); ;}
    break;

  case 288:
#line 1496 "compilers/imcc/imcc.y"
    { (yyval.i) = MK_I(interp, IMCC_INFO(interp)->cur_unit, "if_null", 2, (yyvsp[(3) - (5)].sr), (yyvsp[(5) - (5)].sr)); ;}
    break;

  case 289:
#line 1500 "compilers/imcc/imcc.y"
    { (yyval.t) = 0; ;}
    break;

  case 290:
#line 1501 "compilers/imcc/imcc.y"
    { (yyval.t) = 0; ;}
    break;

  case 291:
#line 1505 "compilers/imcc/imcc.y"
    {  (yyval.s) = "eq"; ;}
    break;

  case 292:
#line 1506 "compilers/imcc/imcc.y"
    {  (yyval.s) = "ne"; ;}
    break;

  case 293:
#line 1507 "compilers/imcc/imcc.y"
    {  (yyval.s) = "gt"; ;}
    break;

  case 294:
#line 1508 "compilers/imcc/imcc.y"
    {  (yyval.s) = "ge"; ;}
    break;

  case 295:
#line 1509 "compilers/imcc/imcc.y"
    {  (yyval.s) = "lt"; ;}
    break;

  case 296:
#line 1510 "compilers/imcc/imcc.y"
    {  (yyval.s) = "le"; ;}
    break;

  case 299:
#line 1519 "compilers/imcc/imcc.y"
    {  (yyval.sr) = NULL; ;}
    break;

  case 300:
#line 1520 "compilers/imcc/imcc.y"
    {  (yyval.sr) = (yyvsp[(1) - (1)].sr); ;}
    break;

  case 301:
#line 1524 "compilers/imcc/imcc.y"
    { (yyval.sr) = IMCC_INFO(interp)->regs[0]; ;}
    break;

  case 303:
#line 1529 "compilers/imcc/imcc.y"
    {  IMCC_INFO(interp)->regs[IMCC_INFO(interp)->nargs++] = (yyvsp[(1) - (1)].sr); ;}
    break;

  case 304:
#line 1531 "compilers/imcc/imcc.y"
    {
                      IMCC_INFO(interp) -> regs[IMCC_INFO(interp)->nargs++] = (yyvsp[(1) - (4)].sr);
                      IMCC_INFO(interp) -> keyvec |= KEY_BIT(IMCC_INFO(interp)->nargs);
                      IMCC_INFO(interp) -> regs[IMCC_INFO(interp)->nargs++] = (yyvsp[(3) - (4)].sr);
                      (yyval.sr) = (yyvsp[(1) - (4)].sr);
                   ;}
    break;

  case 305:
#line 1538 "compilers/imcc/imcc.y"
    {
                      IMCC_INFO(interp) -> regs[IMCC_INFO(interp)->nargs++] = (yyvsp[(2) - (3)].sr);
                      (yyval.sr) = (yyvsp[(2) - (3)].sr);
                   ;}
    break;

  case 307:
#line 1545 "compilers/imcc/imcc.y"
    { (yyval.sr) = mk_sub_address_fromc(interp, (yyvsp[(1) - (1)].s)); ;}
    break;

  case 308:
#line 1546 "compilers/imcc/imcc.y"
    { (yyval.sr) = mk_sub_address_u(interp, (yyvsp[(1) - (1)].s)); ;}
    break;

  case 309:
#line 1550 "compilers/imcc/imcc.y"
    { (yyval.sr) = mk_sub_address(interp, (yyvsp[(1) - (1)].s)); ;}
    break;

  case 310:
#line 1551 "compilers/imcc/imcc.y"
    { (yyval.sr) = mk_sub_address(interp, (yyvsp[(1) - (1)].s)); ;}
    break;

  case 311:
#line 1555 "compilers/imcc/imcc.y"
    { (yyval.sr) = mk_label_address(interp, (yyvsp[(1) - (1)].s)); ;}
    break;

  case 312:
#line 1556 "compilers/imcc/imcc.y"
    { (yyval.sr) = mk_label_address(interp, (yyvsp[(1) - (1)].s)); ;}
    break;

  case 317:
#line 1569 "compilers/imcc/imcc.y"
    {  IMCC_INFO(interp)->nkeys = 0;
                      IMCC_INFO(interp)->in_slice = 0; ;}
    break;

  case 318:
#line 1571 "compilers/imcc/imcc.y"
    {  (yyval.sr) = link_keys(interp,
                                     IMCC_INFO(interp)->nkeys,
                                     IMCC_INFO(interp)->keys, 0); ;}
    break;

  case 319:
#line 1576 "compilers/imcc/imcc.y"
    {  IMCC_INFO(interp)->nkeys = 0;
                      IMCC_INFO(interp)->in_slice = 0; ;}
    break;

  case 320:
#line 1578 "compilers/imcc/imcc.y"
    {  (yyval.sr) = link_keys(interp,
                                     IMCC_INFO(interp)->nkeys,
                                     IMCC_INFO(interp)->keys, 1); ;}
    break;

  case 321:
#line 1584 "compilers/imcc/imcc.y"
    {  IMCC_INFO(interp)->keys[IMCC_INFO(interp)->nkeys++] = (yyvsp[(1) - (1)].sr); ;}
    break;

  case 322:
#line 1586 "compilers/imcc/imcc.y"
    {  IMCC_INFO(interp)->keys[IMCC_INFO(interp)->nkeys++] = (yyvsp[(3) - (3)].sr);
                      (yyval.sr) = IMCC_INFO(interp)->keys[0]; ;}
    break;

  case 323:
#line 1588 "compilers/imcc/imcc.y"
    { IMCC_INFO(interp)->in_slice = 1; ;}
    break;

  case 324:
#line 1589 "compilers/imcc/imcc.y"
    { IMCC_INFO(interp)->keys[IMCC_INFO(interp)->nkeys++] = (yyvsp[(4) - (4)].sr);
                       (yyval.sr) = IMCC_INFO(interp)->keys[0]; ;}
    break;

  case 325:
#line 1594 "compilers/imcc/imcc.y"
    { if (IMCC_INFO(interp)->in_slice) {
                         (yyvsp[(1) - (1)].sr)->type |= VT_START_SLICE | VT_END_SLICE;
                     }
                     (yyval.sr) = (yyvsp[(1) - (1)].sr);
                   ;}
    break;

  case 326:
#line 1600 "compilers/imcc/imcc.y"
    { (yyvsp[(1) - (3)].sr)->type |= VT_START_SLICE;
                     (yyvsp[(3) - (3)].sr)->type |= VT_END_SLICE;
                     IMCC_INFO(interp)->keys[IMCC_INFO(interp)->nkeys++] = (yyvsp[(1) - (3)].sr);
                     (yyval.sr) = (yyvsp[(3) - (3)].sr); ;}
    break;

  case 327:
#line 1604 "compilers/imcc/imcc.y"
    { (yyvsp[(2) - (2)].sr)->type |= VT_START_ZERO | VT_END_SLICE; (yyval.sr) = (yyvsp[(2) - (2)].sr); ;}
    break;

  case 328:
#line 1605 "compilers/imcc/imcc.y"
    { (yyvsp[(1) - (2)].sr)->type |= VT_START_SLICE | VT_END_INF; (yyval.sr) = (yyvsp[(1) - (2)].sr); ;}
    break;

  case 329:
#line 1609 "compilers/imcc/imcc.y"
    {  (yyval.sr) = mk_symreg(interp, (yyvsp[(1) - (1)].s), 'I'); ;}
    break;

  case 330:
#line 1610 "compilers/imcc/imcc.y"
    {  (yyval.sr) = mk_symreg(interp, (yyvsp[(1) - (1)].s), 'N'); ;}
    break;

  case 331:
#line 1611 "compilers/imcc/imcc.y"
    {  (yyval.sr) = mk_symreg(interp, (yyvsp[(1) - (1)].s), 'S'); ;}
    break;

  case 332:
#line 1612 "compilers/imcc/imcc.y"
    {  (yyval.sr) = mk_symreg(interp, (yyvsp[(1) - (1)].s), 'P'); ;}
    break;

  case 333:
#line 1613 "compilers/imcc/imcc.y"
    {  (yyval.sr) = mk_pasm_reg(interp, (yyvsp[(1) - (1)].s));    ;}
    break;

  case 334:
#line 1617 "compilers/imcc/imcc.y"
    {  (yyval.sr) = mk_const(interp, (yyvsp[(1) - (1)].s), 'I'); ;}
    break;

  case 335:
#line 1618 "compilers/imcc/imcc.y"
    {  (yyval.sr) = mk_const(interp, (yyvsp[(1) - (1)].s), 'N'); ;}
    break;

  case 336:
#line 1619 "compilers/imcc/imcc.y"
    {  (yyval.sr) = mk_const(interp, (yyvsp[(1) - (1)].s), 'S'); ;}
    break;

  case 337:
#line 1620 "compilers/imcc/imcc.y"
    {  (yyval.sr) = mk_const(interp, (yyvsp[(1) - (1)].s), 'U'); ;}
    break;

  case 338:
#line 1624 "compilers/imcc/imcc.y"
    {  (yyval.sr) = mk_symreg(interp, (yyvsp[(1) - (1)].s), 'S'); ;}
    break;

  case 339:
#line 1625 "compilers/imcc/imcc.y"
    {  (yyval.sr) = mk_const(interp, (yyvsp[(1) - (1)].s), 'S');  ;}
    break;


/* Line 1267 of yacc.c.  */
#line 4474 "compilers/imcc/imcparser.c"
      default: break;
    }
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;


  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (yyscanner, interp, YY_("syntax error"));
#else
      {
	YYSIZE_T yysize = yysyntax_error (0, yystate, yychar);
	if (yymsg_alloc < yysize && yymsg_alloc < YYSTACK_ALLOC_MAXIMUM)
	  {
	    YYSIZE_T yyalloc = 2 * yysize;
	    if (! (yysize <= yyalloc && yyalloc <= YYSTACK_ALLOC_MAXIMUM))
	      yyalloc = YYSTACK_ALLOC_MAXIMUM;
	    if (yymsg != yymsgbuf)
	      YYSTACK_FREE (yymsg);
	    yymsg = (char *) YYSTACK_ALLOC (yyalloc);
	    if (yymsg)
	      yymsg_alloc = yyalloc;
	    else
	      {
		yymsg = yymsgbuf;
		yymsg_alloc = sizeof yymsgbuf;
	      }
	  }

	if (0 < yysize && yysize <= yymsg_alloc)
	  {
	    (void) yysyntax_error (yymsg, yystate, yychar);
	    yyerror (yyscanner, interp, yymsg);
	  }
	else
	  {
	    yyerror (yyscanner, interp, YY_("syntax error"));
	    if (yysize != 0)
	      goto yyexhaustedlab;
	  }
      }
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse look-ahead token after an
	 error, discard it.  */

      if (yychar <= YYEOF)
	{
	  /* Return failure if at end of input.  */
	  if (yychar == YYEOF)
	    YYABORT;
	}
      else
	{
	  yydestruct ("Error: discarding",
		      yytoken, &yylval, yyscanner, interp);
	  yychar = YYEMPTY;
	}
    }

  /* Else will try to reuse look-ahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule which action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;


      yydestruct ("Error: popping",
		  yystos[yystate], yyvsp, yyscanner, interp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  *++yyvsp = yylval;


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#ifndef yyoverflow
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (yyscanner, interp, YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEOF && yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval, yyscanner, interp);
  /* Do not reclaim the symbols of the rule which action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp, yyscanner, interp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  /* Make sure YYID is used.  */
  return YYID (yyresult);
}


#line 1630 "compilers/imcc/imcc.y"


/* I need this prototype somewhere... */
char *yyget_text(yyscan_t yyscanner);

/* I do not like this function, but, atm, it is the only way I can
 * make the code in yyerror work without segfault on some specific
 * cases.
 */
/* int yyholds_char(yyscan_t yyscanner ); */

int yyerror(void *yyscanner, PARROT_INTERP, char * s)
{
    /* If the error occurr in the end of the buffer (I mean, the last
     * token was already read), yyget_text will return a pointer
     * outside the bison buffer, and thus, not "accessible" by
     * us. This means it may segfault. */
    char *chr = yyget_text((yyscan_t)yyscanner);

    /* IMCC_fataly(interp, E_SyntaxError, s); */
    /* --- This was called before, not sure if I should call some
           similar function that does not die like this one. */

    /* Basically, if current token is a newline, it mean the error was
     * before the newline, and thus, line is the line *after* the
     * error. Instead of duplicating code for both cases (the 'newline' and
     * non-newline case, do the test twice; efficiency is not important when
     * we have an error anyway.
     */
    if (!at_eof(yyscanner)) {
        if (*chr == '\n') {
            IMCC_INFO(interp)->line--;
        }
        
        IMCC_warning(interp, "error:imcc:%s", s);
        /* don't print the current token if it is a newline */
        if (*chr != '\n') {
            IMCC_warning(interp, " ('%s')", chr);
        }    
        IMCC_print_inc(interp);            
        
        if (*chr == '\n') {
            IMCC_INFO(interp)->line++;
        }

    }
    else { /* scanner is at end of file; just to be sure, do not print "current" token. */
        IMCC_warning(interp, "error:imcc:%s", s);
        IMCC_print_inc(interp);
    }

    return 0;
}

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */

