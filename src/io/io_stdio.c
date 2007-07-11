/*
Copyright (C) 2001-2007, The Perl Foundation.
$Id$

=head1 NAME

src/io/io_stdio.c - STDIO layer

=head1 DESCRIPTION

This is the Parrot IO STDIO layer. This may provide a subset of full
functionality, but must compile on any system with the ANSI C standard
library.  Also note that unlike the other low-level IO layers (UNIX,
Win32), this is I<buffered> IO, out of necessity.

=head2 Functions

=over 4

=cut

*/

#include <stdio.h>
#include "parrot/parrot.h"
#include "io_private.h"

/* HEADERIZER HFILE: none */
/* HEADERIZER BEGIN: static */

static const char * flags_to_stdio( INTVAL flags )
        __attribute__const__
        __attribute__warn_unused_result__;

static INTVAL PIO_stdio_close(
    SHIM_INTERP,
    ParrotIOLayer *layer,
    ParrotIO *io /*NN*/ )
        __attribute__nonnull__(3);

static ParrotIO * PIO_stdio_fdopen( PARROT_INTERP,
    ParrotIOLayer *layer,
    PIOHANDLE fptr,
    INTVAL flags )
        __attribute__nonnull__(1);

static INTVAL PIO_stdio_flush(
    SHIM_INTERP,
    ParrotIOLayer *layer,
    ParrotIO *io /*NN*/ )
        __attribute__nonnull__(3);

static INTVAL PIO_stdio_init( PARROT_INTERP, ParrotIOLayer *layer )
        __attribute__nonnull__(1);

static INTVAL PIO_stdio_isatty( PIOHANDLE fptr );
static ParrotIO * PIO_stdio_open( PARROT_INTERP,
    ParrotIOLayer *layer,
    const char *spath,
    INTVAL flags )
        __attribute__nonnull__(1);

static size_t PIO_stdio_peek( PARROT_INTERP,
    ParrotIOLayer *layer,
    ParrotIO *io,
    STRING **buf )
        __attribute__nonnull__(1);

static size_t PIO_stdio_read( PARROT_INTERP,
    ParrotIOLayer *layer,
    ParrotIO *io,
    STRING ** buf )
        __attribute__nonnull__(1);

static PIOOFF_T PIO_stdio_seek(
    SHIM_INTERP,
    ParrotIOLayer *layer,
    ParrotIO *io /*NN*/,
    PIOOFF_T offset,
    INTVAL whence )
        __attribute__nonnull__(3);

static PIOOFF_T PIO_stdio_tell(
    SHIM_INTERP,
    ParrotIOLayer *layer,
    ParrotIO *io /*NN*/ )
        __attribute__nonnull__(3);

static size_t PIO_stdio_write(
    SHIM_INTERP,
    ParrotIOLayer *layer,
    ParrotIO *io /*NN*/,
    STRING *s /*NN*/ )
        __attribute__nonnull__(3)
        __attribute__nonnull__(4);

/* HEADERIZER END: static */

extern INTVAL           PIO_stdio_getblksize(PIOHANDLE fd); /* XXX Use a declaration in a header file */

/* Defined at bottom */
extern const ParrotIOLayerAPI pio_stdio_layer_api;

ParrotIOLayer pio_stdio_layer = {
    NULL,
    "stdio",
    PIO_L_TERMINAL,
    &pio_stdio_layer_api,
    0, 0
};


/*

=item C<static const char *
flags_to_stdio(INTVAL flags)>

Returns a C string representation of C<flags> suitable for passing to
C<fopen()> in C<PIO_stdio_open()>.

=cut

*/

static const char *
flags_to_stdio(INTVAL flags)
    /* CONST, WARN_UNUSED */
{
    if ((flags & (PIO_F_WRITE | PIO_F_READ | PIO_F_APPEND)) ==
        (PIO_F_WRITE | PIO_F_READ | PIO_F_APPEND)) {
        return "a+b";
    }
    else if ((flags & (PIO_F_WRITE | PIO_F_READ | PIO_F_TRUNC)) ==
             (PIO_F_WRITE | PIO_F_READ | PIO_F_TRUNC)) {
        return "w+b";
    }
    else if ((flags & (PIO_F_WRITE | PIO_F_READ)) ==
             (PIO_F_WRITE | PIO_F_READ)) {
        return "r+b";
    }
    else if (flags & PIO_F_APPEND) {
        return "ab";
    }
    else if (flags & PIO_F_WRITE) {
        return "wb";
    }
    else {
        /* PIO_F_READ, hopefully */
        return "rb";
    }
}

