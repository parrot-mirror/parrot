/*
Copyright (C) 2004-2010, Parrot Foundation.
$Id$

=head1 NAME

src/string/encoding/binary.c

=head1 DESCRIPTION

This file implements encoding functions for binary strings.

=over 4

=cut

*/

#include "parrot/parrot.h"
#include "shared.h"

/* HEADERIZER HFILE: none */

/* HEADERIZER BEGIN: static */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

PARROT_CANNOT_RETURN_NULL
static STRING * binary_chr(PARROT_INTERP, UINTVAL codepoint)
        __attribute__nonnull__(1);

PARROT_CANNOT_RETURN_NULL
static STRING* binary_error(PARROT_INTERP, SHIM(const STRING *src))
        __attribute__nonnull__(1);

static UINTVAL binary_scan(PARROT_INTERP, ARGIN(const STRING *src))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_CANNOT_RETURN_NULL
static STRING* binary_to_encoding(PARROT_INTERP, ARGIN(const STRING *src))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

#define ASSERT_ARGS_binary_chr __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_binary_error __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_binary_scan __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(src))
#define ASSERT_ARGS_binary_to_encoding __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(src))
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: static */

#ifdef EXCEPTION
#  undef EXCEPTION
#endif

#define EXCEPTION(err, str) \
    Parrot_ex_throw_from_c_args(interp, NULL, (err), (str))


/*

=item C<static STRING* binary_error(PARROT_INTERP, const STRING *src)>

Throws an exception because of an invalid operation on a binary string.

=cut

*/

PARROT_CANNOT_RETURN_NULL
static STRING*
binary_error(PARROT_INTERP, SHIM(const STRING *src))
{
    ASSERT_ARGS(binary_error)
    EXCEPTION(EXCEPTION_INVALID_ENCODING, "Invalid operation on binary string");
}


/*

=item C<static STRING* binary_to_encoding(PARROT_INTERP, const STRING *src)>

Converts the STRING C<src> to STRING C<dest> in binary mode.

=cut

*/

PARROT_CANNOT_RETURN_NULL
static STRING*
binary_to_encoding(PARROT_INTERP, ARGIN(const STRING *src))
{
    ASSERT_ARGS(binary_to_encoding)

    return fixed8_to_encoding(interp, src, Parrot_binary_encoding_ptr);
}


/*

=item C<static STRING * binary_chr(PARROT_INTERP, UINTVAL codepoint)>

Creates a new STRING object from a single codepoint C<codepoint>. Returns
the new STRING.

=cut

*/

PARROT_CANNOT_RETURN_NULL
static STRING *
binary_chr(PARROT_INTERP, UINTVAL codepoint)
{
    ASSERT_ARGS(binary_chr)
    char real_codepoint = (char)codepoint;
    return Parrot_str_new_init(interp, &real_codepoint, 1,
            Parrot_binary_encoding_ptr, 0);
}


/*

=item C<static UINTVAL binary_scan(PARROT_INTERP, const STRING *src)>

Returns the number of codepoints in string C<src>. No scanning needed
for fixed encodings.

=cut

*/

static UINTVAL
binary_scan(PARROT_INTERP, ARGIN(const STRING *src))
{
    ASSERT_ARGS(binary_scan)

    return src->bufused;
}


static STR_VTABLE Parrot_binary_encoding = {
    0,
    "binary",
    NULL,
    1, /* Max bytes per codepoint */

    binary_to_encoding,
    binary_chr,

    fixed8_equal,
    fixed8_compare,
    fixed8_index,
    fixed8_rindex,
    fixed8_hash,

    binary_scan,
    fixed8_ord,
    fixed_substr,

    (str_vtable_is_cclass_t)binary_error,
    (str_vtable_find_cclass_t)binary_error,
    (str_vtable_find_not_cclass_t)binary_error,

    (str_vtable_get_graphemes_t)binary_error,
    (str_vtable_compose_t)binary_error,
    (str_vtable_decompose_t)binary_error,

    (str_vtable_upcase_t)binary_error,
    (str_vtable_downcase_t)binary_error,
    (str_vtable_titlecase_t)binary_error,
    (str_vtable_upcase_first_t)binary_error,
    (str_vtable_downcase_first_t)binary_error,
    (str_vtable_titlecase_first_t)binary_error,

    fixed8_iter_get,
    fixed8_iter_skip,
    fixed8_iter_get_and_advance,
    fixed8_iter_set_and_advance,
    fixed8_iter_set_position
};

STR_VTABLE *Parrot_binary_encoding_ptr = &Parrot_binary_encoding;


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
