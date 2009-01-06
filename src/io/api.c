/*
Copyright (C) 2001-2008, The Perl Foundation.
$Id$

=head1 NAME

src/io/api.c - Parrot I/O API

=head1 DESCRIPTION

The Parrot I/O subsystem provides the core I/O functionality for all parts of
Parrot. This file implements the public interface to the I/O subsystem. Common
utility functions that aren't part of the public interface are defined in
F<src/io/common.c> and utility functions for a specific platform are in
F<src/io/unix.c>, F<src/io/win32.c>, or F<src/io/portable.c>. The platform is
selected in F<include/parrot/io.h>, based on #defines from the configuration
process.

The C<FileHandle> PMC provides the class-based interface for filehandles that
is used in Parrot ops.

=cut

*/

#include "parrot/parrot.h"
#include "io_private.h"
#include "api.str"

#include <stdarg.h>

/* HEADERIZER HFILE: include/parrot/io.h */

/*

=head2 Generic I/O interface

=over 4

=item C<PMC * Parrot_io_new_pmc>

Creates a new I/O filehandle object. The value of C<flags> is set
in the returned PMC.

=cut

*/

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PMC *
Parrot_io_new_pmc(PARROT_INTERP, INTVAL flags)
{
    ASSERT_ARGS(Parrot_io_new_pmc)
    PMC * const new_io = pmc_new(interp, enum_class_FileHandle);

    Parrot_io_set_flags(interp, new_io, flags);

    return new_io;
}




/*

=item C<PMC * Parrot_io_open>

Return an open filehandle for a given string path and flags. Defaults to
creating a new FileHandle PMC. If a PMC object is passed in, it uses that
object instead of creating a new FileHandle.

=cut

*/

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PMC *
Parrot_io_open(PARROT_INTERP, ARGIN_NULLOK(PMC *pmc),
        ARGIN(STRING *path), ARGIN_NULLOK(STRING *mode))
{
    ASSERT_ARGS(Parrot_io_open)
    PMC *new_filehandle;

    if (PMC_IS_NULL(pmc))
        new_filehandle = pmc_new(interp, enum_class_FileHandle);
    else
        new_filehandle = pmc;

    Parrot_PCCINVOKE(interp, new_filehandle, CONST_STRING(interp, "open"), "SS->P",
            path, mode, &new_filehandle);

    return new_filehandle;
}

/*

=item C<PMC * Parrot_io_fdopen>

Creates and returns a C<FileHandle> PMC for a given set of flags on an
existing, open file descriptor.

This is used particularly to initialize the C<STD*> IO handles onto the
OS IO handles (0, 1, 2).

=cut

*/

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PMC *
Parrot_io_fdopen(PARROT_INTERP, ARGIN_NULLOK(PMC *pmc), PIOHANDLE fd,
        ARGIN(STRING *sflags))
{
    ASSERT_ARGS(Parrot_io_fdopen)
    PMC *new_filehandle;
    INTVAL flags;

    flags = Parrot_io_parse_open_flags(interp, sflags);
    if (!flags)
        return PMCNULL;

    new_filehandle = PIO_FDOPEN(interp, pmc, fd, flags);

    if (PMC_IS_NULL(new_filehandle))
        Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_PIO_ERROR,
            "Unable to open filehandle");

    if (Parrot_io_get_flags(interp, new_filehandle) & PIO_F_CONSOLE)
        Parrot_io_setlinebuf(interp, new_filehandle);
    else
        Parrot_io_setbuf(interp, new_filehandle, PIO_UNBOUND);

    return new_filehandle;
}

/*

=item C<INTVAL Parrot_io_close>

Closes the filehandle object.

=cut

*/

PARROT_EXPORT
INTVAL
Parrot_io_close(PARROT_INTERP, ARGMOD(PMC *pmc))
{
    ASSERT_ARGS(Parrot_io_close)
    INTVAL result;

    if (PMC_IS_NULL(pmc))
        return -1;

    Parrot_PCCINVOKE(interp, pmc, CONST_STRING(interp, "close"), "->I", &result);

    return result;
}

