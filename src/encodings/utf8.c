/*
Copyright (C) 2001-2007, The Perl Foundation.
$Id$

=head1 NAME

src/encodings/utf8.c - UTF-8 encoding

=head1 DESCRIPTION

UTF-8 (L<http://www.utf-8.com/>).

=head2 Functions

*/

#include "parrot/parrot.h"
#include "../unicode.h"
#include "utf8.h"

/* HEADERIZER HFILE: src/encodings/utf8.h */

/* HEADERIZER BEGIN: static */

static void become_encoding( Interp *interp, STRING *src );
static UINTVAL bytes( Interp *interp, STRING *src /*NN*/ )
        __attribute__nonnull__(2)
        __attribute__pure__
        __attribute__warn_unused_result__;

static UINTVAL codepoints( Interp *interp, STRING *src /*NN*/ )
        __attribute__nonnull__(2);

static UINTVAL get_byte( Interp *interp,
    const STRING *src /*NN*/,
    UINTVAL offset )
        __attribute__nonnull__(2);

static STRING * get_bytes( Interp *interp,
    STRING *src,
    UINTVAL offset,
    UINTVAL count );

static STRING * get_bytes_inplace( Interp *interp,
    STRING *src,
    UINTVAL offset,
    UINTVAL count,
    STRING *return_string );

static UINTVAL get_codepoint( Interp *interp,
    const STRING *src /*NN*/,
    UINTVAL offset )
        __attribute__nonnull__(2);

static STRING * get_codepoints( Interp *interp,
    STRING *src,
    UINTVAL offset,
    UINTVAL count );

static STRING * get_codepoints_inplace( Interp *interp,
    STRING *src,
    UINTVAL offset,
    UINTVAL count,
    STRING *return_string );

static void iter_init( Interp *interp,
    const STRING *src,
    String_iter *iter /*NN*/ )
        __attribute__nonnull__(3);

static void set_byte( Interp *interp /*NN*/,
    const STRING *src /*NN*/,
    UINTVAL offset,
    UINTVAL byte )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

static void set_bytes( Interp *interp,
    STRING *src,
    UINTVAL offset,
    UINTVAL count,
    STRING *new_bytes );

static void set_codepoint( Interp *interp,
    STRING *src /*NN*/,
    UINTVAL offset,
    UINTVAL codepoint )
        __attribute__nonnull__(2);

static void set_codepoints( Interp *interp,
    STRING *src,
    UINTVAL offset,
    UINTVAL count,
    STRING *new_codepoints );

static STRING * to_encoding( Interp *interp /*NN*/,
    STRING *src /*NN*/,
    STRING *dest )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

static UINTVAL utf8_characters( const utf8_t *ptr /*NN*/, UINTVAL byte_len )
        __attribute__nonnull__(1);

static UINTVAL utf8_decode( const utf8_t *ptr );
static UINTVAL utf8_decode_and_advance( Interp *interp /*NN*/,
    String_iter *i /*NN*/ )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

static void * utf8_encode( void *ptr /*NN*/, UINTVAL c )
        __attribute__nonnull__(1);

static void utf8_encode_and_advance( Interp *interp /*NN*/,
    String_iter *i /*NN*/,
    UINTVAL c )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

static void utf8_set_position( Interp *interp,
    String_iter *i /*NN*/,
    UINTVAL pos )
        __attribute__nonnull__(2);

static const void * utf8_skip_backward( const void *ptr /*NN*/, UINTVAL n )
        __attribute__nonnull__(1);

static const void * utf8_skip_forward( const void *ptr /*NN*/, UINTVAL n )
        __attribute__nonnull__(1);

/* HEADERIZER END: static */

#define UNIMPL real_exception(interp, NULL, UNIMPLEMENTED, "unimpl utf8")

const char Parrot_utf8skip[256] = {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     /* ascii */
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     /* ascii */
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     /* ascii */
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     /* ascii */
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     /* ascii */
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     /* ascii */
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     /* ascii */
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     /* ascii */
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     /* bogus */
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     /* bogus */
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     /* bogus */
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     /* bogus */
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,     /* scripts */
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,     /* scripts */
    3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,     /* cjk etc. */
    4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6      /* cjk etc. */
};

#if 0
typedef unsigned char utf8_t;
#endif

/*

FUNCDOC: utf8_characters

Returns the number of characters in the C<byte_len> bytes from C<*ptr>.

*/

static UINTVAL
utf8_characters(const utf8_t *ptr /*NN*/, UINTVAL byte_len)
{
    const utf8_t *u8ptr = ptr;
    const utf8_t *u8end = u8ptr + byte_len;
    UINTVAL characters = 0;

    while (u8ptr < u8end) {
        u8ptr += UTF8SKIP(u8ptr);
        characters++;
    }

    if (u8ptr > u8end) {
        internal_exception(MALFORMED_UTF8, "Unaligned end in UTF-8 string\n");
    }

    return characters;
}

