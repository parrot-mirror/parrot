/*
Copyright: 2006 The Perl Foundation.  All Rights Reserved.
$Id$

=head1 NAME

src/nci_ffcall.c - NCI Implementation using ffcall

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Functions

=over 4

=cut

*/

#include <avcall.h>
#include <callback.h>

#include "parrot/parrot.h"
#include "parrot/method_util.h"
#include "parrot/oplib/ops.h"

#include "parrot/nci.h"
#include "nci_ffcall.str"

#if defined(HAS_JIT) && defined(I386)
#  include "parrot/exec.h"
#  include "parrot/jit.h"
/*#  define CAN_BUILD_CALL_FRAMES*/
#endif

/* Structure used for storing arguments and return values */

typedef union UnionArg
{
    char   _char;
    int    _int;
    short  _short;
    long   _long;

    float  _float;
    double _double;

    int    *_int_p;
    long   *_long_p;
    short  *_short_p;

    float  *_float_p;
    double *_double_p;

    char   *_string;

    void   *_pointer;
} UnionArg;


/* The NCI data structure which stores the NCI and parrot signatures
   as well as arguments and return value */

typedef struct NCIArgs
{
    Parrot_csub_t func;

    char *signature;
    char *signature_parrot;

    UnionArg result;
    UnionArg args[10];

} NCIArgs;


/* =========== Main NCI call code =========== */


static void nci_ffcall_invoke (Interp * interpreter, PMC *function);

static void
nci_ffcall_new (Interp *interpreter, PMC *pmc,
                 STRING *signature, Parrot_csub_t func)
{
    NCIArgs* nci_args = (NCIArgs *) mem_sys_allocate (sizeof (NCIArgs));

    nci_args->func = func;
    nci_args->signature = string_to_cstring (interpreter, signature);
    nci_args->signature_parrot= Parrot_convert_signature (nci_args->signature);

    PMC_data(pmc) = nci_args;

    PMC_struct_val(pmc) = nci_ffcall_invoke;
}

static void nci_ffcall_clone (Interp * interpreter, PMC* pmc1, PMC* pmc2)
{
     NCIArgs* nci_args = PMC_data(pmc2);

     /* XXX: Fix signature passed */
     nci_ffcall_new (interpreter, pmc1,
		     0,
		     nci_args->func);
}


static void nci_ffcall_free (Interp *interpreter, PMC *pmc)
{
#if 0
  NCIArgs* nci_args = args;
  
  if (nci_args)
    {
      mem_sys_free (nci_args->signature);
      mem_sys_free (nci_args->signature_parrot);

      mem_sys_free (nci_args);
    }
#endif
}