/*

=item C<static INTVAL
PIO_stdio_init(PARROT_INTERP, ParrotIOLayer *layer)>

Setup standard streams, etc.

=cut

*/

static INTVAL
PIO_stdio_init(PARROT_INTERP, ParrotIOLayer *layer)
{
#ifdef PIO_OS_STDIO
    /* Only set standard handles if stdio is the OS IO */
    PIO_STDIN(interp)
        = new_io_pmc(interp,
                     PIO_stdio_fdopen(interp, layer, stdin, PIO_F_READ));

    PIO_STDOUT(interp)
        = new_io_pmc(interp,
                     PIO_stdio_fdopen(interp, layer, stdout, PIO_F_WRITE));

    PIO_STDERR(interp)
        = new_io_pmc(interp,
                     PIO_stdio_fdopen(interp, layer, stderr, PIO_F_WRITE));
#else  /* PIO_OS_STDIO */
    UNUSED(interp);
    UNUSED(layer);
#endif /* PIO_OS_STDIO */
    return 0;
}

/*

=item C<static ParrotIO *
PIO_stdio_open(PARROT_INTERP, ParrotIOLayer *layer,
              const char *spath, INTVAL flags)>

Open modes (read, write, append, etc.) are done in pseudo-Perl style
using C<< < >>, C<< > >>, etc.

=cut

*/

static ParrotIO *
PIO_stdio_open(PARROT_INTERP, SHIM(ParrotIOLayer *layer),
              const char *spath, INTVAL flags)
{
    ParrotIO *io;
    const char *oflags;
    INTVAL type;
    FILE *fptr;
    type = PIO_TYPE_FILE;

    if ((flags & (PIO_F_WRITE | PIO_F_READ)) == 0)
        return NULL;

    oflags = flags_to_stdio(flags);

    /* Only files for now */
    flags |= PIO_F_FILE;

    /* Try opening the file- note that this can't really handle O_EXCL, etc. */
    fptr = fopen(spath, oflags);

    if (fptr == NULL && errno == ENOENT && (flags & PIO_F_WRITE)) {
        fptr = fopen(spath, "w+b");
    }

    /* File open */
    if (fptr != NULL) {
        if (PIO_stdio_isatty((PIOHANDLE)fptr))
            flags |= PIO_F_CONSOLE;
        io = PIO_new(interp, type, flags, 0);
        io->fd = (PIOHANDLE)fptr;
        return io;
    }
    return NULL;
}

/*

=item C<static ParrotIO *
PIO_stdio_fdopen(PARROT_INTERP, ParrotIOLayer *layer, PIOHANDLE fptr, INTVAL flags)>

Desc.

=cut

*/

static ParrotIO *
PIO_stdio_fdopen(PARROT_INTERP, SHIM(ParrotIOLayer *layer), PIOHANDLE fptr, INTVAL flags)
{
    ParrotIO *io;
    const INTVAL mode = 0;

    if (PIO_stdio_isatty(fptr))
        flags |= PIO_F_CONSOLE;

    /* fdopened files are always shared */
    flags |= PIO_F_SHARED;

    io = PIO_new(interp, PIO_F_FILE, flags, mode);
    io->fd = fptr;
    return io;
}

/*

=item C<static INTVAL
PIO_stdio_close(PARROT_INTERP, ParrotIOLayer *layer, ParrotIO *io)>

Desc.

=cut

*/

static INTVAL
PIO_stdio_close(SHIM_INTERP, SHIM(ParrotIOLayer *layer), ParrotIO *io /*NN*/)
{
    FILE * const fptr = (FILE*)io->fd;

    if (fptr != NULL)
        fclose(fptr);
    io->fd = (PIOHANDLE)NULL;
    return 0;
}

/*

=item C<static INTVAL
PIO_stdio_isatty(PIOHANDLE fptr)>

Desc.

=cut

*/

static INTVAL
PIO_stdio_isatty(PIOHANDLE fptr)
{
    UNUSED(fptr);

    /* no obvious way to check for this with STDIO */
    return 0;
}

static size_t
PIO_stdio_peek(PARROT_INTERP, SHIM(ParrotIOLayer *layer), ParrotIO *io, STRING **buf)
{
    FILE * const fptr = (FILE *)io->fd;
    STRING * const s = PIO_make_io_string(interp, buf, 1);

    /* read the next byte into the buffer */
    const size_t bytes = fread(s->strstart, 1, 1, fptr);

    /* if we got anything from the stream, push it back on */
    if (bytes) {
        s->bufused = s->strlen = 1;
        ungetc(*(char*)s->strstart, fptr);
    }
    else
        s->bufused = s->strlen = 1;

    return bytes;
}