/*

FUNCDOC: utf8_decode

Returns the integer for the UTF-8 character found at C<*ptr>.

*/

static UINTVAL
utf8_decode(const utf8_t *ptr)
{
    const utf8_t *u8ptr = ptr;
    UINTVAL c = *u8ptr;

    if (UTF8_IS_START(c)) {
        UINTVAL len = UTF8SKIP(u8ptr);
        UINTVAL count;

        c &= UTF8_START_MASK(len);
        for (count = 1; count < len; count++) {
            u8ptr++;
            if (!UTF8_IS_CONTINUATION(*u8ptr)) {
                internal_exception(MALFORMED_UTF8, "Malformed UTF-8 string\n");
            }
            c = UTF8_ACCUMULATE(c, *u8ptr);
        }

        if (UNICODE_IS_SURROGATE(c)) {
            internal_exception(MALFORMED_UTF8, "Surrogate in UTF-8 string\n");
        }
    }
    else if (!UNICODE_IS_INVARIANT(c)) {
        internal_exception(MALFORMED_UTF8, "Malformed UTF-8 string\n");
    }

    return c;
}

/*

FUNCDOC: utf8_encode

Returns the UTF-8 encoding of integer C<c>.

*/

static void *
utf8_encode(void *ptr /*NN*/, UINTVAL c)
{
    utf8_t *u8ptr = (utf8_t *)ptr;
    UINTVAL len = UNISKIP(c);
    utf8_t *u8end = u8ptr + len - 1;

    if (c > 0x10FFFF || UNICODE_IS_SURROGATE(c)) {
        internal_exception(INVALID_CHARACTER,
                           "Invalid character for UTF-8 encoding\n");
    }

    while (u8end > u8ptr) {
        *u8end-- =
            (utf8_t)((c & UTF8_CONTINUATION_MASK) | UTF8_CONTINUATION_MARK);
        c >>= UTF8_ACCUMULATION_SHIFT;
    }
    *u8end = (utf8_t)((c & UTF8_START_MASK(len)) | UTF8_START_MARK(len));

    return u8ptr + len;
}

/*

FUNCDOC: utf8_skip_forward

Moves C<ptr> C<n> characters forward.

*/

static const void *
utf8_skip_forward(const void *ptr /*NN*/, UINTVAL n)
{
    const utf8_t *u8ptr = (const utf8_t *)ptr;

    while (n-- > 0) {
        u8ptr += UTF8SKIP(u8ptr);
    }

    return u8ptr;
}

/*

FUNCDOC: utf8_skip_backward

Moves C<ptr> C<n> characters back.

*/

static const void *
utf8_skip_backward(const void *ptr /*NN*/, UINTVAL n)
{
    const utf8_t *u8ptr = (const utf8_t *)ptr;

    while (n-- > 0) {
        u8ptr--;
        while (UTF8_IS_CONTINUATION(*u8ptr))
            u8ptr--;
    }

    return u8ptr;
}

/*

=head2 Iterator Functions

FUNCDOC: utf8_decode_and_advance

The UTF-8 implementation of the string iterator's C<get_and_advance>
function.

FUNCDOC: utf8_encode_and_advance

The UTF-8 implementation of the string iterator's C<set_and_advance>
function.

*/

static UINTVAL
utf8_decode_and_advance(Interp *interp /*NN*/, String_iter *i /*NN*/)
{
    const utf8_t *u8ptr = (utf8_t *)((char *)i->str->strstart + i->bytepos);
    UINTVAL c = *u8ptr;

    if (UTF8_IS_START(c)) {
        UINTVAL len = UTF8SKIP(u8ptr);

        c &= UTF8_START_MASK(len);
        i->bytepos += len;
        for (len--; len; len--) {
            u8ptr++;
            if (!UTF8_IS_CONTINUATION(*u8ptr)) {
                real_exception(interp, NULL, MALFORMED_UTF8, "Malformed UTF-8 string\n");
            }
            c = UTF8_ACCUMULATE(c, *u8ptr);
        }

        if (UNICODE_IS_SURROGATE(c)) {
            real_exception(interp, NULL, MALFORMED_UTF8, "Surrogate in UTF-8 string\n");
        }
    }
    else if (!UNICODE_IS_INVARIANT(c)) {
        real_exception(interp, NULL, MALFORMED_UTF8, "Malformed UTF-8 string\n");
    }
    else {
        i->bytepos++;
    }

    i->charpos++;
    return c;
}

