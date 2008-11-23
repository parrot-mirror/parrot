/*
Copyright (C) 2001-2007, The Perl Foundation.
$Id$

=head1 NAME

src/io/utf8.c - UTF8 I/O utility functions

=head1 DESCRIPTION

Convert output to utf8. Convert input to Parrot's internal string
representation.

=head2 Utility functions

=over 4

=cut

*/

#include "parrot/parrot.h"
#include "io_private.h"
#include "../unicode.h"

/* HEADERIZER HFILE: include/parrot/io.h */

/* HEADERIZER BEGIN: static */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

static size_t PIO_utf8_read(PARROT_INTERP,
    ARGMOD(ParrotIOLayer *layer),
    ARGMOD(ParrotIO *io),
    ARGOUT(STRING **buf))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        FUNC_MODIFIES(*layer)
        FUNC_MODIFIES(*io)
        FUNC_MODIFIES(*buf);

static size_t PIO_utf8_write(PARROT_INTERP,
    ARGIN(ParrotIOLayer *l),
    ARGMOD(ParrotIO *io),
    ARGMOD(STRING *s))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        FUNC_MODIFIES(*io)
        FUNC_MODIFIES(*s);

/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: static */

/*

=item C<size_t Parrot_io_read_utf8>

Read a string from a filehandle in UTF-8 format and convert it to a Parrot
string.

=cut

*/

size_t
Parrot_io_read_utf8(PARROT_INTERP, ARGMOD(PMC *filehandle),
        ARGMOD(STRING **buf))
{
    STRING *s, *s2;
    String_iter iter;

    size_t len  = Parrot_io_read_buffer(interp, filehandle, buf);
    s           = *buf;
    s->charset  = Parrot_unicode_charset_ptr;
    s->encoding = Parrot_utf8_encoding_ptr;

    /* count chars, verify utf8 */
    Parrot_utf8_encoding_ptr->iter_init(interp, s, &iter);

    while (iter.bytepos < s->bufused) {
        if (iter.bytepos + 4 > s->bufused) {
            const utf8_t *u8ptr = (utf8_t *)((char *)s->strstart +
                    iter.bytepos);
            const UINTVAL c = *u8ptr;

            if (UTF8_IS_START(c)) {
                UINTVAL len2 = UTF8SKIP(u8ptr);
                INTVAL  read;

                if (iter.bytepos + len2 <= s->bufused)
                    goto ok;

                /* need len - 1 more chars */
                len2--;
                s2           = NULL;
                s2           = Parrot_io_make_string(interp, &s2, len2);
                s2->bufused  = len2;
                s2->charset  = Parrot_unicode_charset_ptr;
                s2->encoding = Parrot_utf8_encoding_ptr;

                /* RT#46413 need to check the amount read here? */
                read         = Parrot_io_read_buffer(interp, filehandle, &s2);
                UNUSED(read);

                s->strlen    = iter.charpos;
                s            = string_append(interp, s, s2);
                len         += len2 + 1;

                /* check last char */
            }
        }
ok:
        iter.get_and_advance(interp, &iter);
    }
    s->strlen = iter.charpos;
    return len;
}

/*

=item C<size_t Parrot_io_write_utf8>

Write a Parrot string to a filehandle in UTF-8 format.

=cut

*/

size_t
Parrot_io_write_utf8(PARROT_INTERP, ARGMOD(PMC *filehandle),
        ARGMOD(STRING *s))
{
    STRING *dest;

    if (s->encoding == Parrot_utf8_encoding_ptr)
        return Parrot_io_write_buffer(interp, filehandle, s);

    dest = Parrot_utf8_encoding_ptr->to_encoding(interp, s,
            new_string_header(interp, 0));
    return Parrot_io_write_buffer(interp, filehandle, dest);
}

/*

=back

=head1 SEE ALSO

F<src/io/io_passdown.c>,
F<src/io/io.c>,
F<src/io/io_layers.c>,
F<src/io/io_private.h>.

=head1 HISTORY

Initially written by Leo.

=cut

*/


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
