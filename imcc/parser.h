#ifndef __PARSER_H
#define __PARSER_H

#ifdef MAIN
#define EXTERN
#else
#define EXTERN extern
#endif

EXTERN SymReg *regs[IMCC_MAX_REGS];
EXTERN int keyvec;
EXTERN int nargs;

EXTERN int expect_pasm;
EXTERN int pasm_file;
EXTERN int is_def;
EXTERN int IMCC_DEBUG;
EXTERN int gc_off;
EXTERN char* output;
EXTERN FILE *yyin;
EXTERN int yydebug;

#define KEY_BIT(argnum) (1 << (argnum))


SymReg * macro(char *name);
int yyerror(char *);

#endif

/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
*/
