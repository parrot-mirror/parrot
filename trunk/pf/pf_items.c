/* pf_items.c
 *  Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
 *  CVS Info
 *     $Id$
 *  Overview:
 *     Low level packfile functions to fetch and store Parrot data, i.e.
 *     INTVAL, FLOATVAL, STRING ...
 *  Data Structure and Algorithms:
 *  History:
 *     Initial rev by leo 2003.11.21
 *     Most routines moved from src/packfile.c
 *     Renamed PackFile_* to PF_*
 *  Notes:
 *     PF_store_<type> write an opcode_t stream to cursor in natural
 *                     byte-ordering
 *     PF_fetch_<type> read items and possibly convert the foreign
 *                     format
 *     PF_size_<type>  return the needed size in opcode_t units
 *
 *  References:
 */

#include "parrot/parrot.h"
#include <assert.h>

#define TRACE_PACKFILE 0
#define TRACE_PACKFILE_PMC 0

/*
 * round val up to whole size, return result in bytes
 */
#define ROUND_UP_B(val,size) ((((val) + (size - 1))/(size)) * (size))

/*
 * round val up to whole opcode_t, return result in opcodes
 */
#define ROUND_UP(val,size) (((val) + ((size) - 1))/(size))

/*

=head1 pf_items

Parrot data items fetch and store functions.

PF_fetch_<item> functions retrieve the datatype item from the opcode
stream and convert byteordering or binary format on the fly, depending
on the packfile header.

PF_store_<item> functions write the datatype item to the stream as is.
These functions don't check the available size.

PF_size_<item> functions return the store size of item in opcode_t units.

=over 4

=cut

*/

/*
 * low level FLOATVAL fetch and convert functions
 *
 *
 * convert i386 LE 12 byte long double to IEEE 754 8 byte double
 */
static void
cvt_num12_num8(unsigned char *dest, unsigned char *src)
{
    int expo, i, s;
#ifdef __LCC__
    int expo2;
#endif

    memset (dest, 0, 8);
    /* exponents 15 -> 11 bits */
    s = src[9] & 0x80; /* sign */
    expo = ((src[9] & 0x7f)<< 8 | src[8]);
    if (expo == 0) {
nul:
        if (s)
            dest[7] |= 0x80;
        return;
    }
#ifdef __LCC__
    /* Yet again, LCC blows up mysteriously until a temporary variable is
     * added. */
    expo2 = expo - 16383;
    expo  = expo2;
#else
    expo -= 16383;       /* - bias */
#endif
    expo += 1023;       /* + bias 8byte */
    if (expo <= 0)       /* underflow */
        goto nul;
    if (expo > 0x7ff) {	/* inf/nan */
        dest[7] = 0x7f;
        dest[6] = src[7] == 0xc0 ? 0xf8 : 0xf0 ;
        goto nul;
    }
    expo <<= 4;
    dest[6] = (expo & 0xff);
    dest[7] = (expo & 0x7f00) >> 8;
    if (s)
        dest[7] |= 0x80;
    /* long double frac 63 bits => 52 bits
       src[7] &= 0x7f; reset integer bit */
    for (i = 0; i < 6; i++) {
        dest[i+1] |= (i==5 ? src[7]&0x7f : src[i+2]) >> 3;
        dest[i] |= (src[i+2] & 0x1f) << 5;
    }
    dest[0] |= src[1] >> 3;
}

static void
cvt_num12_num8_be(unsigned char *dest, unsigned char *src)
{
    cvt_num12_num8(dest, src);
    /* TODO endianize */
    internal_exception(1, "TODO cvt_num12_num8_be\n");
}

static void
cvt_num12_num8_le(unsigned char *dest, unsigned char *src)
{
    unsigned char b[8];
    cvt_num12_num8(b, src);
    fetch_buf_le_8(dest, b);
}

/*
 * opcode fetch helper function
 */
