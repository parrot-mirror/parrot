#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# auto_byteorder-02.t

use strict;
use warnings;
use Test::More tests => 15;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::auto::byteorder');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
is($trace->store_this_step(), 2,
    "Step stored; has previously been tested");

my $args = process_options(
    {
        argv => [ ],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;
$conf->refresh($trace->get_previous_state());

my $pkg = q{auto::byteorder};
$conf->add_steps($pkg);
$conf->options->set( %{$args} );

my ( $task, $step_name, $step);
$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );

my ($byteorder, $rv);

$byteorder = q{8765};
$rv = $step->_evaluate_byteorder($conf, $byteorder);
ok( $rv, "_evaluate_byteorder() returned true value as expected");
is( $conf->data->get( 'byteorder'), $byteorder, "Got expected byteorder");
ok( $conf->data->get( 'bigendian' ), "Not big-endian");
is( $step->result, 'big-endian', "Indeed, big-endian");

$byteorder = q{4321};
$rv = $step->_evaluate_byteorder($conf, $byteorder);
ok( $rv, "_evaluate_byteorder() returned true value as expected");
is( $conf->data->get( 'byteorder'), $byteorder, "Got expected byteorder");
ok( $conf->data->get( 'bigendian' ), "Not big-endian");
is( $step->result, 'big-endian', "Indeed, big-endian");

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_byteorder-02.t - test config::auto::byteorder

=head1 SYNOPSIS

    % prove t/steps/auto_byteorder-02.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::auto::byteorder.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::byteorder, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
