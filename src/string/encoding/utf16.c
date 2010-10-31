/*
Copyright (C) 2001-2010, Parrot Foundation.
$Id$

=head1 NAME

src/string/encoding/utf16.c - UTF-16 encoding

=head1 DESCRIPTION

UTF-16 encoding

=head2 Functions

=over 4

=cut

*/

#include "parrot/parrot.h"
#include "../unicode.h"
#include "shared.h"

/* HEADERIZER HFILE: none */

/* HEADERIZER BEGIN: static */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

PARROT_WARN_UNUSED_RESULT
static UINTVAL utf16_decode(PARROT_INTERP, ARGIN(const utf16_t *p))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static utf16_t * utf16_encode(PARROT_INTERP,
    ARGMOD(utf16_t *ptr),
    UINTVAL c)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*ptr);

static UINTVAL utf16_iter_get(PARROT_INTERP,
    ARGIN(const STRING *str),
    ARGIN(const String_iter *i),
    INTVAL offset)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_WARN_UNUSED_RESULT
static UINTVAL utf16_iter_get_and_advance(PARROT_INTERP,
    ARGIN(const STRING *str),
    ARGMOD(String_iter *i))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*i);

static void utf16_iter_set_and_advance(PARROT_INTERP,
    ARGMOD(STRING *str),
    ARGMOD(String_iter *i),
    UINTVAL c)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*str)
        FUNC_MODIFIES(*i);

static void utf16_iter_set_position(PARROT_INTERP,
    ARGIN(const STRING *str),
    ARGMOD(String_iter *i),
    UINTVAL pos)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*i);

static void utf16_iter_skip(PARROT_INTERP,
    ARGIN(const STRING *str),
    ARGMOD(String_iter *i),
    INTVAL skip)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*i);

static UINTVAL utf16_ord(PARROT_INTERP,
    ARGIN(const STRING *src),
    INTVAL idx)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_WARN_UNUSED_RESULT
static UINTVAL utf16_scan(PARROT_INTERP, ARGIN(const STRING *src))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static const utf16_t * utf16_skip_backward(
    ARGIN(const utf16_t *p),
    UINTVAL count)
        __attribute__nonnull__(1);

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static const utf16_t * utf16_skip_forward(
    ARGIN(const utf16_t *p),
    UINTVAL count)
        __attribute__nonnull__(1);

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static STRING * utf16_to_encoding(PARROT_INTERP, ARGIN(const STRING *src))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

#define ASSERT_ARGS_utf16_decode __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(p))
#define ASSERT_ARGS_utf16_encode __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(ptr))
#define ASSERT_ARGS_utf16_iter_get __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(str) \
    , PARROT_ASSERT_ARG(i))
#define ASSERT_ARGS_utf16_iter_get_and_advance __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(str) \
    , PARROT_ASSERT_ARG(i))
#define ASSERT_ARGS_utf16_iter_set_and_advance __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(str) \
    , PARROT_ASSERT_ARG(i))
#define ASSERT_ARGS_utf16_iter_set_position __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(str) \
    , PARROT_ASSERT_ARG(i))
#define ASSERT_ARGS_utf16_iter_skip __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(str) \
    , PARROT_ASSERT_ARG(i))
#define ASSERT_ARGS_utf16_ord __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(src))
#define ASSERT_ARGS_utf16_scan __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(src))
#define ASSERT_ARGS_utf16_skip_backward __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(p))
#define ASSERT_ARGS_utf16_skip_forward __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(p))
#define ASSERT_ARGS_utf16_to_encoding __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(src))
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: static */