static opcode_t
fetch_op_mixed(opcode_t b)
{
#if OPCODE_T_SIZE == 4
    union {
        unsigned char buf[8];
        opcode_t o[2];
    } u;
#else
    opcode_t o;
#endif

#if PARROT_BIGENDIAN
#  if OPCODE_T_SIZE == 4
     /* wordsize = 8 then */
     fetch_buf_le_8(u.buf, (unsigned char *) b);
     return u.o[1]; /* or u.o[0] */
#  else
     o = fetch_op_le(b);        /* or fetch_be_le_4 and convert? */
     return o >> 32;    /* or o & 0xffffffff */
#  endif
#else
#  if OPCODE_T_SIZE == 4
     /* wordsize = 8 then */
     fetch_buf_be_8(u.buf, (unsigned char *) b);
     return u.o[0]; /* or u.o[1] */
#  else
     o = fetch_op_be(b);
     return o & 0xffffffff;
#  endif

#endif
}
/*

=item PF_fetch_opcode

Fetch an opcode_t from the stream, converting byteorder if needed.

=item PF_store_opcode

Store an opcode_t to stream as is.

=item PF_size_opcode

Return size of item in opcode_t units, which is 1 per definitionem.

=cut

***************************************/

opcode_t
PF_fetch_opcode(struct PackFile *pf, opcode_t **stream) {
    opcode_t o;
    if (!pf || !pf->fetch_op)
        return *(*stream)++;
#if TRACE_PACKFILE == 2
    PIO_eprintf(NULL, "PF_fetch_opcode: Reordering.\n");
#endif
    o = (pf->fetch_op)(**stream);
    *((unsigned char **) (stream)) += pf->header->wordsize;
    return o;
}

opcode_t*
PF_store_opcode(opcode_t *cursor, opcode_t val)
{
    *cursor++ = val;
    return cursor;
}

size_t
PF_size_opcode(void)
{
    return 1;
}

/***************************************

=item PF_fetch_integer

Fetch an INTVAL from the stream, converting byteorder if needed.

XXX assumes sizeof(INTVAL) == sizeof(opcode_t) - we don't have
    INTVAL size in PF header

=item PF_store_integer

Store an INTVAL to stream as is.

=item PF_size_integer

Return store size of INTVAL in opcode_t units.

=cut

***************************************/

INTVAL
PF_fetch_integer(struct PackFile *pf, opcode_t **stream) {
    INTVAL i;
    if (!pf || pf->fetch_iv == NULL)
        return *(*stream)++;
    i = (pf->fetch_iv)(**stream);
    /* XXX assume sizeof(opcode_t) == sizeof(INTVAL) on the
     * machine producing this PBC
     */
    *((unsigned char **) (stream)) += pf->header->wordsize;
    return i;
}


opcode_t*
PF_store_integer(opcode_t *cursor, INTVAL val)
{
    *cursor++ = (opcode_t)val; /* XXX */
    return cursor;
}

size_t
PF_size_integer(void)
{
    size_t s = sizeof(INTVAL) / sizeof(opcode_t);
    return s ? s : 1;
}

/***************************************

=item PF_fetch_number

Fetch a FLOATVAL from the stream, converting
byteorder if needed. Then advance stream pointer by
amount of packfile float size.

=item PF_store_number

Write a FLOATVAL to the opcode stream as is.

=item PF_size_number

Return store size of FLOATVAL in opcode_t units.

=cut

***************************************/

