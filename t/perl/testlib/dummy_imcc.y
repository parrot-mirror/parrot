%{
/*
 * dummy_imcc.y
 *
 * Dummy .y file for testing headerizer
 * Since this file is strictly fodder for our tests, its length has been
 * trimmed severely.  It will no longer work as a yacc/bison file.
 *
 * $Id$
 *
 */

#include <string.h>

#define _PARSER
#define PARSER_MAIN
#include "imc.h"
#include "parrot/dynext.h"

/* prevent declarations of malloc() and free() in the generated parser. */
#define YYMALLOC
#define YYFREE(Ptr) do { /* empty */; } while (YYID (0))

#ifndef YYENABLE_NLS
#  define YYENABLE_NLS 0
#endif

#ifndef YYLTYPE_IS_TRIVIAL
#  define YYLTYPE_IS_TRIVIAL 0
#endif

/* HEADERIZER HFILE: compilers/imcc/imc.h */

/* HEADERIZER BEGIN: static */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

static void add_pcc_named_arg(PARROT_INTERP,
    ARGMOD(SymReg *cur_call),
    ARGMOD(SymReg *name),
    ARGMOD(SymReg *value))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        FUNC_MODIFIES(*cur_call)
        FUNC_MODIFIES(*name)
        FUNC_MODIFIES(*value);

static void add_pcc_named_arg_var(PARROT_INTERP,
    ARGMOD(SymReg *cur_call),
    ARGMOD(SymReg *name),
    ARGMOD(SymReg *value))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        FUNC_MODIFIES(*cur_call)
        FUNC_MODIFIES(*name)
        FUNC_MODIFIES(*value);

static void add_pcc_named_param(PARROT_INTERP,
    ARGMOD(SymReg *cur_call),
    ARGMOD(SymReg *name),
    ARGMOD(SymReg *value))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        FUNC_MODIFIES(*cur_call)
        FUNC_MODIFIES(*name)
        FUNC_MODIFIES(*value);

static void add_pcc_named_result(PARROT_INTERP,
    ARGMOD(SymReg *cur_call),
    ARGMOD(SymReg *name),
    ARGMOD(SymReg *value))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        FUNC_MODIFIES(*cur_call)
        FUNC_MODIFIES(*name)
        FUNC_MODIFIES(*value);

static void add_pcc_named_return(PARROT_INTERP,
    ARGMOD(SymReg *cur_call),
    ARGMOD(SymReg *name),
    ARGMOD(SymReg *value))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        FUNC_MODIFIES(*cur_call)
        FUNC_MODIFIES(*name)
        FUNC_MODIFIES(*value);

static void adv_named_set(PARROT_INTERP, ARGIN(const char *name))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

static void adv_named_set_u(PARROT_INTERP, ARGIN(const char *name))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

static void begin_return_or_yield(PARROT_INTERP, int yield)
        __attribute__nonnull__(1);

static void clear_state(PARROT_INTERP)
        __attribute__nonnull__(1);

static void do_loadlib(PARROT_INTERP, ARGIN(const char *lib))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static Instruction* func_ins(PARROT_INTERP,
    ARGMOD(IMC_Unit *unit),
    ARGIN(SymReg *lhs),
    ARGIN(const char *op),
    ARGMOD(SymReg **r),
    int n,
    int keyv,
    int emit)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        __attribute__nonnull__(5)
        FUNC_MODIFIES(*unit)
        FUNC_MODIFIES(*r);

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static Instruction * iINDEXFETCH(PARROT_INTERP,
    ARGMOD(IMC_Unit *unit),
    ARGIN(SymReg *r0),
    ARGIN(SymReg *r1),
    ARGIN(SymReg *r2))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        __attribute__nonnull__(5)
        FUNC_MODIFIES(*unit);

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static Instruction * iINDEXSET(PARROT_INTERP,
    ARGMOD(IMC_Unit *unit),
    ARGIN(SymReg *r0),
    ARGIN(SymReg *r1),
    ARGIN(SymReg *r2))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        __attribute__nonnull__(5)
        FUNC_MODIFIES(*unit);

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static Instruction * iLABEL(PARROT_INTERP,
    ARGMOD_NULLOK(IMC_Unit *unit),
    ARGMOD(SymReg *r0))
        __attribute__nonnull__(1)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*unit)
        FUNC_MODIFIES(*r0);

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static const char * inv_op(ARGIN(const char *op))
        __attribute__nonnull__(1);

