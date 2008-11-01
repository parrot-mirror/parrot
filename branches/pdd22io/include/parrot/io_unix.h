/* io_unix.h
 *  Copyright (C) 2001-2003, The Perl Foundation.
 *  SVN Info
 *     $Id: $
 *  Overview:
 *      Parrot IO subsystem
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#ifndef PARROT_IO_UNIX_H_GUARD
#define PARROT_IO_UNIX_H_GUARD

/* HEADERIZER BEGIN: src/io/unix.c */
/* HEADERIZER END: src/io/unix.c */

#define PIO_INIT(interp) Parrot_io_init_unix((interp))
#define PIO_OPEN(interp, pmc, file, flags) \
    Parrot_io_open_unix((interp), (pmc), (file), (flags))
#define PIO_FDOPEN(interp, pmc, handle, flags) \
    Parrot_io_fdopen_unix((interp), (pmc), (handle), (flags))
#define PIO_OPEN_PIPE(interp, pmc, file, flags) \
    Parrot_io_open_pipe_unix((interp), (pmc), (file), (flags))
#define PIO_CLOSE(interp, pmc) Parrot_io_close_unix((interp), (pmc))
#define PIO_READ(interp, pmc, buf) Parrot_io_read_unix((interp), (pmc), (buf))
#define PIO_WRITE(interp, pmc, str) Parrot_io_write_unix((interp), (pmc), (str))
#define PIO_SEEK(interp, pmc, offset, start) \
    Parrot_io_seek_unix((interp), (pmc), (offset), (start))
#define PIO_TELL(interp, pmc) Parrot_io_tell_unix((interp), (pmc))
#define PIO_PEEK(interp, pmc, buf) Parrot_io_peek_unix((interp), (pmc), (buf))
#define PIO_FLUSH(interp, pmc) Parrot_io_flush_unix((interp), (pmc))
#define PIO_ISATTY(handle) Parrot_io_isatty_unix((handle))
#define PIO_GETBLKSIZE(handle) Parrot_io_getblksize_unix((handle))

#endif /* PARROT_IO_UNIX_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
