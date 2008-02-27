#!perl
# Copyright (C) 2001-2007, The Perl Foundation.
# $Id$
# auto_ctags-02.t

use strict;
use warnings;
use Test::More tests => 11;
use Carp;
use lib qw( lib t/configure/testlib );
$ENV{TEST_CTAGS} = [ ( 'foobar' ) ];
use_ok('config::auto::ctags');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use IO::CaptureOutput qw| capture |;
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
ok($trace->store_this_step(),
    "Step stored; has previously been tested");

my $args = process_options(
    {
        argv => [ q{--verbose} ],
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

{
    my $stdout;
    my $ret = capture(
        sub { $step->runstep($conf) },
        \$stdout
    );
    ok( $ret, "$step_name runstep() returned true value" );
    is($step->result(), q{no}, "Got expected result");
    is($conf->data->get('ctags'), 'ctags',
        "Correct value for 'ctags' attribute was set");
}

pass("Keep Devel::Cover happy");
pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

t/steps/auto_ctags-02.t - tests Parrot::Configure step auto::ctags

=head1 SYNOPSIS

    prove t/steps/auto_ctags-02.t

=head1 DESCRIPTION

Regression tests for the L<Parrot::Configure step auto::ctags> module.
This file holds tests for Parrot::Configure step auto::ctags::runstep()
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