PARROT_IGNORABLE_RESULT
PARROT_CANNOT_RETURN_NULL
static Instruction * iSUBROUTINE(PARROT_INTERP,
    ARGMOD_NULLOK(IMC_Unit *unit),
    ARGMOD(SymReg *r))
        __attribute__nonnull__(1)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*unit)
        FUNC_MODIFIES(*r);

PARROT_IGNORABLE_RESULT
PARROT_CAN_RETURN_NULL
static Instruction * MK_I(PARROT_INTERP,
    ARGMOD(IMC_Unit *unit),
    ARGIN(const char *fmt),
    int n,
    ...)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*unit);

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static Instruction* mk_pmc_const(PARROT_INTERP,
    ARGMOD(IMC_Unit *unit),
    ARGIN(const char *type),
    ARGMOD(SymReg *left),
    ARGIN(const char *constant))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        __attribute__nonnull__(5)
        FUNC_MODIFIES(*unit)
        FUNC_MODIFIES(*left);

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static Instruction* mk_pmc_const_named(PARROT_INTERP,
    ARGMOD(IMC_Unit *unit),
    ARGIN(const char *name),
    ARGMOD(SymReg *left),
    ARGIN(const char *constant))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        __attribute__nonnull__(5)
        FUNC_MODIFIES(*unit)
        FUNC_MODIFIES(*left);

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static SymReg * mk_sub_address_fromc(PARROT_INTERP, ARGIN(const char *name))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static SymReg * mk_sub_address_u(PARROT_INTERP, ARGIN(const char *name))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

static void set_lexical(PARROT_INTERP,
    ARGMOD(SymReg *r),
    ARGMOD(SymReg *name))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*r)
        FUNC_MODIFIES(*name);

#define ASSERT_ARGS_add_pcc_named_arg __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(cur_call) \
    , PARROT_ASSERT_ARG(name) \
    , PARROT_ASSERT_ARG(value))
#define ASSERT_ARGS_add_pcc_named_arg_var __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(cur_call) \
    , PARROT_ASSERT_ARG(name) \
    , PARROT_ASSERT_ARG(value))
#define ASSERT_ARGS_add_pcc_named_param __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(cur_call) \
    , PARROT_ASSERT_ARG(name) \
    , PARROT_ASSERT_ARG(value))
#define ASSERT_ARGS_add_pcc_named_result __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(cur_call) \
    , PARROT_ASSERT_ARG(name) \
    , PARROT_ASSERT_ARG(value))
#define ASSERT_ARGS_add_pcc_named_return __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(cur_call) \
    , PARROT_ASSERT_ARG(name) \
    , PARROT_ASSERT_ARG(value))
#define ASSERT_ARGS_adv_named_set __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(name))
#define ASSERT_ARGS_adv_named_set_u __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(name))
#define ASSERT_ARGS_begin_return_or_yield __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_clear_state __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_do_loadlib __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(lib))
#define ASSERT_ARGS_func_ins __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(unit) \
    , PARROT_ASSERT_ARG(lhs) \
    , PARROT_ASSERT_ARG(op) \
    , PARROT_ASSERT_ARG(r))
#define ASSERT_ARGS_iINDEXFETCH __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(unit) \
    , PARROT_ASSERT_ARG(r0) \
    , PARROT_ASSERT_ARG(r1) \
    , PARROT_ASSERT_ARG(r2))
#define ASSERT_ARGS_iINDEXSET __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(unit) \
    , PARROT_ASSERT_ARG(r0) \
    , PARROT_ASSERT_ARG(r1) \
    , PARROT_ASSERT_ARG(r2))
#define ASSERT_ARGS_iLABEL __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(r0))
#define ASSERT_ARGS_inv_op __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(op))
#define ASSERT_ARGS_iSUBROUTINE __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(r))
#define ASSERT_ARGS_MK_I __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(unit) \
    , PARROT_ASSERT_ARG(fmt))
