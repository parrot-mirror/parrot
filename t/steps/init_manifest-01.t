#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# init_manifest-01.t

use strict;
use warnings;
use Test::More tests => 13;
use lib qw( lib t/steps/testlib );
use_ok('config::init::manifest');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Auxiliary qw(
    get_step_name
    get_step_position
    retrieve_state
    dump_state
    get_previous_state
    refresh_from_previous_state
    store_this_step_pure
    update_state
);

my $pkg = get_step_name($0);
ok($pkg, "Step name has true value");
my $step_position = get_step_position($pkg);
like($step_position, qr/^\d+$/, "Step position is numeric");
my $state = retrieve_state();
is(ref($state), q{ARRAY}, "State is an array reference");

ok(store_this_step_pure($pkg),
    "First test file for current step:  state stored");

my $args = process_options(
    {
        argv => [ q{--nomanicheck} ],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;
$conf = refresh_from_previous_state($conf, $pkg);
$conf->add_steps($pkg);
$conf->options->set( %{$args} );

my $task        = $conf->steps->[-1];
my $step_name   = $task->step;

my $step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );
ok(defined ($step->result), "result defined");
ok(! ($step->result), "result not yet true");
my $ret = $step->runstep($conf);
ok( defined $ret, "$step_name runstep() returned defined value" );
is( $step->result, q{skipped},
    "Because of --nomanicheck, result is 'skipped'." );

pass("Completed all tests in $0");


################### DOCUMENTATION ###################

=head1 NAME

init_manifest-01.t - test config::init::manifest

=head1 SYNOPSIS

    % prove t/steps/init_manifest-01.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::init::manifest.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::init::manifest, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

