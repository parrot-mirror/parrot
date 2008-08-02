/*
Copyright (C) 2004-2008, The Perl Foundation.
$Id$

=head1 NAME

src/charset/iso-8859-1.c

=head1 DESCRIPTION

This file implements the charset functions for iso-8859-1 data

=over 4

=cut

*/

#include "parrot/parrot.h"
#include "iso-8859-1.h"
#include "ascii.h"

/* HEADERIZER HFILE: src/charset/iso-8859-1.h */

/* HEADERIZER BEGIN: static */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static STRING* compose(PARROT_INTERP, ARGIN(STRING *src))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_CANNOT_RETURN_NULL
static STRING* decompose(PARROT_INTERP, SHIM(STRING *src))
        __attribute__nonnull__(1);

static void downcase(PARROT_INTERP, ARGIN(STRING *source_string))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

static void downcase_first(PARROT_INTERP, ARGIN(STRING *source_string))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

static INTVAL find_cclass(PARROT_INTERP,
    INTVAL flags,
    ARGIN(STRING *source_string),
    UINTVAL offset,
    UINTVAL count)
        __attribute__nonnull__(1)
        __attribute__nonnull__(3);

static INTVAL find_not_cclass(PARROT_INTERP,
    INTVAL flags,
    ARGIN(STRING *source_string),
    UINTVAL offset,
    UINTVAL count)
        __attribute__nonnull__(1)
        __attribute__nonnull__(3);

static INTVAL is_cclass(PARROT_INTERP,
    INTVAL flags,
    ARGIN(const STRING *source_string),
    UINTVAL offset)
        __attribute__nonnull__(1)
        __attribute__nonnull__(3);

static void set_graphemes(PARROT_INTERP,
    ARGIN(STRING *source_string),
    UINTVAL offset,
    UINTVAL replace_count,
    ARGMOD(STRING *insert_string))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(5)
        FUNC_MODIFIES(*insert_string);

PARROT_CANNOT_RETURN_NULL
static STRING * string_from_codepoint(PARROT_INTERP, UINTVAL codepoint)
        __attribute__nonnull__(1);

static void titlecase(PARROT_INTERP, ARGIN(STRING *source_string))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

static void titlecase_first(PARROT_INTERP, ARGIN(STRING *source_string))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static STRING * to_charset(PARROT_INTERP,
    ARGIN(STRING *src),
    ARGIN_NULLOK(STRING *dest))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_CANNOT_RETURN_NULL
static STRING * to_latin1(PARROT_INTERP,
    ARGIN(STRING *src),
    ARGMOD_NULLOK(STRING *dest))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_CANNOT_RETURN_NULL
static STRING * to_unicode(PARROT_INTERP,
    ARGIN(STRING *src),
    ARGMOD_NULLOK(STRING *dest))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

static void upcase(PARROT_INTERP, ARGIN(STRING *source_string))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

static void upcase_first(PARROT_INTERP, ARGIN(STRING *source_string))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

static UINTVAL validate(PARROT_INTERP, ARGIN(STRING *src))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: static */

#include "tables.h"

/*

=item C<static void set_graphemes>

RT#48260: Not yet documented!!!

=cut

*/

static void
set_graphemes(PARROT_INTERP, ARGIN(STRING *source_string),
        UINTVAL offset, UINTVAL replace_count, ARGMOD(STRING *insert_string))
{
    ENCODING_SET_BYTES(interp, source_string, offset,
            replace_count, insert_string);
}

/*

=item C<static STRING * to_latin1>

RT#48260: Not yet documented!!!

=cut

*/

