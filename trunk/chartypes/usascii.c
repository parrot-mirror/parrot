/*
Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
$Id$

=head1 NAME

chartypes/usascii.c - US-ASCII Chartype

=head1 DESCRIPTION

This file implements the US-ASCII character set functionality in Parrot.

Note that calls to the charclass functions are done via macros of the
form C<Parrot_char_is_digit(chartype, value)> which are generated by
F<config/gen/parrot_include.pl> during configuration to point to either
a dedicated slot or the generic function, as appropriate.

=head2 Functions

=over 4

=cut

*/

#include "parrot/parrot.h"

struct chartype_digit_map_t usascii_digit_map = { 0x30, 0x39, 0 };

/*

=item C<static UINTVAL
usascii_transcode_from_unicode(const CHARTYPE *from, const CHARTYPE *to,
                               UINTVAL c)>

Returns the US-ASCII character for Unicode character C<c>.

Currently this just returns C<c> if it is in the range 0..127, and
raises an exception otherwise.

C<*from> annd C<*to> are assumed to be Unicode and US-ASCII. Their
values are ignored.

=cut

*/

static UINTVAL
usascii_transcode_from_unicode(const CHARTYPE *from, const CHARTYPE *to,
                               UINTVAL c)
{
    if (c > 127) {
        internal_exception(INVALID_CHARACTER,
                           "Invalid character for US-ASCII");
    }
    return c;
}

/*

=item C<static INTVAL
usascii_is_charclass(const struct parrot_chartype_t *type, const Parrot_UInt c, 
                     const unsigned int class)>

Returns whether C<c> is a member of character class C<class>.

This raises an exception of C<class> is and unknown character class.

=cut

*/

static INTVAL
usascii_is_charclass(const struct parrot_chartype_t *type, const Parrot_UInt c, 
                     const unsigned int class)
{
    switch (class) {
        case enum_charclass_alnum:
            return (c >= 0x30 && c <= 0x39) ||
                   (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);
        case enum_charclass_alpha:
            return (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);
        case enum_charclass_ascii:
            return c < 128;
        case enum_charclass_blank:
            return c == 0x20 || c == 0x09;
        case enum_charclass_cntrl:
            return c < 0x20 || c == 0x7F;
        case enum_charclass_digit:
            return c >= 0x30 && c <= 0x39;
        case enum_charclass_graph:
            return c > 0x20 && c < 0x7F;
        case enum_charclass_lower:
            return c >= 0x61 && c <= 0x7A;
        case enum_charclass_print:
            return c >= 0x20 && c < 0x7F;
        case enum_charclass_punct:
            return (c >= 0x21 && c <= 0x2F) ||
                   (c >= 0x3A && c <= 0x40) ||
                   (c >= 0x5B && c <= 0x60) ||
                   (c >= 0x7B && c <= 0x7E);
        case enum_charclass_space:
            return c == 0x20 || c == 0x0C || c == 0x0A || c == 0x0D ||
                   c == 0x09 || c == 0x0B;
        case enum_charclass_upper:
            return c >= 0x41 && c <= 0x5A;
        case enum_charclass_xdigit:
            return (c >= 0x30 && c <= 0x39) ||
                   (c >= 0x41 && c <= 0x46) ||
                   (c >= 0x61 && c <= 0x66);
    }
    internal_exception(INVALID_CHARCLASS, "Unknown character class <%d>\n", 
                       class);
    return 0;
}

CHARTYPE usascii_chartype = {
    enum_chartype_usascii,
    "usascii",
    "singlebyte",
    { 
        chartype_is_digit_map1,      /* is_digit() */
        usascii_is_charclass         /* is_charclass() - slow version */
    },
    chartype_get_digit_map1,         /* get_digit() */
    &usascii_digit_map,              /* digit_map */
    NULL,                            /* unicode_map */
    &usascii_transcode_from_unicode, /* from_unicode() */
    &chartype_transcode_nop,         /* to_unicode() */
    NULL                             /* transcoders */
};

/*

=back

=head1 SEE ALSO

F<chartypes/unicode.c>,
F<src/chartype.c>,
F<include/parrot/chartype.h>,
F<config/gen/parrot_include.pl>,
F<docs/strings.pod>.

=cut

*/

/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
*/
