/*
 * ex: set ro:
 * DO NOT EDIT THIS FILE
 * Generated by Parrot::Configure::Compiler from config/gen/libjit/frame_builder_libjit_c.in
 */

/*
Copyright (C) 2008-2009, Parrot Foundation.
$Id$
*/

/* HEADERIZER HFILE: none */
/* HEADERIZER STOP */

#include "parrot/parrot.h"
#include "pmc/pmc_integer.h"
#include "pmc/pmc_unmanagedstruct.h"
#include "pmc/pmc_managedstruct.h"
#include "frame_builder.h"
#include "frame_builder_libjit.h"

#ifdef PARROT_HAS_LIBJIT

/*

=over 4

=item C<void *Parrot_jit_build_call_func(PARROT_INTERP, PMC *nci, STRING *sig, void **priv)>

Public interface to NCI function interface builder.

=cut

*/

void *
Parrot_jit_build_call_func(PARROT_INTERP, PMC *pmc, STRING *sig, void **priv) {
    void *thunk;
    char *sig_cstr;

    sig_cstr = Parrot_str_to_cstring(interp, sig);
    *priv    = mem_sys_allocate(sizeof (struct jit_buffer_private_data));

    thunk    = Parrot_jit_create_thunk(interp, sig_cstr, *priv);

    Parrot_str_free_cstring(sig_cstr);

    return thunk;
}

/*

=item C<void Parrot_jit_free_buffer(PARROT_INTERP, void *ptr, void *priv)>

This is a callback to implement the proper freeing semantics.  It is called by
the ManagedStruct PMC as it is garbage collected.

=cut

*/

void
Parrot_jit_free_buffer(PARROT_INTERP, void *ptr, void *priv)
{
    struct jit_buffer_private_data *jit = (struct jit_buffer_private_data*)priv;
    jit_context_destroy(jit->ctx);
    mem_sys_free(jit->sig);
    mem_sys_free(priv);
}

/*

=item C<PMC *Parrot_jit_clone_buffer(PARROT_INTERP, PMC *pmc, void *priv)>

This is a callback to implement the proper cloning semantics for jit buffers.
It is called by the ManagedStruct PMC's clone() function.

=back

=cut

*/

PMC *
Parrot_jit_clone_buffer(PARROT_INTERP, PMC *pmc, void *priv)
{
    PMC * const rv = pmc_new(interp, pmc->vtable->base_type);

    VTABLE_init(interp, rv);
    /* copy the attributes */
    {
        void (*tmpfreefunc)(PARROT_INTERP, void*, void*);
        GETATTR_ManagedStruct_custom_free_func(interp, pmc, tmpfreefunc);
        SETATTR_ManagedStruct_custom_free_func(interp, rv , tmpfreefunc);
    }
    {
        PMC* (*tmpclonefunc)(PARROT_INTERP, PMC*, void*);
        GETATTR_ManagedStruct_custom_clone_func(interp, pmc, tmpclonefunc);
        SETATTR_ManagedStruct_custom_clone_func(interp, rv , tmpclonefunc);
    }

    /* compile a clone of the function */
    if (PARROT_MANAGEDSTRUCT(pmc)->ptr) {
        void *rv_priv;
        struct jit_buffer_private_data *jit = (struct jit_buffer_private_data*)priv;
        STRING *sig                         = Parrot_str_new(interp, jit->sig, 0);
        PARROT_MANAGEDSTRUCT(rv)->ptr       = Parrot_jit_build_call_func(interp, rv, sig, &rv_priv);
    }

    return rv;
}

/*
 * JIT functions
 */

