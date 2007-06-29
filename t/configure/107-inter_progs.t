#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 107-inter_progs.t

use strict;
use warnings;
use Test::More qw(no_plan); # tests =>  2;
use Carp;
use Data::Dumper;
use Tie::Filehandle::Preempt::Stdin;
use lib qw( . lib ../lib ../../lib );
use_ok('config::inter::progs');
use Parrot::BuildUtil;
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::IO::Capture::Mini;

=for hints_for_testing Testing and refactoring of inter::progs should
entail understanding of issues discussed in the following RT tickets:
http://rt.perl.org/rt3/Ticket/Display.html?id=43174;
http://rt.perl.org/rt3/Ticket/Display.html?id=43173; and
http://rt.perl.org/rt3/Ticket/Display.html?id=41168.  You will have to
determine a way to test a user response to a prompt.

=cut

my (@prompts, $object, @entered);
@prompts = map { q{foo_} . $_ } 
    qw| alpha beta gamma delta epsilon zeta eta theta iota kappa |;
$object = tie *STDIN, 'Tie::Filehandle::Preempt::Stdin', @prompts;
can_ok('Tie::Filehandle::Preempt::Stdin', ('READLINE'));
isa_ok($object, 'Tie::Filehandle::Preempt::Stdin');

my $pkg = q{inter::progs};
my $parrot_version = Parrot::BuildUtil::parrot_version();
my $args = process_options( {
    argv            => [ q{--ask} ],
    script          => $0,
    parrot_version  => $parrot_version,
    svnid           => '$Id$',
} );

my $conf = Parrot::Configure->new();
$conf->add_steps($pkg);
$conf->options->set(%{$args});

my $task = $conf->steps->[0];
my $step_name   = $task->step;
my @step_params = @{ $task->params };

my $step = $step_name->new();
ok(defined $step, "$step_name constructor returned defined value");
isa_ok($step, $step_name);
ok($step->description(), "$step_name has description");
# print STDERR Dumper ($conf, $step);
# need to capture the --verbose output, because the fact that it does not end
# in a newline confuses Test::Harness
{
    my $tie_out = tie *STDOUT, "Parrot::IO::Capture::Mini"
        or croak "Unable to tie";
    my $ret = $step->runstep($conf);
    my @more_lines = $tie_out->READLINE;
    ok(@more_lines, "prompts were captured");
    ok(defined $ret, "$step_name runstep() returned defined value");
}

$object = undef;
untie *STDIN;

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

107-inter_progs.t - test config::inter::progs

=head1 SYNOPSIS

    % prove t/configure/107-inter_progs.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::inter::progs.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::inter::progs, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
