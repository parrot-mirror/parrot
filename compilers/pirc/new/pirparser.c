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
     TK_MACRO_PARAM = 258,
     TK_LABEL = 259,
     TK_DOTDOT = 260,
     TK_ENDM = 261,
     TK_NL = 262,
     TK_HLL = 263,
     TK_HLL_MAP = 264,
     TK_EMIT = 265,
     TK_EOM = 266,
     TK_N_OPERATORS = 267,
     TK_PRAGMA = 268,
     TK_LOADLIB = 269,
     TK_SUB = 270,
     TK_END = 271,
     TK_PARAM = 272,
     TK_LEX = 273,
     TK_LOCAL = 274,
     TK_NAMESPACE = 275,
     TK_INVOCANT = 276,
     TK_METH_CALL = 277,
     TK_GLOBALCONST = 278,
     TK_CONST = 279,
     TK_RETURN = 280,
     TK_YIELD = 281,
     TK_BEGIN_YIELD = 282,
     TK_END_YIELD = 283,
     TK_BEGIN_RETURN = 284,
     TK_END_RETURN = 285,
     TK_BEGIN_CALL = 286,
     TK_END_CALL = 287,
     TK_GET_RESULTS = 288,
     TK_CALL = 289,
     TK_ARG = 290,
     TK_RESULT = 291,
     TK_NCI_CALL = 292,
     TK_IDENT = 293,
     TK_STRINGC = 294,
     TK_INTC = 295,
     TK_NUMC = 296,
     TK_PASM_PREG = 297,
     TK_PASM_NREG = 298,
     TK_PASM_SREG = 299,
     TK_PASM_IREG = 300,
     TK_SYM_PREG = 301,
     TK_SYM_NREG = 302,
     TK_SYM_SREG = 303,
     TK_SYM_IREG = 304,
     TK_PARROT_OP = 305,
     TK_INT = 306,
     TK_NUM = 307,
     TK_PMC = 308,
     TK_STRING = 309,
     TK_IF = 310,
     TK_UNLESS = 311,
     TK_NULL = 312,
     TK_GOTO = 313,
     TK_ARROW = 314,
     TK_NE = 315,
     TK_EQ = 316,
     TK_LT = 317,
     TK_LE = 318,
     TK_GT = 319,
     TK_GE = 320,
     TK_USHIFT = 321,
     TK_RSHIFT = 322,
     TK_LSHIFT = 323,
     TK_FDIV = 324,
     TK_OR = 325,
     TK_AND = 326,
     TK_XOR = 327,
     TK_CONC = 328,
     TK_ASSIGN_USHIFT = 329,
     TK_ASSIGN_RSHIFT = 330,
     TK_ASSIGN_LSHIFT = 331,
     TK_ASSIGN_INC = 332,
     TK_ASSIGN_DEC = 333,
     TK_ASSIGN_MUL = 334,
     TK_ASSIGN_MOD = 335,
     TK_ASSIGN_POW = 336,
     TK_ASSIGN_DIV = 337,
     TK_ASSIGN_BOR = 338,
     TK_ASSIGN_BAND = 339,
     TK_ASSIGN_FDIV = 340,
     TK_ASSIGN_BNOT = 341,
     TK_ASSIGN_CONC = 342,
     TK_FLAG_INIT = 343,
     TK_FLAG_LOAD = 344,
     TK_FLAG_MAIN = 345,
     TK_FLAG_ANON = 346,
     TK_FLAG_METHOD = 347,
     TK_FLAG_OUTER = 348,
     TK_FLAG_VTABLE = 349,
     TK_FLAG_LEX = 350,
     TK_FLAG_MULTI = 351,
     TK_FLAG_POSTCOMP = 352,
     TK_FLAG_IMMEDIATE = 353,
     TK_FLAG_UNIQUE_REG = 354,
     TK_FLAG_NAMED = 355,
     TK_FLAG_SLURPY = 356,
     TK_FLAG_FLAT = 357,
     TK_FLAG_OPTIONAL = 358,
     TK_FLAG_OPT_FLAG = 359
   };
#endif
/* Tokens.  */
#define TK_MACRO_PARAM 258
#define TK_LABEL 259
#define TK_DOTDOT 260
#define TK_ENDM 261
#define TK_NL 262
#define TK_HLL 263
#define TK_HLL_MAP 264
#define TK_EMIT 265
#define TK_EOM 266
#define TK_N_OPERATORS 267
#define TK_PRAGMA 268
#define TK_LOADLIB 269
#define TK_SUB 270
#define TK_END 271
#define TK_PARAM 272
#define TK_LEX 273
#define TK_LOCAL 274
#define TK_NAMESPACE 275
#define TK_INVOCANT 276
#define TK_METH_CALL 277
#define TK_GLOBALCONST 278
#define TK_CONST 279
#define TK_RETURN 280
#define TK_YIELD 281
#define TK_BEGIN_YIELD 282
#define TK_END_YIELD 283
#define TK_BEGIN_RETURN 284
#define TK_END_RETURN 285
#define TK_BEGIN_CALL 286
#define TK_END_CALL 287
#define TK_GET_RESULTS 288
#define TK_CALL 289
#define TK_ARG 290
#define TK_RESULT 291
#define TK_NCI_CALL 292
#define TK_IDENT 293
#define TK_STRINGC 294
#define TK_INTC 295
#define TK_NUMC 296
#define TK_PASM_PREG 297
#define TK_PASM_NREG 298
#define TK_PASM_SREG 299
#define TK_PASM_IREG 300
#define TK_SYM_PREG 301
#define TK_SYM_NREG 302
#define TK_SYM_SREG 303
#define TK_SYM_IREG 304
#define TK_PARROT_OP 305
#define TK_INT 306
#define TK_NUM 307
#define TK_PMC 308
#define TK_STRING 309
#define TK_IF 310
#define TK_UNLESS 311
#define TK_NULL 312
#define TK_GOTO 313
#define TK_ARROW 314
#define TK_NE 315
#define TK_EQ 316
#define TK_LT 317
#define TK_LE 318
#define TK_GT 319
#define TK_GE 320
#define TK_USHIFT 321
#define TK_RSHIFT 322
#define TK_LSHIFT 323
#define TK_FDIV 324
#define TK_OR 325
#define TK_AND 326
#define TK_XOR 327
#define TK_CONC 328
#define TK_ASSIGN_USHIFT 329
#define TK_ASSIGN_RSHIFT 330
#define TK_ASSIGN_LSHIFT 331
#define TK_ASSIGN_INC 332
#define TK_ASSIGN_DEC 333
#define TK_ASSIGN_MUL 334
#define TK_ASSIGN_MOD 335
#define TK_ASSIGN_POW 336
#define TK_ASSIGN_DIV 337
#define TK_ASSIGN_BOR 338
#define TK_ASSIGN_BAND 339
#define TK_ASSIGN_FDIV 340
#define TK_ASSIGN_BNOT 341
#define TK_ASSIGN_CONC 342
#define TK_FLAG_INIT 343
#define TK_FLAG_LOAD 344
#define TK_FLAG_MAIN 345
#define TK_FLAG_ANON 346
#define TK_FLAG_METHOD 347
#define TK_FLAG_OUTER 348
#define TK_FLAG_VTABLE 349
#define TK_FLAG_LEX 350
#define TK_FLAG_MULTI 351
#define TK_FLAG_POSTCOMP 352
#define TK_FLAG_IMMEDIATE 353
#define TK_FLAG_UNIQUE_REG 354
#define TK_FLAG_NAMED 355
#define TK_FLAG_SLURPY 356
#define TK_FLAG_FLAT 357
#define TK_FLAG_OPTIONAL 358
#define TK_FLAG_OPT_FLAG 359




