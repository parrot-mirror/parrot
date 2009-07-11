#! perl
# Copyright (C) 2009, Parrot Foundation.
# $Id$
# init/hints/darwin-01.t

use strict;
use warnings;
use Test::More;
plan( skip_all => 'only needs testing on Darwin' ) unless $^O =~ /darwin/i;
plan( tests =>  26 );
#use Test::More qw(no_plan); # tests => 26;

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

my ($args, $step_list_ref) = process_options(
    {
        argv => [],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;

test_step_thru_runstep( $conf, q{init::defaults}, $args );

##### Tests of some internal subroutines #####

##### _precheck() #####

my $problematic_flag = 'ccflags';
my $stored = $conf->data->get($problematic_flag);

{
    my ($stdout, $stderr);
    capture(
        sub { init::hints::darwin::_precheck(
            $problematic_flag, $stored, 0
        ) },
        \$stdout,
        \$stderr,
    );
    ok( ! $stdout, "_precheck():  Non-verbose mode produced no output" );
}

{
    my ($stdout, $stderr);
    capture(
        sub { init::hints::darwin::_precheck(
            $problematic_flag, $stored, 1
        ) },
        \$stdout,
        \$stderr,
    );
    ok( $stdout, "_precheck():  Verbose mode produced output" );
    like($stdout, qr/Checking\s+$problematic_flag/,
        "_precheck():  Got expected verbose output" );
    like($stdout, qr/Pre-check:\s+$stored/,
        "_precheck():  Got expected verbose output" );
}

{
    my ($stdout, $stderr);
    capture(
        sub { init::hints::darwin::_precheck(
            $problematic_flag, q{}, 1
        ) },
        \$stdout,
        \$stderr,
    );
    ok( $stdout, "_precheck():  Verbose mode produced output" );
    like($stdout, qr/Checking\s+$problematic_flag/,
        "_precheck():  Got expected verbose output" );
    like($stdout, qr/Pre-check:\s+\(nil\)/,
        "_precheck():  Got expected verbose output" );
}

##### _strip_arch_flags_engine #####

{
    my %defaults = (
        architectures   => [ qw( i386 ppc64 ppc x86_64 ) ],
    );
    my $flagsref = {};
    my $stored = q{-someflag  -arch i386 -someotherflag -arch ppc};
    my $flag = q{ccflags};
    $flagsref = init::hints::darwin::_strip_arch_flags_engine(
      $defaults{architectures}, $stored, $flagsref, $flag
    );
    like(
        $flagsref->{$flag}, 
        qr{-someflag -someotherflag},
        "_strip_arch_flags_engine(): '-arch' flags and extra whitespace removed",
    );


}

##### _postcheck #####

{
    my $flag = 'ccflags';
    my $flagsref = { 'ccflags' => 'my ccflag' };
    my ($stdout, $stderr);

    capture(
        sub { init::hints::darwin::_postcheck(
            $flagsref, $flag, 0
        ) },
        \$stdout,
        \$stderr,
    );
    ok( ! $stdout, "_postcheck():  Non-verbose mode produced no output" );

    capture(
        sub { init::hints::darwin::_postcheck(
            $flagsref, $flag, 1
        ) },
        \$stdout,
        \$stderr,
    );
    ok( $stdout, "_postcheck():  Verbose mode produced output" );
    like($stdout, qr/Post-check:\s+$flagsref->{$flag}/,
        "_postcheck():  Got expected verbose output" );

    $flagsref = { 'ccflags' => undef };
    capture(
        sub { init::hints::darwin::_postcheck(
            $flagsref, $flag, 1
        ) },
        \$stdout,
        \$stderr,
    );
    ok( $stdout, "_postcheck():  Verbose mode produced output" );
    like($stdout, qr/Post-check:\s+\(nil\)/,
        "_postcheck():  Got expected verbose output" );
}

##### _strip_arch_flags #####

{
    my %defaults = (
        problem_flags   => [ qw( ccflags ldflags ) ],
        architectures   => [ qw( i386 ppc64 ppc x86_64 ) ],
    );
    my $flagsref = {};
    my $flag = q{ccflags};
    my $stored = q{-someflag  -arch i386 -someotherflag -arch ppc};
    $conf->data->set( $flag => $stored );

    $flagsref = init::hints::darwin::_strip_arch_flags($conf, 0);
    like($flagsref->{$flag},
        qr/-someflag -someotherflag/,
        "_strip_arch_flags(): '-arch' flags and extra whitespace removed",
    );    

    my ($stdout, $stderr);
    capture(
        sub {
            $flagsref = init::hints::darwin::_strip_arch_flags($conf, 1);
        },
        \$stdout,
        \$stderr,
    );
    like($flagsref->{$flag},
        qr/-someflag -someotherflag/,
        "_strip_arch_flags(): '-arch' flags and extra whitespace removed",
    );
    like(
        $stdout,
        qr/Stripping -arch flags due to Apple multi-architecture build problems:/,
        "_strip_arch_flags(): Got expected verbose output",
    );
}

##### _strip_ldl_as_needed #####

{
    my $major = '7.99.11';
    local $init::hints::darwin::defaults{uname} = $major;
    $conf->data->set( libs => '-somelib -ldl -someotherlib' );
    my $libs = init::hints::darwin::_strip_ldl_as_needed(
        $conf->data->get( 'libs' )
    );
    like( $libs, qr/-somelib\s+-someotherlib/,
        "_strip_ldl_as_needed(): '-ldl' stripped as expected" );
}

##### _set_deployment_environment() #####

{
    my $predicted = '10.99';
    local $ENV{'MACOSX_DEPLOYMENT_TARGET'} = undef;
    no warnings 'once';
    local $init::hints::darwin::defaults{sw_vers} = qq{$predicted.11};
    use warnings;
    init::hints::darwin::_set_deployment_environment();
    is($ENV{'MACOSX_DEPLOYMENT_TARGET'}, $predicted,
        "_set_deployment_environment(): MACOSX_DEPLOYMENT_TARGET set as expected");
}
    
pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

init/hints/darwin-01.t - test init::hints::darwin

=head1 SYNOPSIS

    % prove t/steps/init/hints/darwin-01.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test init::hints::darwin.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::init::hints::darwin, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