void *
Parrot_jit_create_thunk(PARROT_INTERP, char *sig, void *priv) {
    struct jit_buffer_private_data *p;
    jit_function_t f;
    jit_value_t jit_interp, jit_func;
    jit_type_t *jit_args_t;
    jit_value_t *jit_args_v, *jit_regs;

    /* populate private data */
    p      = (struct jit_buffer_private_data*)priv;
    p->ctx = jit_context_create();
    p->sig = mem_sys_strdup(sig);

    /* start compiling */
    jit_context_build_start(p->ctx);

    /* start JIT function */
    {
        jit_type_t arg_types[] = {
            jit_type_void_ptr,  /* interp */
            jit_type_void_ptr   /* nci_info */
        };
        jit_type_t f_sig = jit_type_create_signature(jit_abi_cdecl, jit_type_void, arg_types, 2, 1);
        f                = jit_function_create(p->ctx, f_sig);
    }

    /* get the incomming args */
    jit_interp = jit_value_get_param(f, 0);
    jit_func   = jit__vtable_get_pointer(f, jit_interp, jit_value_get_param(f, 1));

    /* get the outgoing args */
    {
        jit_value_t st;
        int nargs;

        {
            jit_value_t sizeof_call_state
                = jit_value_create_nint_constant(f, jit_type_sys_int, sizeof (call_state));
            st  = jit_insn_alloca(f, sizeof_call_state);
        }

        nargs = Parrot_jit_parse_sig_args_pre(interp, sig, f, jit_interp, st,
                                              &jit_args_t, &jit_args_v, &jit_regs);

        /* get the return type */
        {
            jit_type_t ret_t;
            jit_value_t ret_v;

            ret_t = Parrot_jit_parse_sig_ret_pre(interp, sig);

            /* make the call */
            {
                jit_type_t jit_sig
                          = jit_type_create_signature(jit_abi_cdecl, ret_t, jit_args_t, nargs, 1);
                ret_v     = jit_insn_call_indirect(f, jit_func, jit_sig, jit_args_v, nargs, 0);
            }

            /* get the incomming return */
            Parrot_jit_parse_sig_ret_post(interp, sig, f, jit_interp, st, ret_v);
        }

        /* clean up args */
        Parrot_jit_parse_sig_args_post(interp, sig, nargs, f, jit_interp, jit_args_v, jit_regs);
    }

    /* end JIT function */
    jit_insn_return(f, NULL);

    /* compile to native callable func poitner */
    jit_function_compile(f);
    jit_context_build_end(p->ctx);

    mem_sys_free(jit_args_t);
    mem_sys_free(jit_args_v);
    mem_sys_free(jit_regs);

    return jit_function_to_closure(f);
}

