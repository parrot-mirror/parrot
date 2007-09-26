/* binary.h
 *  Copyright (C) 2004-2007, The Perl Foundation.
 *  SVN Info
 *     $Id$
 *  Overview:
 *     This is the header for the binary charset functions
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#ifndef PARROT_CHARSET_BINARY_H_GUARD
#define PARROT_CHARSET_BINARY_H_GUARD

/* HEADERIZER BEGIN: src/charset/binary.c */

PARROT_CANNOT_RETURN_NULL
const CHARSET * Parrot_charset_binary_init(PARROT_INTERP)
        __attribute__nonnull__(1);

/* HEADERIZER END: src/charset/binary.c */

#endif /* PARROT_CHARSET_BINARY_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
