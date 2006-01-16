/* Convenience routines for fetching values */

#include "parrot/nci.h"

#define PARROT_NCI_CONCAT(x,y,z) x ## y ## z
#define PARROT_NCI_VTABLE(x) PARROT_NCI_CONCAT(nci_,x,_vtable)

/* Selects the configured NCI backend (configured in feature.h)*/
struct nci_vtable *nci_vtable_ptr = &PARROT_NCI_VTABLE(PARROT_NCI_IMPL);

INTVAL
Parrot_get_nci_I(Interp *interpreter, struct call_state *st, int n)
{
    assert(n < st->src.n);
    Parrot_fetch_arg_nci(interpreter, st);
    
    return UVal_int(st->val);
}

FLOATVAL
Parrot_get_nci_N(Interp *interpreter, struct call_state *st, int n)
{
    assert(n < st->src.n);
    Parrot_fetch_arg_nci(interpreter, st);

    return UVal_num(st->val);
}

STRING*
Parrot_get_nci_S(Interp *interpreter, struct call_state *st, int n)
{
    assert(n < st->src.n);
    Parrot_fetch_arg_nci(interpreter, st);

    return UVal_str(st->val);
}

PMC*
Parrot_get_nci_P(Interp *interpreter, struct call_state *st, int n)
{
    /*
     * exessive args are passed as NULL
     * used by e.g. MMD infix like __add
     */
    if (n < st->src.n)
        Parrot_fetch_arg_nci(interpreter, st);
    else
        UVal_pmc(st->val) = NULL;

    return UVal_pmc(st->val);
}

/* Convenience routines for setting values */

void
Parrot_set_nci_I(Interp *interpreter, struct call_state *st, INTVAL val)
{
    Parrot_init_ret_nci(interpreter, st, "I");
    UVal_int(st->val) = val;
    Parrot_convert_arg(interpreter, st);
    Parrot_store_arg(interpreter, st);
}

void
Parrot_set_nci_N(Interp *interpreter, struct call_state *st, FLOATVAL val)
{
    Parrot_init_ret_nci(interpreter, st, "N");
    UVal_num(st->val) = val;
    Parrot_convert_arg(interpreter, st);
    Parrot_store_arg(interpreter, st);
}

void
Parrot_set_nci_S(Interp *interpreter, struct call_state *st, STRING *val)
{
    Parrot_init_ret_nci(interpreter, st, "S");
    UVal_str(st->val) = val;
    Parrot_convert_arg(interpreter, st);
    Parrot_store_arg(interpreter, st);
}

void
Parrot_set_nci_P(Interp *interpreter, struct call_state *st, PMC* val)
{
    Parrot_init_ret_nci(interpreter, st, "P");
    UVal_pmc(st->val) = val;
    Parrot_convert_arg(interpreter, st);
    Parrot_store_arg(interpreter, st);
}


/* Convert NCI signatures to parrot ones */

char *Parrot_convert_signature (const char *signature)
{
    int i, length = strlen (signature);

    char *signature_parrot = (char *) malloc (length);

    for (i = 0 ; i < length+1 ; i++)
        {
            char map = '\0';

            switch (signature[i])
                {
                case 'p': map = 'P'; break;
                case 'i': map = 'I'; break;
                case '3': map = 'P'; break;
                case '2': map = 'P'; break;
                case '4': map = 'P'; break;
                case 'l': map = 'I'; break;
                case 'c': map = 'I'; break;
                case 's': map = 'I'; break;
                case 'f': map = 'N'; break;
                case 'd': map = 'N'; break;
                case 'b': map = 'S'; break;
                case 't': map = 'S'; break;
                case 'P': map = 'P'; break;
                case '0': map = 'P'; break;
                case 'S': map = 'S'; break;
                case 'I': map = 'I'; break;
                case 'N': map = 'N'; break;
                case 'B': map = 'S'; break;
                case 'v': map = 'v'; break;
                case 'J': map = ' '; break;

                }

            signature_parrot[i] = map;
        }


#if 0
    printf ("Map '%s' to '%s'\n", 
            signature, 
            signature_parrot); 
#endif

    return signature_parrot;
}
