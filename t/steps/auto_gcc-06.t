#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# auto_gcc-06.t

use strict;
use warnings;
use Test::More tests => 12;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::auto::gcc');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use IO::CaptureOutput qw | capture |;
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
is($trace->store_this_step(), 2,
    "Step stored; has previously been tested");

my $args = process_options( {
    argv            => [ q{--verbose} ],
    mode            => q{configure},
} );

my $conf = Parrot::Configure->new();
$conf->refresh($trace->get_previous_state());

my ($task, $step_name, $step, $ret);
my $pkg = q{auto::gcc};

$conf->add_steps($pkg);
$conf->options->set(%{$args});
$task = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok(defined $step, "$step_name constructor returned defined value");
isa_ok($step, $step_name);
ok($step->description(), "$step_name has description");

{
    my $rv;
    my $stdout;
    my $gnucref = {};
    $gnucref->{__GNUC__} = q{abc123};
    capture ( sub {$rv = $step->_evaluate_gcc($conf, $gnucref) }, \$stdout);
    ok($rv, "_evaluate_gcc() returned true value");
    ok( $stdout, "verbose output captured" );
    ok(! defined $conf->data->get( 'gccversion' ),
        "gccversion undef as expected");
    is($step->result(), q{no}, "Got expected result");
}

pass("Keep Devel::Cover happy");
pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_gcc-06.t - test config::auto::gcc

=head1 SYNOPSIS

    % prove t/steps/auto_gcc-06.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::auto::gcc.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::gcc, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
