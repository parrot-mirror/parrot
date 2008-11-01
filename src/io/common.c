/*
Copyright (C) 2001-2008, The Perl Foundation.
$Id: $

=head1 NAME

src/io/common.c - Common I/O functions

=head1 DESCRIPTION

This file defines a set of utility functions used by all operating systems.

=cut

*/

#include "src/pmc/pmc_filehandle.h"

/*

=head2 Functions

=over 4

=item C<INTVAL Parrot_io_parse_open_flags>

Parses a Parrot string for file open mode flags (C<r> for read, C<w> for write,
C<a> for append, and C<p> for pipe) and returns the combined generic bit flags.

=cut

*/

PARROT_API
PARROT_WARN_UNUSED_RESULT
INTVAL
Parrot_io_parse_open_flags(ARGIN_NULLOK(STRING *flags))
{
    const char *flagstr;
    const char *s;
    INTVAL flags = 0;

    if (STRING_IS_NULL(flags))
        return 0;

    for (s = flagstr; *s != '\0'; s++) {
        switch (*s) {
            case 'r':
                flags |= PIO_F_READ;
                break;
            case 'w':
                flags |= PIO_F_WRITE;
            case 'a':
                flags |= PIO_F_APPEND;
                break;
            case 'p':
                flags |= PIO_F_PIPE;
                break;
        }
    }

    string_cstring_free(s);
    string_cstring_free(flagstr);

    return flags;
}

/*

=item C<PMC * Parrot_io_new_pmc>

Creates a new I/O filehandle object. The values of C<flags> and C<mode> are set
in the returned PMC.

=cut

*/

PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PMC *
Parrot_io_new_pmc(PARROT_INTERP, INTVAL flags, INTVAL mode)
{
    PMC * const new_io = pmc_new(interp, enum_class_FileHandle);

    Parrot_io_set_flags(interp, new_io, flags);
    Parrot_io_set_mode(interp, new_io, mode);

    return new_io;
}

/*

=item C<void Parrot_io_set_os_handle>

Set the C<os_handle> attribute of the FileHandle object, which stores the
low-level filehandle for the OS.

Currently, this pokes directly into the C struct of the FileHandle PMC. This
needs to change to a general interface that can be used by all subclasses and
polymorphic equivalents of FileHandle. For now, hiding it behind a function, so
it can be cleanly changed later.

Possibly, this function should reset some characteristics of the object (like
buffer and file positions) to their default values.

=cut

*/

PARROT_API
void
Parrot_io_set_os_handle(PARROT_INTERP, ARGIN(PMC *filehandle), PIOHANDLE file_descriptor)
{
    PARROT_FILEHANDLE(filehandle)->os_handle = file_descriptor;
}

/*

=item C<PIOHANDLE Parrot_io_get_os_handle>

Retrieve the C<os_handle> attribute of the FileHandle object, which stores the
low-level filehandle for the OS.

Currently, this pokes directly into the C struct of the FileHandle PMC. This
needs to change to a general interface that can be used by all subclasses and
polymorphic equivalents of FileHandle. For now, hiding it behind a function, so
it can be cleanly changed later.

=cut

*/

PARROT_API
PIOHANDLE
Parrot_io_get_os_handle(PARROT_INTERP, ARGIN(PMC *filehandle))
{
    return PARROT_FILEHANDLE(filehandle)->os_handle;
}

/*

=item C<void Parrot_io_set_flags>

Set the C<flags> attribute of the FileHandle object, which stores bitwise flags
marking filehandle characteristics.

Currently, this pokes directly into the C struct of the FileHandle PMC. This
needs to change to a general interface that can be used by all subclasses and
polymorphic equivalents of FileHandle. For now, hiding it behind a function, so
it can be cleanly changed later.

=cut

*/

PARROT_API
void
Parrot_io_set_flags(PARROT_INTERP, ARGIN(PMC *filehandle), INTVAL flags)
{
    Parrot_FileHandle_attributes *handle_struct = PARROT_FILEHANDLE(filehandle); 
    handle_struct->flags = flags;
}

/*

=item C<void Parrot_io_get_flags>

Set the C<flags> attribute of the FileHandle object, which stores bitwise flags
marking filehandle characteristics.

Currently, this pokes directly into the C struct of the FileHandle PMC. This
needs to change to a general interface that can be used by all subclasses and
polymorphic equivalents of FileHandle. For now, hiding it behind a function, so
it can be cleanly changed later.

=cut

*/

PARROT_API
INTVAL
Parrot_io_get_flags(PARROT_INTERP, ARGIN(PMC *filehandle))
{
    Parrot_FileHandle_attributes *handle_struct = PARROT_FILEHANDLE(filehandle); 
    INTVAL flags = handle_struct->flags;
    return flags;
}

/*

=item C<void Parrot_io_set_mode>

Set the C<mode> attribute of the FileHandle object, which stores bitwise flags
marking filehandle characteristics.

Currently, this pokes directly into the C struct of the FileHandle PMC. This
needs to change to a general interface that can be used by all subclasses and
polymorphic equivalents of FileHandle. For now, hiding it behind a function, so
it can be cleanly changed later.

=cut

*/

