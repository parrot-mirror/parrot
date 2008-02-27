#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# auto_funcptr-03.t

use strict;
use warnings;
use Test::More tests =>  9;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::auto::funcptr');
use Parrot::BuildUtil;
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Test qw( test_step_thru_runstep);
use IO::CaptureOutput qw| capture |;
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
ok($trace->store_this_step(),
    "Step stored; has previously been tested");

my $args = process_options( {
    argv            => [ q{--verbose} ],
    mode            => q{configure},
} );

my $conf = Parrot::Configure->new();
$conf->refresh($trace->get_previous_state());

my ($task, $step_name, $step, $ret);
my $pkg = q{auto::funcptr};

$conf->add_steps($pkg);
$conf->options->set(%{$args});

$task = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok(defined $step, "$step_name constructor returned defined value");
isa_ok($step, $step_name);
ok($step->description(), "$step_name has description");

{
    my $stdout;
    my $ret = capture(
        sub { auto::funcptr::_set_positive_result($step, $conf); },
        \$stdout,
    );
    is($step->result, q{yes}, "Got expected result");
    like($stdout, qr/yes/, "Got expected verbose output");
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_funcptr-03.t - test config::auto::funcptr

=head1 SYNOPSIS

    % prove t/steps/auto_funcptr-03.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test config::auto::funcptr in the case where the
C<--verbose> option has been set.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::funcptr, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
