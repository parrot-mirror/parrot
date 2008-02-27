#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# auto_snprintf-02.t

use strict;
use warnings;
use Test::More tests => 12;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::auto::snprintf');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
ok($trace->store_this_step(),
    "Step stored; has previously been tested");

my $args = process_options( {
    argv            => [],
    mode            => q{configure},
} );

my $conf = Parrot::Configure->new();
$conf->refresh($trace->get_previous_state());

my ($task, $step_name, $step, $ret);
my $pkg = q{auto::snprintf};

$conf->add_steps($pkg);
$conf->options->set(%{$args});
$task = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok(defined $step, "$step_name constructor returned defined value");
isa_ok($step, $step_name);
ok($step->description(), "$step_name has description");

my $res;
$res = q{old snprintf};
ok($step->_evaluate_snprintf($conf, $res),
    "_evaluate_snprintf returned true value");
ok($conf->data->get('HAS_OLD_SNPRINTF'),
    "Got expected value");

$res = q{C99 snprintf};
ok($step->_evaluate_snprintf($conf, $res),
    "_evaluate_snprintf returned true value");
ok($conf->data->get('HAS_C99_SNPRINTF'),
    "Got expected value");
ok($conf->data->get('HAS_SNPRINTF'),
    "Got expected value");

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_snprintf-02.t - test config::auto::snprintf

=head1 SYNOPSIS

    % prove t/steps/auto_snprintf-02.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::auto::snprintf.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::snprintf, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
