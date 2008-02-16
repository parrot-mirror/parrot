#! perl
# Copyright (C) 2008, The Perl Foundation.
# $Id$
# 062-parallel.t

use strict;
use warnings;

use Test::More qw(no_plan); # tests => 11;
use Carp;
use Cwd;
use File::Temp qw| tempdir |;
use lib qw( lib );
use IO::CaptureOutput qw | capture |;
use Parrot::Configure::Parallel::Trace;
use config::init::defaults;
use config::init::install;

my $trace;

@Parrot::Configure::Step::List::steps = qw(
    init::defaults
    init::install
);

my $cwd = cwd();
{
    my $tdir = tempdir( CLEANUP => 1 );
    ok( (chdir $tdir), "Able to change to tempdir");

    $trace = Parrot::Configure::Parallel::Trace->new(
            't/steps/init_defaults-01.t'
    );
    ok(defined $trace, "Constructor returned defined value");
    is($trace->store_this_step_pure(), 1,
        "Got expected return value from store_this_step_pure()");

    my $sto = $trace->get_storable_file();
    ok( -e $sto,
        "Parallel configuration file stored on disk");
    $trace = Parrot::Configure::Parallel::Trace->new(
            't/steps/init_defaults-02.t'
    );
    ok(defined $trace, "Constructor returned defined value");
    is($trace->store_this_step_pure(), 2,
        "Got expected return value from store_this_step_pure()");

    ok( (chdir $cwd), "Able to change back to starting directory");
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

062-parallel.t - Tests for Parrot::Configure::Parallel::Trace

=head1 SYNOPSIS

    % prove t/configure/062-parallel.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file examine what happens when you run
Parrot::Configure::Parallel::Trace.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure::Parallel, Parrot::Configure::Parallel::Trace,
F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
