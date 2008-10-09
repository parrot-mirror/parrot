#ifndef macroHEADER_H
#define macroHEADER_H 1
#define macroIN_HEADER 1

#line 6 "macrolexer.h"

#line 8 "macrolexer.h"

#define  YY_INT_ALIGNED short int

/* A lexical scanner generated by flex */

#define FLEX_SCANNER
#define YY_FLEX_MAJOR_VERSION 2
#define YY_FLEX_MINOR_VERSION 5
#define YY_FLEX_SUBMINOR_VERSION 33
#if YY_FLEX_SUBMINOR_VERSION > 0
#define FLEX_BETA
#endif

/* %if-c++-only */
/* %endif */

/* %if-c-only */

/* %endif */

/* %if-c-only */

/* %endif */

/* First, we deal with  platform-specific or compiler-specific issues. */

/* begin standard C headers. */
/* %if-c-only */
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
/* %endif */

/* %if-tables-serialization */
/* %endif */
/* end standard C headers. */

/* %if-c-or-c++ */
/* flex integer type definitions */

#ifndef FLEXINT_H
#define FLEXINT_H

/* C99 systems have <inttypes.h>. Non-C99 systems may or may not. */

#if __STDC_VERSION__ >= 199901L

/* C99 says to define __STDC_LIMIT_MACROS before including stdint.h,
 * if you want the limit (max/min) macros for int types.
 */
#ifndef __STDC_LIMIT_MACROS
#define __STDC_LIMIT_MACROS 1
#endif

#include <inttypes.h>
typedef int8_t flex_int8_t;
typedef uint8_t flex_uint8_t;
typedef int16_t flex_int16_t;
typedef uint16_t flex_uint16_t;
typedef int32_t flex_int32_t;
typedef uint32_t flex_uint32_t;
#else
typedef signed char flex_int8_t;
typedef short int flex_int16_t;
typedef int flex_int32_t;
typedef unsigned char flex_uint8_t;
typedef unsigned short int flex_uint16_t;
typedef unsigned int flex_uint32_t;
#endif /* ! C99 */

/* Limits of integral types. */
#ifndef INT8_MIN
#define INT8_MIN               (-128)
#endif
#ifndef INT16_MIN
#define INT16_MIN              (-32767-1)
#endif
#ifndef INT32_MIN
#define INT32_MIN              (-2147483647-1)
#endif
#ifndef INT8_MAX
#define INT8_MAX               (127)
#endif
#ifndef INT16_MAX
#define INT16_MAX              (32767)
#endif
#ifndef INT32_MAX
#define INT32_MAX              (2147483647)
#endif
#ifndef UINT8_MAX
#define UINT8_MAX              (255U)
#endif
#ifndef UINT16_MAX
#define UINT16_MAX             (65535U)
#endif
#ifndef UINT32_MAX
#define UINT32_MAX             (4294967295U)
#endif

#endif /* ! FLEXINT_H */

/* %endif */

/* %if-c++-only */
/* %endif */

#ifdef __cplusplus

/* The "const" storage-class-modifier is valid. */
#define YY_USE_CONST

#else   /* ! __cplusplus */

#if __STDC__

#define YY_USE_CONST

#endif  /* __STDC__ */
#endif  /* ! __cplusplus */

#ifdef YY_USE_CONST
#define yyconst const
#else
#define yyconst
#endif

/* %not-for-header */

/* %not-for-header */

/* %if-reentrant */

/* An opaque pointer. */
#ifndef YY_TYPEDEF_YY_SCANNER_T
#define YY_TYPEDEF_YY_SCANNER_T
typedef void* yyscan_t;
#endif

/* For convenience, these vars (plus the bison vars far below)
   are macros in the reentrant scanner. */
#define yyin yyg->yyin_r
#define yyout yyg->yyout_r
#define yyextra yyg->yyextra_r
#define yyleng yyg->yyleng_r
#define yytext yyg->yytext_r
#define yylineno (YY_CURRENT_BUFFER_LVALUE->yy_bs_lineno)
#define yycolumn (YY_CURRENT_BUFFER_LVALUE->yy_bs_column)
#define yy_flex_debug yyg->yy_flex_debug_r

int macrolex_init (yyscan_t* scanner);
/* %endif */

/* %if-not-reentrant */
/* %endif */

