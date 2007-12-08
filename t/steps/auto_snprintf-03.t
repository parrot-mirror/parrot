#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# auto_snprintf-03.t

use strict;
use warnings;
use Test::More tests => 13;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::init::defaults');
use_ok('config::auto::snprintf');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Test qw( test_step_thru_runstep);
use Parrot::IO::Capture::Mini;

my $args = process_options( {
    argv            => [ q{--verbose} ],
    mode            => q{configure},
} );

my $conf = Parrot::Configure->new();

test_step_thru_runstep($conf, q{init::defaults}, $args);

my ($task, $step_name, $step, $ret);
my $pkg = q{auto::snprintf};

$conf->add_steps($pkg);
$conf->options->set(%{$args});
$task = $conf->steps->[1];
$step_name   = $task->step;

$step = $step_name->new();
ok(defined $step, "$step_name constructor returned defined value");
isa_ok($step, $step_name);
ok($step->description(), "$step_name has description");

{
    my $tie_out = tie *STDOUT, "Parrot::IO::Capture::Mini"
        or croak "Unable to tie";
    my $res = q{snprintf};
    ok($step->_evaluate_snprintf($conf, $res),
        "_evaluate_snprintf returned true value");
    my @more_lines = $tie_out->READLINE;
    ok( @more_lines, "verbose output captured" );
    ok($conf->data->get('HAS_SNPRINTF'),
        "Got expected value");
}
untie *STDOUT;

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_snprintf-03.t - test config::auto::snprintf

=head1 SYNOPSIS

    % prove t/steps/auto_snprintf-03.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::auto::snprintf.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::snprintf, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