#define ASSERT_ARGS_mk_pmc_const __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(unit) \
    , PARROT_ASSERT_ARG(type) \
    , PARROT_ASSERT_ARG(left) \
    , PARROT_ASSERT_ARG(constant))
#define ASSERT_ARGS_mk_pmc_const_named __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(unit) \
    , PARROT_ASSERT_ARG(name) \
    , PARROT_ASSERT_ARG(left) \
    , PARROT_ASSERT_ARG(constant))
#define ASSERT_ARGS_mk_sub_address_fromc __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(name))
#define ASSERT_ARGS_mk_sub_address_u __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(name))
#define ASSERT_ARGS_set_lexical __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(r) \
    , PARROT_ASSERT_ARG(name))
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: static */


#define YYDEBUG 1
#define YYERROR_VERBOSE 1

/*
 * We use a pure parser with the interpreter as a parameter. However this still
 * doesn't make the parser reentrant, as there are too many globals around.
 */

/*
 * Choosing instructions for Parrot is pretty easy since many are
 * polymorphic.
 */


/*

=over 4

=item C<static Instruction * MK_I(PARROT_INTERP, IMC_Unit *unit, const char
*fmt, int n, ...)>

build and emitb instruction by INS. fmt may contain:

  op %s, %s # comment

or just

  op

NOTE: Most usage of this function is with
IMCC_INFO(interp)->cur_unit, but there are some
exceptions. Thus, we can't easily factorize that piece of
code.

=cut

 */

PARROT_IGNORABLE_RESULT
PARROT_CAN_RETURN_NULL
static Instruction *
MK_I(PARROT_INTERP, ARGMOD(IMC_Unit *unit), ARGIN(const char *fmt), int n, ...)
{
    ASSERT_ARGS(MK_I)
    char opname[64];
    char *p;
    const char *q;
    va_list ap;
    SymReg *r[IMCC_MAX_FIX_REGS];
    int i;

    for (p = opname, q = fmt; *q && *q != ' ';)
        *p++ = *q++;
    *p = '\0';
    if (!*q)
        fmt = NULL;
    else
        fmt = ++q;
#ifdef OPDEBUG
    fprintf(stderr, "op '%s' format '%s' (%d)\n", opname, fmt?:"", n);
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

/*

=item C<static Instruction* mk_pmc_const(PARROT_INTERP, IMC_Unit *unit, const
char *type, SymReg *left, const char *constant)>

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static Instruction*
mk_pmc_const(PARROT_INTERP, ARGMOD(IMC_Unit *unit), ARGIN(const char *type),
        ARGMOD(SymReg *left), ARGIN(const char *constant))
{
    ASSERT_ARGS(mk_pmc_const)
    const int type_enum = atoi(type);
    const int ascii = (*constant == '\'' || *constant == '"');
    SymReg *rhs;
    SymReg *r[3];
    char   *name;

    if (left->type == VTADDRESS) {      /* IDENTIFIER */
        if (IMCC_INFO(interp)->state->pasm_file) {
            IMCC_fataly(interp, EXCEPTION_SYNTAX_ERROR,
                        "Ident as PMC constant",
                        " %s\n", left->name);
        }
        left->type = VTIDENTIFIER;
        left->set = 'P';
    }
    r[0] = left;
    if (ascii) {
        /* strip delimiters */
        name                   = mem_sys_strdup(constant + 1);
        name[strlen(name) - 1] = 0;
    }
    else {
        name = mem_sys_strdup(constant);
    }

    switch (type_enum) {
      case enum_class_Sub:
      case enum_class_Coroutine:
        rhs = mk_const(interp, name, 'p');

        if (!ascii)
            rhs->type |= VT_ENCODED;

        rhs->usage    |= U_FIXUP | U_SUBID_LOOKUP;
        break;
      default:
        rhs = mk_const(interp, name, 'P');
        break;
    }

    r[1]          = rhs;
    rhs->pmc_type = type_enum;

    mem_sys_free(name);

    return INS(interp, unit, "set_p_pc", "", r, 2, 0, 1);
}