PARROT_API
void
Parrot_io_set_mode(PARROT_INTERP, ARGIN(PMC *filehandle), INTVAL mode)
{
    Parrot_FileHandle_attributes *handle_struct = PARROT_FILEHANDLE(filehandle); 
    handle_struct->mode  = mode;
}

/*

=item C<void Parrot_io_set_file_size>

Set the C<file_size> attribute of the FileHandle object, which stores the
current file size.

Currently, this pokes directly into the C struct of the FileHandle PMC. This
needs to change to a general interface that can be used by all subclasses and
polymorphic equivalents of FileHandle. For now, hiding it behind a function, so
it can be cleanly changed later.

=cut

*/

PARROT_API
void
Parrot_io_set_file_size(PARROT_INTERP, ARGIN(PMC *filehandle), PIOOFF_T file_size)
{
    PARROT_FILEHANDLE(filehandle)->file_size = file_size;
}


/*

=item C<void Parrot_io_get_file_size>

Get the C<file_size> attribute of the FileHandle object, which stores the
current file size.


Currently, this pokes directly into the C struct of the FileHandle PMC. This
needs to change to a general interface that can be used by all subclasses and
polymorphic equivalents of FileHandle. For now, hiding it behind a function, so
it can be cleanly changed later.

=cut

*/

PARROT_API
PIOOFF_T
Parrot_io_get_file_size(PARROT_INTERP, ARGIN(PMC *filehandle))
{
    return PARROT_FILEHANDLE(filehandle)->file_size;
}

/*

=item C<unsigned char *Parrot_io_get_buffer_start>

Get the C<buffer_start> attribute of the FileHandle object, which stores
the position of the start of the buffer.

Currently, this pokes directly into the C struct of the FileHandle PMC. This
needs to change to a general interface that can be used by all subclasses and
polymorphic equivalents of FileHandle. For now, hiding it behind a function, so
it can be cleanly changed later.

=cut

*/

PARROT_API
unsigned char *
Parrot_io_get_buffer_start(PARROT_INTERP, ARGIN(PMC *filehandle))
{
    return PARROT_FILEHANDLE(filehandle)->buffer_start;
}

/*

=item C<unsigned char *Parrot_io_get_buffer_next>

Get the C<buffer_next> attribute of the FileHandle object, which stores
the position of the start of the buffer.

Currently, this pokes directly into the C struct of the FileHandle PMC. This
needs to change to a general interface that can be used by all subclasses and
polymorphic equivalents of FileHandle. For now, hiding it behind a function, so
it can be cleanly changed later.

=cut

*/

PARROT_API
unsigned char *
Parrot_io_get_buffer_next(PARROT_INTERP, ARGIN(PMC *filehandle))
{
    return PARROT_FILEHANDLE(filehandle)->buffer_next;
}

/*

=item C<PIOOFF_T Parrot_io_get_file_position>

Get the C<file_pos> attribute of the FileHandle object, which stores
the current file position of the filehandle.

Currently, this pokes directly into the C struct of the FileHandle PMC. This
needs to change to a general interface that can be used by all subclasses and
polymorphic equivalents of FileHandle. For now, hiding it behind a function, so
it can be cleanly changed later.

=cut

*/

PARROT_API
PIOOFF_T
Parrot_io_get_file_position(PARROT_INTERP, ARGIN(PMC *filehandle))
{
    return PARROT_FILEHANDLE(filehandle)->file_pos;
}

/*

=item C<PIOOFF_T Parrot_io_get_last_file_position>

Get the C<file_pos> attribute of the FileHandle object, which stores
the current file position of the filehandle.

Currently, this pokes directly into the C struct of the FileHandle PMC. This
needs to change to a general interface that can be used by all subclasses and
polymorphic equivalents of FileHandle. For now, hiding it behind a function, so
it can be cleanly changed later.

=cut

*/

PARROT_API
PIOOFF_T
Parrot_io_get_last_file_position(PARROT_INTERP, ARGIN(PMC *filehandle))
{
    return PARROT_FILEHANDLE(filehandle)->last_pos;
}

/*

=item C<void Parrot_io_set_file_position>

Get the C<file_pos> attribute of the FileHandle object, which stores the
current file position of the filehandle. Also set the C<last_pos> attribute to
the previous value of C<file_pos>.

Currently, this pokes directly into the C struct of the FileHandle PMC. This
needs to change to a general interface that can be used by all subclasses and
polymorphic equivalents of FileHandle. For now, hiding it behind a function, so
it can be cleanly changed later.

=cut

*/

PARROT_API
void
Parrot_io_set_file_position(PARROT_INTERP, ARGIN(PMC *filehandle), PIOOFF_T file_pos)
{
    Parrot_FileHandle_attributes *handle_struct = PARROT_FILEHANDLE(filehandle); 
    handle_struct->last_pos = handle_struct->file_pos;
    handle_struct->file_pos = file_pos;
}

/*

=back

=head1 SEE ALSO

F<src/io/unix.c>,
F<src/io/win32.c>,
F<src/io/stdio.c>,
F<src/io/io_private.h>.

=cut

*/


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
