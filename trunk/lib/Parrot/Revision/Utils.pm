# Copyright (C) 2001-2008, The Perl Foundation.
# $Id$
package Parrot::Revision::Utils;
use strict;
use warnings;
use lib qw( lib );
use Parrot::Revision;
use base qw( Exporter );
our @EXPORT_OK = qw(
    get_revision_numbers
    print_src_revision_c
);

sub get_revision_numbers {
    my $current = 0;
    my $config = 0;
    if (-e 'DEVELOPING') {
        $current = $Parrot::Revision::current;
        eval 'use Parrot::Config; $config = $PConfig{revision};';
    }
    return ($current, $config);
}

sub print_src_revision_c {
    my ($current, $config, $script) = @_;
    print <<"EOF";
/* ex: set ro:
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically by $script.
 *
 * Any changes made here will be lost!
 *
 */

/* HEADERIZER HFILE: none */
/* HEADERIZER STOP */

#include "parrot/config.h"

/* also in "parrot/embed.h" */
PARROT_API int Parrot_revision(void);
/* also in "parrot/misc.h" */
PARROT_API int Parrot_config_revision(void);

int Parrot_revision(void)
{
    return $current;
}

int Parrot_config_revision(void)
{
    return $config;
}

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
EOF
    return 1;
}

1;

#################### DOCUMENTATION ####################

=head1 NAME

Parrot::Revision::Utils - Subroutines used in
F<tools/build/revision_c.pl>.

=head1 SYNOPSIS

    use Parrot::Revision::Utils qw(
        get_revision_numbers
        print_src_revision_c
    );

    ($current, $config) = get_revision_numbers();

    print_src_revision_c($current, $config, $script);

=head1 DESCRIPTION

Parrot::Revision::Utils exports on demand two subroutines,
C<get_revision_numbers()> and C<print_src_revision_c()> which are used
in F<tools/build/revision_c.pl>, a Perl 5 program invoked by Parrot's
F<make> program to generate file F<src/revision.c>.  That file, in turn,
provides C function C<Parrot_revision()>.

=head1 SUBROUTINES

=head2 C<get_revision_numbers()>

    ($current, $config) = get_revision_numbers();

=over 4

=item * Purpose

Provide two Parrot repository revision numbers:  the first being the
revision number the last time the user made a commit or an update; the
second being the revision number at which the user last ran
F<Configure.pl>.

=item * Arguments

None.

=item * Return Values

Two-argument list:

=over 4

=item 1 C<current>

The Parrot repository revision number at which the user last made a
commit or an update.

=item 2 C<config>

The Parrot repository revision number prevailing when the user last ran
F<Configure.pl>.

=back

=item * Comment

If the user follows this sequence:

    svn update
    perl Configure.pl
    make

... then, the values for C<current> and C<config> at the point at which
F<make> invokes F<tools/build/revision_c.pl> will be identical.

If, however, the user follows a sequence like this:

    svn update
    perl Configure.pl
    # some time passes and the repository revision number increases
    svn update
    make

... then, the values for C<current> and C<config> at the point at which
F<make> invokes F<tools/build/revision_c.pl> will differ.

=back

=head2 C<print_src_revision_c()>

    print_src_revision_c($current, $config, $0);

=over 4

=item * Purpose

Prints the text for F<src/revision.c>.

=item * Arguments

Three-argument list:  C<current> and C<config> as returned by
C<get_revision_numbers()> (above) and the name of the current script
(typically supplied by C<$0>).

=item * Return Values

True value.

=item * Comment

Output goes to C<STDOUT>.  F<make> redirects this to F<src/revision.c>.

=back

=head1 NOTES

The functionality in this package was transferred from
F<tools/build/revision_c.pl> by James E Keenan.

=head1 SEE ALSO

F<lib/Parrot/Revision.pm>, F<tools/build/revision_c.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
