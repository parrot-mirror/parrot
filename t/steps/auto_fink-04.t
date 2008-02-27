#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# auto_fink-04.t

use strict;
use warnings;
use Test::More;
plan( skip_all => 'Fink is Darwin only' ) unless $^O =~ /darwin/;
plan( tests =>  9 );
# plan qw( no_plan );
use Carp;
use File::Temp;
use lib qw( lib t/configure/testlib );
use_ok('config::auto::fink');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
ok($trace->store_this_step(),
    "Step stored; has previously been tested");

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

{
    # mock Fink config file with no Basepath
    my $tfile = File::Temp->new();
    open my $fh, ">", $tfile
        or croak "Unable to open temporary file for writing";
    print $fh "Message: Hello world\n";
    close $fh or croak "Unable to close temporary file after writing";
    $step->{fink_conf} = $tfile;
    ok(! defined $step->runstep($conf),
        "runstep() returned undef due to defective Fink config file");
    is($step->result(), q{failed},
        "Got expected result for defective Fink Config file");
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_fink-04.t - test config::auto::fink

=head1 SYNOPSIS

    % prove t/steps/auto_fink-04.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test config::auto::fink in the case where the Fink
configuration file is defective.

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
