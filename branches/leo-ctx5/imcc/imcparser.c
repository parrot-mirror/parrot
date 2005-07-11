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
     ADV_OPT_COUNT = 275,
     NEW = 276,
     NEWSUB = 277,
     NEWCLOSURE = 278,
     NEWCOR = 279,
     NEWCONT = 280,
     NAMESPACE = 281,
     ENDNAMESPACE = 282,
     CLASS = 283,
     ENDCLASS = 284,
     FIELD = 285,
     DOT_METHOD = 286,
     SUB = 287,
     SYM = 288,
     LOCAL = 289,
     CONST = 290,
     INC = 291,
     DEC = 292,
     GLOBAL_CONST = 293,
     PLUS_ASSIGN = 294,
     MINUS_ASSIGN = 295,
     MUL_ASSIGN = 296,
     DIV_ASSIGN = 297,
     CONCAT_ASSIGN = 298,
     BAND_ASSIGN = 299,
     BOR_ASSIGN = 300,
     BXOR_ASSIGN = 301,
     FDIV = 302,
     FDIV_ASSIGN = 303,
     MOD_ASSIGN = 304,
     SHR_ASSIGN = 305,
     SHL_ASSIGN = 306,
     SHR_U_ASSIGN = 307,
     SHIFT_LEFT = 308,
     SHIFT_RIGHT = 309,
     INTV = 310,
     FLOATV = 311,
     STRINGV = 312,
     PMCV = 313,
     OBJECTV = 314,
     LOG_XOR = 315,
     RELOP_EQ = 316,
     RELOP_NE = 317,
     RELOP_GT = 318,
     RELOP_GTE = 319,
     RELOP_LT = 320,
     RELOP_LTE = 321,
     GLOBAL = 322,
     GLOBALOP = 323,
     ADDR = 324,
     RESULT = 325,
     RETURN = 326,
     YIELDT = 327,
     POW = 328,
     SHIFT_RIGHT_U = 329,
     LOG_AND = 330,
     LOG_OR = 331,
     COMMA = 332,
     ESUB = 333,
     DOTDOT = 334,
     PCC_BEGIN = 335,
     PCC_END = 336,
     PCC_CALL = 337,
     PCC_SUB = 338,
     PCC_BEGIN_RETURN = 339,
     PCC_END_RETURN = 340,
     PCC_BEGIN_YIELD = 341,
     PCC_END_YIELD = 342,
     NCI_CALL = 343,
     METH_CALL = 344,
     INVOCANT = 345,
     MAIN = 346,
     LOAD = 347,
     IMMEDIATE = 348,
     POSTCOMP = 349,
     METHOD = 350,
     ANON = 351,
     MULTI = 352,
     LABEL = 353,
     EMIT = 354,
     EOM = 355,
     IREG = 356,
     NREG = 357,
     SREG = 358,
     PREG = 359,
     IDENTIFIER = 360,
     REG = 361,
     MACRO = 362,
     ENDM = 363,
     STRINGC = 364,
     INTC = 365,
     FLOATC = 366,
     USTRINGC = 367,
     PARROT_OP = 368,
     VAR = 369,
     LINECOMMENT = 370,
     FILECOMMENT = 371,
     DOT = 372,
     CONCAT = 373,
     POINTY = 374
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
#define ADV_OPT_COUNT 275
#define NEW 276
#define NEWSUB 277
#define NEWCLOSURE 278
#define NEWCOR 279
#define NEWCONT 280
#define NAMESPACE 281
#define ENDNAMESPACE 282
#define CLASS 283
#define ENDCLASS 284
#define FIELD 285
#define DOT_METHOD 286
#define SUB 287
#define SYM 288
#define LOCAL 289
#define CONST 290
#define INC 291
#define DEC 292
#define GLOBAL_CONST 293
#define PLUS_ASSIGN 294
#define MINUS_ASSIGN 295
#define MUL_ASSIGN 296
#define DIV_ASSIGN 297
#define CONCAT_ASSIGN 298
#define BAND_ASSIGN 299
#define BOR_ASSIGN 300
#define BXOR_ASSIGN 301
#define FDIV 302
#define FDIV_ASSIGN 303
#define MOD_ASSIGN 304
#define SHR_ASSIGN 305
#define SHL_ASSIGN 306
#define SHR_U_ASSIGN 307
#define SHIFT_LEFT 308
#define SHIFT_RIGHT 309
#define INTV 310
#define FLOATV 311
#define STRINGV 312
#define PMCV 313
#define OBJECTV 314
#define LOG_XOR 315
#define RELOP_EQ 316
#define RELOP_NE 317
#define RELOP_GT 318
#define RELOP_GTE 319
#define RELOP_LT 320
#define RELOP_LTE 321
#define GLOBAL 322
#define GLOBALOP 323
#define ADDR 324
#define RESULT 325
#define RETURN 326
#define YIELDT 327
#define POW 328
#define SHIFT_RIGHT_U 329
#define LOG_AND 330
#define LOG_OR 331
#define COMMA 332
#define ESUB 333
#define DOTDOT 334
#define PCC_BEGIN 335
#define PCC_END 336
#define PCC_CALL 337
#define PCC_SUB 338
#define PCC_BEGIN_RETURN 339
#define PCC_END_RETURN 340
#define PCC_BEGIN_YIELD 341
#define PCC_END_YIELD 342
#define NCI_CALL 343
#define METH_CALL 344
#define INVOCANT 345
#define MAIN 346
#define LOAD 347
#define IMMEDIATE 348
#define POSTCOMP 349
#define METHOD 350
#define ANON 351
#define MULTI 352
#define LABEL 353
#define EMIT 354
#define EOM 355
#define IREG 356
#define NREG 357
#define SREG 358
#define PREG 359
#define IDENTIFIER 360
#define REG 361
#define MACRO 362
#define ENDM 363
#define STRINGC 364
#define INTC 365
#define FLOATC 366
#define USTRINGC 367
#define PARROT_OP 368
#define VAR 369
#define LINECOMMENT 370
#define FILECOMMENT 371
#define DOT 372
#define CONCAT 373
#define POINTY 374




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
static SymReg *keys[IMCC_MAX_FIX_REGS]; /* TODO key overflow check */
static int nkeys, in_slice;
static int keyvec;
#define IMCC_MAX_STATIC_REGS 100
static SymReg *regs[IMCC_MAX_STATIC_REGS];
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
    SymReg *r[IMCC_MAX_FIX_REGS];
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
    for (i = 0; i < n; ++i) {
	r[i] = va_arg(ap, SymReg *);
    }
    va_end(ap);
    return INS(interpreter, unit, opname, fmt, r, n, keyvec, 1);
}

static Instruction*
mk_pmc_const(Parrot_Interp interp, IMC_Unit *unit,
        char *type, SymReg *left, char *constant)
{
    int type_enum = atoi(type);
    SymReg *rhs;
    SymReg *r[2];
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
}