/* Copy the first part of user declarations.  */
#line 1 "pir.y"


/*
 * $Id$
 * Copyright (C) 2007, The Perl Foundation.
 */

/*

=head1 NAME

pir.y

=head1 DESCRIPTION

This is a complete rewrite of the parser for the PIR language.

=cut

*/

#include <stdio.h>
#include <stdlib.h>

#include "pirparser.h"
#include "pircompiler.h"

/* prevent inclusion of <unistd.h> on windows */
#define YY_NO_UNISTD_H

/* define YY_DECL, so that in "pirlexer.h" it won't be defined */
#define YY_DECL int yylex(YYSTYPE *yylval,  yyscan_t yyscanner)

#include "pirlexer.h"




/* declare yylex() */
extern YY_DECL;

extern int yyerror(yyscan_t yyscanner,
                   struct lexer_state * const lexer, char const * const message);

extern struct lexer_state *new_lexer(char * const filename);





/* enable debugging of generated parser */
#define YYDEBUG         1

/* enable slightly more helpful error messages */
#define YYERROR_VERBOSE 1

/* keep MSVC happy */
#ifndef YYENABLE_NLS
#  define YYENABLE_NLS 0
#endif

/* keep MSVC happy */
#ifndef YYLTYPE_IS_TRIVIAL
#  define YYLTYPE_IS_TRIVIAL 0
#endif






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
#line 189 "pir.y"
{
    double dval;
    int    ival;
    char  *sval;
}
/* Line 187 of yacc.c.  */
#line 381 "pirparser.c"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



/* Copy the second part of user declarations.  */


