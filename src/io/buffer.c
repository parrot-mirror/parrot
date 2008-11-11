/*
Copyright (C) 2001-2008, The Perl Foundation.
$Id$

=head1 NAME

src/io/buffer.c - I/O buffering 

=head1 DESCRIPTION

This file implements a collection of utility functions for I/O buffering.

=head2 Functions

=over 4

=cut

*/

#include "parrot/parrot.h"
#include "io_private.h"

/* HEADERIZER HFILE: include/parrot/io.h */
/* HEADERIZER BEGIN: static */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

static INTVAL io_is_end_of_line(ARGIN(const char *c))
        __attribute__nonnull__(1);

/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: static */


/*

=item C<INTVAL Parrot_io_init_buffer>

Initialize buffering on STDOUT and STDIN.

=cut

*/

INTVAL
Parrot_io_init_buffer(PARROT_INTERP)
{
    if (Parrot_io_STDOUT(interp))
        Parrot_io_setlinebuf(interp, Parrot_io_STDOUT(interp));

    if (Parrot_io_STDIN(interp))
        Parrot_io_setbuf(interp, Parrot_io_STDIN(interp), PIO_UNBOUND);

    return 0;
}

/*

=item C<void Parrot_io_setbuf>

Set the buffering mode for the filehandle.

=cut

*/

void
Parrot_io_setbuf(PARROT_INTERP, ARGMOD(PMC *filehandle), size_t bufsize)
{
    INTVAL filehandle_flags = Parrot_io_get_flags(interp, filehandle);
    INTVAL         buffer_flags = Parrot_io_get_buffer_flags(interp, filehandle);
    unsigned char *buffer_start = Parrot_io_get_buffer_start(interp, filehandle);
    unsigned char *buffer_next  = Parrot_io_get_buffer_next(interp, filehandle);
    size_t         buffer_size;

    /* If there is already a buffer, make sure we flush before modifying it. */
    if (buffer_start)
        Parrot_io_flush_buffer(interp, filehandle);

    /* Choose an appropriate buffer size for caller */
    switch (bufsize) {
        case 0:
            Parrot_io_set_buffer_size(interp, filehandle, 0);
            break;
        case PIO_UNBOUND:
            Parrot_io_set_buffer_size(interp, filehandle,
                    PIO_GETBLKSIZE(Parrot_io_get_os_handle(interp, filehandle)));
            break;
        default:
            Parrot_io_set_buffer_size(interp, filehandle,
                    (bufsize >= PIO_GRAIN ? bufsize : PIO_GRAIN));
            break;
    }

    buffer_size = Parrot_io_get_buffer_size(interp, filehandle);

    if (buffer_start && (buffer_flags & PIO_BF_MALLOC)) {
        mem_sys_free(buffer_start);
        Parrot_io_set_buffer_start(interp, filehandle, NULL);
        Parrot_io_set_buffer_next(interp, filehandle, NULL);
        buffer_start = buffer_next = NULL;
    }

    if (buffer_size > 0) {
        buffer_start = buffer_next = (unsigned char *)mem_sys_allocate(buffer_size);
        Parrot_io_set_buffer_start(interp, filehandle, buffer_start);
        Parrot_io_set_buffer_next(interp, filehandle, buffer_next);
        buffer_flags |= PIO_BF_MALLOC;
    }
    else
        buffer_flags &= ~PIO_BF_MALLOC;

    Parrot_io_set_buffer_flags(interp, filehandle, buffer_flags);

    if (buffer_size != 0) {
        filehandle_flags &= ~PIO_F_LINEBUF;
        filehandle_flags |= PIO_F_BLKBUF;
    }
    else
        filehandle_flags &= ~(PIO_F_BLKBUF | PIO_F_LINEBUF);

    Parrot_io_set_flags(interp, filehandle, filehandle_flags);

}

/*

=item C<INTVAL Parrot_io_setlinebuf>

Set the file handle to line buffering mode.

=cut

*/

INTVAL
Parrot_io_setlinebuf(PARROT_INTERP, ARGMOD(PMC *filehandle))
{
    INTVAL filehandle_flags = Parrot_io_get_flags(interp, filehandle);

    /* already linebuffering */
    if (filehandle_flags & PIO_F_LINEBUF)
        return 0;

    /* Reuse setbuf call */
    Parrot_io_setbuf(interp, filehandle, PIO_LINEBUFSIZE);

    /* Then switch to linebuf */
    filehandle_flags &= ~PIO_F_BLKBUF;
    filehandle_flags |= PIO_F_LINEBUF;
    Parrot_io_set_flags(interp, filehandle, filehandle_flags);
/*    Parrot_io_set_record_separator(interp, filehandle, '\n'); */
    return 0;

}