/*

=item C<INTVAL Parrot_io_is_closed>

Test whether a filehandle is closed.

=cut

*/

PARROT_EXPORT
INTVAL
Parrot_io_is_closed(PARROT_INTERP, ARGMOD(PMC *pmc))
{
    ASSERT_ARGS(Parrot_io_is_closed)
    INTVAL result;

    if (PMC_IS_NULL(pmc))
        return 1;

    Parrot_PCCINVOKE(interp, pmc, CONST_STRING(interp, "is_closed"), "->I", &result);
    return result;
}

/*

=item C<void Parrot_io_flush>

Flushes the C<ParrotIO> PMC C<*pmc>.

=cut

*/

PARROT_EXPORT
void
Parrot_io_flush(PARROT_INTERP, ARGMOD(PMC *pmc))
{
    ASSERT_ARGS(Parrot_io_flush)
    if (PMC_IS_NULL(pmc))
        return;

    Parrot_PCCINVOKE(interp, pmc, CONST_STRING(interp, "flush"), "->");
}

/*

=item C<STRING * Parrot_io_reads>

Return a new C<STRING*> holding up to C<len> bytes.

=cut

*/


PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
STRING *
Parrot_io_reads(PARROT_INTERP, ARGMOD(PMC *pmc), size_t length)
{
    ASSERT_ARGS(Parrot_io_reads)
    STRING *result;
    Parrot_PCCINVOKE(interp, pmc, CONST_STRING(interp, "read"), "I->S",
            length, &result);
    return result;
}

/*

=item C<STRING * Parrot_io_readline>

Return a new C<STRING*> holding the next line read from the file.

=cut

*/


PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
STRING *
Parrot_io_readline(PARROT_INTERP, ARGMOD(PMC *pmc))
{
    ASSERT_ARGS(Parrot_io_readline)
    STRING *result;
    Parrot_PCCINVOKE(interp, pmc, CONST_STRING(interp, "readline"), "->S",
            &result);
    return result;
}

/*

=item C<INTVAL Parrot_io_write>

Writes C<len> bytes from C<*buffer> to C<*pmc>.

=cut

*/

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
INTVAL
Parrot_io_write(PARROT_INTERP, ARGMOD(PMC *pmc), ARGIN(const void *buffer), size_t length)
{
    ASSERT_ARGS(Parrot_io_write)
    DECL_CONST_CAST;
    INTVAL result;
    STRING fake;

    if (PMC_IS_NULL(pmc))
        return -1;

    fake.strstart = (char *) PARROT_const_cast(void *, buffer);
    fake.strlen = fake.bufused = length;
    fake.charset = Parrot_default_charset_ptr;
    fake.encoding = Parrot_default_encoding_ptr;

    result = Parrot_io_putps(interp, pmc, &fake);
    return result;
}

/*

=item C<PIOOFF_T Parrot_io_seek>

Moves the read/write position of C<*pmc> to offset C<bytes> from the
position indicated by C<w>. Typically C<w> will be C<0> for the start of
the file, C<1> for the current position, and C<2> for the end.

=cut

*/

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PIOOFF_T
Parrot_io_seek(PARROT_INTERP, ARGMOD(PMC *pmc), PIOOFF_T offset, INTVAL w)
{
    ASSERT_ARGS(Parrot_io_seek)
    if (Parrot_io_is_closed(interp, pmc))
        return -1;

    return Parrot_io_seek_buffer(interp, pmc, offset, w);
}

/*

=item C<PIOOFF_T Parrot_io_tell>

Returns the current read/write position of C<*pmc>.

=cut

*/

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PIOOFF_T
Parrot_io_tell(PARROT_INTERP, ARGMOD(PMC *pmc))
{
    ASSERT_ARGS(Parrot_io_tell)
    if (Parrot_io_is_closed(interp, pmc))
        return -1;

    return Parrot_io_get_file_position(interp, pmc);
    /* return PIO_TELL(interp, pmc); */
}

