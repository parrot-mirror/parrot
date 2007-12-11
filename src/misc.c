/*
Copyright (C) 2001-2007, The Perl Foundation.
$Id$

=head1 NAME

src/misc.c - Miscellaneous functions

=head1 DESCRIPTION

Miscellaneous functions, mainly the C<Parrot_sprintf> family.

Uses a generalized formatting algorithm (F<src/spf_render.c>) with
a specialized vtable (F<src/spf_vtable.c>) to handle argument extraction.

=head2 Functions

The naming convention used is:

=over 4

=item C<Parrot_v?n?sprintf>

A (nearly) drop-in replacement for v?n?sprintf.

=item  C<Parrot_v?sprintf_c>

Takes a C-string format, returns a Parrot string.

=item  C<Parrot_v?sprintf_s>

Takes a Parrot string format, returns a Parrot string.

So the C<_> means "returns Parrot string" and the other letter indicates
the type for the format.

=cut

*/

#define IN_SPF_SYSTEM

#include "parrot/parrot.h"

/* HEADERIZER HFILE: include/parrot/misc.h */

/*

=item C<PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
STRING *
Parrot_vsprintf_s(PARROT_INTERP, ARGIN(STRING *pat), va_list args)>

Almost all the other sprintf variants in this file are implemented in
terms of this function (see C<Parrot_psprintf()> for the exception). It
in turn calls C<Parrot_sprintf_format()> (see F<src/spf_render.c>).

=cut

*/

PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
STRING *
Parrot_vsprintf_s(PARROT_INTERP, ARGIN(STRING *pat), va_list args)
{
    SPRINTF_OBJ obj = va_core;
    obj.data = PARROT_VA_TO_VAPTR(args);

    return Parrot_sprintf_format(interp, pat, &obj);
}

/*

=item C<PARROT_API
PARROT_CANNOT_RETURN_NULL
STRING *
Parrot_vsprintf_c(PARROT_INTERP, ARGIN(const char *pat), va_list args)>

C string version of C<Parrot_vsprintf_s()>.

=cut

*/

PARROT_API
PARROT_CANNOT_RETURN_NULL
STRING *
Parrot_vsprintf_c(PARROT_INTERP, ARGIN(const char *pat), va_list args)
{
    STRING * const realpat = string_make(interp, pat, strlen(pat),
                                  NULL, PObj_external_FLAG);

    STRING * const ret = Parrot_vsprintf_s(interp, realpat, args);

    return ret;
}

/*

=item C<PARROT_API
void
Parrot_vsnprintf(PARROT_INTERP, ARGOUT(char *targ),
                 size_t len, ARGIN(const char *pat), va_list args)>

Similar to C<Parrot_vsprintf()> but with an option to specify the length
(C<len>) of the returned C string.

=cut

*/

PARROT_API
void
Parrot_vsnprintf(PARROT_INTERP, ARGOUT(char *targ),
                 size_t len, ARGIN(const char *pat), va_list args)
{
    if (len == 0)
        return;
    len--;
    if (len) {
        const STRING * const ret = Parrot_vsprintf_c(interp, pat, args);
        /* string_transcode(interp, ret, NULL, NULL, &ret); */

        if (len > ret->bufused) {
            len = ret->bufused;
        }

        if (len)
            memcpy(targ, ret->strstart, len);
    }
    targ[len] = 0;
}

/*

=item C<PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
STRING *
Parrot_sprintf_s(PARROT_INTERP, ARGIN(STRING *pat), ...)>

Calls C<Parrot_vsprintf_s()> with the C<va_list> obtained from C<...>.

=cut

*/

PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
STRING *
Parrot_sprintf_s(PARROT_INTERP, ARGIN(STRING *pat), ...)
{
    STRING *ret;
    va_list args;

    va_start(args, pat);

    ret = Parrot_vsprintf_s(interp, pat, args);

    va_end(args);

    return ret;
}

/*

=item C<PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
STRING *
Parrot_sprintf_c(PARROT_INTERP, ARGIN(const char *pat), ...)>

C string version of C<Parrot_sprintf_s()>.

=cut

*/

PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
STRING *
Parrot_sprintf_c(PARROT_INTERP, ARGIN(const char *pat), ...)
{
    STRING *ret;
    va_list args;

    va_start(args, pat);

    ret = Parrot_vsprintf_c(interp, pat, args);

    va_end(args);

    return ret;
}

/*

=item C<PARROT_API
void
Parrot_snprintf(PARROT_INTERP, ARGOUT(char *targ), size_t len,
                ARGIN(const char *pat), ...)>

Similar to C<Parrot_sprintf()> but with an option to specify the length
(C<len>) of the returned C string.

=cut

*/

PARROT_API
void
Parrot_snprintf(PARROT_INTERP, ARGOUT(char *targ), size_t len,
                ARGIN(const char *pat), ...)
{
    va_list args;

    va_start(args, pat);

    Parrot_vsnprintf(interp, targ, len, pat, args);

    va_end(args);
}

/*

=item C<PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
STRING *
Parrot_psprintf(PARROT_INTERP, ARGIN(STRING *pat), ARGOUT(PMC *ary))>

Calls C<Parrot_sprintf_format()> with the insertion arguments in an
C<Array> PMC.

=cut

*/

PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
STRING *
Parrot_psprintf(PARROT_INTERP, ARGIN(STRING *pat), ARGOUT(PMC *ary))
{
    SPRINTF_OBJ obj = pmc_core;
    obj.data = ary;

    return Parrot_sprintf_format(interp, pat, &obj);
}

/*

=back

=head1 SEE ALSO

F<src/misc.h>, F<src/spf_vtable.c>, F<src/spf_render.c>.

=head1 HISTORY

This was once a simple, vararg-based implementation that existed
completely within this file.  When the file grew to be nearly 1000
lines long, I split it into three. --BD

=cut

*/


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
