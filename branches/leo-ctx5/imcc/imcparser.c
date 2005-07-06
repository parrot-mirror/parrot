/* A Bison parser, made from imcc/imcc.y, by GNU bison 1.75.  */

/* Skeleton parser for Yacc-like parsing with Bison,
   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002 Free Software Foundation, Inc.

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
   Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */

/* As a special exception, when this file is copied by Bison into a
   Bison output file, you may use that output file without restriction.
   This special exception was added by the Free Software Foundation
   in version 1.24 of Bison.  */

/* Written by Richard Stallman by simplifying the original so called
   ``semantic'' parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON	1

/* Pure parsers.  */
#define YYPURE	1

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
     FASTCALL = 261,
     N_OPERATORS = 262,
     HLL = 263,
     CALL = 264,
     GOTO = 265,
     ARG = 266,
     IF = 267,
     UNLESS = 268,
     END = 269,
     SAVEALL = 270,
     RESTOREALL = 271,
     ADV_FLAT = 272,
     ADV_SLURPY = 273,
     ADV_OPTIONAL = 274,
     NEW = 275,
     NEWSUB = 276,
     NEWCLOSURE = 277,
     NEWCOR = 278,
     NEWCONT = 279,
     NAMESPACE = 280,
     ENDNAMESPACE = 281,
     CLASS = 282,
     ENDCLASS = 283,
     FIELD = 284,
     DOT_METHOD = 285,
     SUB = 286,
     SYM = 287,
     LOCAL = 288,
     CONST = 289,
     INC = 290,
     DEC = 291,
     GLOBAL_CONST = 292,
     PLUS_ASSIGN = 293,
     MINUS_ASSIGN = 294,
     MUL_ASSIGN = 295,
     DIV_ASSIGN = 296,
     CONCAT_ASSIGN = 297,
     BAND_ASSIGN = 298,
     BOR_ASSIGN = 299,
     BXOR_ASSIGN = 300,
     FDIV = 301,
     FDIV_ASSIGN = 302,
     MOD_ASSIGN = 303,
     SHR_ASSIGN = 304,
     SHL_ASSIGN = 305,
     SHR_U_ASSIGN = 306,
     SHIFT_LEFT = 307,
     SHIFT_RIGHT = 308,
     INTV = 309,
     FLOATV = 310,
     STRINGV = 311,
     PMCV = 312,
     OBJECTV = 313,
     LOG_XOR = 314,
     RELOP_EQ = 315,
     RELOP_NE = 316,
     RELOP_GT = 317,
     RELOP_GTE = 318,
     RELOP_LT = 319,
     RELOP_LTE = 320,
     GLOBAL = 321,
     GLOBALOP = 322,
     ADDR = 323,
     RESULT = 324,
     RETURN = 325,
     YIELDT = 326,
     POW = 327,
     SHIFT_RIGHT_U = 328,
     LOG_AND = 329,
     LOG_OR = 330,
     COMMA = 331,
     ESUB = 332,
     DOTDOT = 333,
     PCC_BEGIN = 334,
     PCC_END = 335,
     PCC_CALL = 336,
     PCC_SUB = 337,
     PCC_BEGIN_RETURN = 338,
     PCC_END_RETURN = 339,
     PCC_BEGIN_YIELD = 340,
     PCC_END_YIELD = 341,
     NCI_CALL = 342,
     METH_CALL = 343,
     INVOCANT = 344,
     MAIN = 345,
     LOAD = 346,
     IMMEDIATE = 347,
     POSTCOMP = 348,
     METHOD = 349,
     ANON = 350,
     MULTI = 351,
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
     CONCAT = 372,
     POINTY = 373
   };
#endif
#define LOW_PREC 258
#define PARAM 259
#define PRAGMA 260
#define FASTCALL 261
#define N_OPERATORS 262
#define HLL 263
#define CALL 264
#define GOTO 265
#define ARG 266
#define IF 267
#define UNLESS 268
#define END 269
#define SAVEALL 270
#define RESTOREALL 271
#define ADV_FLAT 272
#define ADV_SLURPY 273
#define ADV_OPTIONAL 274
#define NEW 275
#define NEWSUB 276
#define NEWCLOSURE 277
#define NEWCOR 278
#define NEWCONT 279
#define NAMESPACE 280
#define ENDNAMESPACE 281
#define CLASS 282
#define ENDCLASS 283
#define FIELD 284
#define DOT_METHOD 285
#define SUB 286
#define SYM 287
#define LOCAL 288
#define CONST 289
#define INC 290
#define DEC 291
#define GLOBAL_CONST 292
#define PLUS_ASSIGN 293
#define MINUS_ASSIGN 294
#define MUL_ASSIGN 295
#define DIV_ASSIGN 296
#define CONCAT_ASSIGN 297
#define BAND_ASSIGN 298
#define BOR_ASSIGN 299
#define BXOR_ASSIGN 300
#define FDIV 301
#define FDIV_ASSIGN 302
#define MOD_ASSIGN 303
#define SHR_ASSIGN 304
#define SHL_ASSIGN 305
#define SHR_U_ASSIGN 306
#define SHIFT_LEFT 307
#define SHIFT_RIGHT 308
#define INTV 309
#define FLOATV 310
#define STRINGV 311
#define PMCV 312
#define OBJECTV 313
#define LOG_XOR 314
#define RELOP_EQ 315
#define RELOP_NE 316
#define RELOP_GT 317
#define RELOP_GTE 318
#define RELOP_LT 319
#define RELOP_LTE 320
#define GLOBAL 321
#define GLOBALOP 322
#define ADDR 323
#define RESULT 324
#define RETURN 325
#define YIELDT 326
#define POW 327
#define SHIFT_RIGHT_U 328
#define LOG_AND 329
#define LOG_OR 330
#define COMMA 331
#define ESUB 332
#define DOTDOT 333
#define PCC_BEGIN 334
#define PCC_END 335
#define PCC_CALL 336
#define PCC_SUB 337
#define PCC_BEGIN_RETURN 338
#define PCC_END_RETURN 339
#define PCC_BEGIN_YIELD 340
#define PCC_END_YIELD 341
#define NCI_CALL 342
#define METH_CALL 343
#define INVOCANT 344
#define MAIN 345
#define LOAD 346
#define IMMEDIATE 347
#define POSTCOMP 348
#define METHOD 349
#define ANON 350
#define MULTI 351
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
#define POINTY 373




/* Copy the first part of user declarations.  */
#line 1 "imcc/imcc.y"

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
#define PARSER_MAIN
#include "imc.h"
#include "pbc.h"
#include "parser.h"

#define YYDEBUG 1
#define YYERROR_VERBOSE 1

/*
 * we use a pure parser with the interpreter as a parameter
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

/*
 * Symbol tables and lists
 * This won't scale to multiple namespaces, for now we just keep
 * one symbol table per compilation file.
 */
SymbolTable global_sym_tab;

/*
 * No nested classes for now.
 */
static Class * current_class;
static Instruction * current_call;
static SymReg *cur_obj, *cur_call;
int cur_pmc_type;      /* used in mk_ident */
IMC_Unit * cur_unit;
SymReg *cur_namespace; /* ugly hack for mk_address */

/*
 * these are used for constructing one INS
 */
static SymReg *keys[IMCC_MAX_REGS];
static int nkeys, in_slice;
static int keyvec;
static SymReg *regs[IMCC_MAX_REGS];
static int nargs;
static int cnr;



/*
 * MK_I: build and emitb instruction by INS
 *
 * fmt may contain:
 *   op %s, %s # comment
 * or just
 *   op
 *
 */
static Instruction *
MK_I(Interp *interpreter, IMC_Unit * unit, const char * fmt, int n, ...)
{
    char opname[64];
    char *p;
    const char *q;
    va_list ap;
    SymReg *r[IMCC_MAX_REGS];
    int i;

    for (p = opname, q = fmt; *q && *q != ' '; )
	*p++ = *q++;
    *p = 0;
    if (!*q)
	fmt = 0;
    else
	fmt = ++q;
#if OPDEBUG
    fprintf(stderr, "op '%s' format '%s' (%d)\n", opname, fmt?:"",n);
#endif
    va_start(ap, n);
    i = 0;
    while (i < n) {
	r[i++] = va_arg(ap, SymReg *);
    }
    va_end(ap);
    while (i < IMCC_MAX_REGS)
	r[i++] = NULL;
    return INS(interpreter, unit, opname, fmt, r, n, keyvec, 1);
}

static Instruction*
mk_pmc_const(Parrot_Interp interp, IMC_Unit *unit,
        char *type, SymReg *left, char *constant)
{
    int type_enum = atoi(type);
    SymReg *rhs;
    SymReg *r[IMCC_MAX_REGS];
    char *name;
    int len;

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
    /* strip delimiters */
    len = strlen(constant);
    name = mem_sys_allocate(len);
    constant[len - 1] = '\0';
    strcpy(name, constant + 1);
    free(constant);
    switch (type_enum) {
        case enum_class_Sub:
        case enum_class_Coroutine:
            rhs = mk_const(interp, name, 'p');
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

static Instruction*
func_ins(Parrot_Interp interp, IMC_Unit *unit, SymReg *lhs, char *op,
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

static void clear_state(void)
{
    nargs = 0;
    keyvec = 0;
    memset(regs, 0, sizeof(regs));
}

Instruction * INS_LABEL(IMC_Unit * unit, SymReg * r0, int emit)
{

    SymReg *r[IMCC_MAX_REGS];
    Instruction *ins;
    int i;

    r[0] = r0;
    i = 1;
    while (i < IMCC_MAX_REGS)
	r[i++] = NULL;
    ins = _mk_instruction("","%s:", r, 0);
    ins->type = ITLABEL;
    r0->first_ins = ins;
    if (emit)
        emitb(unit, ins);
    return ins;
}

static Instruction * iLABEL(IMC_Unit * unit, SymReg * r0) {
    Instruction *i = INS_LABEL(unit, r0, 1);
    i->line = line;
    clear_state();
    return i;
}

static Instruction * iSUBROUTINE(IMC_Unit * unit, SymReg * r0) {
    Instruction *i;
    i =  iLABEL(unit, r0);
    i->line = line - 1;
    return i;
}

/*
 * substr or X = Pkey
 */
static Instruction *
iINDEXFETCH(Interp *interp, IMC_Unit * unit, SymReg * r0, SymReg * r1,
    SymReg * r2)
{
    if(r0->set == 'S' && r1->set == 'S' && r2->set == 'I') {
        SymReg * r3 = mk_const(interp, str_dup("1"), 'I');
        return MK_I(interp, unit, "substr %s, %s, %s, 1", 4, r0, r1, r2, r3);
    }
    keyvec |= KEY_BIT(2);
    return MK_I(interp, unit, "set %s, %s[%s]", 3, r0,r1,r2);
}

/*
 * substr or Pkey = X
 */

static Instruction *
iINDEXSET(Interp *interp, IMC_Unit * unit,
          SymReg * r0, SymReg * r1, SymReg * r2)
{
    if(r0->set == 'S' && r1->set == 'I' && r2->set == 'S') {
        SymReg * r3 = mk_const(interp, str_dup("1"), 'I');
        MK_I(interp, unit, "substr %s, %s, %s, %s", 4, r0, r1,r3, r2);
    }
    else if (r0->set == 'P') {
        keyvec |= KEY_BIT(1);
	MK_I(interp, unit, "set %s[%s], %s", 3, r0,r1,r2);
    }
    else {
        IMCC_fataly(interp, E_SyntaxError,
            "unsupported indexed set op\n");
    }
    return 0;
}

static char * inv_op(char *op) {
    int n;
    return (char *) get_neg_op(op, &n);
}

Instruction *
IMCC_create_itcall_label(Interp* interpreter)
{
    char name[128];
    SymReg * r;
    Instruction *i;

    sprintf(name, "%cpcc_sub_call_%d", IMCC_INTERNAL_CHAR, cnr++);
    r = mk_pcc_sub(interpreter, str_dup(name), 0);
    current_call = i = iLABEL(cur_unit, r);
    i->type = ITCALL | ITPCCSUB;
    return i;
}


static SymReg *
mk_sub_address_fromc(Interp *interp, char * name)
{
    /* name is a quoted sub name */
    SymReg *r;

    name[strlen(name) - 1] = '\0';
    r = mk_sub_address(interp, str_dup(name + 1));
    mem_sys_free(name);
    return r;
}

void
IMCC_itcall_sub(Interp* interp, SymReg* sub)
{
    current_call->r[0]->pcc_sub->sub = sub;
    if (cur_obj) {
        if (cur_obj->set != 'P')
            IMCC_fataly(interp, E_SyntaxError, "object isn't a PMC");
        current_call->r[0]->pcc_sub->object = cur_obj;
        cur_obj = NULL;
    }
    if (current_call->r[0]->pcc_sub->sub->pmc_type == enum_class_NCI)
        current_call->r[0]->pcc_sub->flags |= isNCI;
    if (cur_unit->type == IMC_PCCSUB)
        cur_unit->instructions->r[1]->pcc_sub->calls_a_sub |= 1;
}

static void
begin_return_or_yield(Interp *interp, int yield)
{
    Instruction *i, *ins;
    char name[128];
    ins = cur_unit->instructions;
    if(!ins || !ins->r[1] || ins->r[1]->type != VT_PCC_SUB)
        IMCC_fataly(interp, E_SyntaxError,
              "yield or return directive outside pcc subroutine\n");
    if(yield)
       ins->r[1]->pcc_sub->calls_a_sub = 1 | ITPCCYIELD;
    sprintf(name, yield ? "%cpcc_sub_yield_%d" : "%cpcc_sub_ret_%d", IMCC_INTERNAL_CHAR, cnr++);
    interp->imc_info->sr_return = mk_pcc_sub(interp, str_dup(name), 0);
    i = iLABEL(cur_unit, interp->imc_info->sr_return);
    i->type = yield ? ITPCCSUB | ITLABEL | ITPCCYIELD : ITPCCSUB | ITLABEL ;
    interp->imc_info->asm_state = yield ? AsmInYield : AsmInReturn;
}





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

#ifndef YYSTYPE
#line 319 "imcc/imcc.y"
typedef union {
    IdList * idlist;
    int t;
    char * s;
    SymReg * sr;
    Instruction *i;
    Symbol * sym;
    SymbolList * symlist;
    SymbolTable * symtab;
} yystype;
/* Line 193 of /usr/share/bison/yacc.c.  */
#line 638 "imcc/imcparser.c"
# define YYSTYPE yystype
# define YYSTYPE_IS_TRIVIAL 1
#endif

#ifndef YYLTYPE
typedef struct yyltype
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} yyltype;
# define YYLTYPE yyltype
# define YYLTYPE_IS_TRIVIAL 1
#endif

/* Copy the second part of user declarations.  */


/* Line 213 of /usr/share/bison/yacc.c.  */
#line 659 "imcc/imcparser.c"

#if ! defined (yyoverflow) || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# if YYSTACK_USE_ALLOCA
#  define YYSTACK_ALLOC alloca
# else
#  ifndef YYSTACK_USE_ALLOCA
#   if defined (alloca) || defined (_ALLOCA_H)
#    define YYSTACK_ALLOC alloca
#   else
#    ifdef __GNUC__
#     define YYSTACK_ALLOC __builtin_alloca
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning. */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
# else
#  if defined (__STDC__) || defined (__cplusplus)
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   define YYSIZE_T size_t
#  endif
#  define YYSTACK_ALLOC malloc
#  define YYSTACK_FREE free
# endif
#endif /* ! defined (yyoverflow) || YYERROR_VERBOSE */


#if (! defined (yyoverflow) \
     && (! defined (__cplusplus) \
	 || (YYLTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  short yyss;
  YYSTYPE yyvs;
  };

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAX (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (short) + sizeof (YYSTYPE))				\
      + YYSTACK_GAP_MAX)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  register YYSIZE_T yyi;		\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];	\
	}					\
      while (0)
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
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAX;	\
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (0)

