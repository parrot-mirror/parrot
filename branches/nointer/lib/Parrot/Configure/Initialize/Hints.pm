# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$
package Parrot::Configure::Initialize::Hints;
use strict;
use warnings;
use lib ( "./lib" );

################### SUBROUTINES ###################

sub init_hints {
    my $self = shift;
    my $verbose = $self->{verbose};

    my $hints_used = 0;

    my $hints = "Initialize::Hints::" . lc($^O);

    print "[ $hints " if $verbose;

    eval "use $hints";
    die $@ if $@;

    # Call the runstep method if it exists.
    # Otherwise the step must have done its work when it was loaded.
    $hints->runstep( $self, @_ ) if $hints->can('runstep');
    $hints_used++;

    $hints = "Initialize::Hints::Local";
    print "$hints " if $verbose;
    eval "use $hints";

    unless ($@) {
        $hints->runstep( $self, @_ ) if $hints->can('runstep');
        $hints_used++;
    }

    if ( $hints_used == 0 and $verbose ) {
        print "(no hints) ";
    }

    print "]" if $verbose;
}

1;

#################### DOCUMENTATION ####################

=head1 NAME

Parrot::Configure::Initialize::Hints - Hints configuration

=head1 SYNOPSIS

    use Parrot::Configure::Initialize::Hints;

=head1 DESCRIPTION

Modifies settings to match hints (ANSI C Parrot)'s needs.  This step
primarily overwrites a lot of settings in the Configure database to disable
JIT and match ANSI characteristics.

Centralizing these settings will (hopefully) allow for an eventual move away
from using Configure at all for hints builds.

=head1 SUBROUTINES

=head1 NOTES

The functionality in this package was transferred from the former
C<init::hints> configuration steps by Jim Keenan.

=head1 SEE ALSO

F<Configure.pl>.  Parrot::Configure.  Parrot::Configure::Initialize.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