int
Parrot_jit_parse_sig_args_pre(PARROT_INTERP, char *sig, jit_function_t f,
                              jit_value_t jinterp, jit_value_t st,
                              jit_type_t **arg_types,
                              jit_value_t **arg_vals, jit_value_t **arg_regs) {
    int nargs, nregs, i, j;

    sig += 1; /* ignore return character */

    nargs = strlen(sig);
    nregs = Parrot_jit_init_pcc(sig, nargs, f, jinterp, st);

    *arg_types = (jit_type_t *)mem_sys_allocate(nargs * sizeof (jit_type_t));
    *arg_vals  = (jit_value_t *)mem_sys_allocate(nargs * sizeof (jit_value_t));
    *arg_regs  = (jit_value_t *)mem_sys_allocate(nregs * sizeof (jit_value_t));

    for (i = 0, j = 0; i < nargs; i++) {
        char c;
        jit_type_t t1;
        jit_value_t v1, v2, v3, v4;
        switch (c = sig[i]) {
          case 'I':
            t1 = JIT_TYPE_INTVAL;
          read_int_reg:
            (*arg_types)[i]  = t1;
            v1               = jit_value_create_nint_constant(f, jit_type_sys_int, j);
            v2               = jit__get_nci_I(f, jinterp, st, v1);
            (*arg_regs)[j++] = (*arg_vals)[i] = v2;
            break;
          case 'c':
            t1 = jit_type_sys_char;
            goto read_int_reg;
          case 's':
            t1 = jit_type_sys_short;
            goto read_int_reg;
          case 'i':
            t1 = jit_type_sys_int;
            goto read_int_reg;
          case 'l':
            t1 = jit_type_sys_long;
            goto read_int_reg;

          case 'N':
            t1 = JIT_TYPE_FLOATVAL;
          read_float_reg:
            (*arg_types)[i]  = t1;
            v1               = jit_value_create_nint_constant(f, jit_type_sys_int, j);
            v2               = jit__get_nci_N(f, jinterp, st, v1);
            (*arg_regs)[j++] = (*arg_vals)[i] = v2;
            break;
          case 'f':
            t1 = jit_type_sys_float;
            goto read_float_reg;
          case 'd':
            t1 = jit_type_sys_double;
            goto read_float_reg;

          case 'S':
            (*arg_types)[i]  = jit_type_void_ptr;
            v1               = jit_value_create_nint_constant(f, jit_type_sys_int, j);
            v2               = jit__get_nci_S(f, jinterp, st, v1);
            (*arg_regs)[j++] = (*arg_vals)[i] = v2;
            break;

          case 't':
            (*arg_types)[i]  = jit_type_void_ptr;
            v1               = jit_value_create_nint_constant(f, jit_type_sys_int, j);
            v2               = jit__get_nci_S(f, jinterp, st, v1);
            (*arg_regs)[j++] = v2;
            (*arg_vals)[i]   = jit__Parrot_str_to_cstring(f, jinterp, v2);
            break;

          case 'b':
            (*arg_types)[i]  = jit_type_void_ptr;
            v1               = jit_value_create_nint_constant(f, jit_type_sys_int, j);
            v2               = jit__get_nci_S(f, jinterp, st, v1);
            (*arg_regs)[j++] = v2;
            (*arg_vals)[i]   = jit__Buffer_bufstart(f, v2);
            break;
          case 'B':
            (*arg_types)[i]  = jit_type_void_ptr;
            v1               = jit_value_create_nint_constant(f, jit_type_sys_int, j);
            v2               = jit__get_nci_S(f, jinterp, st, v1);
            (*arg_regs)[j++] = v2;
            v3               = jit__Parrot_str_to_cstring(f, jinterp, v2);
            jit_value_set_addressable(v3);
            (*arg_vals)[i]   = jit_insn_address_of(f, v3);
            break;

          case 'p':
            (*arg_types)[i]  = jit_type_void_ptr;
            v1               = jit_value_create_nint_constant(f, jit_type_sys_int, j);
            v2               = jit__get_nci_p(f, jinterp, st, v1);
            (*arg_regs)[j++] = (*arg_vals)[i] = v2;
            break;
          case 'P':
          case 'O':
          case '@':
            (*arg_types)[i]  = jit_type_void_ptr;
            v1               = jit_value_create_nint_constant(f, jit_type_sys_int, j);
            v2               = jit__get_nci_P(f, jinterp, st, v1);
            (*arg_regs)[j++] = (*arg_vals)[i] = v2;
            break;
          case '2':
            t1 = jit_type_sys_short;
            goto call_get_integer;
          case '3':
            t1 = jit_type_sys_int;
            goto call_get_integer;
          case '4':
            t1 = jit_type_sys_long;
          call_get_integer:
            (*arg_types)[i]  = jit_type_void_ptr;
            v1               = jit_value_create_nint_constant(f, jit_type_sys_int, j);
            v2               = jit__get_nci_P(f, jinterp, st, v1);
            (*arg_regs)[j++] = v2;
            v3               = jit__vtable_get_integer(f, jinterp, v2);
            v4               = jit_value_create(f, t1);
            jit_value_set_addressable(v4);
            jit_insn_store(f, v4, v3);
            (*arg_vals)[i]   = jit_insn_address_of(f, v4);
            break;

          case 'V':
            (*arg_types)[i]  = jit_type_void_ptr;
            v1               = jit_value_create_nint_constant(f, jit_type_sys_int, j);
            v2               = jit__get_nci_P(f, jinterp, st, v1);
            (*arg_regs)[j++] = v2;
            v3               = jit__vtable_get_pointer(f, jinterp, v2);
            v4               = jit_value_create(f, jit_type_void_ptr);
            jit_value_set_addressable(v4);
            jit_insn_store(f, v4, v3);
            (*arg_vals)[i]   = jit_insn_address_of(f, v4);
            break;

          case '0':
            (*arg_types)[i] = jit_type_void_ptr;
            (*arg_vals)[i]  = jit_value_create_nint_constant(f, jit_type_void_ptr, (jit_nint)NULL);
            break;

          case 'J':
            (*arg_types)[i] = jit_type_void_ptr;
            (*arg_vals)[i]  = jinterp;
            break;

          case 'U':
            /* TODO */
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_JIT_ERROR,
                "arg type 'U' not yet implemented");
            return -1;

          default:
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_JIT_ERROR,
                "unkown arg type '%c'", c);
            return -1;
        }
    }

    return nargs;
}