/*

=item C<static STRING * utf16_to_encoding(PARROT_INTERP, const STRING *src)>

Converts the string C<src> to this particular encoding.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static STRING *
utf16_to_encoding(PARROT_INTERP, ARGIN(const STRING *src))
{
    ASSERT_ARGS(utf16_to_encoding)
    STRING  *result;
    UINTVAL  src_len;

    src_len = STRING_length(src);

    if (STRING_max_bytes_per_codepoint(src) == 1) {
        result           = Parrot_gc_new_string_header(interp, 0);
        result->encoding = Parrot_ucs2_encoding_ptr;
        result->bufused  = 2 * src_len;
        result->strlen   = src_len;

        if (src_len) {
            UINTVAL       i;
            Parrot_UInt2 *p;

            Parrot_gc_allocate_string_storage(interp, result, 2 * src_len);
            p = (Parrot_UInt2 *)result->strstart;

            for (i = 0; i < src_len; ++i) {
                p[i] = (unsigned char)src->strstart[i];
            }
        }
    }
    else if (src->encoding == Parrot_utf16_encoding_ptr
         ||  src->encoding == Parrot_ucs2_encoding_ptr) {
        /* we have to use clone instead of copy because the Unicode upcase
         * and downcase functions assume to get an unshared buffer */
        result = Parrot_str_clone(interp, src);
    }
    else {
        result = encoding_to_encoding(interp, src, Parrot_utf16_encoding_ptr, 2.2);

        /* downgrade if possible */
        if (result->bufused == result->strlen << 1)
            result->encoding = Parrot_ucs2_encoding_ptr;
    }

    return result;
}


/*

=item C<static UINTVAL utf16_scan(PARROT_INTERP, const STRING *src)>

Returns the number of codepoints in string C<src> by scanning the whole
string.

=cut

*/

PARROT_WARN_UNUSED_RESULT
static UINTVAL
utf16_scan(PARROT_INTERP, ARGIN(const STRING *src))
{
    ASSERT_ARGS(utf16_scan)
    const utf16_t *p   = (utf16_t *)src->strstart;
    UINTVAL        len = 0;
    UINTVAL        i, n;

    if (src->bufused & 1)
        Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_MALFORMED_UTF16,
            "Unaligned end in UTF-16 string\n");

    n = src->bufused >> 1;

    for (i = 0; i < n; ++i) {
        UINTVAL c = p[i];

        if (UNICODE_IS_HIGH_SURROGATE(c)) {
            ++i;

            if (i >= n)
                Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_MALFORMED_UTF16,
                    "Unaligned end in UTF-16 string\n");

            if (!UNICODE_IS_LOW_SURROGATE(p[i]))
                Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_MALFORMED_UTF16,
                    "Malformed UTF-16 string\n");

            c = UNICODE_DECODE_SURROGATE(c, p[i]);
        }
        else {
            if (UNICODE_IS_LOW_SURROGATE(c))
                Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_MALFORMED_UTF16,
                    "Malformed UTF-16 string\n");
        }

        if (UNICODE_IS_NON_CHARACTER(c))
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_MALFORMED_UTF16,
                "Non-character in UTF-16 string\n");

        ++len;
    }

    return len;
}


/*

=item C<static const utf16_t * utf16_skip_forward(const utf16_t *p, UINTVAL
count)>

Skips C<count> codepoints starting from C<p>. Returns the new pointer.

=cut

*/

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static const utf16_t *
utf16_skip_forward(ARGIN(const utf16_t *p), UINTVAL count)
{
    ASSERT_ARGS(utf16_skip_forward)
    UINTVAL i;

    for (i = 0; i < count; ++i) {
        if (UNICODE_IS_HIGH_SURROGATE(*p))
            p += 2;
        else
            p += 1;
    }

    return p;
}


/*

=item C<static const utf16_t * utf16_skip_backward(const utf16_t *p, UINTVAL
count)>

Skips C<count> codepoints backwards starting from C<p>. Returns the new
pointer.

=cut

*/

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static const utf16_t *
utf16_skip_backward(ARGIN(const utf16_t *p), UINTVAL count)
{
    ASSERT_ARGS(utf16_skip_backward)
    UINTVAL i;

    for (i = 0; i < count; ++i) {
        --p;
        if (UNICODE_IS_LOW_SURROGATE(*p))
            --p;
    }

    return p;
}


/*

=item C<static UINTVAL utf16_decode(PARROT_INTERP, const utf16_t *p)>

Decodes the codepoint starting at C<p>.

=cut

*/

PARROT_WARN_UNUSED_RESULT
static UINTVAL
utf16_decode(PARROT_INTERP, ARGIN(const utf16_t *p))
{
    UINTVAL c = *p;

    if (UNICODE_IS_HIGH_SURROGATE(c))
        c = UNICODE_DECODE_SURROGATE(c, p[1]);

    return c;
}


