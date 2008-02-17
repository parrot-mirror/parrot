#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# auto_gc-03.t

use strict;
use warnings;
use Test::More tests => 10;
use lib qw( lib t/configure/testlib );
use_ok('config::auto::gc');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
is($trace->store_this_step(), 2,
    "Step stored; has previously been tested");

my $args = process_options(
    {
        argv => [ q{--gc=libc} ],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;
$conf->refresh($trace->get_previous_state());

my $pkg = q{auto::gc};
$conf->add_steps($pkg);
$conf->options->set( %{$args} );

my ( $task, $step_name, $step);
$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );

$conf->data->set('i_malloc' => 1);
my $ret = $step->runstep($conf);
ok( $ret, "$step_name runstep() returned true value" );
is($conf->data->get('gc_flag'), '-DGC_IS_MALLOC',
    "Got expected value for 'gc_flag'");
is($conf->data->get('malloc_header'), 'malloc.h',
    "Got expected value for 'malloc_header'");

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_gc-03.t - test config::auto::gc

=head1 SYNOPSIS

    % prove t/steps/auto_gc-03.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::auto::gc.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::gc, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