/*

=item C<INTVAL Parrot_io_flush_buffer>

Flush the I/O buffer for a given filehandle object.

=cut

*/

INTVAL
Parrot_io_flush_buffer(PARROT_INTERP, ARGMOD(PMC *filehandle))
{
    long wrote;
    size_t to_write;
    STRING fake;
    unsigned char *buffer_start = Parrot_io_get_buffer_start(interp, filehandle);
    unsigned char *buffer_next  = Parrot_io_get_buffer_next(interp, filehandle);
    INTVAL         buffer_flags = Parrot_io_get_buffer_flags(interp, filehandle);

    /*
     * Either buffering is null, disabled, or empty.
     */
    if (!buffer_start
        || (Parrot_io_get_flags(interp, filehandle) & (PIO_F_BLKBUF | PIO_F_LINEBUF)) == 0
        || (buffer_flags & (PIO_BF_WRITEBUF | PIO_BF_READBUF)) == 0)
        return 0;
    /*
     * Write flush
     */
    if (buffer_flags & PIO_BF_WRITEBUF) {
        to_write = buffer_next - buffer_start;

        /* Flush to next layer */
        fake.strstart = (char *)buffer_start;
        fake.bufused = to_write;
        wrote = PIO_WRITE(interp, filehandle, &fake);
        if (wrote == (long)to_write) {
            Parrot_io_set_buffer_next(interp, filehandle, buffer_start);
            /* Release buffer */
            Parrot_io_set_buffer_flags(interp, filehandle, (buffer_flags & ~PIO_BF_WRITEBUF));
            return 0;
        }
        else {
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_PIO_ERROR,
                    "Attempt to flush invalid write buffer");
        }
    }
    /*
     * Read flush
     */
    else if (buffer_flags & PIO_BF_READBUF) {
        Parrot_io_set_buffer_next(interp, filehandle, buffer_start);
        /* Release buffer */
        Parrot_io_set_buffer_flags(interp, filehandle, (buffer_flags & ~PIO_BF_READBUF));
    }
    return -1;
}

/*

=item C<size_t Parrot_io_fill_readbuf>

The buffer layer's C<Fill> function.

=cut

*/

size_t
Parrot_io_fill_readbuf(PARROT_INTERP, ARGMOD(PMC *filehandle))
{
    size_t got;
    PIOOFF_T pos = Parrot_io_get_file_position(interp, filehandle);
    STRING fake, *s;
    fake.strstart = (char *)Parrot_io_get_buffer_start(interp, filehandle);
    fake.bufused  = Parrot_io_get_buffer_size(interp, filehandle);
    s = &fake;

    got = PIO_READ(interp, filehandle, &s);
    /* buffer-filling does not change fileposition */
    Parrot_io_set_file_position(interp, filehandle, pos);

    /* nothing to get */
    if (got == 0)
        return 0;

    Parrot_io_set_buffer_end(interp, filehandle,
            (got + Parrot_io_get_buffer_start(interp, filehandle)));
    Parrot_io_set_buffer_next(interp, filehandle,
            Parrot_io_get_buffer_start(interp, filehandle));

    Parrot_io_set_buffer_flags(interp, filehandle,
            (Parrot_io_get_buffer_flags(interp, filehandle) | PIO_BF_READBUF));

    return got;
}

/*

=item C<size_t Parrot_io_read_buffer>

The buffer layer's C<Read> function.

=cut

*/

