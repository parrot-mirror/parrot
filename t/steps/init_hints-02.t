#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# init_hints-02.t

use strict;
use warnings;
use Test::More;
plan( skip_all => 'Macports is Darwin only' ) unless $^O =~ /darwin/;
plan( tests => 32 );
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

########### _get_adjusted_user_options() ##########

my @flags = qw(ccflags linkflags ldflags ld_share_flags ld_load_flags);
my %flags_orig = ();
map { $flags_orig{$_} => $conf->options->get($_) } @flags;
my $fixed = 'foo';
$conf->options->set( ldflags        => $fixed );
$conf->options->set( ld_share_flags => 'bar' );
$conf->options->set( ld_load_flags  => 'baz' );
my $flag = 'ldflags';
is( init::hints::darwin::_get_adjusted_user_options($conf, $flag),
    $fixed, "Got expected value for $flag"); 
$flag = 'ld_share_flags';
is( init::hints::darwin::_get_adjusted_user_options($conf, $flag),
    $fixed, "Got expected value for $flag"); 
$flag = 'ld_load_flags';
is( init::hints::darwin::_get_adjusted_user_options($conf, $flag),
    $fixed, "Got expected value for $flag"); 

$conf->options->set( ldflags        => undef );
$conf->options->set( ld_share_flags => 'bar' );
$conf->options->set( ld_load_flags  => 'foo' );
$fixed = '';
$flag = 'ldflags';
is( init::hints::darwin::_get_adjusted_user_options($conf, $flag),
    $fixed, "Got expected value for $flag"); 
$flag = 'ld_share_flags';
is( init::hints::darwin::_get_adjusted_user_options($conf, $flag),
    $fixed, "Got expected value for $flag"); 
$flag = 'ld_load_flags';
is( init::hints::darwin::_get_adjusted_user_options($conf, $flag),
    $fixed, "Got expected value for $flag"); 

# re-set for next test
map { $conf->options->set($_) => $flags_orig{$_} } @flags;

my $opt = q{-fno-common -DPERL_DARWIN -no-cpp-precomp -fno-strict-aliasing -pipe -I/opt/ -L/Users/me/work/parrot};
$conf->options->set( ldflags => $opt );
$flag = 'ldflags';
is( init::hints::darwin::_get_adjusted_user_options($conf, $flag),
    $opt, "Got expected value for $flag"); 

# re-set for next test
map { $conf->options->set($_) => $flags_orig{$_} } @flags;

########### _precheck() ##########

my ($set_flags, $stored, $verbose);
$flag = 'ccflags';
{
    $set_flags = 'bar';
    $stored = 'baz';
    $verbose = 1;
    my ($stdout, $stderr);
    capture (
        sub { init::hints::darwin::_precheck(
            $flag, $set_flags, $stored, $verbose); },
        \$stdout,
        \$stderr,
    );
    like($stdout, qr/Checking $flag/s,
        "Got expected verbose output for _precheck()");
    like($stdout, qr/User-specified:\s+$set_flags/s,
        "Got expected verbose output for _precheck()");
    like($stdout, qr/Pre-check:\s+$stored/s,
        "Got expected verbose output for _precheck()");
}

{
    $set_flags = q{};
    $stored = q{};
    $verbose = 1;
    my ($stdout, $stderr);
    capture (
        sub { init::hints::darwin::_precheck(
            $flag, $set_flags, $stored, $verbose); },
        \$stdout,
        \$stderr,
    );
    like($stdout, qr/Checking $flag/s,
        "Got expected verbose output for _precheck()");
    like($stdout, qr/User-specified:\s+\(nil\)/s,
        "Got expected verbose output for _precheck()");
    like($stdout, qr/Pre-check:\s+\(nil\)/s,
        "Got expected verbose output for _precheck()");
}

{
    $set_flags = 'bar';
    $stored = 'baz';
    $verbose = 0;
    my ($stdout, $stderr);
    capture (
        sub { init::hints::darwin::_precheck(
            $flag, $set_flags, $stored, $verbose); },
        \$stdout,
        \$stderr,
    );
    ok(! $stdout, "As expected, got no verbose output");
}

########### _postcheck() ##########

my $setting;
$flag = 'ccflags';
my $ccflags_orig = $conf->data->get('ccflags');
{
    $setting = 'foobar';
    $verbose = 1;
    $conf->data->set( ccflags => $setting );
    my ($stdout, $stderr);
    capture (
        sub { init::hints::darwin::_postcheck($conf, $flag, $verbose); },
        \$stdout,
        \$stderr,
    );
    like( $stdout,
        qr/Post-check:\s+$setting/s,
        "Got expected verbose output for _postcheck()"
    );
    # re-set for next test
    $conf->data->set( ccflags => $ccflags_orig );
}

{
    $setting = 'foobar';
    $verbose = 1;
    $conf->data->set( ccflags => undef );
    my ($stdout, $stderr);
    capture (
        sub { init::hints::darwin::_postcheck($conf, $flag, $verbose); },
        \$stdout,
        \$stderr,
    );
    like( $stdout,
        qr/Post-check:\s+\(nil\)/s,
        "Got expected verbose output for _postcheck()"
    );
    # re-set for next test
    $conf->data->set( ccflags => $ccflags_orig );
}