int
Parrot_jit_init_pcc(char *sig, int nargs, jit_function_t f, jit_value_t interp, jit_value_t st) {
    int i, j;
    char pcc_sig[nargs];

    for (i = 0, j = 0; i < nargs; i++) {
        switch (sig[i]) {
          case 'I':
          case 'c':
          case 's':
          case 'i':
          case 'l':
            pcc_sig[j++] = 'I';
            break;

          case 'N':
          case 'f':
          case 'd':
            pcc_sig[j++] = 'N';
            break;

          case 'S':
          case 't':
          case 'b':
          case 'B':
            pcc_sig[j++] = 'S';
            break;

          case 'p':
          case 'P':
          case 'O':
          case 'V':
          case '2':
          case '3':
          case '4':
            pcc_sig[j++] = 'P';
            break;

          case '@':
            pcc_sig[j++] = '@';
            break;

          default:
            break;
        }
    }
    pcc_sig[j]  = '\0';

    jit__Parrot_init_arg_nci(f, interp, st,
                             jit_value_create_string_constant(f, pcc_sig, j+1));

    return j;
}

jit_type_t
Parrot_jit_parse_sig_ret_pre(PARROT_INTERP, char *sig) {
    char c;
    switch (c = sig[0]) {
      case 'v':
        return jit_type_void;

      case 'I':
        return JIT_TYPE_INTVAL;
      case 'c':
        return jit_type_sys_char;
      case 's':
        return jit_type_sys_short;
      case 'i':
        return jit_type_sys_int;
      case 'l':
        return jit_type_sys_long;

      case 'N':
        return JIT_TYPE_FLOATVAL;
      case 'f':
        return jit_type_sys_float;
      case 'd':
        return jit_type_sys_double;

      case 'S':
      case 't':
        return jit_type_void_ptr;

      case 'p':
      case 'P':
        return jit_type_void_ptr;

      case 'U':
        /* TODO */
        Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_JIT_ERROR,
                                    "return type 'U' not yet implemented");
        return NULL;
      default:
        /* FAIL */
        Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_JIT_ERROR,
                                    "unknown return type '%c'", c);
        return NULL;
    }
}

