/* $Id$ */

/* GNU m4 -- A simple macro processor
   Copyright (C) 1989, 90, 91, 92, 93, 94 Free Software Foundation, Inc.
  
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
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#include <stdlib.h> 
#include <stdio.h> 
#include <error.h> 
#include <ctype.h> 
typedef int boolean;
int warning_status;
typedef int eval_t;

/* Error handling.  */
#define CODE_SIZE 128

/* This file contains the functions to evaluate integer expressions for
   the "eval" macro.  It is a little, fairly self-contained module, with
   its own scanner, and a recursive descent parser.  The only entry point
   is evaluate ().  */


/* Evaluates token types.  */
typedef enum eval_token
  {
    ERROR,
    PLUS, MINUS,
    EXPONENT,
    TIMES, DIVIDE, MODULO,
    EQ, NOTEQ, GT, GTEQ, LS, LSEQ,
    LSHIFT, RSHIFT,
    LNOT, LAND, LOR,
    NOT, AND, OR, XOR,
    LEFTP, RIGHTP,
    NUMBER, EOTEXT
  }
eval_token;

/* Error types.  */

typedef enum eval_error
  {
    NO_ERROR,
    MISSING_RIGHT,
    SYNTAX_ERROR,
    UNKNOWN_INPUT,
    EXCESS_INPUT,
    DIVIDE_ZERO,
    MODULO_ZERO
  }
eval_error;


static eval_error logical_or_term( eval_token, eval_t * );

static eval_error logical_and_term( eval_token, eval_t * );
static eval_error or_term( eval_token, eval_t * );
static eval_error xor_term( eval_token, eval_t * );
static eval_error and_term( eval_token, eval_t * );
static eval_error not_term( eval_token, eval_t * );
static eval_error logical_not_term( eval_token, eval_t * );
static eval_error cmp_term( eval_token, eval_t * );
static eval_error shift_term( eval_token, eval_t * );
static eval_error add_term( eval_token, eval_t * );
static eval_error mult_term( eval_token, eval_t * );
static eval_error exp_term( eval_token, eval_t * );
static eval_error unary_term( eval_token, eval_t * );
static eval_error simple_term( eval_token, eval_t * );

/*--------------------.
| Lexical functions.  |
`--------------------*/

/* Pointer to next character of input text.  */
static const char *eval_text;

/* Value of eval_text, from before last call of eval_lex ().  This is so we
   can back up, if we have read too much.  */
static const char *last_text;

static void eval_init_lex( const char *text )
{
  eval_text = text;
  last_text = NULL;
}

static void
eval_undo (void)
{
  eval_text = last_text;
}

/* VAL is numerical value, if any.  */

static eval_token eval_lex( eval_t *val )
{
  while ( isspace(*eval_text) ) eval_text++;

  last_text = eval_text;

  if (*eval_text == '\0') return EOTEXT;

  if (isdigit (*eval_text))
  {
      int base, digit;

      if (*eval_text == '0')
	{
	  eval_text++;
	  switch (*eval_text)
	    {
	    case 'x':
	    case 'X':
	      base = 16;
	      eval_text++;
	      break;

	    case 'b':
	    case 'B':
	      base = 2;
	      eval_text++;
	      break;

	    case 'r':
	    case 'R':
	      base = 0;
	      eval_text++;
	      while (isdigit (*eval_text) && base <= 36)
		base = 10 * base + *eval_text++ - '0';
	      if (base == 0 || base > 36 || *eval_text != ':')
		return ERROR;
	      eval_text++;
	      break;

	    default:
	      base = 8;
	    }
	}
      else
	base = 10;

      (*val) = 0;
      for (; *eval_text; eval_text++)
	{
	  if (isdigit (*eval_text))
	    digit = *eval_text - '0';
	  else if (islower (*eval_text))
	    digit = *eval_text - 'a' + 10;
	  else if (isupper (*eval_text))
	    digit = *eval_text - 'A' + 10;
	  else
	    break;

	  if (digit >= base)
	    break;

	  (*val) = (*val) * base + digit;
	}
      return NUMBER;
    }

  switch (*eval_text++)
    {
    case '+':
      return PLUS;
    case '-':
      return MINUS;
    case '*':
      if (*eval_text == '*')
	{
	  eval_text++;
	  return EXPONENT;
	}
      else
	return TIMES;
    case '/':
      return DIVIDE;
    case '%':
      return MODULO;
    case '=':
      if (*eval_text == '=')
	eval_text++;
      return EQ;
    case '!':
      if (*eval_text == '=')
	{
	  eval_text++;
	  return NOTEQ;
	}
      else
	return LNOT;
    case '>':
      if (*eval_text == '=')
	{
	  eval_text++;
	  return GTEQ;
	}
      else if (*eval_text == '>')
	{
	  eval_text++;
	  return RSHIFT;
	}
      else
	return GT;
    case '<':
      if (*eval_text == '=')
	{
	  eval_text++;
	  return LSEQ;
	}
      else if (*eval_text == '<')
	{
	  eval_text++;
	  return LSHIFT;
	}
      else
	return LS;
    case '^':
      return XOR;
    case '~':
      return NOT;
    case '&':
      if (*eval_text == '&')
	{
	  eval_text++;
	  return LAND;
	}
      else
	return AND;
    case '|':
      if (*eval_text == '|')
	{
	  eval_text++;
	  return LOR;
	}
      else
	return OR;
    case '(':
      return LEFTP;
    case ')':
      return RIGHTP;
    default:
      return ERROR;
    }
}

