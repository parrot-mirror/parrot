#! perl
# Copyright (C) 2008, The Perl Foundation.
# $Id$

use strict;
use warnings;
use Test::More qw(no_plan); # tests => 14;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::auto::crypto');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
ok($trace->store_this_step(), "Step stored");

my $args = process_options(
    {
        argv => [ q{--without-crypto} ],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;
$conf->refresh($trace->get_previous_state());

my $pkg = q{auto::crypto};

$conf->add_steps($pkg);
$conf->options->set( %{$args} );

my ( $task, $step_name, $step);
$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );

my $ret = $step->runstep($conf);
ok( $ret, "$step_name runstep() returned true value" );
is($conf->data->get('has_crypto'), 0,
    "Got expected value for 'has_crypto'");
is($step->result(), q{no}, "Expected result was set");

pass("Keep Devel::Cover happy");
pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_crypto-01.t - test config::auto::crypto

=head1 SYNOPSIS

    % prove t/steps/auto_crypto-01.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test config::auto::crypto in the case where the
C<--without-crypto> option is set.

=head1 HISTORY

Mostly taken from F<t/steps/auto_gdbm-01.t>.

=head1 AUTHOR

Francois Perrad

=head1 SEE ALSO

config::auto::crypto, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
