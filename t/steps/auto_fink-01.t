#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# auto_fink-01.t

use strict;
use warnings;
use Test::More tests =>  8;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::auto::fink');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
is($trace->store_this_step(), 1, "Step stored");

SKIP: {
    skip 'Fink is Darwin only', 4 unless $^O =~ /darwin/;
    my $args = process_options( {
        argv            => [],
        mode            => q{configure},
    } );
    
    my $conf = Parrot::Configure->new();
    $conf->refresh($trace->get_previous_state());
    
    my ($task, $step_name, $step, $ret);
    my $pkg = q{auto::fink};
    
    $conf->add_steps($pkg);
    $conf->options->set(%{$args});
    $task = $conf->steps->[-1];
    $step_name   = $task->step;
    
    $step = $step_name->new();
    ok(defined $step, "$step_name constructor returned defined value");
    isa_ok($step, $step_name);
    ok($step->description(), "$step_name has description");
    
    # Success in the following test means:
    # (a) OS is Darwin.
    # (b) Either Fink is not installed or it is installed correctly, i.e., we can
    # locate the Fink subdirectories we need for later Parrot configuration steps.
    ok($step->runstep($conf), "runstep() returned true value");
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_fink-01.t - test config::auto::fink

=head1 SYNOPSIS

    % prove t/steps/auto_fink-01.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file run on Darwin only and test config::auto::fink.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::fink, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
