#! perl
# Copyright (C) 2008, The Perl Foundation.
# $Id$
# 061-parallel.t

use strict;
use warnings;

use Test::More tests => 13;
use Carp;
use lib qw( lib );
use IO::CaptureOutput qw | capture |;
use Parrot::Configure::Parallel::Trace;

my $trace;

eval { $trace = Parrot::Configure::Parallel::Trace->new(); };
like($@, qr/^Need to provide name of test script/,
    "Constructor correctly failed due to lack of argument");

my $base = q{fake_alpha-01.t};
eval { $trace =
    Parrot::Configure::Parallel::Trace->new(qq{t/pseudo/$base}); };
like($@, qr/^Cannot parse test file name $base/,
    "Constructor correctly failed due to argument not related to config step class");

@Parrot::Configure::Step::List::steps = qw(
    init::alpha
    auto::beta
    inter::gamma
);
$trace =
    Parrot::Configure::Parallel::Trace->new('t/pseudo/init_alpha-01.t');
ok(defined $trace, "Constructor returned defined value");

is($trace->get_step_name(), 'init::alpha',
    "Got expected step class name");

is($trace->get_step_position(), 1,
    "Got expected step class position");

my $stepsref = $trace->get_all_step_positions();
is($stepsref->{'init::alpha'}, 1,
    "Got expected step class position");
is($stepsref->{'auto::beta'}, 2,
    "Got expected step class position");
is($stepsref->{'inter::gamma'}, 3,
    "Got expected step class position");

$Parrot::Configure::Parallel::Trace::sto = q{.nonexistent.sto};
$trace =
    Parrot::Configure::Parallel::Trace->new('t/pseudo/auto_beta-01.t');
ok(defined $trace, "New constructor returned defined value");
my $stateref = $trace->retrieve_state();
is(ref($stateref), 'ARRAY',
    "retrieve_state() returned array ref");
is(scalar( @{$stateref} ), 0,
    "No Storable object means retrieve_state() returns ref to empty array");

my ($stdout, $stderr);
capture(
    sub { $trace->dump_state(); },
    \$stdout,
);
like($stdout, qr/^\$VAR1.*\[\]/, "Got expected Dumper output");

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

061-parallel.t - Tests for Parrot::Configure::Parallel::Trace

=head1 SYNOPSIS

    % prove t/configure/061-parallel.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file examine what happens when you run
Parrot::Configure::Parallel::Trace.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure::Parallel, Parrot::Configure::Parallel::Trace,
F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
