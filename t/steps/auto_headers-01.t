#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# auto_headers-01.t

use strict;
use warnings;
use Test::More tests =>  35;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::init::defaults');
use_ok('config::auto::headers');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Test qw(
    test_step_thru_runstep
    rerun_defaults_for_testing
);
use IO::CaptureOutput qw | capture |;

my $args = process_options(
    {
        argv => [ q{--miniparrot} ],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;

my $serialized = $conf->pcfreeze();

test_step_thru_runstep( $conf, q{init::defaults}, $args );
my $pkg = q{auto::headers};

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
is($step->result(), q{skipped}, "Expected result was set");

$conf->replenish($serialized);

$args = process_options(
    {
        argv => [ ],
        mode => q{configure},
    }
);

rerun_defaults_for_testing($conf, $args );

$conf->add_steps($pkg);
$conf->options->set( %{$args} );

$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );

$ret = $step->runstep($conf);
ok( $ret, "$step_name runstep() returned true value" );
is($step->result(), q{}, "Result is empty string as expected");

$conf->replenish($serialized);

$args = process_options(
    {
        argv => [ q{--verbose} ],
        mode => q{configure},
    }
);

rerun_defaults_for_testing($conf, $args );

$conf->add_steps($pkg);
$conf->options->set( %{$args} );

$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );

{
    my $rv;
    my $stdout;
    capture ( sub {$rv = $step->runstep($conf) }, \$stdout);
    ok( $stdout, "verbose output captured" );
    ok( $rv, "$step_name runstep() returned true value" );
    is($step->result(), q{}, "Result is empty string as expected");
}

$conf->replenish($serialized);

$args = process_options(
    {
        argv => [ ],
        mode => q{configure},
    }
);

rerun_defaults_for_testing($conf, $args );

$conf->add_steps($pkg);
$conf->options->set( %{$args} );

$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );

auto::headers::_set_from_Config($conf);
ok(! $conf->data->get('i_niin'), "Mapping made correctly");

{
    $conf->data->set_p5( OSNAME => "msys" );
    my %extra_headers =
        map {$_, 1} auto::headers::_list_extra_headers($conf);
    ok($extra_headers{'sysmman.h'}, "Special header set for msys");
    ok($extra_headers{'netdb.h'}, "Special header set for msys");
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_headers-01.t - test config::auto::headers

=head1 SYNOPSIS

    % prove t/steps/auto_headers-01.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test config::auto::headers with the C<miniparrot>
option set.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::headers, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