PARROT_CANNOT_RETURN_NULL
static STRING *
to_latin1(PARROT_INTERP, ARGIN(STRING *src), ARGMOD_NULLOK(STRING *dest))
{
    UINTVAL offs, src_len;
    String_iter iter;

    ENCODING_ITER_INIT(interp, src, &iter);
    src_len = src->strlen;
    if (dest) {
        Parrot_reallocate_string(interp, dest, src_len);
        dest->strlen  = src_len;
    }
    else {
        /* latin1 is never bigger then source */
        dest = src;
    }
    dest->bufused = src_len;
    dest->charset = Parrot_iso_8859_1_charset_ptr;
    dest->encoding = Parrot_fixed_8_encoding_ptr;
    for (offs = 0; offs < src_len; ++offs) {
        const UINTVAL c = iter.get_and_advance(interp, &iter);
        if (c >= 0x100)
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_LOSSY_CONVERSION,
                "lossy conversion to ascii");

        ENCODING_SET_BYTE(interp, dest, offs, c);
    }
    return dest;
}

/*

=item C<static STRING * to_unicode>

RT#48260: Not yet documented!!!

=cut

*/

PARROT_CANNOT_RETURN_NULL
static STRING *
to_unicode(PARROT_INTERP, ARGIN(STRING *src), ARGMOD_NULLOK(STRING *dest))
{
    if (dest) {
        UINTVAL offs;
        String_iter iter;

        dest->charset = Parrot_unicode_charset_ptr;
        dest->encoding = CHARSET_GET_PREFERRED_ENCODING(interp, dest);
        Parrot_reallocate_string(interp, dest, src->strlen);
        ENCODING_ITER_INIT(interp, dest, &iter);
        for (offs = 0; offs < src->strlen; ++offs) {
            const UINTVAL c = ENCODING_GET_BYTE(interp, src, offs);

            if (iter.bytepos >= PObj_buflen(dest) - 4) {
                UINTVAL need = (UINTVAL)((src->strlen - offs) * 1.5);
                if (need < 16)
                    need = 16;
                Parrot_reallocate_string(interp, dest,
                        PObj_buflen(dest) + need);
            }
            iter.set_and_advance(interp, &iter, c);
        }
        dest->bufused = iter.bytepos;
        dest->strlen  = iter.charpos;
        return dest;
    }
    Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_UNIMPLEMENTED,
            "to_unicode inplace for iso-8859-1 not implemented");
}

/*

=item C<static STRING * to_charset>

RT#48260: Not yet documented!!!

=cut

*/

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static STRING *
to_charset(PARROT_INTERP, ARGIN(STRING *src), ARGIN_NULLOK(STRING *dest))
{
    const charset_converter_t conversion_func =
        Parrot_find_charset_converter(interp, src->charset, Parrot_iso_8859_1_charset_ptr);

    if (conversion_func)
        return conversion_func(interp, src, dest);
    else
        return to_latin1(interp, src, dest);
}


/*

=item C<static STRING* compose>

RT#48260: Not yet documented!!!

=cut

*/

/* A noop. can't compose iso-8859-1 */
PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static STRING*
compose(PARROT_INTERP, ARGIN(STRING *src))
{
    return string_copy(interp, src);
}

/*

=item C<static STRING* decompose>

RT#48260: Not yet documented!!!

=cut

*/

PARROT_CANNOT_RETURN_NULL
static STRING*
decompose(PARROT_INTERP, SHIM(STRING *src))
{
    Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_UNIMPLEMENTED,
            "decompose for iso-8859-1 not implemented");
}

/*

=item C<static void upcase>

RT#48260: Not yet documented!!!

=cut

*/

static void
upcase(PARROT_INTERP, ARGIN(STRING *source_string))
{
    unsigned char *buffer;
    UINTVAL offset = 0;

    if (!source_string->strlen)
        return;

    Parrot_unmake_COW(interp, source_string);
    buffer = (unsigned char *)source_string->strstart;
    for (offset = 0; offset < source_string->strlen; offset++) {
        unsigned int c = buffer[offset]; /* XXX use encoding ? */
        if (c >= 0xe0 && c != 0xf7)
            c &= ~0x20;
        else
            c = toupper((unsigned char)c);
        buffer[offset] = (unsigned char)c;
    }
}

/*

=item C<static void downcase>

RT#48260: Not yet documented!!!

=cut

*/