#ifndef YY_TYPEDEF_YY_BUFFER_STATE
#define YY_TYPEDEF_YY_BUFFER_STATE
typedef struct yy_buffer_state *YY_BUFFER_STATE;
#endif

/* %if-not-reentrant */
/* %endif */

/* %if-c-only */
/* %if-not-reentrant */
/* %endif */
/* %endif */

/* The following is because we cannot portably get our hands on size_t
 * (without autoconf's help, which isn't available because we want
 * flex-generated scanners to compile on their own).
 */

#ifndef YY_TYPEDEF_YY_SIZE_T
#define YY_TYPEDEF_YY_SIZE_T
typedef unsigned int yy_size_t;
#endif

#ifndef YY_STRUCT_YY_BUFFER_STATE
#define YY_STRUCT_YY_BUFFER_STATE
struct yy_buffer_state
    {
/* %if-c-only */
    FILE *yy_input_file;
/* %endif */

/* %if-c++-only */
/* %endif */

    char *yy_ch_buf;        /* input buffer */
    char *yy_buf_pos;       /* current position in input buffer */

    /* Size of input buffer in bytes, not including room for EOB
     * characters.
     */
    yy_size_t yy_buf_size;

    /* Number of characters read into yy_ch_buf, not including EOB
     * characters.
     */
    int yy_n_chars;

    /* Whether we "own" the buffer - i.e., we know we created it,
     * and can realloc() it to grow it, and should free() it to
     * delete it.
     */
    int yy_is_our_buffer;

    /* Whether this is an "interactive" input source; if so, and
     * if we're using stdio for input, then we want to use getc()
     * instead of fread(), to make sure we stop fetching input after
     * each newline.
     */
    int yy_is_interactive;

    /* Whether we're considered to be at the beginning of a line.
     * If so, '^' rules will be active on the next match, otherwise
     * not.
     */
    int yy_at_bol;

    int yy_bs_lineno; /**< The line count. */
    int yy_bs_column; /**< The column count. */

    /* Whether to try to fill the input buffer when we reach the
     * end of it.
     */
    int yy_fill_buffer;

    int yy_buffer_status;

    };
#endif /* !YY_STRUCT_YY_BUFFER_STATE */

/* %if-c-only Standard (non-C++) definition */
/* %not-for-header */

/* %endif */

/* %if-c-only Standard (non-C++) definition */

/* %if-not-reentrant */
/* %not-for-header */

/* %endif */

void macrorestart (FILE *input_file ,yyscan_t yyscanner );
void macro_switch_to_buffer (YY_BUFFER_STATE new_buffer ,yyscan_t yyscanner );
YY_BUFFER_STATE macro_create_buffer (FILE *file,int size ,yyscan_t yyscanner );
void macro_delete_buffer (YY_BUFFER_STATE b ,yyscan_t yyscanner );
void macro_flush_buffer (YY_BUFFER_STATE b ,yyscan_t yyscanner );
void macropush_buffer_state (YY_BUFFER_STATE new_buffer ,yyscan_t yyscanner );
void macropop_buffer_state (yyscan_t yyscanner );

YY_BUFFER_STATE macro_scan_buffer (char *base,yy_size_t size ,yyscan_t yyscanner );
YY_BUFFER_STATE macro_scan_string (yyconst char *yy_str ,yyscan_t yyscanner );
YY_BUFFER_STATE macro_scan_bytes (yyconst char *bytes,int len ,yyscan_t yyscanner );

/* %endif */

void *macroalloc (yy_size_t ,yyscan_t yyscanner );
void *macrorealloc (void *,yy_size_t ,yyscan_t yyscanner );
void macrofree (void * ,yyscan_t yyscanner );

/* %% [1.0] yytext/yyin/yyout/yy_state_type/yylineno etc. def's & init go here */
/* Begin user sect3 */

#define macrowrap(n) 1
#define YY_SKIP_YYWRAP

#define FLEX_DEBUG

#define yytext_ptr yytext_r

/* %if-c-only Standard (non-C++) definition */

/* %endif */

#ifdef YY_HEADER_EXPORT_START_CONDITIONS
#define INITIAL 0
#define MACRODEF 1
#define CONSTDEF 2
#define MACROPAR 3
#define MACROBODY 4
#define EXPAND 5
#define LINE 6
#define MACROLOCAL 7
#define BRACEDARGS 8
#define EXPARGS 9

