/*
Copyright (C) 2004-2010, Parrot Foundation.
$Id$

=head1 NAME

src/string/encoding/latin1.c

=head1 DESCRIPTION

This file implements encoding functions for ISO-8859-1 strings.

=over 4

=cut

*/

#include "parrot/parrot.h"
#include "shared.h"
#include "tables.h"

/* HEADERIZER HFILE: none */

/* HEADERIZER BEGIN: static */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

PARROT_CANNOT_RETURN_NULL
static STRING * latin1_chr(PARROT_INTERP, UINTVAL codepoint)
        __attribute__nonnull__(1);

PARROT_CANNOT_RETURN_NULL
static STRING* latin1_downcase(PARROT_INTERP, ARGIN(const STRING *src))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_CANNOT_RETURN_NULL
static STRING* latin1_downcase_first(PARROT_INTERP,
    ARGIN(const STRING *src))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

static UINTVAL latin1_scan(PARROT_INTERP, ARGIN(const STRING *src))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_CANNOT_RETURN_NULL
static STRING* latin1_titlecase(PARROT_INTERP, ARGIN(const STRING *src))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_CANNOT_RETURN_NULL
static STRING* latin1_titlecase_first(PARROT_INTERP,
    ARGIN(const STRING *src))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static STRING * latin1_to_encoding(PARROT_INTERP, ARGIN(const STRING *src))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_CANNOT_RETURN_NULL
static STRING* latin1_upcase(PARROT_INTERP, ARGIN(const STRING *src))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_CANNOT_RETURN_NULL
static STRING* latin1_upcase_first(PARROT_INTERP, ARGIN(const STRING *src))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

#define ASSERT_ARGS_latin1_chr __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_latin1_downcase __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(src))
#define ASSERT_ARGS_latin1_downcase_first __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(src))
#define ASSERT_ARGS_latin1_scan __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(src))
#define ASSERT_ARGS_latin1_titlecase __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(src))
#define ASSERT_ARGS_latin1_titlecase_first __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(src))
#define ASSERT_ARGS_latin1_to_encoding __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(src))
#define ASSERT_ARGS_latin1_upcase __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(src))
#define ASSERT_ARGS_latin1_upcase_first __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(src))
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: static */


/*

=item C<static STRING * latin1_to_encoding(PARROT_INTERP, const STRING *src)>

Converts the STRING C<src> to an ISO-8859-1 STRING C<dest>.

=cut

*/

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static STRING *
latin1_to_encoding(PARROT_INTERP, ARGIN(const STRING *src))
{
    ASSERT_ARGS(latin1_to_encoding)

    return fixed8_to_encoding(interp, src, Parrot_latin1_encoding_ptr);
}


/*

=item C<static STRING * latin1_chr(PARROT_INTERP, UINTVAL codepoint)>

Creates a new STRING from the single codepoint C<codepoint>.

=cut

*/

PARROT_CANNOT_RETURN_NULL
static STRING *
latin1_chr(PARROT_INTERP, UINTVAL codepoint)
{
    ASSERT_ARGS(latin1_chr)
    char real_codepoint = (char)codepoint;
    PARROT_ASSERT(codepoint < 0x100);
    return Parrot_str_new_init(interp, &real_codepoint, 1,
            Parrot_latin1_encoding_ptr, 0);
}


/*

=item C<static UINTVAL latin1_scan(PARROT_INTERP, const STRING *src)>

Returns the number of codepoints in string C<src>. No scanning needed
for fixed encodings.

=cut

*/

static UINTVAL
latin1_scan(PARROT_INTERP, ARGIN(const STRING *src))
{
    ASSERT_ARGS(latin1_scan)

    return src->bufused;
}


/*

=item C<static STRING* latin1_upcase(PARROT_INTERP, const STRING *src)>

Convert all graphemes in the STRING C<src> to upper case, for those
graphemes that support cases.

=cut

*/

PARROT_CANNOT_RETURN_NULL
static STRING*
latin1_upcase(PARROT_INTERP, ARGIN(const STRING *src))
{
    ASSERT_ARGS(latin1_upcase)
    unsigned char *buffer;
    UINTVAL        offset = 0;
    STRING        *result = Parrot_str_clone(interp, src);

    if (!result->strlen)
        return result;

    buffer = (unsigned char *)result->strstart;
    for (offset = 0; offset < result->strlen; ++offset) {
        unsigned int c = buffer[offset]; /* XXX use encoding ? */
        if (c >= 0xe0 && c != 0xf7)
            c &= ~0x20;
        else
            c = toupper((unsigned char)c);
        buffer[offset] = (unsigned char)c;
    }

    return result;
}


/*

=item C<static STRING* latin1_downcase(PARROT_INTERP, const STRING *src)>

Converts all graphemes in STRING C<src> to lower-case, for those graphemes
that support cases.

=cut

*/

