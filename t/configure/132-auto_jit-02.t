#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 132-auto_jit-02.t

use strict;
use warnings;
use Test::More tests => 18;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::init::defaults');
use_ok('config::auto::arch');
use_ok('config::auto::jit');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Test qw( test_step_thru_runstep);

my $args = process_options(
    {
        argv => [ ],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;

test_step_thru_runstep( $conf, q{init::defaults}, $args );
test_step_thru_runstep( $conf, q{auto::arch}, $args );

my $pkg = q{auto::jit};

$conf->add_steps($pkg);
$conf->options->set( %{$args} );

my ( $task, $step_name, @step_params, $step);
$task        = $conf->steps->[2];
$step_name   = $task->step;
@step_params = @{ $task->params };

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );

my $ret = $step->runstep($conf);
ok( $ret, "$step_name runstep() returned true value" );
is($step->result(), q{}, "Result was empty string as expected");
#print STDERR "archname:  ", $conf->data->get('archname'), "\n";
#print STDERR "cpuarch:  ", $conf->data->get('cpuarch'), "\n";
#print STDERR "osname:  ", $conf->data->get('osname'), "\n";

pass("Keep Devel::Cover happy");
pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

132-auto_jit-02.t - test config::auto::jit

=head1 SYNOPSIS

    % prove t/configure/132-auto_jit-02.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file tests config::auto::jit in its most typical use.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::jit, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