static void nci_ffcall_invoke (Interp *interpreter, PMC * pmc)
{
    PMC *temp;
    unsigned int i, length;
    struct call_state st;
    char *signature;
    __VA_function pointer;

    av_alist alist;

    NCIArgs* nci_args = (NCIArgs *) PMC_data(pmc);

    signature = nci_args->signature;
    pointer = (__VA_function) nci_args->func;

    /* Set up return type for function */
    switch (signature[0])
        {

        case 'p':
        case 'P':
            av_start_ptr (alist, pointer, void *, &nci_args->result._pointer);
            break;

        case 'c':
            av_start_char (alist, pointer, &nci_args->result._char);
            break;

        case 's':
            av_start_short (alist, pointer, &nci_args->result._short);
            break;

        case 'i':
            av_start_int (alist, pointer, &nci_args->result._int);
            break;

        case 'l':
            av_start_long (alist, pointer, &nci_args->result._long);
            break;

        case 'f':
            av_start_float (alist, pointer, &nci_args->result._float);
            break;

        case 'd':
            av_start_double (alist, pointer, &nci_args->result._double);
            break;

        case 't':
            av_start_ptr (alist, pointer, char *, &nci_args->result._string);
            break;

        case '\0':
        case 'v':
            av_start_void (alist, pointer);
            break;

        default:
            PIO_eprintf(interpreter, "Bad nci return type '%c'\n",
                        signature[0]);
            break;
        }

    length = strlen (nci_args->signature);

    Parrot_init_arg_nci(interpreter, &st, nci_args->signature_parrot+1);

    /* Set function input arguments */
    for (i = 0 ; i < length-1 ; i++)
        {
            switch (signature[i+1])
                {
                case 'J':
                    temp = GET_NCI_P (i);
                    av_ptr (alist, void *, interpreter);
                    break;

                case 'p':
                    temp = GET_NCI_P (i);
                    nci_args->args[i]._pointer = PMC_data (temp);
                    av_ptr (alist, void *, nci_args->args[i]._pointer);
                    break;

                case 'P':
                    temp = GET_NCI_P (i);                    
                    nci_args->args[i]._pointer =
                        temp == PMCNULL
                        ? NULL
                        : temp;
                    av_ptr (alist, void *, nci_args->args[i]._pointer);
                    break;

                case 'b':
                    nci_args->args[i]._pointer = PMC_struct_val(GET_NCI_S(i)) ;
                    av_ptr (alist, void *, nci_args->args[i]._pointer);
                    break;

                case 'B':
                    nci_args->args[i]._pointer = &PObj_bufstart(GET_NCI_S(i)) ;
                    av_ptr (alist, void *, nci_args->args[i]._pointer);
                    break;

                case 'c':
                    nci_args->args[i]._char = GET_NCI_I (i) ;
                    av_char (alist, nci_args->args[i]._char);
                    break;

                case 's':
                    nci_args->args[i]._short = GET_NCI_I (i) ;
                    av_short (alist, nci_args->args[i]._short);
                    break;

                case 'i':
                    nci_args->args[i]._int = GET_NCI_I (i) ;
                    av_int (alist, nci_args->args[i]._int);
                    break;

                case 'l':
                    nci_args->args[i]._long = GET_NCI_I (i) ;
                    av_long (alist, nci_args->args[i]._long);
                    break;

                case 'f':
                    nci_args->args[i]._float = GET_NCI_N (i) ;
                    av_float (alist, nci_args->args[i]._float);
                    break;

                case 'd':
                    nci_args->args[i]._double = GET_NCI_N (i) ;
                    av_double (alist, nci_args->args[i]._double);
                    break;

                case 't':
                    nci_args->args[i]._string = 
                        string_to_cstring(interpreter, GET_NCI_S (i));
                    av_ptr (alist, char *, nci_args->args[i]._string);
                    break;

                case '2':
                    temp = GET_NCI_P (i);
                    nci_args->args[i]._short_p = mem_sys_allocate (sizeof (short));
                    *nci_args->args[i]._long_p = PMC_int_val (temp);
                    av_ptr (alist, short *, nci_args->args[i]._short_p);
                    break;

                case '4':
                    temp = GET_NCI_P (i);
                    nci_args->args[i]._long_p = mem_sys_allocate (sizeof (long));
                    *nci_args->args[i]._long_p = PMC_int_val (temp);
                    av_ptr (alist, long *, nci_args->args[i]._long_p);
                    break;

                case '3':
                    temp = GET_NCI_P (i);
                    nci_args->args[i]._int_p = mem_sys_allocate (sizeof (int));
                    *nci_args->args[i]._long_p = PMC_int_val (temp);
                    av_ptr (alist, int *, nci_args->args[i]._int_p);
                    break;

                case 'v':
                    /* 'v' arguments will be rare, and only one allowed */
                    break;

                default:
                    temp = GET_NCI_P (i);
                    PIO_eprintf(interpreter, "Bad nci argument type '%c'\n",
                                signature[i+1]);
                    break;
                }


        }

    /* Make the actual call to C function */
    av_call (alist);

    /* Reinitialise interating arguments */
    Parrot_init_arg_nci(interpreter, &st, nci_args->signature_parrot+1);
  
    /* Write backs to variables and cleanup */
    for (i = 0 ; i < length-1 ; i++)
        {
            switch (signature[i+1])
                {
                case '2':
                    temp = GET_NCI_P (i);
                    PMC_int_val (temp) = *nci_args->args[i]._short_p;
                    mem_sys_free (nci_args->args[i]._short_p);
                    break;


                case '3':
                    temp = GET_NCI_P (i);
                    PMC_int_val (temp) = *nci_args->args[i]._int_p;
                    mem_sys_free (nci_args->args[i]._int_p);
                    break;

                case '4':
                    temp = GET_NCI_P (i);
                    PMC_int_val (temp) = *nci_args->args[i]._long_p;
                    mem_sys_free (nci_args->args[i]._long_p);
                    break;

                case 't':
                    mem_sys_free (nci_args->args[i]._string);
                    break;

                default:
                    /* This is required to synchronise the arguments */
                    temp = GET_NCI_P (i);
                    break;
                }
        }



    /* Retrieve return value from function */
    switch (signature[0])
        {
        case 'p':
        case 'P':
            temp = pmc_new(interpreter, enum_class_UnManagedStruct);
            PMC_data (temp) = nci_args->result._pointer;
            SET_NCI_P (temp);
            break;

        case 'c':
            SET_NCI_I(nci_args->result._char);
            break;

        case 's':
            SET_NCI_I(nci_args->result._short);
            break;

        case 'i':
            SET_NCI_I(nci_args->result._int);
            break;

        case 'l':
            SET_NCI_I(nci_args->result._long);
            break;

        case 'f':
            SET_NCI_N(nci_args->result._float);
            break;

        case 'd':
            SET_NCI_N(nci_args->result._double);
            break;

        case 't':
            {
                STRING *string =
                    string_from_cstring(interpreter,
                                        nci_args->result._string, 0);
                SET_NCI_S (string);
            }
            break;
        }
}