FLOATVAL
PF_fetch_number(struct PackFile *pf, opcode_t **stream) {
    /* When we have alignment all squared away we don't need
     * to use memcpy() for native byteorder.
     */
    FLOATVAL f;
    double d;
    if (!pf || !pf->fetch_nv) {
#if TRACE_PACKFILE
        PIO_eprintf(NULL, "PF_fetch_number: Native [%d bytes]..\n",
                sizeof(FLOATVAL));
#endif
        memcpy(&f, *stream, sizeof(FLOATVAL));
        (*stream) += (sizeof(FLOATVAL) + sizeof(opcode_t) - 1)/
            sizeof(opcode_t);
        return f;
    }
    f = (FLOATVAL) 0;
#if TRACE_PACKFILE
    PIO_eprintf(NULL, "PF_fetch_number: Byteordering..\n");
#endif
    /* Here is where the size transforms get messy */
    if (NUMVAL_SIZE == 8 && pf->header->floattype == 1) {
        (pf->fetch_nv)((unsigned char *)&f, (unsigned char *) *stream);
        *((unsigned char **) (stream)) += 12;
    }
    else {
        (pf->fetch_nv)((unsigned char *)&d, (unsigned char *) *stream);
        *((unsigned char **) (stream)) += 8;
        f = d;
    }
    return f;
}

opcode_t*
PF_store_number(opcode_t *cursor, FLOATVAL *val)
{
    opcode_t padded_size  = (sizeof(FLOATVAL) + sizeof(opcode_t) - 1) /
        sizeof(opcode_t);
    mem_sys_memcopy(cursor, val, sizeof(FLOATVAL));
    cursor += padded_size;
    return cursor;
}

size_t
PF_size_number(void)
{
    return ROUND_UP(sizeof(FLOATVAL), sizeof(opcode_t));
}

/*

=item PF_fetch_string

Fetch a STRING from bytecode and return an new STRING.
Opcode format is:

  opcode_t flags
  opcode_t encoding
  opcode_t type
  opcode_t size
  *  data

=item PF_store_string

Write a STRING to the opcode stream.

=item PF_size_string

Report store size of STRING in opcode_t units.

=cut

*/


STRING *
PF_fetch_string(Parrot_Interp interp, struct PackFile *pf, opcode_t **cursor)
{
    UINTVAL flags;
    opcode_t encoding;
    opcode_t type;
    size_t size;
    STRING *s;
    int wordsize = pf ? pf->header->wordsize : sizeof(opcode_t);

    flags = PF_fetch_opcode(pf, cursor);
    /* don't let PBC mess our internals - only constant or not */
    flags &= PObj_constant_FLAG;
    encoding = PF_fetch_opcode(pf, cursor);
    type = PF_fetch_opcode(pf, cursor);

    /* These may need to be separate */
    size = (size_t)PF_fetch_opcode(pf, cursor);

#if TRACE_PACKFILE
    PIO_eprintf(NULL, "Constant_unpack_string(): flags are 0x%04x...\n", flags);
    PIO_eprintf(NULL, "Constant_unpack_string(): encoding is %ld...\n",
           encoding);
    PIO_eprintf(NULL, "Constant_unpack_string(): type is %ld...\n", type);
    PIO_eprintf(NULL, "Constant_unpack_string(): size is %ld...\n", size);
#endif

    s = string_make(interp, *cursor, size,
                               encoding_lookup_index(encoding),
                               flags,
                               chartype_lookup_index(type));

    size = ROUND_UP_B(size, wordsize) / sizeof(opcode_t);
    *cursor += size;
    return s;
}

opcode_t*
PF_store_string(opcode_t *cursor, STRING *s)
{
    opcode_t padded_size = s->bufused;
    char *charcursor;
    size_t i;

    if (padded_size % sizeof(opcode_t)) {
        padded_size += sizeof(opcode_t) - (padded_size % sizeof(opcode_t));
    }

    *cursor++ = PObj_get_FLAGS(s); /* only constant_FLAG */
    *cursor++ = s->encoding->index;
    *cursor++ = s->type->index;
    *cursor++ = s->bufused;

    /* Switch to char * since rest of string is addressed by
     * characters to ensure padding.  */
    charcursor = (char *)cursor;

    if (s->strstart) {
        mem_sys_memcopy(charcursor, s->strstart, s->bufused);
        charcursor += s->bufused;

        if (s->bufused % sizeof(opcode_t)) {
            for (i = 0; i < (sizeof(opcode_t) -
                        (s->bufused % sizeof(opcode_t))); i++) {
                *charcursor++ = 0;
            }
        }
    }
    assert( ((int)charcursor & 3) == 0);
    LVALUE_CAST(char *, cursor) = charcursor;
    return cursor;
}

