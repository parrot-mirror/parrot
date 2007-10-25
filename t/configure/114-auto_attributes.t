#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 114-auto_attributes.t

use strict;
use warnings;
use Test::More tests => 11;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::init::defaults');
use_ok('config::auto::attributes');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Test qw( test_step_thru_runstep);

my $pkg = q{auto::attributes};

my $args = process_options( {
    argv            => [ qq{--verbose-step=$pkg} ],
    mode            => q{configure},
} );

my $conf = Parrot::Configure->new();

test_step_thru_runstep($conf, q{init::defaults}, $args);

my ($task, $step_name, @step_params, $step, $ret);

$conf->add_steps($pkg);
$conf->options->set(%{$args});
$task = $conf->steps->[1];
$step_name   = $task->step;
@step_params = @{ $task->params };

$step = $step_name->new();
ok(defined $step, "$step_name constructor returned defined value");
isa_ok($step, $step_name);
ok($step->description(), "$step_name has description");

# Can't use Parrot::IO::Capture::Mini to tie STDOUT here because the C
# programs inside runstep() are messing with STDOUT.
# So we'll have to infer that verbose output was printed from the
# coverage report.
$ret = $step->runstep($conf);
ok( defined $ret, "$step_name runstep() returned defined value" );

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

114-auto_attributes.t - test config::auto::attributes

=head1 SYNOPSIS

    % prove t/configure/114-auto_attributes.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::auto::attributes.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::attributes, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