/* =========== Callback code =========== */

/* TODO: Synchronous/Assynchronous */


static void Parrot_callback_trampoline (void *data,
                                        va_alist alist)
{
    PMC *    passed_interp;
    PMC *    signature;
    PMC *    pmc_args[10];
    PMC *    sub;
    PMC *    pmc;
    STRING * sig_str;
    char *   p;
    STRING* sc;
    unsigned int length, i;

    char signature_parrot[10];

    UnionArg arg, return_value;

    Parrot_Interp interpreter = NULL;

    PMC *user_data = (PMC *) data;

    /* Find the correct interpreter */

    LOCK(interpreter_array_mutex);
    for (i = 0; i < n_interpreters; i++) {
        if (interpreter_array[i] == NULL)
            continue;
        interpreter = interpreter_array[i];
        if (interpreter)
            if (contained_in_pool(interpreter,
                        interpreter->arena_base->pmc_pool, user_data))
                break;
    }
    UNLOCK(interpreter_array_mutex);

    if (!interpreter)
        PANIC("interpreter not found for callback");

    sc = CONST_STRING(interpreter, "_interpreter");
    passed_interp = VTABLE_getprop(interpreter, user_data, sc);
    if (PMC_data(passed_interp) != interpreter)
        PANIC("callback gone to wrong interpreter");

    /* Retrieve the values which hangs off the userdata PMC */

    sc = CONST_STRING(interpreter, "_sub");
    sub = VTABLE_getprop(interpreter, user_data, sc);

    sc = CONST_STRING(interpreter, "_signature");
    signature = VTABLE_getprop(interpreter, user_data, sc);

    sig_str = VTABLE_get_string(interpreter, signature);
    p = sig_str->strstart;

    length = strlen (p);

    /* Specify return type */

    switch (p[0])
        {
        case 'p':
            va_start_ptr (alist, void *);
            break;

        case 'c':
            va_start_char (alist);
            break;

        case 's':
            va_start_short (alist);
            break;

        case 'i':
            va_start_int (alist);
            break;

        case 'l':
            va_start_long (alist);
            break;

        case 'f':
            va_start_float (alist);
            break;

        case 'd':
            va_start_double (alist);
            break;

        case 't':
            va_start_ptr (alist, char *);
            break;

        case '\0':
        case 'v':
            va_start_void (alist);
            break;

        default:
            PIO_eprintf(interpreter, "Bad nci callback return type '%c'\n",
                        signature[0]);
            break;
        }


    /* Iterate arguments */

    for (i = 0 ; i < length-1 ; i++)
        {
            switch (p[i+1])
                {
                case 'p':
                    pmc_args[i] =
                        pmc_new(interpreter, enum_class_UnManagedStruct);
                    PMC_data (pmc_args[i]) = va_arg_ptr (alist, void *);
                    break;
                    
                case 'c':
                    pmc_args[i] = pmc_new(interpreter, enum_class_Integer);
                    VTABLE_set_integer_native (interpreter, pmc_args[i],
                                               va_arg_char (alist));
                    break;

                case 's':
                    pmc_args[i] = pmc_new(interpreter, enum_class_Integer);
                    VTABLE_set_integer_native (interpreter, pmc_args[i],
                                               va_arg_short (alist));
                    break;
                    break;

                case 'i':
                    pmc_args[i] = pmc_new(interpreter, enum_class_Integer);
                    VTABLE_set_integer_native (interpreter, pmc_args[i],
                                               va_arg_int (alist));
                    break;

                case 'l':
                    pmc_args[i] = pmc_new(interpreter, enum_class_Integer);
                    VTABLE_set_integer_native (interpreter, pmc_args[i],
                                               va_arg_long (alist));
                    break;

                case 'f':
                    pmc_args[i] = pmc_new(interpreter, enum_class_Float);
                    VTABLE_set_number_native (interpreter, pmc_args[i],
                                              va_arg_float (alist));
                    break;

                case 'd':
                    pmc_args[i] = pmc_new(interpreter, enum_class_Float);
                    VTABLE_set_number_native (interpreter, pmc_args[i],
                                              va_arg_double (alist));
                    break;

                case 't':
                    arg._string = va_arg_ptr (alist, char *);
                    pmc_args[i] = pmc_new(interpreter, enum_class_String);
                    VTABLE_set_string_native (interpreter, pmc_args[i],
                                              string_from_cstring (interpreter,
                                                                   va_arg_ptr (alist,
                                                                               char *),
                                                                   0));

                    break;


                default:
                    PIO_eprintf(interpreter,
                                "Bad nci callback argument type '%c'\n",
                                p[i+1]);
                    break;
                }
        }

    /* Prepare parrot signature */

    for (i = 0 ; i < length ; i++)
        {
          signature_parrot[i] = (p[i] == 'v') ? 'v' : 'P';
        }
    
    /* Make actual call to parrot callback */
    pmc = Parrot_runops_fromc_args (interpreter, sub,
                                    signature_parrot, 
                                    pmc_args[0],
                                    pmc_args[1],
                                    pmc_args[2],
                                    pmc_args[3],
                                    pmc_args[4],
                                    pmc_args[5],
                                    pmc_args[6],
                                    pmc_args[7],
                                    pmc_args[8],
                                    pmc_args[9]);

    /* Retrieve returned value */

    switch (p[0])
        {
        case 'p':
            va_return_ptr (alist, void *, PMC_data (pmc));
            break;

        case 'c':
            va_return_char (alist, VTABLE_get_integer (interpreter, pmc));
            break;

        case 's':
            va_return_short (alist, VTABLE_get_integer (interpreter, pmc));
            break;

        case 'i':
            va_return_int (alist, VTABLE_get_integer (interpreter, pmc));
            break;

        case 'l':
            va_return_long (alist, VTABLE_get_integer (interpreter, pmc));
            break;

        case 'f':
            va_return_float (alist, VTABLE_get_number (interpreter, pmc));
            break;

        case 'd':
            va_return_double (alist, VTABLE_get_number (interpreter, pmc));
            break;

        case 't':
            /* This will leak memory */
            va_return_ptr (alist,
                           char *,
                           string_to_cstring(interpreter,
                                             VTABLE_get_string (interpreter,
                                                                pmc)));
            break;

        case 'v':
        case '\0':
            va_return_void (alist);
            break;
        }
}