void
Parrot_jit_parse_sig_ret_post(PARROT_INTERP, char *sig,
                              jit_function_t f, jit_value_t jinterp, jit_value_t st,
                              jit_value_t retval) {
    jit_type_t t1;
    jit_value_t v1, v2, v3;
    switch (sig[0]) {
      case 'v':
        break;

      case 'I':
      case 'c':
      case 's':
      case 'i':
      case 'l':
        jit__set_nci_I(f, jinterp, st, retval);
        break;

      case 'N':
      case 'f':
      case 'd':
        jit__set_nci_N(f, jinterp, st, retval);
        break;

      case 'S':
        jit__set_nci_S(f, jinterp, st, retval);
        break;
      case 't':
        v1 = jit_value_create_nint_constant(f, jit_type_sys_int, 0);
        v2 = jit__Parrot_str_new(f, jinterp, retval, v1);
        jit__set_nci_S(f, jinterp, st, v2);
        break;

      case 'P':
        jit__set_nci_P(f, jinterp, st, retval);
        break;
      case 'p':
        v1 = jit_value_create_intval_constant(f, enum_class_UnManagedStruct);
        v2 = jit__pmc_new_noinit(f, jinterp, v1);
        jit__vtable_set_pointer(f, jinterp, v2, retval);
        jit__set_nci_P(f, jinterp, st, v2);
        break;
      case '2':
        t1 = jit_type_sys_short;
        goto create_int_pmc;
      case '3':
        t1 = jit_type_sys_int;
        goto create_int_pmc;
      case '4':
        t1 = jit_type_sys_long;
      create_int_pmc:
        v1 = jit_insn_load_relative(f, retval, 0, t1);
        v2 = jit_value_create_intval_constant(f, enum_class_Integer);
        v3 = jit__pmc_new_noinit(f, jinterp, v2);
        jit__vtable_set_integer_native(f, jinterp, v3, v1);
        jit__set_nci_P(f, jinterp, st, v3);
        break;

      case 'U':
        /* ignore (failed elsewhere) */
        break;

      default:
        /* ignore (failed elsewhere) */
        break;
    }
}

void
Parrot_jit_parse_sig_args_post(PARROT_INTERP, char *sig, int nargs,
                               jit_function_t f, jit_value_t jinterp,
                               jit_value_t *args, jit_value_t *regs) {
    int i, j;

    sig += 1;

    for (i = 0, j = 0; i < nargs; i++) {
        jit_type_t t1;
        jit_value_t v1;
        switch (sig[i]) {
          case 't':
            jit__Parrot_str_free_cstring(f, args[i]);
            j++;
            break;

          case 'B':
            v1 = jit_insn_load_relative(f, args[i], 0, jit_type_void_ptr);
            jit__Parrot_str_free_cstring(f, v1);
            j++;
            break;

          case '2':
            t1 = jit_type_sys_short;
            goto set_integer;
          case '3':
            t1 = jit_type_sys_int;
            goto set_integer;
          case '4':
            t1 = jit_type_sys_long;
          set_integer:
            v1 = jit_insn_load_relative(f, args[i], 0, t1);
            jit__vtable_set_integer_native(f, jinterp, regs[j], v1);
            j++;
            break;

          case 'V':
            v1 = jit_insn_load_relative(f, args[i], 0, jit_type_void_ptr);
            jit__vtable_set_pointer(f, jinterp, regs[j], v1);
            j++;
            break;

          case 'I':
          case 'c':
          case 'i':
          case 'l':
          case 'N':
          case 'f':
          case 'd':
          case 'S':
          case 'b':
          case 'p':
          case 'P':
          case 'O':
          case '@':
            j++;
            break;

          case 'U':
            /* TODO */
            break;
          default:
            /* ignore */
            break;
        }
    }
}

jit_value_t
jit_value_create_intval_constant(jit_function_t f, INTVAL i) {
    return jit_value_create_nint_constant(f, JIT_TYPE_INTVAL, i);
}

jit_value_t
jit_value_create_string_constant(jit_function_t f, char *str, int len) {
    jit_value_t jit_len, jit_str;
    int i;

    if (len < 1) {
        len = strlen(str);
    }

    jit_len = jit_value_create_nint_constant(f, jit_type_sys_int, len);
    jit_str = jit_insn_alloca(f, jit_len);

    for (i = 0; i < len; i++) {
        jit_value_t c = jit_value_create_nint_constant(f, jit_type_sys_char, str[i]);
        jit_insn_store_relative(f, jit_str, i, c);
    }

    return jit_str;
}

/*
 * JIT wrappers
 */

/* custom wrappers */
jit_value_t
jit__Buffer_bufstart(jit_function_t f, jit_value_t buf) {
    return jit_insn_load_relative(f, buf, offsetof(Buffer, _bufstart), jit_type_void_ptr);
}

