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
     CALL = 261,
     GOTO = 262,
     ARG = 263,
     FLATTEN_ARG = 264,
     IF = 265,
     UNLESS = 266,
     END = 267,
     SAVEALL = 268,
     RESTOREALL = 269,
     NEW = 270,
     NEWSUB = 271,
     NEWCLOSURE = 272,
     NEWCOR = 273,
     NEWCONT = 274,
     NAMESPACE = 275,
     ENDNAMESPACE = 276,
     CLASS = 277,
     ENDCLASS = 278,
     FIELD = 279,
     DOT_METHOD = 280,
     SUB = 281,
     SYM = 282,
     LOCAL = 283,
     CONST = 284,
     INC = 285,
     DEC = 286,
     GLOBAL_CONST = 287,
     PLUS_ASSIGN = 288,
     MINUS_ASSIGN = 289,
     MUL_ASSIGN = 290,
     DIV_ASSIGN = 291,
     CONCAT_ASSIGN = 292,
     BAND_ASSIGN = 293,
     BOR_ASSIGN = 294,
     BXOR_ASSIGN = 295,
     SHR_ASSIGN = 296,
     SHL_ASSIGN = 297,
     SHR_U_ASSIGN = 298,
     SHIFT_LEFT = 299,
     SHIFT_RIGHT = 300,
     INTV = 301,
     FLOATV = 302,
     STRINGV = 303,
     PMCV = 304,
     OBJECTV = 305,
     LOG_XOR = 306,
     RELOP_EQ = 307,
     RELOP_NE = 308,
     RELOP_GT = 309,
     RELOP_GTE = 310,
     RELOP_LT = 311,
     RELOP_LTE = 312,
     GLOBAL = 313,
     GLOBALOP = 314,
     ADDR = 315,
     RESULT = 316,
     RETURN = 317,
     POW = 318,
     SHIFT_RIGHT_U = 319,
     LOG_AND = 320,
     LOG_OR = 321,
     COMMA = 322,
     ESUB = 323,
     DOTDOT = 324,
     PCC_BEGIN = 325,
     PCC_END = 326,
     PCC_CALL = 327,
     PCC_SUB = 328,
     PCC_BEGIN_RETURN = 329,
     PCC_END_RETURN = 330,
     PCC_BEGIN_YIELD = 331,
     PCC_END_YIELD = 332,
     NCI_CALL = 333,
     METH_CALL = 334,
     INVOCANT = 335,
     PROTOTYPED = 336,
     NON_PROTOTYPED = 337,
     MAIN = 338,
     LOAD = 339,
     IMMEDIATE = 340,
     POSTCOMP = 341,
     METHOD = 342,
     LABEL = 343,
     EMIT = 344,
     EOM = 345,
     IREG = 346,
     NREG = 347,
     SREG = 348,
     PREG = 349,
     IDENTIFIER = 350,
     STRINGC = 351,
     INTC = 352,
     FLOATC = 353,
     REG = 354,
     MACRO = 355,
     ENDM = 356,
     PARROT_OP = 357,
     VAR = 358,
     LINECOMMENT = 359,
     FILECOMMENT = 360,
     DOT = 361,
     CONCAT = 362,
     POINTY = 363
   };
#endif
#define LOW_PREC 258
#define PARAM 259
#define PRAGMA 260
#define CALL 261
#define GOTO 262
#define ARG 263
#define FLATTEN_ARG 264
#define IF 265
#define UNLESS 266
#define END 267
#define SAVEALL 268
#define RESTOREALL 269
#define NEW 270
#define NEWSUB 271
#define NEWCLOSURE 272
#define NEWCOR 273
#define NEWCONT 274
#define NAMESPACE 275
#define ENDNAMESPACE 276
#define CLASS 277
#define ENDCLASS 278
#define FIELD 279
#define DOT_METHOD 280
#define SUB 281
#define SYM 282
#define LOCAL 283
#define CONST 284
#define INC 285
#define DEC 286
#define GLOBAL_CONST 287
#define PLUS_ASSIGN 288
#define MINUS_ASSIGN 289
#define MUL_ASSIGN 290
#define DIV_ASSIGN 291
#define CONCAT_ASSIGN 292
#define BAND_ASSIGN 293
#define BOR_ASSIGN 294
#define BXOR_ASSIGN 295
#define SHR_ASSIGN 296
#define SHL_ASSIGN 297
#define SHR_U_ASSIGN 298
#define SHIFT_LEFT 299
#define SHIFT_RIGHT 300
#define INTV 301
#define FLOATV 302
#define STRINGV 303
#define PMCV 304
#define OBJECTV 305
#define LOG_XOR 306
#define RELOP_EQ 307
#define RELOP_NE 308
#define RELOP_GT 309
#define RELOP_GTE 310
#define RELOP_LT 311
#define RELOP_LTE 312
#define GLOBAL 313
#define GLOBALOP 314
#define ADDR 315
#define RESULT 316
#define RETURN 317
#define POW 318
#define SHIFT_RIGHT_U 319
#define LOG_AND 320
#define LOG_OR 321
#define COMMA 322
#define ESUB 323
#define DOTDOT 324
#define PCC_BEGIN 325
#define PCC_END 326
#define PCC_CALL 327
#define PCC_SUB 328
#define PCC_BEGIN_RETURN 329
#define PCC_END_RETURN 330
#define PCC_BEGIN_YIELD 331
#define PCC_END_YIELD 332
#define NCI_CALL 333
#define METH_CALL 334
#define INVOCANT 335
#define PROTOTYPED 336
#define NON_PROTOTYPED 337
#define MAIN 338
#define LOAD 339
#define IMMEDIATE 340
#define POSTCOMP 341
#define METHOD 342
#define LABEL 343
#define EMIT 344
#define EOM 345
#define IREG 346
#define NREG 347
#define SREG 348
#define PREG 349
#define IDENTIFIER 350
#define STRINGC 351
#define INTC 352
#define FLOATC 353
#define REG 354
#define MACRO 355
#define ENDM 356
#define PARROT_OP 357
#define VAR 358
#define LINECOMMENT 359
#define FILECOMMENT 360
#define DOT 361
#define CONCAT 362
#define POINTY 363




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
static SymReg *cur_obj;
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
    function = r0->name;
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
        SymReg * r3 = mk_const(str_dup("1"), 'I');
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
        SymReg * r3 = mk_const(str_dup("1"), 'I');
        MK_I(interp, unit, "substr %s, %s, %s, %s", 4, r0, r1,r3, r2);
    }
    else if (r0->set == 'P') {
        keyvec |= KEY_BIT(1);
	MK_I(interp, unit, "set %s[%s], %s", 3, r0,r1,r2);
    }
    else {
        fataly(EX_SOFTWARE, sourcefile, line,"unsupported indexed set op\n");
    }
    return 0;
}

static char * inv_op(char *op) {
    int n;
    return (char *) get_neg_op(op, &n);
}

static Instruction *
create_itcall_label(void)
{
    char name[128];
    SymReg * r;
    Instruction *i;

    sprintf(name, "%cpcc_sub_call_%d", IMCC_INTERNAL_CHAR, cnr++);
    r = mk_pcc_sub(str_dup(name), 0);
    current_call = i = iLABEL(cur_unit, r);
    i->type = ITCALL | ITPCCSUB;
    return i;
}