/* Line 216 of yacc.c.  */
#line 394 "pirparser.c"

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
#define YYFINAL  4
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   473

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  120
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  100
/* YYNRULES -- Number of rules.  */
#define YYNRULES  247
/* YYNRULES -- Number of states.  */
#define YYNSTATES  397

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   359

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,   112,     2,     2,     2,   117,     2,     2,
     108,   109,   116,   114,   105,   111,   119,   115,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,   118,
       2,   110,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,   106,     2,   107,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,   113,     2,     2,     2,
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
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      65,    66,    67,    68,    69,    70,    71,    72,    73,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89,    90,    91,    92,    93,    94,
      95,    96,    97,    98,    99,   100,   101,   102,   103,   104
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint16 yyprhs[] =
{
       0,     0,     3,     7,     8,    10,    12,    16,    18,    20,
      22,    24,    26,    28,    30,    32,    36,    39,    44,    49,
      54,    55,    58,    61,    64,    66,    70,    72,    77,    79,
      83,    91,    93,    95,    96,    99,   101,   103,   105,   107,
     109,   111,   116,   119,   124,   126,   128,   129,   133,   135,
     137,   139,   141,   142,   145,   150,   153,   158,   159,   162,
     165,   168,   170,   172,   174,   176,   178,   180,   182,   184,
     186,   188,   190,   192,   194,   196,   198,   201,   205,   210,
     216,   219,   223,   226,   230,   233,   236,   238,   242,   245,
     247,   250,   252,   254,   257,   258,   260,   262,   266,   268,
     271,   273,   275,   277,   279,   281,   283,   285,   287,   289,
     291,   293,   295,   297,   299,   301,   303,   305,   307,   309,
     311,   313,   315,   319,   321,   325,   327,   330,   334,   337,
     339,   341,   345,   349,   353,   358,   360,   364,   366,   369,
     371,   373,   379,   381,   383,   392,   393,   396,   401,   404,
     407,   413,   414,   417,   422,   424,   431,   435,   438,   439,
     441,   443,   447,   450,   451,   454,   456,   458,   460,   463,
     465,   467,   469,   471,   473,   475,   480,   482,   484,   486,
     488,   490,   492,   494,   496,   502,   504,   506,   510,   514,
     518,   522,   523,   525,   527,   531,   534,   538,   544,   545,
     548,   553,   554,   557,   562,   563,   566,   568,   571,   572,
     574,   578,   581,   584,   588,   593,   598,   603,   608,   611,
     613,   615,   619,   621,   623,   625,   627,   629,   631,   633,
     635,   637,   639,   641,   643,   645,   647,   649,   651,   653,
     655,   657,   659,   661,   663,   665,   667,   669
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int16 yyrhs[] =
{
     121,     0,    -1,   122,   123,   122,    -1,    -1,     7,    -1,
     124,    -1,   123,     7,   124,    -1,   135,    -1,   208,    -1,
     133,    -1,   129,    -1,   127,    -1,   128,    -1,   126,    -1,
     125,    -1,    13,    12,    40,    -1,    14,    39,    -1,     8,
      39,   105,    39,    -1,     9,    39,   105,    39,    -1,    10,
       7,   130,    11,    -1,    -1,   130,   131,    -1,     4,     7,
      -1,     4,   132,    -1,   132,    -1,    50,   154,     7,    -1,
      20,    -1,    20,   106,   134,   107,    -1,    39,    -1,   134,
     164,    39,    -1,    15,   136,   137,     7,   141,   144,    16,
      -1,   171,    -1,    39,    -1,    -1,   137,   138,    -1,    91,
      -1,    88,    -1,    89,    -1,    90,    -1,    92,    -1,    95,
      -1,    93,   108,   136,   109,    -1,    94,   206,    -1,    96,
     108,   139,   109,    -1,    97,    -1,    98,    -1,    -1,   139,
     105,   140,    -1,   171,    -1,    39,    -1,   161,    -1,   218,
      -1,    -1,   141,   142,    -1,    17,   143,   184,     7,    -1,
     218,   171,    -1,   218,    39,    59,   171,    -1,    -1,   144,
     145,    -1,     4,     7,    -1,     4,   146,    -1,   146,    -1,
     165,    -1,   166,    -1,   167,    -1,   168,    -1,   172,    -1,
     209,    -1,   190,    -1,   192,    -1,   173,    -1,   150,    -1,
     149,    -1,   132,    -1,   148,    -1,   147,    -1,     1,     7,
      -1,    57,   219,     7,    -1,   219,   110,    57,     7,    -1,
      33,   108,   181,   109,     7,    -1,   188,     7,    -1,   219,
     151,     7,    -1,   160,   213,    -1,   161,   110,   213,    -1,
     110,   152,    -1,   158,   213,    -1,   213,    -1,   213,   159,
     213,    -1,   219,   161,    -1,   157,    -1,    39,   195,    -1,
     188,    -1,   153,    -1,    50,   155,    -1,    -1,   155,    -1,
     156,    -1,   155,   105,   156,    -1,   213,    -1,   187,   195,
      -1,   111,    -1,   112,    -1,   113,    -1,   114,    -1,   111,
      -1,   115,    -1,   116,    -1,   117,    -1,    73,    -1,    77,
      -1,    78,    -1,    79,    -1,    81,    -1,    82,    -1,    85,
      -1,    83,    -1,    84,    -1,    86,    -1,    87,    -1,    75,
      -1,    76,    -1,    74,    -1,   106,   162,   107,    -1,   163,
      -1,   162,   164,   163,    -1,   213,    -1,   213,     5,    -1,
     213,     5,   213,    -1,     5,   213,    -1,   118,    -1,   105,
      -1,    55,   211,   167,    -1,    56,   211,   167,    -1,    58,
     171,     7,    -1,    19,   218,   169,     7,    -1,   170,    -1,
     169,   105,   170,    -1,   171,    -1,   171,    99,    -1,    38,
      -1,    50,    -1,    18,    39,   105,   219,     7,    -1,   174,
      -1,   180,    -1,    31,     7,   175,   177,     7,   178,    32,
       7,    -1,    -1,   175,   176,    -1,    35,   213,   204,     7,
      -1,    34,   187,    -1,    37,   187,    -1,    21,   187,     7,
      22,   189,    -1,    -1,   178,   179,    -1,    36,   219,   184,
       7,    -1,   168,    -1,   108,   181,   109,   110,   186,     7,
      -1,    39,   195,     7,    -1,   157,     7,    -1,    -1,   182,
      -1,   183,    -1,   182,   105,   183,    -1,   219,   184,    -1,
      -1,   184,   185,    -1,   103,    -1,   104,    -1,   101,    -1,
     100,   206,    -1,    99,    -1,   157,    -1,   188,    -1,    46,
      -1,    42,    -1,   171,    -1,   187,   119,   189,   195,    -1,
     171,    -1,    39,    -1,    48,    -1,    44,    -1,    42,    -1,
      46,    -1,   193,    -1,   191,    -1,    29,     7,   202,    30,
       7,    -1,   194,    -1,   199,    -1,    25,   195,     7,    -1,
      25,   186,     7,    -1,    26,   195,     7,    -1,   108,   196,
     109,    -1,    -1,   197,    -1,   198,    -1,   197,   105,   198,
      -1,   213,   204,    -1,    39,    59,   213,    -1,    27,     7,
     200,    28,     7,    -1,    -1,   200,   201,    -1,    26,   213,
     204,     7,    -1,    -1,   202,   203,    -1,    25,   213,   204,
       7,    -1,    -1,   204,   205,    -1,   102,    -1,   100,   206,
      -1,    -1,   207,    -1,   108,    39,   109,    -1,    24,   210,
      -1,   208,     7,    -1,    23,   210,     7,    -1,    51,   171,
     110,    40,    -1,    52,   171,   110,    41,    -1,    53,   171,
     110,    39,    -1,    54,   171,   110,    39,    -1,    57,   213,
      -1,   213,    -1,   212,    -1,   213,   217,   213,    -1,   219,
      -1,   214,    -1,    39,    -1,    40,    -1,    41,    -1,    46,
      -1,    47,    -1,    49,    -1,    48,    -1,   216,    -1,    42,
      -1,    43,    -1,    45,    -1,    44,    -1,    60,    -1,    61,
      -1,    62,    -1,    63,    -1,    65,    -1,    64,    -1,    51,
      -1,    52,    -1,    53,    -1,    54,    -1,   215,    -1,   171,
      -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   223,   223,   228,   229,   232,   233,   236,   237,   238,
     239,   240,   241,   242,   243,   246,   249,   254,   257,   262,
     268,   269,   272,   273,   274,   277,   282,   283,   286,   287,
     292,   298,   299,   302,   303,   306,   307,   308,   309,   310,
     311,   312,   313,   314,   315,   316,   319,   320,   323,   324,
     325,   326,   329,   330,   333,   336,   337,   343,   344,   348,
     349,   350,   353,   354,   355,   356,   357,   358,   359,   360,
     361,   362,   363,   364,   365,   366,   367,   370,   371,   374,
     377,   380,   383,   384,   385,   388,   389,   390,   391,   392,
     393,   394,   395,   399,   402,   403,   406,   407,   410,   414,
     417,   418,   419,   422,   423,   424,   425,   426,   427,   431,
     432,   433,   434,   435,   436,   437,   438,   439,   440,   441,
     442,   443,   446,   449,   450,   453,   454,   455,   456,   459,
     460,   464,   467,   470,   473,   476,   477,   480,   481,   484,
     485,   488,   491,   492,   495,   502,   503,   506,   509,   510,
     511,   515,   516,   519,   520,   523,   524,   525,   528,   529,
     532,   533,   536,   539,   540,   543,   544,   545,   546,   547,
     550,   551,   554,   555,   556,   559,   562,   563,   564,   565,
     566,   567,   570,   571,   574,   580,   581,   584,   585,   588,
     591,   594,   595,   598,   599,   602,   603,   606,   611,   612,
     615,   618,   619,   622,   625,   626,   629,   630,   633,   634,
     637,   640,   643,   644,   647,   648,   649,   650,   653,   654,
     655,   658,   661,   662,   666,   667,   668,   671,   672,   673,
     674,   675,   679,   680,   681,   682,   685,   686,   687,   688,
     689,   690,   693,   694,   695,   696,   699,   700
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "TK_MACRO_PARAM", "\"label\"", "\"..\"",
  "\".endm\"", "\"\\n\"", "\".HLL\"", "\".HLL_map\"", "\".emit\"",
  "\".eom\"", "\"n_operators\"", "\".pragma\"", "\".loadlib\"", "\".sub\"",
  "\".end\"", "\".param\"", "\".lex\"", "\".local\"", "\".namespace\"",
  "\".invocant\"", "\".meth_call\"", "\".globalconst\"", "\".const\"",
  "\".return\"", "\".yield\"", "\".begin_yield\"", "\".end_yield\"",
  "\".begin_return\"", "\".end_return\"", "\".begin_call\"",
  "\".end_call\"", "\".get_results\"", "\".call\"", "\".arg\"",
  "\".result\"", "\".nci_call\"", "\"identifier\"", "\"string constant\"",
  "\"integer constant\"", "\"number constant\"", "\"PMC register\"",
  "\"Number register\"", "\"String register\"", "\"Integer register\"",
  "\"Symbolic PMC register\"", "\"Symbolic number register\"",
  "\"Symbolic string register\"", "\"Symbolic integer register\"",
  "\"parrot op\"", "\"int\"", "\"num\"", "\"pmc\"", "\"string\"", "\"if\"",
  "\"unless\"", "\"null\"", "\"goto\"", "\"=>\"", "\"!=\"", "\"==\"",
  "\"<\"", "\"<=\"", "\">\"", "\">=\"", "\">>>\"", "\">>\"", "\"<<\"",
  "\"//\"", "\"||\"", "\"&&\"", "\"^\"", "\".\"", "\">>>=\"", "\">>=\"",
  "\"<<=\"", "\"+=\"", "\"-=\"", "\"*=\"", "\"%=\"", "\"**=\"", "\"/=\"",
  "\"|=\"", "\"&=\"", "\"//=\"", "\"~=\"", "\".=\"", "\":init\"",
  "\":load\"", "\":main\"", "\":anon\"", "\":method\"", "\":outer\"",
  "\":vtable\"", "\":lex\"", "\":multi\"", "\":postcomp\"",
  "\":immediate\"", "\":unique_reg\"", "\":named\"", "\":slurpy\"",
  "\":flat\"", "\":optional\"", "\":opt_flag\"", "','", "'['", "']'",
  "'('", "')'", "'='", "'-'", "'!'", "'~'", "'+'", "'/'", "'*'", "'%'",
  "';'", "'.'", "$accept", "program", "opt_nl", "compilation_units",
  "compilation_unit", "pir_pragma", "loadlib", "hll_specifier",
  "hll_mapping", "emit_block", "pasm_instructions", "pasm_instruction",
  "parrot_statement", "namespace_declaration", "namespace_id",
  "sub_definition", "sub_id", "sub_flags", "sub_flag", "multi_type_list",
  "multi_type", "parameters", "parameter", "param_def", "instructions",
  "labeled_instruction", "instruction", "null_statement",
  "getresults_statement", "methodcall_statement", "assignment_statement",
  "assignment_tail", "assignment_expression", "parrot_instruction",
  "opt_parrot_op_args", "parrot_op_args", "parrot_op_arg",
  "simple_invocation", "unop", "binop", "augmented_op", "keylist", "keys",
  "key", "separator", "if_statement", "unless_statement", "goto_statement",
  "local_declaration", "local_id_list", "local_id", "identifier",
  "lex_declaration", "invocation_statement", "long_invocation_statement",
  "long_arguments", "long_argument", "long_invocation", "long_results",
  "long_result", "short_invocation_statement", "opt_target_list",
  "target_list", "result_target", "param_flags", "param_flag",
  "invocation_expression", "invokable", "methodcall", "method",
  "return_statement", "long_return_statement", "yield_statement",
  "short_return_statement", "short_yield_statement", "arguments",
  "opt_arguments_list", "arguments_list", "argument",
  "long_yield_statement", "yield_expressions", "yield_expression",
  "return_expressions", "return_expression", "arg_flags", "arg_flag",
  "opt_paren_string", "paren_string", "const_declaration",
  "const_decl_statement", "const_tail", "condition",
  "conditional_expression", "expression", "constant", "reg", "pasm_reg",
  "rel_op", "type", "target", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,   292,   293,   294,
     295,   296,   297,   298,   299,   300,   301,   302,   303,   304,
     305,   306,   307,   308,   309,   310,   311,   312,   313,   314,
     315,   316,   317,   318,   319,   320,   321,   322,   323,   324,
     325,   326,   327,   328,   329,   330,   331,   332,   333,   334,
     335,   336,   337,   338,   339,   340,   341,   342,   343,   344,
     345,   346,   347,   348,   349,   350,   351,   352,   353,   354,
     355,   356,   357,   358,   359,    44,    91,    93,    40,    41,
      61,    45,    33,   126,    43,    47,    42,    37,    59,    46
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,   120,   121,   122,   122,   123,   123,   124,   124,   124,
     124,   124,   124,   124,   124,   125,   126,   127,   128,   129,
     130,   130,   131,   131,   131,   132,   133,   133,   134,   134,
     135,   136,   136,   137,   137,   138,   138,   138,   138,   138,
     138,   138,   138,   138,   138,   138,   139,   139,   140,   140,
     140,   140,   141,   141,   142,   143,   143,   144,   144,   145,
     145,   145,   146,   146,   146,   146,   146,   146,   146,   146,
     146,   146,   146,   146,   146,   146,   146,   147,   147,   148,
     149,   150,   151,   151,   151,   152,   152,   152,   152,   152,
     152,   152,   152,   153,   154,   154,   155,   155,   156,   157,
     158,   158,   158,   159,   159,   159,   159,   159,   159,   160,
     160,   160,   160,   160,   160,   160,   160,   160,   160,   160,
     160,   160,   161,   162,   162,   163,   163,   163,   163,   164,
     164,   165,   166,   167,   168,   169,   169,   170,   170,   171,
     171,   172,   173,   173,   174,   175,   175,   176,   177,   177,
     177,   178,   178,   179,   179,   180,   180,   180,   181,   181,
     182,   182,   183,   184,   184,   185,   185,   185,   185,   185,
     186,   186,   187,   187,   187,   188,   189,   189,   189,   189,
     189,   189,   190,   190,   191,   192,   192,   193,   193,   194,
     195,   196,   196,   197,   197,   198,   198,   199,   200,   200,
     201,   202,   202,   203,   204,   204,   205,   205,   206,   206,
     207,   208,   209,   209,   210,   210,   210,   210,   211,   211,
     211,   212,   213,   213,   214,   214,   214,   215,   215,   215,
     215,   215,   216,   216,   216,   216,   217,   217,   217,   217,
     217,   217,   218,   218,   218,   218,   219,   219
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     3,     0,     1,     1,     3,     1,     1,     1,
       1,     1,     1,     1,     1,     3,     2,     4,     4,     4,
       0,     2,     2,     2,     1,     3,     1,     4,     1,     3,
       7,     1,     1,     0,     2,     1,     1,     1,     1,     1,
       1,     4,     2,     4,     1,     1,     0,     3,     1,     1,
       1,     1,     0,     2,     4,     2,     4,     0,     2,     2,
       2,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     2,     3,     4,     5,
       2,     3,     2,     3,     2,     2,     1,     3,     2,     1,
       2,     1,     1,     2,     0,     1,     1,     3,     1,     2,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     3,     1,     3,     1,     2,     3,     2,     1,
       1,     3,     3,     3,     4,     1,     3,     1,     2,     1,
       1,     5,     1,     1,     8,     0,     2,     4,     2,     2,
       5,     0,     2,     4,     1,     6,     3,     2,     0,     1,
       1,     3,     2,     0,     2,     1,     1,     1,     2,     1,
       1,     1,     1,     1,     1,     4,     1,     1,     1,     1,
       1,     1,     1,     1,     5,     1,     1,     3,     3,     3,
       3,     0,     1,     1,     3,     2,     3,     5,     0,     2,
       4,     0,     2,     4,     0,     2,     1,     2,     0,     1,
       3,     2,     2,     3,     4,     4,     4,     4,     2,     1,
       1,     3,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       3,     4,     0,     0,     1,     0,     0,     0,     0,     0,
       0,    26,     0,     3,     5,    14,    13,    11,    12,    10,
       9,     7,     8,     0,     0,    20,     0,    16,   139,    32,
     140,    33,    31,     0,     0,     0,     0,     0,   211,     4,
       2,     0,     0,     0,    15,     0,    28,     0,     0,     0,
       0,     0,     6,    17,    18,     0,    19,    94,    21,    24,
      52,    36,    37,    38,    35,    39,     0,   208,    40,     0,
      44,    45,    34,   130,    27,   129,     0,     0,     0,     0,
       0,    22,    23,   224,   225,   226,   232,   233,   235,   234,
     227,   228,   230,   229,     0,    95,    96,   247,    98,   223,
     246,   231,   222,    57,     0,     0,    42,   209,    46,    29,
     214,   215,   216,   217,    25,     0,     0,    53,     0,     0,
       0,     0,    97,   242,   243,   244,   245,   163,     0,     0,
       0,    30,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   232,   227,   140,     0,     0,     0,     0,   158,
      73,    58,    61,    75,    74,    72,    71,     0,    62,    63,
      64,    65,   247,    66,    70,   142,   143,     0,     0,    68,
     183,    69,   182,   185,   186,     0,    67,     0,    41,   210,
       0,    43,     0,     0,    55,    76,    59,    60,     0,     0,
       0,   173,   172,   191,   170,   174,     0,   171,     0,     0,
     198,   201,   145,   158,     0,     0,     0,   220,   219,     0,
       0,     0,     0,   159,   160,   163,   157,     0,    99,    80,
     212,   121,   119,   120,   109,   110,   111,   112,   113,   115,
     116,   114,   117,   118,     0,     0,     0,     0,     0,    49,
      47,    50,    48,    51,    54,   169,   208,   167,   165,   166,
     164,     0,     0,     0,   135,   137,   213,   224,     0,   192,
     193,   204,   188,   187,   189,     0,     0,     0,     0,   156,
     218,   131,   236,   237,   238,   239,   241,   240,     0,   132,
      77,   133,     0,     0,   162,   177,   180,   179,   181,   178,
     176,     0,     0,     0,   123,   125,   224,   140,     0,   100,
     101,   102,    84,    92,    89,     0,    91,    86,   222,    81,
      82,     0,   168,    56,     0,   134,     0,   138,     0,   190,
       0,   195,     0,     0,   199,     0,     0,   202,     0,     0,
       0,     0,   146,     0,     0,   221,     0,   161,   175,   128,
     122,     0,   126,    90,    93,    78,    85,   108,   104,   103,
     105,   106,   107,     0,    88,    83,   141,   136,   196,   194,
     208,   206,   205,   204,   197,   204,   184,     0,   148,   204,
     149,   151,    79,     0,   124,   127,    87,   207,     0,     0,
       0,     0,     0,   155,   200,   203,     0,   147,     0,     0,
     154,   152,   150,   144,   163,     0,   153
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,     2,     3,    13,    14,    15,    16,    17,    18,    19,
      43,    58,   150,    20,    47,    21,    31,    45,    72,   121,
     240,   103,   117,   127,   118,   151,   152,   153,   154,   155,
     156,   236,   302,   303,    94,    95,    96,   157,   305,   353,
     237,   238,   293,   294,    76,   158,   159,   160,   161,   253,
     254,    97,   163,   164,   165,   267,   332,   333,   382,   391,
     166,   212,   213,   214,   182,   250,   196,   167,   168,   291,
     169,   170,   171,   172,   173,   198,   258,   259,   260,   174,
     265,   324,   266,   327,   321,   362,   106,   107,    22,   176,
      38,   206,   207,    98,    99,   100,   101,   278,   128,   102
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -319
static const yytype_int16 yypact[] =
{
      13,  -319,    70,   204,  -319,    32,    49,    86,    84,    63,
      36,     0,   202,   105,  -319,  -319,  -319,  -319,  -319,  -319,
    -319,  -319,  -319,    25,    51,  -319,    94,  -319,  -319,  -319,
    -319,  -319,  -319,   122,    90,    90,    90,    90,  -319,   204,
    -319,   124,   125,    35,  -319,    55,  -319,   -84,    91,    99,
     100,   112,  -319,  -319,  -319,     5,  -319,   389,  -319,  -319,
    -319,  -319,  -319,  -319,  -319,  -319,   107,   119,  -319,   127,
    -319,  -319,  -319,  -319,  -319,  -319,   197,   199,   206,   201,
     210,  -319,  -319,  -319,  -319,  -319,  -319,  -319,  -319,  -319,
    -319,  -319,  -319,  -319,   244,   154,  -319,  -319,  -319,  -319,
    -319,  -319,  -319,   243,    36,   231,  -319,  -319,  -319,  -319,
    -319,  -319,  -319,  -319,  -319,   389,   261,  -319,    34,   162,
     163,   -61,  -319,  -319,  -319,  -319,  -319,  -319,   134,   286,
     219,  -319,   263,   261,   202,    57,   208,   298,   310,   313,
     214,   208,   -90,    61,   339,   366,   366,   312,    90,   312,
    -319,  -319,  -319,  -319,  -319,  -319,  -319,   317,  -319,  -319,
    -319,  -319,    89,  -319,  -319,  -319,  -319,    92,   318,  -319,
    -319,  -319,  -319,  -319,  -319,   321,  -319,   316,  -319,  -319,
     257,  -319,    10,   264,  -319,  -319,  -319,  -319,   224,    90,
     323,  -319,  -319,   402,  -319,  -319,   337,  -319,   338,   340,
    -319,  -319,  -319,   312,   341,   389,   291,  -319,   169,   291,
     357,   358,   258,   265,  -319,  -319,  -319,   148,  -319,  -319,
    -319,  -319,  -319,  -319,  -319,  -319,  -319,  -319,  -319,  -319,
    -319,  -319,  -319,  -319,   293,   240,   359,   389,   259,  -319,
    -319,  -319,  -319,  -319,  -319,  -319,   119,  -319,  -319,  -319,
    -319,    90,   312,    -1,  -319,   269,  -319,   314,   262,   267,
    -319,  -319,  -319,  -319,  -319,   111,    39,   141,   266,  -319,
    -319,  -319,  -319,  -319,  -319,  -319,  -319,  -319,   389,  -319,
    -319,  -319,   307,   312,   200,  -319,  -319,  -319,  -319,  -319,
    -319,   208,   389,   -64,  -319,   369,   208,   389,   411,  -319,
    -319,  -319,  -319,  -319,  -319,   389,  -319,    43,   290,  -319,
    -319,   389,  -319,  -319,   412,  -319,    90,  -319,   389,  -319,
     402,   121,   389,   413,  -319,   389,   414,  -319,   153,   153,
     389,   153,  -319,   417,   418,  -319,   153,  -319,  -319,  -319,
    -319,   293,   389,  -319,   154,  -319,  -319,  -319,  -319,  -319,
    -319,  -319,  -319,   389,  -319,  -319,  -319,  -319,  -319,  -319,
     119,  -319,  -319,  -319,  -319,  -319,  -319,   446,  -319,  -319,
    -319,  -319,  -319,   447,  -319,  -319,  -319,  -319,    15,    29,
     433,    33,    -4,  -319,  -319,  -319,   148,  -319,   449,   312,
    -319,  -319,  -319,  -319,  -319,    23,  -319
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -319,  -319,   444,  -319,   419,  -319,  -319,  -319,  -319,  -319,
    -319,  -319,    -6,  -319,  -319,  -319,   355,  -319,  -319,  -319,
    -319,  -319,  -319,  -319,  -319,  -319,   330,  -319,  -319,  -319,
    -319,  -319,  -319,  -319,  -319,   164,   347,  -134,  -319,  -319,
    -319,  -176,  -319,   123,   170,  -319,  -319,  -196,    83,  -319,
     150,   -10,  -319,  -319,  -319,  -319,  -319,  -319,  -319,  -319,
    -319,   268,  -319,   184,  -212,  -319,   132,   -37,  -130,    87,
    -319,  -319,  -319,  -319,  -319,  -125,  -319,  -319,   149,  -319,
    -319,  -319,  -319,  -319,  -318,  -319,  -239,  -319,    59,  -319,
     336,   326,  -319,  -137,  -319,  -319,  -319,  -319,  -114,  -116
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -175
static const yytype_int16 yytable[] =
{
      32,   194,   177,   284,   241,   197,   315,   312,   208,   208,
     271,   199,    81,   279,   177,   133,   204,   244,  -173,   189,
       1,    73,   384,    74,    48,    49,    50,    51,   388,  -173,
     396,   210,   389,   215,    75,   129,   385,    59,   130,    55,
     387,    73,   218,   340,   180,   378,    56,   379,   181,    82,
     131,   381,   132,   133,    75,    57,   261,   134,    12,   135,
     136,   137,    60,   138,   325,   139,   243,   140,   270,   326,
       4,    23,    28,   141,    28,    29,   142,    87,    88,    89,
     143,    91,    92,    93,   144,    57,    30,   215,    24,   145,
     146,   147,   148,    25,    32,    28,    26,   295,   307,   191,
     310,   304,    27,   192,   316,   306,    33,    30,   162,   245,
     246,   247,    39,   248,   249,   360,   347,   361,   184,   308,
     162,   377,   245,   246,   247,   195,   248,   249,    28,   360,
      41,   361,   354,   360,    44,   361,   314,   322,   211,   323,
      30,   335,   149,    61,    62,    63,    64,    65,    66,    67,
      68,    69,    70,    71,   348,   339,    42,   349,   350,   351,
     352,    46,   328,    53,    54,   193,   338,   215,   346,  -172,
     242,   343,    28,   183,   355,   329,   330,   175,   331,   255,
    -172,   358,   395,   261,    30,   363,    28,   285,   365,   175,
     286,    28,   287,   369,   288,   191,   289,  -174,    30,   192,
     193,    77,   194,    30,   295,   375,   197,   290,  -174,    78,
      79,   217,     5,     6,     7,   104,   376,     8,     9,    10,
     129,   360,    80,   361,    11,   162,   186,   105,    12,   272,
     273,   274,   275,   276,   277,   108,   109,   132,   133,   110,
     112,   313,   134,    12,   135,   136,   137,   111,   138,   113,
     139,   114,   140,    34,    35,    36,    37,    28,   141,   115,
     116,   142,    87,    88,    89,   143,    91,    92,    93,   144,
     120,   178,   179,   394,   145,   146,   147,   148,    28,   296,
      84,    85,   142,    87,    88,    89,   143,    91,    92,    93,
     297,   367,   368,   185,   370,    28,   239,   298,   292,   245,
     246,   247,   188,   248,   249,   200,   255,    30,   123,   124,
     125,   126,   123,   124,   125,   126,   193,   201,   195,   195,
     202,   195,   203,   251,   216,   219,   195,   149,   220,   252,
     256,    28,    83,    84,    85,    86,    87,    88,    89,    90,
      91,    92,    93,    30,   262,   263,   -94,   264,   269,   148,
      28,   299,   300,   301,    86,    87,    88,    89,    90,    91,
      92,    93,    30,   234,   280,   281,   309,   282,   317,   311,
     283,   319,   320,   318,   342,   334,   290,    28,    83,    84,
      85,    86,    87,    88,    89,    90,    91,    92,    93,    30,
     221,   222,   223,   224,   225,   226,   234,   227,   228,   229,
     230,   231,   232,   233,    28,    83,    84,    85,    86,    87,
      88,    89,    90,    91,    92,    93,    30,   336,   345,   356,
     364,   366,   234,   205,   371,   372,   235,    28,    83,    84,
      85,    86,    87,    88,    89,    90,    91,    92,    93,    30,
      28,   257,    84,    85,    86,    87,    88,    89,    90,    91,
      92,    93,    30,   380,   383,   386,   393,    40,    52,   119,
     187,   344,   122,   341,   374,   390,   357,   337,   373,   359,
     190,   268,   209,   392
};

static const yytype_uint16 yycheck[] =
{
      10,   135,   118,   215,   180,   135,     7,   246,   145,   146,
     206,   136,     7,   209,   130,    19,   141,     7,   108,   133,
       7,   105,     7,   107,    34,    35,    36,    37,    32,   119,
       7,   147,    36,   149,   118,     1,     7,    43,     4,     4,
       7,   105,   167,   107,   105,   363,    11,   365,   109,    55,
      16,   369,    18,    19,   118,    50,   193,    23,    24,    25,
      26,    27,     7,    29,    25,    31,   180,    33,   205,    30,
       0,    39,    38,    39,    38,    39,    42,    43,    44,    45,
      46,    47,    48,    49,    50,    50,    50,   203,    39,    55,
      56,    57,    58,     7,   104,    38,    12,   234,   235,    42,
     237,   235,    39,    46,   105,   235,   106,    50,   118,    99,
     100,   101,     7,   103,   104,   100,    73,   102,   128,   235,
     130,   360,    99,   100,   101,   135,   103,   104,    38,   100,
     105,   102,   308,   100,    40,   102,   252,    26,   148,    28,
      50,   278,   108,    88,    89,    90,    91,    92,    93,    94,
      95,    96,    97,    98,   111,   292,   105,   114,   115,   116,
     117,    39,    21,    39,    39,   108,   291,   283,   305,   108,
     180,   296,    38,    39,   311,    34,    35,   118,    37,   189,
     119,   318,   394,   320,    50,   322,    38,    39,   325,   130,
      42,    38,    44,   330,    46,    42,    48,   108,    50,    46,
     108,   110,   336,    50,   341,   342,   336,   217,   119,   110,
     110,   119,     8,     9,    10,   108,   353,    13,    14,    15,
       1,   100,   110,   102,    20,   235,     7,   108,    24,    60,
      61,    62,    63,    64,    65,   108,    39,    18,    19,    40,
      39,   251,    23,    24,    25,    26,    27,    41,    29,    39,
      31,     7,    33,    51,    52,    53,    54,    38,    39,   105,
      17,    42,    43,    44,    45,    46,    47,    48,    49,    50,
      39,   109,   109,   389,    55,    56,    57,    58,    38,    39,
      40,    41,    42,    43,    44,    45,    46,    47,    48,    49,
      50,   328,   329,     7,   331,    38,    39,    57,     5,    99,
     100,   101,    39,   103,   104,     7,   316,    50,    51,    52,
      53,    54,    51,    52,    53,    54,   108,     7,   328,   329,
       7,   331,   108,    59,     7,     7,   336,   108,     7,   105,
       7,    38,    39,    40,    41,    42,    43,    44,    45,    46,
      47,    48,    49,    50,     7,     7,     7,     7,     7,    58,
      38,   111,   112,   113,    42,    43,    44,    45,    46,    47,
      48,    49,    50,   106,     7,     7,     7,   109,    99,   110,
     105,   109,   105,    59,     5,   109,   386,    38,    39,    40,
      41,    42,    43,    44,    45,    46,    47,    48,    49,    50,
      74,    75,    76,    77,    78,    79,   106,    81,    82,    83,
      84,    85,    86,    87,    38,    39,    40,    41,    42,    43,
      44,    45,    46,    47,    48,    49,    50,   110,     7,     7,
       7,     7,   106,    57,     7,     7,   110,    38,    39,    40,
      41,    42,    43,    44,    45,    46,    47,    48,    49,    50,
      38,    39,    40,    41,    42,    43,    44,    45,    46,    47,
      48,    49,    50,     7,     7,    22,     7,    13,    39,   104,
     130,   297,   115,   293,   341,   382,   316,   283,   336,   320,
     134,   203,   146,   386
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     7,   121,   122,     0,     8,     9,    10,    13,    14,
      15,    20,    24,   123,   124,   125,   126,   127,   128,   129,
     133,   135,   208,    39,    39,     7,    12,    39,    38,    39,
      50,   136,   171,   106,    51,    52,    53,    54,   210,     7,
     122,   105,   105,   130,    40,   137,    39,   134,   171,   171,
     171,   171,   124,    39,    39,     4,    11,    50,   131,   132,
       7,    88,    89,    90,    91,    92,    93,    94,    95,    96,
      97,    98,   138,   105,   107,   118,   164,   110,   110,   110,
     110,     7,   132,    39,    40,    41,    42,    43,    44,    45,
      46,    47,    48,    49,   154,   155,   156,   171,   213,   214,
     215,   216,   219,   141,   108,   108,   206,   207,   108,    39,
      40,    41,    39,    39,     7,   105,    17,   142,   144,   136,
      39,   139,   156,    51,    52,    53,    54,   143,   218,     1,
       4,    16,    18,    19,    23,    25,    26,    27,    29,    31,
      33,    39,    42,    46,    50,    55,    56,    57,    58,   108,
     132,   145,   146,   147,   148,   149,   150,   157,   165,   166,
     167,   168,   171,   172,   173,   174,   180,   187,   188,   190,
     191,   192,   193,   194,   199,   208,   209,   219,   109,   109,
     105,   109,   184,    39,   171,     7,     7,   146,    39,   218,
     210,    42,    46,   108,   157,   171,   186,   188,   195,   195,
       7,     7,     7,   108,   195,    57,   211,   212,   213,   211,
     219,   171,   181,   182,   183,   219,     7,   119,   195,     7,
       7,    74,    75,    76,    77,    78,    79,    81,    82,    83,
      84,    85,    86,    87,   106,   110,   151,   160,   161,    39,
     140,   161,   171,   218,     7,    99,   100,   101,   103,   104,
     185,    59,   105,   169,   170,   171,     7,    39,   196,   197,
     198,   213,     7,     7,     7,   200,   202,   175,   181,     7,
     213,   167,    60,    61,    62,    63,    64,    65,   217,   167,
       7,     7,   109,   105,   184,    39,    42,    44,    46,    48,
     171,   189,     5,   162,   163,   213,    39,    50,    57,   111,
     112,   113,   152,   153,   157,   158,   188,   213,   219,     7,
     213,   110,   206,   171,   219,     7,   105,    99,    59,   109,
     105,   204,    26,    28,   201,    25,    30,   203,    21,    34,
      35,    37,   176,   177,   109,   213,   110,   183,   195,   213,
     107,   164,     5,   195,   155,     7,   213,    73,   111,   114,
     115,   116,   117,   159,   161,   213,     7,   170,   213,   198,
     100,   102,   205,   213,     7,   213,     7,   187,   187,   213,
     187,     7,     7,   186,   163,   213,   213,   206,   204,   204,
       7,   204,   178,     7,     7,     7,    22,     7,    32,    36,
     168,   179,   189,     7,   219,   184,     7
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
      yyerror (yyscanner, lexer, YY_("syntax error: cannot back up")); \
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
# define YYLEX yylex (&yylval, yyscanner)
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
		  Type, Value, yyscanner, lexer); \
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
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, yyscan_t yyscanner, struct lexer_state * lexer)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep, yyscanner, lexer)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
    yyscan_t yyscanner;
    struct lexer_state * lexer;
#endif
{
  if (!yyvaluep)
    return;
  YYUSE (yyscanner);
  YYUSE (lexer);
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
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, yyscan_t yyscanner, struct lexer_state * lexer)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep, yyscanner, lexer)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
    yyscan_t yyscanner;
    struct lexer_state * lexer;
