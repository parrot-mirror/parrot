# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$
package Parrot::Configure::Initialize::Headers;
use strict;
use warnings;
use ExtUtils::Manifest qw(maniread);
use lib ( "./lib" );

################### SUBROUTINES ###################

sub init_headers {
    my $self = shift;
    my $inc = 'include/parrot';

    my @headers = (
        sort
            map { m{^$inc/(.*\.h)\z} }
            keys %{ maniread() }
    );

    $_ = "\$(INC_DIR)/$_" for @headers;
    my $TEMP_nongen_headers = join( "\\\n        ", @headers );

    $self->set(
        inc                 => $inc,
        TEMP_nongen_headers => $TEMP_nongen_headers,
    );
    return 1;
}

1;

#################### DOCUMENTATION ####################

=head1 NAME

Parrot::Configure::Initialize::Headers - Headers configuration

=head1 SYNOPSIS

    use Parrot::Configure::Initialize::Headers;

=head1 DESCRIPTION

Modifies settings to match headers (ANSI C Parrot)'s needs.  This step
primarily overwrites a lot of settings in the Configure database to disable
JIT and match ANSI characteristics.

Centralizing these settings will (hopefully) allow for an eventual move away
from using Configure at all for headers builds.

=head1 SUBROUTINES

=head1 NOTES

The functionality in this package was transferred from the former
C<init::headers> configuration steps by Jim Keenan.

=head1 SEE ALSO

F<Configure.pl>.  Parrot::Configure.  Parrot::Configure::Initialize.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