static void
downcase(PARROT_INTERP, ARGIN(STRING *source_string))
{
    if (source_string->strlen) {
        UINTVAL offset;
        unsigned char *buffer;

        Parrot_unmake_COW(interp, source_string);
        buffer = (unsigned char *)source_string->strstart;
        for (offset = 0; offset < source_string->strlen; offset++) {
            unsigned int c = buffer[offset];
            if (c >= 0xc0 && c != 0xd7 && c <= 0xde)
                c |= 0x20;
            else
                c = tolower((unsigned char)c);
            buffer[offset] = (unsigned char)c;
        }
    }
}

/*

=item C<static void titlecase>

RT#48260: Not yet documented!!!

=cut

*/

static void
titlecase(PARROT_INTERP, ARGIN(STRING *source_string))
{
    unsigned char *buffer;
    unsigned int c;
    UINTVAL offset;

    if (!source_string->strlen)
        return;

    Parrot_unmake_COW(interp, source_string);
    buffer = (unsigned char *)source_string->strstart;
    c = buffer[0];
    if (c >= 0xe0 && c != 0xf7)
        c &= ~0x20;
    else
        c = toupper((unsigned char)c);
    buffer[0] = (unsigned char)c;

    for (offset = 1; offset < source_string->strlen; offset++) {
        c = buffer[offset];
        if (c >= 0xc0 && c != 0xd7 && c <= 0xde)
            c |= 0x20;
        else
            c = tolower((unsigned char)c);
        buffer[offset] = (unsigned char)c;
    }
}

/*

=item C<static void upcase_first>

RT#48260: Not yet documented!!!

=cut

*/

static void
upcase_first(PARROT_INTERP, ARGIN(STRING *source_string))
{
    if (source_string->strlen) {
        unsigned char *buffer;
        unsigned int c;

        Parrot_unmake_COW(interp, source_string);
        buffer = (unsigned char *)source_string->strstart;
        c = buffer[0];
        if (c >= 0xe0 && c != 0xf7)
            c &= ~0x20;
        else
            c = toupper((unsigned char)c);
        buffer[0] = (unsigned char)c;
    }
}

/*

=item C<static void downcase_first>

RT#48260: Not yet documented!!!

=cut

*/

static void
downcase_first(PARROT_INTERP, ARGIN(STRING *source_string))
{
    if (source_string->strlen) {
        unsigned char *buffer;
        unsigned int c;

        Parrot_unmake_COW(interp, source_string);
        buffer = (unsigned char *)source_string->strstart;
        c = buffer[0];
        if (c >= 0xc0 && c != 0xd7 && c <= 0xde)
            c &= ~0x20;
        else
            c = tolower((unsigned char)c);
        buffer[0] = (unsigned char)c;
    }
}

/*

=item C<static void titlecase_first>

RT#48260: Not yet documented!!!

=cut

*/

static void
titlecase_first(PARROT_INTERP, ARGIN(STRING *source_string))
{
    upcase_first(interp, source_string);
}


/*

=item C<static UINTVAL validate>

RT#48260: Not yet documented!!!

=cut

*/

static UINTVAL
validate(PARROT_INTERP, ARGIN(STRING *src))
{
    UINTVAL offset;

    for (offset = 0; offset < string_length(interp, src); ++offset) {
        const UINTVAL codepoint = ENCODING_GET_CODEPOINT(interp, src, offset);
        if (codepoint >= 0x100)
            return 0;
    }
    return 1;
}

/*

=item C<static INTVAL is_cclass>

RT#48260: Not yet documented!!!

=cut

*/

static INTVAL
is_cclass(PARROT_INTERP, INTVAL flags,
          ARGIN(const STRING *source_string), UINTVAL offset)
{
    UINTVAL codepoint;

    if (offset >= source_string->strlen) return 0;
    codepoint = ENCODING_GET_CODEPOINT(interp, source_string, offset);

    if (codepoint >= sizeof (Parrot_ascii_typetable) /
                     sizeof (Parrot_ascii_typetable[0])) {
        return 0;
    }
    return (Parrot_iso_8859_1_typetable[codepoint] & flags) ? 1 : 0;
}

/*

=item C<static INTVAL find_cclass>

RT#48260: Not yet documented!!!

=cut

*/