/*---------------------------------------.
| Main entry point, called from "eval".	 |
`---------------------------------------*/

boolean
evaluate (const char *expr, eval_t *val)
{
    eval_token et;
    eval_error err;

    eval_init_lex (expr);
    et = eval_lex (val);
    err = logical_or_term( et, val );

  if (err == NO_ERROR && *eval_text != '\0')
    err = EXCESS_INPUT;
    
  switch (err)
    {
    case NO_ERROR:
      break;

    case MISSING_RIGHT:
      fprintf( stderr, "Bad expression in eval (missing right parenthesis): %s",
		expr);
      break;

    case SYNTAX_ERROR:
      fprintf( stderr, "Bad expression in eval: %s", expr);
      break;

    case UNKNOWN_INPUT:
      fprintf( stderr, "Bad expression in eval (bad input): %s", expr);
      break;

    case EXCESS_INPUT:
      fprintf( stderr, "Bad expression in eval (excess input): %s", expr);
      break;

    case DIVIDE_ZERO:
      fprintf( stderr, "Divide by zero in eval: %s", expr);
      break;

    case MODULO_ZERO:
      fprintf( stderr, "Modulo by zero in eval: %s", expr);
      break;

    default:
      fprintf( stderr, "INTERNAL ERROR: Bad error code in evaluate ()");
      abort ();
    }

  return (boolean) (err != NO_ERROR);
}

/*---------------------------.
| Recursive descent parser.  |
`---------------------------*/

static eval_error
logical_or_term (eval_token et, eval_t *v1)
{
  eval_t v2;
  eval_error er;

  if ((er = logical_and_term (et, v1)) != NO_ERROR)
    return er;

  while ((et = eval_lex (&v2)) == LOR)
    {
      et = eval_lex (&v2);
      if (et == ERROR)
	return UNKNOWN_INPUT;

      if ((er = logical_and_term (et, &v2)) != NO_ERROR)
	return er;

      *v1 = *v1 || v2;
    }
  if (et == ERROR)
    return UNKNOWN_INPUT;

  eval_undo ();
  return NO_ERROR;
}

static eval_error
logical_and_term (eval_token et, eval_t *v1)
{
  eval_t v2;
  eval_error er;

  if ((er = or_term (et, v1)) != NO_ERROR)
    return er;

  while ((et = eval_lex (&v2)) == LAND)
    {
      et = eval_lex (&v2);
      if (et == ERROR)
	return UNKNOWN_INPUT;

      if ((er = or_term (et, &v2)) != NO_ERROR)
	return er;

      *v1 = *v1 && v2;
    }
  if (et == ERROR)
    return UNKNOWN_INPUT;

  eval_undo ();
  return NO_ERROR;
}

static eval_error
or_term (eval_token et, eval_t *v1)
{
  eval_t v2;
  eval_error er;

  if ((er = xor_term (et, v1)) != NO_ERROR)
    return er;

  while ((et = eval_lex (&v2)) == OR)
    {
      et = eval_lex (&v2);
      if (et == ERROR)
	return UNKNOWN_INPUT;

      if ((er = xor_term (et, &v2)) != NO_ERROR)
	return er;

      *v1 = *v1 | v2;
    }
  if (et == ERROR)
    return UNKNOWN_INPUT;

  eval_undo ();
  return NO_ERROR;
}

