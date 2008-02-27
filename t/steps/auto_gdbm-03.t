#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# auto_gdbm-03.t

use strict;
use warnings;
use Test::More tests => 14;
use Carp;
use Cwd;
use lib qw( lib t/configure/testlib );
use_ok('config::auto::gdbm');
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
        argv => [ q{--without-gdbm} ],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;
$conf->refresh($trace->get_previous_state());

my $pkg = q{auto::gdbm};
$conf->add_steps($pkg);
$conf->options->set( %{$args} );

my ($task, $step_name, $step);
$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );

my ($test, $has_gdbm, $verbose);

$test = qq{gdbm is working.\n};
$has_gdbm = 0;
$verbose = undef;
$has_gdbm = $step->_evaluate_cc_run($test, $has_gdbm, $verbose);
is($has_gdbm, 1, "'has_gdbm' set as expected");
is($step->result(), 'yes', "Expected result was set");
# Prepare for next test
$step->set_result(undef);

$test = qq{foobar};
$has_gdbm = 0;
$verbose = undef;
$has_gdbm = $step->_evaluate_cc_run($test, $has_gdbm, $verbose);
is($has_gdbm, 0, "'has_gdbm' set as expected");
ok(! defined $step->result(), "Result is undefined, as expected");

{
    my $stdout;
    $test = qq{gdbm is working.\n};
    $has_gdbm = 0;
    $verbose = 1;
    capture(
        sub { $has_gdbm =
            $step->_evaluate_cc_run($test, $has_gdbm, $verbose); },
        \$stdout,
    );
    is($has_gdbm, 1, "'has_gdbm' set as expected");
    is($step->result(), 'yes', "Expected result was set");
    like($stdout, qr/\(yes\)/, "Got expected verbose output");
    # Prepare for next test
    $step->set_result(undef);
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_gdbm-03.t - test config::auto::gdbm

=head1 SYNOPSIS

    % prove t/steps/auto_gdbm-03.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test config::auto::gdbm.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::gdbm, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
