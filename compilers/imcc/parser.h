/*
 * XXX - We need a description of the file here
 *
 * $Id$
 */

#ifndef PARROT_IMCC_PARSER_H_GUARD
#define PARROT_IMCC_PARSER_H_GUARD

#ifdef PARSER_MAIN
#  define EXTERN
#else
#  define EXTERN extern
#endif

typedef struct _IdList {
    char* id;
    int unique_reg;
    struct _IdList*  next;
} IdList;

#include "imcparser.h"

/* short ranged globals for lexer state */
EXTERN int is_def;

#define KEY_BIT(argnum) (1 << (argnum))

/* An opaque pointer. */
#ifndef YY_TYPEDEF_YY_SCANNER_T
#  define YY_TYPEDEF_YY_SCANNER_T
typedef void* yyscan_t;
#endif

SymReg * macro(PARROT_INTERP, char *name);

PARROT_API int yyparse(yyscan_t, PARROT_INTERP);
PARROT_API int yylex(YYSTYPE *, yyscan_t, PARROT_INTERP);
PARROT_API int yylex_destroy(yyscan_t);

int yylex_init(yyscan_t*);
int yyget_column(yyscan_t);
void yyset_column(int column_no , yyscan_t);
int yyerror(yyscan_t, Interp*, char *);

/* These are generated by flex. YY_EXTRA_TYPE is used also by flex, so
 * defining it is handy: we do not need typecasts. */
#define YY_EXTRA_TYPE Interp*
YY_EXTRA_TYPE yyget_extra(yyscan_t yyscanner );
void yyset_extra(YY_EXTRA_TYPE user_defined ,yyscan_t yyscanner );

extern void compile_file(PARROT_INTERP, FILE *file, void *);
extern void compile_string(PARROT_INTERP, char *, void *);

int at_eof(yyscan_t yyscanner);

#endif /* PARROT_IMCC_PARSER_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
