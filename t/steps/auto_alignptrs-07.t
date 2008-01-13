#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# auto_alignptrs-07.t

use strict;
use warnings;
use Test::More tests => 18;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::init::defaults');
use_ok('config::auto::attributes');
use_ok('config::auto::alignptrs');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Test qw( test_step_thru_runstep);

my $args = process_options(
    {
        argv => [ ],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;

test_step_thru_runstep( $conf, q{init::defaults}, $args );
test_step_thru_runstep( $conf, q{auto::attributes}, $args );

my $pkg = q{auto::alignptrs};

$conf->add_steps($pkg);
$conf->options->set( %{$args} );

my ( $task, $step_name, $step);
$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );

my ($results, $try_align, $align);
is(auto::alignptrs::_evaluate_results(q{OK}, 2), 2,
    "Got expected alignment");
is(auto::alignptrs::_evaluate_results(q{OK align}, 2), undef,
    "Got undef as expected");
is(auto::alignptrs::_evaluate_results(q{foobar}, 2), undef,
    "Got undef as expected");

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_alignptrs-07.t - test config::auto::alignptrs

=head1 SYNOPSIS

    % prove t/steps/auto_alignptrs-07.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::auto::alignptrs.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::alignptrs, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