/*

=item C<static Instruction* mk_pmc_const_named(PARROT_INTERP, IMC_Unit *unit,
const char *name, SymReg *left, const char *constant)>

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static Instruction*
mk_pmc_const_named(PARROT_INTERP, ARGMOD(IMC_Unit *unit),
    ARGIN(const char *name), ARGMOD(SymReg *left), ARGIN(const char *constant))
{
    ASSERT_ARGS(mk_pmc_const_named)
    SymReg *rhs;
    SymReg *r[3];
    char   *const_name;
    const int ascii       = (*constant == '\'' || *constant == '"');
    char   *unquoted_name = mem_sys_strdup(name + 1);
    size_t  name_length   = strlen(unquoted_name) - 1;

    unquoted_name[name_length] = 0;

    if (left->type == VTADDRESS) {      /* IDENTIFIER */
        if (IMCC_INFO(interp)->state->pasm_file) {
            IMCC_fataly(interp, EXCEPTION_SYNTAX_ERROR,
                        "Ident as PMC constant",
                        " %s\n", left->name);
        }
        left->type = VTIDENTIFIER;
        left->set = 'P';
    }
    r[0] = left;
    if (ascii) {
        /* strip delimiters */
        const_name                         = mem_sys_strdup(constant + 1);
        const_name[strlen(const_name) - 1] = 0;
    }
    else {
        const_name = mem_sys_strdup(constant);
    }

    if ((strncmp(unquoted_name, "Sub",       name_length) == 0)
    ||  (strncmp(unquoted_name, "Coroutine", name_length) == 0)) {
        rhs = mk_const(interp, const_name, 'p');

        if (!ascii)
            rhs->type |= VT_ENCODED;

        rhs->usage    |= U_FIXUP | U_SUBID_LOOKUP;
    }
    else {
        rhs = mk_const(interp, const_name, 'P');
    }

    r[1]          = rhs;
    rhs->pmc_type = Parrot_pmc_get_type_str(interp,
        Parrot_str_new(interp, unquoted_name, name_length));

    mem_sys_free(unquoted_name);
    mem_sys_free(const_name);

    return INS(interp, unit, "set_p_pc", "", r, 2, 0, 1);
}

/*

=item C<static Instruction* func_ins(PARROT_INTERP, IMC_Unit *unit, SymReg *lhs,
const char *op, SymReg **r, int n, int keyv, int emit)>

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static Instruction*
func_ins(PARROT_INTERP, ARGMOD(IMC_Unit *unit), ARGIN(SymReg *lhs), ARGIN(const char *op),
         ARGMOD(SymReg **r), int n, int keyv, int emit)
{
    ASSERT_ARGS(func_ins)
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

=item C<static void clear_state(PARROT_INTERP)>

=cut

*/

static void
clear_state(PARROT_INTERP)
{
    ASSERT_ARGS(clear_state)
    IMCC_INFO(interp) -> nargs = 0;
    IMCC_INFO(interp) -> keyvec = 0;
}

/*

=item C<Instruction * INS_LABEL(PARROT_INTERP, IMC_Unit *unit, SymReg *r0, int
emit)>

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
Instruction *
INS_LABEL(PARROT_INTERP, ARGMOD_NULLOK(IMC_Unit *unit), ARGMOD(SymReg *r0), int emit)
{
    ASSERT_ARGS(INS_LABEL)

    Instruction * const ins = _mk_instruction("", "%s:", 1, &r0, 0);
    ins->type               = ITLABEL;
    r0->first_ins           = ins;

    if (emit)
        emitb(interp, unit, ins);

    return ins;
}

/*

=item C<static Instruction * iLABEL(PARROT_INTERP, IMC_Unit *unit, SymReg *r0)>

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static Instruction *
iLABEL(PARROT_INTERP, ARGMOD_NULLOK(IMC_Unit *unit), ARGMOD(SymReg *r0))
{
    ASSERT_ARGS(iLABEL)
    Instruction * const i = INS_LABEL(interp, unit, r0, 1);
    i->line               = IMCC_INFO(interp)->line;

    clear_state(interp);
    return i;
}

/*

=item C<static Instruction * iSUBROUTINE(PARROT_INTERP, IMC_Unit *unit, SymReg
*r)>

=cut

*/

