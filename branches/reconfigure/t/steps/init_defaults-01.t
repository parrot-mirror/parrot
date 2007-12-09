#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# init_defaults-01.t

use strict;
use warnings;
use Test::More qw(no_plan); # tests => 6;
use Carp;
use lib qw( lib t/steps/testlib );
use_ok('config::init::defaults');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Auxiliary qw(
    get_step_name
    store_this_step_pure
    get_previous_state
);

my $pkg = get_step_name($0);
ok($pkg, "Step name has true value");
ok(store_this_step_pure($pkg), "State stored");

my $args = process_options(
    {
        argv => [ q{--debugging=0}, q{--profile}, q{--m=32} ],

        # These 3 options are non-default and inside
        # init::defaults::runsteps() they create what, from a
        # testing coverage perspective, create branches or
        # conditions.  The regular run of Configure.pl during
        # coverage analysis will cover the default
        # branches/conditions.  Hence, we supply the
        # non-default options here to increase coverage.
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;
$conf->refresh(get_previous_state($pkg));
$conf->add_steps($pkg);
$conf->options->set( %{$args} );

my $task        = $conf->steps->[-1];
my $step_name   = $task->step;

my $step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );
my $ret = $step->runstep($conf);
ok( defined $ret, "$step_name runstep() returned defined value" );

# RT#44451:  Write a SKIP block which will test the one OS-specific branch in
# init::defaults.

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

init_defaults-01.t - test config::init::defaults

=head1 SYNOPSIS

    % prove t/steps/init_defaults-01.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::init::defaults.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::init::defaults, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
