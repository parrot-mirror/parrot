/* utf8.h
 *  Copyright (C) 2004-2007, Parrot Foundation.
 *  SVN Info
 *     $Id$
 *  Overview:
 *     This is the header for the utf8 variable-width encoding.
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#ifndef PARROT_ENCODING_UTF8_H_GUARD
#define PARROT_ENCODING_UTF8_H_GUARD

/* HEADERIZER BEGIN: src/string/encoding/utf8.c */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

void Parrot_encoding_utf8_init(PARROT_INTERP)
        __attribute__nonnull__(1);

size_t utf_hash(PARROT_INTERP, ARGIN(const STRING *src), size_t seed)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

#define ASSERT_ARGS_Parrot_encoding_utf8_init __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_utf_hash __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(src))
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: src/string/encoding/utf8.c */

#endif /* PARROT_ENCODING_UTF8_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
