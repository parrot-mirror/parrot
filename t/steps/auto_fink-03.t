#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# auto_fink-03.t

use strict;
use warnings;
use Test::More;
plan( skip_all => 'Fink is Darwin only' ) unless $^O =~ /darwin/;
#plan( tests => 12 );
plan qw( no_plan );
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::auto::fink');
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
my $pkg = q{auto::fink};

$conf->add_steps($pkg);
$conf->options->set(%{$args});
$task = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok(defined $step, "$step_name constructor returned defined value");
isa_ok($step, $step_name);
ok($step->description(), "$step_name has description");

# mock no Fink
$step->{fink_conf} = q{my_ridiculous_foobar};
my $msg = q{Fink not installed};
ok($step->runstep($conf), "runstep() returned true value");
is($step->result(), $msg,
    "Got expected result for $msg");

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_fink-03.t - test config::auto::fink

=head1 SYNOPSIS

    % prove t/steps/auto_fink-03.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test config::auto::fink in the case where the OS is
Darwin but Fink is not installed.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::fink, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