/*

=item C<static utf16_t * utf16_encode(PARROT_INTERP, utf16_t *ptr, UINTVAL c)>

Decodes the codepoint starting at C<p>.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static utf16_t *
utf16_encode(PARROT_INTERP, ARGMOD(utf16_t *ptr), UINTVAL c)
{
    ASSERT_ARGS(utf16_encode)

    if (c < 0xFFFE) {
        if (UNICODE_IS_SURROGATE(c)
        || (c >= 0xFDD0 && c <= 0xFDEF))
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_CHARACTER,
                    "Invalid character for UTF-16 encoding\n");

        *ptr++ = c;
    }
    else {
        if ((c & 0xFFFE) == 0xFFFE
        ||   c > 0x10FFFF)
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_CHARACTER,
                    "Invalid character for UTF-16 encoding\n");

        *ptr++ = UNICODE_HIGH_SURROGATE(c);
        *ptr++ = UNICODE_LOW_SURROGATE(c);
    }

    return ptr;
}


/*

=item C<static UINTVAL utf16_ord(PARROT_INTERP, const STRING *src, INTVAL idx)>

Returns the codepoint in string C<src> at position C<offset>.

=cut

*/

static UINTVAL
utf16_ord(PARROT_INTERP, ARGIN(const STRING *src), INTVAL idx)
{
    ASSERT_ARGS(utf16_ord)
    const UINTVAL  len = STRING_length(src);
    const utf16_t *start;

    if (idx < 0)
        idx += len;

    if ((UINTVAL)idx >= len)
        encoding_ord_error(interp, src, idx);

    start = utf16_skip_forward((const utf16_t *)src->strstart, idx);

    return utf16_decode(interp, start);
}


/*

=item C<static UINTVAL utf16_iter_get(PARROT_INTERP, const STRING *str, const
String_iter *i, INTVAL offset)>

Get the character at C<i> plus C<offset>.

=cut

*/

static UINTVAL
utf16_iter_get(PARROT_INTERP,
    ARGIN(const STRING *str), ARGIN(const String_iter *i), INTVAL offset)
{
    ASSERT_ARGS(utf16_iter_get)
    const utf16_t *ptr = (utf16_t *)(str->strstart + i->bytepos);

    PARROT_ASSERT((UINTVAL)(i->charpos + offset) <= str->strlen);

    if (offset > 0)
        ptr = utf16_skip_forward(ptr, offset);
    else if (offset < 0)
        ptr = utf16_skip_backward(ptr, -offset);

    return utf16_decode(interp, ptr);
}

/*

=item C<static void utf16_iter_skip(PARROT_INTERP, const STRING *str,
String_iter *i, INTVAL skip)>

Moves the string iterator C<i> by C<skip> characters.

=cut

*/

static void
utf16_iter_skip(PARROT_INTERP,
    ARGIN(const STRING *str), ARGMOD(String_iter *i), INTVAL skip)
{
    ASSERT_ARGS(utf16_iter_skip)
    const utf16_t *ptr = (utf16_t *)(str->strstart + i->bytepos);

    i->charpos += skip;

    PARROT_ASSERT(i->charpos <= str->strlen);

    if (skip > 0)
        ptr = utf16_skip_forward(ptr, skip);
    else if (skip < 0)
        ptr = utf16_skip_backward(ptr, -skip);

    i->bytepos = (const char *)ptr - (const char *)str->strstart;

    PARROT_ASSERT(i->bytepos <= str->bufused);
}

/*

=item C<static UINTVAL utf16_iter_get_and_advance(PARROT_INTERP, const STRING
*str, String_iter *i)>

Moves the string iterator C<i> to the next UTF-16 codepoint.

=cut

*/

PARROT_WARN_UNUSED_RESULT
static UINTVAL
utf16_iter_get_and_advance(PARROT_INTERP,
    ARGIN(const STRING *str), ARGMOD(String_iter *i))
{
    ASSERT_ARGS(utf16_iter_get_and_advance)
    const utf16_t *ptr = (utf16_t *)(str->strstart + i->bytepos);
    UINTVAL        c   = utf16_decode(interp, ptr);

    i->charpos += 1;

    if (UNICODE_IS_HIGH_SURROGATE(*ptr))
        i->bytepos += 4;
    else
        i->bytepos += 2;

    PARROT_ASSERT(i->bytepos <= str->bufused);

    return c;
}

