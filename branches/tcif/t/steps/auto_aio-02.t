#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# auto_aio-02.t

use strict;
use warnings;
use Test::More tests => 11;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::auto::aio');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use IO::CaptureOutput qw( capture );
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
ok($trace->store_this_step(),
    "Step stored; has previously been tested");

my $args = process_options(
    {
        argv => [ q{--verbose} ],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;
$conf->refresh($trace->get_previous_state());

my $pkg = q{auto::aio};
$conf->add_steps($pkg);
$conf->options->set( %{$args} );

my ( $task, $step_name, $step);
$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );

{
    my ($stdout, $stderr);
    my $ret = capture sub { $step->runstep($conf) }, \$stdout, \$stderr;
    ok( $ret, "$step_name runstep() returned true value" );
    like(
        $step->result(),
        qr/^(yes|no)$/i,
        "One of two possible valid results was set"
    );
    like(
        $stdout,
        qr/\s+\((yes|no)\)\s+/,
        "Got expected verbose output"
    );
}

pass("Keep Devel::Cover happy");
pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_aio-02.t - test config::auto::aio

=head1 SYNOPSIS

    % prove t/steps/auto_aio-02.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test methods found in configuration step class
config::auto::aio in the case where C<--verbose> is selected.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::aio, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