/* vtable wrappers */
jit_value_t
jit__vtable_get_pointer(jit_function_t f, jit_value_t interp, jit_value_t self ) {
    jit_type_t sig;
    jit_value_t vtable, method;
    jit_type_t  arg_t[] = { jit_type_void_ptr, jit_type_void_ptr  };
    jit_value_t arg_v[] = { interp, self  };

    sig = jit_type_create_signature(jit_abi_cdecl, jit_type_void_ptr, arg_t, 0 + 2, 1);

    vtable = jit_insn_load_relative(f, self,   offsetof(PMC, vtable),         jit_type_void_ptr);
    method = jit_insn_load_relative(f, vtable, offsetof(VTABLE, get_pointer), jit_type_void_ptr);

    return jit_insn_call_indirect(f, method, sig, arg_v, 0 + 2, 0);
}

jit_value_t
jit__vtable_set_pointer(jit_function_t f, jit_value_t interp, jit_value_t self , jit_value_t v1) {
    jit_type_t sig;
    jit_value_t vtable, method;
    jit_type_t  arg_t[] = { jit_type_void_ptr, jit_type_void_ptr , jit_type_void_ptr };
    jit_value_t arg_v[] = { interp, self , v1 };

    sig = jit_type_create_signature(jit_abi_cdecl, jit_type_void, arg_t, 1 + 2, 1);

    vtable = jit_insn_load_relative(f, self,   offsetof(PMC, vtable),         jit_type_void_ptr);
    method = jit_insn_load_relative(f, vtable, offsetof(VTABLE, set_pointer), jit_type_void_ptr);

    return jit_insn_call_indirect(f, method, sig, arg_v, 1 + 2, 0);
}

jit_value_t
jit__vtable_set_integer_native(jit_function_t f, jit_value_t interp, jit_value_t self , jit_value_t v1) {
    jit_type_t sig;
    jit_value_t vtable, method;
    jit_type_t  arg_t[] = { jit_type_void_ptr, jit_type_void_ptr , JIT_TYPE_INTVAL };
    jit_value_t arg_v[] = { interp, self , v1 };

    sig = jit_type_create_signature(jit_abi_cdecl, jit_type_void, arg_t, 1 + 2, 1);

    vtable = jit_insn_load_relative(f, self,   offsetof(PMC, vtable),         jit_type_void_ptr);
    method = jit_insn_load_relative(f, vtable, offsetof(VTABLE, set_integer_native), jit_type_void_ptr);

    return jit_insn_call_indirect(f, method, sig, arg_v, 1 + 2, 0);
}

jit_value_t
jit__vtable_get_integer(jit_function_t f, jit_value_t interp, jit_value_t self ) {
    jit_type_t sig;
    jit_value_t vtable, method;
    jit_type_t  arg_t[] = { jit_type_void_ptr, jit_type_void_ptr  };
    jit_value_t arg_v[] = { interp, self  };

    sig = jit_type_create_signature(jit_abi_cdecl, JIT_TYPE_INTVAL, arg_t, 0 + 2, 1);

    vtable = jit_insn_load_relative(f, self,   offsetof(PMC, vtable),         jit_type_void_ptr);
    method = jit_insn_load_relative(f, vtable, offsetof(VTABLE, get_integer), jit_type_void_ptr);

    return jit_insn_call_indirect(f, method, sig, arg_v, 0 + 2, 0);
}


/* function wrappers */
jit_value_t
jit__Parrot_str_free_cstring(jit_function_t f, jit_value_t v1) {
    jit_type_t sig;
    jit_type_t  arg_t[] = { jit_type_void_ptr };
    jit_value_t arg_v[] = { v1 };

    sig = jit_type_create_signature(jit_abi_cdecl, jit_type_void, arg_t, 1, 1);

    return jit_insn_call_native(f, "Parrot_str_free_cstring", (void *)&Parrot_str_free_cstring, sig, arg_v, 1, 0);
}

