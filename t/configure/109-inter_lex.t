#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 109-inter_lex.t

use strict;
use warnings;
use Test::More qw(no_plan); # tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib t/configure/testlib );
use_ok('config::init::defaults');
use_ok('config::inter::lex');
use Parrot::BuildUtil;
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::IO::Capture::Mini;
use Auxiliary qw( test_step_thru_runstep);
use Tie::Filehandle::Preempt::Stdin;

=for hints_for_testing Since inter::lex probes for the lex program found
on a particular OS, it will probably be difficult to achieve high branch
or condition coverage.  Check latest reports of Parrot configuration
tools testing coverage to see where your time is best devoted.  You will
have to determine a way to test a user response to a prompt.

=cut

my $parrot_version = Parrot::BuildUtil::parrot_version();
my $args = process_options( {
    argv            => [ q{--ask} ],
    script          => $0,
    parrot_version  => $parrot_version,
    svnid           => '$Id$',
} );

my $conf = Parrot::Configure->new;

test_step_thru_runstep($conf, q{init::defaults}, $args, 0);

my (@prompts, $object, @entered);
@prompts = map { q{foo_} . $_ } 
    qw| alpha |;
$object = tie *STDIN, 'Tie::Filehandle::Preempt::Stdin', @prompts;
can_ok('Tie::Filehandle::Preempt::Stdin', ('READLINE'));
isa_ok($object, 'Tie::Filehandle::Preempt::Stdin');

my ($task, $step_name, @step_params, $step, $ret);
my $pkg = q{inter::lex};

$conf->add_steps($pkg);
$conf->options->set(%{$args});

$task = $conf->steps->[1];
$step_name   = $task->step;
@step_params = @{ $task->params };

$step = $step_name->new();
ok(defined $step, "$step_name constructor returned defined value");
isa_ok($step, $step_name);
ok($step->description(), "$step_name has description");
$ret = $step->runstep($conf);
ok(defined $ret, "$step_name runstep() returned defined value");

$object = undef;
untie *STDIN;

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

109-inter_lex.t - test config::inter::lex

=head1 SYNOPSIS

    % prove t/configure/109-inter_lex.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::inter::lex.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::inter::lex, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