size_t
Parrot_io_read_buffer(PARROT_INTERP, ARGMOD(PMC *filehandle),
              ARGIN(STRING **buf))
{
    unsigned char *out_buf;
    STRING *s;
    size_t len;
    size_t current = 0;
    INTVAL buffer_flags = Parrot_io_get_buffer_flags(interp, filehandle);
    unsigned char *buffer_start = Parrot_io_get_buffer_start(interp, filehandle);
    unsigned char *buffer_next  = Parrot_io_get_buffer_next(interp, filehandle);
    unsigned char *buffer_end   = Parrot_io_get_buffer_end(interp, filehandle);

    /* write buffer flush */
    if (buffer_flags & PIO_BF_WRITEBUF) {
        Parrot_io_flush_buffer(interp, filehandle);
    }

    /* line buffered read */
    if (Parrot_io_get_flags(interp, filehandle) & PIO_F_LINEBUF) {
        return Parrot_io_readline_buffer(interp, filehandle, buf);
    }

    if (*buf == NULL) {
        *buf = new_string_header(interp, 0);
        (*buf)->bufused = len = 2048;
    }
    s = *buf;
    len = s->bufused;
    if (!s->strstart) {
        Parrot_allocate_string(interp, s, len);
    }
    out_buf = (unsigned char *)s->strstart;
    /* read Data from buffer */
    if (buffer_flags & PIO_BF_READBUF) {
        const size_t avail = buffer_end - buffer_next;

        current = avail < len ? avail : len;
        memcpy(out_buf, buffer_next, current);
        buffer_next += current;
        Parrot_io_set_buffer_next(interp, filehandle, buffer_next);
        Parrot_io_set_file_position(interp, filehandle, (current +
                Parrot_io_get_file_position(interp, filehandle)));

        /* buffer completed */
        if (current == avail) {
            Parrot_io_set_buffer_flags(interp, filehandle,
                    (buffer_flags & ~PIO_BF_READBUF));
            /* Reset next and end */
            Parrot_io_set_buffer_end(interp, filehandle, NULL);
            Parrot_io_set_buffer_next(interp, filehandle, buffer_start);
        }

        if (len == current) {
            s->strlen = s->bufused = len;
            return current;
        }
        else {
            /* more data needed from downlayer */
            out_buf += current;
            len -= current;
        }
    }

    /* (re)fill the readbuffer */
    if (!(buffer_flags & PIO_BF_READBUF)) {
        size_t got;
        if (len >= Parrot_io_get_buffer_size(interp, filehandle)) {
            STRING fake;
            STRING *sf = &fake;

            fake.strstart = (char *)out_buf;
            fake.bufused  = len;
            got = PIO_READ(interp, filehandle, &sf);
            s->strlen = s->bufused = current + got;
            Parrot_io_set_file_position(interp, filehandle, (got +
                    Parrot_io_get_file_position(interp, filehandle)));
            return current + got;
        }

        got = Parrot_io_fill_readbuf(interp, filehandle);

        len = len < got ? len : got;
    }

    /* read from the read_buffer */
    memcpy(out_buf, buffer_next, len);
    s->strlen = s->bufused = current + len;
    buffer_next += len;
    Parrot_io_set_buffer_next(interp, filehandle, buffer_next);
    Parrot_io_set_file_position(interp, filehandle, (len +
            Parrot_io_get_file_position(interp, filehandle)));

    /* is the buffer is completely empty ? */
    if (buffer_next == buffer_end) {
        Parrot_io_set_buffer_flags(interp, filehandle,
                (buffer_flags & ~PIO_BF_READBUF));
        /* Reset next and end */
        Parrot_io_set_buffer_end(interp, filehandle, NULL);
        Parrot_io_set_buffer_next(interp, filehandle, buffer_start);
    }
    return current + len;
}

/*

=item C<size_t Parrot_io_peek_buffer>

Retrieve the next character in the buffer without modifying the stream.

=cut

*/

size_t
Parrot_io_peek_buffer(PARROT_INTERP, ARGMOD(PMC *filehandle),
        ARGOUT(STRING **buf))
{
    size_t len = 1;
    size_t avail = 0;

    INTVAL         buffer_flags = Parrot_io_get_buffer_flags(interp, filehandle);
    unsigned char *buffer_next  = Parrot_io_get_buffer_next(interp, filehandle);
    unsigned char *buffer_end   = Parrot_io_get_buffer_end(interp, filehandle);

    STRING * const s = Parrot_io_make_string(interp, buf, 1);

    /* write buffer flush */
    if (buffer_flags & PIO_BF_WRITEBUF) {
        Parrot_io_flush_buffer(interp, filehandle);
    }

    /* read Data from buffer */
    if (buffer_flags & PIO_BF_READBUF) {
        avail = buffer_end - buffer_next;

        /* if we have data available, copy out the next byte */
        if (avail) {
ret_string:
            memcpy(s->strstart, buffer_next, len);
            s->bufused = s->strlen = len;
            return len;
        }
    }

    /* (re)fill the buffer */
    if (! (buffer_flags & PIO_BF_READBUF)) {
        size_t got;
        /* exception if we're unbuffered */
        if (Parrot_io_get_buffer_size(interp, filehandle) == 0)
            Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_PIO_ERROR,
                "Can't peek at unbuffered I/O");

        got = Parrot_io_fill_readbuf(interp, filehandle);
        len = (len < got) ? len : got;
    }

    /* if we got any data, then copy out the next byte */
    goto ret_string;
}