static INTVAL
find_cclass(PARROT_INTERP, INTVAL flags,
            ARGIN(STRING *source_string), UINTVAL offset, UINTVAL count)
{
    UINTVAL pos = offset;
    UINTVAL end = offset + count;
    UINTVAL codepoint;

    PARROT_ASSERT(source_string != 0);
    end = source_string->strlen < end ? source_string->strlen : end;
    for (; pos < end; ++pos) {
        codepoint = ENCODING_GET_CODEPOINT(interp, source_string, pos);
        if ((Parrot_iso_8859_1_typetable[codepoint] & flags) != 0) {
            return pos;
        }
    }
    return end;
}

/*

=item C<static INTVAL find_not_cclass>

RT#48260: Not yet documented!!!

=cut

*/

static INTVAL
find_not_cclass(PARROT_INTERP, INTVAL flags,
                ARGIN(STRING *source_string), UINTVAL offset, UINTVAL count)
{
    UINTVAL pos = offset;
    UINTVAL end = offset + count;

    PARROT_ASSERT(source_string);
    end = source_string->strlen < end ? source_string->strlen : end;
    for (; pos < end; ++pos) {
        const UINTVAL codepoint = ENCODING_GET_CODEPOINT(interp, source_string, pos);
        if ((Parrot_iso_8859_1_typetable[codepoint] & flags) == 0) {
            return pos;
        }
    }
    return end;
}


/*

=item C<static STRING * string_from_codepoint>

RT#48260: Not yet documented!!!

=cut

*/

PARROT_CANNOT_RETURN_NULL
static STRING *
string_from_codepoint(PARROT_INTERP, UINTVAL codepoint)
{
    char real_codepoint = (char)codepoint;
    STRING * const return_string = string_make(interp, &real_codepoint, 1,
            "iso-8859-1", 0);
    return return_string;
}

/*

=item C<const CHARSET * Parrot_charset_iso_8859_1_init>

RT#48260: Not yet documented!!!

=cut

*/

PARROT_CANNOT_RETURN_NULL
const CHARSET *
Parrot_charset_iso_8859_1_init(PARROT_INTERP)
{
    CHARSET * const return_set = Parrot_new_charset(interp);
    static const CHARSET base_set = {
        "iso-8859-1",
        ascii_get_graphemes,
        ascii_get_graphemes_inplace,
        set_graphemes,
        to_charset,
        compose,
        decompose,
        upcase,
        downcase,
        titlecase,
        upcase_first,
        downcase_first,
        titlecase_first,
        ascii_compare,
        ascii_cs_index,
        ascii_cs_rindex,
        validate,
        is_cclass,
        find_cclass,
        find_not_cclass,
        string_from_codepoint,
        ascii_compute_hash,
        NULL
    };

    STRUCT_COPY_FROM_STRUCT(return_set, base_set);
    return_set->preferred_encoding = Parrot_fixed_8_encoding_ptr;
    Parrot_register_charset(interp, "iso-8859-1", return_set);
    return return_set;
}

/*

=item C<STRING * charset_cvt_iso_8859_1_to_ascii>

RT#48260: Not yet documented!!!

=cut

*/

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
STRING *
charset_cvt_iso_8859_1_to_ascii(PARROT_INTERP, ARGIN(STRING *src),
        ARGMOD_NULLOK(STRING *dest))
{
    UINTVAL offs;
    if (dest) {
        Parrot_reallocate_string(interp, dest, src->strlen);
        dest->bufused = src->bufused;
        dest->strlen  = src->strlen;
    }
    for (offs = 0; offs < src->strlen; ++offs) {
        UINTVAL c = ENCODING_GET_BYTE(interp, src, offs);
        if (c >= 0x80)
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_LOSSY_CONVERSION,
                "lossy conversion to ascii");

        if (dest)
            ENCODING_SET_BYTE(interp, dest, offs, c);
    }
    if (dest)
        return dest;
    src->charset = Parrot_ascii_charset_ptr;
    return src;
}

/*

=back

=cut

*/


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
