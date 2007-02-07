# Copyright (C) 2004-2006, The Perl Foundation.
# $Id: Auxiliary.pm 16894 2007-02-04 22:54:29Z jkeenan $
package Parrot::Ops2c::Auxiliary;
use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK);
@ISA = qw( Exporter );
@EXPORT_OK = qw( Usage getoptions );
use Getopt::Long qw(:config permute);
use Pod::Usage;

#sub Usage {
#    print STDERR <<_EOF_;
#usage: tools/build/ops2pm.pl [--help] [--no-lines] input.ops [input2.ops ...]
#_EOF_
#    return 1;
#}

sub Usage {
    return pod2usage( -exitval => 1, -verbose => 0, -output => \*STDERR );
}

sub getoptions {
    my %flags;
    GetOptions(
        "no-lines"  => \$flags{nolines},
        "help"      => \$flags{help},
        "dynamic|d" => \$flags{dynamic},
        "core"      => \$flags{core},
    );
    return \%flags;
}

1;

#################### DOCUMENTATION ####################

=head1 NAME

Parrot::Ops2c::Auxiliary - Non-method subroutines holding functionality for F<tools/build/ops2c.pl>.

=head1 SYNOPSIS

    use Parrot::Ops2c::Auxiliary qw( Usage getoptions );
    
    Usage();

    $flagref = getoptions();

=cut

=head1 DESCRIPTION

Parrot::Ops2c::Auxiliary provides subroutines called by F<tools/build/ops2c.pl>, a
program which is called at the very beginning of the Parrot F<make> process.
This package is intended to hold subroutines used by that program I<other
than> the object-oriented methods provided by Parrot::Ops2c::Utils.

Extraction of the subroutines exported by this package from
F<tools/build/ops2c.pl> facilitates the testing of their functionality by the
tests in F<t/tools/ops2cutils/*.t>.

=head1 SUBROUTINES

=head2 C<Usage()>

=over 4

=item * Purpose

Display a short description of how to use F<tools/build/ops2c.pl> on
standard output.

    usage: tools/build/ops2pm.pl [--help] [--no-lines] input.ops [input2.ops ...]

=item * Arguments

None.

=item * Return Value

Implicitly returns true upon successful printing.

=back

=head2 C<getoptions>

=over 4

=item * Purpose

Process arguments provided on command-line to F<tools/build/ops2c.pl>.

=item * Arguments

None.

=item * Return Value

Hash reference where any of the following keys may or may not be defined.

   no-lines
   help
   renum

=item * Comment

A wrapper around Getopt::Long::GetOptions() designed to assure testability.

=back

=head1 AUTHOR

Jim Keenan (refactoring code originally found in F<tools/build/ops2c.pl>).

=head1 SEE ALSO

Parrot::Ops2c::Utils.  F<tools/build/ops2c.pl>.

=cut

