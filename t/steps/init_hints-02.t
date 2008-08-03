#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# init_hints-02.t

use strict;
use warnings;
use Data::Dumper;$Data::Dumper::Indent=1;
use Test::More;
plan( skip_all => 'Macports is Darwin only' ) unless $^O =~ /darwin/;
plan( tests => 29 );
use Carp;
use Cwd;
use File::Path ();
use File::Spec::Functions qw/catfile/;
use File::Temp qw(tempdir);
use lib qw( lib t/configure/testlib );
use_ok('config::init::defaults');
use_ok('config::init::hints');
use_ok('config::init::hints::darwin');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Test qw(
    test_step_thru_runstep
    test_step_constructor_and_description
);
use IO::CaptureOutput qw | capture |;

my $args = process_options( {
        argv => [],
        mode => q{configure},
} );

my $conf = Parrot::Configure->new;
test_step_thru_runstep( $conf, q{init::defaults}, $args );
my $pkg = q{init::hints};
$conf->add_steps($pkg);
my $serialized = $conf->pcfreeze();
$conf->options->set( %{$args} );
my $step = test_step_constructor_and_description($conf);

########### _precheck() ##########

my ($flag, $stored, $verbose);
$flag = 'ccflags';
{
    $stored = 'baz';
    $verbose = 1;
    my ($stdout, $stderr);
    capture (
        sub { init::hints::darwin::_precheck(
            $flag, $stored, $verbose); },
        \$stdout,
        \$stderr,
    );
    like($stdout, qr/Checking $flag/s,
        "Got expected verbose output for _precheck()");
    like($stdout, qr/Pre-check:\s+$stored/s,
        "Got expected verbose output for _precheck()");
}

{
    $stored = q{};
    $verbose = 1;
    my ($stdout, $stderr);
    capture (
        sub { init::hints::darwin::_precheck(
            $flag, $stored, $verbose); },
        \$stdout,
        \$stderr,
    );
    like($stdout, qr/Checking $flag/s,
        "Got expected verbose output for _precheck()");
    like($stdout, qr/Pre-check:\s+\(nil\)/s,
        "Got expected verbose output for _precheck()");
}

{
    $stored = 'baz';
    $verbose = 0;
    my ($stdout, $stderr);
    capture (
        sub { init::hints::darwin::_precheck(
            $flag, $stored, $verbose); },
        \$stdout,
        \$stderr,
    );
    ok(! $stdout, "As expected, got no verbose output");
}

########### _strip_arch_flags_engine() ##########

my ($arches, $flagsref);
$arches = $init::hints::darwin::defaults{architecture};
$stored = q{foo -arch i386 -arch ppc bar -arch i386 baz};
$flagsref  = {
    map { $_ => '' }
        @{ $init::hints::darwin::defaults{problem_flags} }
};
$flagsref = init::hints::darwin::_strip_arch_flags_engine(
    $arches, $stored, $flagsref, 'ccflags'
);
$flagsref = init::hints::darwin::_strip_arch_flags_engine(
    $arches, $stored, $flagsref, 'ldflags'
);
my $expected = qr/foo\sbar\sbaz/;
like($flagsref->{ccflags}, $expected,
    "-arch flags stripped appropriately from ccflags" );
like($flagsref->{ldflags}, $expected,
    "-arch flags stripped appropriately from ldflags" );

########### _postcheck() ##########

my $setting;
$flag = 'ccflags';
{
    $setting = 'foo bar baz';
    $verbose = 1;
    my ($stdout, $stderr);
    capture (
        sub { init::hints::darwin::_postcheck($flagsref, $flag, $verbose); },
        \$stdout,
        \$stderr,
    );
    like( $stdout,
        qr/Post-check:\s+$setting/s,
        "Got expected verbose output for _postcheck()"
    );
}

{
    $setting = 'foo bar baz';
    $verbose = 0;
    my ($stdout, $stderr);
    capture (
        sub { init::hints::darwin::_postcheck($flagsref, $flag, $verbose); },
        \$stdout,
        \$stderr,
    );
    ok( ! $stdout, "As expected, got no verbose output");
}

########### _strip_arch_flags() ##########

my $ccflags_orig  = $conf->data->get( 'ccflags' );
my $ldflags_orig  = $conf->data->get( 'ldflags' );
$conf->data->set( ccflags =>
    q{foo -arch i386 -arch ppc bar -arch i386 baz} );
$conf->data->set( ldflags =>
    q{foo -arch i386 -arch ppc bar -arch i386 baz -arch ppc samba} );
$verbose = 0;
$flagsref = init::hints::darwin::_strip_arch_flags($conf, $verbose);
like( $flagsref->{ccflags}, qr/foo\sbar\sbaz/,
    "-arch flags stripped appropriately for ccflags" );
like( $flagsref->{ldflags}, qr/foo\sbar\sbaz\ssamba/,
    "-arch flags stripped appropriately for ldflags" );

$verbose = 1;
{
    my ($stdout, $stderr);
    capture( sub { $flagsref =
        init::hints::darwin::_strip_arch_flags($conf, $verbose); },
        \$stdout,
        \$stderr,
    );
    like( $flagsref->{ccflags}, qr/foo\sbar\sbaz/,
        "-arch flags stripped appropriately for ccflags" );
    like( $flagsref->{ldflags}, qr/foo\sbar\sbaz\ssamba/,
        "-arch flags stripped appropriately for ldflags" );
    like( $stdout,
        qr/Stripping -arch flags due to Apple multi-architecture build problems/,
        "Got expected verbose output from _strip_arch_flags()" );
}

# re-set for next test
$conf->data->set( ccflags => $ccflags_orig );
$conf->data->set( ldflags => $ldflags_orig );

########### _strip_ldl_as_needed() ##########

my $libs_orig = $conf->data->get( 'libs' );
my $uname_orig = $init::hints::darwin::defaults{uname};
my $libs;

$init::hints::darwin::defaults{uname} = '8.1.0';
$libs = q{-ldlfoobar};
$libs = init::hints::darwin::_strip_ldl_as_needed($libs);
is($libs, q{foobar}, "'-ldl' stripped as expected");

$init::hints::darwin::defaults{uname} = '6.1.0';
$libs = q{-ldlfoobar};
$libs = init::hints::darwin::_strip_ldl_as_needed($libs);
is($libs, q{-ldlfoobar}, "'-ldl' not stripped, as expected");

# re-set for next test
$conf->data->set( ccflags => $ccflags_orig );
$init::hints::darwin::defaults{uname} = $uname_orig;

########### _set_deployment_environment()##########
{
    local $ENV{'MACOSX_DEPLOYMENT_TARGET'} = undef;
    my $sw_vers_orig = $init::hints::darwin::defaults{sw_vers};
    $init::hints::darwin::defaults{sw_vers} = qq{99.88.77\n};
    init::hints::darwin::_set_deployment_environment();
    is( $ENV{'MACOSX_DEPLOYMENT_TARGET'}, q{99.88},
        "Got expected environmental setting");

    # re-set for next test
    $init::hints::darwin::defaults{sw_vers} = $sw_vers_orig;

    local $ENV{'MACOSX_DEPLOYMENT_TARGET'} = q{66.55};
    init::hints::darwin::_set_deployment_environment();
    is( $ENV{'MACOSX_DEPLOYMENT_TARGET'}, q{66.55},
        "Got expected environmental setting");
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

init_hints-02.t - test init::hints::darwin

=head1 SYNOPSIS

    % prove t/steps/init_hints-02.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test init::hints::darwin.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::init::hints, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
