/* ex: set ro ft=c:
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically from 'compilers/imcc/imcc.y'
 * by tools/build/fixup_gen_file.pl.
 *
 * Any changes made here will be lost!
 *
 */
/* HEADERIZER HFILE: none */
/* HEADERIZER STOP */
/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

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

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     LOW_PREC = 258,
     PARAM = 259,
     HLL = 260,
     TK_LINE = 261,
     TK_FILE = 262,
     GOTO = 263,
     ARG = 264,
     IF = 265,
     UNLESS = 266,
     PNULL = 267,
     SET_RETURN = 268,
     SET_YIELD = 269,
     ADV_FLAT = 270,
     ADV_SLURPY = 271,
     ADV_OPTIONAL = 272,
     ADV_OPT_FLAG = 273,
     ADV_NAMED = 274,
     ADV_ARROW = 275,
     NEW = 276,
     ADV_INVOCANT = 277,
     ADV_CALL_SIG = 278,
     NAMESPACE = 279,
     DOT_METHOD = 280,
     SUB = 281,
     SYM = 282,
     LOCAL = 283,
     LEXICAL = 284,
     CONST = 285,
     ANNOTATE = 286,
     INC = 287,
     DEC = 288,
     GLOBAL_CONST = 289,
     PLUS_ASSIGN = 290,
     MINUS_ASSIGN = 291,
     MUL_ASSIGN = 292,
     DIV_ASSIGN = 293,
     CONCAT_ASSIGN = 294,
     BAND_ASSIGN = 295,
     BOR_ASSIGN = 296,
     BXOR_ASSIGN = 297,
     FDIV = 298,
     FDIV_ASSIGN = 299,
     MOD_ASSIGN = 300,
     SHR_ASSIGN = 301,
     SHL_ASSIGN = 302,
     SHR_U_ASSIGN = 303,
     SHIFT_LEFT = 304,
     SHIFT_RIGHT = 305,
     INTV = 306,
     FLOATV = 307,
     STRINGV = 308,
     PMCV = 309,
     LOG_XOR = 310,
     RELOP_EQ = 311,
     RELOP_NE = 312,
     RELOP_GT = 313,
     RELOP_GTE = 314,
     RELOP_LT = 315,
     RELOP_LTE = 316,
     RESULT = 317,
     RETURN = 318,
     TAILCALL = 319,
     YIELDT = 320,
     GET_RESULTS = 321,
     POW = 322,
     SHIFT_RIGHT_U = 323,
     LOG_AND = 324,
     LOG_OR = 325,
     COMMA = 326,
     ESUB = 327,
     DOTDOT = 328,
     PCC_BEGIN = 329,
     PCC_END = 330,
     PCC_CALL = 331,
     PCC_SUB = 332,
     PCC_BEGIN_RETURN = 333,
     PCC_END_RETURN = 334,
     PCC_BEGIN_YIELD = 335,
     PCC_END_YIELD = 336,
     NCI_CALL = 337,
     METH_CALL = 338,
     INVOCANT = 339,
     MAIN = 340,
     LOAD = 341,
     INIT = 342,
     IMMEDIATE = 343,
     POSTCOMP = 344,
     METHOD = 345,
     ANON = 346,
     OUTER = 347,
     NEED_LEX = 348,
     MULTI = 349,
     VTABLE_METHOD = 350,
     LOADLIB = 351,
     SUB_INSTANCE_OF = 352,
     SUBID = 353,
     NS_ENTRY = 354,
     UNIQUE_REG = 355,
     LABEL = 356,
     EMIT = 357,
     EOM = 358,
     IREG = 359,
     NREG = 360,
     SREG = 361,
     PREG = 362,
     IDENTIFIER = 363,
     REG = 364,
     MACRO = 365,
     ENDM = 366,
     STRINGC = 367,
     INTC = 368,
     FLOATC = 369,
     USTRINGC = 370,
     PARROT_OP = 371,
     VAR = 372,
     LINECOMMENT = 373,
     FILECOMMENT = 374,
     DOT = 375,
     CONCAT = 376
   };
