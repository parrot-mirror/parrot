#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# auto_byteorder-03.t

use strict;
use warnings;
use Test::More tests =>  10;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::init::defaults');
use_ok('config::auto::byteorder');
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

my $pkg = q{auto::byteorder};

$conf->add_steps($pkg);
$conf->options->set( %{$args} );

my ( $task, $step_name, $step);
$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );


my ($byteorder, $rv);

$byteorder = q{foobar};
eval {
    $rv = $step->_evaluate_byteorder($conf, $byteorder);
};
like($@,
    qr/Unsupported byte-order \[$byteorder\]!/,
    "Got error message expected with bad byte-order");

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_byteorder-03.t - test config::auto::byteorder

=head1 SYNOPSIS

    % prove t/steps/auto_byteorder-03.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::auto::byteorder.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::byteorder, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