#if 0
PMC*
Parrot_make_cb (Parrot_Interp interpreter, PMC* sub,
                PMC* user_data, STRING *cb_signature)
{

    PMC* interp_pmc, *cb, *cb_sig;
    __TR_function callback;
    STRING *sc;

    interp_pmc = VTABLE_get_pmc_keyed_int(interpreter, interpreter->iglobals,
            (INTVAL) IGLOBALS_INTERPRETER);

    sc = CONST_STRING(interpreter, "_interpreter");
    VTABLE_setprop(interpreter, user_data, sc, interp_pmc);

    sc = CONST_STRING(interpreter, "_sub");
    VTABLE_setprop(interpreter, user_data, sc, sub);

    cb_sig = pmc_new(interpreter, enum_class_String);
    VTABLE_set_string_native(interpreter, cb_sig, cb_signature);

    sc = CONST_STRING(interpreter, "_signature");
    VTABLE_setprop(interpreter, user_data, sc, cb_sig);

    dod_register_pmc(interpreter, user_data);

    cb = pmc_new(interpreter, enum_class_UnManagedStruct);

    dod_register_pmc(interpreter, cb);

    callback = alloc_callback (Parrot_callback_trampoline,
                               user_data);

    PMC_data(cb) = callback;

    return cb;
}




void
Parrot_run_callback(Parrot_Interp interpreter,
                    PMC* user_data, void* external_data)
{
    internal_exception(1, "Parrot_run_callback needs implementing for ffcall");
}
#endif


struct nci_vtable nci_ffcall_vtable =
{
    nci_ffcall_new,
    nci_ffcall_clone,
    nci_ffcall_invoke,
    nci_ffcall_free
};


/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
 */