#endif
/* Tokens.  */
#define LOW_PREC 258
#define PARAM 259
#define HLL 260
#define TK_LINE 261
#define TK_FILE 262
#define GOTO 263
#define ARG 264
#define IF 265
#define UNLESS 266
#define PNULL 267
#define SET_RETURN 268
#define SET_YIELD 269
#define ADV_FLAT 270
#define ADV_SLURPY 271
#define ADV_OPTIONAL 272
#define ADV_OPT_FLAG 273
#define ADV_NAMED 274
#define ADV_ARROW 275
#define NEW 276
#define ADV_INVOCANT 277
#define ADV_CALL_SIG 278
#define NAMESPACE 279
#define DOT_METHOD 280
#define SUB 281
#define SYM 282
#define LOCAL 283
#define LEXICAL 284
#define CONST 285
#define ANNOTATE 286
#define INC 287
#define DEC 288
#define GLOBAL_CONST 289
#define PLUS_ASSIGN 290
#define MINUS_ASSIGN 291
#define MUL_ASSIGN 292
#define DIV_ASSIGN 293
#define CONCAT_ASSIGN 294
#define BAND_ASSIGN 295
#define BOR_ASSIGN 296
#define BXOR_ASSIGN 297
#define FDIV 298
#define FDIV_ASSIGN 299
#define MOD_ASSIGN 300
#define SHR_ASSIGN 301
#define SHL_ASSIGN 302
#define SHR_U_ASSIGN 303
#define SHIFT_LEFT 304
#define SHIFT_RIGHT 305
#define INTV 306
#define FLOATV 307
#define STRINGV 308
#define PMCV 309
#define LOG_XOR 310
#define RELOP_EQ 311
#define RELOP_NE 312
#define RELOP_GT 313
#define RELOP_GTE 314
#define RELOP_LT 315
#define RELOP_LTE 316
#define RESULT 317
#define RETURN 318
#define TAILCALL 319
#define YIELDT 320
#define GET_RESULTS 321
#define POW 322
#define SHIFT_RIGHT_U 323
#define LOG_AND 324
#define LOG_OR 325
#define COMMA 326
#define ESUB 327
#define DOTDOT 328
#define PCC_BEGIN 329
#define PCC_END 330
#define PCC_CALL 331
#define PCC_SUB 332
#define PCC_BEGIN_RETURN 333
#define PCC_END_RETURN 334
#define PCC_BEGIN_YIELD 335
#define PCC_END_YIELD 336
#define NCI_CALL 337
#define METH_CALL 338
#define INVOCANT 339
#define MAIN 340
#define LOAD 341
#define INIT 342
#define IMMEDIATE 343
#define POSTCOMP 344
#define METHOD 345
#define ANON 346
#define OUTER 347
#define NEED_LEX 348
#define MULTI 349
#define VTABLE_METHOD 350
#define LOADLIB 351
#define SUB_INSTANCE_OF 352
#define SUBID 353
#define NS_ENTRY 354
#define UNIQUE_REG 355
#define LABEL 356
#define EMIT 357
#define EOM 358
#define IREG 359
#define NREG 360
#define SREG 361
#define PREG 362
#define IDENTIFIER 363
#define REG 364
#define MACRO 365
#define ENDM 366
#define STRINGC 367
#define INTC 368
#define FLOATC 369
#define USTRINGC 370
#define PARROT_OP 371
#define VAR 372
#define LINECOMMENT 373
#define FILECOMMENT 374
#define DOT 375
#define CONCAT 376




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 1059 "compilers/imcc/imcc.y"
{
    IdList * idlist;
    int t;
    char * s;
    SymReg * sr;
    Instruction *i;
}
/* Line 1489 of yacc.c.  */
#line 299 "compilers/imcc/imcparser.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



