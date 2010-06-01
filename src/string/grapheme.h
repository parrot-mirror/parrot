/*
Copyright (C) 2010, Parrot Foundation.
$Id$
*/

#ifndef PARROT_GRAPHEME_H_GUARD
#define PARROT_GRAPHEME_H_GUARD

#if PARROT_HAS_ICU
#  include <unicode/uchar.h>

struct grapheme_t {
    UINTVAL  len;        /* Grapheme length in codepoints. */
    UChar32 *codepoints; /* UCS-4 codepoints that make up the grapheme */
    UINTVAL  hash;
};

typedef struct grapheme_t grapheme;

#define MIN_TABLE_LENGTH 1

struct grapheme_table_t {
    UINTVAL size; /* Total table size, in graphemes. */
    UINTVAL used; /* Number of slots used from the table. */
    grapheme graphemes[MIN_TABLE_LENGTH];
    /*
     * Not really a static array. When we need a bigger table, we just allocate
     * a bigger structure and keep going after the 'end' of the array.
     */
};

typedef struct grapheme_table_t grapheme_table;

#define ISCOMBINING(c) ( (0x0299 < (c) &&  (c) < 0x0370)\
                      || (0x1dbf < (c) &&  (c) < 0x1e00)\
                      || (0x20cf < (c) &&  (c) < 0x2100)\
                      || (0xfe1f < (c) &&  (c) < 0xfe30))

/* HEADERIZER BEGIN: src/string/grapheme.c */
/* HEADERIZER END: src/string/grapheme.c */

#endif /* PARROT_HAS_ICU */
#endif /* PARROT_GRAPHEME_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