#endif

#if defined (__STDC__) || defined (__cplusplus)
   typedef signed char yysigned_char;
#else
   typedef short yysigned_char;
#endif

/* YYFINAL -- State number of the termination state. */
#define YYFINAL  43
#define YYLAST   584

/* YYNTOKENS -- Number of terminals. */
#define YYNTOKENS  135
/* YYNNTS -- Number of nonterminals. */
#define YYNNTS  117
/* YYNRULES -- Number of rules. */
#define YYNRULES  314
/* YYNRULES -- Number of states. */
#define YYNSTATES  524

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   373

#define YYTRANSLATE(X) \
  ((unsigned)(X) <= YYMAXUTOK ? yytranslate[X] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const unsigned char yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       4,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,   125,     2,     2,     2,   131,   132,     2,
     123,   124,   129,   128,     2,   126,     2,   130,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,   134,
       2,   120,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,   121,     2,   122,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,   133,     2,   127,     2,     2,     2,
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
     116,   117,   118,   119
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const unsigned short yyprhs[] =
{
       0,     0,     3,     5,     7,    10,    12,    14,    16,    18,
      20,    22,    24,    27,    29,    31,    35,    38,    40,    43,
      48,    52,    58,    59,    66,    67,    74,    76,    79,    83,
      86,    88,    90,    92,    94,    95,    99,   103,   104,   106,
     107,   112,   113,   115,   120,   121,   128,   130,   131,   133,
     136,   138,   140,   142,   147,   152,   153,   154,   155,   166,
     167,   169,   173,   174,   180,   181,   185,   189,   191,   193,
     198,   199,   203,   205,   207,   209,   211,   213,   215,   216,
     218,   219,   220,   221,   232,   233,   243,   244,   247,   248,
     252,   253,   255,   259,   261,   263,   265,   267,   269,   271,
     277,   281,   285,   289,   293,   299,   305,   306,   310,   313,
     314,   318,   322,   323,   328,   329,   332,   334,   336,   338,
     340,   342,   344,   345,   351,   353,   354,   357,   361,   365,
     366,   372,   373,   379,   380,   382,   386,   388,   391,   392,
     395,   398,   400,   402,   403,   405,   408,   410,   412,   416,
     418,   422,   424,   426,   429,   432,   433,   438,   439,   446,
     448,   449,   456,   457,   462,   465,   468,   471,   474,   477,
     480,   483,   484,   488,   491,   493,   495,   497,   498,   500,
     502,   504,   506,   508,   510,   512,   514,   516,   518,   520,
     524,   529,   534,   539,   545,   551,   557,   563,   569,   575,
     581,   587,   593,   599,   605,   611,   617,   623,   629,   635,
     641,   648,   655,   662,   670,   675,   680,   687,   695,   700,
     707,   712,   717,   722,   727,   734,   742,   746,   747,   757,
     759,   761,   765,   769,   773,   777,   781,   785,   789,   793,
     797,   801,   805,   809,   813,   818,   820,   822,   824,   828,
     832,   836,   838,   840,   841,   847,   848,   852,   854,   857,
     858,   861,   863,   867,   869,   876,   883,   888,   893,   898,
     903,   905,   907,   909,   911,   913,   915,   917,   919,   920,
     922,   926,   928,   930,   935,   937,   939,   941,   943,   945,
     947,   949,   951,   953,   955,   956,   959,   961,   965,   966,
     971,   973,   977,   980,   983,   985,   987,   989,   991,   993,
     995,   997,   999,  1001,  1003
};

/* YYRHS -- A `-1'-separated list of the rules' RHS. */
static const short yyrhs[] =
{
     136,     0,    -1,   137,    -1,   138,    -1,   137,   138,    -1,
     156,    -1,   155,    -1,   143,    -1,   142,    -1,   163,    -1,
     175,    -1,   152,    -1,   107,     4,    -1,   139,    -1,     4,
      -1,     6,   140,     4,    -1,   141,     4,    -1,     7,    -1,
       8,   110,    -1,     9,   109,    77,   109,    -1,    67,   218,
     105,    -1,    67,   218,   105,   120,   250,    -1,    -1,    35,
     144,   218,   105,   120,   250,    -1,    -1,    35,   146,   110,
     242,   120,   109,    -1,   148,    -1,   147,   148,    -1,   206,
     149,     4,    -1,   107,     4,    -1,   116,    -1,   115,    -1,
     155,    -1,   145,    -1,    -1,   150,   113,   151,    -1,    83,
     183,    98,    -1,    -1,   236,    -1,    -1,    99,   153,   154,
     100,    -1,    -1,   147,    -1,    26,   121,   244,   122,    -1,
      -1,    28,   105,   157,     4,   158,    29,    -1,   159,    -1,
      -1,   160,    -1,   159,   160,    -1,   161,    -1,   162,    -1,
       4,    -1,    30,   218,   105,     4,    -1,    31,   105,   105,
       4,    -1,    -1,    -1,    -1,    32,   164,   239,   165,   170,
       4,   166,   167,   174,    78,    -1,    -1,     4,    -1,   167,
     168,     4,    -1,    -1,     5,   169,   218,   105,   191,    -1,
      -1,   170,    77,   184,    -1,   170,    77,   171,    -1,   184,
      -1,   171,    -1,    97,   123,   172,   124,    -1,    -1,   172,
      77,   173,    -1,   173,    -1,    55,    -1,    56,    -1,    58,
      -1,    57,    -1,   105,    -1,    -1,   203,    -1,    -1,    -1,
      -1,    83,   176,   105,   177,   170,     4,   178,   167,   174,
      78,    -1,    -1,    80,     4,   180,   186,   182,   185,   181,
     188,    81,    -1,    -1,   208,     4,    -1,    -1,    90,   243,
       4,    -1,    -1,   184,    -1,   183,    77,   184,    -1,    92,
      -1,    91,    -1,    93,    -1,    94,    -1,    96,    -1,    95,
      -1,    82,   243,    77,   243,     4,    -1,    82,   243,     4,
      -1,    88,   243,     4,    -1,    89,   235,     4,    -1,    89,
     109,     4,    -1,    89,   235,    77,   243,     4,    -1,    89,
     109,    77,   243,     4,    -1,    -1,   186,   187,     4,    -1,
      12,   229,    -1,    -1,   188,   189,     4,    -1,    70,   235,
     191,    -1,    -1,    34,   190,   218,   105,    -1,    -1,   191,
     192,    -1,    19,    -1,    20,    -1,    84,    -1,    86,    -1,
      85,    -1,    87,    -1,    -1,   193,     4,   196,   197,   194,
      -1,   199,    -1,    -1,   197,     4,    -1,   197,   198,     4,
      -1,    71,   243,   230,    -1,    -1,    71,   123,   200,   202,
     124,    -1,    -1,    72,   123,   201,   202,   124,    -1,    -1,
     243,    -1,   202,    77,   243,    -1,   205,    -1,   203,   205,
      -1,    -1,   204,   209,    -1,   107,     4,    -1,   116,    -1,
     115,    -1,    -1,   207,    -1,   207,   208,    -1,   208,    -1,
      98,    -1,   206,   211,     4,    -1,   105,    -1,   210,    77,
     105,    -1,   220,    -1,   233,    -1,    26,   105,    -1,    27,
     105,    -1,    -1,    34,   212,   218,   210,    -1,    -1,    35,
     213,   218,   105,   120,   250,    -1,   145,    -1,    -1,    38,
     214,   218,   105,   120,   250,    -1,    -1,     5,   215,   218,
     105,    -1,     5,   249,    -1,    70,   243,    -1,    12,   229,
      -1,    71,   243,    -1,    71,   226,    -1,    10,   241,    -1,
      11,   241,    -1,    -1,    22,   216,   151,    -1,   113,   236,
      -1,   226,    -1,   179,    -1,   195,    -1,    -1,    22,    -1,
      23,    -1,    24,    -1,    25,    -1,    55,    -1,    56,    -1,
      57,    -1,    58,    -1,    59,    -1,   219,    -1,   105,    -1,
     235,   120,   243,    -1,   235,   120,   125,   243,    -1,   235,
     120,   126,   243,    -1,   235,   120,   127,   243,    -1,   235,
     120,   243,   128,   243,    -1,   235,   120,   243,   126,   243,
      -1,   235,   120,   243,   129,   243,    -1,   235,   120,   243,
      73,   243,    -1,   235,   120,   243,   130,   243,    -1,   235,
     120,   243,    47,   243,    -1,   235,   120,   243,   131,   243,
      -1,   235,   120,   243,   118,   243,    -1,   235,   120,   243,
      53,   243,    -1,   235,   120,   243,    54,   243,    -1,   235,
     120,   243,    74,   243,    -1,   235,   120,   243,    75,   243,
      -1,   235,   120,   243,    76,   243,    -1,   235,   120,   243,
      60,   243,    -1,   235,   120,   243,   132,   243,    -1,   235,
     120,   243,   133,   243,    -1,   235,   120,   243,   127,   243,
      -1,   235,   120,   243,   121,   244,   122,    -1,   235,   121,
     244,   122,   120,   243,    -1,   235,   120,    21,   219,    77,
     243,    -1,   235,   120,    21,   219,   121,   244,   122,    -1,
     235,   120,    21,   219,    -1,   235,   120,    21,   243,    -1,
     235,   120,    21,   243,    77,   243,    -1,   235,   120,    21,
     243,   121,   244,   122,    -1,   235,   120,   217,   105,    -1,
     235,   120,   217,   105,    77,   105,    -1,   235,   120,    69,
     105,    -1,   235,   120,    68,   251,    -1,    68,   251,   120,
     243,    -1,    21,   235,    77,   243,    -1,    21,   235,    77,
     243,    77,   243,    -1,    21,   235,    77,   243,   121,   244,
     122,    -1,   235,   120,   226,    -1,    -1,   221,   123,   232,
     124,   120,   224,   123,   228,   124,    -1,   222,    -1,   223,
      -1,   235,    39,   243,    -1,   235,    40,   243,    -1,   235,
      41,   243,    -1,   235,    42,   243,    -1,   235,    49,   243,
      -1,   235,    48,   243,    -1,   235,    43,   243,    -1,   235,
      44,   243,    -1,   235,    45,   243,    -1,   235,    46,   243,
      -1,   235,    50,   243,    -1,   235,    51,   243,    -1,   235,
      52,   243,    -1,   235,   120,   113,   151,    -1,   105,    -1,
     109,    -1,   235,    -1,   235,   225,   240,    -1,   235,   225,
     109,    -1,   235,   225,   235,    -1,   119,    -1,   117,    -1,
      -1,   224,   227,   123,   228,   124,    -1,    -1,   228,    77,
     229,    -1,   229,    -1,   243,   230,    -1,    -1,   230,   231,
      -1,    18,    -1,   232,    77,   235,    -1,   235,    -1,    13,
     243,   234,   243,    11,   241,    -1,    14,   243,   234,   243,
      11,   241,    -1,    13,   243,    11,   241,    -1,    14,   243,
      11,   241,    -1,    13,   243,    77,   241,    -1,    14,   243,
      77,   241,    -1,    61,    -1,    62,    -1,    63,    -1,    64,
      -1,    65,    -1,    66,    -1,   114,    -1,   249,    -1,    -1,
     237,    -1,   237,    77,   238,    -1,   238,    -1,   242,    -1,
     235,   121,   244,   122,    -1,   240,    -1,   109,    -1,   105,
      -1,   113,    -1,   105,    -1,   113,    -1,   241,    -1,   243,
      -1,   235,    -1,   250,    -1,    -1,   245,   246,    -1,   248,
      -1,   246,   134,   248,    -1,    -1,   246,    77,   247,   248,
      -1,   243,    -1,   243,    79,   243,    -1,    79,   243,    -1,
     243,    79,    -1,   101,    -1,   102,    -1,   103,    -1,   104,
      -1,   106,    -1,   110,    -1,   111,    -1,   109,    -1,   112,
      -1,   103,    -1,   109,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const unsigned short yyrline[] =
{
       0,   402,   402,   406,   408,   411,   413,   414,   415,   416,
     417,   418,   419,   420,   421,   424,   425,   428,   429,   437,
     448,   455,   464,   463,   469,   468,   472,   474,   477,   479,
     480,   481,   482,   483,   486,   486,   490,   497,   500,   505,
     504,   515,   517,   520,   538,   536,   552,   554,   557,   559,
     562,   564,   565,   568,   582,   600,   606,   611,   598,   616,
     618,   619,   623,   622,   628,   630,   631,   632,   633,   636,
     639,   641,   642,   645,   647,   648,   649,   650,   662,   664,
     668,   670,   676,   667,   683,   681,   712,   714,   717,   719,
     723,   725,   726,   729,   731,   732,   733,   734,   735,   738,
     744,   746,   751,   753,   755,   759,   766,   768,   771,   776,
     778,   781,   783,   783,   787,   789,   792,   794,   798,   800,
     803,   805,   810,   808,   814,   819,   821,   823,   827,   833,
     831,   840,   839,   848,   850,   851,   855,   857,   868,   872,
     875,   876,   877,   880,   882,   885,   887,   890,   896,   901,
     909,   917,   919,   920,   921,   922,   922,   935,   935,   937,
     938,   938,   940,   940,   943,   944,   945,   946,   947,   951,
     952,   953,   953,   956,   959,   960,   961,   962,   965,   967,
     968,   969,   972,   974,   975,   976,   977,   978,   981,   992,
     994,   995,   996,   997,   998,   999,  1000,  1001,  1002,  1003,
    1004,  1005,  1007,  1009,  1011,  1013,  1015,  1017,  1019,  1021,
    1023,  1025,  1027,  1029,  1031,  1033,  1035,  1037,  1039,  1042,
    1049,  1052,  1054,  1058,  1060,  1062,  1065,  1072,  1071,  1080,
    1081,  1084,  1087,  1089,  1091,  1093,  1095,  1097,  1099,  1101,
    1103,  1105,  1107,  1109,  1113,  1121,  1122,  1123,  1128,  1129,
    1130,  1133,  1134,  1139,  1137,  1147,  1149,  1150,  1153,  1157,
    1159,  1162,  1166,  1168,  1171,  1174,  1176,  1178,  1180,  1182,
    1186,  1188,  1189,  1190,  1191,  1192,  1195,  1197,  1200,  1202,
    1205,  1207,  1210,  1212,  1219,  1221,  1224,  1226,  1229,  1231,
    1234,  1236,  1239,  1241,  1244,  1244,  1248,  1250,  1252,  1252,
    1256,  1262,  1265,  1266,  1269,  1271,  1272,  1273,  1274,  1277,
    1279,  1280,  1281,  1284,  1286
};
#endif

#if YYDEBUG || YYERROR_VERBOSE
/* YYTNME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals. */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "LOW_PREC", "'\\n'", "PARAM", "PRAGMA", 
  "FASTCALL", "N_OPERATORS", "HLL", "CALL", "GOTO", "ARG", "IF", "UNLESS", 
  "END", "SAVEALL", "RESTOREALL", "ADV_FLAT", "ADV_SLURPY", 
  "ADV_OPTIONAL", "NEW", "NEWSUB", "NEWCLOSURE", "NEWCOR", "NEWCONT", 
  "NAMESPACE", "ENDNAMESPACE", "CLASS", "ENDCLASS", "FIELD", "DOT_METHOD", 
  "SUB", "SYM", "LOCAL", "CONST", "INC", "DEC", "GLOBAL_CONST", 
  "PLUS_ASSIGN", "MINUS_ASSIGN", "MUL_ASSIGN", "DIV_ASSIGN", 
  "CONCAT_ASSIGN", "BAND_ASSIGN", "BOR_ASSIGN", "BXOR_ASSIGN", "FDIV", 
  "FDIV_ASSIGN", "MOD_ASSIGN", "SHR_ASSIGN", "SHL_ASSIGN", "SHR_U_ASSIGN", 
  "SHIFT_LEFT", "SHIFT_RIGHT", "INTV", "FLOATV", "STRINGV", "PMCV", 
  "OBJECTV", "LOG_XOR", "RELOP_EQ", "RELOP_NE", "RELOP_GT", "RELOP_GTE", 
  "RELOP_LT", "RELOP_LTE", "GLOBAL", "GLOBALOP", "ADDR", "RESULT", 
  "RETURN", "YIELDT", "POW", "SHIFT_RIGHT_U", "LOG_AND", "LOG_OR", 
  "COMMA", "ESUB", "DOTDOT", "PCC_BEGIN", "PCC_END", "PCC_CALL", 
  "PCC_SUB", "PCC_BEGIN_RETURN", "PCC_END_RETURN", "PCC_BEGIN_YIELD", 
  "PCC_END_YIELD", "NCI_CALL", "METH_CALL", "INVOCANT", "MAIN", "LOAD", 
  "IMMEDIATE", "POSTCOMP", "METHOD", "ANON", "MULTI", "LABEL", "EMIT", 
  "EOM", "IREG", "NREG", "SREG", "PREG", "IDENTIFIER", "REG", "MACRO", 
  "ENDM", "STRINGC", "INTC", "FLOATC", "USTRINGC", "PARROT_OP", "VAR", 
  "LINECOMMENT", "FILECOMMENT", "DOT", "CONCAT", "POINTY", "'='", "'['", 
  "']'", "'('", "')'", "'!'", "'-'", "'~'", "'+'", "'*'", "'/'", "'%'", 
  "'&'", "'|'", "';'", "$accept", "program", "compilation_units", 
  "compilation_unit", "pragma", "pragma_1", "hll_def", "global", 
  "constdef", "@1", "pmc_const", "@2", "pasmcode", "pasmline", 
  "pasm_inst", "@3", "pasm_args", "emit", "@4", "opt_pasmcode", 
  "class_namespace", "class", "@5", "class_body", "member_decls", 
  "member_decl", "field_decl", "method_decl", "sub", "@6", "@7", "@8", 
  "sub_params", "sub_param", "@9", "sub_proto", "multi", "multi_types", 
  "multi_type", "sub_body", "pcc_sub", "@10", "@11", "@12", 
  "pcc_sub_call", "@13", "opt_label", "opt_invocant", "pcc_sub_proto", 
  "proto", "pcc_call", "pcc_args", "pcc_arg", "pcc_results", "pcc_result", 
  "@14", "paramtype_list", "paramtype", "begin_ret_or_yield", 
  "end_ret_or_yield", "pcc_ret", "@15", "pcc_returns", "pcc_return", 
  "pcc_return_many", "@16", "@17", "var_returns", "statements", 
  "helper_clear_state", "statement", "labels", "_labels", "label", 
  "instruction", "id_list", "labeled_inst", "@18", "@19", "@20", "@21", 
  "@22", "newsub", "type", "classname", "assignment", "@23", "op_assign", 
  "func_assign", "the_sub", "ptr", "sub_call", "@24", "arglist", "arg", 
  "argtype_list", "argtype", "targetlist", "if_statement", "relop", 
  "target", "vars", "_vars", "_var_or_i", "sub_label_op_c", 
  "sub_label_op", "label_op", "var_or_i", "var", "keylist", "@25", 
  "_keylist", "@26", "key", "reg", "const", "string", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const unsigned short yytoknum[] =
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
     364,   365,   366,   367,   368,   369,   370,   371,   372,   373,
      61,    91,    93,    40,    41,    33,    45,   126,    43,    42,
      47,    37,    38,   124,    59
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const unsigned char yyr1[] =
{
       0,   135,   136,   137,   137,   138,   138,   138,   138,   138,
     138,   138,   138,   138,   138,   139,   139,   140,   140,   141,
     142,   142,   144,   143,   146,   145,   147,   147,   148,   148,
     148,   148,   148,   148,   150,   149,   149,   149,   151,   153,
     152,   154,   154,   155,   157,   156,   158,   158,   159,   159,
     160,   160,   160,   161,   162,   164,   165,   166,   163,   167,
     167,   167,   169,   168,   170,   170,   170,   170,   170,   171,
     172,   172,   172,   173,   173,   173,   173,   173,   174,   174,
     176,   177,   178,   175,   180,   179,   181,   181,   182,   182,
     183,   183,   183,   184,   184,   184,   184,   184,   184,   185,
     185,   185,   185,   185,   185,   185,   186,   186,   187,   188,
     188,   189,   190,   189,   191,   191,   192,   192,   193,   193,
     194,   194,   196,   195,   195,   197,   197,   197,   198,   200,
     199,   201,   199,   202,   202,   202,   203,   203,   204,   205,
     205,   205,   205,   206,   206,   207,   207,   208,   209,   210,
     210,   211,   211,   211,   211,   212,   211,   213,   211,   211,
     214,   211,   215,   211,   211,   211,   211,   211,   211,   211,
     211,   216,   211,   211,   211,   211,   211,   211,   217,   217,
     217,   217,   218,   218,   218,   218,   218,   218,   219,   220,
     220,   220,   220,   220,   220,   220,   220,   220,   220,   220,
     220,   220,   220,   220,   220,   220,   220,   220,   220,   220,
     220,   220,   220,   220,   220,   220,   220,   220,   220,   220,
     220,   220,   220,   220,   220,   220,   220,   221,   220,   220,
     220,   222,   222,   222,   222,   222,   222,   222,   222,   222,
     222,   222,   222,   222,   223,   224,   224,   224,   224,   224,
     224,   225,   225,   227,   226,   228,   228,   228,   229,   230,
     230,   231,   232,   232,   233,   233,   233,   233,   233,   233,
     234,   234,   234,   234,   234,   234,   235,   235,   236,   236,
     237,   237,   238,   238,   239,   239,   240,   240,   241,   241,
     242,   242,   243,   243,   245,   244,   246,   246,   247,   246,
     248,   248,   248,   248,   249,   249,   249,   249,   249,   250,
     250,   250,   250,   251,   251
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const unsigned char yyr2[] =
{
       0,     2,     1,     1,     2,     1,     1,     1,     1,     1,
       1,     1,     2,     1,     1,     3,     2,     1,     2,     4,
       3,     5,     0,     6,     0,     6,     1,     2,     3,     2,
       1,     1,     1,     1,     0,     3,     3,     0,     1,     0,
       4,     0,     1,     4,     0,     6,     1,     0,     1,     2,
       1,     1,     1,     4,     4,     0,     0,     0,    10,     0,
       1,     3,     0,     5,     0,     3,     3,     1,     1,     4,
       0,     3,     1,     1,     1,     1,     1,     1,     0,     1,
       0,     0,     0,    10,     0,     9,     0,     2,     0,     3,
       0,     1,     3,     1,     1,     1,     1,     1,     1,     5,
       3,     3,     3,     3,     5,     5,     0,     3,     2,     0,
       3,     3,     0,     4,     0,     2,     1,     1,     1,     1,
       1,     1,     0,     5,     1,     0,     2,     3,     3,     0,
       5,     0,     5,     0,     1,     3,     1,     2,     0,     2,
       2,     1,     1,     0,     1,     2,     1,     1,     3,     1,
       3,     1,     1,     2,     2,     0,     4,     0,     6,     1,
       0,     6,     0,     4,     2,     2,     2,     2,     2,     2,
       2,     0,     3,     2,     1,     1,     1,     0,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     3,
       4,     4,     4,     5,     5,     5,     5,     5,     5,     5,
       5,     5,     5,     5,     5,     5,     5,     5,     5,     5,
       6,     6,     6,     7,     4,     4,     6,     7,     4,     6,
       4,     4,     4,     4,     6,     7,     3,     0,     9,     1,
       1,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     4,     1,     1,     1,     3,     3,
       3,     1,     1,     0,     5,     0,     3,     1,     2,     0,
       2,     1,     3,     1,     6,     6,     4,     4,     4,     4,
       1,     1,     1,     1,     1,     1,     1,     1,     0,     1,
       3,     1,     1,     4,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     0,     2,     1,     3,     0,     4,
       1,     3,     2,     2,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const unsigned short yydefact[] =
{
       0,    14,     0,     0,     0,     0,    55,    22,     0,    80,
      39,     0,     0,     2,     3,    13,     0,     8,     7,    11,
       6,     5,     9,    10,    17,     0,     0,     0,   294,    44,
       0,     0,   182,   183,   184,   185,   186,   188,     0,   187,
       0,   143,    12,     1,     4,    16,    18,    15,     0,     0,
       0,     0,   286,   285,   287,    56,   284,     0,    20,    81,
      24,   147,     0,    31,    30,    33,   143,    26,     0,    32,
      34,   144,   146,    19,    43,     0,   304,   305,   306,   307,
     308,   311,   309,   310,   312,   276,   292,   300,   295,   296,
     277,   293,    47,    64,     0,     0,    64,     0,    29,    27,
      40,    90,     0,     0,   145,   302,   303,   298,     0,    52,
       0,     0,     0,    46,    48,    50,    51,    94,    93,    95,
      96,    98,    97,     0,     0,    68,    67,     0,    21,     0,
       0,     0,    91,    28,   278,   301,     0,   297,     0,     0,
      45,    49,    70,    57,     0,    23,    82,   288,   289,   290,
       0,   291,     0,    36,    35,   292,    38,   279,   281,   282,
     299,     0,     0,    73,    74,    76,    75,    77,     0,    72,
      59,    66,    65,    59,     0,    92,   294,     0,    53,    54,
       0,    69,    60,   138,   138,    25,     0,   280,    71,    62,
       0,   142,   141,     0,     0,   138,   143,   136,     0,   283,
       0,   140,    61,    58,   137,   177,   139,    83,     0,   162,
       0,     0,     0,     0,     0,     0,   171,     0,     0,   155,
     157,   160,     0,     0,     0,     0,     0,   118,   119,   245,
     246,   278,   159,   175,     0,   176,   124,     0,   151,     0,
     229,   230,   253,   174,   152,   247,   114,     0,   164,   169,
     170,   166,   259,     0,     0,     0,   278,   153,   154,     0,
       0,     0,   313,   314,     0,   165,   311,   129,   168,   292,
     167,   131,    84,   173,   122,   148,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   252,   251,     0,   294,     0,    63,     0,   258,     0,
     270,   271,   272,   273,   274,   275,     0,     0,     0,     0,
       0,     0,   172,     0,     0,     0,     0,   133,   133,   106,
     125,     0,   263,   255,   231,   232,   233,   234,   237,   238,
     239,   240,   236,   235,   241,   242,   243,     0,   178,   179,
     180,   181,     0,     0,   278,     0,     0,     0,     0,   226,
     189,     0,   249,   250,   248,   116,   117,   115,   163,   261,
     260,   266,   268,     0,   267,   269,     0,   223,   149,   156,
       0,     0,   222,     0,   134,     0,    88,     0,     0,     0,
       0,   257,   214,   215,   221,   220,   244,   190,   191,   192,
     218,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     294,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   294,     0,     0,     0,     0,   130,   132,
       0,     0,     0,     0,   126,     0,   120,   121,   123,     0,
     262,     0,     0,   254,     0,   294,     0,   294,     0,   198,
     201,   202,   206,   196,   203,   204,   205,   200,     0,   194,
     209,   193,   195,   197,   199,   207,   208,     0,   264,   265,
     224,     0,   150,   158,   161,   135,   108,     0,     0,     0,
       0,    86,   107,   259,   127,     0,   247,   256,   212,     0,
     216,     0,   219,   210,   211,   225,    89,     0,     0,     0,
       0,   109,     0,   128,   255,   213,   217,   100,     0,   101,
     103,     0,   102,     0,     0,    87,     0,     0,     0,     0,
     112,     0,    85,     0,   228,    99,   105,   104,     0,   114,
     110,     0,   111,   113
};

/* YYDEFGOTO[NTERM-NUM]. */
static const short yydefgoto[] =
{
      -1,    12,    13,    14,    15,    26,    16,    17,    18,    31,
      65,    97,    66,    67,   102,   103,   154,    19,    41,    68,
      20,    21,    51,   112,   113,   114,   115,   116,    22,    30,
      93,   170,   183,   193,   200,   124,   125,   168,   169,   194,
      23,    40,    96,   173,   233,   319,   491,   422,   131,   126,
     471,   376,   423,   504,   513,   518,   296,   357,   234,   428,
     235,   320,   377,   429,   236,   317,   318,   373,   195,   196,
     197,    70,    71,    72,   206,   369,   237,   259,   260,   261,
     247,   256,   348,    38,    39,   238,   239,   240,   241,   242,
     295,   243,   277,   380,   381,   298,   360,   321,   244,   307,
      86,   156,   157,   158,    55,    56,   149,   159,   151,    49,
      50,    88,   136,    89,    90,    91,   264
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -249
static const short yypact[] =
{
       9,  -249,   119,   -73,   -81,   -43,  -249,  -249,   162,  -249,
    -249,   117,   144,     9,  -249,  -249,   141,  -249,  -249,  -249,
    -249,  -249,  -249,  -249,  -249,    50,   148,    86,  -249,  -249,
     -57,   162,  -249,  -249,  -249,  -249,  -249,  -249,    14,  -249,
      59,   -10,  -249,  -249,  -249,  -249,  -249,  -249,    64,    46,
     183,   170,  -249,  -249,  -249,  -249,  -249,    70,    58,  -249,
    -249,  -249,   175,  -249,  -249,  -249,    25,  -249,    80,  -249,
      15,    91,  -249,  -249,  -249,   456,  -249,  -249,  -249,  -249,
    -249,  -249,  -249,  -249,  -249,  -249,  -249,   128,   -60,  -249,
    -249,  -249,    19,   299,    89,   230,   299,   100,  -249,  -249,
    -249,   388,   207,   101,  -249,  -249,   456,  -249,   183,  -249,
     162,   108,   186,    19,  -249,  -249,  -249,  -249,  -249,  -249,
    -249,  -249,  -249,    99,     7,  -249,  -249,   230,  -249,     8,
     428,   -44,  -249,  -249,   428,  -249,   183,  -249,   118,   120,
    -249,  -249,   146,  -249,   299,  -249,  -249,  -249,  -249,  -249,
     106,  -249,   388,  -249,  -249,   124,  -249,   150,  -249,  -249,
    -249,   243,   244,  -249,  -249,  -249,  -249,  -249,   -53,  -249,
     246,  -249,  -249,   246,   143,  -249,  -249,   428,  -249,  -249,
     146,  -249,  -249,     2,     2,  -249,   137,  -249,  -249,  -249,
     261,  -249,  -249,   264,   200,    75,    91,  -249,   202,  -249,
     162,  -249,  -249,  -249,  -249,   392,  -249,  -249,   177,   171,
     -67,   -67,   456,   456,   456,   229,  -249,   191,   204,  -249,
     178,  -249,   -56,   456,   215,   168,   311,  -249,  -249,  -249,
    -249,   428,  -249,  -249,   324,  -249,  -249,   333,  -249,   211,
    -249,  -249,  -249,  -249,  -249,   262,  -249,   162,  -249,  -249,
    -249,  -249,  -249,   122,   131,   276,   428,  -249,  -249,   162,
     162,   162,  -249,  -249,   242,  -249,   240,  -249,  -249,    20,
    -249,  -249,  -249,  -249,  -249,  -249,   229,   241,   456,   456,
     456,   456,   456,   456,   456,   456,   456,   456,   456,   456,
     456,  -249,  -249,    45,  -249,   330,   115,   263,   348,   -67,
    -249,  -249,  -249,  -249,  -249,  -249,   -67,   456,   -67,   -67,
     456,   456,  -249,   266,   267,   271,   456,   456,   456,  -249,
    -249,   -46,  -249,   456,  -249,  -249,  -249,  -249,  -249,  -249,
    -249,  -249,  -249,  -249,  -249,  -249,  -249,   442,  -249,  -249,
    -249,  -249,   -56,   272,   428,   456,   456,   456,   275,  -249,
     395,   245,  -249,  -249,  -249,  -249,  -249,  -249,  -249,  -249,
    -249,  -249,  -249,   358,  -249,  -249,   373,   -48,  -249,   309,
     268,   278,  -249,   -22,  -249,   -12,    -3,     6,   229,   279,
       4,  -249,   -35,   -14,  -249,  -249,  -249,  -249,  -249,  -249,
     323,   456,   456,   456,   456,   456,   456,   456,   456,   456,
    -249,   456,   456,   456,   456,   456,   456,   456,   456,   287,
     -67,   -67,   456,  -249,   303,   230,   230,   456,  -249,  -249,
     456,   456,    42,   405,  -249,   456,  -249,  -249,  -249,   407,
    -249,   470,   456,  -249,   456,  -249,   456,  -249,   307,  -249,
    -249,  -249,  -249,  -249,  -249,  -249,  -249,  -249,   293,  -249,
    -249,  -249,  -249,  -249,  -249,  -249,  -249,   456,  -249,  -249,
    -249,   295,  -249,  -249,  -249,  -249,  -249,   416,   456,   456,
     152,    91,  -249,  -249,  -249,   300,   -74,  -249,  -249,   302,
    -249,   306,  -249,  -249,  -249,  -249,  -249,    18,   421,    22,
      23,  -249,   425,   348,   456,  -249,  -249,  -249,   456,  -249,
    -249,   456,  -249,   456,    41,  -249,    38,   433,   434,   436,
    -249,   229,  -249,   437,  -249,  -249,  -249,  -249,   162,  -249,
    -249,   340,   115,  -249
};

/* YYPGOTO[NTERM-NUM].  */
static const short yypgoto[] =
{
    -249,  -249,  -249,   439,  -249,  -249,  -249,  -249,  -249,  -249,
     248,  -249,  -249,   380,  -249,  -249,  -248,  -249,  -249,  -249,
      -9,  -249,  -249,  -249,  -249,   337,  -249,  -249,  -249,  -249,
    -249,  -249,   284,  -249,  -249,   362,   315,  -249,   281,   282,
    -249,  -249,  -249,  -249,  -249,  -249,  -249,  -249,  -249,   -80,
    -249,  -249,  -249,  -249,  -249,  -249,   -54,  -249,  -249,  -249,
    -249,  -249,  -249,  -249,  -249,  -249,  -249,   149,  -249,  -249,
     280,   277,  -249,   -70,  -249,  -249,  -249,  -249,  -249,  -249,
    -249,  -249,  -249,   -31,   140,  -249,  -249,  -249,  -249,    43,
    -249,  -210,  -249,    -8,  -208,    12,  -249,  -249,  -249,   234,
     -95,   258,  -249,   313,  -249,   196,  -205,   369,   -47,  -156,
    -249,  -249,  -249,   -78,   283,   -93,   158
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, parse error.  */
#define YYTABLE_NINF -248
static const short yytable[] =
{
      57,   104,   128,    87,   251,   249,   250,   189,   312,   420,
     424,   143,   146,     1,   268,     2,     4,   107,     3,   -37,
     186,   132,   497,   109,   180,    60,   500,   502,   105,   412,
     137,   378,    69,   152,   145,     4,    27,     5,   147,   155,
      28,     6,   434,   291,     7,   292,   148,   262,    52,   110,
     111,     4,    53,   263,   153,   417,    54,    69,   160,   135,
      60,    87,    29,   436,   172,   417,   337,   338,   339,   340,
     341,   181,   175,   413,   108,   510,     8,   425,   379,   138,
     -78,   432,   155,   349,   144,   144,   435,   421,    61,    87,
     -41,   426,     9,   427,   361,   498,   386,    62,   101,   501,
     503,   362,   418,   364,   365,    63,    64,   437,    10,   190,
     245,   511,   419,   342,   343,   432,    11,   191,   192,    58,
     255,    42,   512,    61,   468,   -42,    24,    25,   433,   269,
     469,   470,    62,   299,   355,   356,   155,   291,   351,   292,
      63,    64,   308,  -247,    43,    45,    76,    77,    78,    79,
     229,    80,    47,   -79,   266,    82,    83,    84,   344,    85,
      46,   155,   514,    48,    59,   252,   253,   254,    74,   208,
     345,   346,   347,    73,    92,    94,   265,   270,    95,    98,
     100,   322,   190,   300,   301,   302,   303,   304,   305,    61,
     191,   192,   300,   301,   302,   303,   304,   305,   269,   306,
     353,   163,   164,   165,   166,   458,   459,   106,   309,   127,
     130,   133,   466,   139,   134,   140,   297,    32,    33,    34,
      35,    36,   142,   161,   477,   162,   174,   177,   313,   314,
     315,   324,   325,   326,   327,   328,   329,   330,   331,   332,
     333,   334,   335,   336,   448,   176,   350,   178,   179,   155,
     182,   167,   185,    76,    77,    78,    79,   461,    80,   199,
     363,   489,    75,   366,   367,   201,    85,    37,   202,   372,
     374,   374,    76,    77,    78,    79,   252,    80,   203,   479,
     207,   481,   246,   430,    76,    77,    78,    79,   -24,    80,
     383,   271,    81,    82,    83,    84,   257,    85,   387,   388,
     389,   278,   279,   280,   281,   282,   283,   284,   285,   258,
     286,   287,   288,   289,   290,   272,    76,    77,    78,    79,
     229,    80,   463,   464,   266,    82,    83,    84,   274,    85,
      76,    77,    78,    79,   276,    80,   476,   275,   267,    81,
      82,    83,    84,    85,   439,   440,   441,   442,   443,   444,
     445,   446,   447,   311,   449,   450,   451,   452,   453,   454,
     455,   456,   316,  -246,   323,   460,   359,   409,   358,   410,
     465,   368,   370,   252,   467,   490,   371,   385,   473,   291,
     390,   292,   293,   294,   411,   252,   414,   478,   415,   480,
     117,   118,   119,   120,   121,   122,   123,   209,   416,   431,
     438,   492,   210,   211,   212,   213,   214,   457,   462,   472,
     484,   474,   482,   215,   216,   483,   519,   485,   217,   218,
     486,   487,   488,   494,   495,   499,   219,   220,   496,   505,
     221,    76,    77,    78,    79,    52,    80,   515,   516,   352,
     517,   520,   391,    54,    85,   523,    99,   252,   392,   393,
     141,   507,    44,   232,   508,   394,   509,   184,   129,   171,
     222,   188,   223,   224,   225,   522,   198,   375,   395,   396,
     397,   398,   226,   205,   475,   204,   227,   382,   228,   117,
     118,   119,   120,   121,   122,   493,   506,   521,   310,   273,
     187,   354,   248,    76,    77,    78,    79,   229,    80,   150,
     384,   230,     0,     0,     0,   231,    85,     0,     0,     0,
       0,     0,     0,   399,     0,  -227,   400,     0,     0,     0,
       0,   401,   402,   403,   404,   405,   406,   407,   408,    76,
      77,    78,    79,   147,    80,     0,     0,    81,    82,    83,
      84,   148,    85,    76,    77,    78,    79,    37,    80,     0,
       0,    81,    82,    83,    84,     0,    85,    76,    77,    78,
      79,     0,    80,     0,     0,    81,    82,    83,    84,     0,
      85,    76,    77,    78,    79,   229,    80,     0,     0,   230,
       0,     0,     0,     0,    85
};

static const short yycheck[] =
{
      31,    71,    95,    50,   212,   210,   211,     5,   256,    12,
       4,     4,     4,     4,   224,     6,    26,    77,     9,     4,
     176,   101,     4,     4,    77,    35,     4,     4,    75,    77,
     108,    77,    41,    77,   127,    26,   109,    28,   105,   134,
     121,    32,    77,   117,    35,   119,   113,   103,   105,    30,
      31,    26,   109,   109,    98,    77,   113,    66,   136,   106,
      35,   108,   105,    77,   144,    77,    21,    22,    23,    24,
      25,   124,   152,   121,   134,    34,    67,    71,   124,   110,
      78,    77,   177,   293,    77,    77,   121,    90,    98,   136,
     100,    85,    83,    87,   299,    77,   344,   107,    83,    77,
      77,   306,   124,   308,   309,   115,   116,   121,    99,   107,
     205,    70,   124,    68,    69,    77,   107,   115,   116,   105,
     215,     4,    81,    98,    82,   100,     7,     8,   124,   224,
      88,    89,   107,    11,    19,    20,   231,   117,   294,   119,
     115,   116,    11,   123,     0,     4,   101,   102,   103,   104,
     105,   106,     4,    78,   109,   110,   111,   112,   113,   114,
     110,   256,   124,    77,   105,   212,   213,   214,   122,   200,
     125,   126,   127,   109,     4,   105,   223,   224,   120,     4,
     100,   276,   107,    61,    62,    63,    64,    65,    66,    98,
     115,   116,    61,    62,    63,    64,    65,    66,   293,    77,
     295,    55,    56,    57,    58,   410,   411,    79,    77,   120,
     110,     4,   420,   105,   113,    29,   247,    55,    56,    57,
      58,    59,   123,   105,   432,   105,   120,    77,   259,   260,
     261,   278,   279,   280,   281,   282,   283,   284,   285,   286,
     287,   288,   289,   290,   400,   121,   293,     4,     4,   344,
       4,   105,   109,   101,   102,   103,   104,   413,   106,   122,
     307,   109,    79,   310,   311,     4,   114,   105,     4,   316,
     317,   318,   101,   102,   103,   104,   323,   106,    78,   435,
      78,   437,   105,   378,   101,   102,   103,   104,   110,   106,
     337,   123,   109,   110,   111,   112,   105,   114,   345,   346,
     347,    39,    40,    41,    42,    43,    44,    45,    46,   105,
      48,    49,    50,    51,    52,     4,   101,   102,   103,   104,
     105,   106,   415,   416,   109,   110,   111,   112,     4,   114,
     101,   102,   103,   104,   123,   106,   431,     4,   123,   109,
     110,   111,   112,   114,   391,   392,   393,   394,   395,   396,
     397,   398,   399,    77,   401,   402,   403,   404,   405,   406,
     407,   408,   120,   123,   123,   412,    18,   122,   105,    11,
     417,   105,   105,   420,   421,   470,   105,   105,   425,   117,
     105,   119,   120,   121,    11,   432,    77,   434,   120,   436,
      91,    92,    93,    94,    95,    96,    97,     5,   120,   120,
      77,   471,    10,    11,    12,    13,    14,   120,   105,     4,
     457,     4,   105,    21,    22,   122,   511,   122,    26,    27,
       4,   468,   469,   123,   122,     4,    34,    35,   122,     4,
      38,   101,   102,   103,   104,   105,   106,     4,     4,   109,
       4,     4,    47,   113,   114,   105,    66,   494,    53,    54,
     113,   498,    13,   205,   501,    60,   503,   173,    96,   144,
      68,   180,    70,    71,    72,   519,   184,   318,    73,    74,
      75,    76,    80,   196,   431,   195,    84,   337,    86,    91,
      92,    93,    94,    95,    96,   473,   494,   518,   254,   231,
     177,   295,   209,   101,   102,   103,   104,   105,   106,   130,
     342,   109,    -1,    -1,    -1,   113,   114,    -1,    -1,    -1,
      -1,    -1,    -1,   118,    -1,   123,   121,    -1,    -1,    -1,
      -1,   126,   127,   128,   129,   130,   131,   132,   133,   101,
     102,   103,   104,   105,   106,    -1,    -1,   109,   110,   111,
     112,   113,   114,   101,   102,   103,   104,   105,   106,    -1,
      -1,   109,   110,   111,   112,    -1,   114,   101,   102,   103,
     104,    -1,   106,    -1,    -1,   109,   110,   111,   112,    -1,
     114,   101,   102,   103,   104,   105,   106,    -1,    -1,   109,
      -1,    -1,    -1,    -1,   114
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const unsigned char yystos[] =
{
       0,     4,     6,     9,    26,    28,    32,    35,    67,    83,
      99,   107,   136,   137,   138,   139,   141,   142,   143,   152,
     155,   156,   163,   175,     7,     8,   140,   109,   121,   105,
     164,   144,    55,    56,    57,    58,    59,   105,   218,   219,
     176,   153,     4,     0,   138,     4,   110,     4,    77,   244,
     245,   157,   105,   109,   113,   239,   240,   218,   105,   105,
      35,    98,   107,   115,   116,   145,   147,   148,   154,   155,
     206,   207,   208,   109,   122,    79,   101,   102,   103,   104,
     106,   109,   110,   111,   112,   114,   235,   243,   246,   248,
     249,   250,     4,   165,   105,   120,   177,   146,     4,   148,
     100,    83,   149,   150,   208,   243,    79,    77,   134,     4,
      30,    31,   158,   159,   160,   161,   162,    91,    92,    93,
      94,    95,    96,    97,   170,   171,   184,   120,   250,   170,
     110,   183,   184,     4,   113,   243,   247,   248,   218,   105,
      29,   160,   123,     4,    77,   250,     4,   105,   113,   241,
     242,   243,    77,    98,   151,   235,   236,   237,   238,   242,
     248,   105,   105,    55,    56,    57,    58,   105,   172,   173,
     166,   171,   184,   178,   120,   184,   121,    77,     4,     4,
      77,   124,     4,   167,   167,   109,   244,   238,   173,     5,
     107,   115,   116,   168,   174,   203,   204,   205,   174,   122,
     169,     4,     4,    78,   205,   206,   209,    78,   218,     5,
      10,    11,    12,    13,    14,    21,    22,    26,    27,    34,
      35,    38,    68,    70,    71,    72,    80,    84,    86,   105,
     109,   113,   145,   179,   193,   195,   199,   211,   220,   221,
     222,   223,   224,   226,   233,   235,   105,   215,   249,   241,
     241,   229,   243,   243,   243,   235,   216,   105,   105,   212,
     213,   214,   103,   109,   251,   243,   109,   123,   226,   235,
     243,   123,     4,   236,     4,     4,   123,   227,    39,    40,
      41,    42,    43,    44,    45,    46,    48,    49,    50,    51,
      52,   117,   119,   120,   121,   225,   191,   218,   230,    11,
      61,    62,    63,    64,    65,    66,    77,   234,    11,    77,
     234,    77,   151,   218,   218,   218,   120,   200,   201,   180,
     196,   232,   235,   123,   243,   243,   243,   243,   243,   243,
     243,   243,   243,   243,   243,   243,   243,    21,    22,    23,
      24,    25,    68,    69,   113,   125,   126,   127,   217,   226,
     243,   244,   109,   235,   240,    19,    20,   192,   105,    18,
     231,   241,   241,   243,   241,   241,   243,   243,   105,   210,
     105,   105,   243,   202,   243,   202,   186,   197,    77,   124,
     228,   229,   219,   243,   251,   105,   151,   243,   243,   243,
     105,    47,    53,    54,    60,    73,    74,    75,    76,   118,
     121,   126,   127,   128,   129,   130,   131,   132,   133,   122,
      11,    11,    77,   121,    77,   120,   120,    77,   124,   124,
      12,    90,   182,   187,     4,    71,    85,    87,   194,   198,
     235,   120,    77,   124,    77,   121,    77,   121,    77,   243,
     243,   243,   243,   243,   243,   243,   243,   243,   244,   243,
     243,   243,   243,   243,   243,   243,   243,   120,   241,   241,
     243,   244,   105,   250,   250,   243,   229,   243,    82,    88,
      89,   185,     4,   243,     4,   224,   235,   229,   243,   244,
     243,   244,   105,   122,   243,   122,     4,   243,   243,   109,
     235,   181,   208,   230,   123,   122,   122,     4,    77,     4,
       4,    77,     4,    77,   188,     4,   228,   243,   243,   243,
      34,    70,    81,   189,   124,     4,     4,     4,   190,   235,
       4,   218,   191,   105
};

#if ! defined (YYSIZE_T) && defined (__SIZE_TYPE__)
# define YYSIZE_T __SIZE_TYPE__
#endif
#if ! defined (YYSIZE_T) && defined (size_t)
# define YYSIZE_T size_t
#endif
#if ! defined (YYSIZE_T)
# if defined (__STDC__) || defined (__cplusplus)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# endif
#endif
#if ! defined (YYSIZE_T)
# define YYSIZE_T unsigned int
#endif

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		-2
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrlab1

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
      yychar1 = YYTRANSLATE (yychar);				\
      YYPOPSTACK;						\
      goto yybackup;						\
    }								\
  else								\
    { 								\
      yyerror ("syntax error: cannot back up");			\
      YYERROR;							\
    }								\
while (0)

#define YYTERROR	1
#define YYERRCODE	256

/* YYLLOC_DEFAULT -- Compute the default location (before the actions
   are run).  */

#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)           \
  Current.first_line   = Rhs[1].first_line;      \
  Current.first_column = Rhs[1].first_column;    \
  Current.last_line    = Rhs[N].last_line;       \
  Current.last_column  = Rhs[N].last_column;
#endif

/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX	yylex (&yylval, YYLEX_PARAM)
#else
# define YYLEX	yylex (&yylval)
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
} while (0)
# define YYDSYMPRINT(Args)			\
do {						\
  if (yydebug)					\
    yysymprint Args;				\
} while (0)
/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YYDSYMPRINT(Args)
#endif /* !YYDEBUG */

/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   SIZE_MAX < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#if YYMAXDEPTH == 0
# undef YYMAXDEPTH
#endif

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined (__GLIBC__) && defined (_STRING_H)
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
static YYSIZE_T
#   if defined (__STDC__) || defined (__cplusplus)
yystrlen (const char *yystr)
#   else
yystrlen (yystr)
     const char *yystr;
#   endif
{
  register const char *yys = yystr;

  while (*yys++ != '\0')
    continue;

  return yys - yystr - 1;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined (__GLIBC__) && defined (_STRING_H) && defined (_GNU_SOURCE)
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
#   if defined (__STDC__) || defined (__cplusplus)
yystpcpy (char *yydest, const char *yysrc)
#   else
yystpcpy (yydest, yysrc)
     char *yydest;
     const char *yysrc;
#   endif
{
  register char *yyd = yydest;
  register const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

#endif /* !YYERROR_VERBOSE */



#if YYDEBUG
/*-----------------------------.
| Print this symbol on YYOUT.  |
`-----------------------------*/

static void
#if defined (__STDC__) || defined (__cplusplus)
yysymprint (FILE* yyout, int yytype, YYSTYPE yyvalue)
#else
yysymprint (yyout, yytype, yyvalue)
    FILE* yyout;
    int yytype;
    YYSTYPE yyvalue;
#endif
{
  /* Pacify ``unused variable'' warnings.  */
  (void) yyvalue;

  if (yytype < YYNTOKENS)
    {
      YYFPRINTF (yyout, "token %s (", yytname[yytype]);
# ifdef YYPRINT
      YYPRINT (yyout, yytoknum[yytype], yyvalue);
# endif
    }
  else
    YYFPRINTF (yyout, "nterm %s (", yytname[yytype]);

  switch (yytype)
    {
      default:
        break;
    }
  YYFPRINTF (yyout, ")");
}
#endif /* YYDEBUG. */


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
#if defined (__STDC__) || defined (__cplusplus)
yydestruct (int yytype, YYSTYPE yyvalue)
#else
yydestruct (yytype, yyvalue)
    int yytype;
    YYSTYPE yyvalue;
#endif
{
  /* Pacify ``unused variable'' warnings.  */
  (void) yyvalue;

  switch (yytype)
    {
      default:
        break;
    }
}



/* The user can define YYPARSE_PARAM as the name of an argument to be passed
   into yyparse.  The argument should have type void *.
   It should actually point to an object.
   Grammar actions can access the variable by casting it
   to the proper pointer type.  */

#ifdef YYPARSE_PARAM
# if defined (__STDC__) || defined (__cplusplus)
#  define YYPARSE_PARAM_ARG void *YYPARSE_PARAM
#  define YYPARSE_PARAM_DECL
# else
#  define YYPARSE_PARAM_ARG YYPARSE_PARAM
#  define YYPARSE_PARAM_DECL void *YYPARSE_PARAM;
# endif
#else /* !YYPARSE_PARAM */
# define YYPARSE_PARAM_ARG
# define YYPARSE_PARAM_DECL
#endif /* !YYPARSE_PARAM */

/* Prevent warning if -Wstrict-prototypes.  */
#ifdef __GNUC__
# ifdef YYPARSE_PARAM
int yyparse (void *);
# else
int yyparse (void);
# endif
#endif




int
yyparse (YYPARSE_PARAM_ARG)
     YYPARSE_PARAM_DECL
{
  /* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;

/* Number of parse errors so far.  */
int yynerrs;

  register int yystate;
  register int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Lookahead token as an internal (translated) token number.  */
  int yychar1 = 0;

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack.  */
  short	yyssa[YYINITDEPTH];
  short *yyss = yyssa;
  register short *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  register YYSTYPE *yyvsp;



#define YYPOPSTACK   (yyvsp--, yyssp--)

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;


  /* When reducing, the number of symbols on the RHS of the reduced
     rule.  */
  int yylen;

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
     have just been pushed. so pushing a state here evens the stacks.
     */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyssp >= yyss + yystacksize - 1)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack. Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	short *yyss1 = yyss;


	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow ("parser stack overflow",
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),

		    &yystacksize);

	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyoverflowlab;
# else
      /* Extend the stack our own way.  */
      if (yystacksize >= YYMAXDEPTH)
	goto yyoverflowlab;
      yystacksize *= 2;
      if (yystacksize > YYMAXDEPTH)
	yystacksize = YYMAXDEPTH;

      {
	short *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyoverflowlab;
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

      if (yyssp >= yyss + yystacksize - 1)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

/* Do appropriate processing given the current state.  */
/* Read a lookahead token if we need one and don't already have one.  */
/* yyresume: */

  /* First try to decide what to do without reference to lookahead token.  */

  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* yychar is either YYEMPTY or YYEOF
     or a valid token in external form.  */

  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  /* Convert token to internal form (in yychar1) for indexing tables with.  */

  if (yychar <= 0)		/* This means end of input.  */
    {
      yychar1 = 0;
      yychar = YYEOF;		/* Don't call YYLEX any more.  */

      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yychar1 = YYTRANSLATE (yychar);

      /* We have to keep this `#if YYDEBUG', since we use variables
	 which are defined only if `YYDEBUG' is set.  */
      YYDPRINTF ((stderr, "Next token is "));
      YYDSYMPRINT ((stderr, yychar1, yylval));
      YYDPRINTF ((stderr, "\n"));
    }

  /* If the proper action on seeing token YYCHAR1 is to reduce or to
     detect an error, take that action.  */
  yyn += yychar1;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yychar1)
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

  /* Shift the lookahead token.  */
  YYDPRINTF ((stderr, "Shifting token %d (%s), ",
	      yychar, yytname[yychar1]));

  /* Discard the token being shifted unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  *++yyvsp = yylval;


  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  yystate = yyn;
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



#if YYDEBUG
  /* We have to keep this `#if YYDEBUG', since we use variables which
     are defined only if `YYDEBUG' is set.  */
  if (yydebug)
    {
      int yyi;

      YYFPRINTF (stderr, "Reducing via rule %d (line %d), ",
		 yyn - 1, yyrline[yyn]);

      /* Print the symbols being reduced, and their result.  */
      for (yyi = yyprhs[yyn]; yyrhs[yyi] >= 0; yyi++)
	YYFPRINTF (stderr, "%s ", yytname[yyrhs[yyi]]);
      YYFPRINTF (stderr, " -> %s\n", yytname[yyr1[yyn]]);
    }
#endif
  switch (yyn)
    {
        case 2:
#line 403 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 5:
#line 412 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; cur_unit = 0; }
    break;

  case 6:
#line 413 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; }
    break;

  case 7:
#line 414 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; }
    break;

  case 8:
#line 415 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; }
    break;

  case 9:
#line 416 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; imc_close_unit(interp, cur_unit); cur_unit = 0; }
    break;

  case 10:
#line 417 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; imc_close_unit(interp, cur_unit); cur_unit = 0; }
    break;

  case 11:
#line 418 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; imc_close_unit(interp, cur_unit); cur_unit = 0; }
    break;

  case 12:
#line 419 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 13:
#line 420 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 14:
#line 421 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 15:
#line 424 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 16:
#line 425 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 17:
#line 428 "imcc/imcc.y"
    { IMCC_INFO(interp)->state->pragmas |= PR_FASTCALL; }
    break;

  case 18:
#line 430 "imcc/imcc.y"
    { if (yyvsp[0].s)
                          IMCC_INFO(interp)->state->pragmas |= PR_N_OPERATORS;
                      else
                          IMCC_INFO(interp)->state->pragmas &= ~PR_N_OPERATORS;
                    }
    break;

  case 19:
#line 438 "imcc/imcc.y"
    {
            STRING *hll_name, *hll_lib;
            hll_name = string_unescape_cstring(interp, yyvsp[-2].s + 1, '"', NULL);
            hll_lib =  string_unescape_cstring(interp, yyvsp[0].s + 1, '"', NULL);
            IMCC_INFO(interp)->HLL_id =
                Parrot_register_HLL(interp, hll_name, hll_lib);
            yyval.t = 0;
         }
    break;

  case 20:
#line 450 "imcc/imcc.y"
    {
            IMCC_fataly(interp, E_SyntaxError,
                ".global not implemented yet\n");
            yyval.i = 0;
         }
    break;

  case 21:
#line 456 "imcc/imcc.y"
    {
            IMCC_fataly(interp, E_SyntaxError,
                ".global not implemented yet\n");
            yyval.i = 0;
         }
    break;

  case 22:
#line 464 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 23:
#line 465 "imcc/imcc.y"
    { mk_const_ident(interp, yyvsp[-2].s, yyvsp[-3].t, yyvsp[0].sr, 1);is_def=0; }
    break;

  case 24:
#line 469 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 25:
#line 470 "imcc/imcc.y"
    { yyval.i = mk_pmc_const(interp, cur_unit, yyvsp[-3].s, yyvsp[-2].sr, yyvsp[0].s);is_def=0; }
    break;

  case 28:
#line 478 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 29:
#line 479 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 30:
#line 480 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 31:
#line 481 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 32:
#line 482 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; }
    break;

  case 34:
#line 486 "imcc/imcc.y"
    { clear_state(); }
    break;

  case 35:
#line 488 "imcc/imcc.y"
    { yyval.i = INS(interp, cur_unit, yyvsp[-1].s,0,regs,nargs,keyvec,1);
                     free(yyvsp[-1].s); }
    break;

  case 36:
#line 491 "imcc/imcc.y"
    {
                     yyval.i = iSUBROUTINE(cur_unit, mk_sub_label(interp, yyvsp[0].s));
                     yyval.i->r[1] = mk_pcc_sub(interp, str_dup(yyval.i->r[0]->name), 0);
                     add_namespace(interp, cur_unit);
                     yyval.i->r[1]->pcc_sub->pragma = yyvsp[-1].t;
                   }
    break;

  case 37:
#line 497 "imcc/imcc.y"
    { yyval.i = 0;}
    break;

  case 39:
#line 505 "imcc/imcc.y"
    { cur_unit = imc_open_unit(interp, IMC_PASM); }
    break;

  case 40:
#line 507 "imcc/imcc.y"
    { /*
                      if (optimizer_level & OPT_PASM)
                         imc_compile_unit(interp, IMCC_INFO(interp)->cur_unit);
                         emit_flush(interp);
                     */
                     yyval.i=0; }
    break;

  case 43:
#line 522 "imcc/imcc.y"
    {
                    int re_open = 0;
                    yyval.i=0;
                    if (IMCC_INFO(interp)->state->pasm_file && cur_namespace) {
                        imc_close_unit(interp, cur_unit);
                        re_open = 1;
                    }
                    IMCC_INFO(interp)->cur_namespace = yyvsp[-1].sr;
                    cur_namespace = yyvsp[-1].sr;
                    if (re_open)
                        cur_unit = imc_open_unit(interp, IMC_PASM);
                }
    break;

  case 44:
#line 538 "imcc/imcc.y"
    {
                      Symbol * sym = new_symbol(yyvsp[0].s);
                      cur_unit = imc_open_unit(interp, IMC_CLASS);
                      current_class = new_class(sym);
                      sym->p = (void*)current_class;
                      store_symbol(&global_sym_tab, sym); }
    break;

  case 45:
#line 545 "imcc/imcc.y"
    {
                      /* Do nothing for now. Need to parse metadata for
                       * PBC creation. */
                      current_class = NULL;
                      yyval.i = 0; }
    break;

  case 47:
#line 554 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 52:
#line 565 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 53:
#line 570 "imcc/imcc.y"
    {
                      Symbol * sym = new_symbol(yyvsp[-1].s);
                      if(lookup_field_symbol(current_class, yyvsp[-1].s)) {
                        IMCC_fataly(interp, E_SyntaxError,
                            "field '%s' previously declared in class '%s'\n",
                            yyvsp[-1].s, current_class->sym->name);
                      }
                      sym->type = yyvsp[-2].t;
                      store_field_symbol(current_class, sym);
                      yyval.i = 0; }
    break;

  case 54:
#line 584 "imcc/imcc.y"
    {
           Method * meth;
           Symbol * sym = new_symbol(yyvsp[-2].s);
           if(lookup_method_symbol(current_class, yyvsp[-2].s)) {
                IMCC_fataly(interp, E_SyntaxError,
                 "method '%s' previously declared in class '%s'\n",
                    yyvsp[-2].s, current_class->sym->name);
           }
           meth = new_method(sym, new_symbol(yyvsp[-1].s));
           store_method_symbol(current_class, sym);
           yyval.i = 0;
        }
    break;

  case 55:
#line 600 "imcc/imcc.y"
    {
           cur_unit = (IMCC_INFO(interp)->state->pragmas & PR_FASTCALL ?
                  imc_open_unit(interp, IMC_FASTSUB)
                : imc_open_unit(interp, IMC_PCCSUB));
        }
    break;

  case 56:
#line 606 "imcc/imcc.y"
    {
          Instruction *i = iSUBROUTINE(cur_unit, yyvsp[0].sr);
          i->r[1] = cur_call = mk_pcc_sub(interp, str_dup(i->r[0]->name), 0);
          add_namespace(interp, cur_unit);
        }
    break;

  case 57:
#line 611 "imcc/imcc.y"
    { cur_call->pcc_sub->pragma = yyvsp[-1].t; }
    break;

  case 58:
#line 613 "imcc/imcc.y"
    { yyval.i = 0; cur_call = NULL; }
    break;

  case 59:
#line 617 "imcc/imcc.y"
    { yyval.sr = 0; }
    break;

  case 60:
#line 618 "imcc/imcc.y"
    { yyval.sr = 0; }
    break;

  case 61:
#line 619 "imcc/imcc.y"
    { add_pcc_param(cur_call, yyvsp[-1].sr);}
    break;

  case 62:
#line 623 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 63:
#line 624 "imcc/imcc.y"
    { yyval.sr = mk_ident(interp, yyvsp[-1].s, yyvsp[-2].t);
                                         is_def=0; yyval.sr->type |= yyvsp[0].t; }
    break;

  case 64:
#line 629 "imcc/imcc.y"
    { yyval.t = 0;  }
    break;

  case 65:
#line 630 "imcc/imcc.y"
    { yyval.t = yyvsp[-2].t | yyvsp[0].t; }
    break;

  case 66:
#line 631 "imcc/imcc.y"
    { yyval.t = yyvsp[-2].t | yyvsp[0].t; }
    break;

  case 67:
#line 632 "imcc/imcc.y"
    { yyval.t = yyvsp[0].t; }
    break;

  case 68:
#line 633 "imcc/imcc.y"
    { yyval.t = yyvsp[0].t; }
    break;

  case 69:
#line 636 "imcc/imcc.y"
    { yyval.t = 0; }
    break;

  case 70:
#line 640 "imcc/imcc.y"
    { yyval.t = 0; }
    break;

  case 71:
#line 641 "imcc/imcc.y"
    { yyval.t = 0; add_pcc_multi(cur_call, yyvsp[0].sr); }
    break;

  case 72:
#line 642 "imcc/imcc.y"
    { yyval.t = 0;  add_pcc_multi(cur_call, yyvsp[0].sr);}
    break;

  case 73:
#line 646 "imcc/imcc.y"
    { yyval.sr = mk_const(interp, str_dup("INTVAL"), 'S'); }
    break;

  case 74:
#line 647 "imcc/imcc.y"
    { yyval.sr = mk_const(interp, str_dup("FLOATVAL"), 'S'); }
    break;

  case 75:
#line 648 "imcc/imcc.y"
    { yyval.sr = mk_const(interp, str_dup("PMC"), 'S'); }
    break;

  case 76:
#line 649 "imcc/imcc.y"
    { yyval.sr = mk_const(interp, str_dup("STRING"), 'S'); }
    break;

  case 77:
#line 650 "imcc/imcc.y"
    {
                          SymReg *r;
                          if (strcmp(yyvsp[0].s, "_"))
                              r = mk_const(interp, yyvsp[0].s, 'S');
                          else {
                              free(yyvsp[0].s),
                              r = mk_const(interp, str_dup("PMC"), 'S');
                           }
                           yyval.sr = r;
                       }
    break;

  case 80:
#line 668 "imcc/imcc.y"
    { cur_unit = imc_open_unit(interp, IMC_PCCSUB); }
    break;

  case 81:
#line 670 "imcc/imcc.y"
    {
            Instruction *i = iSUBROUTINE(cur_unit, mk_sub_label(interp, yyvsp[0].s));
            i->r[1] = cur_call = mk_pcc_sub(interp, str_dup(i->r[0]->name), 0);
            add_namespace(interp, cur_unit);

         }
    break;

  case 82:
#line 676 "imcc/imcc.y"
    { cur_call->pcc_sub->pragma = yyvsp[-1].t; }
    break;

  case 83:
#line 678 "imcc/imcc.y"
    { yyval.i = 0; cur_call = NULL; }
    break;

  case 84:
#line 683 "imcc/imcc.y"
    {
            char name[128];
            SymReg * r, *r1;
            Instruction *i;

            sprintf(name, "%cpcc_sub_call_%d", IMCC_INTERNAL_CHAR, cnr++);
            yyval.sr = r = mk_pcc_sub(interp, str_dup(name), 0);
            /* this mid rule action has the semantic value of the
             * sub SymReg.
             * This is used below to append args & results
             */
            current_call = i = iLABEL(cur_unit, r);
            i->type = ITPCCSUB;
            /*
             * if we are inside a pcc_sub mark the sub as doing a
             * sub call; the sub is in r1 of the first ins
             */
            r1 = cur_unit->instructions->r[1];
            if (r1 && r1->pcc_sub)
                r1->pcc_sub->calls_a_sub |= 1;
         }
    break;

  case 85:
#line 709 "imcc/imcc.y"
    { yyval.i = 0; current_call = NULL; }
    break;

  case 86:
#line 713 "imcc/imcc.y"
    { yyval.i = NULL;  current_call->r[0]->pcc_sub->label = 0; }
    break;

  case 87:
#line 714 "imcc/imcc.y"
    { yyval.i = NULL;  current_call->r[0]->pcc_sub->label = 1; }
    break;

  case 88:
#line 718 "imcc/imcc.y"
    { yyval.i = NULL; }
    break;

  case 89:
#line 720 "imcc/imcc.y"
    { yyval.i = NULL;  current_call->r[0]->pcc_sub->object = yyvsp[-1].sr; }
    break;

  case 90:
#line 724 "imcc/imcc.y"
    { yyval.t = 0; }
    break;

  case 91:
#line 725 "imcc/imcc.y"
    { yyval.t = yyvsp[0].t; }
    break;

  case 92:
#line 726 "imcc/imcc.y"
    { yyval.t = yyvsp[-2].t | yyvsp[0].t; }
    break;

  case 93:
#line 730 "imcc/imcc.y"
    {  yyval.t = P_LOAD; }
    break;

  case 94:
#line 731 "imcc/imcc.y"
    {  yyval.t = P_MAIN; }
    break;

  case 95:
#line 732 "imcc/imcc.y"
    {  yyval.t = P_IMMEDIATE; }
    break;

  case 96:
#line 733 "imcc/imcc.y"
    {  yyval.t = P_POSTCOMP; }
    break;

  case 97:
#line 734 "imcc/imcc.y"
    {  yyval.t = P_ANON; }
    break;

  case 98:
#line 735 "imcc/imcc.y"
    {  yyval.t = P_METHOD; }
    break;

  case 99:
#line 740 "imcc/imcc.y"
    {
            add_pcc_sub(current_call->r[0], yyvsp[-3].sr);
            add_pcc_cc(current_call->r[0], yyvsp[-1].sr);
         }
    break;

  case 100:
#line 745 "imcc/imcc.y"
    {  add_pcc_sub(current_call->r[0], yyvsp[-1].sr); }
    break;

  case 101:
#line 747 "imcc/imcc.y"
    {
            add_pcc_sub(current_call->r[0], yyvsp[-1].sr);
            current_call->r[0]->pcc_sub->flags |= isNCI;
         }
    break;

  case 102:
#line 752 "imcc/imcc.y"
    {  add_pcc_sub(current_call->r[0], yyvsp[-1].sr); }
    break;

  case 103:
#line 754 "imcc/imcc.y"
    {  add_pcc_sub(current_call->r[0], mk_const(interp, yyvsp[-1].s,'S')); }
    break;

  case 104:
#line 756 "imcc/imcc.y"
    {  add_pcc_sub(current_call->r[0], yyvsp[-3].sr);
            add_pcc_cc(current_call->r[0], yyvsp[-1].sr);
         }
    break;

  case 105:
#line 760 "imcc/imcc.y"
    {  add_pcc_sub(current_call->r[0], mk_const(interp, yyvsp[-3].s,'S'));
            add_pcc_cc(current_call->r[0], yyvsp[-1].sr);
         }
    break;

  case 106:
#line 767 "imcc/imcc.y"
    {  yyval.sr = 0; }
    break;

  case 107:
#line 768 "imcc/imcc.y"
    {  add_pcc_arg(current_call->r[0], yyvsp[-1].sr); }
    break;

  case 108:
#line 772 "imcc/imcc.y"
    {  yyval.sr = yyvsp[0].sr; }
    break;

  case 109:
#line 777 "imcc/imcc.y"
    {  yyval.sr = 0; }
    break;

  case 110:
#line 778 "imcc/imcc.y"
    {  if(yyvsp[-1].sr) add_pcc_result(current_call->r[0], yyvsp[-1].sr); }
    break;

  case 111:
#line 782 "imcc/imcc.y"
    {  yyval.sr = yyvsp[-1].sr; yyval.sr->type |= yyvsp[0].t; }
    break;

  case 112:
#line 783 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 113:
#line 784 "imcc/imcc.y"
    {  mk_ident(interp, yyvsp[0].s, yyvsp[-1].t); is_def=0; yyval.sr=0; }
    break;

  case 114:
#line 788 "imcc/imcc.y"
    {  yyval.t = 0; }
    break;

  case 115:
#line 789 "imcc/imcc.y"
    {  yyval.t = yyvsp[-1].t | yyvsp[0].t; }
    break;

  case 116:
#line 793 "imcc/imcc.y"
    {  yyval.t = VT_FLAT;   }
    break;

  case 117:
#line 794 "imcc/imcc.y"
    {  yyval.t = VT_OPTIONAL; }
    break;

  case 118:
#line 799 "imcc/imcc.y"
    { yyval.t = 0; }
    break;

  case 119:
#line 800 "imcc/imcc.y"
    { yyval.t = 1; }
    break;

  case 122:
#line 810 "imcc/imcc.y"
    { begin_return_or_yield(interp, yyvsp[-1].t); }
    break;

  case 123:
#line 813 "imcc/imcc.y"
    { yyval.i = 0;   IMCC_INFO(interp)->asm_state = AsmDefault; }
    break;

  case 124:
#line 814 "imcc/imcc.y"
    {  IMCC_INFO(interp)->asm_state = AsmDefault; yyval.i = 0;  }
    break;

  case 125:
#line 820 "imcc/imcc.y"
    {  yyval.sr = 0; }
    break;

  case 126:
#line 822 "imcc/imcc.y"
    {  if(yyvsp[-1].sr) add_pcc_return(IMCC_INFO(interp)->sr_return, yyvsp[-1].sr); }
    break;

  case 127:
#line 824 "imcc/imcc.y"
    {  if(yyvsp[-1].sr) add_pcc_return(IMCC_INFO(interp)->sr_return, yyvsp[-1].sr); }
    break;

  case 128:
#line 828 "imcc/imcc.y"
    {  yyval.sr = yyvsp[-1].sr; yyval.sr->type |= yyvsp[0].t; }
    break;

  case 129:
#line 833 "imcc/imcc.y"
    {
            if ( IMCC_INFO(interp)->asm_state == AsmDefault)
                begin_return_or_yield(interp, 0);
        }
    break;

  case 130:
#line 838 "imcc/imcc.y"
    {  IMCC_INFO(interp)->asm_state = AsmDefault; yyval.t = 0;  }
    break;

  case 131:
#line 840 "imcc/imcc.y"
    {
            if ( IMCC_INFO(interp)->asm_state == AsmDefault)
                begin_return_or_yield(interp, 1);
        }
    break;

  case 132:
#line 845 "imcc/imcc.y"
    {  IMCC_INFO(interp)->asm_state = AsmDefault; yyval.t = 0;  }
    break;

  case 133:
#line 849 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 134:
#line 850 "imcc/imcc.y"
    {  add_pcc_return(IMCC_INFO(interp)->sr_return, yyvsp[0].sr);    }
    break;

  case 135:
#line 851 "imcc/imcc.y"
    {  add_pcc_return(IMCC_INFO(interp)->sr_return, yyvsp[0].sr);    }
    break;

  case 138:
#line 869 "imcc/imcc.y"
    { clear_state(); }
    break;

  case 139:
#line 874 "imcc/imcc.y"
    {  yyval.i = yyvsp[0].i; }
    break;

  case 140:
#line 875 "imcc/imcc.y"
    {  yyval.i = 0; }
    break;

  case 141:
#line 876 "imcc/imcc.y"
    {  yyval.i = 0; }
    break;

  case 142:
#line 877 "imcc/imcc.y"
    {  yyval.i = 0; }
    break;

  case 143:
#line 881 "imcc/imcc.y"
    {  yyval.i = NULL; }
    break;

  case 147:
#line 891 "imcc/imcc.y"
    {
                     yyval.i = iLABEL(cur_unit, mk_local_label(interp, yyvsp[0].s));
                   }
    break;

  case 148:
#line 898 "imcc/imcc.y"
    { yyval.i = yyvsp[-1].i; }
    break;

  case 149:
#line 902 "imcc/imcc.y"
    {
            IdList* l = malloc(sizeof(IdList));
            l->next = NULL;
            l->id = yyvsp[0].s;
            yyval.idlist = l;
         }
    break;

  case 150:
#line 910 "imcc/imcc.y"
    {  IdList* l = malloc(sizeof(IdList));
           l->id = yyvsp[0].s;
           l->next = yyvsp[-2].idlist;
           yyval.idlist = l;
        }
    break;

  case 153:
#line 920 "imcc/imcc.y"
    { push_namespace(yyvsp[0].s); }
    break;

  case 154:
#line 921 "imcc/imcc.y"
    { pop_namespace(yyvsp[0].s); }
    break;

  case 155:
#line 922 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 156:
#line 923 "imcc/imcc.y"
    {
        IdList* l = yyvsp[0].idlist;
         while(l) {
             IdList* l1;
             mk_ident(interp, l->id, yyvsp[-1].t);
             l1 = l;
             l = l->next;
             free(l1);
     }
    is_def=0; yyval.i=0;

   }
    break;

  case 157:
#line 935 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 158:
#line 936 "imcc/imcc.y"
    { mk_const_ident(interp, yyvsp[-2].s, yyvsp[-3].t, yyvsp[0].sr, 0);is_def=0; }
    break;

  case 160:
#line 938 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 161:
#line 939 "imcc/imcc.y"
    { mk_const_ident(interp, yyvsp[-2].s, yyvsp[-3].t, yyvsp[0].sr, 1);is_def=0; }
    break;

  case 162:
#line 940 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 163:
#line 941 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "restore",
                                1, mk_ident(interp, yyvsp[0].s, yyvsp[-1].t));is_def=0; }
    break;

  case 164:
#line 943 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "restore", 1, yyvsp[0].sr); }
    break;

  case 165:
#line 944 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "restore", 1, yyvsp[0].sr); }
    break;

  case 166:
#line 945 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "save", 1, yyvsp[0].sr); }
    break;

  case 167:
#line 946 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "save", 1, yyvsp[0].sr); }
    break;

  case 168:
#line 947 "imcc/imcc.y"
    { yyval.i = NULL;
                           current_call->r[0]->pcc_sub->flags |= isTAIL_CALL;
                           current_call = NULL;
                        }
    break;

  case 169:
#line 951 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "bsr",  1, yyvsp[0].sr); }
    break;

  case 170:
#line 952 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "branch",1, yyvsp[0].sr); }
    break;

  case 171:
#line 953 "imcc/imcc.y"
    { expect_pasm = 1; }
    break;

  case 172:
#line 955 "imcc/imcc.y"
    { yyval.i = INS(interp, cur_unit, "newsub",0,regs,nargs,keyvec,1); }
    break;

  case 173:
#line 957 "imcc/imcc.y"
    { yyval.i = INS(interp, cur_unit, yyvsp[-1].s, 0, regs, nargs, keyvec, 1);
                                          free(yyvsp[-1].s); }
    break;

  case 174:
#line 959 "imcc/imcc.y"
    {  yyval.i = 0; current_call = NULL; }
    break;

  case 175:
#line 960 "imcc/imcc.y"
    {  yyval.i = 0; }
    break;

  case 177:
#line 962 "imcc/imcc.y"
    { yyval.i = 0;}
    break;

  case 178:
#line 966 "imcc/imcc.y"
    { yyval.t = NEWSUB; }
    break;

  case 179:
#line 967 "imcc/imcc.y"
    { yyval.t = NEWCLOSURE; }
    break;

  case 180:
#line 968 "imcc/imcc.y"
    { yyval.t = NEWCOR; }
    break;

  case 181:
#line 969 "imcc/imcc.y"
    { yyval.t = NEWCONT; }
    break;

  case 182:
#line 973 "imcc/imcc.y"
    { yyval.t = 'I'; }
    break;

  case 183:
#line 974 "imcc/imcc.y"
    { yyval.t = 'N'; }
    break;

  case 184:
#line 975 "imcc/imcc.y"
    { yyval.t = 'S'; }
    break;

  case 185:
#line 976 "imcc/imcc.y"
    { yyval.t = 'P'; }
    break;

  case 186:
#line 977 "imcc/imcc.y"
    { yyval.t = 'P'; }
    break;

  case 187:
#line 978 "imcc/imcc.y"
    { yyval.t = 'P'; free(yyvsp[0].s); }
    break;

  case 188:
#line 983 "imcc/imcc.y"
    {
            if (( cur_pmc_type = pmc_type(interp,
                  string_from_cstring(interp, yyvsp[0].s, 0))) <= 0) {
                IMCC_fataly(interp, E_SyntaxError,
                   "Unknown PMC type '%s'\n", yyvsp[0].s);
            }
         }
    break;

  case 189:
#line 993 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "set", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 190:
#line 994 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "not", 2, yyvsp[-3].sr, yyvsp[0].sr);}
    break;

  case 191:
#line 995 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "neg", 2, yyvsp[-3].sr, yyvsp[0].sr);}
    break;

  case 192:
#line 996 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "bnot", 2, yyvsp[-3].sr, yyvsp[0].sr);}
    break;

  case 193:
#line 997 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "add", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 194:
#line 998 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "sub", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 195:
#line 999 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "mul", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 196:
#line 1000 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "pow", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 197:
#line 1001 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "div", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 198:
#line 1002 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "fdiv", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 199:
#line 1003 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "mod", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 200:
#line 1004 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "concat", 3, yyvsp[-4].sr,yyvsp[-2].sr,yyvsp[0].sr); }
    break;

  case 201:
#line 1006 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "shl", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 202:
#line 1008 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "shr", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 203:
#line 1010 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "lsr", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 204:
#line 1012 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "and", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 205:
#line 1014 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "or", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 206:
#line 1016 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "xor", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 207:
#line 1018 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "band", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 208:
#line 1020 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "bor", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 209:
#line 1022 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "bxor", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 210:
#line 1024 "imcc/imcc.y"
    { yyval.i = iINDEXFETCH(interp, cur_unit, yyvsp[-5].sr, yyvsp[-3].sr, yyvsp[-1].sr); }
    break;

  case 211:
#line 1026 "imcc/imcc.y"
    { yyval.i = iINDEXSET(interp, cur_unit, yyvsp[-5].sr, yyvsp[-3].sr, yyvsp[0].sr); }
    break;

  case 212:
#line 1028 "imcc/imcc.y"
    { yyval.i = iNEW(interp, cur_unit, yyvsp[-5].sr, yyvsp[-2].s, yyvsp[0].sr, 1); }
    break;

  case 213:
#line 1030 "imcc/imcc.y"
    { yyval.i = iNEW(interp, cur_unit, yyvsp[-6].sr, yyvsp[-3].s, yyvsp[-1].sr, 1); }
    break;

  case 214:
#line 1032 "imcc/imcc.y"
    { yyval.i = iNEW(interp, cur_unit, yyvsp[-3].sr, yyvsp[0].s, NULL, 1); }
    break;

  case 215:
#line 1034 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "new", 2, yyvsp[-3].sr, yyvsp[0].sr); }
    break;

  case 216:
#line 1036 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "new", 3, yyvsp[-5].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 217:
#line 1038 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "new", 3, yyvsp[-6].sr, yyvsp[-3].sr, yyvsp[-1].sr); }
    break;

  case 218:
#line 1040 "imcc/imcc.y"
    { yyval.i = iNEWSUB(interp, cur_unit, yyvsp[-3].sr, yyvsp[-1].t,
                                  mk_sub_address(interp, yyvsp[0].s), NULL, 1); }
    break;

  case 219:
#line 1043 "imcc/imcc.y"
    { /* XXX: Fix 4arg version of newsub PASM op
                              * to use  instead of implicit P0
                              */
                              yyval.i = iNEWSUB(interp, cur_unit, NULL, yyvsp[-3].t,
                                           mk_sub_address(interp, yyvsp[-2].s),
                                           mk_sub_address(interp, yyvsp[0].s), 1); }
    break;

  case 220:
#line 1050 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "set_addr",
                            2, yyvsp[-3].sr, mk_label_address(interp, yyvsp[0].s)); }
    break;

  case 221:
#line 1053 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "find_global",2,yyvsp[-3].sr,yyvsp[0].sr);}
    break;

  case 222:
#line 1055 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "store_global",2, yyvsp[-2].sr,yyvsp[0].sr); }
    break;

  case 223:
#line 1059 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "new", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 224:
#line 1061 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "new", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 225:
#line 1063 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "new", 3, yyvsp[-5].sr, yyvsp[-3].sr, yyvsp[-1].sr); }
    break;

  case 226:
#line 1066 "imcc/imcc.y"
    {
            add_pcc_result(yyvsp[0].i->r[0], yyvsp[-2].sr);
            current_call = NULL;
            yyval.i = 0;
         }
    break;

  case 227:
#line 1072 "imcc/imcc.y"
    {
            yyval.i = IMCC_create_itcall_label(interp);
         }
    break;

  case 228:
#line 1076 "imcc/imcc.y"
    {
           IMCC_itcall_sub(interp, yyvsp[-3].sr);
           current_call = NULL;
         }
    break;

  case 231:
#line 1086 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "add", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 232:
#line 1088 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "sub", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 233:
#line 1090 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "mul", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 234:
#line 1092 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "div", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 235:
#line 1094 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "mod", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 236:
#line 1096 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "fdiv", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 237:
#line 1098 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "concat", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 238:
#line 1100 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "band", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 239:
#line 1102 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "bor", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 240:
#line 1104 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "bxor", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 241:
#line 1106 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "shr", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 242:
#line 1108 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "shl", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 243:
#line 1110 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "lsr", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 244:
#line 1115 "imcc/imcc.y"
    { yyval.i = func_ins(interp, cur_unit, yyvsp[-3].sr, yyvsp[-1].s,
                                   regs,nargs,keyvec,1);
                     free(yyvsp[-1].s);
                   }
    break;

  case 245:
#line 1121 "imcc/imcc.y"
    { yyval.sr = mk_sub_address(interp, yyvsp[0].s); }
    break;

  case 246:
#line 1122 "imcc/imcc.y"
    { yyval.sr = mk_sub_address_fromc(interp, yyvsp[0].s); }
    break;

  case 247:
#line 1123 "imcc/imcc.y"
    { yyval.sr = yyvsp[0].sr;
                       if (yyvsp[0].sr->set != 'P')
                            IMCC_fataly(interp, E_SyntaxError,
                                  "Sub isn't a PMC");
                     }
    break;

  case 248:
#line 1128 "imcc/imcc.y"
    { cur_obj = yyvsp[-2].sr; yyval.sr = yyvsp[0].sr; }
    break;

  case 249:
#line 1129 "imcc/imcc.y"
    { cur_obj = yyvsp[-2].sr; yyval.sr = mk_const(interp, yyvsp[0].s, 'S'); }
    break;

  case 250:
#line 1130 "imcc/imcc.y"
    { cur_obj = yyvsp[-2].sr; yyval.sr = yyvsp[0].sr; }
    break;

  case 251:
#line 1133 "imcc/imcc.y"
    { yyval.t=0; }
    break;

  case 252:
#line 1134 "imcc/imcc.y"
    { yyval.t=0; }
    break;

  case 253:
#line 1139 "imcc/imcc.y"
    {
           yyval.i = IMCC_create_itcall_label(interp);
           IMCC_itcall_sub(interp, yyvsp[0].sr);
        }
    break;

  case 254:
#line 1144 "imcc/imcc.y"
    {  yyval.i = yyvsp[-3].i; }
    break;

  case 255:
#line 1148 "imcc/imcc.y"
    {  yyval.symlist = 0; }
    break;

  case 256:
#line 1149 "imcc/imcc.y"
    {  yyval.symlist = 0; add_pcc_arg(current_call->r[0], yyvsp[0].sr); }
    break;

  case 257:
#line 1150 "imcc/imcc.y"
    {  yyval.symlist = 0; add_pcc_arg(current_call->r[0], yyvsp[0].sr); }
    break;

  case 258:
#line 1154 "imcc/imcc.y"
    {  yyval.sr = yyvsp[-1].sr; yyval.sr->type |= yyvsp[0].t; }
    break;

  case 259:
#line 1158 "imcc/imcc.y"
    {  yyval.t = 0; }
    break;

  case 260:
#line 1159 "imcc/imcc.y"
    {  yyval.t = yyvsp[-1].t | yyvsp[0].t; }
    break;

  case 261:
#line 1163 "imcc/imcc.y"
    {  yyval.t = VT_FLAT; }
    break;

  case 262:
#line 1167 "imcc/imcc.y"
    { yyval.symlist = 0; add_pcc_result(current_call->r[0], yyvsp[0].sr); }
    break;

  case 263:
#line 1168 "imcc/imcc.y"
    { yyval.symlist = 0; add_pcc_result(current_call->r[0], yyvsp[0].sr); }
    break;

  case 264:
#line 1173 "imcc/imcc.y"
    {  yyval.i =MK_I(interp, cur_unit, yyvsp[-3].s, 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 265:
#line 1175 "imcc/imcc.y"
    {  yyval.i =MK_I(interp, cur_unit, inv_op(yyvsp[-3].s), 3, yyvsp[-4].sr,yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 266:
#line 1177 "imcc/imcc.y"
    {  yyval.i = MK_I(interp, cur_unit, "if", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 267:
#line 1179 "imcc/imcc.y"
    {  yyval.i = MK_I(interp, cur_unit, "unless",2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 268:
#line 1181 "imcc/imcc.y"
    {  yyval.i = MK_I(interp, cur_unit, "if", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 269:
#line 1183 "imcc/imcc.y"
    {  yyval.i = MK_I(interp, cur_unit, "unless", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 270:
#line 1187 "imcc/imcc.y"
    {  yyval.s = "eq"; }
    break;

  case 271:
#line 1188 "imcc/imcc.y"
    {  yyval.s = "ne"; }
    break;

  case 272:
#line 1189 "imcc/imcc.y"
    {  yyval.s = "gt"; }
    break;

  case 273:
#line 1190 "imcc/imcc.y"
    {  yyval.s = "ge"; }
    break;

  case 274:
#line 1191 "imcc/imcc.y"
    {  yyval.s = "lt"; }
    break;

  case 275:
#line 1192 "imcc/imcc.y"
    {  yyval.s = "le"; }
    break;

  case 278:
#line 1201 "imcc/imcc.y"
    {  yyval.sr = NULL; }
    break;

  case 279:
#line 1202 "imcc/imcc.y"
    {  yyval.sr = yyvsp[0].sr; }
    break;

  case 280:
#line 1206 "imcc/imcc.y"
    { yyval.sr = regs[0]; }
    break;

  case 282:
#line 1211 "imcc/imcc.y"
    {  regs[nargs++] = yyvsp[0].sr; }
    break;

  case 283:
#line 1213 "imcc/imcc.y"
    {
                      regs[nargs++] = yyvsp[-3].sr;
                      keyvec |= KEY_BIT(nargs);
                      regs[nargs++] = yyvsp[-1].sr; yyval.sr = yyvsp[-3].sr;
                   }
    break;

  case 285:
#line 1221 "imcc/imcc.y"
    { yyval.sr = mk_sub_address_fromc(interp, yyvsp[0].s); }
    break;

  case 286:
#line 1225 "imcc/imcc.y"
    { yyval.sr = mk_sub_address(interp, yyvsp[0].s); }
    break;

  case 287:
#line 1226 "imcc/imcc.y"
    { yyval.sr = mk_sub_address(interp, yyvsp[0].s); }
    break;

  case 288:
#line 1230 "imcc/imcc.y"
    { yyval.sr = mk_label_address(interp, yyvsp[0].s); }
    break;

  case 289:
#line 1231 "imcc/imcc.y"
    { yyval.sr = mk_label_address(interp, yyvsp[0].s); }
    break;

  case 294:
#line 1244 "imcc/imcc.y"
    {  nkeys=0; in_slice = 0; }
    break;

  case 295:
#line 1245 "imcc/imcc.y"
    {  yyval.sr = link_keys(interp, nkeys, keys); }
    break;

  case 296:
#line 1249 "imcc/imcc.y"
    {  keys[nkeys++] = yyvsp[0].sr; }
    break;

  case 297:
#line 1251 "imcc/imcc.y"
    {  keys[nkeys++] = yyvsp[0].sr; yyval.sr =  keys[0]; }
    break;

  case 298:
#line 1252 "imcc/imcc.y"
    { in_slice = 1; }
    break;

  case 299:
#line 1253 "imcc/imcc.y"
    { keys[nkeys++] = yyvsp[0].sr; yyval.sr =  keys[0]; }
    break;

  case 300:
#line 1257 "imcc/imcc.y"
    { if (in_slice) {
                         yyvsp[0].sr->type |= VT_START_SLICE | VT_END_SLICE;
                     }
                     yyval.sr = yyvsp[0].sr;
                   }
    break;

  case 301:
#line 1263 "imcc/imcc.y"
    { yyvsp[-2].sr->type |= VT_START_SLICE;  yyvsp[0].sr->type |= VT_END_SLICE;
                     keys[nkeys++] = yyvsp[-2].sr; yyval.sr = yyvsp[0].sr; }
    break;

  case 302:
#line 1265 "imcc/imcc.y"
    { yyvsp[0].sr->type |= VT_START_ZERO | VT_END_SLICE; yyval.sr = yyvsp[0].sr; }
    break;

  case 303:
#line 1266 "imcc/imcc.y"
    { yyvsp[-1].sr->type |= VT_START_SLICE | VT_END_INF; yyval.sr = yyvsp[-1].sr; }
    break;

  case 304:
#line 1270 "imcc/imcc.y"
    {  yyval.sr = mk_symreg(interp, yyvsp[0].s, 'I'); }
    break;

  case 305:
#line 1271 "imcc/imcc.y"
    {  yyval.sr = mk_symreg(interp, yyvsp[0].s, 'N'); }
    break;

  case 306:
#line 1272 "imcc/imcc.y"
    {  yyval.sr = mk_symreg(interp, yyvsp[0].s, 'S'); }
    break;

  case 307:
#line 1273 "imcc/imcc.y"
    {  yyval.sr = mk_symreg(interp, yyvsp[0].s, 'P'); }
    break;

  case 308:
#line 1274 "imcc/imcc.y"
    {  yyval.sr = mk_pasm_reg(interp, yyvsp[0].s); }
    break;

  case 309:
#line 1278 "imcc/imcc.y"
    {  yyval.sr = mk_const(interp, yyvsp[0].s, 'I'); }
    break;

  case 310:
#line 1279 "imcc/imcc.y"
    {  yyval.sr = mk_const(interp, yyvsp[0].s, 'N'); }
    break;

  case 311:
#line 1280 "imcc/imcc.y"
    {  yyval.sr = mk_const(interp, yyvsp[0].s, 'S'); }
    break;

  case 312:
#line 1281 "imcc/imcc.y"
    {  yyval.sr = mk_const(interp, yyvsp[0].s, 'U'); }
    break;

  case 313:
#line 1285 "imcc/imcc.y"
    {  yyval.sr = mk_symreg(interp, yyvsp[0].s, 'S'); }
    break;

  case 314:
#line 1286 "imcc/imcc.y"
    {  yyval.sr = mk_const(interp, yyvsp[0].s, 'S'); }
    break;


    }

/* Line 1016 of /usr/share/bison/yacc.c.  */
#line 3628 "imcc/imcparser.c"

  yyvsp -= yylen;
  yyssp -= yylen;


#if YYDEBUG
  if (yydebug)
    {
      short *yyssp1 = yyss - 1;
      YYFPRINTF (stderr, "state stack now");
      while (yyssp1 != yyssp)
	YYFPRINTF (stderr, " %d", *++yyssp1);
      YYFPRINTF (stderr, "\n");
    }
#endif

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
#if YYERROR_VERBOSE
      yyn = yypact[yystate];

      if (YYPACT_NINF < yyn && yyn < YYLAST)
	{
	  YYSIZE_T yysize = 0;
	  int yytype = YYTRANSLATE (yychar);
	  char *yymsg;
	  int yyx, yycount;

	  yycount = 0;
	  /* Start YYX at -YYN if negative to avoid negative indexes in
	     YYCHECK.  */
	  for (yyx = yyn < 0 ? -yyn : 0;
	       yyx < (int) (sizeof (yytname) / sizeof (char *)); yyx++)
	    if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	      yysize += yystrlen (yytname[yyx]) + 15, yycount++;
	  yysize += yystrlen ("parse error, unexpected ") + 1;
	  yysize += yystrlen (yytname[yytype]);
	  yymsg = (char *) YYSTACK_ALLOC (yysize);
	  if (yymsg != 0)
	    {
	      char *yyp = yystpcpy (yymsg, "parse error, unexpected ");
	      yyp = yystpcpy (yyp, yytname[yytype]);

	      if (yycount < 5)
		{
		  yycount = 0;
		  for (yyx = yyn < 0 ? -yyn : 0;
		       yyx < (int) (sizeof (yytname) / sizeof (char *));
		       yyx++)
		    if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
		      {
			const char *yyq = ! yycount ? ", expecting " : " or ";
			yyp = yystpcpy (yyp, yyq);
			yyp = yystpcpy (yyp, yytname[yyx]);
			yycount++;
		      }
		}
	      yyerror (yymsg);
	      YYSTACK_FREE (yymsg);
	    }
	  else
	    yyerror ("parse error; also virtual memory exhausted");
	}
      else
#endif /* YYERROR_VERBOSE */
	yyerror ("parse error");
    }
  goto yyerrlab1;


/*----------------------------------------------------.
| yyerrlab1 -- error raised explicitly by an action.  |
`----------------------------------------------------*/
yyerrlab1:
  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
	 error, discard it.  */

      /* Return failure if at end of input.  */
      if (yychar == YYEOF)
        {
	  /* Pop the error token.  */
          YYPOPSTACK;
	  /* Pop the rest of the stack.  */
	  while (yyssp > yyss)
	    {
	      YYDPRINTF ((stderr, "Error: popping "));
	      YYDSYMPRINT ((stderr,
			    yystos[*yyssp],
			    *yyvsp));
	      YYDPRINTF ((stderr, "\n"));
	      yydestruct (yystos[*yyssp], *yyvsp);
	      YYPOPSTACK;
	    }
	  YYABORT;
        }

      YYDPRINTF ((stderr, "Discarding token %d (%s).\n",
		  yychar, yytname[yychar1]));
      yydestruct (yychar1, yylval);
      yychar = YYEMPTY;
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */

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

      YYDPRINTF ((stderr, "Error: popping "));
      YYDSYMPRINT ((stderr,
		    yystos[*yyssp], *yyvsp));
      YYDPRINTF ((stderr, "\n"));

      yydestruct (yystos[yystate], *yyvsp);
      yyvsp--;
      yystate = *--yyssp;


#if YYDEBUG
      if (yydebug)
	{
	  short *yyssp1 = yyss - 1;
	  YYFPRINTF (stderr, "Error: state stack now");
	  while (yyssp1 != yyssp)
	    YYFPRINTF (stderr, " %d", *++yyssp1);
	  YYFPRINTF (stderr, "\n");
	}
#endif
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  YYDPRINTF ((stderr, "Shifting error token, "));

  *++yyvsp = yylval;


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
/*----------------------------------------------.
| yyoverflowlab -- parser overflow comes here.  |
`----------------------------------------------*/
yyoverflowlab:
  yyerror ("parser stack overflow");
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
  return yyresult;
}


#line 1291 "imcc/imcc.y"



int yyerror(char * s)
{
    /* XXX */
    IMCC_fataly(NULL, E_SyntaxError, s);
    /* fprintf(stderr, "last token = [%s]\n", yylval.s); */
    return 0;
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

