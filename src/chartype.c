/* chartype.c
 *  Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
 *  CVS Info
 *     $Id$
 *  Overview:
 *     This defines the string character type subsystem
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#include "parrot/parrot.h"

/*
 * Unicode mapping table
 */
struct chartype_unicode_map_t {
    UINTVAL n1;
    INTVAL *cparray;
    INTVAL *cparray2;
};

extern CHARTYPE usascii_chartype;
extern CHARTYPE unicode_chartype;

/* Registered character types */
static CHARTYPE **chartype_array = NULL;
static int chartype_count = 0;

/* Registered transcoders */
static struct chartype_transcoder_entry_t **transcoder_array = NULL;
static int transcoder_count = 0;

struct chartype_digit_map_t default_digit_map = { 0x30, 0x39, 0 };

/*
 * Register a chartype entry
 * XXX Register transcode functions
 */
static void
chartype_register(CHARTYPE *type)
{
    if (type->index == -1)
        type->index = chartype_count;
    if (type->index >= chartype_count) {
        size_t old_size = chartype_count * sizeof(CHARTYPE *);
        size_t new_size = (type->index + 1) * sizeof(CHARTYPE *);
        chartype_array = mem_sys_realloc(chartype_array, new_size);
        memset((char *)chartype_array + old_size, 0, new_size - old_size);
        chartype_count = type->index + 1;
    }
    chartype_array[type->index] = type;
}

void
chartype_init()
{
    chartype_count = enum_chartype_MAX;
    chartype_array = mem_sys_allocate(sizeof(CHARTYPE*) * chartype_count);
    chartype_register(&unicode_chartype);
    chartype_register(&usascii_chartype);
}

void
chartype_destroy()
{
    mem_sys_free(chartype_array);
}

static char *
malloc_and_strcpy(const char *in)
{
    size_t len = strlen(in);
    char *out = mem_sys_allocate(len+1);
    strcpy(out, in);
    return out;
}

static UINTVAL
chartype_to_unicode_cparray(const CHARTYPE *from, const CHARTYPE *to, 
                            UINTVAL c)
{
    const struct chartype_unicode_map_t *map = from->unicode_map;

    if (c < map->n1)
        return c;
    else if (c < 256) 
        return map->cparray[c - map->n1];
    else
        return map->cparray2[c - 128*256];
}

static UINTVAL
chartype_from_unicode_cparray(const CHARTYPE *from, const CHARTYPE *to,
                              UINTVAL c)
{
    const struct chartype_unicode_map_t *map = to->unicode_map;

    if (c < map->n1) {
        return c;
    }
    else {
        UINTVAL i;
        if (map->cparray) {
            for (i = 0; i < 256 - map->n1; i++) {
                if (map->cparray[i] == (INTVAL)c)
                    return i + map->n1;
            }
        }
        if (map->cparray2) {
            for (i = 0; i < 128*256; i++) {
                if (map->cparray2[i] == (INTVAL)c)
                    return i + 128*256;
            }
        }
        internal_exception(INVALID_CHARACTER,
                           "Invalid character <%X> for chartype\n",c);
        return 0;
    }
}

/*
 * Digit mapping via translation to Unicode
 * XXX Replace by generation of custom digit mapping table
 */
static Parrot_Int
chartype_is_digit_Unicode(const CHARTYPE* type, const UINTVAL c, 
                          unsigned int class)
{
    UINTVAL uc = chartype_to_unicode_cparray(type, NULL, c);
    return chartype_is_digit_mapn(&unicode_chartype, uc, enum_charclass_digit);
}

static Parrot_Int
chartype_get_digit_Unicode(const CHARTYPE* type, const UINTVAL c)
{
    UINTVAL uc = chartype_to_unicode_cparray(type, NULL, c);
    return chartype_get_digit_mapn(&unicode_chartype, uc);
}

static INTVAL
chartype_is_charclass_Unicode(const struct parrot_chartype_t *type, 
                              const Parrot_UInt c, const unsigned int class)
{
    UINTVAL uc = chartype_to_unicode_cparray(type, NULL, c);
    return unicode_chartype.is_charclass[enum_charclass_SLOW]
               (&unicode_chartype, uc, class);
}


/*
 * Create chartype from mapping file
 * Still TODO:
 *   Handle more encodings (singlebyte & dbcs implemented so far)
 *   Create custom digit mapping table
 *   Path is hardcoded to "runtime/parrot/chartypes/<name>.TXT"
 *   Does direct file system IO - should probably use Parrot IO
 *   Better parsing code - e.g. handle erroneous input!
 */
