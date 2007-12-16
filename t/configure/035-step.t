#!perl
# Copyright (C) 2001-2005, The Perl Foundation.
# $Id$

use strict;
use warnings;

use Test::More tests =>  9;
use Carp;
use Cwd;
use lib qw( lib t/configure/testlib );
use IO::CaptureOutput qw| capture |;

BEGIN {
    use_ok('Parrot::Configure::Compiler');
}

my $cwd = cwd();
my $command;

$command = q{echo Hello world};
{
    my $tdir = tempdir( CLEANUP => 1 );
    chdir $tdir or croak "Unable to change to temporary directory";
    my $out     = q{out};
    my $err     = q{err};
    my $verbose = 0;
    my $rv      = Parrot::Configure::Compiler::_run_command( $command, $out, $err, $verbose );
    is( $rv, 0, "Got expected exit code of 0" );

    chdir $cwd or croak "Unable to change back to starting directory";
}

$command = q{echo Hello world};
{
    my $tdir = tempdir( CLEANUP => 1 );
    chdir $tdir or croak "Unable to change to temporary directory";
    my $out     = q{out};
    my $err     = q{err};
    my $verbose = 1;

    my ($rv, $stdout);
    capture(
        sub { $rv = Parrot::Configure::Compiler::_run_command(
                $command, $out, $err, $verbose ); },
        \$stdout,
    );
    is( $rv, 0, "Got expected exit code of 0" );

    chdir $cwd or croak "Unable to change back to starting directory";
}


$command = q{echo Hello world};
{
    my $tdir = tempdir( CLEANUP => 1 );
    chdir $tdir or croak "Unable to change to temporary directory";
    my $out     = q{out};
    my $err     = $out;
    my $verbose = 0;
    my $rv      = Parrot::Configure::Compiler::_run_command( $command, $out, $err, $verbose );
    is( $rv, 0, "Got expected exit code of 0" );

    chdir $cwd or croak "Unable to change back to starting directory";
}

$command = q{echo Hello world};
{
    my $tdir = tempdir( CLEANUP => 1 );
    chdir $tdir or croak "Unable to change to temporary directory";
    my $out     = q{out};
    my $err     = q{/dev/null};
    my $verbose = 0;
    my $rv      = Parrot::Configure::Compiler::_run_command( $command, $out, $err, $verbose );
    is( $rv, 0, "Got expected exit code of 0" );

    chdir $cwd or croak "Unable to change back to starting directory";
}

$command = $^O eq 'MSWin32' ? q{dir} : q{date};
{
    my $tdir = tempdir( CLEANUP => 1 );
    chdir $tdir or croak "Unable to change to temporary directory";
    my $out     = undef;
    my $err     = q{err};
    my $verbose = 0;
    my ($rv, $stdout);
    capture(
        sub { $rv = Parrot::Configure::Compiler::_run_command(
                $command, $out, $err, $verbose );
        },
        \$stdout,
    );
    is( $rv, 0, "Got expected exit code of 0" );

    chdir $cwd or croak "Unable to change back to starting directory";
}

$command = $^O eq 'MSWin32' ? q{dir} : q{date};
{
    my $tdir = tempdir( CLEANUP => 1 );
    chdir $tdir or croak "Unable to change to temporary directory";
    my $out     = undef;
    my $err     = q{err};
    my $verbose = 1;
    my ($rv, $stdout, $stderr);
    capture(
        sub { $rv = Parrot::Configure::Compiler::_run_command(
                $command, $out, $err, $verbose );
        },
        \$stdout,
        \$stderr,
    );
    is( $rv, 0, "Got expected exit code of 0" );

    chdir $cwd or croak "Unable to change back to starting directory";
}

$command = $^O eq 'MSWin32' ? q{dir} : q{date};
{
    my $tdir = tempdir( CLEANUP => 1 );
    chdir $tdir or croak "Unable to change to temporary directory";
    my $out     = q{out};
    my $err     = q{/dev/null};
    my $verbose = 1;
    my ($rv, $stdout, $stderr);
    capture(
        sub { $rv = Parrot::Configure::Compiler::_run_command(
                $command, $out, $err, $verbose );
        },
        \$stdout,
        \$stderr,
    );
    is( $rv, 0, "Got expected exit code of 0" );

    chdir $cwd or croak "Unable to change back to starting directory";
}

$command = $^O eq 'MSWin32' ? q{dir} : q{date};
{
    my $tdir = tempdir( CLEANUP => 1 );
    chdir $tdir or croak "Unable to change to temporary directory";
    my $out     = q{&go};
    my $err     = q{err};
    my $verbose = 1;
    my ($rv, $stdout, $stderr);
    capture(
        sub { $rv = Parrot::Configure::Compiler::_run_command(
                $command, $out, $err, $verbose );
        },
        \$stdout,
        \$stderr,
    );
    is( $rv, 0, "Got expected exit code of 0" );

    chdir $cwd or croak "Unable to change back to starting directory";
}

################### DOCUMENTATION ###################

=head1 NAME

t/configure/035-step.t - tests Parrot::Configure::Step

=head1 SYNOPSIS

    prove t/configure/035-step.t

=head1 DESCRIPTION

Regression tests for the L<Parrot::Configure::Step> module.  This file holds
tests for Parrot::Configure::Compiler::_run_command() (a non-exported subroutine).

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
