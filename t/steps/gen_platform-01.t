#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# gen_platform-01.t

use strict;
use warnings;
use Test::More tests => 16;
use Carp;
use lib qw( lib );
use_ok('config::gen::platform');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Test qw(
    test_step_thru_runstep
    test_step_constructor_and_description
);
use IO::CaptureOutput qw( capture );

my $args = process_options(
    {
        argv => [ ],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;
my $pkg = q{gen::platform};
$conf->add_steps($pkg);
$conf->options->set( %{$args} );
my $step = test_step_constructor_and_description($conf);

ok(-f $step->{platform_interface},
    "Located required platform interface header");

my $platform_orig = $conf->data->get_p5('OSNAME');
my $archname_orig = $conf->data->get_p5('archname');
$conf->data->set_p5( archname => 'foo-bar' );
my $verbose = 0;

$conf->options->set( miniparrot => 1 );
is( gen::platform::_get_platform( $conf, $verbose ), q{ansi},
    "Got expected platform for miniparrot");
$conf->options->set( miniparrot => undef );

$conf->data->set_p5( OSNAME => 'msys' );
is( gen::platform::_get_platform( $conf, $verbose ), q{win32},
    "Got expected platform for msys");

$conf->data->set_p5( OSNAME => 'mingw' );
is( gen::platform::_get_platform( $conf, $verbose ), q{win32},
    "Got expected platform for mingw");

$conf->data->set_p5( OSNAME => 'MSWin32' );
is( gen::platform::_get_platform( $conf, $verbose ), q{win32},
    "Got expected platform for MSWin32");

# re-set to original values
$conf->data->set_p5( OSNAME => $platform_orig );
$conf->data->set_p5( archname => $archname_orig );

$conf->data->set_p5( archname => 'ia64-bar' );
is( gen::platform::_get_platform( $conf, $verbose ), q{ia64},
    "Got expected platform for ia64");

$conf->data->set_p5( archname => 'foo-bar' );
$conf->data->set_p5( OSNAME => 'foo' );
{
    $verbose = 1;
    my ($stdout, $stderr, $rv);
    my $expected = q{generic};
    capture(
        sub { $rv = gen::platform::_get_platform( $conf, $verbose ) },
        \$stdout,
        \$stderr,
    );
    is( $rv, $expected, "Got expected platform for foo");
    like( $stdout, qr/platform='$expected'/, "Got expected verbose output");
}

# re-set to original values
$conf->data->set_p5( archname => $archname_orig );
$conf->data->set_p5( OSNAME => $platform_orig );

my $TEMP_generated_orig = $conf->data->get('TEMP_generated');
{
    $verbose = 1;
    my ($stdout, $stderr, $rv);
    my $expected = q{foo};
    $conf->data->set( TEMP_generated => $expected );
    capture(
        sub { $rv = gen::platform::_get_generated( $conf, $verbose ) },
        \$stdout,
        \$stderr,
    );
    is( $rv, $expected, "Got expected generated");
    like( $stdout, qr/\($expected\)/, "Got expected verbose output");
}
$conf->data->set( TEMP_generated => undef );
$verbose = 0;
is( gen::platform::_get_generated( $conf, $verbose ), q{},
    "Got expected generated");

# re-set to original values
$conf->data->set( TEMP_generated => $TEMP_generated_orig );

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

gen_platform-01.t - test config::gen::platform

=head1 SYNOPSIS

    % prove t/steps/gen_platform-01.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::gen::platform.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::gen::platform, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