#endif
{
  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep, yyscanner, lexer);
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
yy_reduce_print (YYSTYPE *yyvsp, int yyrule, yyscan_t yyscanner, struct lexer_state * lexer)
#else
static void
yy_reduce_print (yyvsp, yyrule, yyscanner, lexer)
    YYSTYPE *yyvsp;
    int yyrule;
    yyscan_t yyscanner;
    struct lexer_state * lexer;
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
		       		       , yyscanner, lexer);
      fprintf (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (yyvsp, Rule, yyscanner, lexer); \
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
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep, yyscan_t yyscanner, struct lexer_state * lexer)
#else
static void
yydestruct (yymsg, yytype, yyvaluep, yyscanner, lexer)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
    yyscan_t yyscanner;
    struct lexer_state * lexer;
#endif
{
  YYUSE (yyvaluep);
  YYUSE (yyscanner);
  YYUSE (lexer);

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
int yyparse (yyscan_t yyscanner, struct lexer_state * lexer);
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
yyparse (yyscan_t yyscanner, struct lexer_state * lexer)
#else
int
yyparse (yyscanner, lexer)
    yyscan_t yyscanner;
    struct lexer_state * lexer;
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
        case 76:
#line 367 "pir.y"
    { yyerrok; ;}
    break;


/* Line 1267 of yacc.c.  */
#line 2053 "pirparser.c"
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
      yyerror (yyscanner, lexer, YY_("syntax error"));
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
	    yyerror (yyscanner, lexer, yymsg);
	  }
	else
	  {
	    yyerror (yyscanner, lexer, YY_("syntax error"));
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
		      yytoken, &yylval, yyscanner, lexer);
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
		  yystos[yystate], yyvsp, yyscanner, lexer);
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
  yyerror (yyscanner, lexer, YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEOF && yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval, yyscanner, lexer);
  /* Do not reclaim the symbols of the rule which action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp, yyscanner, lexer);
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


#line 703 "pir.y"


#include <string.h>
#include <assert.h>


/*

wrapper function for yyerror.

*/
void
syntax_error(yyscan_t yyscanner, struct lexer_state *lexer, char *message) {
    yyerror(yyscanner, lexer, message);
}