PARROT_IGNORABLE_RESULT
PARROT_CANNOT_RETURN_NULL
static Instruction *
iSUBROUTINE(PARROT_INTERP, ARGMOD_NULLOK(IMC_Unit *unit), ARGMOD(SymReg *r))
{
    ASSERT_ARGS(iSUBROUTINE)
    Instruction * const i = iLABEL(interp, unit, r);

    r->type    = (r->type & VT_ENCODED) ? VT_PCC_SUB|VT_ENCODED : VT_PCC_SUB;
    r->pcc_sub = mem_gc_allocate_zeroed_typed(interp, pcc_sub_t);

    IMCC_INFO(interp)->cur_call = r;
    i->line                     = IMCC_INFO(interp)->line;

    add_namespace(interp, unit);
    return i;
}

/*

=item C<static Instruction * iINDEXFETCH(PARROT_INTERP, IMC_Unit *unit, SymReg
*r0, SymReg *r1, SymReg *r2)>

substr or X = P[key]

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static Instruction *
iINDEXFETCH(PARROT_INTERP, ARGMOD(IMC_Unit *unit), ARGIN(SymReg *r0), ARGIN(SymReg *r1),
        ARGIN(SymReg *r2))
{
    ASSERT_ARGS(iINDEXFETCH)
    IMCC_INFO(interp) -> keyvec |= KEY_BIT(2);
    return MK_I(interp, unit, "set %s, %s[%s]", 3, r0, r1, r2);
}

/*

=item C<static Instruction * iINDEXSET(PARROT_INTERP, IMC_Unit *unit, SymReg
*r0, SymReg *r1, SymReg *r2)>

substr or P[key] = X

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static Instruction *
iINDEXSET(PARROT_INTERP, ARGMOD(IMC_Unit *unit), ARGIN(SymReg *r0), ARGIN(SymReg *r1),
        ARGIN(SymReg *r2))
{
    ASSERT_ARGS(iINDEXSET)
    if (r0->set == 'P') {
        IMCC_INFO(interp)->keyvec |= KEY_BIT(1);
        MK_I(interp, unit, "set %s[%s], %s", 3, r0, r1, r2);
    }
    else
        IMCC_fataly(interp, EXCEPTION_SYNTAX_ERROR,
            "unsupported indexed set op\n");

    return NULL;
}

/*

=item C<static const char * inv_op(const char *op)>

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static const char *
inv_op(ARGIN(const char *op))
{
    ASSERT_ARGS(inv_op)
    int n;
    return get_neg_op(op, &n);
}

/*

=item C<Instruction * IMCC_create_itcall_label(PARROT_INTERP)>

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
Instruction *
IMCC_create_itcall_label(PARROT_INTERP)
{
    ASSERT_ARGS(IMCC_create_itcall_label)
    char         name[128];
    SymReg      *r;
    Instruction *i;

    snprintf(name, sizeof (name), "%cpcc_sub_call_%d", IMCC_INTERNAL_CHAR,
        IMCC_INFO(interp)->cnr++);

    r       = mk_pcc_sub(interp, name, 0);
    i       = iLABEL(interp, IMCC_INFO(interp)->cur_unit, r);
    i->type = ITCALL | ITPCCSUB;

    IMCC_INFO(interp)->cur_call = r;

    return i;
}

/*

=item C<static SymReg * mk_sub_address_fromc(PARROT_INTERP, const char *name)>

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static SymReg *
mk_sub_address_fromc(PARROT_INTERP, ARGIN(const char *name))
{
    ASSERT_ARGS(mk_sub_address_fromc)
    /* name is a quoted sub name */
    SymReg *r;
    char   *name_copy;

    /* interpolate only if the first character is a double-quote */
    if (*name == '"') {
        STRING *unescaped = Parrot_str_unescape(interp, name, '"', NULL);
        name_copy         = Parrot_str_to_cstring(interp, unescaped);
    }
    else {
        name_copy = mem_sys_strdup(name);
        name_copy[ strlen(name) - 1 ] = 0;
    }

    r = mk_sub_address(interp, name_copy + 1);
    mem_sys_free(name_copy);

    return r;
}