static eval_error
xor_term (eval_token et, eval_t *v1)
{
  eval_t v2;
  eval_error er;

  if ((er = and_term (et, v1)) != NO_ERROR)
    return er;

  while ((et = eval_lex (&v2)) == XOR)
    {
      et = eval_lex (&v2);
      if (et == ERROR)
	return UNKNOWN_INPUT;

      if ((er = and_term (et, &v2)) != NO_ERROR)
	return er;

      *v1 = *v1 ^ v2;
    }
  if (et == ERROR)
    return UNKNOWN_INPUT;

  eval_undo ();
  return NO_ERROR;
}

static eval_error
and_term (eval_token et, eval_t *v1)
{
  eval_t v2;
  eval_error er;

  if ((er = not_term (et, v1)) != NO_ERROR)
    return er;

  while ((et = eval_lex (&v2)) == AND)
    {
      et = eval_lex (&v2);
      if (et == ERROR)
	return UNKNOWN_INPUT;

      if ((er = not_term (et, &v2)) != NO_ERROR)
	return er;

      *v1 = *v1 & v2;
    }
  if (et == ERROR)
    return UNKNOWN_INPUT;

  eval_undo ();
  return NO_ERROR;
}

static eval_error
not_term (eval_token et, eval_t *v1)
{
  eval_error er;

  if (et == NOT)
    {
      et = eval_lex (v1);
      if (et == ERROR)
	return UNKNOWN_INPUT;

      if ((er = not_term (et, v1)) != NO_ERROR)
	return er;
      *v1 = ~*v1;
    }
  else
    if ((er = logical_not_term (et, v1)) != NO_ERROR)
      return er;

  return NO_ERROR;
}

static eval_error
logical_not_term (eval_token et, eval_t *v1)
{
  eval_error er;

  if (et == LNOT)
    {
      et = eval_lex (v1);
      if (et == ERROR)
	return UNKNOWN_INPUT;

      if ((er = logical_not_term (et, v1)) != NO_ERROR)
	return er;
      *v1 = !*v1;
    }
  else
    if ((er = cmp_term (et, v1)) != NO_ERROR)
      return er;

  return NO_ERROR;
}

static eval_error
cmp_term (eval_token et, eval_t *v1)
{
  eval_token op;
  eval_t v2;
  eval_error er;

  if ((er = shift_term (et, v1)) != NO_ERROR)
    return er;

  while ((op = eval_lex (&v2)) == EQ || op == NOTEQ
	 || op == GT || op == GTEQ
	 || op == LS || op == LSEQ)
    {

      et = eval_lex (&v2);
      if (et == ERROR)
	return UNKNOWN_INPUT;

      if ((er = shift_term (et, &v2)) != NO_ERROR)
	return er;

      switch (op)
	{
	case EQ:
	  *v1 = *v1 == v2;
	  break;

	case NOTEQ:
	  *v1 = *v1 != v2;
	  break;

	case GT:
	  *v1 = *v1 > v2;
	  break;

	case GTEQ:
	  *v1 = *v1 >= v2;
	  break;

	case LS:
	  *v1 = *v1 < v2;
	  break;

	case LSEQ:
	  *v1 = *v1 <= v2;
	  break;

	default:
	  fprintf( stderr, "INTERNAL ERROR: Bad comparison operator in cmp_term ()");
	  abort ();
	}
    }
  if (op == ERROR)
    return UNKNOWN_INPUT;

  eval_undo ();
  return NO_ERROR;
}

static eval_error
shift_term (eval_token et, eval_t *v1)
{
  eval_token op;
  eval_t v2;
  eval_error er;

  if ((er = add_term (et, v1)) != NO_ERROR)
    return er;

  while ((op = eval_lex (&v2)) == LSHIFT || op == RSHIFT)
    {

      et = eval_lex (&v2);
      if (et == ERROR)
	return UNKNOWN_INPUT;

      if ((er = add_term (et, &v2)) != NO_ERROR)
	return er;

      switch (op)
	{
	case LSHIFT:
	  *v1 = *v1 << v2;
	  break;

	case RSHIFT:
	  *v1 = *v1 >> v2;
	  break;

	default:
	  fprintf( stderr, "INTERNAL ERROR: Bad shift operator in shift_term ()");
	  abort ();
	}
    }
  if (op == ERROR)
    return UNKNOWN_INPUT;

  eval_undo ();
  return NO_ERROR;
}