/*

Pre-process the file only. Don't do any analysis.
This function does a bit of pretty-printing. Future improvement includes keeping track
of the amount of indention, for instance for labels and conditional blocks.

*/
static void
do_pre_process(yyscan_t yyscanner, struct lexer_state *lexer, char *outputfile) {
    int token;
    YYSTYPE val;
    int in_sub_body   = 0;    /* flag to keep track whether we're in a sub body */
    int just_print_nl = 0;    /* flag to keep track whether we just printed a newline */
    int indention     = 0;    /* amount of indention */
    FILE *output      = NULL; /* pointer to output file, if any is specified */


    if (outputfile != NULL) {
        output = fopen(outputfile, "w"); /* overwrite */
    }
    else {
        output = stderr; /* no file specified, output to stderr */
    }


    do {
        token = yylex(&val, yyscanner);

        if (token == TK_END) { /* ".end" must be printed at column 1 */
            in_sub_body = 0;
        }

        /* if we just printed a newline, and we're in a sub body ... */
        if (in_sub_body == 1 && just_print_nl) {
            /* ... and the current token is a non-indented token, (which needs to be printed
             * at column 1, print an indention.
             */

            if (token == TK_LABEL)
                indention = 1; /* labels are indented 1 space */
            else
                indention = 2; /* normal code is indented 2 spaces */
        }
        else { /* not in sub body or this is not first token on the line. */
            indention = 0;
        }

        /* print <indention> number of spaces before printing the token */
        fprintf(output, "%*s%s", indention, indention > 0 ? " " : "", yyget_text(yyscanner));

        /* don't print a space after one of these: [() */
        switch (token) {
            case '[': case ']':
            case '(': case ')':
                /* don't print a space */
                break;
            default:
                fprintf(output, " ");
                break;
        }


        if (token == TK_SUB) { /* we're entering a sub body, next lines must be indented. */
            in_sub_body = 1;
        }

        /* if we just printed a newline character, the trailing space should be removed:
         * do a carriage-return. Always clear flag of having read a newline.
         */
        just_print_nl = 0;
        if (strchr(yyget_text(yyscanner), '\n') != NULL) {
            fprintf(output, "\r");
            just_print_nl = 1;
        }
    }
    while (token > 0);

    if (outputfile != NULL) {
        fclose(output);
    }
}