static void
utf8_encode_and_advance(Interp *interp /*NN*/, String_iter *i /*NN*/, UINTVAL c)
{
    const STRING * const s = i->str;
    unsigned char * const pos = (unsigned char *)s->strstart + i->bytepos;
    unsigned char * const new_pos = (unsigned char *)utf8_encode(pos, c);

    i->bytepos += (new_pos - pos);
    /* XXX possible buffer overrun exception? */
    assert(i->bytepos <= PObj_buflen(s));
    i->charpos++;
}

/*

FUNCDOC: utf8_set_position

The UTF-8 implementation of the string iterator's C<set_position>
function.

*/

/* XXX Should use quickest direction */
static void
utf8_set_position(SHIM_INTERP, String_iter *i /*NN*/, UINTVAL pos)
{
    const utf8_t *u8ptr = (const utf8_t *)i->str->strstart;

    i->charpos = pos;
    while (pos-- > 0) {
        u8ptr += UTF8SKIP(u8ptr);
    }
    i->bytepos = (const char *)u8ptr - (const char *)i->str->strstart;
}


static STRING *
to_encoding(Interp *interp /*NN*/, STRING *src /*NN*/, STRING *dest)
{
    STRING *result;
    String_iter src_iter;
    UINTVAL offs, c, dest_len, dest_pos, src_len;
    int in_place = dest == NULL;
    unsigned char *new_pos, *pos, *p;

    if (src->encoding == Parrot_utf8_encoding_ptr)
        return in_place ? src : string_copy(interp, src);
    src_len = src->strlen;
    if (in_place) {
        result = src;
    }
    else {
        result = dest;
    }

    /* init iter before possilby changing encoding */
    ENCODING_ITER_INIT(interp, src, &src_iter);
    result->charset  = Parrot_unicode_charset_ptr;
    result->encoding = Parrot_utf8_encoding_ptr;
    result->strlen   = src_len;

    if (!src->strlen)
        return dest;

    if (in_place) {
        /* need intermediate memory */
        p = (unsigned char *)mem_sys_allocate(src_len);
    }
    else {
        Parrot_reallocate_string(interp, dest, src_len);
        p = (unsigned char *)dest->strstart;
    }
    if (src->charset == Parrot_ascii_charset_ptr) {
        for (dest_len = 0; dest_len < src_len; ++dest_len) {
            p[dest_len] = ((unsigned char*)src->strstart)[dest_len];
        }
        result->bufused = dest_len;
    }
    else {
        dest_len = src_len;
        dest_pos = 0;
        for (offs = 0; offs < src_len; ++offs) {
            c = src_iter.get_and_advance(interp, &src_iter);
            if (dest_len - dest_pos < 6) {
                UINTVAL need = (UINTVAL)((src->strlen - offs) * 1.5);
                if (need < 16)
                    need = 16;
                dest_len += need;
                if (in_place)
                    p = (unsigned char *)mem_sys_realloc(p, dest_len);
                else {
                    result->bufused = dest_pos;
                    Parrot_reallocate_string(interp, dest, dest_len);
                    p = (unsigned char *)dest->strstart;
                }
            }

            pos = p + dest_pos;
            new_pos = (unsigned char *)utf8_encode(pos, c);
            dest_pos += (new_pos - pos);
        }
        result->bufused = dest_pos;
    }
    if (in_place) {
        Parrot_reallocate_string(interp, src, src->bufused);
        memcpy(src->strstart, p, src->bufused);
        mem_sys_free(p);
    }
    return result;
}

static UINTVAL
get_codepoint(SHIM_INTERP, const STRING *src /*NN*/, UINTVAL offset)
{
    const utf8_t * const start = (const utf8_t *)utf8_skip_forward(src->strstart, offset);
    return utf8_decode(start);
}

static void
set_codepoint(SHIM_INTERP, STRING *src /*NN*/,
        UINTVAL offset, UINTVAL codepoint)
{
    const void *start;
    void *p;
    DECL_CONST_CAST;

    start = utf8_skip_forward(src->strstart, offset);
    p = const_cast(start);
    utf8_encode(p, codepoint);
}

static UINTVAL
get_byte(SHIM_INTERP, const STRING *src /*NN*/, UINTVAL offset)
{
    unsigned char *contents = (unsigned char *)src->strstart;
    if (offset >= src->bufused) {
/*        real_exception(interp, NULL, 0,
                "get_byte past the end of the buffer (%i of %i)",
                offset, src->bufused);*/
        return 0;
    }
    return contents[offset];
}

static void
set_byte(Interp *interp /*NN*/, const STRING *src /*NN*/,
        UINTVAL offset, UINTVAL byte)
{
    unsigned char *contents;
    if (offset >= src->bufused) {
        real_exception(interp, NULL, 0, "set_byte past the end of the buffer");
    }
    contents = (unsigned char *)src->strstart;
    contents[offset] = (unsigned char)byte;
}