/*

=item C<static SymReg * mk_sub_address_u(PARROT_INTERP, const char *name)>

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static SymReg *
mk_sub_address_u(PARROT_INTERP, ARGIN(const char *name))
{
    ASSERT_ARGS(mk_sub_address_u)
    SymReg * const r = mk_sub_address(interp, name);
    r->type         |= VT_ENCODED;

    return r;
}

/*

=item C<void IMCC_itcall_sub(PARROT_INTERP, SymReg *sub)>

=cut

*/

void
IMCC_itcall_sub(PARROT_INTERP, ARGIN(SymReg *sub))
{
    ASSERT_ARGS(IMCC_itcall_sub)
    IMCC_INFO(interp)->cur_call->pcc_sub->sub = sub;

    if (IMCC_INFO(interp)->cur_obj) {
        if (IMCC_INFO(interp)->cur_obj->set != 'P')
            IMCC_fataly(interp, EXCEPTION_SYNTAX_ERROR, "object isn't a PMC");

        IMCC_INFO(interp)->cur_call->pcc_sub->object =
            IMCC_INFO(interp)->cur_obj;
        IMCC_INFO(interp)->cur_obj = NULL;
    }
}


/*

=item C<static void begin_return_or_yield(PARROT_INTERP, int yield)>

=cut

*/

static void
begin_return_or_yield(PARROT_INTERP, int yield)
{
    ASSERT_ARGS(begin_return_or_yield)
    Instruction *i;
    Instruction * const ins = IMCC_INFO(interp)->cur_unit->instructions;
    char                name[128];

    if (!ins || !ins->symregs[0] || !(ins->symregs[0]->type & VT_PCC_SUB))
        IMCC_fataly(interp, EXCEPTION_SYNTAX_ERROR,
                    "yield or return directive outside pcc subroutine\n");
    ins->symregs[0]->pcc_sub->yield = yield;
    snprintf(name, sizeof (name), yield ? "%cpcc_sub_yield_%d" : "%cpcc_sub_ret_%d",
            IMCC_INTERNAL_CHAR, IMCC_INFO(interp)->cnr++);
    interp->imc_info->sr_return = mk_pcc_sub(interp, name, 0);
    i = iLABEL(interp, IMCC_INFO(interp)->cur_unit, interp->imc_info->sr_return);
    i->type = yield ? ITPCCSUB | ITLABEL | ITPCCYIELD : ITPCCSUB | ITLABEL ;
    interp->imc_info->asm_state = yield ? AsmInYield : AsmInReturn;
}

/*

=item C<static void set_lexical(PARROT_INTERP, SymReg *r, SymReg *name)>

=cut

*/

static void
set_lexical(PARROT_INTERP, ARGMOD(SymReg *r), ARGMOD(SymReg *name))
{
    ASSERT_ARGS(set_lexical)

    r->usage |= U_LEXICAL;

    if (name == r->reg)
        IMCC_fataly(interp, EXCEPTION_SYNTAX_ERROR,
            "register %s already declared as lexical %s", r->name, name->name);

    /* chain all names in r->reg */
    name->reg    = r->reg;
    r->reg       = name;
    name->usage |= U_LEXICAL;
    r->use_count++;
}


/*

=item C<static void add_pcc_named_arg(PARROT_INTERP, SymReg *cur_call, SymReg
*name, SymReg *value)>

=cut

*/

static void
add_pcc_named_arg(PARROT_INTERP,
        ARGMOD(SymReg *cur_call),
        ARGMOD(SymReg *name),
        ARGMOD(SymReg *value))
{
    ASSERT_ARGS(add_pcc_named_arg)
    name->type  |= VT_NAMED;

    add_pcc_arg(interp, cur_call, name);
    add_pcc_arg(interp, cur_call, value);
}

/*

=item C<static void add_pcc_named_arg_var(PARROT_INTERP, SymReg *cur_call,
SymReg *name, SymReg *value)>

=cut

*/

static void
add_pcc_named_arg_var(PARROT_INTERP,
        ARGMOD(SymReg *cur_call),
        ARGMOD(SymReg *name),
        ARGMOD(SymReg *value))
{
    ASSERT_ARGS(add_pcc_named_arg_var)
    name->type |= VT_NAMED;
    add_pcc_arg(interp, cur_call, name);
    add_pcc_arg(interp, cur_call, value);
}

