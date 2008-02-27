#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# init_miniparrot-01.t

use strict;
use warnings;
use Test::More tests => 20;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::init::defaults');
use_ok('config::init::miniparrot');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
ok($trace->store_this_step(), "Step stored");

my $pkg  = q{init::miniparrot};
my $args = process_options(
    {
        argv => [q{--miniparrot}],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;
$conf->refresh($trace->get_previous_state());

is( $conf->data->get('miniparrot'),  undef, "miniparrot is not yet enabled" );
is( $conf->data->get('jitarchname'), undef, "jitarchname undef as expected" );
is( $conf->data->get('jitcpuarch'),  undef, "jitcpuarch undef as expected" );
is( $conf->data->get('jitcpu'),      undef, "jitcpu undef as expected" );
is( $conf->data->get('jitosname'),   undef, "jitosname undef as expected" );

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

ok( $conf->data->get('miniparrot'), "miniparrot is enabled" );
is( $conf->data->get('jitarchname'), 'nojit', "jitarchname as expected" );
is( $conf->data->get('jitcpuarch'),  'i386',  "jitcpuarch as expected" );
is( $conf->data->get('jitcpu'),      'I386',  "jitcpu as expected" );
is( $conf->data->get('jitosname'),   'nojit', "jitosname as expected" );
ok( !$conf->data->get('jitcapable'), "jitcapable as expected" );

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

init_miniparrot-01.t - test config::init::miniparrot

=head1 SYNOPSIS

    % prove t/steps/init_miniparrot-01.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::init::miniparrot.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::init::miniparrot, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