static STRING *
get_codepoints(Interp *interp, STRING *src,
        UINTVAL offset, UINTVAL count)
{
    String_iter iter;
    UINTVAL start;
    STRING * const return_string = Parrot_make_COW_reference(interp, src);
    iter_init(interp, src, &iter);
    iter.set_position(interp, &iter, offset);
    start = iter.bytepos;
    return_string->strstart = (char *)return_string->strstart + start ;
    iter.set_position(interp, &iter, offset + count);
    return_string->bufused = iter.bytepos - start;
    return_string->strlen = count;
    return_string->hashval = 0;
    return return_string;
}

static STRING *
get_bytes(Interp *interp, STRING *src,
        UINTVAL offset, UINTVAL count)
{
    STRING *return_string = Parrot_make_COW_reference(interp,
            src);
    return_string->encoding = src->encoding;    /* XXX */
    return_string->charset = src->charset;

    return_string->strstart = (char *)return_string->strstart + offset ;
    return_string->bufused = count;

    return_string->strlen = count;
    return_string->hashval = 0;

    return return_string;
}


static STRING *
get_codepoints_inplace(Interp *interp, STRING *src,
        UINTVAL offset, UINTVAL count, STRING *return_string)
{
    String_iter iter;
    UINTVAL start;
    Parrot_reuse_COW_reference(interp, src, return_string);
    iter_init(interp, src, &iter);
    iter.set_position(interp, &iter, offset);
    start = iter.bytepos;
    return_string->strstart = (char *)return_string->strstart + start ;
    iter.set_position(interp, &iter, offset + count);
    return_string->bufused = iter.bytepos - start;
    return_string->strlen = count;
    return_string->hashval = 0;
    return return_string;
}

static STRING *
get_bytes_inplace(Interp *interp, STRING *src,
        UINTVAL offset, UINTVAL count, STRING *return_string)
{
    UNIMPL;
    UNUSED(interp);
    UNUSED(src);
    UNUSED(return_string);
    return NULL;
}

static void
set_codepoints(Interp *interp, STRING *src,
        UINTVAL offset, UINTVAL count, STRING *new_codepoints)
{
    UNUSED(interp);
    UNUSED(src);
    UNUSED(new_codepoints);
    UNIMPL;
}

static void
set_bytes(Interp *interp, STRING *src,
        UINTVAL offset, UINTVAL count, STRING *new_bytes)
{
    UNUSED(interp);
    UNUSED(src);
    UNUSED(new_bytes);
    UNIMPL;
}

/* Unconditionally makes the string be in this encoding, if that's
   valid */
static void
become_encoding(Interp *interp, STRING *src)
{
    UNUSED(interp);
    UNUSED(src);
    UNIMPL;
}


static UINTVAL
codepoints(Interp *interp, STRING *src /*NN*/)
{
    String_iter iter;
    /*
     * this is used to initially calculate src->strlen,
     * therefore we must scan the whole string
     */
    iter_init(interp, src, &iter);
    while (iter.bytepos < src->bufused)
        iter.get_and_advance(interp, &iter);
    return iter.charpos;
}

static UINTVAL
bytes(SHIM_INTERP, STRING *src /*NN*/)
    /* PURE, WARN_UNUSED */
{
    return src->bufused;
}

static void
iter_init(SHIM_INTERP, const STRING *src, String_iter *iter /*NN*/)
{
    iter->str = src;
    iter->bytepos = iter->charpos = 0;
    iter->get_and_advance = utf8_decode_and_advance;
    iter->set_and_advance = utf8_encode_and_advance;
    iter->set_position =    utf8_set_position;
}

ENCODING *
Parrot_encoding_utf8_init(Interp *interp /*NN*/)
{
    ENCODING * const return_encoding = Parrot_new_encoding(interp);

    static const ENCODING base_encoding = {
        "utf8",
        4, /* Max bytes per codepoint 0 .. 0x10ffff */
        to_encoding,
        get_codepoint,
        set_codepoint,
        get_byte,
        set_byte,
        get_codepoints,
        get_codepoints_inplace,
        get_bytes,
        get_bytes_inplace,
        set_codepoints,
        set_bytes,
        become_encoding,
        codepoints,
        bytes,
        iter_init
    };
    STRUCT_COPY(return_encoding, &base_encoding);
    Parrot_register_encoding(interp, "utf8", return_encoding);
    return return_encoding;
}

/*

=head1 SEE ALSO

F<src/encodings/fixed_8.c>,
F<src/string.c>,
F<include/parrot/string.h>,
F<docs/string.pod>.

*/


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
