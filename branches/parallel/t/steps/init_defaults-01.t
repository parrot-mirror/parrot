#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# init_defaults-01.t

use strict;
use warnings;
use Test::More tests => 36;
use Carp;
use Cwd;
use File::Copy;
use File::Temp qw| tempdir |;
use lib qw( lib );
use_ok('config::init::defaults');
use Parrot::Configure;
use Parrot::Configure::Step;
use Parrot::Configure::Options qw( process_options );
use base qw(Parrot::Configure::Step);

my $pkg  = q{init::defaults};
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
$conf->add_steps($pkg);

my $serialized = $conf->pcfreeze();

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

$conf->replenish($serialized);

# DEVELOPING non-existence is faked by working in a tempdir which lacks it

my $cwd = cwd();
{
    my $tdir = tempdir( CLEANUP => 1 );
    ok( chdir $tdir, "Changed to temporary directory for testing" );
    ok( copy( "$cwd/VERSION", "$tdir/VERSION" ), "Able to copy VERSION for testing" );

    my $pkg  = q{init::defaults};
    my $args = process_options(
        {
            argv => [],
            mode => q{configure},
        }
    );
    $conf->options->set( %{$args} );

    my $task        = $conf->steps->[-1];
    my $step_name   = $task->step;

    my $step = $step_name->new();
    ok( defined $step, "$step_name constructor returned defined value" );
    isa_ok( $step, $step_name );

    my $ret = $step->runstep($conf);
    ok( defined $ret, "$step_name runstep() returned defined value" );

    unlink "$tdir/VERSION"
        or croak "Unable to unlink file from tempdir after testing";
    ok( chdir $cwd, "Able to change back to directory after testing" );
}

$conf->replenish($serialized);

$args = process_options(
    {
        argv => [ q{--m=32} ],
        mode => q{configure},
    }
);

$conf->options->set( %{$args} );

$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );

$conf->data->set( archname => 'x86_64' );
$conf->data->set( cc => 'cc' );
$conf->data->set( cxx => 'c++' );
$conf->data->set( link => 'cc' );
$conf->data->set( ld => 'env cc' );
$conf->data->set( ld_load_flags => '-bundle -L/usr/local/lib64' );
$conf->data->set( ld_share_flags => '-bundle -L/usr/local/lib64' );
$conf->data->set( ldflags => '-bundle -L/usr/local/lib64' );
$conf->data->set( linkflags => '-bundle -L/usr/local/lib64' );
ok(init::defaults::_64_bit_adjustments($conf),
    "_64_bit_adjustments() returned true");
is($conf->data->get( 'archname' ), 'i386', "Got expected value for 'archname'");
is($conf->data->get( 'cc' ), 'cc -m32', "Got expected value for 'cc'");
is($conf->data->get( 'cxx' ), 'c++ -m32', "Got expected value for 'cxx'");
is($conf->data->get( 'link' ), 'cc -m32', "Got expected value for 'link'");
is($conf->data->get( 'ld' ), 'env cc -m32', "Got expected value for 'ld'");
is($conf->data->get( 'ld_load_flags' ), '-bundle -L/usr/local/lib',
    "Got expected value for 'ld_load_flags'");
is($conf->data->get( 'ld_share_flags' ), '-bundle -L/usr/local/lib',
    "Got expected value for 'ld_share_flags");
is($conf->data->get( 'ldflags' ), '-bundle -L/usr/local/lib',
    "Got expected value for 'ldflags'");
is($conf->data->get( 'linkflags' ), '-bundle -L/usr/local/lib',
    "Got expected value for 'linkflags'");

$conf->replenish($serialized);

$args = process_options(
    {
        argv => [ ],
        mode => q{configure},
    }
);

$conf->options->set( %{$args} );

$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );


$conf->data->set( archname => 'x86_64' );
$conf->data->set( cc => 'cc' );
$conf->data->set( cxx => 'c++' );
$conf->data->set( link => 'cc' );
$conf->data->set( ld => 'env cc' );
$conf->data->set( ld_load_flags => '-bundle -L/usr/local/lib64' );
$conf->data->set( ld_share_flags => '-bundle -L/usr/local/lib64' );
$conf->data->set( ldflags => '-bundle -L/usr/local/lib64' );
$conf->data->set( linkflags => '-bundle -L/usr/local/lib64' );
ok(init::defaults::_64_bit_adjustments($conf),
    "_64_bit_adjustments() returned true");
is($conf->data->get( 'archname' ), 'x86_64', "Got expected value for 'archname'");
is($conf->data->get( 'cc' ), 'cc', "Got expected value for 'cc'");
is($conf->data->get( 'cxx' ), 'c++', "Got expected value for 'cxx'");
is($conf->data->get( 'link' ), 'cc', "Got expected value for 'link'");
is($conf->data->get( 'ld' ), 'env cc', "Got expected value for 'ld'");
is($conf->data->get( 'ld_load_flags' ), '-bundle -L/usr/local/lib64',
    "Got expected value for 'ld_load_flags'");
is($conf->data->get( 'ld_share_flags' ), '-bundle -L/usr/local/lib64',
    "Got expected value for 'ld_share_flags");
is($conf->data->get( 'ldflags' ), '-bundle -L/usr/local/lib64',
    "Got expected value for 'ldflags'");
is($conf->data->get( 'linkflags' ), '-bundle -L/usr/local/lib64',
    "Got expected value for 'linkflags'");
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