/*

=item C<static void add_pcc_named_result(PARROT_INTERP, SymReg *cur_call, SymReg
*name, SymReg *value)>

=cut

*/

static void
add_pcc_named_result(PARROT_INTERP,
        ARGMOD(SymReg *cur_call),
        ARGMOD(SymReg *name),
        ARGMOD(SymReg *value))
{
    ASSERT_ARGS(add_pcc_named_result)
    name->type         |= VT_NAMED;

    add_pcc_result(interp, cur_call, name);
    add_pcc_result(interp, cur_call, value);
}

/*

=item C<static void add_pcc_named_param(PARROT_INTERP, SymReg *cur_call, SymReg
*name, SymReg *value)>

=cut

*/

static void
add_pcc_named_param(PARROT_INTERP,
        ARGMOD(SymReg *cur_call),
        ARGMOD(SymReg *name),
        ARGMOD(SymReg *value))
{
    ASSERT_ARGS(add_pcc_named_param)
    name->type         |= VT_NAMED;

    add_pcc_arg(interp, cur_call, name);
    add_pcc_arg(interp, cur_call, value);
}

/*

=item C<static void add_pcc_named_return(PARROT_INTERP, SymReg *cur_call, SymReg
*name, SymReg *value)>

=cut

*/

static void
add_pcc_named_return(PARROT_INTERP,
        ARGMOD(SymReg *cur_call),
        ARGMOD(SymReg *name),
        ARGMOD(SymReg *value))
{
    ASSERT_ARGS(add_pcc_named_return)
    name->type         |= VT_NAMED;

    add_pcc_result(interp, cur_call, name);
    add_pcc_result(interp, cur_call, value);
}

/*

=item C<static void adv_named_set(PARROT_INTERP, const char *name)>

Sets the name of the current named argument.

C<adv_named_set_u> is the Unicode version of this function.

=cut

*/

static void
adv_named_set(PARROT_INTERP, ARGIN(const char *name))
{
    ASSERT_ARGS(adv_named_set)
    if (IMCC_INFO(interp)->adv_named_id)
        IMCC_fataly(interp, EXCEPTION_SYNTAX_ERROR,
                    "Named parameter with more than one name.\n");

    IMCC_INFO(interp)->adv_named_id = mk_const(interp, name, 'S');
}

static void
adv_named_set_u(PARROT_INTERP, ARGIN(const char *name))
{
    ASSERT_ARGS(adv_named_set_u)
    if (IMCC_INFO(interp)->adv_named_id)
        IMCC_fataly(interp, EXCEPTION_SYNTAX_ERROR,
                    "Named parameter with more than one name.\n");

    IMCC_INFO(interp)->adv_named_id = mk_const(interp, name, 'U');
}

/*

=item C<static void do_loadlib(PARROT_INTERP, const char *lib)>

=cut

*/

static void
do_loadlib(PARROT_INTERP, ARGIN(const char *lib))
{
    ASSERT_ARGS(do_loadlib)
    STRING * const s       = Parrot_str_unescape(interp, lib + 1, '"', NULL);
    PMC    * const lib_pmc = Parrot_load_lib(interp, s, NULL);
    if (PMC_IS_NULL(lib_pmc) || !VTABLE_get_bool(interp, lib_pmc)) {
        IMCC_fataly(interp, EXCEPTION_LIBRARY_ERROR,
            "loadlib directive could not find library `%S'", s);
    }
    Parrot_register_HLL_lib(interp, s);
}

/* HEADERIZER STOP */

/* Some bogus copy between headerizer stop and the yacc %} delimiter.
 */

%}

%union {
    IdList * idlist;
    int t;
    char * s;
    SymReg * sr;
    Instruction *i;
}


/* The End */
%%

/* I need this prototype somewhere... */
char *yyget_text(yyscan_t yyscanner);

/* I do not like this function, but, atm, it is the only way I can
 * make the code in yyerror work without segfault on some specific
 * cases.
 */
/* int yyholds_char(yyscan_t yyscanner); */

int yyerror(void *yyscanner, PARROT_INTERP, const char *s)
{
    /* If the error occurr in the end of the buffer (I mean, the last
     * us. This means it may segfault. */

    return 0;
}

/*

=back

 */
/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
