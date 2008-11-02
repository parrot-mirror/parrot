/* io_portable.h
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

#ifndef PARROT_IO_PORTABLE_H_GUARD
#define PARROT_IO_PORTABLE_H_GUARD

typedef FILE* PIOHANDLE;
typedef long PIOOFF_T;

/* HEADERIZER BEGIN: src/io/portable.c */
/* HEADERIZER END: src/io/portable.c */

#define PIO_INIT(interp) Parrot_io_init_portable((interp))
#define PIO_OPEN(interp, pmc, file, flags) \
    Parrot_io_open_portable((interp), (pmc), (file), (flags))
#define PIO_FDOPEN(interp, pmc, handle, flags) \
    Parrot_io_fdopen_portable((interp), (pmc), (handle), (flags))
#define PIO_OPEN_PIPE(interp, pmc, file, flags) \
    Parrot_io_open_pipe_portable((interp), (pmc), (file), (flags))
#define PIO_CLOSE(interp, pmc) Parrot_io_close_portable((interp), (pmc))
#define PIO_IS_CLOSED(interp, pmc) Parrot_io_is_closed_portable((interp), (pmc))
#define PIO_READ(interp, pmc, buf) Parrot_io_read_portable((interp), (pmc), (buf))
#define PIO_WRITE(interp, pmc, str) Parrot_io_write_portable((interp), (pmc), (str))
#define PIO_SEEK(interp, pmc, offset, start) \
    Parrot_io_seek_portable((interp), (pmc), (offset), (start))
#define PIO_TELL(interp, pmc) Parrot_io_tell_portable((interp), (pmc))
#define PIO_PEEK(interp, pmc, buf) Parrot_io_peek_portable((interp), (pmc), (buf))
#define PIO_FLUSH(interp, pmc) Parrot_io_flush_portable((interp), (pmc))
#define PIO_GETBLKSIZE(handle) Parrot_io_getblksize_portable((handle))

#endif /* PARROT_IO_PORTABLE_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
