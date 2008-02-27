#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# auto_memalign-04.t

use strict;
use warnings;
use Test::More tests => 27;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::auto::memalign');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use IO::CaptureOutput qw| capture |;
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

my $pkg = q{auto::memalign};
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
    $conf->data->set( malloc_header => 'malloc.h' );
    my ($rv, $stdout, $expected);
    $expected = 'posix_memalign';
    capture(
        sub { $rv = $step->_set_memalign($conf, 1, 1); },
        \$stdout,
    );
    ok($rv, "_set_memalign() returned true value");
    ok(! defined $conf->data->get( 'malloc_header' ),
        "malloc_header now undef as expected");
    is($conf->data->get( 'memalign' ), $expected,
        "Got expected value for memalign");
    is($step->result(), q{yes}, "Got expected result");
    like($stdout, qr/Yep:$expected/,
        "Got expected verbose output");
}

{
    $conf->data->set( malloc_header => 'malloc.h' );
    my ($rv, $stdout, $expected);
    $expected = 'memalign';
    capture(
        sub { $rv = $step->_set_memalign($conf, 1, 0); },
        \$stdout,
    );
    ok($rv, "_set_memalign() returned true value");
    ok(! defined $conf->data->get( 'malloc_header' ),
        "malloc_header now undef as expected");
    is($conf->data->get( 'memalign' ), $expected,
        "Got expected value for memalign");
    is($step->result(), q{yes}, "Got expected result");
    like($stdout, qr/Yep:$expected/,
        "Got expected verbose output");
}

{
    $conf->data->set( malloc_header => 'malloc.h' );
    my ($rv, $stdout, $expected);
    $expected = 'posix_memalign';
    capture(
        sub { $rv = $step->_set_memalign($conf, 0, 1); },
        \$stdout,
    );
    ok($rv, "_set_memalign() returned true value");
    ok(! defined $conf->data->get( 'malloc_header' ),
        "malloc_header now undef as expected");
    is($conf->data->get( 'memalign' ), $expected,
        "Got expected value for memalign");
    is($step->result(), q{no}, "Got expected result");
    like($stdout, qr/no/,
        "Got expected verbose output");
}

{
    $conf->data->set( malloc_header => 'malloc.h' );
    my ($rv, $stdout, $expected);
    $expected = '';
    capture(
        sub { $rv = $step->_set_memalign($conf, 0, 0); },
        \$stdout,
    );
    ok($rv, "_set_memalign() returned true value");
    ok(! defined $conf->data->get( 'malloc_header' ),
        "malloc_header now undef as expected");
    is($conf->data->get( 'memalign' ), $expected,
        "Got expected value (empty string) for memalign");
    is($step->result(), q{no}, "Got expected result");
    like($stdout, qr/no/,
        "Got expected verbose output");
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_memalign-04.t - test config::auto::memalign

=head1 SYNOPSIS

    % prove t/steps/auto_memalign-04.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by
config::auto::memalign.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::memalign, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
