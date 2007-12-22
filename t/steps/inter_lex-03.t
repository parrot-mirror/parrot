#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# inter_lex-03.t

use strict;
use warnings;
use Test::More tests =>  9;
use Carp;
use lib qw( lib t/configure/testlib t/steps/testlib );
$ENV{TEST_LEX} = 'foobar';
use_ok('config::inter::lex');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Auxiliary qw(
    get_step_name
    store_this_step_pure
    get_previous_state
);

my $pkg = get_step_name($0);
ok($pkg, "Step name has true value");
ok(store_this_step_pure($pkg), "State stored");

my $args = process_options(
    {
        argv => [ q{--ask}, q{--maintainer} ],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new();
$conf->refresh(get_previous_state($pkg));

my ( $task, $step_name, $step, $ret );

$conf->add_steps($pkg);
$conf->options->set( %{$args} );

$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );
$ret = $step->runstep($conf);
is( $ret, undef, "$step_name runstep() returned undefined value" );
my $result_expected = q{no lex program was found};
is( $step->result(), $result_expected, "Result was $result_expected" );

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

inter_lex-03.t - test config::inter::lex

=head1 SYNOPSIS

    % prove t/steps/inter_lex-03.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::inter::lex.  In
this case, the C<--ask> and C<--maintainer> options are provided but an
environmental variable was provided in order to trick the package into not
finding a real F<lex>-equivalent program.  As a result, no prompt is ever
reached.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::inter::lex, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