{
    $setting = 'foobar';
    $verbose = 0;
    $conf->data->set( ccflags => $setting );
    my ($stdout, $stderr);
    capture (
        sub { init::hints::darwin::_postcheck($conf, $flag, $verbose); },
        \$stdout,
        \$stderr,
    );
    ok( ! $stdout, "As expected, got no verbose output");
    # re-set for next test
    $conf->data->set( ccflags => $ccflags_orig );
}

########### _strip_ldl_as_needed() ##########

my ( $ldflags_orig, $libs_orig );
( $ccflags_orig, $ldflags_orig, $libs_orig ) =
    $conf->data->get(qw(ccflags ldflags libs));
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

########### --verbose ##########
#
#my $args = process_options(
#    {
#        argv => [q{--verbose}],
#        mode => q{configure},
#    }
#);
#
#my $conf = Parrot::Configure->new;
#
#test_step_thru_runstep( $conf, q{init::defaults}, $args );
#
#my $pkg = q{init::hints};
#
#$conf->add_steps($pkg);
#
#my $serialized = $conf->pcfreeze();
#
#$conf->options->set( %{$args} );
#my $step = test_step_constructor_and_description($conf);
#
## need to capture the --verbose output, because the fact that it does not end
## in a newline confuses Test::Harness
#{
#    my $rv;
#    my $stdout;
#    capture ( sub {$rv = $step->runstep($conf)}, \$stdout);
#    ok( $stdout, "verbose output:  hints were captured" );
#    ok( defined $rv, "runstep() returned defined value" );
#}
#
#$conf->replenish($serialized);
#
########### --verbose; local hints directory ##########
#
#$args = process_options(
#    {
#        argv => [q{--verbose}],
#        mode => q{configure},
#    }
#);
#
#$conf->options->set( %{$args} );
#$step = test_step_constructor_and_description($conf);
#
#my $cwd = cwd();
#{
#    my $tdir = tempdir( CLEANUP => 1 );
#    File::Path::mkpath(qq{$tdir/init/hints})
#        or croak "Unable to create directory for local hints";
#    my $localhints = qq{$tdir/init/hints/local.pm};
#    open my $FH, '>', $localhints
#        or croak "Unable to open temp file for writing";
#    print $FH <<END;
#package init::hints::local;
#use strict;
#sub runstep {
#    return 1;
#}
#1;
#END
#    close $FH or croak "Unable to close temp file after writing";
#    unshift( @INC, $tdir );
#
#    {
#     my $rv;
#     my $stdout;
#     capture ( sub {$rv = $step->runstep($conf)}, \$stdout);
#     ok( $stdout, "verbose output:  hints were captured" );
#     ok( defined $rv, "runstep() returned defined value" );
#    }
#    unlink $localhints or croak "Unable to delete $localhints";
#}
#
#$conf->replenish($serialized);
#
########### --verbose; local hints directory; no runstep() in local hints ##########
#
#$args = process_options(
#    {
#        argv => [q{--verbose}],
#        mode => q{configure},
#    }
#);
#
#$conf->options->set( %{$args} );
#$step = test_step_constructor_and_description($conf);
#
#$cwd = cwd();
#{
#    my $tdir = tempdir( CLEANUP => 1 );
#    File::Path::mkpath(qq{$tdir/init/hints})
#        or croak "Unable to create directory for local hints";
#    my $localhints = qq{$tdir/init/hints/local.pm};
#    open my $FH, '>', $localhints
#        or croak "Unable to open temp file for writing";
#    print $FH <<END;
#package init::hints::local;
#use strict;
#1;
#END
#    close $FH or croak "Unable to close temp file after writing";
#    unshift( @INC, $tdir );
#
#    {
#     my $rv;
#     my $stdout;
#     capture ( sub {$rv = $step->runstep($conf)}, \$stdout);
#     ok( $stdout, "verbose output:  hints were captured" );
#     ok( defined $rv, "runstep() returned defined value" );
#    }
#    unlink $localhints or croak "Unable to delete $localhints";
#}
#
#$conf->replenish($serialized);
#
########### --verbose; imaginary OS ##########
#
#$args = process_options(
#    {
#        argv => [ q{--verbose} ],
#        mode => q{configure},
#    }
#);
#
#$conf->options->set( %{$args} );
#$step = test_step_constructor_and_description($conf);
#{
#    my ($stdout, $stderr, $ret);
#    $conf->data->set_p5( OSNAME => q{imaginaryOS} );
#    my $osname = lc( $conf->data->get_p5( 'OSNAME' ) );
#    my $hints_file = catfile('config', 'init', 'hints', "$osname.pm");
#    capture (
#        sub { $ret = $step->runstep($conf); },
#        \$stdout,
#        \$stderr,
#    );;
#    like(
#        $stdout,
#        qr/No \Q$hints_file\E found/s,
#        "Got expected verbose output when no hints file found"
#    );
#}

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
