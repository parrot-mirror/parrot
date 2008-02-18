#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# auto_env-02.t

use strict;
use warnings;
use Test::More tests => 12;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::auto::env');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
is($trace->store_this_step(), 2,
    "Step stored; has previously been tested");

my $args = process_options( {
    argv            => [],
    mode            => q{configure},
} );

my $conf = Parrot::Configure->new();
$conf->refresh($trace->get_previous_state());

my ($task, $step_name, $step, $ret);
my $pkg = q{auto::env};

$conf->add_steps($pkg);
$conf->options->set(%{$args});
$task = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok(defined $step, "$step_name constructor returned defined value");
isa_ok($step, $step_name);
ok($step->description(), "$step_name has description");

my ($setenv, $unsetenv);

$setenv = 1;
$unsetenv = 1;
$step->_evaluate_env($conf, $setenv, $unsetenv);
is($step->result(), q{both}, "Got expected result");

$setenv = 1;
$unsetenv = 0;
$step->_evaluate_env($conf, $setenv, $unsetenv);
is($step->result(), q{setenv}, "Got expected result");

$setenv = 0;
$unsetenv = 1;
$step->_evaluate_env($conf, $setenv, $unsetenv);
is($step->result(), q{unsetenv}, "Got expected result");

$setenv = 0;
$unsetenv = 0;
$step->_evaluate_env($conf, $setenv, $unsetenv);
is($step->result(), q{no}, "Got expected result");

pass("Keep Devel::Cover happy");
pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_env-02.t - test config::auto::env

=head1 SYNOPSIS

    % prove t/steps/auto_env-02.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test config::auto::env::_evaluate_env(), an
internal subroutine, in the various permutations of having or lacking
C<setenv> and C<unsetenv>.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::env, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
