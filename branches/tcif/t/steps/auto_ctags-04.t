#!perl
# Copyright (C) 2001-2007, The Perl Foundation.
# $Id$
# auto_ctags-04.t

use strict;
use warnings;
use Test::More tests => 12;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::auto::ctags');
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
        argv => [ ],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;
$conf->refresh($trace->get_previous_state());

my $pkg = q{auto::ctags};
$conf->add_steps($pkg);
$conf->options->set( %{$args} );

my ( $task, $step_name, $step);
$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );

ok(auto::ctags::_probe_for_ctags_output('Exuberant Ctags', 0),
    "Probe returned true when output matched");

ok(! auto::ctags::_probe_for_ctags_output('alpha', 0),
    "Probe returned false when output matched");

{
    my $stdout;
    my $rv = capture(
        sub { auto::ctags::_probe_for_ctags_output('Exuberant Ctags', 1) },
        \$stdout
    );
    ok($rv, "Probe returned true when output matched");
}

{
    my $stdout;
    my $rv = capture(
        sub { auto::ctags::_probe_for_ctags_output('alpha', 1) },
        \$stdout
    );
    ok(! $rv, "Probe returned false when output matched");
}

pass("Keep Devel::Cover happy");
pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

t/steps/auto_ctags-04.t - tests Parrot::Configure step auto::ctags

=head1 SYNOPSIS

    prove t/steps/auto_ctags-04.t

=head1 DESCRIPTION

Regression tests for the L<Parrot::Configure step auto::ctags> module.
This file holds tests for Parrot::Configure step
auto::ctags::_probe_for_ctags_output()
(a non-exported subroutine).

=head1 AUTHOR

Paul Cochrane <paultcochrane at gmail dot com>

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
