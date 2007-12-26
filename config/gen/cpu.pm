# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$

=head1 NAME

config/gen/cpu.pm - CPU specific Files

=head1 DESCRIPTION

Runs C<runstep()> in F<config/gen/cpu/${cpuarch}/auto.pm> if it exists.

=cut

package gen::cpu;

use strict;
use warnings;

use base qw(Parrot::Configure::Step::Base);

use Parrot::Configure::Step qw(copy_if_diff);
use Carp;


sub _init {
    my $self = shift;
    my %data;
    $data{description} = q{Generating CPU specific stuff};
    $data{args}        = [ qw( miniparrot verbose ) ];
    $data{result}      = q{};
    return \%data;
}

sub runstep {
    my ( $self, $conf ) = @_;

    if ( $conf->options->get('miniparrot') ) {
        $self->set_result('skipped');
        return 1;
    }

    my $verbose = $conf->options->get('verbose');

    $conf->data->add( ' ', TEMP_atomic_o => '' );    # assure a default

    my $hints = "gen::cpu::" . $conf->data->get('cpuarch') . "::auto";

    print "\t(cpu hints = '$hints') " if $verbose;

    eval "use $hints";
    unless ($@) {
        $hints->runstep( $conf, @_ );
    }
    else {
        print "(no cpu specific hints)" if $verbose;
    }

    return 1;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
