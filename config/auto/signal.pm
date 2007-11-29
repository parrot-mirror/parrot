# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$

=head1 NAME

config/auto/signal.pm - Signals

=head1 DESCRIPTION

Determines some signal stuff.

=cut

package auto::signal;

use strict;
use warnings;

use base qw(Parrot::Configure::Step::Base);

use Parrot::Configure::Step ':auto';


sub _init {
    my $self = shift;
    my %data;
    $data{description} = q{Determining some signal stuff};
    $data{args}        = [ qw( miniparrot verbose ) ];
    $data{result}      = q{};
    return \%data;
}

sub runstep {
    my ( $self, $conf ) = @_;

    my $verbose = $conf->options->get('verbose');

    $conf->data->set(
        has___sighandler_t => undef,
        has_sigatomic_t    => undef,
        has_sigaction      => undef,
        has_setitimer      => undef
    );
    if ( defined $conf->options->get('miniparrot') ) {
        $self->set_result('skipped');
        return 1;
    }

    cc_gen('config/auto/signal/test_1.in');
    eval { cc_build(); };
    unless ( $@ || cc_run() !~ /ok/ ) {
        $conf->data->set( has___sighandler_t => 'define' );
        print " (__sighandler_t)" if $verbose;
    }
    cc_clean();

    cc_gen('config/auto/signal/test_2.in');
    eval { cc_build(); };
    unless ( $@ || cc_run() !~ /ok/ ) {
        $conf->data->set( has_sigaction => 'define' );
        print " (sigaction)" if $verbose;
    }
    cc_clean();

    cc_gen('config/auto/signal/test_itimer.in');
    eval { cc_build(); };
    unless ( $@ || cc_run() !~ /ok/ ) {
        $conf->data->set(
            has_setitimer    => 'define',
            has_sig_atomic_t => 'define'
        );
        print " (setitimer) " if $verbose;
    }
    cc_clean();

    # now generate signal constants
    open my $O, ">", "runtime/parrot/include/signal.pasm"
        or die "Cant write runtime/parrot/include/signal.pasm";
    print {$O} <<"EOF";
# DO NOT EDIT THIS FILE.
#
# This file is generated automatically by config/auto/signal.pm
#
# Any changes made here will be lost.
#
EOF
    my ( $i, $name );
    $i = 0;
    foreach $name ( split( ' ', $conf->data->get('p5Config_sig_name') ) ) {
        print {$O} ".constant SIG$name\t$i\n" if $i;
        $i++;
    }
    close $O;

    return 1;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