/*

=item C<INTVAL Parrot_io_peek>

Retrieve the next character in the stream without modifying the stream. Calls
the platform-specific implementation of 'peek'.

=cut

*/

PARROT_EXPORT
INTVAL
Parrot_io_peek(PARROT_INTERP, ARGMOD(PMC *pmc), ARGOUT(STRING **buffer))
{
    ASSERT_ARGS(Parrot_io_peek)
    if (Parrot_io_is_closed(interp, pmc))
        return -1;

    return Parrot_io_peek_buffer(interp, pmc, buffer);
}

/*

=item C<INTVAL Parrot_io_eof>

Returns a boolean value indication whether C<*pmc>'s current read/write
position is C<EOF>.

=cut

*/

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
INTVAL
Parrot_io_eof(PARROT_INTERP, ARGMOD(PMC *pmc))
{
    ASSERT_ARGS(Parrot_io_eof)
    INTVAL result;

    /* io could be null here, but rather than return a negative error
     * we just fake EOF since eof test is usually in a boolean context.
     */
    if (PMC_IS_NULL(pmc))
            return 1;

    Parrot_PCCINVOKE(interp, pmc, CONST_STRING(interp, "eof"), "->I",
            &result);

    return result;

}

/*

=item C<INTVAL Parrot_io_puts>

Writes C<*s> tp C<*pmc>. C string version.

=cut

*/

PARROT_EXPORT
INTVAL
Parrot_io_puts(PARROT_INTERP, ARGMOD(PMC *pmc), ARGIN(const char *s))
{
    ASSERT_ARGS(Parrot_io_puts)
    return Parrot_io_write(interp, pmc, s, strlen(s));
}

/*

=item C<INTVAL Parrot_io_putps>

Writes C<*s> to C<*pmc>. Parrot string version.

=cut

*/

PARROT_EXPORT
INTVAL
Parrot_io_putps(PARROT_INTERP, ARGMOD(PMC *pmc), ARGMOD_NULLOK(STRING *s))
{
    ASSERT_ARGS(Parrot_io_putps)
    INTVAL result;

    if (PMC_IS_NULL(pmc))
        Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_PIO_ERROR,
            "Cannot write to null PMC");

    Parrot_PCCINVOKE(interp, pmc, CONST_STRING(interp, "puts"), "S->I",
            s, &result);
    return result;

}

/*

=item C<INTVAL Parrot_io_fprintf>

Writes a C string format with varargs to C<*pmc>.

=cut

*/

PARROT_EXPORT
INTVAL
Parrot_io_fprintf(PARROT_INTERP, ARGMOD(PMC *pmc), ARGIN(const char *s), ...)
{
    ASSERT_ARGS(Parrot_io_fprintf)
    va_list args;
    INTVAL ret;

    va_start(args, s);

    ret = Parrot_io_putps(interp, pmc, Parrot_vsprintf_c(interp, s, args));

    va_end(args);

    return ret;
}

/*

=item C<INTVAL Parrot_io_printf>

Writes a C string format with varargs to C<stdout>.

=cut

*/

PARROT_EXPORT
INTVAL
Parrot_io_printf(PARROT_INTERP, ARGIN(const char *s), ...)
{
    ASSERT_ARGS(Parrot_io_printf)
    va_list args;
    INTVAL ret;

    va_start(args, s);

    if (interp) {
        STRING * const str = Parrot_vsprintf_c(interp, s, args);
        ret = Parrot_io_putps(interp, _PIO_STDOUT(interp), str);
    }
    else {
        /* Be nice about this...
         **   XXX BD Should this use the default PIO_STDOUT or something?
         */
        ret = vfprintf(stdout, s, args);
    }

    va_end(args);

    return ret;
}

/*

=item C<INTVAL Parrot_io_eprintf>

Writes a C string format with varargs to C<stderr>.

=cut

*/