/*

*/
static void
print_help(char const * const program_name) {

    fprintf(stderr, "Usage: %s [options] <files>\n", program_name);
    fprintf(stderr, "Options:\n\n");
    fprintf(stderr, "  -E        pre-process\n");
    fprintf(stderr, "  -d        show debug messages of parser\n");
    fprintf(stderr, "  -h        show this help message\n");
    fprintf(stderr, "  -o <file> write output to the specified file. "
                    "Currently only works in combination with '-E' option\n");
}

char debugtable[256];

/*
 * Main compiler driver.
 */
int
main(int argc, char *argv[]) {

    char const * const program_name = argv[0];
    int total_errors  = 0;
    int pre_process   = 0;
    int flexdebug     = 0;
    char *outputfile  = NULL;
    yyscan_t yyscanner;


    int i;

    for (i = 0; i < 256; i++) {
        debugtable[i] = i;
    }

    if (argc < 2) {
        print_help(program_name);
        exit(EXIT_FAILURE);
    }



    /* skip program name */
    argc--;
    argv++;

    /* very basic argument handling; I'm too lazy to check out
     * the standard funtion for that, right now. This is a TODO. */
    while (argc > 0 && argv[0][0] == '-') {
        switch (argv[0][1]) {
            case 'E':
                pre_process = 1;
                break;
            /* Only allow for debug flag if the generated parser supports it */
#ifdef YYDEBUG
            case 'd':
                yydebug = 1;
                break;
#endif
            case 'f':
                flexdebug = 1;
                break;
            case 'h':
                print_help(program_name);
                exit(EXIT_SUCCESS); /* asking for help doesn't make you a failure */
                /* break; */
            case 'o':
                if (argc > 1) { /* there must be at least 2 more args,
                                         the output file, and an input */
                    argc--;
                    argv++;
                    outputfile = argv[0];
                }
                else {
                    fprintf(stderr, "Missing argument for option '-o'\n");
                    exit(EXIT_FAILURE);
                }
                break;
            default:
                fprintf(stderr, "Unknown option: '%c'\n", argv[0][1]);
                break;
        }
        /* goto next command line argument */
        argv++;
        argc--;
    }

    if (argc < 1) {
        fprintf(stderr, "No input file specified\n");
        exit(EXIT_FAILURE);
    }


    /* compile all files specified on the command line */
    while (argc > 0) {
        FILE *infile = NULL;
        struct lexer_state *lexer = NULL;
        int parse_errors = 0;

        fprintf(stderr, "Processing file '%s'\n", argv[0]);

        /* done handling arguments, open the file */
        infile = fopen(argv[0], "r");

        if (infile == NULL) {
            fprintf(stderr, "Failed to open file '%s'\n", argv[0]);
            exit(EXIT_FAILURE);
        }

        /* create a yyscan_t object */
        yylex_init(&yyscanner);
        /* set debug flag */
        yyset_debug(flexdebug, yyscanner);
        /* set the input file */
        yyset_in(infile, yyscanner);

        /* set the extra parameter in the yyscan_t structure */
        lexer = new_lexer(argv[0]);
        yyset_extra(lexer, yyscanner);


        if (pre_process) {
            fprintf(stderr, "pre-processing %s\n", argv[0]);
            do_pre_process(yyscanner, lexer, outputfile);
        }
        else {
            fprintf(stderr, "compiling %s\n", argv[0]);
            yyparse(yyscanner, lexer);

            /* get parse errors for this file */
            parse_errors = get_parse_errors(lexer);
            /* update total error count */
            total_errors += parse_errors;

            if (parse_errors == 0) {
                fprintf(stderr, "Parse successful!\n");
            }
            else {
                fprintf(stderr, "There %s %d %s in file '%s'\n", parse_errors > 1 ? "were" :
                        "was", parse_errors, parse_errors > 1 ? "errors" : "error",
                        get_current_file(lexer));
            }
        }

        /* clean up after playing */
        yylex_destroy(yyscanner);

        argc--;
        argv++;
    }

    if (total_errors > 0)
        fprintf(stderr, "There were %d parse errors in all files\n", total_errors);


    /* go home! */
    return 0;
}



/*

*/
int
yyerror(yyscan_t yyscanner, struct lexer_state * const  lexer, char const * const message) {

    char const * const text = yyget_text(yyscanner);

    /* increment parse errors in the lexer structure */
    parse_error(lexer);
    /* emit an error */
    fprintf(stderr, "\nError in file '%s' (line %d)\n%s ",
            get_current_file(lexer), get_line_nr(lexer), message);


    /* print current token if it's not a newline (or \r\n on windows) */

    /* the following should be fixed; the point is not to print the token if
     * it's a newline, that looks silly.
     */
    if (strcmp(text, "\r\n") != 0 || strcmp(text, "\n") == 0) {
        fprintf(stderr, "('%s')\n\n", text);
    }
    else {
        fprintf(stderr, "\n\n");
    }


    return 0;
}


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */


