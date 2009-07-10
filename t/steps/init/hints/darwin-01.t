#! perl
# Copyright (C) 2009, Parrot Foundation.
# $Id$
# init/hints/darwin-01.t

use strict;
use warnings;
#use Test::More;
#plan( skip_all => 'only needs testing on Darwin' ) unless $^O =~ /darwin/i;
#plan( tests =>  15 );
use Test::More qw(no_plan); # tests => 15;

#use Carp;
#use Cwd;
#use File::Path ();
#use File::Spec::Functions qw/catfile/;
#use File::Temp qw(tempdir);
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

########### --verbose ##########

my ($args, $step_list_ref) = process_options(
    {
        argv => [],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;

test_step_thru_runstep( $conf, q{init::defaults}, $args );

#my $pkg = q{init::hints};
#
#$conf->add_steps($pkg);

##### Tests of some internal subroutines #####

##### _precheck() #####

my $problematic_flag = 'ccflags';
my $stored = $conf->data->get($problematic_flag);
print STDERR "$problematic_flag\t$stored\n";

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