size_t
PF_size_string(STRING *s)
{
    opcode_t padded_size = s->bufused;

    if (padded_size % sizeof(opcode_t)) {
        padded_size += sizeof(opcode_t) - (padded_size % sizeof(opcode_t));
    }

    /* Include space for flags, encoding, type, and size fields.  */
    return 4 + (size_t)padded_size / sizeof(opcode_t);
}

/*

=item PF_fetch_cstring

Fetch a cstring from bytecode and return an allocated copy

=item PF_store_cstring

Write a 0-terminate string to the stream.

=item PF_size_cstring

Return store size of a C-string in opcode_t units.

=cut

*/

char *
PF_fetch_cstring(struct PackFile *pf, opcode_t **cursor)
{
    size_t str_len = strlen ((char *)(*cursor)) + 1;
    char *p = mem_sys_allocate(str_len);
    int wordsize = pf->header->wordsize;

    strcpy(p, (char*) (*cursor));
    (*cursor) += ROUND_UP_B(str_len, wordsize) / sizeof(opcode_t);
    return p;
}

opcode_t*
PF_store_cstring(opcode_t *cursor, const char *s)
{
    strcpy((char *) cursor, s);
    return cursor + PF_size_cstring(s);
}

size_t
PF_size_cstring(const char *s)
{
    size_t str_len;

    assert(s);
    str_len = strlen(s);
    return ROUND_UP(str_len + 1, sizeof(opcode_t));
}

/*

=back

=cut

*/

/*
 * Assign transform functions to vtable
 */
void
PackFile_assign_transforms(struct PackFile *pf) {
#if PARROT_BIGENDIAN
    if(pf->header->byteorder != PARROT_BIGENDIAN) {
        pf->need_endianize = 1;
        if (pf->header->wordsize == sizeof(opcode_t))
            pf->fetch_op = fetch_op_le;
        else {
            pf->need_wordsize = 1;
            pf->fetch_op = fetch_op_mixed;
        }

        pf->fetch_iv = fetch_iv_le;
        if (pf->header->floattype == 0)
            pf->fetch_nv = fetch_buf_le_8;
        else if (pf->header->floattype == 1)
            pf->fetch_nv = cvt_num12_num8_le;
    }
#else
    if(pf->header->byteorder != PARROT_BIGENDIAN) {
        pf->need_endianize = 1;
        if (pf->header->wordsize == sizeof(opcode_t)) {
            pf->fetch_op = fetch_op_be;
        }
        else {
            pf->need_wordsize = 1;
            pf->fetch_op = fetch_op_mixed;
        }
        pf->fetch_iv = fetch_iv_be;
        if (pf->header->floattype == 0)
            pf->fetch_nv = fetch_buf_be_8;
        else if (pf->header->floattype == 1)
            pf->fetch_nv = cvt_num12_num8_be;
    }
    else {
        if (NUMVAL_SIZE == 8 && pf->header->floattype == 1)
            pf->fetch_nv = cvt_num12_num8;
        else if (NUMVAL_SIZE != 8 && pf->header->floattype == 0)
            pf->fetch_nv = fetch_buf_le_8;
    }
#  if TRACE_PACKFILE
        PIO_eprintf(NULL, "header->byteorder [%d] native byteorder [%d]\n",
            pf->header->byteorder, PARROT_BIGENDIAN);
#  endif
#endif
    if (pf->header->wordsize != sizeof(opcode_t)) {
        pf->need_wordsize = 1;
        pf->fetch_op = fetch_op_mixed;
    }
}

/*
* Local variables:
* c-indentation-style: bsd
* c-basic-offset: 4
* indent-tabs-mode: nil
* End:
*
* vim: expandtab shiftwidth=4:
*/