jit_value_t
jit__get_nci_N(jit_function_t f, jit_value_t v1, jit_value_t v2, jit_value_t v3) {
    jit_type_t sig;
    jit_type_t  arg_t[] = { jit_type_void_ptr, jit_type_void_ptr, jit_type_sys_int };
    jit_value_t arg_v[] = { v1, v2, v3 };

    sig = jit_type_create_signature(jit_abi_cdecl, JIT_TYPE_FLOATVAL, arg_t, 3, 1);

    return jit_insn_call_native(f, "get_nci_N", (void *)&get_nci_N, sig, arg_v, 3, 0);
}

jit_value_t
jit__Parrot_str_to_cstring(jit_function_t f, jit_value_t v1, jit_value_t v2) {
    jit_type_t sig;
    jit_type_t  arg_t[] = { jit_type_void_ptr, jit_type_void_ptr };
    jit_value_t arg_v[] = { v1, v2 };

    sig = jit_type_create_signature(jit_abi_cdecl, jit_type_void_ptr, arg_t, 2, 1);

    return jit_insn_call_native(f, "Parrot_str_to_cstring", (void *)&Parrot_str_to_cstring, sig, arg_v, 2, 0);
}

jit_value_t
jit__get_nci_S(jit_function_t f, jit_value_t v1, jit_value_t v2, jit_value_t v3) {
    jit_type_t sig;
    jit_type_t  arg_t[] = { jit_type_void_ptr, jit_type_void_ptr, jit_type_sys_int };
    jit_value_t arg_v[] = { v1, v2, v3 };

    sig = jit_type_create_signature(jit_abi_cdecl, jit_type_void_ptr, arg_t, 3, 1);

    return jit_insn_call_native(f, "get_nci_S", (void *)&get_nci_S, sig, arg_v, 3, 0);
}

jit_value_t
jit__set_nci_S(jit_function_t f, jit_value_t v1, jit_value_t v2, jit_value_t v3) {
    jit_type_t sig;
    jit_type_t  arg_t[] = { jit_type_void_ptr, jit_type_void_ptr, jit_type_void_ptr };
    jit_value_t arg_v[] = { v1, v2, v3 };

    sig = jit_type_create_signature(jit_abi_cdecl, jit_type_void, arg_t, 3, 1);

    return jit_insn_call_native(f, "set_nci_S", (void *)&set_nci_S, sig, arg_v, 3, 0);
}

jit_value_t
jit__set_nci_N(jit_function_t f, jit_value_t v1, jit_value_t v2, jit_value_t v3) {
    jit_type_t sig;
    jit_type_t  arg_t[] = { jit_type_void_ptr, jit_type_void_ptr, JIT_TYPE_FLOATVAL };
    jit_value_t arg_v[] = { v1, v2, v3 };

    sig = jit_type_create_signature(jit_abi_cdecl, jit_type_void, arg_t, 3, 1);

    return jit_insn_call_native(f, "set_nci_N", (void *)&set_nci_N, sig, arg_v, 3, 0);
}

jit_value_t
jit__Parrot_init_arg_nci(jit_function_t f, jit_value_t v1, jit_value_t v2, jit_value_t v3) {
    jit_type_t sig;
    jit_type_t  arg_t[] = { jit_type_void_ptr, jit_type_void_ptr, jit_type_void_ptr };
    jit_value_t arg_v[] = { v1, v2, v3 };

    sig = jit_type_create_signature(jit_abi_cdecl, jit_type_void_ptr, arg_t, 3, 1);

    return jit_insn_call_native(f, "Parrot_init_arg_nci", (void *)&Parrot_init_arg_nci, sig, arg_v, 3, 0);
}

jit_value_t
jit__get_nci_I(jit_function_t f, jit_value_t v1, jit_value_t v2, jit_value_t v3) {
    jit_type_t sig;
    jit_type_t  arg_t[] = { jit_type_void_ptr, jit_type_void_ptr, jit_type_sys_int };
    jit_value_t arg_v[] = { v1, v2, v3 };

    sig = jit_type_create_signature(jit_abi_cdecl, JIT_TYPE_INTVAL, arg_t, 3, 1);

    return jit_insn_call_native(f, "get_nci_I", (void *)&get_nci_I, sig, arg_v, 3, 0);
}