static const CHARTYPE *
chartype_create_from_mapping(const char *name)
{
    char *path;
    FILE *f;
    CHARTYPE *type;
    char line[80];
    INTVAL typecode;
    INTVAL unicode;
    INTVAL *cparray = NULL;
    INTVAL *cparray2 = NULL;
    struct chartype_unicode_map_t *map;
    int one2one = 0;
    int i;

    path = mem_sys_allocate(strlen(name) + 32);
    sprintf(path, "runtime/parrot/chartypes/%s.TXT", name);
    f = fopen(path, "r");
    if (!f) {
        internal_exception(INVALID_CHARTYPE, "Invalid chartype '%s'\n", name);
        return NULL;
    }

    while (!feof(f)) {
        char *p = fgets(line, 80, f);
        if (line[0] != '#') {
            int n = sscanf(line, "%li\t%li", &typecode, &unicode);
            if (n == 2 && typecode >= 0) {
                if (typecode < 256 && typecode == one2one && 
                    unicode == typecode) 
                {
                    one2one++;
                }
                else if (typecode < 256) {
                    if (!cparray) {
                        int size = (256 - one2one) * sizeof(INTVAL);
                        cparray = mem_sys_allocate(size);
                        memset(cparray, 0xFF, size);
                    }
                    cparray[typecode-one2one] = unicode;
                }
                /* XXX Should abort loading if invalid value found */
                else if (typecode >= 128*256) {
                    if (!cparray2) {
                        int size = 128 * 256 * sizeof(INTVAL);
                        cparray2 = mem_sys_allocate(size);
                        memset(cparray2, 0xFF, size);
                    }
                    cparray2[typecode - (128*256)] = unicode;
                }
            }
        }
    }
    fclose(f);

    type = mem_sys_allocate(sizeof(CHARTYPE));
    type->index = -1;    /* will be allocated during registration */
    type->name = malloc_and_strcpy(name);
    if (cparray2) {
        type->default_encoding = malloc_and_strcpy("dbcs");
    }
    else {
        type->default_encoding = malloc_and_strcpy("singlebyte");
    }
    type->from_unicode = chartype_from_unicode_cparray;
    type->to_unicode = chartype_to_unicode_cparray;
    for (i=0; i<=enum_charclass_SLOW; i++)
        type->is_charclass[i] = chartype_is_charclass_Unicode;
    /* XXX Should generate a custom digit mapping table */
    if (enum_charclass_digit < enum_charclass_SLOW)
        type->is_charclass[enum_charclass_digit] = chartype_is_digit_Unicode;
    type->get_digit = chartype_get_digit_Unicode;
    type->digit_map = NULL;
    map = mem_sys_allocate(sizeof(struct chartype_unicode_map_t));
    map->n1 = one2one;
    map->cparray = cparray;
    map->cparray2 = cparray2;
    type->unicode_map = map;
    type->transcoders = NULL;
    chartype_register(type);
    return type;
}

const CHARTYPE *
chartype_lookup(const char *name)
{
    int i;

    for (i=0; i<chartype_count; i++) {
        if (chartype_array[i] && !strcmp(name, chartype_array[i]->name)) {
            return chartype_array[i];
        }
    }

    return chartype_create_from_mapping(name);
}

const CHARTYPE *
chartype_lookup_index(INTVAL n)
{
    return chartype_array[n];
}

INTVAL
chartype_find_chartype(const char *name)
{
    const CHARTYPE *type = chartype_lookup(name);
    if (type)
        return type->index;
    else
        return -1;
}

CHARTYPE_TRANSCODER
chartype_lookup_transcoder(const CHARTYPE *from, const CHARTYPE *to)
{
    CHARTYPE_TRANSCODER transcoder;
    int i;

    for (i=0; i<transcoder_count; i++) {
        if (transcoder_array[i]) {
            if (!strcmp(from->name, transcoder_array[i]->from)
             && !strcmp(to->name, transcoder_array[i]->to))
                return transcoder_array[i]->transcoder;
        }
    }
    return NULL;
}

/*
 * Generic versions of the digit handling functions
 */
Parrot_Int
chartype_is_digit_map1(const CHARTYPE* type, const UINTVAL c, 
                       unsigned int class)
{
    return c >= type->digit_map->first_code && c <= type->digit_map->last_code;
}

Parrot_Int
chartype_get_digit_map1(const CHARTYPE* type, const UINTVAL c)
{
    if (c >= type->digit_map->first_code && c <= type->digit_map->last_code)
        return c - type->digit_map->first_code + type->digit_map->first_value;
    else {
        /* XXX Should we throw an exception? */
        return -1;
    }
}

Parrot_Int
chartype_is_digit_mapn(const CHARTYPE* type, const UINTVAL c,
                       unsigned int class)
{
    const struct chartype_digit_map_t *map = type->digit_map;
    while (map->first_value >= 0) {
        if (c < map->first_code)
            return 0;
        if (c <= map->last_code)
            return map->last_code;
        map++;
    }
    return 0;
}

Parrot_Int
chartype_get_digit_mapn(const CHARTYPE* type, const UINTVAL c)
{
    const struct chartype_digit_map_t *map = type->digit_map;
    while (map->first_value >= 0) {
        if (c < map->first_code)
            break;
        if (c <= map->last_code)
            return c - map->first_code + map->first_value;
        map++;
    }
    /* XXX should we throw an exception? */
    return -1;
}

/*
 * Generic Unicode mapping functions
 */
UINTVAL
chartype_transcode_nop(const CHARTYPE *from, const CHARTYPE *to, UINTVAL c)
{
    return c;
}


/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
*/