Instruction * INS_LABEL(IMC_Unit * unit, SymReg * r0, int emit)
{

    Instruction *ins;

    ins = _mk_instruction("","%s:", 1, &r0, 0);
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
#line 311 "imcc/imcc.y"
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
#line 632 "imcc/imcparser.c"
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
#line 653 "imcc/imcparser.c"

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
#define YYLAST   577

/* YYNTOKENS -- Number of terminals. */
#define YYNTOKENS  136
/* YYNNTS -- Number of nonterminals. */
#define YYNNTS  117
/* YYNRULES -- Number of rules. */
#define YYNRULES  315
/* YYNRULES -- Number of states. */
#define YYNSTATES  525

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   374

#define YYTRANSLATE(X) \
  ((unsigned)(X) <= YYMAXUTOK ? yytranslate[X] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const unsigned char yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       4,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,   126,     2,     2,     2,   132,   133,     2,
     124,   125,   130,   129,     2,   127,     2,   131,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,   135,
       2,   121,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,   122,     2,   123,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,   134,     2,   128,     2,     2,     2,
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
     116,   117,   118,   119,   120
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
     340,   342,   344,   346,   347,   353,   355,   356,   359,   363,
     367,   368,   374,   375,   381,   382,   384,   388,   390,   393,
     394,   397,   400,   402,   404,   405,   407,   410,   412,   414,
     418,   420,   424,   426,   428,   431,   434,   435,   440,   441,
     448,   450,   451,   458,   459,   464,   467,   470,   473,   476,
     479,   482,   485,   486,   490,   493,   495,   497,   499,   500,
     502,   504,   506,   508,   510,   512,   514,   516,   518,   520,
     522,   526,   531,   536,   541,   547,   553,   559,   565,   571,
     577,   583,   589,   595,   601,   607,   613,   619,   625,   631,
     637,   643,   650,   657,   664,   672,   677,   682,   689,   697,
     702,   709,   714,   719,   724,   729,   736,   744,   748,   749,
     759,   761,   763,   767,   771,   775,   779,   783,   787,   791,
     795,   799,   803,   807,   811,   815,   820,   822,   824,   826,
     830,   834,   838,   840,   842,   843,   849,   850,   854,   856,
     859,   860,   863,   865,   869,   871,   878,   885,   890,   895,
     900,   905,   907,   909,   911,   913,   915,   917,   919,   921,
     922,   924,   928,   930,   932,   937,   939,   941,   943,   945,
     947,   949,   951,   953,   955,   957,   958,   961,   963,   967,
     968,   973,   975,   979,   982,   985,   987,   989,   991,   993,
     995,   997,   999,  1001,  1003,  1005
};

/* YYRHS -- A `-1'-separated list of the rules' RHS. */
static const short yyrhs[] =
{
     137,     0,    -1,   138,    -1,   139,    -1,   138,   139,    -1,
     157,    -1,   156,    -1,   144,    -1,   143,    -1,   164,    -1,
     176,    -1,   153,    -1,   108,     4,    -1,   140,    -1,     4,
      -1,     6,   141,     4,    -1,   142,     4,    -1,     7,    -1,
       8,   111,    -1,     9,   110,    78,   110,    -1,    68,   219,
     106,    -1,    68,   219,   106,   121,   251,    -1,    -1,    36,
     145,   219,   106,   121,   251,    -1,    -1,    36,   147,   111,
     243,   121,   110,    -1,   149,    -1,   148,   149,    -1,   207,
     150,     4,    -1,   108,     4,    -1,   117,    -1,   116,    -1,
     156,    -1,   146,    -1,    -1,   151,   114,   152,    -1,    84,
     184,    99,    -1,    -1,   237,    -1,    -1,   100,   154,   155,
     101,    -1,    -1,   148,    -1,    27,   122,   245,   123,    -1,
      -1,    29,   106,   158,     4,   159,    30,    -1,   160,    -1,
      -1,   161,    -1,   160,   161,    -1,   162,    -1,   163,    -1,
       4,    -1,    31,   219,   106,     4,    -1,    32,   106,   106,
       4,    -1,    -1,    -1,    -1,    33,   165,   240,   166,   171,
       4,   167,   168,   175,    79,    -1,    -1,     4,    -1,   168,
     169,     4,    -1,    -1,     5,   170,   219,   106,   192,    -1,
      -1,   171,    78,   185,    -1,   171,    78,   172,    -1,   185,
      -1,   172,    -1,    98,   124,   173,   125,    -1,    -1,   173,
      78,   174,    -1,   174,    -1,    56,    -1,    57,    -1,    59,
      -1,    58,    -1,   106,    -1,    -1,   204,    -1,    -1,    -1,
      -1,    84,   177,   106,   178,   171,     4,   179,   168,   175,
      79,    -1,    -1,    81,     4,   181,   187,   183,   186,   182,
     189,    82,    -1,    -1,   209,     4,    -1,    -1,    91,   244,
       4,    -1,    -1,   185,    -1,   184,    78,   185,    -1,    93,
      -1,    92,    -1,    94,    -1,    95,    -1,    97,    -1,    96,
      -1,    83,   244,    78,   244,     4,    -1,    83,   244,     4,
      -1,    89,   244,     4,    -1,    90,   236,     4,    -1,    90,
     110,     4,    -1,    90,   236,    78,   244,     4,    -1,    90,
     110,    78,   244,     4,    -1,    -1,   187,   188,     4,    -1,
      12,   230,    -1,    -1,   189,   190,     4,    -1,    71,   236,
     192,    -1,    -1,    35,   191,   219,   106,    -1,    -1,   192,
     193,    -1,    19,    -1,    20,    -1,    21,    -1,    85,    -1,
      87,    -1,    86,    -1,    88,    -1,    -1,   194,     4,   197,
     198,   195,    -1,   200,    -1,    -1,   198,     4,    -1,   198,
     199,     4,    -1,    72,   244,   231,    -1,    -1,    72,   124,
     201,   203,   125,    -1,    -1,    73,   124,   202,   203,   125,
      -1,    -1,   244,    -1,   203,    78,   244,    -1,   206,    -1,
     204,   206,    -1,    -1,   205,   210,    -1,   108,     4,    -1,
     117,    -1,   116,    -1,    -1,   208,    -1,   208,   209,    -1,
     209,    -1,    99,    -1,   207,   212,     4,    -1,   106,    -1,
     211,    78,   106,    -1,   221,    -1,   234,    -1,    27,   106,
      -1,    28,   106,    -1,    -1,    35,   213,   219,   211,    -1,
      -1,    36,   214,   219,   106,   121,   251,    -1,   146,    -1,
      -1,    39,   215,   219,   106,   121,   251,    -1,    -1,     5,
     216,   219,   106,    -1,     5,   250,    -1,    71,   244,    -1,
      12,   230,    -1,    72,   244,    -1,    72,   227,    -1,    10,
     242,    -1,    11,   242,    -1,    -1,    23,   217,   152,    -1,
     114,   237,    -1,   227,    -1,   180,    -1,   196,    -1,    -1,
      23,    -1,    24,    -1,    25,    -1,    26,    -1,    56,    -1,
      57,    -1,    58,    -1,    59,    -1,    60,    -1,   220,    -1,
     106,    -1,   236,   121,   244,    -1,   236,   121,   126,   244,
      -1,   236,   121,   127,   244,    -1,   236,   121,   128,   244,
      -1,   236,   121,   244,   129,   244,    -1,   236,   121,   244,
     127,   244,    -1,   236,   121,   244,   130,   244,    -1,   236,
     121,   244,    74,   244,    -1,   236,   121,   244,   131,   244,
      -1,   236,   121,   244,    48,   244,    -1,   236,   121,   244,
     132,   244,    -1,   236,   121,   244,   119,   244,    -1,   236,
     121,   244,    54,   244,    -1,   236,   121,   244,    55,   244,
      -1,   236,   121,   244,    75,   244,    -1,   236,   121,   244,
      76,   244,    -1,   236,   121,   244,    77,   244,    -1,   236,
     121,   244,    61,   244,    -1,   236,   121,   244,   133,   244,
      -1,   236,   121,   244,   134,   244,    -1,   236,   121,   244,
     128,   244,    -1,   236,   121,   244,   122,   245,   123,    -1,
     236,   122,   245,   123,   121,   244,    -1,   236,   121,    22,
     220,    78,   244,    -1,   236,   121,    22,   220,   122,   245,
     123,    -1,   236,   121,    22,   220,    -1,   236,   121,    22,
     244,    -1,   236,   121,    22,   244,    78,   244,    -1,   236,
     121,    22,   244,   122,   245,   123,    -1,   236,   121,   218,
     106,    -1,   236,   121,   218,   106,    78,   106,    -1,   236,
     121,    70,   106,    -1,   236,   121,    69,   252,    -1,    69,
     252,   121,   244,    -1,    22,   236,    78,   244,    -1,    22,
     236,    78,   244,    78,   244,    -1,    22,   236,    78,   244,
     122,   245,   123,    -1,   236,   121,   227,    -1,    -1,   222,
     124,   233,   125,   121,   225,   124,   229,   125,    -1,   223,
      -1,   224,    -1,   236,    40,   244,    -1,   236,    41,   244,
      -1,   236,    42,   244,    -1,   236,    43,   244,    -1,   236,
      50,   244,    -1,   236,    49,   244,    -1,   236,    44,   244,
      -1,   236,    45,   244,    -1,   236,    46,   244,    -1,   236,
      47,   244,    -1,   236,    51,   244,    -1,   236,    52,   244,
      -1,   236,    53,   244,    -1,   236,   121,   114,   152,    -1,
     106,    -1,   110,    -1,   236,    -1,   236,   226,   241,    -1,
     236,   226,   110,    -1,   236,   226,   236,    -1,   120,    -1,
     118,    -1,    -1,   225,   228,   124,   229,   125,    -1,    -1,
     229,    78,   230,    -1,   230,    -1,   244,   231,    -1,    -1,
     231,   232,    -1,    18,    -1,   233,    78,   236,    -1,   236,
      -1,    13,   244,   235,   244,    11,   242,    -1,    14,   244,
     235,   244,    11,   242,    -1,    13,   244,    11,   242,    -1,
      14,   244,    11,   242,    -1,    13,   244,    78,   242,    -1,
      14,   244,    78,   242,    -1,    62,    -1,    63,    -1,    64,
      -1,    65,    -1,    66,    -1,    67,    -1,   115,    -1,   250,
      -1,    -1,   238,    -1,   238,    78,   239,    -1,   239,    -1,
     243,    -1,   236,   122,   245,   123,    -1,   241,    -1,   110,
      -1,   106,    -1,   114,    -1,   106,    -1,   114,    -1,   242,
      -1,   244,    -1,   236,    -1,   251,    -1,    -1,   246,   247,
      -1,   249,    -1,   247,   135,   249,    -1,    -1,   247,    78,
     248,   249,    -1,   244,    -1,   244,    80,   244,    -1,    80,
     244,    -1,   244,    80,    -1,   102,    -1,   103,    -1,   104,
      -1,   105,    -1,   107,    -1,   111,    -1,   112,    -1,   110,
      -1,   113,    -1,   104,    -1,   110,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const unsigned short yyrline[] =
{
       0,   394,   394,   398,   400,   403,   405,   406,   407,   408,
     409,   410,   411,   412,   413,   416,   417,   420,   421,   429,
     440,   447,   456,   455,   461,   460,   464,   466,   469,   471,
     472,   473,   474,   475,   478,   478,   482,   489,   492,   497,
     496,   507,   509,   512,   530,   528,   544,   546,   549,   551,
     554,   556,   557,   560,   574,   592,   598,   603,   590,   608,
     610,   611,   615,   614,   620,   622,   623,   624,   625,   628,
     631,   633,   634,   637,   639,   640,   641,   642,   654,   656,
     660,   662,   668,   659,   675,   673,   704,   706,   709,   711,
     715,   717,   718,   721,   723,   724,   725,   726,   727,   730,
     736,   738,   743,   745,   747,   751,   758,   760,   763,   768,
     770,   773,   775,   775,   779,   781,   784,   786,   787,   791,
     793,   796,   798,   803,   801,   807,   812,   814,   816,   820,
     826,   824,   833,   832,   841,   843,   844,   848,   850,   861,
     865,   868,   869,   870,   873,   875,   878,   880,   883,   889,
     894,   902,   910,   912,   913,   914,   915,   915,   928,   928,
     930,   931,   931,   933,   933,   936,   937,   938,   939,   940,
     944,   945,   946,   946,   949,   952,   953,   954,   955,   958,
     960,   961,   962,   965,   967,   968,   969,   970,   971,   974,
     985,   987,   988,   989,   990,   991,   992,   993,   994,   995,
     996,   997,   998,  1000,  1002,  1004,  1006,  1008,  1010,  1012,
    1014,  1016,  1018,  1020,  1022,  1024,  1026,  1028,  1030,  1032,
    1035,  1042,  1045,  1047,  1051,  1053,  1055,  1058,  1065,  1064,
    1073,  1074,  1077,  1080,  1082,  1084,  1086,  1088,  1090,  1092,
    1094,  1096,  1098,  1100,  1102,  1106,  1114,  1115,  1116,  1121,
    1122,  1123,  1126,  1127,  1132,  1130,  1140,  1142,  1143,  1146,
    1150,  1152,  1155,  1159,  1161,  1164,  1167,  1169,  1171,  1173,
    1175,  1179,  1181,  1182,  1183,  1184,  1185,  1188,  1190,  1193,
    1195,  1198,  1200,  1203,  1205,  1212,  1214,  1217,  1219,  1222,
    1224,  1227,  1229,  1232,  1234,  1237,  1237,  1241,  1243,  1245,
    1245,  1249,  1255,  1258,  1259,  1262,  1264,  1265,  1266,  1267,
    1270,  1272,  1273,  1274,  1277,  1279
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
  "ADV_OPTIONAL", "ADV_OPT_COUNT", "NEW", "NEWSUB", "NEWCLOSURE", 
  "NEWCOR", "NEWCONT", "NAMESPACE", "ENDNAMESPACE", "CLASS", "ENDCLASS", 
  "FIELD", "DOT_METHOD", "SUB", "SYM", "LOCAL", "CONST", "INC", "DEC", 
  "GLOBAL_CONST", "PLUS_ASSIGN", "MINUS_ASSIGN", "MUL_ASSIGN", 
  "DIV_ASSIGN", "CONCAT_ASSIGN", "BAND_ASSIGN", "BOR_ASSIGN", 
  "BXOR_ASSIGN", "FDIV", "FDIV_ASSIGN", "MOD_ASSIGN", "SHR_ASSIGN", 
  "SHL_ASSIGN", "SHR_U_ASSIGN", "SHIFT_LEFT", "SHIFT_RIGHT", "INTV", 
  "FLOATV", "STRINGV", "PMCV", "OBJECTV", "LOG_XOR", "RELOP_EQ", 
  "RELOP_NE", "RELOP_GT", "RELOP_GTE", "RELOP_LT", "RELOP_LTE", "GLOBAL", 
  "GLOBALOP", "ADDR", "RESULT", "RETURN", "YIELDT", "POW", 
  "SHIFT_RIGHT_U", "LOG_AND", "LOG_OR", "COMMA", "ESUB", "DOTDOT", 
  "PCC_BEGIN", "PCC_END", "PCC_CALL", "PCC_SUB", "PCC_BEGIN_RETURN", 
  "PCC_END_RETURN", "PCC_BEGIN_YIELD", "PCC_END_YIELD", "NCI_CALL", 
  "METH_CALL", "INVOCANT", "MAIN", "LOAD", "IMMEDIATE", "POSTCOMP", 
  "METHOD", "ANON", "MULTI", "LABEL", "EMIT", "EOM", "IREG", "NREG", 
  "SREG", "PREG", "IDENTIFIER", "REG", "MACRO", "ENDM", "STRINGC", "INTC", 
  "FLOATC", "USTRINGC", "PARROT_OP", "VAR", "LINECOMMENT", "FILECOMMENT", 
  "DOT", "CONCAT", "POINTY", "'='", "'['", "']'", "'('", "')'", "'!'", 
  "'-'", "'~'", "'+'", "'*'", "'/'", "'%'", "'&'", "'|'", "';'", 
  "$accept", "program", "compilation_units", "compilation_unit", "pragma", 
  "pragma_1", "hll_def", "global", "constdef", "@1", "pmc_const", "@2", 
  "pasmcode", "pasmline", "pasm_inst", "@3", "pasm_args", "emit", "@4", 
  "opt_pasmcode", "class_namespace", "class", "@5", "class_body", 
  "member_decls", "member_decl", "field_decl", "method_decl", "sub", "@6", 
  "@7", "@8", "sub_params", "sub_param", "@9", "sub_proto", "multi", 
  "multi_types", "multi_type", "sub_body", "pcc_sub", "@10", "@11", "@12", 
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
     374,    61,    91,    93,    40,    41,    33,    45,   126,    43,
      42,    47,    37,    38,   124,    59
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const unsigned char yyr1[] =
{
       0,   136,   137,   138,   138,   139,   139,   139,   139,   139,
     139,   139,   139,   139,   139,   140,   140,   141,   141,   142,
     143,   143,   145,   144,   147,   146,   148,   148,   149,   149,
     149,   149,   149,   149,   151,   150,   150,   150,   152,   154,
     153,   155,   155,   156,   158,   157,   159,   159,   160,   160,
     161,   161,   161,   162,   163,   165,   166,   167,   164,   168,
     168,   168,   170,   169,   171,   171,   171,   171,   171,   172,
     173,   173,   173,   174,   174,   174,   174,   174,   175,   175,
     177,   178,   179,   176,   181,   180,   182,   182,   183,   183,
     184,   184,   184,   185,   185,   185,   185,   185,   185,   186,
     186,   186,   186,   186,   186,   186,   187,   187,   188,   189,
     189,   190,   191,   190,   192,   192,   193,   193,   193,   194,
     194,   195,   195,   197,   196,   196,   198,   198,   198,   199,
     201,   200,   202,   200,   203,   203,   203,   204,   204,   205,
     206,   206,   206,   206,   207,   207,   208,   208,   209,   210,
     211,   211,   212,   212,   212,   212,   213,   212,   214,   212,
     212,   215,   212,   216,   212,   212,   212,   212,   212,   212,
     212,   212,   217,   212,   212,   212,   212,   212,   212,   218,
     218,   218,   218,   219,   219,   219,   219,   219,   219,   220,
     221,   221,   221,   221,   221,   221,   221,   221,   221,   221,
     221,   221,   221,   221,   221,   221,   221,   221,   221,   221,
     221,   221,   221,   221,   221,   221,   221,   221,   221,   221,
     221,   221,   221,   221,   221,   221,   221,   221,   222,   221,
     221,   221,   223,   223,   223,   223,   223,   223,   223,   223,
     223,   223,   223,   223,   223,   224,   225,   225,   225,   225,
     225,   225,   226,   226,   228,   227,   229,   229,   229,   230,
     231,   231,   232,   233,   233,   234,   234,   234,   234,   234,
     234,   235,   235,   235,   235,   235,   235,   236,   236,   237,
     237,   238,   238,   239,   239,   240,   240,   241,   241,   242,
     242,   243,   243,   244,   244,   246,   245,   247,   247,   248,
     247,   249,   249,   249,   249,   250,   250,   250,   250,   250,
     251,   251,   251,   251,   252,   252
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
       1,     1,     1,     0,     5,     1,     0,     2,     3,     3,
       0,     5,     0,     5,     0,     1,     3,     1,     2,     0,
       2,     2,     1,     1,     0,     1,     2,     1,     1,     3,
       1,     3,     1,     1,     2,     2,     0,     4,     0,     6,
       1,     0,     6,     0,     4,     2,     2,     2,     2,     2,
       2,     2,     0,     3,     2,     1,     1,     1,     0,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       3,     4,     4,     4,     5,     5,     5,     5,     5,     5,
       5,     5,     5,     5,     5,     5,     5,     5,     5,     5,
       5,     6,     6,     6,     7,     4,     4,     6,     7,     4,
       6,     4,     4,     4,     4,     6,     7,     3,     0,     9,
       1,     1,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     4,     1,     1,     1,     3,
       3,     3,     1,     1,     0,     5,     0,     3,     1,     2,
       0,     2,     1,     3,     1,     6,     6,     4,     4,     4,
       4,     1,     1,     1,     1,     1,     1,     1,     1,     0,
       1,     3,     1,     1,     4,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     0,     2,     1,     3,     0,
       4,     1,     3,     2,     2,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const unsigned short yydefact[] =
{
       0,    14,     0,     0,     0,     0,    55,    22,     0,    80,
      39,     0,     0,     2,     3,    13,     0,     8,     7,    11,
       6,     5,     9,    10,    17,     0,     0,     0,   295,    44,
       0,     0,   183,   184,   185,   186,   187,   189,     0,   188,
       0,   144,    12,     1,     4,    16,    18,    15,     0,     0,
       0,     0,   287,   286,   288,    56,   285,     0,    20,    81,
      24,   148,     0,    31,    30,    33,   144,    26,     0,    32,
      34,   145,   147,    19,    43,     0,   305,   306,   307,   308,
     309,   312,   310,   311,   313,   277,   293,   301,   296,   297,
     278,   294,    47,    64,     0,     0,    64,     0,    29,    27,
      40,    90,     0,     0,   146,   303,   304,   299,     0,    52,
       0,     0,     0,    46,    48,    50,    51,    94,    93,    95,
      96,    98,    97,     0,     0,    68,    67,     0,    21,     0,
       0,     0,    91,    28,   279,   302,     0,   298,     0,     0,
      45,    49,    70,    57,     0,    23,    82,   289,   290,   291,
       0,   292,     0,    36,    35,   293,    38,   280,   282,   283,
     300,     0,     0,    73,    74,    76,    75,    77,     0,    72,
      59,    66,    65,    59,     0,    92,   295,     0,    53,    54,
       0,    69,    60,   139,   139,    25,     0,   281,    71,    62,
       0,   143,   142,     0,     0,   139,   144,   137,     0,   284,
       0,   141,    61,    58,   138,   178,   140,    83,     0,   163,
       0,     0,     0,     0,     0,     0,   172,     0,     0,   156,
     158,   161,     0,     0,     0,     0,     0,   119,   120,   246,
     247,   279,   160,   176,     0,   177,   125,     0,   152,     0,
     230,   231,   254,   175,   153,   248,   114,     0,   165,   170,
     171,   167,   260,     0,     0,     0,   279,   154,   155,     0,
       0,     0,   314,   315,     0,   166,   312,   130,   169,   293,
     168,   132,    84,   174,   123,   149,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   253,   252,     0,   295,     0,    63,     0,   259,     0,
     271,   272,   273,   274,   275,   276,     0,     0,     0,     0,
       0,     0,   173,     0,     0,     0,     0,   134,   134,   106,
     126,     0,   264,   256,   232,   233,   234,   235,   238,   239,
     240,   241,   237,   236,   242,   243,   244,     0,   179,   180,
     181,   182,     0,     0,   279,     0,     0,     0,     0,   227,
     190,     0,   250,   251,   249,   116,   117,   118,   115,   164,
     262,   261,   267,   269,     0,   268,   270,     0,   224,   150,
     157,     0,     0,   223,     0,   135,     0,    88,     0,     0,
       0,     0,   258,   215,   216,   222,   221,   245,   191,   192,
     193,   219,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   295,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   295,     0,     0,     0,     0,   131,
     133,     0,     0,     0,     0,   127,     0,   121,   122,   124,
       0,   263,     0,     0,   255,     0,   295,     0,   295,     0,
     199,   202,   203,   207,   197,   204,   205,   206,   201,     0,
     195,   210,   194,   196,   198,   200,   208,   209,     0,   265,
     266,   225,     0,   151,   159,   162,   136,   108,     0,     0,
       0,     0,    86,   107,   260,   128,     0,   248,   257,   213,
       0,   217,     0,   220,   211,   212,   226,    89,     0,     0,
       0,     0,   109,     0,   129,   256,   214,   218,   100,     0,
     101,   103,     0,   102,     0,     0,    87,     0,     0,     0,
       0,   112,     0,    85,     0,   229,    99,   105,   104,     0,
     114,   110,     0,   111,   113
};

/* YYDEFGOTO[NTERM-NUM]. */
static const short yydefgoto[] =
{
      -1,    12,    13,    14,    15,    26,    16,    17,    18,    31,
      65,    97,    66,    67,   102,   103,   154,    19,    41,    68,
      20,    21,    51,   112,   113,   114,   115,   116,    22,    30,
      93,   170,   183,   193,   200,   124,   125,   168,   169,   194,
      23,    40,    96,   173,   233,   319,   492,   423,   131,   126,
     472,   377,   424,   505,   514,   519,   296,   358,   234,   429,
     235,   320,   378,   430,   236,   317,   318,   374,   195,   196,
     197,    70,    71,    72,   206,   370,   237,   259,   260,   261,
     247,   256,   348,    38,    39,   238,   239,   240,   241,   242,
     295,   243,   277,   381,   382,   298,   361,   321,   244,   307,
      86,   156,   157,   158,    55,    56,   149,   159,   151,    49,
      50,    88,   136,    89,    90,    91,   264
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -250
static const short yypact[] =
{
       8,  -250,    73,   -41,    -7,   -58,  -250,  -250,    68,  -250,
    -250,   147,    91,     8,  -250,  -250,   148,  -250,  -250,  -250,
    -250,  -250,  -250,  -250,  -250,    52,   166,    94,  -250,  -250,
     -68,    68,  -250,  -250,  -250,  -250,  -250,  -250,    67,  -250,
      69,    63,  -250,  -250,  -250,  -250,  -250,  -250,    79,    59,
     107,   179,  -250,  -250,  -250,  -250,  -250,    85,    76,  -250,
    -250,  -250,   190,  -250,  -250,  -250,    87,  -250,   100,  -250,
       4,   103,  -250,  -250,  -250,   448,  -250,  -250,  -250,  -250,
    -250,  -250,  -250,  -250,  -250,  -250,  -250,   125,   -63,  -250,
    -250,  -250,   153,   199,   102,   176,   199,    97,  -250,  -250,
    -250,   299,   211,   110,  -250,  -250,   448,  -250,   107,  -250,
      68,   115,   196,   153,  -250,  -250,  -250,  -250,  -250,  -250,
    -250,  -250,  -250,   121,     7,  -250,  -250,   176,  -250,     9,
     331,   -35,  -250,  -250,   331,  -250,   107,  -250,   141,   142,
    -250,  -250,   -33,  -250,   199,  -250,  -250,  -250,  -250,  -250,
     106,  -250,   299,  -250,  -250,   134,  -250,   180,  -250,  -250,
    -250,   255,   257,  -250,  -250,  -250,  -250,  -250,   -48,  -250,
     258,  -250,  -250,   258,   155,  -250,  -250,   331,  -250,  -250,
     -33,  -250,  -250,     5,     5,  -250,   144,  -250,  -250,  -250,
     264,  -250,  -250,   274,   203,   -50,   103,  -250,   204,  -250,
      68,  -250,  -250,  -250,  -250,   393,  -250,  -250,   195,   265,
     -74,   -74,   448,   448,   448,   229,  -250,   210,   223,  -250,
     224,  -250,    49,   448,   215,   186,   334,  -250,  -250,  -250,
    -250,   331,  -250,  -250,   339,  -250,  -250,   350,  -250,   239,
    -250,  -250,  -250,  -250,  -250,   262,  -250,    68,  -250,  -250,
    -250,  -250,  -250,    82,   188,   286,   331,  -250,  -250,    68,
      68,    68,  -250,  -250,   244,  -250,   249,  -250,  -250,    72,
    -250,  -250,  -250,  -250,  -250,  -250,   229,   253,   448,   448,
     448,   448,   448,   448,   448,   448,   448,   448,   448,   448,
     448,  -250,  -250,    28,  -250,   425,   321,   272,   363,   -74,
    -250,  -250,  -250,  -250,  -250,  -250,   -74,   448,   -74,   -74,
     448,   448,  -250,   279,   281,   283,   448,   448,   448,  -250,
    -250,   -42,  -250,   448,  -250,  -250,  -250,  -250,  -250,  -250,
    -250,  -250,  -250,  -250,  -250,  -250,  -250,   408,  -250,  -250,
    -250,  -250,    49,   291,   331,   448,   448,   448,   293,  -250,
     415,   277,  -250,  -250,  -250,  -250,  -250,  -250,  -250,  -250,
    -250,  -250,  -250,  -250,   390,  -250,  -250,   397,   -62,  -250,
     332,   288,   292,  -250,   -16,  -250,   -13,    15,    14,   229,
     297,    -8,  -250,    -4,    -3,  -250,  -250,  -250,  -250,  -250,
    -250,   336,   448,   448,   448,   448,   448,   448,   448,   448,
     448,  -250,   448,   448,   448,   448,   448,   448,   448,   448,
     298,   -74,   -74,   448,  -250,   306,   176,   176,   448,  -250,
    -250,   448,   448,   -34,   420,  -250,   448,  -250,  -250,  -250,
     421,  -250,   462,   448,  -250,   448,  -250,   448,  -250,   320,
    -250,  -250,  -250,  -250,  -250,  -250,  -250,  -250,  -250,   304,
    -250,  -250,  -250,  -250,  -250,  -250,  -250,  -250,   448,  -250,
    -250,  -250,   307,  -250,  -250,  -250,  -250,  -250,   427,   448,
     448,   170,   103,  -250,  -250,  -250,   315,   -73,  -250,  -250,
     317,  -250,   324,  -250,  -250,  -250,  -250,  -250,    18,   445,
      27,    29,  -250,   446,   363,   448,  -250,  -250,  -250,   448,
    -250,  -250,   448,  -250,   448,   -14,  -250,    33,   447,   449,
     450,  -250,   229,  -250,   452,  -250,  -250,  -250,  -250,    68,
    -250,  -250,   352,   321,  -250
};

/* YYPGOTO[NTERM-NUM].  */
static const short yypgoto[] =
{
    -250,  -250,  -250,   454,  -250,  -250,  -250,  -250,  -250,  -250,
     254,  -250,  -250,   394,  -250,  -250,  -249,  -250,  -250,  -250,
     127,  -250,  -250,  -250,  -250,   348,  -250,  -250,  -250,  -250,
    -250,  -250,   295,  -250,  -250,   375,   328,  -250,   301,   289,
    -250,  -250,  -250,  -250,  -250,  -250,  -250,  -250,  -250,   -81,
    -250,  -250,  -250,  -250,  -250,  -250,   -45,  -250,  -250,  -250,
    -250,  -250,  -250,  -250,  -250,  -250,  -250,   159,  -250,  -250,
     284,   287,  -250,   -70,  -250,  -250,  -250,  -250,  -250,  -250,
    -250,  -250,  -250,   -31,   145,  -250,  -250,  -250,  -250,    53,
    -250,  -215,  -250,   -11,  -208,    12,  -250,  -250,  -250,   233,
     -95,   263,  -250,   316,  -250,   206,  -205,   372,   -47,  -157,
    -250,  -250,  -250,    42,   296,   -93,   162
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, parse error.  */
#define YYTABLE_NINF -249
static const short yytable[] =
{
      57,   104,   128,    87,   251,   249,   250,   312,   -37,   268,
     189,   143,     1,   146,     2,   107,   413,     3,   425,   186,
     132,   511,   498,   163,   164,   165,   166,   421,   105,   -79,
     180,   501,   147,   503,   145,     4,   379,     5,    52,   155,
     148,     6,    53,   152,     7,   291,    54,   292,    29,   469,
     337,   338,   339,   340,   341,   470,   471,   512,   190,   135,
     414,    87,   418,   172,   153,   418,   191,   192,   513,    27,
     433,   175,   108,   167,   435,   437,     8,   181,   349,   138,
      24,    25,   155,   380,   -78,   144,   426,   144,   101,    87,
       4,    43,     9,   299,   362,   387,   499,   342,   343,    60,
     427,   363,   428,   365,   366,   502,   422,   504,    10,   419,
     245,   433,   420,   190,     4,    28,    11,   434,   436,   438,
     255,   191,   192,    60,    32,    33,    34,    35,    36,   269,
      76,    77,    78,    79,   229,    80,   155,   351,   266,    82,
      83,    84,   344,    85,   300,   301,   302,   303,   304,   305,
     137,    42,    45,   262,   345,   346,   347,   109,   515,   263,
     306,   155,    61,    46,   -41,   252,   253,   254,    69,   208,
      47,    62,    48,    58,    37,    59,   265,   270,   160,    63,
      64,   322,    74,    92,   110,   111,    61,    75,   -42,    73,
     291,    94,   292,    69,    98,    62,  -248,    95,   269,   308,
     353,   100,    61,    63,    64,   106,   459,   460,   130,    76,
      77,    78,    79,   467,    80,   133,   297,    81,    82,    83,
      84,   139,    85,   127,   134,   478,   140,   174,   313,   314,
     315,   324,   325,   326,   327,   328,   329,   330,   331,   332,
     333,   334,   335,   336,   449,   142,   350,   161,   162,   155,
     300,   301,   302,   303,   304,   305,   176,   462,   177,   178,
     364,   179,   182,   367,   368,   185,   309,   199,   201,   373,
     375,   375,    76,    77,    78,    79,   252,    80,   202,   480,
     490,   482,   203,   207,   431,    85,    81,    82,    83,    84,
     384,   117,   118,   119,   120,   121,   122,   123,   388,   389,
     390,   246,   278,   279,   280,   281,   282,   283,   284,   285,
     271,   286,   287,   288,   289,   290,   257,    76,    77,    78,
      79,   229,    80,   464,   465,   266,    82,    83,    84,   258,
      85,    76,    77,    78,    79,   -24,    80,   477,   272,   267,
     355,   356,   357,   274,    85,   440,   441,   442,   443,   444,
     445,   446,   447,   448,   275,   450,   451,   452,   453,   454,
     455,   456,   457,   276,   311,   316,   461,    76,    77,    78,
      79,   466,    80,  -247,   252,   468,   491,   323,   359,   474,
     291,   360,   292,   293,   294,   369,   252,   371,   479,   372,
     481,   117,   118,   119,   120,   121,   122,   386,   209,   391,
     410,   411,   493,   210,   211,   212,   213,   214,   412,   416,
     415,   485,   463,   417,   439,   215,   216,   520,   432,   458,
     217,   218,   488,   489,   473,   475,   483,   484,   219,   220,
     486,   487,   221,    76,    77,    78,    79,   147,    80,   495,
     496,    81,    82,    83,    84,   148,    85,   497,   252,   500,
     506,   516,   508,   517,   518,   509,   521,   510,   524,   232,
      99,   141,   222,   392,   223,   224,   225,    44,   184,   393,
     394,   129,   171,   198,   226,   523,   395,   376,   227,   204,
     228,   188,   383,   205,   507,   476,   494,   310,   522,   396,
     397,   398,   399,   187,   273,    76,    77,    78,    79,   229,
      80,   354,   150,   230,   385,   248,     0,   231,    85,     0,
      76,    77,    78,    79,    37,    80,     0,  -228,    81,    82,
      83,    84,     0,    85,     0,     0,     0,    76,    77,    78,
      79,    52,    80,     0,   400,   352,     0,   401,     0,    54,
      85,     0,   402,   403,   404,   405,   406,   407,   408,   409,
      76,    77,    78,    79,     0,    80,     0,     0,    81,    82,
      83,    84,     0,    85,    76,    77,    78,    79,   229,    80,
       0,     0,   230,     0,     0,     0,     0,    85
};

static const short yycheck[] =
{
      31,    71,    95,    50,   212,   210,   211,   256,     4,   224,
       5,     4,     4,     4,     6,    78,    78,     9,     4,   176,
     101,    35,     4,    56,    57,    58,    59,    12,    75,    79,
      78,     4,   106,     4,   127,    27,    78,    29,   106,   134,
     114,    33,   110,    78,    36,   118,   114,   120,   106,    83,
      22,    23,    24,    25,    26,    89,    90,    71,   108,   106,
     122,   108,    78,   144,    99,    78,   116,   117,    82,   110,
      78,   152,   135,   106,    78,    78,    68,   125,   293,   110,
       7,     8,   177,   125,    79,    78,    72,    78,    84,   136,
      27,     0,    84,    11,   299,   344,    78,    69,    70,    36,
      86,   306,    88,   308,   309,    78,    91,    78,   100,   125,
     205,    78,   125,   108,    27,   122,   108,   125,   122,   122,
     215,   116,   117,    36,    56,    57,    58,    59,    60,   224,
     102,   103,   104,   105,   106,   107,   231,   294,   110,   111,
     112,   113,   114,   115,    62,    63,    64,    65,    66,    67,
     108,     4,     4,   104,   126,   127,   128,     4,   125,   110,
      78,   256,    99,   111,   101,   212,   213,   214,    41,   200,
       4,   108,    78,   106,   106,   106,   223,   224,   136,   116,
     117,   276,   123,     4,    31,    32,    99,    80,   101,   110,
     118,   106,   120,    66,     4,   108,   124,   121,   293,    11,
     295,   101,    99,   116,   117,    80,   411,   412,   111,   102,
     103,   104,   105,   421,   107,     4,   247,   110,   111,   112,
     113,   106,   115,   121,   114,   433,    30,   121,   259,   260,
     261,   278,   279,   280,   281,   282,   283,   284,   285,   286,
     287,   288,   289,   290,   401,   124,   293,   106,   106,   344,
      62,    63,    64,    65,    66,    67,   122,   414,    78,     4,
     307,     4,     4,   310,   311,   110,    78,   123,     4,   316,
     317,   318,   102,   103,   104,   105,   323,   107,     4,   436,
     110,   438,    79,    79,   379,   115,   110,   111,   112,   113,
     337,    92,    93,    94,    95,    96,    97,    98,   345,   346,
     347,   106,    40,    41,    42,    43,    44,    45,    46,    47,
     124,    49,    50,    51,    52,    53,   106,   102,   103,   104,
     105,   106,   107,   416,   417,   110,   111,   112,   113,   106,
     115,   102,   103,   104,   105,   111,   107,   432,     4,   124,
      19,    20,    21,     4,   115,   392,   393,   394,   395,   396,
     397,   398,   399,   400,     4,   402,   403,   404,   405,   406,
     407,   408,   409,   124,    78,   121,   413,   102,   103,   104,
     105,   418,   107,   124,   421,   422,   471,   124,   106,   426,
     118,    18,   120,   121,   122,   106,   433,   106,   435,   106,
     437,    92,    93,    94,    95,    96,    97,   106,     5,   106,
     123,    11,   472,    10,    11,    12,    13,    14,    11,   121,
      78,   458,   106,   121,    78,    22,    23,   512,   121,   121,
      27,    28,   469,   470,     4,     4,   106,   123,    35,    36,
     123,     4,    39,   102,   103,   104,   105,   106,   107,   124,
     123,   110,   111,   112,   113,   114,   115,   123,   495,     4,
       4,     4,   499,     4,     4,   502,     4,   504,   106,   205,
      66,   113,    69,    48,    71,    72,    73,    13,   173,    54,
      55,    96,   144,   184,    81,   520,    61,   318,    85,   195,
      87,   180,   337,   196,   495,   432,   474,   254,   519,    74,
      75,    76,    77,   177,   231,   102,   103,   104,   105,   106,
     107,   295,   130,   110,   342,   209,    -1,   114,   115,    -1,
     102,   103,   104,   105,   106,   107,    -1,   124,   110,   111,
     112,   113,    -1,   115,    -1,    -1,    -1,   102,   103,   104,
     105,   106,   107,    -1,   119,   110,    -1,   122,    -1,   114,
     115,    -1,   127,   128,   129,   130,   131,   132,   133,   134,
     102,   103,   104,   105,    -1,   107,    -1,    -1,   110,   111,
     112,   113,    -1,   115,   102,   103,   104,   105,   106,   107,
      -1,    -1,   110,    -1,    -1,    -1,    -1,   115
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const unsigned char yystos[] =
{
       0,     4,     6,     9,    27,    29,    33,    36,    68,    84,
     100,   108,   137,   138,   139,   140,   142,   143,   144,   153,
     156,   157,   164,   176,     7,     8,   141,   110,   122,   106,
     165,   145,    56,    57,    58,    59,    60,   106,   219,   220,
     177,   154,     4,     0,   139,     4,   111,     4,    78,   245,
     246,   158,   106,   110,   114,   240,   241,   219,   106,   106,
      36,    99,   108,   116,   117,   146,   148,   149,   155,   156,
     207,   208,   209,   110,   123,    80,   102,   103,   104,   105,
     107,   110,   111,   112,   113,   115,   236,   244,   247,   249,
     250,   251,     4,   166,   106,   121,   178,   147,     4,   149,
     101,    84,   150,   151,   209,   244,    80,    78,   135,     4,
      31,    32,   159,   160,   161,   162,   163,    92,    93,    94,
      95,    96,    97,    98,   171,   172,   185,   121,   251,   171,
     111,   184,   185,     4,   114,   244,   248,   249,   219,   106,
      30,   161,   124,     4,    78,   251,     4,   106,   114,   242,
     243,   244,    78,    99,   152,   236,   237,   238,   239,   243,
     249,   106,   106,    56,    57,    58,    59,   106,   173,   174,
     167,   172,   185,   179,   121,   185,   122,    78,     4,     4,
      78,   125,     4,   168,   168,   110,   245,   239,   174,     5,
     108,   116,   117,   169,   175,   204,   205,   206,   175,   123,
     170,     4,     4,    79,   206,   207,   210,    79,   219,     5,
      10,    11,    12,    13,    14,    22,    23,    27,    28,    35,
      36,    39,    69,    71,    72,    73,    81,    85,    87,   106,
     110,   114,   146,   180,   194,   196,   200,   212,   221,   222,
     223,   224,   225,   227,   234,   236,   106,   216,   250,   242,
     242,   230,   244,   244,   244,   236,   217,   106,   106,   213,
     214,   215,   104,   110,   252,   244,   110,   124,   227,   236,
     244,   124,     4,   237,     4,     4,   124,   228,    40,    41,
      42,    43,    44,    45,    46,    47,    49,    50,    51,    52,
      53,   118,   120,   121,   122,   226,   192,   219,   231,    11,
      62,    63,    64,    65,    66,    67,    78,   235,    11,    78,
     235,    78,   152,   219,   219,   219,   121,   201,   202,   181,
     197,   233,   236,   124,   244,   244,   244,   244,   244,   244,
     244,   244,   244,   244,   244,   244,   244,    22,    23,    24,
      25,    26,    69,    70,   114,   126,   127,   128,   218,   227,
     244,   245,   110,   236,   241,    19,    20,    21,   193,   106,
      18,   232,   242,   242,   244,   242,   242,   244,   244,   106,
     211,   106,   106,   244,   203,   244,   203,   187,   198,    78,
     125,   229,   230,   220,   244,   252,   106,   152,   244,   244,
     244,   106,    48,    54,    55,    61,    74,    75,    76,    77,
     119,   122,   127,   128,   129,   130,   131,   132,   133,   134,
     123,    11,    11,    78,   122,    78,   121,   121,    78,   125,
     125,    12,    91,   183,   188,     4,    72,    86,    88,   195,
     199,   236,   121,    78,   125,    78,   122,    78,   122,    78,
     244,   244,   244,   244,   244,   244,   244,   244,   244,   245,
     244,   244,   244,   244,   244,   244,   244,   244,   121,   242,
     242,   244,   245,   106,   251,   251,   244,   230,   244,    83,
      89,    90,   186,     4,   244,     4,   225,   236,   230,   244,
     245,   244,   245,   106,   123,   244,   123,     4,   244,   244,
     110,   236,   182,   209,   231,   124,   123,   123,     4,    78,
       4,     4,    78,     4,    78,   189,     4,   229,   244,   244,
     244,    35,    71,    82,   190,   125,     4,     4,     4,   191,
     236,     4,   219,   192,   106
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
#line 395 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 5:
#line 404 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; cur_unit = 0; }
    break;

  case 6:
#line 405 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; }
    break;

  case 7:
#line 406 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; }
    break;

  case 8:
#line 407 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; }
    break;

  case 9:
#line 408 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; imc_close_unit(interp, cur_unit); cur_unit = 0; }
    break;

  case 10:
#line 409 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; imc_close_unit(interp, cur_unit); cur_unit = 0; }
    break;

  case 11:
#line 410 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; imc_close_unit(interp, cur_unit); cur_unit = 0; }
    break;

  case 12:
#line 411 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 13:
#line 412 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 14:
#line 413 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 15:
#line 416 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 16:
#line 417 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 17:
#line 420 "imcc/imcc.y"
    { IMCC_INFO(interp)->state->pragmas |= PR_FASTCALL; }
    break;

  case 18:
#line 422 "imcc/imcc.y"
    { if (yyvsp[0].s)
                          IMCC_INFO(interp)->state->pragmas |= PR_N_OPERATORS;
                      else
                          IMCC_INFO(interp)->state->pragmas &= ~PR_N_OPERATORS;
                    }
    break;

  case 19:
#line 430 "imcc/imcc.y"
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
#line 442 "imcc/imcc.y"
    {
            IMCC_fataly(interp, E_SyntaxError,
                ".global not implemented yet\n");
            yyval.i = 0;
         }
    break;

  case 21:
#line 448 "imcc/imcc.y"
    {
            IMCC_fataly(interp, E_SyntaxError,
                ".global not implemented yet\n");
            yyval.i = 0;
         }
    break;

  case 22:
#line 456 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 23:
#line 457 "imcc/imcc.y"
    { mk_const_ident(interp, yyvsp[-2].s, yyvsp[-3].t, yyvsp[0].sr, 1);is_def=0; }
    break;

  case 24:
#line 461 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 25:
#line 462 "imcc/imcc.y"
    { yyval.i = mk_pmc_const(interp, cur_unit, yyvsp[-3].s, yyvsp[-2].sr, yyvsp[0].s);is_def=0; }
    break;

  case 28:
#line 470 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 29:
#line 471 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 30:
#line 472 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 31:
#line 473 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 32:
#line 474 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; }
    break;

  case 34:
#line 478 "imcc/imcc.y"
    { clear_state(); }
    break;

  case 35:
#line 480 "imcc/imcc.y"
    { yyval.i = INS(interp, cur_unit, yyvsp[-1].s,0,regs,nargs,keyvec,1);
                     free(yyvsp[-1].s); }
    break;

  case 36:
#line 483 "imcc/imcc.y"
    {
                     yyval.i = iSUBROUTINE(cur_unit, mk_sub_label(interp, yyvsp[0].s));
                     yyval.i->r[1] = mk_pcc_sub(interp, str_dup(yyval.i->r[0]->name), 0);
                     add_namespace(interp, cur_unit);
                     yyval.i->r[1]->pcc_sub->pragma = yyvsp[-1].t;
                   }
    break;

  case 37:
#line 489 "imcc/imcc.y"
    { yyval.i = 0;}
    break;

  case 39:
#line 497 "imcc/imcc.y"
    { cur_unit = imc_open_unit(interp, IMC_PASM); }
    break;

  case 40:
#line 499 "imcc/imcc.y"
    { /*
                      if (optimizer_level & OPT_PASM)
                         imc_compile_unit(interp, IMCC_INFO(interp)->cur_unit);
                         emit_flush(interp);
                     */
                     yyval.i=0; }
    break;

  case 43:
#line 514 "imcc/imcc.y"
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
#line 530 "imcc/imcc.y"
    {
                      Symbol * sym = new_symbol(yyvsp[0].s);
                      cur_unit = imc_open_unit(interp, IMC_CLASS);
                      current_class = new_class(sym);
                      sym->p = (void*)current_class;
                      store_symbol(&global_sym_tab, sym); }
    break;

  case 45:
#line 537 "imcc/imcc.y"
    {
                      /* Do nothing for now. Need to parse metadata for
                       * PBC creation. */
                      current_class = NULL;
                      yyval.i = 0; }
    break;

  case 47:
#line 546 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 52:
#line 557 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 53:
#line 562 "imcc/imcc.y"
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
#line 576 "imcc/imcc.y"
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
#line 592 "imcc/imcc.y"
    {
           cur_unit = (IMCC_INFO(interp)->state->pragmas & PR_FASTCALL ?
                  imc_open_unit(interp, IMC_FASTSUB)
                : imc_open_unit(interp, IMC_PCCSUB));
        }
    break;

  case 56:
#line 598 "imcc/imcc.y"
    {
          Instruction *i = iSUBROUTINE(cur_unit, yyvsp[0].sr);
          i->r[1] = cur_call = mk_pcc_sub(interp, str_dup(i->r[0]->name), 0);
          add_namespace(interp, cur_unit);
        }
    break;

  case 57:
#line 603 "imcc/imcc.y"
    { cur_call->pcc_sub->pragma = yyvsp[-1].t; }
    break;

  case 58:
#line 605 "imcc/imcc.y"
    { yyval.i = 0; cur_call = NULL; }
    break;

  case 59:
#line 609 "imcc/imcc.y"
    { yyval.sr = 0; }
    break;

  case 60:
#line 610 "imcc/imcc.y"
    { yyval.sr = 0; }
    break;

  case 61:
#line 611 "imcc/imcc.y"
    { add_pcc_param(cur_call, yyvsp[-1].sr);}
    break;

  case 62:
#line 615 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 63:
#line 616 "imcc/imcc.y"
    { yyval.sr = mk_ident(interp, yyvsp[-1].s, yyvsp[-2].t);
                                         is_def=0; yyval.sr->type |= yyvsp[0].t; }
    break;

  case 64:
#line 621 "imcc/imcc.y"
    { yyval.t = 0;  }
    break;

  case 65:
#line 622 "imcc/imcc.y"
    { yyval.t = yyvsp[-2].t | yyvsp[0].t; }
    break;

  case 66:
#line 623 "imcc/imcc.y"
    { yyval.t = yyvsp[-2].t | yyvsp[0].t; }
    break;

  case 67:
#line 624 "imcc/imcc.y"
    { yyval.t = yyvsp[0].t; }
    break;

  case 68:
#line 625 "imcc/imcc.y"
    { yyval.t = yyvsp[0].t; }
    break;

  case 69:
#line 628 "imcc/imcc.y"
    { yyval.t = 0; }
    break;

  case 70:
#line 632 "imcc/imcc.y"
    { yyval.t = 0; }
    break;

  case 71:
#line 633 "imcc/imcc.y"
    { yyval.t = 0; add_pcc_multi(cur_call, yyvsp[0].sr); }
    break;

  case 72:
#line 634 "imcc/imcc.y"
    { yyval.t = 0;  add_pcc_multi(cur_call, yyvsp[0].sr);}
    break;

  case 73:
#line 638 "imcc/imcc.y"
    { yyval.sr = mk_const(interp, str_dup("INTVAL"), 'S'); }
    break;

  case 74:
#line 639 "imcc/imcc.y"
    { yyval.sr = mk_const(interp, str_dup("FLOATVAL"), 'S'); }
    break;

  case 75:
#line 640 "imcc/imcc.y"
    { yyval.sr = mk_const(interp, str_dup("PMC"), 'S'); }
    break;

  case 76:
#line 641 "imcc/imcc.y"
    { yyval.sr = mk_const(interp, str_dup("STRING"), 'S'); }
    break;

  case 77:
#line 642 "imcc/imcc.y"
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
#line 660 "imcc/imcc.y"
    { cur_unit = imc_open_unit(interp, IMC_PCCSUB); }
    break;

  case 81:
#line 662 "imcc/imcc.y"
    {
            Instruction *i = iSUBROUTINE(cur_unit, mk_sub_label(interp, yyvsp[0].s));
            i->r[1] = cur_call = mk_pcc_sub(interp, str_dup(i->r[0]->name), 0);
            add_namespace(interp, cur_unit);

         }
    break;

  case 82:
#line 668 "imcc/imcc.y"
    { cur_call->pcc_sub->pragma = yyvsp[-1].t; }
    break;

  case 83:
#line 670 "imcc/imcc.y"
    { yyval.i = 0; cur_call = NULL; }
    break;

  case 84:
#line 675 "imcc/imcc.y"
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
#line 701 "imcc/imcc.y"
    { yyval.i = 0; current_call = NULL; }
    break;

  case 86:
#line 705 "imcc/imcc.y"
    { yyval.i = NULL;  current_call->r[0]->pcc_sub->label = 0; }
    break;

  case 87:
#line 706 "imcc/imcc.y"
    { yyval.i = NULL;  current_call->r[0]->pcc_sub->label = 1; }
    break;

  case 88:
#line 710 "imcc/imcc.y"
    { yyval.i = NULL; }
    break;

  case 89:
#line 712 "imcc/imcc.y"
    { yyval.i = NULL;  current_call->r[0]->pcc_sub->object = yyvsp[-1].sr; }
    break;

  case 90:
#line 716 "imcc/imcc.y"
    { yyval.t = 0; }
    break;

  case 91:
#line 717 "imcc/imcc.y"
    { yyval.t = yyvsp[0].t; }
    break;

  case 92:
#line 718 "imcc/imcc.y"
    { yyval.t = yyvsp[-2].t | yyvsp[0].t; }
    break;

  case 93:
#line 722 "imcc/imcc.y"
    {  yyval.t = P_LOAD; }
    break;

  case 94:
#line 723 "imcc/imcc.y"
    {  yyval.t = P_MAIN; }
    break;

  case 95:
#line 724 "imcc/imcc.y"
    {  yyval.t = P_IMMEDIATE; }
    break;

  case 96:
#line 725 "imcc/imcc.y"
    {  yyval.t = P_POSTCOMP; }
    break;

  case 97:
#line 726 "imcc/imcc.y"
    {  yyval.t = P_ANON; }
    break;

  case 98:
#line 727 "imcc/imcc.y"
    {  yyval.t = P_METHOD; }
    break;

  case 99:
#line 732 "imcc/imcc.y"
    {
            add_pcc_sub(current_call->r[0], yyvsp[-3].sr);
            add_pcc_cc(current_call->r[0], yyvsp[-1].sr);
         }
    break;

  case 100:
#line 737 "imcc/imcc.y"
    {  add_pcc_sub(current_call->r[0], yyvsp[-1].sr); }
    break;

  case 101:
#line 739 "imcc/imcc.y"
    {
            add_pcc_sub(current_call->r[0], yyvsp[-1].sr);
            current_call->r[0]->pcc_sub->flags |= isNCI;
         }
    break;

  case 102:
#line 744 "imcc/imcc.y"
    {  add_pcc_sub(current_call->r[0], yyvsp[-1].sr); }
    break;

  case 103:
#line 746 "imcc/imcc.y"
    {  add_pcc_sub(current_call->r[0], mk_const(interp, yyvsp[-1].s,'S')); }
    break;

  case 104:
#line 748 "imcc/imcc.y"
    {  add_pcc_sub(current_call->r[0], yyvsp[-3].sr);
            add_pcc_cc(current_call->r[0], yyvsp[-1].sr);
         }
    break;

  case 105:
#line 752 "imcc/imcc.y"
    {  add_pcc_sub(current_call->r[0], mk_const(interp, yyvsp[-3].s,'S'));
            add_pcc_cc(current_call->r[0], yyvsp[-1].sr);
         }
    break;

  case 106:
#line 759 "imcc/imcc.y"
    {  yyval.sr = 0; }
    break;

  case 107:
#line 760 "imcc/imcc.y"
    {  add_pcc_arg(current_call->r[0], yyvsp[-1].sr); }
    break;

  case 108:
#line 764 "imcc/imcc.y"
    {  yyval.sr = yyvsp[0].sr; }
    break;

  case 109:
#line 769 "imcc/imcc.y"
    {  yyval.sr = 0; }
    break;

  case 110:
#line 770 "imcc/imcc.y"
    {  if(yyvsp[-1].sr) add_pcc_result(current_call->r[0], yyvsp[-1].sr); }
    break;

  case 111:
#line 774 "imcc/imcc.y"
    {  yyval.sr = yyvsp[-1].sr; yyval.sr->type |= yyvsp[0].t; }
    break;

  case 112:
#line 775 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 113:
#line 776 "imcc/imcc.y"
    {  mk_ident(interp, yyvsp[0].s, yyvsp[-1].t); is_def=0; yyval.sr=0; }
    break;

  case 114:
#line 780 "imcc/imcc.y"
    {  yyval.t = 0; }
    break;

  case 115:
#line 781 "imcc/imcc.y"
    {  yyval.t = yyvsp[-1].t | yyvsp[0].t; }
    break;

  case 116:
#line 785 "imcc/imcc.y"
    {  yyval.t = VT_FLAT;   }
    break;

  case 117:
#line 786 "imcc/imcc.y"
    {  yyval.t = VT_OPTIONAL; }
    break;

  case 118:
#line 787 "imcc/imcc.y"
    {  yyval.t = VT_OPT_COUNT; }
    break;

  case 119:
#line 792 "imcc/imcc.y"
    { yyval.t = 0; }
    break;

  case 120:
#line 793 "imcc/imcc.y"
    { yyval.t = 1; }
    break;

  case 123:
#line 803 "imcc/imcc.y"
    { begin_return_or_yield(interp, yyvsp[-1].t); }
    break;

  case 124:
#line 806 "imcc/imcc.y"
    { yyval.i = 0;   IMCC_INFO(interp)->asm_state = AsmDefault; }
    break;

  case 125:
#line 807 "imcc/imcc.y"
    {  IMCC_INFO(interp)->asm_state = AsmDefault; yyval.i = 0;  }
    break;

  case 126:
#line 813 "imcc/imcc.y"
    {  yyval.sr = 0; }
    break;

  case 127:
#line 815 "imcc/imcc.y"
    {  if(yyvsp[-1].sr) add_pcc_return(IMCC_INFO(interp)->sr_return, yyvsp[-1].sr); }
    break;

  case 128:
#line 817 "imcc/imcc.y"
    {  if(yyvsp[-1].sr) add_pcc_return(IMCC_INFO(interp)->sr_return, yyvsp[-1].sr); }
    break;

  case 129:
#line 821 "imcc/imcc.y"
    {  yyval.sr = yyvsp[-1].sr; yyval.sr->type |= yyvsp[0].t; }
    break;

  case 130:
#line 826 "imcc/imcc.y"
    {
            if ( IMCC_INFO(interp)->asm_state == AsmDefault)
                begin_return_or_yield(interp, 0);
        }
    break;

  case 131:
#line 831 "imcc/imcc.y"
    {  IMCC_INFO(interp)->asm_state = AsmDefault; yyval.t = 0;  }
    break;

  case 132:
#line 833 "imcc/imcc.y"
    {
            if ( IMCC_INFO(interp)->asm_state == AsmDefault)
                begin_return_or_yield(interp, 1);
        }
    break;

  case 133:
#line 838 "imcc/imcc.y"
    {  IMCC_INFO(interp)->asm_state = AsmDefault; yyval.t = 0;  }
    break;

  case 134:
#line 842 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 135:
#line 843 "imcc/imcc.y"
    {  add_pcc_return(IMCC_INFO(interp)->sr_return, yyvsp[0].sr);    }
    break;

  case 136:
#line 844 "imcc/imcc.y"
    {  add_pcc_return(IMCC_INFO(interp)->sr_return, yyvsp[0].sr);    }
    break;

  case 139:
#line 862 "imcc/imcc.y"
    { clear_state(); }
    break;

  case 140:
#line 867 "imcc/imcc.y"
    {  yyval.i = yyvsp[0].i; }
    break;

  case 141:
#line 868 "imcc/imcc.y"
    {  yyval.i = 0; }
    break;

  case 142:
#line 869 "imcc/imcc.y"
    {  yyval.i = 0; }
    break;

  case 143:
#line 870 "imcc/imcc.y"
    {  yyval.i = 0; }
    break;

  case 144:
#line 874 "imcc/imcc.y"
    {  yyval.i = NULL; }
    break;

  case 148:
#line 884 "imcc/imcc.y"
    {
                     yyval.i = iLABEL(cur_unit, mk_local_label(interp, yyvsp[0].s));
                   }
    break;

  case 149:
#line 891 "imcc/imcc.y"
    { yyval.i = yyvsp[-1].i; }
    break;

  case 150:
#line 895 "imcc/imcc.y"
    {
            IdList* l = malloc(sizeof(IdList));
            l->next = NULL;
            l->id = yyvsp[0].s;
            yyval.idlist = l;
         }
    break;

  case 151:
#line 903 "imcc/imcc.y"
    {  IdList* l = malloc(sizeof(IdList));
           l->id = yyvsp[0].s;
           l->next = yyvsp[-2].idlist;
           yyval.idlist = l;
        }
    break;

  case 154:
#line 913 "imcc/imcc.y"
    { push_namespace(yyvsp[0].s); }
    break;

  case 155:
#line 914 "imcc/imcc.y"
    { pop_namespace(yyvsp[0].s); }
    break;

  case 156:
#line 915 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 157:
#line 916 "imcc/imcc.y"
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

  case 158:
#line 928 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 159:
#line 929 "imcc/imcc.y"
    { mk_const_ident(interp, yyvsp[-2].s, yyvsp[-3].t, yyvsp[0].sr, 0);is_def=0; }
    break;

  case 161:
#line 931 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 162:
#line 932 "imcc/imcc.y"
    { mk_const_ident(interp, yyvsp[-2].s, yyvsp[-3].t, yyvsp[0].sr, 1);is_def=0; }
    break;

  case 163:
#line 933 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 164:
#line 934 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "restore",
                                1, mk_ident(interp, yyvsp[0].s, yyvsp[-1].t));is_def=0; }
    break;

  case 165:
#line 936 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "restore", 1, yyvsp[0].sr); }
    break;

  case 166:
#line 937 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "restore", 1, yyvsp[0].sr); }
    break;

  case 167:
#line 938 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "save", 1, yyvsp[0].sr); }
    break;

  case 168:
#line 939 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "save", 1, yyvsp[0].sr); }
    break;

  case 169:
#line 940 "imcc/imcc.y"
    { yyval.i = NULL;
                           current_call->r[0]->pcc_sub->flags |= isTAIL_CALL;
                           current_call = NULL;
                        }
    break;

  case 170:
#line 944 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "bsr",  1, yyvsp[0].sr); }
    break;

  case 171:
#line 945 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "branch",1, yyvsp[0].sr); }
    break;

  case 172:
#line 946 "imcc/imcc.y"
    { expect_pasm = 1; }
    break;

  case 173:
#line 948 "imcc/imcc.y"
    { yyval.i = INS(interp, cur_unit, "newsub",0,regs,nargs,keyvec,1); }
    break;

  case 174:
#line 950 "imcc/imcc.y"
    { yyval.i = INS(interp, cur_unit, yyvsp[-1].s, 0, regs, nargs, keyvec, 1);
                                          free(yyvsp[-1].s); }
    break;

  case 175:
#line 952 "imcc/imcc.y"
    {  yyval.i = 0; current_call = NULL; }
    break;

  case 176:
#line 953 "imcc/imcc.y"
    {  yyval.i = 0; }
    break;

  case 178:
#line 955 "imcc/imcc.y"
    { yyval.i = 0;}
    break;

  case 179:
#line 959 "imcc/imcc.y"
    { yyval.t = NEWSUB; }
    break;

  case 180:
#line 960 "imcc/imcc.y"
    { yyval.t = NEWCLOSURE; }
    break;

  case 181:
#line 961 "imcc/imcc.y"
    { yyval.t = NEWCOR; }
    break;

  case 182:
#line 962 "imcc/imcc.y"
    { yyval.t = NEWCONT; }
    break;

  case 183:
#line 966 "imcc/imcc.y"
    { yyval.t = 'I'; }
    break;

  case 184:
#line 967 "imcc/imcc.y"
    { yyval.t = 'N'; }
    break;

  case 185:
#line 968 "imcc/imcc.y"
    { yyval.t = 'S'; }
    break;

  case 186:
#line 969 "imcc/imcc.y"
    { yyval.t = 'P'; }
    break;

  case 187:
#line 970 "imcc/imcc.y"
    { yyval.t = 'P'; }
    break;

  case 188:
#line 971 "imcc/imcc.y"
    { yyval.t = 'P'; free(yyvsp[0].s); }
    break;

  case 189:
#line 976 "imcc/imcc.y"
    {
            if (( cur_pmc_type = pmc_type(interp,
                  string_from_cstring(interp, yyvsp[0].s, 0))) <= 0) {
                IMCC_fataly(interp, E_SyntaxError,
                   "Unknown PMC type '%s'\n", yyvsp[0].s);
            }
         }
    break;

  case 190:
#line 986 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "set", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 191:
#line 987 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "not", 2, yyvsp[-3].sr, yyvsp[0].sr);}
    break;

  case 192:
#line 988 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "neg", 2, yyvsp[-3].sr, yyvsp[0].sr);}
    break;

  case 193:
#line 989 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "bnot", 2, yyvsp[-3].sr, yyvsp[0].sr);}
    break;

  case 194:
#line 990 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "add", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 195:
#line 991 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "sub", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 196:
#line 992 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "mul", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 197:
#line 993 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "pow", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 198:
#line 994 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "div", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 199:
#line 995 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "fdiv", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 200:
#line 996 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "mod", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 201:
#line 997 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "concat", 3, yyvsp[-4].sr,yyvsp[-2].sr,yyvsp[0].sr); }
    break;

  case 202:
#line 999 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "shl", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 203:
#line 1001 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "shr", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 204:
#line 1003 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "lsr", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 205:
#line 1005 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "and", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 206:
#line 1007 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "or", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 207:
#line 1009 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "xor", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 208:
#line 1011 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "band", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 209:
#line 1013 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "bor", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 210:
#line 1015 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "bxor", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 211:
#line 1017 "imcc/imcc.y"
    { yyval.i = iINDEXFETCH(interp, cur_unit, yyvsp[-5].sr, yyvsp[-3].sr, yyvsp[-1].sr); }
    break;

  case 212:
#line 1019 "imcc/imcc.y"
    { yyval.i = iINDEXSET(interp, cur_unit, yyvsp[-5].sr, yyvsp[-3].sr, yyvsp[0].sr); }
    break;

  case 213:
#line 1021 "imcc/imcc.y"
    { yyval.i = iNEW(interp, cur_unit, yyvsp[-5].sr, yyvsp[-2].s, yyvsp[0].sr, 1); }
    break;

  case 214:
#line 1023 "imcc/imcc.y"
    { yyval.i = iNEW(interp, cur_unit, yyvsp[-6].sr, yyvsp[-3].s, yyvsp[-1].sr, 1); }
    break;

  case 215:
#line 1025 "imcc/imcc.y"
    { yyval.i = iNEW(interp, cur_unit, yyvsp[-3].sr, yyvsp[0].s, NULL, 1); }
    break;

  case 216:
#line 1027 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "new", 2, yyvsp[-3].sr, yyvsp[0].sr); }
    break;

  case 217:
#line 1029 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "new", 3, yyvsp[-5].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 218:
#line 1031 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "new", 3, yyvsp[-6].sr, yyvsp[-3].sr, yyvsp[-1].sr); }
    break;

  case 219:
#line 1033 "imcc/imcc.y"
    { yyval.i = iNEWSUB(interp, cur_unit, yyvsp[-3].sr, yyvsp[-1].t,
                                  mk_sub_address(interp, yyvsp[0].s), NULL, 1); }
    break;

  case 220:
#line 1036 "imcc/imcc.y"
    { /* XXX: Fix 4arg version of newsub PASM op
                              * to use  instead of implicit P0
                              */
                              yyval.i = iNEWSUB(interp, cur_unit, NULL, yyvsp[-3].t,
                                           mk_sub_address(interp, yyvsp[-2].s),
                                           mk_sub_address(interp, yyvsp[0].s), 1); }
    break;

  case 221:
#line 1043 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "set_addr",
                            2, yyvsp[-3].sr, mk_label_address(interp, yyvsp[0].s)); }
    break;

  case 222:
#line 1046 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "find_global",2,yyvsp[-3].sr,yyvsp[0].sr);}
    break;

  case 223:
#line 1048 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "store_global",2, yyvsp[-2].sr,yyvsp[0].sr); }
    break;

  case 224:
#line 1052 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "new", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 225:
#line 1054 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "new", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 226:
#line 1056 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "new", 3, yyvsp[-5].sr, yyvsp[-3].sr, yyvsp[-1].sr); }
    break;

  case 227:
#line 1059 "imcc/imcc.y"
    {
            add_pcc_result(yyvsp[0].i->r[0], yyvsp[-2].sr);
            current_call = NULL;
            yyval.i = 0;
         }
    break;

  case 228:
#line 1065 "imcc/imcc.y"
    {
            yyval.i = IMCC_create_itcall_label(interp);
         }
    break;

  case 229:
#line 1069 "imcc/imcc.y"
    {
           IMCC_itcall_sub(interp, yyvsp[-3].sr);
           current_call = NULL;
         }
    break;

  case 232:
#line 1079 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "add", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 233:
#line 1081 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "sub", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 234:
#line 1083 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "mul", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 235:
#line 1085 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "div", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 236:
#line 1087 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "mod", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 237:
#line 1089 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "fdiv", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 238:
#line 1091 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "concat", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 239:
#line 1093 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "band", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 240:
#line 1095 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "bor", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 241:
#line 1097 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "bxor", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 242:
#line 1099 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "shr", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 243:
#line 1101 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "shl", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 244:
#line 1103 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "lsr", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 245:
#line 1108 "imcc/imcc.y"
    { yyval.i = func_ins(interp, cur_unit, yyvsp[-3].sr, yyvsp[-1].s,
                                   regs,nargs,keyvec,1);
                     free(yyvsp[-1].s);
                   }
    break;

  case 246:
#line 1114 "imcc/imcc.y"
    { yyval.sr = mk_sub_address(interp, yyvsp[0].s); }
    break;

  case 247:
#line 1115 "imcc/imcc.y"
    { yyval.sr = mk_sub_address_fromc(interp, yyvsp[0].s); }
    break;

  case 248:
#line 1116 "imcc/imcc.y"
    { yyval.sr = yyvsp[0].sr;
                       if (yyvsp[0].sr->set != 'P')
                            IMCC_fataly(interp, E_SyntaxError,
                                  "Sub isn't a PMC");
                     }
    break;

  case 249:
#line 1121 "imcc/imcc.y"
    { cur_obj = yyvsp[-2].sr; yyval.sr = yyvsp[0].sr; }
    break;

  case 250:
#line 1122 "imcc/imcc.y"
    { cur_obj = yyvsp[-2].sr; yyval.sr = mk_const(interp, yyvsp[0].s, 'S'); }
    break;

  case 251:
#line 1123 "imcc/imcc.y"
    { cur_obj = yyvsp[-2].sr; yyval.sr = yyvsp[0].sr; }
    break;

  case 252:
#line 1126 "imcc/imcc.y"
    { yyval.t=0; }
    break;

  case 253:
#line 1127 "imcc/imcc.y"
    { yyval.t=0; }
    break;

  case 254:
#line 1132 "imcc/imcc.y"
    {
           yyval.i = IMCC_create_itcall_label(interp);
           IMCC_itcall_sub(interp, yyvsp[0].sr);
        }
    break;

  case 255:
#line 1137 "imcc/imcc.y"
    {  yyval.i = yyvsp[-3].i; }
    break;

  case 256:
#line 1141 "imcc/imcc.y"
    {  yyval.symlist = 0; }
    break;

  case 257:
#line 1142 "imcc/imcc.y"
    {  yyval.symlist = 0; add_pcc_arg(current_call->r[0], yyvsp[0].sr); }
    break;

  case 258:
#line 1143 "imcc/imcc.y"
    {  yyval.symlist = 0; add_pcc_arg(current_call->r[0], yyvsp[0].sr); }
    break;

  case 259:
#line 1147 "imcc/imcc.y"
    {  yyval.sr = yyvsp[-1].sr; yyval.sr->type |= yyvsp[0].t; }
    break;

  case 260:
#line 1151 "imcc/imcc.y"
    {  yyval.t = 0; }
    break;

  case 261:
#line 1152 "imcc/imcc.y"
    {  yyval.t = yyvsp[-1].t | yyvsp[0].t; }
    break;

  case 262:
#line 1156 "imcc/imcc.y"
    {  yyval.t = VT_FLAT; }
    break;

  case 263:
#line 1160 "imcc/imcc.y"
    { yyval.symlist = 0; add_pcc_result(current_call->r[0], yyvsp[0].sr); }
    break;

  case 264:
#line 1161 "imcc/imcc.y"
    { yyval.symlist = 0; add_pcc_result(current_call->r[0], yyvsp[0].sr); }
    break;

  case 265:
#line 1166 "imcc/imcc.y"
    {  yyval.i =MK_I(interp, cur_unit, yyvsp[-3].s, 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 266:
#line 1168 "imcc/imcc.y"
    {  yyval.i =MK_I(interp, cur_unit, inv_op(yyvsp[-3].s), 3, yyvsp[-4].sr,yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 267:
#line 1170 "imcc/imcc.y"
    {  yyval.i = MK_I(interp, cur_unit, "if", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 268:
#line 1172 "imcc/imcc.y"
    {  yyval.i = MK_I(interp, cur_unit, "unless",2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 269:
#line 1174 "imcc/imcc.y"
    {  yyval.i = MK_I(interp, cur_unit, "if", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 270:
#line 1176 "imcc/imcc.y"
    {  yyval.i = MK_I(interp, cur_unit, "unless", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 271:
#line 1180 "imcc/imcc.y"
    {  yyval.s = "eq"; }
    break;

  case 272:
#line 1181 "imcc/imcc.y"
    {  yyval.s = "ne"; }
    break;

  case 273:
#line 1182 "imcc/imcc.y"
    {  yyval.s = "gt"; }
    break;

  case 274:
#line 1183 "imcc/imcc.y"
    {  yyval.s = "ge"; }
    break;

  case 275:
#line 1184 "imcc/imcc.y"
    {  yyval.s = "lt"; }
    break;

  case 276:
#line 1185 "imcc/imcc.y"
    {  yyval.s = "le"; }
    break;

  case 279:
#line 1194 "imcc/imcc.y"
    {  yyval.sr = NULL; }
    break;

  case 280:
#line 1195 "imcc/imcc.y"
    {  yyval.sr = yyvsp[0].sr; }
    break;

  case 281:
#line 1199 "imcc/imcc.y"
    { yyval.sr = regs[0]; }
    break;

  case 283:
#line 1204 "imcc/imcc.y"
    {  regs[nargs++] = yyvsp[0].sr; }
    break;

  case 284:
#line 1206 "imcc/imcc.y"
    {
                      regs[nargs++] = yyvsp[-3].sr;
                      keyvec |= KEY_BIT(nargs);
                      regs[nargs++] = yyvsp[-1].sr; yyval.sr = yyvsp[-3].sr;
                   }
    break;

  case 286:
#line 1214 "imcc/imcc.y"
    { yyval.sr = mk_sub_address_fromc(interp, yyvsp[0].s); }
    break;

  case 287:
#line 1218 "imcc/imcc.y"
    { yyval.sr = mk_sub_address(interp, yyvsp[0].s); }
    break;

  case 288:
#line 1219 "imcc/imcc.y"
    { yyval.sr = mk_sub_address(interp, yyvsp[0].s); }
    break;

  case 289:
#line 1223 "imcc/imcc.y"
    { yyval.sr = mk_label_address(interp, yyvsp[0].s); }
    break;

  case 290:
#line 1224 "imcc/imcc.y"
    { yyval.sr = mk_label_address(interp, yyvsp[0].s); }
    break;

  case 295:
#line 1237 "imcc/imcc.y"
    {  nkeys=0; in_slice = 0; }
    break;

  case 296:
#line 1238 "imcc/imcc.y"
    {  yyval.sr = link_keys(interp, nkeys, keys); }
    break;

  case 297:
#line 1242 "imcc/imcc.y"
    {  keys[nkeys++] = yyvsp[0].sr; }
    break;

  case 298:
#line 1244 "imcc/imcc.y"
    {  keys[nkeys++] = yyvsp[0].sr; yyval.sr =  keys[0]; }
    break;

  case 299:
#line 1245 "imcc/imcc.y"
    { in_slice = 1; }
    break;

  case 300:
#line 1246 "imcc/imcc.y"
    { keys[nkeys++] = yyvsp[0].sr; yyval.sr =  keys[0]; }
    break;

  case 301:
#line 1250 "imcc/imcc.y"
    { if (in_slice) {
                         yyvsp[0].sr->type |= VT_START_SLICE | VT_END_SLICE;
                     }
                     yyval.sr = yyvsp[0].sr;
                   }
    break;

  case 302:
#line 1256 "imcc/imcc.y"
    { yyvsp[-2].sr->type |= VT_START_SLICE;  yyvsp[0].sr->type |= VT_END_SLICE;
                     keys[nkeys++] = yyvsp[-2].sr; yyval.sr = yyvsp[0].sr; }
    break;

  case 303:
#line 1258 "imcc/imcc.y"
    { yyvsp[0].sr->type |= VT_START_ZERO | VT_END_SLICE; yyval.sr = yyvsp[0].sr; }
    break;

  case 304:
#line 1259 "imcc/imcc.y"
    { yyvsp[-1].sr->type |= VT_START_SLICE | VT_END_INF; yyval.sr = yyvsp[-1].sr; }
    break;

  case 305:
#line 1263 "imcc/imcc.y"
    {  yyval.sr = mk_symreg(interp, yyvsp[0].s, 'I'); }
    break;

  case 306:
#line 1264 "imcc/imcc.y"
    {  yyval.sr = mk_symreg(interp, yyvsp[0].s, 'N'); }
    break;

  case 307:
#line 1265 "imcc/imcc.y"
    {  yyval.sr = mk_symreg(interp, yyvsp[0].s, 'S'); }
    break;

  case 308:
#line 1266 "imcc/imcc.y"
    {  yyval.sr = mk_symreg(interp, yyvsp[0].s, 'P'); }
    break;

  case 309:
#line 1267 "imcc/imcc.y"
    {  yyval.sr = mk_pasm_reg(interp, yyvsp[0].s); }
    break;

  case 310:
#line 1271 "imcc/imcc.y"
    {  yyval.sr = mk_const(interp, yyvsp[0].s, 'I'); }
    break;

  case 311:
#line 1272 "imcc/imcc.y"
    {  yyval.sr = mk_const(interp, yyvsp[0].s, 'N'); }
    break;

  case 312:
#line 1273 "imcc/imcc.y"
    {  yyval.sr = mk_const(interp, yyvsp[0].s, 'S'); }
    break;

  case 313:
#line 1274 "imcc/imcc.y"
    {  yyval.sr = mk_const(interp, yyvsp[0].s, 'U'); }
    break;

  case 314:
#line 1278 "imcc/imcc.y"
    {  yyval.sr = mk_symreg(interp, yyvsp[0].s, 'S'); }
    break;

  case 315:
#line 1279 "imcc/imcc.y"
    {  yyval.sr = mk_const(interp, yyvsp[0].s, 'S'); }
    break;


    }

/* Line 1016 of /usr/share/bison/yacc.c.  */
#line 3625 "imcc/imcparser.c"

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


#line 1284 "imcc/imcc.y"



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