PARROT_CANNOT_RETURN_NULL
static STRING*
latin1_downcase(PARROT_INTERP, ARGIN(const STRING *src))
{
    ASSERT_ARGS(latin1_downcase)
    unsigned char *buffer;
    UINTVAL        offset = 0;
    STRING        *result = Parrot_str_clone(interp, src);

    if (!result->strlen)
        return result;

    buffer = (unsigned char *)result->strstart;
    for (offset = 0; offset < result->strlen; ++offset) {
        unsigned int c = buffer[offset];
        if (c >= 0xc0 && c != 0xd7 && c <= 0xde)
            c |= 0x20;
        else
            c = tolower((unsigned char)c);
        buffer[offset] = (unsigned char)c;
    }

    return result;
}


/*

=item C<static STRING* latin1_titlecase(PARROT_INTERP, const STRING *src)>

Converts the graphemes in STRING C<src> to title case, for those graphemes
that support cases.

=cut

*/

PARROT_CANNOT_RETURN_NULL
static STRING*
latin1_titlecase(PARROT_INTERP, ARGIN(const STRING *src))
{
    ASSERT_ARGS(latin1_titlecase)
    unsigned char *buffer;
    unsigned int   c;
    UINTVAL        offset;
    STRING        *result = Parrot_str_clone(interp, src);

    if (!result->strlen)
        return result;

    buffer = (unsigned char *)result->strstart;
    c = buffer[0];
    if (c >= 0xe0 && c != 0xf7)
        c &= ~0x20;
    else
        c = toupper((unsigned char)c);
    buffer[0] = (unsigned char)c;

    for (offset = 1; offset < result->strlen; ++offset) {
        c = buffer[offset];
        if (c >= 0xc0 && c != 0xd7 && c <= 0xde)
            c |= 0x20;
        else
            c = tolower((unsigned char)c);
        buffer[offset] = (unsigned char)c;
    }

    return result;
}


/*

=item C<static STRING* latin1_upcase_first(PARROT_INTERP, const STRING *src)>

Converts the first grapheme in STRING C<src> to upper case, if it
supports cases.

=cut

*/

PARROT_CANNOT_RETURN_NULL
static STRING*
latin1_upcase_first(PARROT_INTERP, ARGIN(const STRING *src))
{
    ASSERT_ARGS(latin1_upcase_first)
    unsigned char *buffer;
    unsigned int   c;
    STRING        *result = Parrot_str_clone(interp, src);

    if (!result->strlen)
        return result;

    buffer = (unsigned char *)result->strstart;
    c = buffer[0];
    if (c >= 0xe0 && c != 0xf7)
        c &= ~0x20;
    else
        c = toupper((unsigned char)c);
    buffer[0] = (unsigned char)c;

    return result;
}


/*

=item C<static STRING* latin1_downcase_first(PARROT_INTERP, const STRING *src)>

Converts the first character of the STRING C<src> to lower case, if the
grapheme supports lower case.

=cut

*/

PARROT_CANNOT_RETURN_NULL
static STRING*
latin1_downcase_first(PARROT_INTERP, ARGIN(const STRING *src))
{
    ASSERT_ARGS(latin1_downcase_first)
    unsigned char *buffer;
    unsigned int   c;
    STRING        *result = Parrot_str_clone(interp, src);

    if (!result->strlen)
        return result;

    buffer = (unsigned char *)result->strstart;
    c = buffer[0];
    if (c >= 0xc0 && c != 0xd7 && c <= 0xde)
        c &= ~0x20;
    else
        c = tolower((unsigned char)c);
    buffer[0] = (unsigned char)c;

    return result;
}


/*

=item C<static STRING* latin1_titlecase_first(PARROT_INTERP, const STRING *src)>

Converts the first grapheme in STRING C<src> to title case, if the grapheme
supports case.

=cut

*/

PARROT_CANNOT_RETURN_NULL
static STRING*
latin1_titlecase_first(PARROT_INTERP, ARGIN(const STRING *src))
{
    ASSERT_ARGS(latin1_titlecase_first)
    return latin1_upcase_first(interp, src);
}


static STR_VTABLE Parrot_latin1_encoding = {
    0,
    "iso-8859-1",
    NULL,
    1, /* Max bytes per codepoint */

    latin1_to_encoding,
    latin1_chr,

    fixed8_equal,
    fixed8_compare,
    fixed8_index,
    fixed8_rindex,
    fixed8_hash,
    encoding_validate,

    latin1_scan,
    fixed8_ord,
    fixed_substr,

    fixed8_is_cclass,
    fixed8_find_cclass,
    fixed8_find_not_cclass,

    encoding_get_graphemes,
    fixed8_compose,
    encoding_decompose,

    latin1_upcase,
    latin1_downcase,
    latin1_titlecase,
    latin1_upcase_first,
    latin1_downcase_first,
    latin1_titlecase_first,

    fixed8_iter_get,
    fixed8_iter_skip,
    fixed8_iter_get_and_advance,
    fixed8_iter_set_and_advance,
    fixed8_iter_set_position
};

STR_VTABLE *Parrot_latin1_encoding_ptr = &Parrot_latin1_encoding;


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