static void
itcall_sub(SymReg* sub)
{
   current_call->r[0]->pcc_sub->sub = sub;
   if (cur_obj) {
       if (cur_obj->set != 'P')
          fataly(1, sourcefile, line, "object isn't a PMC");
       current_call->r[0]->pcc_sub->object = cur_obj;
       cur_obj = NULL;
   }
   /* FIXME use the default settings from .pragma */
   current_call->r[0]->pcc_sub->pragma = P_PROTOTYPED;
   if (current_call->r[0]->pcc_sub->sub->pmc_type == enum_class_NCI)
       current_call->r[0]->pcc_sub->nci = 1;
   if (cur_unit->type == IMC_PCCSUB)
        cur_unit->instructions->r[1]->pcc_sub->calls_a_sub = 1;
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
#line 247 "imcc/imcc.y"
typedef union {
    int t;
    char * s;
    SymReg * sr;
    Instruction *i;
    Symbol * sym;
    SymbolList * symlist;
    SymbolTable * symtab;
} yystype;
/* Line 193 of /usr/share/bison/yacc.c.  */
#line 545 "imcc/imcparser.c"
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
#line 566 "imcc/imcparser.c"

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
#define YYFINAL  35
#define YYLAST   541

/* YYNTOKENS -- Number of terminals. */
#define YYNTOKENS  125
/* YYNNTS -- Number of nonterminals. */
#define YYNNTS  100
/* YYNRULES -- Number of rules. */
#define YYNRULES  265
/* YYNRULES -- Number of states. */
#define YYNSTATES  449

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   363

#define YYTRANSLATE(X) \
  ((unsigned)(X) <= YYMAXUTOK ? yytranslate[X] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const unsigned char yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       4,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,   113,     2,     2,     2,   119,   120,     2,
     122,   123,   117,   116,     2,   114,     2,   118,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,   124,
       2,   110,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,   111,     2,   112,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,   121,     2,   115,     2,     2,     2,
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
     106,   107,   108,   109
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const unsigned short yyprhs[] =
{
       0,     0,     3,     5,     7,    10,    12,    14,    16,    18,
      20,    22,    24,    27,    29,    33,    39,    40,    47,    49,
      52,    56,    59,    61,    63,    65,    66,    70,    74,    75,
      77,    78,    83,    88,    89,    96,    98,    99,   101,   104,
     106,   108,   110,   115,   120,   121,   122,   131,   132,   134,
     138,   139,   144,   147,   148,   149,   158,   159,   161,   165,
     166,   171,   172,   183,   184,   187,   188,   192,   194,   196,
     197,   201,   203,   205,   207,   209,   211,   213,   215,   221,
     225,   229,   233,   237,   243,   249,   250,   254,   257,   260,
     261,   265,   268,   269,   274,   275,   281,   282,   288,   289,
     292,   296,   299,   301,   304,   305,   308,   311,   313,   315,
     316,   318,   321,   323,   325,   329,   331,   333,   336,   339,
     340,   345,   346,   353,   354,   361,   362,   367,   370,   373,
     376,   379,   382,   385,   386,   390,   393,   395,   397,   399,
     401,   402,   404,   406,   408,   410,   412,   414,   416,   418,
     420,   422,   424,   428,   433,   438,   443,   449,   455,   461,
     467,   473,   479,   485,   491,   497,   503,   509,   515,   521,
     527,   533,   539,   546,   553,   560,   565,   570,   577,   582,
     589,   594,   599,   604,   605,   609,   613,   614,   624,   626,
     628,   632,   636,   640,   644,   648,   652,   656,   660,   664,
     668,   672,   677,   679,   681,   685,   689,   693,   695,   697,
     698,   704,   705,   709,   711,   713,   716,   720,   722,   729,
     736,   741,   746,   751,   756,   758,   760,   762,   764,   766,
     768,   770,   772,   773,   775,   779,   781,   783,   788,   790,
     792,   794,   796,   798,   800,   802,   804,   805,   808,   810,
     814,   815,   820,   822,   826,   829,   832,   834,   836,   838,
     840,   842,   844,   846,   848,   850
};

/* YYRHS -- A `-1'-separated list of the rules' RHS. */
static const short yyrhs[] =
{
     126,     0,    -1,   127,    -1,   128,    -1,   127,   128,    -1,
     140,    -1,   139,    -1,   130,    -1,   129,    -1,   147,    -1,
     154,    -1,   137,    -1,   101,     4,    -1,     4,    -1,    59,
     193,    96,    -1,    59,   193,    96,   110,   223,    -1,    -1,
      30,   131,   193,    96,   110,   223,    -1,   133,    -1,   132,
     133,    -1,   182,   134,     4,    -1,   101,     4,    -1,   106,
      -1,   105,    -1,   139,    -1,    -1,   135,   103,   136,    -1,
      74,   165,    89,    -1,    -1,   210,    -1,    -1,    90,   138,
     132,    91,    -1,    21,   111,   217,   112,    -1,    -1,    23,
      96,   141,     4,   142,    24,    -1,   143,    -1,    -1,   144,
      -1,   143,   144,    -1,   145,    -1,   146,    -1,     4,    -1,
      25,   193,    96,     4,    -1,    26,    96,    96,     4,    -1,
      -1,    -1,    27,   148,   213,   165,     4,   149,   150,   153,
      -1,    -1,     4,    -1,   150,   151,     4,    -1,    -1,     5,
     152,   193,    96,    -1,   179,    69,    -1,    -1,    -1,    74,
     155,    96,   165,     4,   156,   157,   153,    -1,    -1,     4,
      -1,   157,   158,     4,    -1,    -1,     5,   159,   193,    96,
      -1,    -1,    71,   164,     4,   161,   168,   163,   167,   162,
     170,    72,    -1,    -1,   184,     4,    -1,    -1,    81,   216,
       4,    -1,    82,    -1,    83,    -1,    -1,   165,    68,   166,
      -1,   166,    -1,   164,    -1,    85,    -1,    84,    -1,    86,
      -1,    87,    -1,    88,    -1,    73,   216,    68,   216,     4,
      -1,    73,   216,     4,    -1,    79,   216,     4,    -1,    80,
     209,     4,    -1,    80,    97,     4,    -1,    80,   209,    68,
     216,     4,    -1,    80,    97,    68,   216,     4,    -1,    -1,
     168,   169,     4,    -1,     9,   216,    -1,    10,   209,    -1,
      -1,   170,   171,     4,    -1,    62,   209,    -1,    -1,    29,
     172,   193,    96,    -1,    -1,    75,     4,   174,   177,    76,
      -1,    -1,    77,     4,   176,   177,    78,    -1,    -1,   177,
       4,    -1,   177,   178,     4,    -1,    63,   216,    -1,   181,
      -1,   179,   181,    -1,    -1,   180,   185,    -1,   101,     4,
      -1,   106,    -1,   105,    -1,    -1,   183,    -1,   183,   184,
      -1,   184,    -1,    89,    -1,   182,   186,     4,    -1,   195,
      -1,   207,    -1,    21,    96,    -1,    22,    96,    -1,    -1,
      29,   187,   193,    96,    -1,    -1,    30,   188,   193,    96,
     110,   223,    -1,    -1,    33,   189,   193,    96,   110,   223,
      -1,    -1,     5,   190,   193,    96,    -1,     5,   222,    -1,
      62,   216,    -1,     9,   216,    -1,    63,   216,    -1,     7,
     214,    -1,     8,   214,    -1,    -1,    17,   191,   136,    -1,
     103,   210,    -1,   202,    -1,   160,    -1,   173,    -1,   175,
      -1,    -1,    17,    -1,    18,    -1,    19,    -1,    20,    -1,
      47,    -1,    48,    -1,    49,    -1,    50,    -1,    51,    -1,
     194,    -1,    96,    -1,   209,   110,   216,    -1,   209,   110,
     113,   216,    -1,   209,   110,   114,   216,    -1,   209,   110,
     115,   216,    -1,   209,   110,   216,   116,   216,    -1,   209,
     110,   216,   114,   216,    -1,   209,   110,   216,   117,   216,
      -1,   209,   110,   216,    64,   216,    -1,   209,   110,   216,
     118,   216,    -1,   209,   110,   216,   119,   216,    -1,   209,
     110,   216,   108,   216,    -1,   209,   110,   216,    45,   216,
      -1,   209,   110,   216,    46,   216,    -1,   209,   110,   216,
      65,   216,    -1,   209,   110,   216,    66,   216,    -1,   209,
     110,   216,    67,   216,    -1,   209,   110,   216,    52,   216,
      -1,   209,   110,   216,   120,   216,    -1,   209,   110,   216,
     121,   216,    -1,   209,   110,   216,   115,   216,    -1,   209,
     110,   216,   111,   217,   112,    -1,   209,   111,   217,   112,
     110,   216,    -1,   209,   110,    16,   194,    68,   216,    -1,
     209,   110,    16,   194,    -1,   209,   110,    16,   216,    -1,
     209,   110,    16,   216,    68,   216,    -1,   209,   110,   192,
      96,    -1,   209,   110,   192,    96,    68,    96,    -1,   209,
     110,    61,    96,    -1,   209,   110,    60,   224,    -1,    60,
     224,   110,   216,    -1,    -1,    16,   196,   136,    -1,   209,
     110,   202,    -1,    -1,   197,   122,   206,   123,   110,   200,
     122,   204,   123,    -1,   198,    -1,   199,    -1,   209,    34,
     216,    -1,   209,    35,   216,    -1,   209,    36,   216,    -1,
     209,    37,   216,    -1,   209,    38,   216,    -1,   209,    39,
     216,    -1,   209,    40,   216,    -1,   209,    41,   216,    -1,
     209,    42,   216,    -1,   209,    43,   216,    -1,   209,    44,
     216,    -1,   209,   110,   103,   136,    -1,    96,    -1,   209,
      -1,   209,   201,   213,    -1,   209,   201,    97,    -1,   209,
     201,   209,    -1,   109,    -1,   107,    -1,    -1,   200,   203,
     122,   204,   123,    -1,    -1,   204,    68,   205,    -1,   205,
      -1,   216,    -1,    10,   209,    -1,   206,    68,   209,    -1,
     209,    -1,    11,   216,   208,   216,     8,   214,    -1,    12,
     216,   208,   216,     8,   214,    -1,    11,   216,     8,   214,
      -1,    12,   216,     8,   214,    -1,    11,   216,    68,   214,
      -1,    12,   216,    68,   214,    -1,    53,    -1,    54,    -1,
      55,    -1,    56,    -1,    57,    -1,    58,    -1,   104,    -1,
     222,    -1,    -1,   211,    -1,   211,    68,   212,    -1,   212,
      -1,   215,    -1,   209,   111,   217,   112,    -1,    96,    -1,
     103,    -1,    96,    -1,   103,    -1,   214,    -1,   216,    -1,
     209,    -1,   223,    -1,    -1,   218,   219,    -1,   221,    -1,
     219,   124,   221,    -1,    -1,   219,    68,   220,   221,    -1,
     216,    -1,   216,    70,   216,    -1,    70,   216,    -1,   216,
      70,    -1,    92,    -1,    93,    -1,    94,    -1,    95,    -1,
     100,    -1,    98,    -1,    99,    -1,    97,    -1,    94,    -1,
      97,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const unsigned short yyrline[] =
{
       0,   321,   321,   325,   327,   330,   332,   333,   334,   335,
     336,   337,   338,   339,   342,   348,   356,   355,   360,   362,
     365,   367,   368,   369,   370,   373,   373,   377,   384,   387,
     392,   391,   403,   412,   410,   426,   428,   431,   433,   436,
     438,   439,   442,   456,   474,   479,   472,   489,   491,   492,
     496,   495,   500,   505,   507,   504,   517,   519,   520,   524,
     523,   530,   528,   560,   562,   565,   567,   570,   572,   575,
     577,   578,   581,   582,   583,   584,   585,   586,   589,   595,
     597,   602,   604,   606,   610,   616,   618,   621,   623,   626,
     628,   631,   634,   634,   640,   638,   660,   658,   679,   681,
     683,   687,   691,   693,   704,   708,   711,   712,   713,   716,
     718,   721,   723,   726,   733,   738,   740,   741,   742,   743,
     743,   744,   744,   746,   746,   748,   748,   750,   751,   752,
     753,   754,   755,   756,   756,   759,   762,   763,   764,   765,
     766,   769,   771,   772,   773,   776,   778,   779,   780,   781,
     782,   785,   795,   797,   798,   799,   800,   801,   802,   803,
     804,   805,   806,   807,   809,   811,   813,   815,   817,   819,
     821,   823,   825,   827,   829,   831,   833,   835,   837,   840,
     847,   850,   852,   857,   856,   861,   868,   867,   876,   877,
     880,   883,   885,   887,   889,   891,   893,   895,   897,   899,
     901,   905,   913,   914,   918,   919,   920,   923,   924,   929,
     927,   937,   939,   940,   943,   946,   950,   952,   955,   958,
     960,   962,   964,   966,   970,   972,   973,   974,   975,   976,
     979,   981,   984,   986,   989,   991,   994,   996,  1004,  1006,
    1009,  1011,  1014,  1016,  1019,  1021,  1024,  1024,  1028,  1030,
    1032,  1032,  1036,  1042,  1045,  1046,  1049,  1051,  1052,  1053,
    1054,  1057,  1059,  1060,  1063,  1065
};
#endif

#if YYDEBUG || YYERROR_VERBOSE
/* YYTNME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals. */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "LOW_PREC", "'\\n'", "PARAM", "PRAGMA", 
  "CALL", "GOTO", "ARG", "FLATTEN_ARG", "IF", "UNLESS", "END", "SAVEALL", 
  "RESTOREALL", "NEW", "NEWSUB", "NEWCLOSURE", "NEWCOR", "NEWCONT", 
  "NAMESPACE", "ENDNAMESPACE", "CLASS", "ENDCLASS", "FIELD", "DOT_METHOD", 
  "SUB", "SYM", "LOCAL", "CONST", "INC", "DEC", "GLOBAL_CONST", 
  "PLUS_ASSIGN", "MINUS_ASSIGN", "MUL_ASSIGN", "DIV_ASSIGN", 
  "CONCAT_ASSIGN", "BAND_ASSIGN", "BOR_ASSIGN", "BXOR_ASSIGN", 
  "SHR_ASSIGN", "SHL_ASSIGN", "SHR_U_ASSIGN", "SHIFT_LEFT", "SHIFT_RIGHT", 
  "INTV", "FLOATV", "STRINGV", "PMCV", "OBJECTV", "LOG_XOR", "RELOP_EQ", 
  "RELOP_NE", "RELOP_GT", "RELOP_GTE", "RELOP_LT", "RELOP_LTE", "GLOBAL", 
  "GLOBALOP", "ADDR", "RESULT", "RETURN", "POW", "SHIFT_RIGHT_U", 
  "LOG_AND", "LOG_OR", "COMMA", "ESUB", "DOTDOT", "PCC_BEGIN", "PCC_END", 
  "PCC_CALL", "PCC_SUB", "PCC_BEGIN_RETURN", "PCC_END_RETURN", 
  "PCC_BEGIN_YIELD", "PCC_END_YIELD", "NCI_CALL", "METH_CALL", "INVOCANT", 
  "PROTOTYPED", "NON_PROTOTYPED", "MAIN", "LOAD", "IMMEDIATE", "POSTCOMP", 
  "METHOD", "LABEL", "EMIT", "EOM", "IREG", "NREG", "SREG", "PREG", 
  "IDENTIFIER", "STRINGC", "INTC", "FLOATC", "REG", "MACRO", "ENDM", 
  "PARROT_OP", "VAR", "LINECOMMENT", "FILECOMMENT", "DOT", "CONCAT", 
  "POINTY", "'='", "'['", "']'", "'!'", "'-'", "'~'", "'+'", "'*'", "'/'", 
  "'%'", "'&'", "'|'", "'('", "')'", "';'", "$accept", "program", 
  "compilation_units", "compilation_unit", "global", "constdef", "@1", 
  "pasmcode", "pasmline", "pasm_inst", "@2", "pasm_args", "emit", "@3", 
  "class_namespace", "class", "@4", "class_body", "member_decls", 
  "member_decl", "field_decl", "method_decl", "sub", "@5", "@6", 
  "sub_params", "sub_param", "@7", "sub_body", "pcc_sub", "@8", "@9", 
  "pcc_params", "pcc_param", "@10", "pcc_sub_call", "@11", "opt_label", 
  "opt_invocant", "pcc_proto", "pcc_sub_proto", "proto", "pcc_call", 
  "pcc_args", "pcc_arg", "pcc_results", "pcc_result", "@12", "pcc_ret", 
  "@13", "pcc_yield", "@14", "pcc_returns", "pcc_return", "statements", 
  "helper_clear_state", "statement", "labels", "_labels", "label", 
  "instruction", "labeled_inst", "@15", "@16", "@17", "@18", "@19", 
  "newsub", "type", "classname", "assignment", "@20", "@21", "op_assign", 
  "func_assign", "the_sub", "ptr", "sub_call", "@22", "arglist", "arg", 
  "targetlist", "if_statement", "relop", "target", "vars", "_vars", 
  "_var_or_i", "sub_label_op", "label_op", "var_or_i", "var", "keylist", 
  "@23", "_keylist", "@24", "key", "reg", "const", "string", 0
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
      61,    91,    93,    33,    45,   126,    43,    42,    47,    37,
      38,   124,    40,    41,    59
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const unsigned char yyr1[] =
{
       0,   125,   126,   127,   127,   128,   128,   128,   128,   128,
     128,   128,   128,   128,   129,   129,   131,   130,   132,   132,
     133,   133,   133,   133,   133,   135,   134,   134,   134,   136,
     138,   137,   139,   141,   140,   142,   142,   143,   143,   144,
     144,   144,   145,   146,   148,   149,   147,   150,   150,   150,
     152,   151,   153,   155,   156,   154,   157,   157,   157,   159,
     158,   161,   160,   162,   162,   163,   163,   164,   164,   165,
     165,   165,   166,   166,   166,   166,   166,   166,   167,   167,
     167,   167,   167,   167,   167,   168,   168,   169,   169,   170,
     170,   171,   172,   171,   174,   173,   176,   175,   177,   177,
     177,   178,   179,   179,   180,   181,   181,   181,   181,   182,
     182,   183,   183,   184,   185,   186,   186,   186,   186,   187,
     186,   188,   186,   189,   186,   190,   186,   186,   186,   186,
     186,   186,   186,   191,   186,   186,   186,   186,   186,   186,
     186,   192,   192,   192,   192,   193,   193,   193,   193,   193,
     193,   194,   195,   195,   195,   195,   195,   195,   195,   195,
     195,   195,   195,   195,   195,   195,   195,   195,   195,   195,
     195,   195,   195,   195,   195,   195,   195,   195,   195,   195,
     195,   195,   195,   196,   195,   195,   197,   195,   195,   195,
     198,   198,   198,   198,   198,   198,   198,   198,   198,   198,
     198,   199,   200,   200,   200,   200,   200,   201,   201,   203,
     202,   204,   204,   204,   205,   205,   206,   206,   207,   207,
     207,   207,   207,   207,   208,   208,   208,   208,   208,   208,
     209,   209,   210,   210,   211,   211,   212,   212,   213,   213,
     214,   214,   215,   215,   216,   216,   218,   217,   219,   219,
     220,   219,   221,   221,   221,   221,   222,   222,   222,   222,
     222,   223,   223,   223,   224,   224
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const unsigned char yyr2[] =
{
       0,     2,     1,     1,     2,     1,     1,     1,     1,     1,
       1,     1,     2,     1,     3,     5,     0,     6,     1,     2,
       3,     2,     1,     1,     1,     0,     3,     3,     0,     1,
       0,     4,     4,     0,     6,     1,     0,     1,     2,     1,
       1,     1,     4,     4,     0,     0,     8,     0,     1,     3,
       0,     4,     2,     0,     0,     8,     0,     1,     3,     0,
       4,     0,    10,     0,     2,     0,     3,     1,     1,     0,
       3,     1,     1,     1,     1,     1,     1,     1,     5,     3,
       3,     3,     3,     5,     5,     0,     3,     2,     2,     0,
       3,     2,     0,     4,     0,     5,     0,     5,     0,     2,
       3,     2,     1,     2,     0,     2,     2,     1,     1,     0,
       1,     2,     1,     1,     3,     1,     1,     2,     2,     0,
       4,     0,     6,     0,     6,     0,     4,     2,     2,     2,
       2,     2,     2,     0,     3,     2,     1,     1,     1,     1,
       0,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     3,     4,     4,     4,     5,     5,     5,     5,
       5,     5,     5,     5,     5,     5,     5,     5,     5,     5,
       5,     5,     6,     6,     6,     4,     4,     6,     4,     6,
       4,     4,     4,     0,     3,     3,     0,     9,     1,     1,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     4,     1,     1,     3,     3,     3,     1,     1,     0,
       5,     0,     3,     1,     1,     2,     3,     1,     6,     6,
       4,     4,     4,     4,     1,     1,     1,     1,     1,     1,
       1,     1,     0,     1,     3,     1,     1,     4,     1,     1,
       1,     1,     1,     1,     1,     1,     0,     2,     1,     3,
       0,     4,     1,     3,     2,     2,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const unsigned short yydefact[] =
{
       0,    13,     0,     0,    44,    16,     0,    53,    30,     0,
       0,     2,     3,     8,     7,    11,     6,     5,     9,    10,
     246,    33,     0,     0,   145,   146,   147,   148,   149,   151,
       0,   150,     0,   109,    12,     1,     4,     0,     0,     0,
     238,   239,    69,     0,    14,    69,   113,     0,    23,    22,
     109,    18,    24,    25,   110,   112,    32,     0,   256,   257,
     258,   259,   263,   261,   262,   260,   230,   244,   252,   247,
     248,   231,   245,    36,    67,    68,    74,    73,    75,    76,
      77,    72,     0,    71,     0,     0,     0,    21,    31,    19,
      69,     0,     0,   111,   254,   255,   250,     0,    41,     0,
       0,     0,    35,    37,    39,    40,    45,     0,     0,    15,
      54,     0,    20,   232,   253,     0,   249,     0,     0,    34,
      38,    47,    70,    17,    56,    27,   240,   241,    26,   244,
      29,   233,   235,   242,   236,   243,   251,     0,     0,    48,
     104,    57,   104,   246,     0,    42,    43,    50,     0,   108,
     107,     0,    46,   104,   109,   102,    59,    55,     0,     0,
     234,     0,   106,    49,    52,   103,   140,   105,     0,    58,
     237,     0,   125,     0,     0,     0,     0,     0,   183,   133,
       0,     0,   119,   121,   123,     0,     0,     0,     0,     0,
       0,   202,   232,   137,   138,   139,     0,   115,     0,   188,
     189,   209,   136,   116,   203,     0,    51,     0,   127,   131,
     132,   129,     0,     0,   232,   232,   117,   118,     0,     0,
       0,   264,   265,     0,   128,   130,     0,    94,    96,   135,
     114,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   208,   207,     0,   246,     0,    60,
       0,     0,   224,   225,   226,   227,   228,   229,     0,     0,
       0,     0,     0,   184,   134,     0,     0,     0,     0,    61,
      98,    98,     0,   217,   211,   190,   191,   192,   193,   194,
     195,   196,   197,   198,   199,   200,     0,   141,   142,   143,
     144,     0,     0,   232,     0,     0,     0,     0,   185,   244,
     152,     0,   205,   206,   204,   126,   220,   222,     0,   221,
     223,     0,   120,     0,     0,   182,    85,     0,     0,     0,
       0,     0,     0,   213,   214,   175,   176,   181,   180,   201,
     153,   154,   155,   178,     0,     0,     0,     0,     0,     0,
       0,     0,   246,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    65,    99,     0,    95,
       0,    97,   216,     0,   215,     0,   210,     0,     0,     0,
     163,   164,   168,   159,   165,   166,   167,   162,     0,   157,
     171,   156,   158,   160,   161,   169,   170,     0,   218,   219,
     122,   124,     0,     0,     0,     0,     0,   101,   100,     0,
     203,   212,   174,   177,   179,   172,   173,    87,    88,     0,
       0,     0,     0,    63,    86,   211,    66,     0,     0,     0,
       0,    89,     0,     0,    79,     0,    80,    82,     0,    81,
       0,     0,    64,   187,     0,     0,     0,    92,     0,    62,
       0,    78,    84,    83,     0,    91,    90,     0,    93
};

/* YYDEFGOTO[NTERM-NUM]. */
static const short yydefgoto[] =
{
      -1,    10,    11,    12,    13,    14,    23,    50,    51,    91,
      92,   128,    15,    33,    16,    17,    39,   101,   102,   103,
     104,   105,    18,    22,   121,   140,   151,   161,   152,    19,
      32,   124,   142,   158,   168,   193,   316,   421,   395,    81,
      82,    83,   413,   356,   396,   431,   440,   444,   194,   270,
     195,   271,   317,   360,   153,   154,   155,    53,    54,    55,
     167,   196,   218,   219,   220,   207,   215,   297,    30,    31,
     197,   214,   198,   199,   200,   201,   248,   202,   232,   322,
     323,   272,   203,   259,    67,   130,   131,   132,    42,   133,
     134,   135,    37,    38,    69,   115,    70,    71,    72,   223
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -202
static const short yypact[] =
{
       8,  -202,   -84,   -51,  -202,  -202,   193,  -202,  -202,    57,
      63,     8,  -202,  -202,  -202,  -202,  -202,  -202,  -202,  -202,
    -202,  -202,   -66,   193,  -202,  -202,  -202,  -202,  -202,  -202,
     -25,  -202,   -22,    31,  -202,  -202,  -202,   -26,   121,    73,
    -202,  -202,   170,    22,   -11,   170,  -202,   115,  -202,  -202,
      -4,  -202,  -202,     4,    46,  -202,  -202,   437,  -202,  -202,
    -202,  -202,  -202,  -202,  -202,  -202,  -202,  -202,    61,   -52,
    -202,  -202,  -202,   122,  -202,  -202,  -202,  -202,  -202,  -202,
    -202,  -202,    20,  -202,    29,    18,    28,  -202,  -202,  -202,
     170,   142,    47,  -202,  -202,   437,  -202,   121,  -202,   193,
      53,   129,   122,  -202,  -202,  -202,  -202,   170,    18,  -202,
    -202,   -42,  -202,   330,  -202,   121,  -202,    58,    59,  -202,
    -202,   152,  -202,  -202,   154,  -202,  -202,  -202,  -202,    62,
    -202,   106,  -202,  -202,  -202,  -202,  -202,   172,   183,  -202,
      -1,  -202,     6,  -202,   330,  -202,  -202,  -202,   184,  -202,
    -202,   185,  -202,   -36,    46,  -202,  -202,  -202,   186,    80,
    -202,   193,  -202,  -202,  -202,  -202,   380,  -202,   193,  -202,
    -202,    98,   190,    10,    10,   437,   437,   437,  -202,  -202,
     114,   116,  -202,  -202,  -202,   -43,   437,   437,   -27,   219,
     222,  -202,   330,  -202,  -202,  -202,   225,  -202,   108,  -202,
    -202,  -202,  -202,  -202,   127,   132,  -202,   193,  -202,  -202,
    -202,  -202,   125,   209,   330,   330,  -202,  -202,   193,   193,
     193,  -202,  -202,   135,  -202,  -202,   227,  -202,  -202,  -202,
    -202,   344,   110,   437,   437,   437,   437,   437,   437,   437,
     437,   437,   437,   437,  -202,  -202,   400,  -202,   224,  -202,
     139,    10,  -202,  -202,  -202,  -202,  -202,  -202,    10,   437,
      10,    10,   437,  -202,  -202,   150,   151,   153,   437,  -202,
    -202,  -202,   -48,  -202,    30,  -202,  -202,  -202,  -202,  -202,
    -202,  -202,  -202,  -202,  -202,  -202,   424,  -202,  -202,  -202,
    -202,   -43,   173,   330,   437,   437,   437,   174,  -202,    50,
     229,   156,  -202,  -202,  -202,  -202,  -202,  -202,   265,  -202,
    -202,   268,  -202,   168,   169,  -202,  -202,     5,     1,   344,
     176,   344,   -40,  -202,  -202,   212,   220,  -202,  -202,  -202,
    -202,  -202,  -202,   223,   437,   437,   437,   437,   437,   437,
     437,   437,  -202,   437,   437,   437,   437,   437,   437,   437,
     437,   177,    10,    10,    18,    18,     9,  -202,   437,  -202,
     293,  -202,  -202,   269,  -202,    30,  -202,   437,   437,   202,
    -202,  -202,  -202,  -202,  -202,  -202,  -202,  -202,   195,  -202,
    -202,  -202,  -202,  -202,  -202,  -202,  -202,   437,  -202,  -202,
    -202,  -202,   437,   344,   437,   -30,   321,  -202,  -202,   204,
     -50,  -202,  -202,  -202,  -202,  -202,  -202,  -202,  -202,   325,
     437,   437,   311,    46,  -202,    30,  -202,    35,   327,    40,
      42,  -202,   331,   -34,  -202,   437,  -202,  -202,   437,  -202,
     437,   -14,  -202,  -202,   332,   334,   335,  -202,   344,  -202,
     338,  -202,  -202,  -202,   193,  -202,  -202,   238,  -202
};

/* YYPGOTO[NTERM-NUM].  */
static const short yypgoto[] =
{
    -202,  -202,  -202,   340,  -202,  -202,  -202,  -202,   303,  -202,
    -202,  -201,  -202,  -202,     3,  -202,  -202,  -202,  -202,   252,
    -202,  -202,  -202,  -202,  -202,  -202,  -202,  -202,   213,  -202,
    -202,  -202,  -202,  -202,  -202,  -202,  -202,  -202,  -202,   178,
     -24,   249,  -202,  -202,  -202,  -202,  -202,  -202,  -202,  -202,
    -202,  -202,    87,  -202,  -202,  -202,   215,   216,  -202,   -53,
    -202,  -202,  -202,  -202,  -202,  -202,  -202,  -202,   -23,    85,
    -202,  -202,  -202,  -202,  -202,    11,  -202,   126,  -202,   -38,
      13,  -202,  -202,   166,   -71,   189,  -202,   239,   134,  -167,
    -202,   -35,  -133,  -202,  -202,  -202,   -74,   214,   -83,    93
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, parse error.  */
#define YYTABLE_NINF -204
static const short yytable[] =
{
      43,    93,   109,    68,   147,   357,   209,   210,   -28,   357,
     159,   156,     1,   263,   264,   437,    96,     2,   392,   393,
     319,    86,    94,   116,   106,   123,   107,    20,   365,     2,
      40,     3,   110,   164,   365,     4,    52,    41,     5,   424,
     321,   136,   129,   410,   427,    21,   429,   125,   438,   411,
     412,   221,     2,    52,   222,    74,    75,   244,   439,   245,
     114,    34,    68,    35,   358,   148,   111,     6,   358,   149,
     150,    44,    97,   129,    45,   320,   117,    73,    90,   361,
      68,   359,     7,   366,   306,    46,    56,    88,   107,   433,
     394,   307,   329,   309,   310,   204,   107,    47,     8,    85,
     148,    48,    49,   425,   149,   150,   126,   148,   428,     9,
     430,   149,   150,   127,   301,    62,    63,    64,    84,    87,
      46,   129,    58,    59,    60,    61,    98,    62,    63,    64,
      65,    95,    47,   251,    66,    46,    48,    49,   171,   108,
     211,   212,   213,   129,   129,   205,   112,    99,   100,   118,
     113,   224,   225,   119,   137,   138,   139,   244,   141,   245,
     273,   233,   234,   235,   236,   237,   238,   239,   240,   241,
     242,   243,  -203,   143,   144,   299,   145,   303,   252,   253,
     254,   255,   256,   257,   250,   388,   389,   146,   162,   163,
     169,    57,   170,   258,   206,   265,   266,   267,   275,   276,
     277,   278,   279,   280,   281,   282,   283,   284,   285,   378,
     216,   300,   217,    58,    59,    60,    61,   260,    62,    63,
      64,    65,   129,   227,   308,    66,   228,   311,   249,   230,
     231,   269,   274,   315,   244,   305,   245,   246,   247,   324,
      24,    25,    26,    27,    28,   268,   312,   313,   362,   314,
     364,   326,    74,    75,    76,    77,    78,    79,    80,   330,
     331,   332,   252,   253,   254,   255,   256,   257,   351,   328,
     333,   390,   391,   352,   334,   335,   353,   261,   354,   355,
     367,   336,    58,    59,    60,    61,   363,   387,   368,    29,
      65,   369,   400,   337,   338,   339,   340,   398,   404,   370,
     371,   372,   373,   374,   375,   376,   377,   405,   379,   380,
     381,   382,   383,   384,   385,   386,    58,    59,    60,    61,
      40,   302,   408,   397,    65,   414,   415,    41,    66,   416,
     324,   426,   402,   403,   448,   432,   441,   341,   442,   443,
     342,   420,   446,   343,   344,   345,   346,   347,   348,   349,
     350,    36,   406,    89,   120,   157,   122,   407,   318,   409,
     422,    58,    59,    60,    61,   191,   226,   445,   165,    65,
     166,   325,   298,    66,   399,   417,   418,   423,   401,   262,
     324,   229,   304,   160,   327,   172,   208,   173,   174,   175,
     434,   176,   177,   435,     0,   436,   178,   179,     0,     0,
       0,   180,   181,    58,    59,    60,    61,     0,   419,   182,
     183,    65,     0,   184,     0,    66,   286,   287,   288,   289,
     290,   447,    58,    59,    60,    61,   126,    62,    63,    64,
      65,     0,     0,   127,    66,     0,    58,    59,    60,    61,
     185,     0,   186,   187,    65,     0,     0,     0,    66,     0,
       0,   188,     0,     0,     0,   189,     0,   190,     0,     0,
     291,   292,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    58,    59,    60,    61,   191,     0,     0,     0,
      65,     0,     0,   192,    66,     0,     0,     0,     0,     0,
       0,     0,    58,    59,    60,    61,   191,    62,    63,    64,
      65,     0,  -186,   293,    66,     0,     0,     0,     0,     0,
       0,     0,     0,   294,   295,   296,    58,    59,    60,    61,
      29,    62,    63,    64,    65,     0,     0,     0,    66,    58,
      59,    60,    61,     0,    62,    63,    64,    65,     0,     0,
       0,    66
};

static const short yycheck[] =
{
      23,    54,    85,    38,     5,     4,   173,   174,     4,     4,
     143,     5,     4,   214,   215,    29,    68,    21,     9,    10,
      68,    45,    57,    97,     4,   108,    68,   111,    68,    21,
      96,    23,     4,    69,    68,    27,    33,   103,    30,     4,
      10,   115,   113,    73,     4,    96,     4,    89,    62,    79,
      80,    94,    21,    50,    97,    82,    83,   107,    72,   109,
      95,     4,    97,     0,    63,   101,    90,    59,    63,   105,
     106,    96,   124,   144,    96,   123,    99,     4,    74,    78,
     115,    76,    74,   123,   251,    89,   112,    91,    68,   123,
      81,   258,   293,   260,   261,   166,    68,   101,    90,   110,
     101,   105,   106,    68,   105,   106,    96,   101,    68,   101,
      68,   105,   106,   103,   247,    97,    98,    99,    96,     4,
      89,   192,    92,    93,    94,    95,     4,    97,    98,    99,
     100,    70,   101,     8,   104,    89,   105,   106,   161,   110,
     175,   176,   177,   214,   215,   168,     4,    25,    26,    96,
     103,   186,   187,    24,    96,    96,     4,   107,     4,   109,
     231,    34,    35,    36,    37,    38,    39,    40,    41,    42,
      43,    44,   122,   111,    68,   246,     4,   248,    53,    54,
      55,    56,    57,    58,   207,   352,   353,     4,     4,     4,
       4,    70,   112,    68,    96,   218,   219,   220,   233,   234,
     235,   236,   237,   238,   239,   240,   241,   242,   243,   342,
      96,   246,    96,    92,    93,    94,    95,     8,    97,    98,
      99,   100,   293,     4,   259,   104,     4,   262,    96,     4,
     122,     4,   122,   268,   107,    96,   109,   110,   111,   274,
      47,    48,    49,    50,    51,   110,    96,    96,   319,    96,
     321,   286,    82,    83,    84,    85,    86,    87,    88,   294,
     295,   296,    53,    54,    55,    56,    57,    58,   112,    96,
      96,   354,   355,     8,    45,    46,     8,    68,   110,   110,
      68,    52,    92,    93,    94,    95,   110,   110,    68,    96,
     100,    68,   363,    64,    65,    66,    67,     4,    96,   334,
     335,   336,   337,   338,   339,   340,   341,   112,   343,   344,
     345,   346,   347,   348,   349,   350,    92,    93,    94,    95,
      96,    97,   393,   358,   100,     4,   122,   103,   104,     4,
     365,     4,   367,   368,    96,     4,     4,   108,     4,     4,
     111,   412,     4,   114,   115,   116,   117,   118,   119,   120,
     121,    11,   387,    50,   102,   142,   107,   392,   271,   394,
     413,    92,    93,    94,    95,    96,   188,   438,   153,   100,
     154,   286,   246,   104,   363,   410,   411,   415,   365,   213,
     415,   192,   248,   144,   291,     5,   172,     7,     8,     9,
     425,    11,    12,   428,    -1,   430,    16,    17,    -1,    -1,
      -1,    21,    22,    92,    93,    94,    95,    -1,    97,    29,
      30,   100,    -1,    33,    -1,   104,    16,    17,    18,    19,
      20,   444,    92,    93,    94,    95,    96,    97,    98,    99,
     100,    -1,    -1,   103,   104,    -1,    92,    93,    94,    95,
      60,    -1,    62,    63,   100,    -1,    -1,    -1,   104,    -1,
      -1,    71,    -1,    -1,    -1,    75,    -1,    77,    -1,    -1,
      60,    61,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    92,    93,    94,    95,    96,    -1,    -1,    -1,
     100,    -1,    -1,   103,   104,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    92,    93,    94,    95,    96,    97,    98,    99,
     100,    -1,   122,   103,   104,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   113,   114,   115,    92,    93,    94,    95,
      96,    97,    98,    99,   100,    -1,    -1,    -1,   104,    92,
      93,    94,    95,    -1,    97,    98,    99,   100,    -1,    -1,
      -1,   104
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const unsigned char yystos[] =
{
       0,     4,    21,    23,    27,    30,    59,    74,    90,   101,
     126,   127,   128,   129,   130,   137,   139,   140,   147,   154,
     111,    96,   148,   131,    47,    48,    49,    50,    51,    96,
     193,   194,   155,   138,     4,     0,   128,   217,   218,   141,
      96,   103,   213,   193,    96,    96,    89,   101,   105,   106,
     132,   133,   139,   182,   183,   184,   112,    70,    92,    93,
      94,    95,    97,    98,    99,   100,   104,   209,   216,   219,
     221,   222,   223,     4,    82,    83,    84,    85,    86,    87,
      88,   164,   165,   166,    96,   110,   165,     4,    91,   133,
      74,   134,   135,   184,   216,    70,    68,   124,     4,    25,
      26,   142,   143,   144,   145,   146,     4,    68,   110,   223,
       4,   165,     4,   103,   216,   220,   221,   193,    96,    24,
     144,   149,   166,   223,   156,    89,    96,   103,   136,   209,
     210,   211,   212,   214,   215,   216,   221,    96,    96,     4,
     150,     4,   157,   111,    68,     4,     4,     5,   101,   105,
     106,   151,   153,   179,   180,   181,     5,   153,   158,   217,
     212,   152,     4,     4,    69,   181,   182,   185,   159,     4,
     112,   193,     5,     7,     8,     9,    11,    12,    16,    17,
      21,    22,    29,    30,    33,    60,    62,    63,    71,    75,
      77,    96,   103,   160,   173,   175,   186,   195,   197,   198,
     199,   200,   202,   207,   209,   193,    96,   190,   222,   214,
     214,   216,   216,   216,   196,   191,    96,    96,   187,   188,
     189,    94,    97,   224,   216,   216,   164,     4,     4,   210,
       4,   122,   203,    34,    35,    36,    37,    38,    39,    40,
      41,    42,    43,    44,   107,   109,   110,   111,   201,    96,
     193,     8,    53,    54,    55,    56,    57,    58,    68,   208,
       8,    68,   208,   136,   136,   193,   193,   193,   110,     4,
     174,   176,   206,   209,   122,   216,   216,   216,   216,   216,
     216,   216,   216,   216,   216,   216,    16,    17,    18,    19,
      20,    60,    61,   103,   113,   114,   115,   192,   202,   209,
     216,   217,    97,   209,   213,    96,   214,   214,   216,   214,
     214,   216,    96,    96,    96,   216,   161,   177,   177,    68,
     123,    10,   204,   205,   216,   194,   216,   224,    96,   136,
     216,   216,   216,    96,    45,    46,    52,    64,    65,    66,
      67,   108,   111,   114,   115,   116,   117,   118,   119,   120,
     121,   112,     8,     8,   110,   110,   168,     4,    63,    76,
     178,    78,   209,   110,   209,    68,   123,    68,    68,    68,
     216,   216,   216,   216,   216,   216,   216,   216,   217,   216,
     216,   216,   216,   216,   216,   216,   216,   110,   214,   214,
     223,   223,     9,    10,    81,   163,   169,   216,     4,   200,
     209,   205,   216,   216,    96,   112,   216,   216,   209,   216,
      73,    79,    80,   167,     4,   122,     4,   216,   216,    97,
     209,   162,   184,   204,     4,    68,     4,     4,    68,     4,
      68,   170,     4,   123,   216,   216,   216,    29,    62,    72,
     171,     4,     4,     4,   172,   209,     4,   193,    96
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
#line 322 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 5:
#line 331 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; cur_unit = 0; }
    break;

  case 6:
#line 332 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; }
    break;

  case 7:
#line 333 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; }
    break;

  case 8:
#line 334 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; }
    break;

  case 9:
#line 335 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; imc_close_unit(interp, cur_unit); cur_unit = 0; }
    break;

  case 10:
#line 336 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; imc_close_unit(interp, cur_unit); cur_unit = 0; }
    break;

  case 11:
#line 337 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; imc_close_unit(interp, cur_unit); cur_unit = 0; }
    break;

  case 12:
#line 338 "imcc/imcc.y"
    { yyval.i = 0;  imc_close_unit(interp, cur_unit); cur_unit = 0; }
    break;

  case 13:
#line 339 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 14:
#line 344 "imcc/imcc.y"
    {
            fataly(EX_SOFTWARE, sourcefile, line, ".global not implemented yet\n");
            yyval.i = 0;
         }
    break;

  case 15:
#line 349 "imcc/imcc.y"
    {
            fataly(EX_SOFTWARE, sourcefile, line, ".global not implemented yet\n");
            yyval.i = 0;
         }
    break;

  case 16:
#line 356 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 17:
#line 357 "imcc/imcc.y"
    { mk_const_ident(yyvsp[-2].s, yyvsp[-3].t, yyvsp[0].sr, 1);is_def=0; }
    break;

  case 20:
#line 366 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 21:
#line 367 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 22:
#line 368 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 23:
#line 369 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 24:
#line 370 "imcc/imcc.y"
    { yyval.i = yyvsp[0].i; }
    break;

  case 25:
#line 373 "imcc/imcc.y"
    { clear_state(); }
    break;

  case 26:
#line 375 "imcc/imcc.y"
    { yyval.i = INS(interp, cur_unit, yyvsp[-1].s,0,regs,nargs,keyvec,1);
                     free(yyvsp[-1].s); }
    break;

  case 27:
#line 378 "imcc/imcc.y"
    {
                     yyval.i = iSUBROUTINE(cur_unit, mk_sub_label(yyvsp[0].s));
                     yyval.i->r[1] = mk_pcc_sub(str_dup(yyval.i->r[0]->name), 0);
                     add_namespace(interp, yyval.i->r[1]);
                     yyval.i->r[1]->pcc_sub->pragma = yyvsp[-1].t;
                   }
    break;

  case 28:
#line 384 "imcc/imcc.y"
    { yyval.i = 0;}
    break;

  case 30:
#line 392 "imcc/imcc.y"
    { cur_unit = imc_open_unit(interp, IMC_PASM);
                     function = "(emit)"; }
    break;

  case 31:
#line 395 "imcc/imcc.y"
    { /*
                      if (optimizer_level & OPT_PASM)
                         imc_compile_unit(interp, IMC_INFO(interp)->cur_unit);
                         emit_flush(interp);
                     */
                     yyval.i=0; }
    break;

  case 32:
#line 404 "imcc/imcc.y"
    { yyval.i=0;
                                 IMCC_INFO(interp)->cur_namespace = yyvsp[-1].sr;
                                 cur_namespace = yyvsp[-1].sr;
                                 }
    break;

  case 33:
#line 412 "imcc/imcc.y"
    {
                      Symbol * sym = new_symbol(yyvsp[0].s);
                      cur_unit = imc_open_unit(interp, IMC_CLASS);
                      current_class = new_class(sym);
                      sym->p = (void*)current_class;
                      store_symbol(&global_sym_tab, sym); }
    break;

  case 34:
#line 419 "imcc/imcc.y"
    {
                      /* Do nothing for now. Need to parse metadata for
                       * PBC creation. */
                      current_class = NULL;
                      yyval.i = 0; }
    break;

  case 36:
#line 428 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 41:
#line 439 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 42:
#line 444 "imcc/imcc.y"
    {
                      Symbol * sym = new_symbol(yyvsp[-1].s);
                      if(lookup_field_symbol(current_class, yyvsp[-1].s)) {
                         fataly(EX_SOFTWARE, sourcefile, line,
                            "field '%s' previously declared in class '%s'\n",
                            yyvsp[-1].s, current_class->sym->name);
                      }
                      sym->type = yyvsp[-2].t;
                      store_field_symbol(current_class, sym);
                      yyval.i = 0; }
    break;

  case 43:
#line 458 "imcc/imcc.y"
    {
           Method * meth;
           Symbol * sym = new_symbol(yyvsp[-2].s);
           if(lookup_method_symbol(current_class, yyvsp[-2].s)) {
              fataly(EX_SOFTWARE, sourcefile, line,
                 "method '%s' previously declared in class '%s'\n",
                    yyvsp[-2].s, current_class->sym->name);
           }
           meth = new_method(sym, new_symbol(yyvsp[-1].s));
           store_method_symbol(current_class, sym);
           yyval.i = 0;
        }
    break;

  case 44:
#line 474 "imcc/imcc.y"
    {
           cur_unit = (pragmas.fastcall ? imc_open_unit(interp, IMC_FASTSUB)
                                          : imc_open_unit(interp, IMC_PCCSUB));
        }
    break;

  case 45:
#line 479 "imcc/imcc.y"
    {
          Instruction *i = iSUBROUTINE(cur_unit, yyvsp[-2].sr);
          i->r[1] = yyval.sr = mk_pcc_sub(str_dup(i->r[0]->name), 0);
          add_namespace(interp, i->r[1]);
          i->r[1]->pcc_sub->pragma = yyvsp[-1].t;
        }
    break;

  case 46:
#line 486 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 47:
#line 490 "imcc/imcc.y"
    { yyval.sr = 0; }
    break;

  case 48:
#line 491 "imcc/imcc.y"
    { yyval.sr = 0; }
    break;

  case 49:
#line 492 "imcc/imcc.y"
    { add_pcc_param(yyvsp[-3].sr, yyvsp[-1].sr);}
    break;

  case 50:
#line 496 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 51:
#line 497 "imcc/imcc.y"
    { yyval.sr = mk_ident(yyvsp[0].s, yyvsp[-1].t); is_def=0; }
    break;

  case 52:
#line 501 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 53:
#line 505 "imcc/imcc.y"
    { cur_unit = imc_open_unit(interp, IMC_PCCSUB); }
    break;

  case 54:
#line 507 "imcc/imcc.y"
    {
            Instruction *i = iSUBROUTINE(cur_unit, mk_sub_label(yyvsp[-2].s));
            i->r[1] = yyval.sr = mk_pcc_sub(str_dup(i->r[0]->name), 0);
            add_namespace(interp, i->r[1]);
            i->r[1]->pcc_sub->pragma = yyvsp[-1].t;
         }
    break;

  case 55:
#line 514 "imcc/imcc.y"
    { yyval.i = 0; }
    break;

  case 56:
#line 518 "imcc/imcc.y"
    { yyval.sr = 0; }
    break;

  case 57:
#line 519 "imcc/imcc.y"
    { yyval.sr = 0; }
    break;

  case 58:
#line 520 "imcc/imcc.y"
    { add_pcc_param(yyvsp[-3].sr, yyvsp[-1].sr);}
    break;

  case 59:
#line 524 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 60:
#line 525 "imcc/imcc.y"
    { yyval.sr = mk_ident(yyvsp[0].s, yyvsp[-1].t); is_def=0; }
    break;

  case 61:
#line 530 "imcc/imcc.y"
    {
            char name[128];
            SymReg * r, *r1;
            Instruction *i;

            sprintf(name, "%cpcc_sub_call_%d", IMCC_INTERNAL_CHAR, cnr++);
            yyval.sr = r = mk_pcc_sub(str_dup(name), 0);
            r->pcc_sub->pragma = yyvsp[-1].t;
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
                r1->pcc_sub->calls_a_sub = 1;
         }
    break;

  case 62:
#line 557 "imcc/imcc.y"
    { yyval.i = 0; current_call = NULL; }
    break;

  case 63:
#line 561 "imcc/imcc.y"
    { yyval.i = NULL;  current_call->r[0]->pcc_sub->label = 0; }
    break;

  case 64:
#line 562 "imcc/imcc.y"
    { yyval.i = NULL;  current_call->r[0]->pcc_sub->label = 1; }
    break;

  case 65:
#line 566 "imcc/imcc.y"
    { yyval.i = NULL; }
    break;

  case 66:
#line 568 "imcc/imcc.y"
    { yyval.i = NULL;  current_call->r[0]->pcc_sub->object = yyvsp[-1].sr; }
    break;

  case 67:
#line 571 "imcc/imcc.y"
    {  yyval.t = P_PROTOTYPED ; }
    break;

  case 68:
#line 572 "imcc/imcc.y"
    {  yyval.t = P_NON_PROTOTYPED ; }
    break;

  case 69:
#line 576 "imcc/imcc.y"
    {  yyval.t = P_NONE; }
    break;

  case 70:
#line 577 "imcc/imcc.y"
    { yyval.t |= yyvsp[0].t; }
    break;

  case 71:
#line 578 "imcc/imcc.y"
    { yyval.t |= yyvsp[0].t; }
    break;

  case 73:
#line 582 "imcc/imcc.y"
    {  yyval.t = P_LOAD; }
    break;

  case 74:
#line 583 "imcc/imcc.y"
    {  yyval.t = P_MAIN; }
    break;

  case 75:
#line 584 "imcc/imcc.y"
    {  yyval.t = P_IMMEDIATE; }
    break;

  case 76:
#line 585 "imcc/imcc.y"
    {  yyval.t = P_POSTCOMP; }
    break;

  case 77:
#line 586 "imcc/imcc.y"
    {  yyval.t = P_METHOD | P_NONE ; }
    break;

  case 78:
#line 591 "imcc/imcc.y"
    {
            add_pcc_sub(current_call->r[0], yyvsp[-3].sr);
            add_pcc_cc(current_call->r[0], yyvsp[-1].sr);
         }
    break;

  case 79:
#line 596 "imcc/imcc.y"
    {  add_pcc_sub(current_call->r[0], yyvsp[-1].sr); }
    break;

  case 80:
#line 598 "imcc/imcc.y"
    {
            add_pcc_sub(current_call->r[0], yyvsp[-1].sr);
            current_call->r[0]->pcc_sub->nci = 1;
         }
    break;

  case 81:
#line 603 "imcc/imcc.y"
    {  add_pcc_sub(current_call->r[0], yyvsp[-1].sr); }
    break;

  case 82:
#line 605 "imcc/imcc.y"
    {  add_pcc_sub(current_call->r[0], mk_const(yyvsp[-1].s,'S')); }
    break;

  case 83:
#line 607 "imcc/imcc.y"
    {  add_pcc_sub(current_call->r[0], yyvsp[-3].sr);
            add_pcc_cc(current_call->r[0], yyvsp[-1].sr);
         }
    break;

  case 84:
#line 611 "imcc/imcc.y"
    {  add_pcc_sub(current_call->r[0], mk_const(yyvsp[-3].s,'S'));
            add_pcc_cc(current_call->r[0], yyvsp[-1].sr);
         }
    break;

  case 85:
#line 617 "imcc/imcc.y"
    {  yyval.sr = 0; }
    break;

  case 86:
#line 618 "imcc/imcc.y"
    {  add_pcc_arg(current_call->r[0], yyvsp[-1].sr);}
    break;

  case 87:
#line 622 "imcc/imcc.y"
    {  yyval.sr = yyvsp[0].sr; }
    break;

  case 88:
#line 623 "imcc/imcc.y"
    {  yyvsp[0].sr->type |= VT_FLATTEN; yyval.sr = yyvsp[0].sr; }
    break;

  case 89:
#line 627 "imcc/imcc.y"
    {  yyval.sr = 0; }
    break;

  case 90:
#line 628 "imcc/imcc.y"
    {  if(yyvsp[-1].sr) add_pcc_result(current_call->r[0], yyvsp[-1].sr); }
    break;

  case 91:
#line 633 "imcc/imcc.y"
    {  yyval.sr = yyvsp[0].sr; }
    break;

  case 92:
#line 634 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 93:
#line 635 "imcc/imcc.y"
    {  mk_ident(yyvsp[0].s, yyvsp[-1].t); is_def=0; yyval.sr=0; }
    break;

  case 94:
#line 640 "imcc/imcc.y"
    {
            Instruction *i, *ins;
            SymReg *r;
            char name[128];
            ins = cur_unit->instructions;
            if(!ins || !ins->r[1] || ins->r[1]->type != VT_PCC_SUB)
               fataly(EX_SOFTWARE, sourcefile, line,
                      "pcc_return not inside pcc subroutine\n");
            sprintf(name, "%cpcc_sub_ret_%d", IMCC_INTERNAL_CHAR, cnr++);
            yyval.sr = r = mk_pcc_sub(str_dup(name), 0);
            i = iLABEL(cur_unit, r);
            i->type = ITPCCSUB | ITLABEL;
         }
    break;

  case 95:
#line 655 "imcc/imcc.y"
    {  yyval.i = 0; }
    break;

  case 96:
#line 660 "imcc/imcc.y"
    {
            Instruction *i, *ins;
            SymReg *r;
            char name[128];
            ins = cur_unit->instructions;
            if(!ins || !ins->r[1] || ins->r[1]->type != VT_PCC_SUB)
               fataly(EX_SOFTWARE, sourcefile, line,
                      "pcc_yield not inside pcc subroutine\n");
            ins->r[1]->pcc_sub->calls_a_sub = 1;
            sprintf(name, "%cpcc_sub_yield_%d", IMCC_INTERNAL_CHAR, cnr++);
            yyval.sr = r = mk_pcc_sub(str_dup(name), 0);
            i = iLABEL(cur_unit, r);
            i->type = ITPCCSUB | ITLABEL | ITPCCYIELD;
         }
    break;

  case 97:
#line 676 "imcc/imcc.y"
    {  yyval.i = 0; }
    break;

  case 98:
#line 680 "imcc/imcc.y"
    {  yyval.sr = 0; }
    break;

  case 99:
#line 682 "imcc/imcc.y"
    {  if(yyvsp[-1].sr) add_pcc_return(yyvsp[-2].sr, yyvsp[-1].sr); }
    break;

  case 100:
#line 684 "imcc/imcc.y"
    {  if(yyvsp[-1].sr) add_pcc_return(yyvsp[-3].sr, yyvsp[-1].sr); }
    break;

  case 101:
#line 688 "imcc/imcc.y"
    {  yyval.sr = yyvsp[0].sr; }
    break;

  case 104:
#line 705 "imcc/imcc.y"
    { clear_state(); }
    break;

  case 105:
#line 710 "imcc/imcc.y"
    {  yyval.i = yyvsp[0].i; }
    break;

  case 106:
#line 711 "imcc/imcc.y"
    {  yyval.i = 0; }
    break;

  case 107:
#line 712 "imcc/imcc.y"
    {  yyval.i = 0; }
    break;

  case 108:
#line 713 "imcc/imcc.y"
    {  yyval.i = 0; }
    break;

  case 109:
#line 717 "imcc/imcc.y"
    {  yyval.i = NULL; }
    break;

  case 113:
#line 727 "imcc/imcc.y"
    {
                     /* $$ = iLABEL(cur_unit, mk_address(, U_add_uniq_label)); */
                     yyval.i = iLABEL(cur_unit, mk_local_label(cur_unit, yyvsp[0].s));
                   }
    break;

  case 114:
#line 735 "imcc/imcc.y"
    { yyval.i = yyvsp[-1].i; }
    break;

  case 117:
#line 741 "imcc/imcc.y"
    { push_namespace(yyvsp[0].s); }
    break;

  case 118:
#line 742 "imcc/imcc.y"
    { pop_namespace(yyvsp[0].s); }
    break;

  case 119:
#line 743 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 120:
#line 743 "imcc/imcc.y"
    { mk_ident(yyvsp[0].s, yyvsp[-1].t); is_def=0; }
    break;

  case 121:
#line 744 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 122:
#line 745 "imcc/imcc.y"
    { mk_const_ident(yyvsp[-2].s, yyvsp[-3].t, yyvsp[0].sr, 0);is_def=0; }
    break;

  case 123:
#line 746 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 124:
#line 747 "imcc/imcc.y"
    { mk_const_ident(yyvsp[-2].s, yyvsp[-3].t, yyvsp[0].sr, 1);is_def=0; }
    break;

  case 125:
#line 748 "imcc/imcc.y"
    { is_def=1; }
    break;

  case 126:
#line 748 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "restore",
		                            1, mk_ident(yyvsp[0].s, yyvsp[-1].t));is_def=0; }
    break;

  case 127:
#line 750 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "restore", 1, yyvsp[0].sr); }
    break;

  case 128:
#line 751 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "restore", 1, yyvsp[0].sr); }
    break;

  case 129:
#line 752 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "save", 1, yyvsp[0].sr); }
    break;

  case 130:
#line 753 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "save", 1, yyvsp[0].sr); }
    break;

  case 131:
#line 754 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "bsr",  1, yyvsp[0].sr); }
    break;

  case 132:
#line 755 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "branch",1, yyvsp[0].sr); }
    break;

  case 133:
#line 756 "imcc/imcc.y"
    { expect_pasm = 1; }
    break;

  case 134:
#line 758 "imcc/imcc.y"
    { yyval.i = INS(interp, cur_unit, "newsub",0,regs,nargs,keyvec,1); }
    break;

  case 135:
#line 760 "imcc/imcc.y"
    { yyval.i = INS(interp, cur_unit, yyvsp[-1].s, 0, regs, nargs, keyvec, 1);
                                          free(yyvsp[-1].s); }
    break;

  case 136:
#line 762 "imcc/imcc.y"
    {  yyval.i = 0; current_call = NULL; }
    break;

  case 137:
#line 763 "imcc/imcc.y"
    {  yyval.i = 0; }
    break;

  case 140:
#line 766 "imcc/imcc.y"
    { yyval.i = 0;}
    break;

  case 141:
#line 770 "imcc/imcc.y"
    { yyval.t = NEWSUB; }
    break;

  case 142:
#line 771 "imcc/imcc.y"
    { yyval.t = NEWCLOSURE; }
    break;

  case 143:
#line 772 "imcc/imcc.y"
    { yyval.t = NEWCOR; }
    break;

  case 144:
#line 773 "imcc/imcc.y"
    { yyval.t = NEWCONT; }
    break;

  case 145:
#line 777 "imcc/imcc.y"
    { yyval.t = 'I'; }
    break;

  case 146:
#line 778 "imcc/imcc.y"
    { yyval.t = 'N'; }
    break;

  case 147:
#line 779 "imcc/imcc.y"
    { yyval.t = 'S'; }
    break;

  case 148:
#line 780 "imcc/imcc.y"
    { yyval.t = 'P'; }
    break;

  case 149:
#line 781 "imcc/imcc.y"
    { yyval.t = 'P'; }
    break;

  case 150:
#line 782 "imcc/imcc.y"
    { yyval.t = 'P'; free(yyvsp[0].s); }
    break;

  case 151:
#line 787 "imcc/imcc.y"
    {
            if (( cur_pmc_type = pmc_type(interp,
                  string_from_cstring(interp, yyvsp[0].s, 0))) <= 0) {
               fataly(1, sourcefile, line, "Unknown PMC type '%s'\n", yyvsp[0].s);
            }
         }
    break;

  case 152:
#line 796 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "set", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 153:
#line 797 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "not", 2, yyvsp[-3].sr, yyvsp[0].sr);}
    break;

  case 154:
#line 798 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "neg", 2, yyvsp[-3].sr, yyvsp[0].sr);}
    break;

  case 155:
#line 799 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "bnot", 2, yyvsp[-3].sr, yyvsp[0].sr);}
    break;

  case 156:
#line 800 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "add", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 157:
#line 801 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "sub", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 158:
#line 802 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "mul", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 159:
#line 803 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "pow", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 160:
#line 804 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "div", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 161:
#line 805 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "mod", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 162:
#line 806 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "concat", 3, yyvsp[-4].sr,yyvsp[-2].sr,yyvsp[0].sr); }
    break;

  case 163:
#line 808 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "shl", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 164:
#line 810 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "shr", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 165:
#line 812 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "lsr", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 166:
#line 814 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "and", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 167:
#line 816 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "or", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 168:
#line 818 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "xor", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 169:
#line 820 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "band", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 170:
#line 822 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "bor", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 171:
#line 824 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "bxor", 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 172:
#line 826 "imcc/imcc.y"
    { yyval.i = iINDEXFETCH(interp, cur_unit, yyvsp[-5].sr, yyvsp[-3].sr, yyvsp[-1].sr); }
    break;

  case 173:
#line 828 "imcc/imcc.y"
    { yyval.i = iINDEXSET(interp, cur_unit, yyvsp[-5].sr, yyvsp[-3].sr, yyvsp[0].sr); }
    break;

  case 174:
#line 830 "imcc/imcc.y"
    { yyval.i = iNEW(interp, cur_unit, yyvsp[-5].sr, yyvsp[-2].s, yyvsp[0].sr, 1); }
    break;

  case 175:
#line 832 "imcc/imcc.y"
    { yyval.i = iNEW(interp, cur_unit, yyvsp[-3].sr, yyvsp[0].s, NULL, 1); }
    break;

  case 176:
#line 834 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "new", 2, yyvsp[-3].sr, yyvsp[0].sr); }
    break;

  case 177:
#line 836 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "new", 3, yyvsp[-5].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 178:
#line 838 "imcc/imcc.y"
    { yyval.i = iNEWSUB(interp, cur_unit, yyvsp[-3].sr, yyvsp[-1].t,
                                          mk_sub_address(yyvsp[0].s), NULL, 1); }
    break;

  case 179:
#line 841 "imcc/imcc.y"
    { /* XXX: Fix 4arg version of newsub PASM op
                              * to use  instead of implicit P0
                              */
                              yyval.i = iNEWSUB(interp, cur_unit, NULL, yyvsp[-3].t,
                                           mk_sub_address(yyvsp[-2].s),
                                           mk_sub_address(yyvsp[0].s), 1); }
    break;

  case 180:
#line 848 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "set_addr",
                                    2, yyvsp[-3].sr, mk_label_address(cur_unit, yyvsp[0].s)); }
    break;

  case 181:
#line 851 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "find_global",2,yyvsp[-3].sr,yyvsp[0].sr);}
    break;

  case 182:
#line 853 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "store_global",2, yyvsp[-2].sr,yyvsp[0].sr); }
    break;

  case 183:
#line 857 "imcc/imcc.y"
    { expect_pasm = 1; }
    break;

  case 184:
#line 859 "imcc/imcc.y"
    { yyval.i = INS(interp, cur_unit, "new",0,regs,nargs,keyvec,1); }
    break;

  case 185:
#line 862 "imcc/imcc.y"
    {
            add_pcc_result(yyvsp[0].i->r[0], yyvsp[-2].sr);
            current_call = NULL;
            yyval.i = 0;
         }
    break;

  case 186:
#line 868 "imcc/imcc.y"
    {
            yyval.i = create_itcall_label();
         }
    break;

  case 187:
#line 872 "imcc/imcc.y"
    {
           itcall_sub(yyvsp[-3].sr);
           current_call = NULL;
         }
    break;

  case 190:
#line 882 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "add", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 191:
#line 884 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "sub", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 192:
#line 886 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "mul", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 193:
#line 888 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "div", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 194:
#line 890 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "concat", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 195:
#line 892 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "band", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 196:
#line 894 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "bor", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 197:
#line 896 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "bxor", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 198:
#line 898 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "shr", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 199:
#line 900 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "shl", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 200:
#line 902 "imcc/imcc.y"
    { yyval.i = MK_I(interp, cur_unit, "lsr", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 201:
#line 907 "imcc/imcc.y"
    { yyval.i = func_ins(interp, cur_unit, yyvsp[-3].sr, yyvsp[-1].s,
                                   regs,nargs,keyvec,1);
                     free(yyvsp[-1].s);
                   }
    break;

  case 202:
#line 913 "imcc/imcc.y"
    { yyval.sr = mk_sub_address(yyvsp[0].s); }
    break;

  case 203:
#line 914 "imcc/imcc.y"
    { yyval.sr = yyvsp[0].sr;
                       if (yyvsp[0].sr->set != 'P')
                          fataly(1, sourcefile, line, "Sub isn't a PMC");
                     }
    break;

  case 204:
#line 918 "imcc/imcc.y"
    { cur_obj = yyvsp[-2].sr; yyval.sr = yyvsp[0].sr; }
    break;

  case 205:
#line 919 "imcc/imcc.y"
    { cur_obj = yyvsp[-2].sr; yyval.sr = mk_const(yyvsp[0].s, 'S'); }
    break;

  case 206:
#line 920 "imcc/imcc.y"
    { cur_obj = yyvsp[-2].sr; yyval.sr = yyvsp[0].sr; }
    break;

  case 207:
#line 923 "imcc/imcc.y"
    { yyval.t=0; }
    break;

  case 208:
#line 924 "imcc/imcc.y"
    { yyval.t=0; }
    break;

  case 209:
#line 929 "imcc/imcc.y"
    {
           yyval.i = create_itcall_label();
           itcall_sub(yyvsp[0].sr);
        }
    break;

  case 210:
#line 934 "imcc/imcc.y"
    {  yyval.i = yyvsp[-3].i; }
    break;

  case 211:
#line 938 "imcc/imcc.y"
    {  yyval.symlist = 0; }
    break;

  case 212:
#line 939 "imcc/imcc.y"
    {  yyval.symlist = 0; add_pcc_arg(current_call->r[0], yyvsp[0].sr); }
    break;

  case 213:
#line 940 "imcc/imcc.y"
    {  yyval.symlist = 0; add_pcc_arg(current_call->r[0], yyvsp[0].sr); }
    break;

  case 214:
#line 945 "imcc/imcc.y"
    { yyval.sr = yyvsp[0].sr; }
    break;

  case 215:
#line 947 "imcc/imcc.y"
    { yyvsp[0].sr->type |= VT_FLATTEN; yyval.sr = yyvsp[0].sr; }
    break;

  case 216:
#line 951 "imcc/imcc.y"
    { yyval.symlist = 0; add_pcc_result(current_call->r[0], yyvsp[0].sr); }
    break;

  case 217:
#line 952 "imcc/imcc.y"
    { yyval.symlist = 0; add_pcc_result(current_call->r[0], yyvsp[0].sr); }
    break;

  case 218:
#line 957 "imcc/imcc.y"
    {  yyval.i =MK_I(interp, cur_unit, yyvsp[-3].s, 3, yyvsp[-4].sr, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 219:
#line 959 "imcc/imcc.y"
    {  yyval.i =MK_I(interp, cur_unit, inv_op(yyvsp[-3].s), 3, yyvsp[-4].sr,yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 220:
#line 961 "imcc/imcc.y"
    {  yyval.i = MK_I(interp, cur_unit, "if", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 221:
#line 963 "imcc/imcc.y"
    {  yyval.i = MK_I(interp, cur_unit, "unless",2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 222:
#line 965 "imcc/imcc.y"
    {  yyval.i = MK_I(interp, cur_unit, "if", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 223:
#line 967 "imcc/imcc.y"
    {  yyval.i = MK_I(interp, cur_unit, "unless", 2, yyvsp[-2].sr, yyvsp[0].sr); }
    break;

  case 224:
#line 971 "imcc/imcc.y"
    {  yyval.s = "eq"; }
    break;

  case 225:
#line 972 "imcc/imcc.y"
    {  yyval.s = "ne"; }
    break;

  case 226:
#line 973 "imcc/imcc.y"
    {  yyval.s = "gt"; }
    break;

  case 227:
#line 974 "imcc/imcc.y"
    {  yyval.s = "ge"; }
    break;

  case 228:
#line 975 "imcc/imcc.y"
    {  yyval.s = "lt"; }
    break;

  case 229:
#line 976 "imcc/imcc.y"
    {  yyval.s = "le"; }
    break;

  case 232:
#line 985 "imcc/imcc.y"
    {  yyval.sr = NULL; }
    break;

  case 233:
#line 986 "imcc/imcc.y"
    {  yyval.sr = yyvsp[0].sr; }
    break;

  case 234:
#line 990 "imcc/imcc.y"
    { yyval.sr = regs[0]; }
    break;

  case 236:
#line 995 "imcc/imcc.y"
    {  regs[nargs++] = yyvsp[0].sr; }
    break;

  case 237:
#line 997 "imcc/imcc.y"
    {
                      regs[nargs++] = yyvsp[-3].sr;
                      keyvec |= KEY_BIT(nargs);
                      regs[nargs++] = yyvsp[-1].sr; yyval.sr = yyvsp[-3].sr;
                   }
    break;

  case 238:
#line 1005 "imcc/imcc.y"
    { yyval.sr = mk_sub_address(yyvsp[0].s); }
    break;

  case 239:
#line 1006 "imcc/imcc.y"
    { yyval.sr = mk_sub_address(yyvsp[0].s); }
    break;

  case 240:
#line 1010 "imcc/imcc.y"
    { yyval.sr = mk_label_address(cur_unit, yyvsp[0].s); }
    break;

  case 241:
#line 1011 "imcc/imcc.y"
    { yyval.sr = mk_label_address(cur_unit, yyvsp[0].s); }
    break;

  case 246:
#line 1024 "imcc/imcc.y"
    {  nkeys=0; in_slice = 0; }
    break;

  case 247:
#line 1025 "imcc/imcc.y"
    {  yyval.sr = link_keys(nkeys, keys); }
    break;

  case 248:
#line 1029 "imcc/imcc.y"
    {  keys[nkeys++] = yyvsp[0].sr; }
    break;

  case 249:
#line 1031 "imcc/imcc.y"
    {  keys[nkeys++] = yyvsp[0].sr; yyval.sr =  keys[0]; }
    break;

  case 250:
#line 1032 "imcc/imcc.y"
    { in_slice = 1; }
    break;

  case 251:
#line 1033 "imcc/imcc.y"
    { keys[nkeys++] = yyvsp[0].sr; yyval.sr =  keys[0]; }
    break;

  case 252:
#line 1037 "imcc/imcc.y"
    { if (in_slice) {
                         yyvsp[0].sr->type |= VT_START_SLICE | VT_END_SLICE;
                     }
                     yyval.sr = yyvsp[0].sr;
                   }
    break;

  case 253:
#line 1043 "imcc/imcc.y"
    { yyvsp[-2].sr->type |= VT_START_SLICE;  yyvsp[0].sr->type |= VT_END_SLICE;
                     keys[nkeys++] = yyvsp[-2].sr; yyval.sr = yyvsp[0].sr; }
    break;

  case 254:
#line 1045 "imcc/imcc.y"
    { yyvsp[0].sr->type |= VT_START_ZERO | VT_END_SLICE; yyval.sr = yyvsp[0].sr; }
    break;

  case 255:
#line 1046 "imcc/imcc.y"
    { yyvsp[-1].sr->type |= VT_START_SLICE | VT_END_INF; yyval.sr = yyvsp[-1].sr; }
    break;

  case 256:
#line 1050 "imcc/imcc.y"
    {  yyval.sr = mk_symreg(yyvsp[0].s, 'I'); }
    break;

  case 257:
#line 1051 "imcc/imcc.y"
    {  yyval.sr = mk_symreg(yyvsp[0].s, 'N'); }
    break;

  case 258:
#line 1052 "imcc/imcc.y"
    {  yyval.sr = mk_symreg(yyvsp[0].s, 'S'); }
    break;

  case 259:
#line 1053 "imcc/imcc.y"
    {  yyval.sr = mk_symreg(yyvsp[0].s, 'P'); }
    break;

  case 260:
#line 1054 "imcc/imcc.y"
    {  yyval.sr = mk_pasm_reg(yyvsp[0].s); }
    break;

  case 261:
#line 1058 "imcc/imcc.y"
    {  yyval.sr = mk_const(yyvsp[0].s, 'I'); }
    break;

  case 262:
#line 1059 "imcc/imcc.y"
    {  yyval.sr = mk_const(yyvsp[0].s, 'N'); }
    break;

  case 263:
#line 1060 "imcc/imcc.y"
    {  yyval.sr = mk_const(yyvsp[0].s, 'S'); }
    break;

  case 264:
#line 1064 "imcc/imcc.y"
    {  yyval.sr = mk_symreg(yyvsp[0].s, 'S'); }
    break;

  case 265:
#line 1065 "imcc/imcc.y"
    {  yyval.sr = mk_const(yyvsp[0].s, 'S'); }
    break;


    }

/* Line 1016 of /usr/share/bison/yacc.c.  */
#line 3212 "imcc/imcparser.c"

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


#line 1070 "imcc/imcc.y"



int yyerror(char * s)
{
    /* fprintf(stderr, "last token = [%s]\n", yylval.s); */
    fataly(EX_UNAVAILABLE, sourcefile, line, "%s\n", s);
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