jit_value_t
jit__set_nci_I(jit_function_t f, jit_value_t v1, jit_value_t v2, jit_value_t v3) {
    jit_type_t sig;
    jit_type_t  arg_t[] = { jit_type_void_ptr, jit_type_void_ptr, JIT_TYPE_INTVAL };
    jit_value_t arg_v[] = { v1, v2, v3 };

    sig = jit_type_create_signature(jit_abi_cdecl, jit_type_void, arg_t, 3, 1);

    return jit_insn_call_native(f, "set_nci_I", (void *)&set_nci_I, sig, arg_v, 3, 0);
}

jit_value_t
jit__Parrot_str_new(jit_function_t f, jit_value_t v1, jit_value_t v2, jit_value_t v3) {
    jit_type_t sig;
    jit_type_t  arg_t[] = { jit_type_void_ptr, jit_type_void_ptr, JIT_TYPE_UINTVAL };
    jit_value_t arg_v[] = { v1, v2, v3 };

    sig = jit_type_create_signature(jit_abi_cdecl, jit_type_void_ptr, arg_t, 3, 1);

    return jit_insn_call_native(f, "Parrot_str_new", (void *)&Parrot_str_new, sig, arg_v, 3, 0);
}

jit_value_t
jit__set_nci_P(jit_function_t f, jit_value_t v1, jit_value_t v2, jit_value_t v3) {
    jit_type_t sig;
    jit_type_t  arg_t[] = { jit_type_void_ptr, jit_type_void_ptr, jit_type_void_ptr };
    jit_value_t arg_v[] = { v1, v2, v3 };

    sig = jit_type_create_signature(jit_abi_cdecl, jit_type_void, arg_t, 3, 1);

    return jit_insn_call_native(f, "set_nci_P", (void *)&set_nci_P, sig, arg_v, 3, 0);
}

jit_value_t
jit__get_nci_p(jit_function_t f, jit_value_t v1, jit_value_t v2, jit_value_t v3) {
    jit_type_t sig;
    jit_type_t  arg_t[] = { jit_type_void_ptr, jit_type_void_ptr, jit_type_sys_int };
    jit_value_t arg_v[] = { v1, v2, v3 };

    sig = jit_type_create_signature(jit_abi_cdecl, jit_type_void_ptr, arg_t, 3, 1);

    return jit_insn_call_native(f, "get_nci_p", (void *)&get_nci_p, sig, arg_v, 3, 0);
}

jit_value_t
jit__get_nci_P(jit_function_t f, jit_value_t v1, jit_value_t v2, jit_value_t v3) {
    jit_type_t sig;
    jit_type_t  arg_t[] = { jit_type_void_ptr, jit_type_void_ptr, jit_type_sys_int };
    jit_value_t arg_v[] = { v1, v2, v3 };

    sig = jit_type_create_signature(jit_abi_cdecl, jit_type_void_ptr, arg_t, 3, 1);

    return jit_insn_call_native(f, "get_nci_P", (void *)&get_nci_P, sig, arg_v, 3, 0);
}

jit_value_t
jit__pmc_new_noinit(jit_function_t f, jit_value_t v1, jit_value_t v2) {
    jit_type_t sig;
    jit_type_t  arg_t[] = { jit_type_void_ptr, JIT_TYPE_INTVAL };
    jit_value_t arg_v[] = { v1, v2 };

    sig = jit_type_create_signature(jit_abi_cdecl, jit_type_void_ptr, arg_t, 2, 1);

    return jit_insn_call_native(f, "pmc_new_noinit", (void *)&pmc_new_noinit, sig, arg_v, 2, 0);
}


#endif /* PARROT_HAS_LIBJIT */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
