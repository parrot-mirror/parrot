
#include "parrot/parrot.h"

#include "binary.h"
#include <stdio.h>

static int class_TclFloat  = 0;
static int class_TclInt    = 0;
static int class_TclList   = 0;
static int class_TclString = 0;

static PMC *
binary_scan_number_field(Interp *interp, char field, char *binstr, int *_pos, int length)
{
    char *c;
    double *d;
    float *f;
    int *n;

    int len;
    PMC *value = PMCNULL;
    int pos = *_pos;
    switch (field)
    {
        case 'c':
            if (pos >= length)
                break;
            c     = (char *)(binstr + pos);
            value = pmc_new(interp, class_TclInt);
            VTABLE_set_integer_native(interp, value, (INTVAL)*c);
            pos += 1;
            break;
        case 'd':
            len = sizeof(double)/sizeof(char);
            if (pos + len > length)
                break;
            d     = (double *)(binstr + pos);
            value = pmc_new(interp, class_TclFloat);
            VTABLE_set_number_native(interp, value, *d);
            pos += len;
            break;
        case 'f':
            len = sizeof(float)/sizeof(char);
            if (pos + len > length)
                break;
            f     = (float *)(binstr + pos);
            value = pmc_new(interp, class_TclFloat);
            VTABLE_set_number_native(interp, value, *f);
            pos += len;
            break;
        case 'n':
            len = sizeof(int)/sizeof(char);
            if (pos + len > length)
                break;
            n     = (int *)(binstr + pos);
            value = pmc_new(interp, class_TclInt);
            VTABLE_set_integer_native(interp, value, *n);
            pos += len;
            break;
    }
    (*_pos) = pos;
    return value;
}

static PMC *
binary_scan_number_slurpy(Interp *interp, char field, char *binstr, int *_pos, int length)
{
    PMC *elem;
    PMC *values = pmc_new(interp, class_TclList);

    while ((elem = binary_scan_number_field(interp, field, binstr, _pos, length)) != PMCNULL)
        VTABLE_push_pmc(interp, values, elem);

    return values;
}

static PMC *
binary_scan_number(Interp *interp, char field,
                   char *format, int *formatpos, int formatlen,
                   char *binstr, int *binstrpos, int binstrlen)
{
    PMC *value;

    if ((*formatpos) < formatlen && format[*formatpos] == '*')
    {
        (*formatpos)++;
        value = binary_scan_number_slurpy(interp, field, binstr, binstrpos, binstrlen);
    }
    else
        value = binary_scan_number_field(interp, field, binstr, binstrpos, binstrlen);

    return value;
}

static STRING *
binary_scan_string_field(Interp *interp, char field,
                         char *binstr, int *_pos, int length, STRING *value)
{
    int pos = *_pos;

    char *c;
    switch (field)
    {
        case 'a':
            if (pos + 1 > length)
                return NULL;
            c     = binstr + pos;
            value = string_concat(interp, value, string_from_cstring(interp, c, 1), 1);
            pos++;
            break;
        default:
            return NULL;
    }

    *_pos = pos;
    return value;
}

static STRING *
binary_scan_string_slurpy(Interp *interp, char field,
                          char *binstr, int *_pos, int length, STRING *value)
{
    STRING *retval;

    while (retval = binary_scan_string_field(interp, field, binstr, _pos, length, value))
        value = retval;

    return value;
}

static PMC *
binary_scan_string(Interp *interp, char field,
                   char *format, int *formatpos, int formatlen,
                   char *binstr, int *binstrpos, int binstrlen)
{
    STRING *value = string_make_empty(interp, enum_stringrep_one, 128);
    PMC *pmcval   = pmc_new(interp, class_TclString);

    if ((*formatpos) < formatlen && format[*formatpos] == '*')
    {
        (*formatpos)++;
        value = binary_scan_string_slurpy(interp, field, binstr, binstrpos, binstrlen, value);
    }
    else
        value = binary_scan_string_field(interp, field, binstr, binstrpos, binstrlen, value);

    VTABLE_set_string_native(interp, pmcval, value);
    return pmcval;
}

PMC *ParTcl_binary_scan(Interp *interp, STRING *BINSTR, STRING *FORMAT)
{
    char *binstr  = string_to_cstring(interp, BINSTR);
    int binstrlen = (int)string_length(interp, BINSTR);
    int binstrpos = 0;
    char *format  = string_to_cstring(interp, FORMAT);
    int formatlen = string_length(interp, FORMAT);
    int formatpos = 0;
    PMC *values;

    if (!class_TclFloat)
    {
        class_TclFloat  = pmc_type(interp, string_from_const_cstring(interp, "TclFloat", 0));
        class_TclInt    = pmc_type(interp, string_from_const_cstring(interp, "TclInt", 0));
        class_TclList   = pmc_type(interp, string_from_const_cstring(interp, "TclList", 0));
        class_TclString = pmc_type(interp, string_from_const_cstring(interp, "TclString", 0));
    }

    values = pmc_new(interp, class_TclList);
    while (formatpos < formatlen)
    {
        char field = format[formatpos++];
        PMC *value;

        switch (field)
        {
            case 'c':
            case 'd':
            case 'f':
            case 'n':
                value = binary_scan_number(interp, field,
                                           format, &formatpos, formatlen,
                                           binstr, &binstrpos, binstrlen);
                break;
            case 'a':
            case 'A':
                value = binary_scan_string(interp, field,
                                           format, &formatpos, formatlen,
                                           binstr, &binstrpos, binstrlen);
                break;
        }

        VTABLE_push_pmc(interp, values, value);
    }

    string_cstring_free(binstr);
    string_cstring_free(format);

    return values;
}

static STRING *
binary_format_field(Interp *interp, char field, STRING *binstr, PMC *value)
{
    char c;
    double d;
    float f;
    int n;

    INTVAL len;

    switch (field)
    {
        /* a char */
        case 'c':
            c      = (char)VTABLE_get_integer(interp, value);
            binstr = string_concat(interp, binstr, string_from_cstring(interp, &c, 1), 1);
            break;
        /* a double */
        case 'd':
            d      = (double)VTABLE_get_number(interp, value);
            len    = sizeof(double)/sizeof(char);
            binstr = string_concat(interp, binstr, string_from_cstring(interp, &d, len), len);
            break;
        /* a float */
        case 'f':
            f      = (float)VTABLE_get_number(interp, value);
            len    = sizeof(float)/sizeof(char);
            binstr = string_concat(interp, binstr, string_from_cstring(interp, &f, len), len);
            break;
        /* a native integer */
        case 'n':
            n      = (int)VTABLE_get_integer(interp, value);
            len    = sizeof(int)/sizeof(char);
            binstr = string_concat(interp, binstr, string_from_cstring(interp, &n, len), len);
            break;
    }

    return binstr;
}

STRING *ParTcl_binary_format(Interp *interp, STRING *FORMAT, PMC *values)
{
    char *format      = string_to_cstring(interp, FORMAT);
    INTVAL formatlen  = string_length(interp, FORMAT);
    INTVAL pos        = 0;
    INTVAL valueidx   = 0;
    STRING *binstr    = string_make_empty(interp, enum_stringrep_one, 128);

    while (pos < formatlen)
    {
        PMC *value = VTABLE_get_pmc_keyed_int(interp, values, valueidx++);
        binstr = binary_format_field(interp, format[pos++], binstr, value);
    }

    string_cstring_free(format);

    return binstr;
}

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
