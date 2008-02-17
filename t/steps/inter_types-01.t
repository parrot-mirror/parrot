#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# inter_types-01.t

use strict;
use warnings;
use Test::More tests =>  8;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::inter::types');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
is($trace->store_this_step(), 1, "Step stored");

my $args = process_options(
    {
        argv => [],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;
$conf->refresh($trace->get_previous_state());

my $pkg = q{inter::types};
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

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

inter_types-01.t - test config::inter::types

=head1 SYNOPSIS

    % prove t/steps/inter_types-01.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::inter::types.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::inter::types, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
