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

use base qw(Parrot::Configure::Step);

use Parrot::Configure::Utils ':auto';


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

    my $verbose = $conf->options->get('verbose');

    $conf->cc_gen('config/auto/signal/test_1.in');
    eval { $conf->cc_build(); };
    unless ( $@ || $conf->cc_run() !~ /ok/ ) {
        _handle__sighandler_t($conf, $verbose);
    }
    $conf->cc_clean();

    $conf->cc_gen('config/auto/signal/test_2.in');
    eval { $conf->cc_build(); };
    unless ( $@ || $conf->cc_run() !~ /ok/ ) {
        _handle_sigaction($conf, $verbose);
    }
    $conf->cc_clean();

    $conf->cc_gen('config/auto/signal/test_itimer.in');
    eval { $conf->cc_build(); };
    unless ( $@ || $conf->cc_run() !~ /ok/ ) {
        _handle_setitimer($conf, $verbose);
    }
    $conf->cc_clean();

    # now generate signal constants
    my $signalpasm = "runtime/parrot/include/signal.pasm";
    _print_signalpasm($conf, $signalpasm);

    return 1;
}

sub _handle__sighandler_t {
    my ($conf, $verbose) = @_;
    $conf->data->set( has___sighandler_t => 'define' );
    print " (__sighandler_t)" if $verbose;
    return 1;
}

sub _handle_sigaction {
    my ($conf, $verbose) = @_;
    $conf->data->set( has_sigaction => 'define' );
    print " (sigaction)" if $verbose;
    return 1;
}

sub _handle_setitimer {
    my ($conf, $verbose) = @_;
    $conf->data->set(
        has_setitimer    => 'define',
        has_sig_atomic_t => 'define',
    );
    print " (setitimer) " if $verbose;
    return 1;
}

sub _print_signalpasm {
    my ($conf, $signalpasm) = @_;
    open my $O, ">", $signalpasm
        or die "Cant write $signalpasm";
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
    foreach $name ( split( ' ', $conf->data->get_p5('sig_name') ) ) {
        print {$O} ".macro_const SIG$name\t$i\n" if $i;
        $i++;
    }
    close $O;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