/*

=item C<INTVAL
PIO_stdio_getblksize(PIOHANDLE fptr)>

Desc.

=cut

*/

INTVAL
PIO_stdio_getblksize(PIOHANDLE fptr)
{
    UNUSED(fptr);

    /* Hard coded for now */
    return PIO_BLKSIZE;
}

/*

=item C<static INTVAL
PIO_stdio_flush(PARROT_INTERP, ParrotIOLayer *layer, ParrotIO *io)>

Desc.

=cut

*/

static INTVAL
PIO_stdio_flush(SHIM_INTERP, SHIM(ParrotIOLayer *layer), ParrotIO *io /*NN*/)
{
    return fflush((FILE*)io->fd);
}

/*

=item C<static size_t
PIO_stdio_read(PARROT_INTERP, ParrotIOLayer *layer, ParrotIO *io,
              STRING **)>

Desc.

=cut

*/

static size_t
PIO_stdio_read(PARROT_INTERP, SHIM(ParrotIOLayer *layer), ParrotIO *io,
              STRING ** buf)
{
    FILE * const fptr = (FILE *)io->fd;
    STRING * const s = PIO_make_io_string(interp, buf, 2048);
    const size_t len = s->bufused;
    void * const buffer = s->strstart;

    const size_t bytes = fread(buffer, 1, len, fptr);

    s->bufused = s->strlen = bytes;

    if (bytes != len) {
        if (feof(fptr)) {
            io->flags |= PIO_F_EOF;
        }
    }

    return bytes;
}

/*

=item C<static size_t
PIO_stdio_write(PARROT_INTERP, ParrotIOLayer *layer, ParrotIO *io,
               STRING *s)>

Desc.

=cut

*/

static size_t
PIO_stdio_write(SHIM_INTERP, SHIM(ParrotIOLayer *layer), ParrotIO *io /*NN*/, STRING *s /*NN*/)
{
    void * const buffer = s->strstart;
    return fwrite(buffer, 1, s->bufused, (FILE*)io->fd);
}

/*

=item C<static PIOOFF_T
PIO_stdio_seek(PARROT_INTERP, ParrotIOLayer *layer, ParrotIO *io,
              PIOOFF_T offset, INTVAL whence)>

Hard seek.

=cut

*/

static PIOOFF_T
PIO_stdio_seek(SHIM_INTERP, SHIM(ParrotIOLayer *layer), ParrotIO *io /*NN*/,
              PIOOFF_T offset, INTVAL whence)
{
    PIOOFF_T pos;
    errno = 0;

    if ((pos = fseek((FILE*)io->fd, (long)offset, whence)) >= 0) {
        io->lpos = io->fpos;
        io->fpos = pos;
    }

    /* Seek clears EOF */
    io->flags &= ~PIO_F_EOF;
    return pos;
}

/*

=item C<static PIOOFF_T
PIO_stdio_tell(PARROT_INTERP, ParrotIOLayer *layer, ParrotIO *io)>

Desc.

=cut

*/

static PIOOFF_T
PIO_stdio_tell(SHIM_INTERP, SHIM(ParrotIOLayer *layer), ParrotIO *io /*NN*/)
{
    return (ftell((FILE*)io->fd));
}

const ParrotIOLayerAPI pio_stdio_layer_api = {
    PIO_stdio_init,
    PIO_base_new_layer,
    PIO_base_delete_layer,
    PIO_null_push_layer,
    PIO_null_pop_layer,
    PIO_stdio_open,
    PIO_null_open2,
    PIO_null_open3,
    PIO_null_open_async,
    PIO_stdio_fdopen,
    PIO_stdio_close,
    PIO_stdio_write,
    PIO_null_write_async,
    PIO_stdio_read,
    PIO_null_read_async,
    PIO_stdio_flush,
    PIO_stdio_peek,
    PIO_stdio_seek,
    PIO_stdio_tell,
    PIO_null_setbuf,
    PIO_null_setlinebuf,
    PIO_null_getcount,
    PIO_null_fill,
    PIO_null_eof,
    0, /* no poll */
    0, /* no socket */
    0, /* no connect */
    0, /* no send */
    0, /* no recv */
    0, /* no bind */
    0, /* no listen */
    0  /* no accept */
};

/*

=back

=head1 SEE ALSO

F<src/io/io_buf.c>,
F<src/io/io_passdown.c>,
F<src/io/io_unix.c>,
F<src/io/io_win32.c>,
F<src/io/io.c>,
F<src/io/io_private.h>.

=head1 HISTORY

Adapted from io_unix.c by Josh Wilmes (josh@hitchhiker.org).

=cut

*/


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