/*

=item C<size_t Parrot_io_readline_buffer>

This is called from C<Parrot_io_read_buffer()> to do line buffered reading if
that is what is required.

=cut

*/

size_t
Parrot_io_readline_buffer(PARROT_INTERP, ARGMOD(PMC *filehandle), ARGOUT(STRING **buf))
{
    size_t l;
    unsigned char *out_buf;
    unsigned char *buf_start;
    INTVAL         buffer_flags = Parrot_io_get_buffer_flags(interp, filehandle);
    unsigned char *buffer_next  = Parrot_io_get_buffer_next(interp, filehandle);
    unsigned char *buffer_end   = Parrot_io_get_buffer_end(interp, filehandle);
    size_t len;
    STRING *s;

    if (*buf == NULL) {
        *buf = new_string_header(interp, 0);
    }
    s = *buf;
    s->strlen = 0;

    /* fill empty buffer */
    if (!(buffer_flags & PIO_BF_READBUF)) {
        if (Parrot_io_fill_readbuf(interp, filehandle) == 0)
            return 0;
    }

    buf_start = buffer_next;
    for (l = 0; buffer_next < buffer_end;) {
        l++;
        if (io_is_end_of_line((char *)buffer_next++)) {
            break;
        }
        /* if there is a buffer, readline is called by the read opcode
         * - return just that part
         */
        if (s->bufused && l == s->bufused)
            break;
        /* buffer completed; copy out and refill */
        if (buffer_next == buffer_end) {
            len = buffer_end - buf_start;
            if (s->bufused < l) {
                if (s->strstart) {
                    Parrot_reallocate_string(interp, s, l);
                }
                else {
                    Parrot_allocate_string(interp, s, l);
                }
            }
            out_buf = (unsigned char*)s->strstart + s->strlen;
            memcpy(out_buf, buf_start, len);
            s->strlen = s->bufused = l;
            if (Parrot_io_fill_readbuf(interp, filehandle) == 0)
                return l;
            buf_start = Parrot_io_get_buffer_start(interp, filehandle);;
        }
    }
    if (s->bufused < l) {
        if (s->strstart) {
            Parrot_reallocate_string(interp, s, l);
        }
        else {
            Parrot_allocate_string(interp, s, l);
        }
    }
    out_buf = (unsigned char*)s->strstart + s->strlen;
    len = buffer_next - buf_start;
    memcpy(out_buf, buf_start, len);
    s->strlen = s->bufused = l;

    /* check if buffer is finished */
    if (buffer_next == buffer_end) {
        Parrot_io_set_buffer_flags(interp, filehandle,
                (buffer_flags & ~PIO_BF_READBUF));
        Parrot_io_set_buffer_next(interp, filehandle,
                Parrot_io_get_buffer_start(interp, filehandle));
        Parrot_io_set_buffer_end(interp, filehandle, NULL);
    }

    return l;
}

/*

=item C<size_t Parrot_io_write_buffer>

The buffer layer's C<Write> function.

=cut

*/