/*

=item C<static void utf16_iter_set_and_advance(PARROT_INTERP, STRING *str,
String_iter *i, UINTVAL c)>

With the string iterator C<i>, appends the codepoint C<c> and advances to the
next position in the string.

=cut

*/

static void
utf16_iter_set_and_advance(PARROT_INTERP,
    ARGMOD(STRING *str), ARGMOD(String_iter *i), UINTVAL c)
{
    ASSERT_ARGS(utf16_iter_set_and_advance)
    utf16_t * const ptr = (utf16_t *)(str->strstart + i->bytepos);
    utf16_t * const end = utf16_encode(interp, ptr, c);

    i->charpos += 1;
    i->bytepos += (char *)end - (char *)ptr;

    PARROT_ASSERT(i->bytepos <= str->bufused);
}

/*

=item C<static void utf16_iter_set_position(PARROT_INTERP, const STRING *str,
String_iter *i, UINTVAL pos)>

Moves the string iterator C<i> to the position C<pos> in the string.

=cut

*/

static void
utf16_iter_set_position(PARROT_INTERP,
    ARGIN(const STRING *str), ARGMOD(String_iter *i), UINTVAL pos)
{
    ASSERT_ARGS(utf16_iter_set_position)
    const utf16_t *ptr;

    if (pos == 0) {
        i->charpos = 0;
        i->bytepos = 0;
        return;
    }

    PARROT_ASSERT(pos <= str->strlen);

    /*
     * we know the byte offsets of three positions: start, current and end
     * now find the shortest way to reach pos
     */
    if (pos < i->charpos) {
        if (pos <= (i->charpos >> 1)) {
            /* go forward from start */
            ptr = (utf16_t *)str->strstart;
            ptr = utf16_skip_forward(ptr, pos);
        }
        else {
            /* go backward from current */
            ptr = (utf16_t *)(str->strstart + i->bytepos);
            ptr = utf16_skip_backward(ptr, i->charpos - pos);
        }
    }
    else {
        const UINTVAL  len = str->strlen;
        if (pos <= i->charpos + ((len - i->charpos) >> 1)) {
            /* go forward from current */
            ptr = (utf16_t *)(str->strstart + i->bytepos);
            ptr = utf16_skip_forward(ptr, pos - i->charpos);
        }
        else {
            /* go backward from end */
            ptr = (utf16_t *)(str->strstart + str->bufused);
            ptr = utf16_skip_backward(ptr, len - pos);
        }
    }

    i->charpos = pos;
    i->bytepos = (const char *)ptr - (const char *)str->strstart;

    PARROT_ASSERT(i->bytepos <= str->bufused);
}


static STR_VTABLE Parrot_utf16_encoding = {
    0,
    "utf16",
    NULL,
    4, /* Max bytes per codepoint */

    utf16_to_encoding,
    unicode_chr,

    encoding_equal,
    encoding_compare,
    encoding_index,
    encoding_rindex,
    encoding_hash,

    utf16_scan,
    utf16_ord,
    encoding_substr,

    encoding_is_cclass,
    encoding_find_cclass,
    encoding_find_not_cclass,

    encoding_get_graphemes,
    unicode_compose,
    encoding_decompose,

    unicode_upcase,
    unicode_downcase,
    unicode_titlecase,
    unicode_upcase_first,
    unicode_downcase_first,
    unicode_titlecase_first,

    utf16_iter_get,
    utf16_iter_skip,
    utf16_iter_get_and_advance,
    utf16_iter_set_and_advance,
    utf16_iter_set_position
};

STR_VTABLE *Parrot_utf16_encoding_ptr = &Parrot_utf16_encoding;


/*

=back

=head1 SEE ALSO

F<src/string/encoding/fixed_8.c>,
F<src/string/encoding/utf8.c>,
F<src/string.c>,
F<include/parrot/string.h>,
F<docs/string.pod>.

=cut

*/


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