static eval_error
add_term (eval_token et, eval_t *v1)
{
  eval_token op;
  eval_t v2;
  eval_error er;

  if ((er = mult_term (et, v1)) != NO_ERROR)
    return er;

  while ((op = eval_lex (&v2)) == PLUS || op == MINUS)
    {
      et = eval_lex (&v2);
      if (et == ERROR)
	return UNKNOWN_INPUT;

      if ((er = mult_term (et, &v2)) != NO_ERROR)
	return er;

      if (op == PLUS)
	*v1 = *v1 + v2;
      else
	*v1 = *v1 - v2;
    }
  if (op == ERROR)
    return UNKNOWN_INPUT;

  eval_undo ();
  return NO_ERROR;
}

static eval_error
mult_term (eval_token et, eval_t *v1)
{
  eval_token op;
  eval_t v2;
  eval_error er;

  if ((er = exp_term (et, v1)) != NO_ERROR)
    return er;

  while ((op = eval_lex (&v2)) == TIMES || op == DIVIDE || op == MODULO)
    {
      et = eval_lex (&v2);
      if (et == ERROR)
	return UNKNOWN_INPUT;

      if ((er = exp_term (et, &v2)) != NO_ERROR)
	return er;

      switch (op)
	{
	case TIMES:
	  *v1 = *v1 * v2;
	  break;

	case DIVIDE:
	  if (v2 == 0)
	    return DIVIDE_ZERO;
	  else
	    *v1 = *v1 / v2;
	  break;

	case MODULO:
	  if (v2 == 0)
	    return MODULO_ZERO;
	  else
	    *v1 = *v1 % v2;
	  break;

	default:
	  fprintf( stderr, "INTERNAL ERROR: Bad operator in mult_term ()");
	  abort ();
	}
    }
  if (op == ERROR)
    return UNKNOWN_INPUT;

  eval_undo ();
  return NO_ERROR;
}

static eval_error
exp_term (eval_token et, eval_t *v1)
{
  register eval_t result;
  eval_t v2;
  eval_error er;

  if ((er = unary_term (et, v1)) != NO_ERROR)
    return er;
  result = *v1;

  while ((et = eval_lex (&v2)) == EXPONENT)
    {
      et = eval_lex (&v2);
      if (et == ERROR)
	return UNKNOWN_INPUT;

      if ((er = exp_term (et, &v2)) != NO_ERROR)
	return er;

      result = 1;
      while (v2-- > 0)
	result *= *v1;
      *v1 = result;
    }
  if (et == ERROR)
    return UNKNOWN_INPUT;

  eval_undo ();
  return NO_ERROR;
}

static eval_error
unary_term (eval_token et, eval_t *v1)
{
  eval_token et2 = et;
  eval_error er;

  if (et == PLUS || et == MINUS)
    {
      et2 = eval_lex (v1);
      if (et2 == ERROR)
	return UNKNOWN_INPUT;

      if ((er = simple_term (et2, v1)) != NO_ERROR)
	return er;

      if (et == MINUS)
	*v1 = -*v1;
    }
  else
    if ((er = simple_term (et, v1)) != NO_ERROR)
      return er;

  return NO_ERROR;
}

static eval_error
simple_term (eval_token et, eval_t *v1)
{
  eval_t v2;
  eval_error er;

  switch (et)
    {
    case LEFTP:
      et = eval_lex (v1);
      if (et == ERROR)
	return UNKNOWN_INPUT;

      if ((er = logical_or_term (et, v1)) != NO_ERROR)
	return er;

      et = eval_lex (&v2);
      if (et == ERROR)
	return UNKNOWN_INPUT;

      if (et != RIGHTP)
	return MISSING_RIGHT;

      break;

    case NUMBER:
      break;

    default:
      return SYNTAX_ERROR;
    }

  return NO_ERROR;
}

/*
compiler used by builtin macro 'eval' of Parrot m4

$ make -C examples/compilers/

*/

#include "parrot/parrot.h"
#include "parrot/embed.h"