PARROT_EXPORT
PARROT_IGNORABLE_RESULT
INTVAL
Parrot_io_eprintf(NULLOK(PARROT_INTERP), ARGIN(const char *s), ...)
{
    ASSERT_ARGS(Parrot_io_eprintf)
    va_list args;
    INTVAL ret;

    va_start(args, s);

    if (interp) {
        STRING * const str = Parrot_vsprintf_c(interp, s, args);

        ret = Parrot_io_putps(interp, _PIO_STDERR(interp), str);
    }
    else {
        /* Be nice about this...
        **   XXX BD Should this use the default PIO_STDERR or something?
        */
        ret = vfprintf(stderr, s, args);
    }

    va_end(args);

    return ret;
}

/*

=item C<PIOHANDLE Parrot_io_getfd>

Returns C<*pmc>'s file descriptor, or C<0> if it is not defined.

=cut

*/

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PIOHANDLE
Parrot_io_getfd(PARROT_INTERP, ARGMOD(PMC *pmc))
{
    ASSERT_ARGS(Parrot_io_getfd)
    return Parrot_io_get_os_handle(interp, pmc);
}

/*

=item C<INTVAL Parrot_io_is_tty>

Returns a boolean value indicating whether C<*pmc> is a console/tty.

=cut

*/

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
INTVAL
Parrot_io_is_tty(PARROT_INTERP, ARGMOD(PMC *pmc))
{
    ASSERT_ARGS(Parrot_io_is_tty)
    if (Parrot_io_is_closed(interp, pmc))
        return 0;

    return (Parrot_io_get_flags(interp, pmc) & PIO_F_CONSOLE) ? 1 : 0;
}

/*

=back

=head2 C<Parrot_io_STD*> Functions

=over 4

=item C<PMC * Parrot_io_STDIN>

Returns the C<FileHandle> PMC for C<stdin>.

=cut

*/

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PMC *
Parrot_io_STDIN(PARROT_INTERP)
{
    ASSERT_ARGS(Parrot_io_STDIN)
    return _PIO_STDIN(interp);
}

/*

=item C<PMC * Parrot_io_STDOUT>

Returns the C<FileHandle> PMC for C<stdout>.

=cut

*/

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PMC *
Parrot_io_STDOUT(PARROT_INTERP)
{
    ASSERT_ARGS(Parrot_io_STDOUT)
    return _PIO_STDOUT(interp);
}

/*

=item C<PMC * Parrot_io_STDERR>

Returns the C<FileHandle> PMC for C<stderr>.

=cut

*/

PARROT_EXPORT
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PMC *
Parrot_io_STDERR(PARROT_INTERP)
{
    ASSERT_ARGS(Parrot_io_STDERR)
    return _PIO_STDERR(interp);
}

/*

=back

=head2 Offset Functions

These are used to create offsets for the C<seek> op.

=over 4

=item C<PIOOFF_T Parrot_io_make_offset>

Returns C<offset>.

=cut

*/

PARROT_EXPORT
PIOOFF_T
Parrot_io_make_offset(INTVAL offset)
{
    ASSERT_ARGS(Parrot_io_make_offset)
    return offset;
}

/*

=item C<PIOOFF_T Parrot_io_make_offset32>

C<hi> is shifted 32 bytes to the left and C<or>ed together with C<lo>.
This allows 64-bit seeks with only 32-bit C<INTVALS>.

=cut

*/

PIOOFF_T
Parrot_io_make_offset32(INTVAL hi, INTVAL lo)
{
    ASSERT_ARGS(Parrot_io_make_offset32)
    return ((PIOOFF_T)hi << 31) | lo;
}

/*

=item C<PIOOFF_T Parrot_io_make_offset_pmc>

Returns the return value of the C<get_integer> vtable method on C<*pmc>.

=cut

*/

PIOOFF_T
Parrot_io_make_offset_pmc(PARROT_INTERP, ARGMOD(PMC *pmc))
{
    ASSERT_ARGS(Parrot_io_make_offset_pmc)
    return VTABLE_get_integer(interp, pmc);
}


/*

=back

=head1 SEE ALSO

F<io/unix.c>,
F<io/win32.c>,
F<io/portable.c>,
F<io/io_private.h>.

=cut

*/



/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