#endif

#ifndef YY_NO_UNISTD_H
/* Special case for "unistd.h", since it is non-ANSI. We include it way
 * down here because we want the user's section 1 to have been scanned first.
 * The user has a chance to override it with an option.
 */
/* %if-c-only */
#include <unistd.h>
/* %endif */
/* %if-c++-only */
/* %endif */
#endif

#ifndef YY_EXTRA_TYPE
#define YY_EXTRA_TYPE void *
#endif

/* %if-c-only Reentrant structure and macros (non-C++). */
/* %if-reentrant */

/* %if-c-only */

/* %endif */

/* %if-reentrant */

/* %endif */

/* Accessor methods to globals.
   These are made visible to non-reentrant scanners for convenience. */

int macrolex_destroy (yyscan_t yyscanner );

int macroget_debug (yyscan_t yyscanner );

void macroset_debug (int debug_flag ,yyscan_t yyscanner );

YY_EXTRA_TYPE macroget_extra (yyscan_t yyscanner );

void macroset_extra (YY_EXTRA_TYPE user_defined ,yyscan_t yyscanner );

FILE *macroget_in (yyscan_t yyscanner );

void macroset_in  (FILE * in_str ,yyscan_t yyscanner );

FILE *macroget_out (yyscan_t yyscanner );

void macroset_out  (FILE * out_str ,yyscan_t yyscanner );

int macroget_leng (yyscan_t yyscanner );

char *macroget_text (yyscan_t yyscanner );

int macroget_lineno (yyscan_t yyscanner );

void macroset_lineno (int line_number ,yyscan_t yyscanner );

/* %if-bison-bridge */

YYSTYPE * macroget_lval (yyscan_t yyscanner );

void macroset_lval (YYSTYPE * yylval_param ,yyscan_t yyscanner );

/* %endif */
/* %endif End reentrant structures and macros. */

/* Macros after this point can all be overridden by user definitions in
 * section 1.
 */

#ifndef YY_SKIP_YYWRAP
#ifdef __cplusplus
extern "C" int macrowrap (yyscan_t yyscanner );
#else
extern int macrowrap (yyscan_t yyscanner );
#endif
#endif

/* %not-for-header */

/* %endif */

#ifndef yytext_ptr
static void yy_flex_strncpy (char *,yyconst char *,int ,yyscan_t yyscanner);
#endif

#ifdef YY_NEED_STRLEN
static int yy_flex_strlen (yyconst char * ,yyscan_t yyscanner);
#endif

#ifndef YY_NO_INPUT
/* %if-c-only Standard (non-C++) definition */
/* %not-for-header */

/* %endif */
#endif

/* %if-c-only */

/* %endif */

/* Amount of stuff to slurp up with each read. */
#ifndef YY_READ_BUF_SIZE
#define YY_READ_BUF_SIZE 8192
#endif

/* Number of entries by which start-condition stack grows. */
#ifndef YY_START_STACK_INCR
#define YY_START_STACK_INCR 25
#endif

/* %if-tables-serialization structures and prototypes */
/* %not-for-header */

/* %not-for-header */

/* Default declaration of generated scanner - a define so the user can
 * easily add parameters.
 */
#ifndef YY_DECL
#define YY_DECL_IS_OURS 1
/* %if-c-only Standard (non-C++) definition */

extern int macrolex (YYSTYPE * yylval_param ,yyscan_t yyscanner);

#define YY_DECL int macrolex (YYSTYPE * yylval_param , yyscan_t yyscanner)
/* %endif */
/* %if-c++-only C++ definition */
/* %endif */
#endif /* !YY_DECL */

/* %not-for-header */

/* %if-c++-only */
/* %not-for-header */

/* %endif */

/* yy_get_previous_state - get the state just before the EOB char was reached */

/* %if-c-only */
/* %not-for-header */

#undef YY_NEW_FILE
#undef YY_FLUSH_BUFFER
#undef yy_set_bol
#undef yy_new_buffer
#undef yy_set_interactive
#undef YY_DO_BEFORE_ACTION

#ifdef YY_DECL_IS_OURS
#undef YY_DECL_IS_OURS
#undef YY_DECL
#endif

#line 598 "macro.l"


#line 459 "macrolexer.h"
#undef macroIN_HEADER
#endif /* macroHEADER_H */