void* m4_eval_compiler(Parrot_Interp interpreter, const char *s);

/*
 * loadlib calls the load and init hooks
 * we use init to register the compiler
 */

void
Parrot_lib_m4_eval_compiler_init(Parrot_Interp interpreter, PMC* lib)
{
    STRING *cmp;

    cmp = const_string(interpreter, "m4_eval_compiler");
    Parrot_compreg(interpreter, cmp, (PMC*)F2DPTR(m4_eval_compiler));
}

/*
 * some code almost duplicated from imcc/pbc.c
 * XXX should make some public util functions
 */
static struct PackFile_Segment *
create_seg(struct PackFile_Directory *dir, pack_file_types t, const char *name)
{
    struct PackFile_Segment *seg;
    seg = PackFile_Segment_new_seg(dir, t, name, 1);

    return seg;
}

static struct PackFile *
create_pf_segs(Parrot_Interp interpreter)
{
    struct PackFile *pf = PackFile_new(0);
    struct PackFile_Segment *seg;
    struct PackFile_ByteCode *cur_cs;

    seg = create_seg(&pf->directory, PF_BYTEC_SEG, "JaPHc_bc");
    cur_cs = pf->cur_cs = (struct PackFile_ByteCode*)seg;

    seg = create_seg(&pf->directory, PF_CONST_SEG, "JaPHc_const");
    cur_cs->consts = pf->const_table = (struct PackFile_ConstTable*) seg;
    cur_cs->consts->code = cur_cs;

    return pf;
}

static int
unescape(char *string)
{
    char *start, *p;

    for (start = p = string ; *string; string++) {
        if (*string == '\\' && string[1]) {
            switch (*++string) {
                case 'n':
                    *p++ = '\n';
                    break;
                default:
                    *p++ = *string;
                    break;
            }
        }
        else
            *p++ = *string;
    }
    *p = 0;
    return p - start;
}

/* add constant string to constant_table */
static int
add_const_str(Parrot_Interp interpreter,
	struct PackFile_ConstTable *consts, const char *str)
{
    int k, l;
    char *o;
    char *buf = o = strdup(str);

    /*
     * TODO strip delimiters in lexer, this needs adjustment in printint strings
     */
    if (*buf == '"') {
        buf++;
        l = unescape(buf);
        if (l)
        buf[--l] = '\0';
    }
    else if (*buf == '\'') {
        buf++;
        l = strlen(buf);
        if (l)
            buf[--l] = '\0';
    }
    else {
        l = unescape(buf);
    }

    /* Update the constant count and reallocate */
    k = ++consts->const_count;
    consts->constants = mem_sys_realloc(consts->constants,
            k * sizeof(struct PackFile_Constant *));

    /* Allocate a new constant */
    consts->constants[--k] = PackFile_Constant_new();
    consts->constants[k]->type = PFC_STRING;
    consts->constants[k]->u.string =
        string_make(interpreter, buf, (UINTVAL) l, "iso-8859-1", 0 );
    free(o);
    return k;
}

/*
 * simple compiler - no error checking
 */
void*
m4_eval_compiler( Parrot_Interp interpreter, const char *program )
{
    eval_t value;

    struct PackFile *pf;
    struct PackFile_ByteCode *cur_cs;
    struct PackFile_ConstTable *consts;
    opcode_t* pc;


    evaluate( program, &value );

    /*
     * need some packfile segments
     */
    pf = create_pf_segs(interpreter);
    cur_cs = pf->cur_cs;
    /*
     * alloc byte code mem
     */
    cur_cs->base.data = mem_sys_allocate(CODE_SIZE * sizeof(opcode_t));
    cur_cs->base.size = CODE_SIZE;
    consts = cur_cs->consts;
    /*
     * now start compiling
     */
    pc = cur_cs->base.data;
    /* *pc++ = interpreter->op_lib->op_code("print_sc", 1); */
    /* *pc++ = add_const_str(interpreter, consts, "asdfasdf" ); */
    *pc++ = interpreter->op_lib->op_code("set_p_ic", 1);
    *pc++ = 16;
    *pc++ = value;
    /* *pc++ = add_const_str(interpreter, consts, program ); */
    /* *pc++ = interpreter->op_lib->op_code("invoke_p", 1); */
    /* *pc++ = 1; */

    return pf;
}
