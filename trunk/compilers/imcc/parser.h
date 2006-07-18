/* 
 * XXX - We need a description of the file here
 *
 * $Id$
 */

#if !defined(PARROT_IMCC_PARSER_H_GUARD)
#define PARROT_IMCC_PARSER_H_GUARD

#ifdef PARSER_MAIN
#define EXTERN
#else
#define EXTERN extern
#endif

typedef struct _IdList {
    char* id;
    int unique_reg;
    struct _IdList*  next;
} IdList;

#include "imcparser.h"

/* short ranged globals for lexer state */
EXTERN int expect_pasm;
EXTERN int is_def;

/* bison */
PARROT_API EXTERN int yydebug;

#define KEY_BIT(argnum) (1 << (argnum))

/* An opaque pointer. */
#ifndef YY_TYPEDEF_YY_SCANNER_T
#define YY_TYPEDEF_YY_SCANNER_T
typedef void* yyscan_t;
#endif

SymReg * macro(Interp *, char *name);

PARROT_API int yyparse (yyscan_t, Interp*);
PARROT_API int yylex(YYSTYPE *, yyscan_t, Interp*);
PARROT_API int yylex_destroy (yyscan_t);
PARROT_API int do_yylex_init (yyscan_t*);

int yylex_init (yyscan_t*);
int yyget_column (yyscan_t);
void yyset_column (int column_no , yyscan_t);
int yyerror(yyscan_t, Interp*, char *);

void op_fullname(char * dest, const char * name, SymReg * args[], int, int);
PARROT_API void open_comp_unit(void);
void register_compilers(Parrot_Interp);
void *imcc_eval_pasm(Parrot_Interp, const char *s);
void *imcc_eval_pir (Parrot_Interp, const char *s);
int try_find_op(Parrot_Interp, IMC_Unit *, char *, SymReg **, int, int, int);
Instruction * multi_keyed(Interp *interpreter, IMC_Unit *, char *name,
    SymReg ** r, int nr, int keyvec, int emit);

extern void compile_file(Interp *interp, FILE *file, void *);
extern void compile_string(Interp *interp, char *, void *);

#endif /* PARROT_IMCC_PARSER_H_GUARD */

/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
*/