size_t
Parrot_io_write_buffer(PARROT_INTERP, ARGMOD(PMC *filehandle), ARGIN(STRING *s))
{
    size_t avail;
    void * const buffer = s->strstart;
    size_t len = s->bufused;
    int need_flush;

    INTVAL         buffer_flags = Parrot_io_get_buffer_flags(interp, filehandle);
    unsigned char *buffer_start = Parrot_io_get_buffer_start(interp, filehandle);
    unsigned char *buffer_next  = Parrot_io_get_buffer_next(interp, filehandle);
    size_t         buffer_size  = Parrot_io_get_buffer_size(interp, filehandle);

    if (len <= 0)
        return 0;
    if (buffer_flags & PIO_BF_WRITEBUF) {
        avail = buffer_size - (buffer_next - buffer_start);
    }
    else if (buffer_flags & PIO_BF_READBUF) {
        buffer_flags &= ~PIO_BF_READBUF;
        Parrot_io_set_buffer_flags(interp, filehandle, buffer_flags);
        Parrot_io_set_buffer_next(interp, filehandle, buffer_start);
        avail = buffer_size;
    }
    else {
        avail = buffer_size;
    }
    /* If we are line buffered, check for newlines.
     * If any, we should flush
     */
    need_flush = 0;
    if (Parrot_io_get_flags(interp, filehandle) & PIO_F_LINEBUF) {
        /* scan from end, it's likely that EOL is at end of string */
        const char *p = (char*)buffer + len - 1;
        size_t i;
        for (i = 0; i < len; ++i, --p)
            if (io_is_end_of_line(p)) {
                need_flush = 1;
                break;
            }
    }

    /*
     * Large writes (multiples of blocksize) should write
     * through generally for best performance, else you are
     * just doing extra memcpys.
     * FIXME: This is badly optimized, will fixup later.
     */
    if (need_flush || len >= buffer_size) {
        long wrote;
        /* Write through, skip buffer. */
        Parrot_io_flush_buffer(interp, filehandle);
        wrote = PIO_WRITE(interp, filehandle, s);
        if (wrote == (long)len) {
            Parrot_io_set_file_position(interp, filehandle, (wrote +
                        Parrot_io_get_file_position(interp, filehandle)));
            return wrote;
        }
        else {
            return (size_t)-1; /* Write error */
        }
    }
    else if (avail > len) {
        buffer_flags |= PIO_BF_WRITEBUF;
        Parrot_io_set_buffer_flags(interp, filehandle, buffer_flags);
        memcpy(buffer_next, buffer, len);
        buffer_next += len;
        Parrot_io_set_file_position(interp, filehandle, (len +
                    Parrot_io_get_file_position(interp, filehandle)));
        return len;
    }
    else {
        const unsigned int diff = (int)(len - avail);

        buffer_flags |= PIO_BF_WRITEBUF;
        Parrot_io_set_buffer_flags(interp, filehandle, buffer_flags);
        /* Fill remainder, flush, then try to buffer more */
        memcpy(buffer_next, buffer, avail);
        buffer_next += avail;
        Parrot_io_set_file_position(interp, filehandle, (avail +
                    Parrot_io_get_file_position(interp, filehandle)));
        Parrot_io_flush_buffer(interp, filehandle);
        memcpy(buffer_start, ((const char *)buffer + avail), diff);
        buffer_next += diff;
        Parrot_io_set_file_position(interp, filehandle, (diff +
                    Parrot_io_get_file_position(interp, filehandle)));
        return len;
    }
}

/*

=item C<PIOOFF_T Parrot_io_seek_buffer>

The buffer layer's C<Seek> function.

=cut

*/

PIOOFF_T
Parrot_io_seek_buffer(PARROT_INTERP, ARGMOD(PMC *filehandle),
        PIOOFF_T offset, INTVAL whence)
{
    PIOOFF_T newpos;
    PIOOFF_T file_pos = Parrot_io_get_file_position(interp, filehandle);
    unsigned char *buffer_start = Parrot_io_get_buffer_start(interp, filehandle);
    unsigned char *buffer_next  = Parrot_io_get_buffer_next(interp, filehandle);
    unsigned char *buffer_end   = Parrot_io_get_buffer_end(interp, filehandle);

    switch (whence) {
    case SEEK_SET:
        newpos = offset;
        break;
    case SEEK_CUR:
        newpos = file_pos + offset;
        break;
    case SEEK_END:
        newpos = PIO_SEEK(interp, filehandle, offset,
                               whence);
        if (newpos == -1)
            return -1;

        break;
    default:
        /* XXX: somehow report the illegal whence value */
        return -1;
    }

    if ((newpos < file_pos - (buffer_next - buffer_start))
        || (newpos >= file_pos + (buffer_end - buffer_next))) {
        Parrot_io_flush_buffer(interp, filehandle);
        newpos = PIO_SEEK(interp, filehandle, newpos, SEEK_SET);
    }
    else {
        buffer_next += newpos - file_pos;
        Parrot_io_set_buffer_next(interp, filehandle, buffer_next);
    }

    Parrot_io_set_file_position(interp, filehandle, newpos);

    return newpos;
}

/* 

=item C<static INTVAL io_is_end_of_line>

Determine if the current character is the end of the line.

Note that this is not a portable solution, but it is what the old architecture
was doing, once you boil away the useless macros. This will need to change to
support the Strings PDD, but is left as-is for now, for a smooth transition to
the new architecture.

*/

static INTVAL
io_is_end_of_line(ARGIN(const char *c))
{
    if ((*(c)) == '\n')
        return 1;

    return 0;
}

/*

=back

=head1 SEE ALSO

F<src/io/api.c>,
F<src/io/unix.c>,
F<src/io/win32.c>,
F<src/io/portable.c>,
F<src/io.c>,
F<src/io/io_private.h>.

=cut

*/


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
