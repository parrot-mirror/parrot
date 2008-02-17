#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# auto_signal-03.t

use strict;
use warnings;
use Test::More tests => 17;
use Carp;
use Cwd;
use lib qw( lib t/configure/testlib );
use_ok('config::auto::signal');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use IO::CaptureOutput qw| capture |;
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
is($trace->store_this_step(), 2,
    "Step stored; has previously been tested");

my $args = process_options(
    {
        argv => [ q{--verbose} ],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;
$conf->refresh($trace->get_previous_state());

my $pkg = q{auto::signal};
$conf->add_steps($pkg);
$conf->options->set( %{$args} );

my ( $task, $step_name, $step);
$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );

my $verbose = 1;
{
    my ($rv, $stdout);
    capture(
        sub { $rv = auto::signal::_handle__sighandler_t($conf, $verbose); },
        \$stdout,
    );
    ok($rv, "_handle__sighandler_t() returned true value");
    is($conf->data->get( 'has___sighandler_t'), 'define',
        "Got expected value for has__sighandler_t");
    like($stdout, qr/__sighandler_t/, "Got expected verbose output");
}

{
    my ($rv, $stdout);
    capture(
        sub { $rv = auto::signal::_handle_sigaction($conf, $verbose); },
        \$stdout,
    );
    ok($rv, "_handle_sigaction() returned true value");
    is($conf->data->get( 'has_sigaction'), 'define',
        "Got expected value for has_sigaction");
    like($stdout, qr/sigaction/, "Got expected verbose output");
}

{
    my ($rv, $stdout);
    capture(
        sub { $rv = auto::signal::_handle_setitimer($conf, $verbose); },
        \$stdout,
    );
    ok($rv, "_handle_setitimer() returned true value");
    is($conf->data->get( 'has_setitimer'), 'define',
        "Got expected value for has_setitimer");
    is($conf->data->get( 'has_sig_atomic_t'), 'define',
        "Got expected value for has_sig_atomic_t");
    like($stdout, qr/setitimer/s, "Got expected verbose output");
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_signal-03.t - test config::auto::signal

=head1 SYNOPSIS

    % prove t/steps/auto_signal-03.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::auto::signal.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::signal, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

