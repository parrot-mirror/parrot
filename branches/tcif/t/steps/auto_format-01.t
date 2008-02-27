#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# auto_format-01.t

use strict;
use warnings;
use Test::More tests => 13;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::auto::format');
use Parrot::BuildUtil;
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
ok($trace->store_this_step(), "Step stored");

my $args = process_options( {
    argv            => [],
    mode            => q{configure},
} );

my $conf = Parrot::Configure->new();
$conf->refresh($trace->get_previous_state());

my ($task, $step_name, $step, $ret);
my $pkg = q{auto::format};
$conf->add_steps($pkg);
$conf->options->set(%{$args});

$task = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok(defined $step, "$step_name constructor returned defined value");
isa_ok($step, $step_name);
ok($step->description(), "$step_name has description");

{
    $conf->data->set( iv => 'int' );
    auto::format::_set_intvalfmt($conf);
    is($conf->data->get( 'intvalfmt' ), '%d',
        "intvalfmt set as expected");
    # reset for next test
    $conf->data->set( iv => undef );
}

{
    $conf->data->set( iv => 'long' );
    auto::format::_set_intvalfmt($conf);
    is($conf->data->get( 'intvalfmt' ), '%ld',
        "intvalfmt set as expected");
    # reset for next test
    $conf->data->set( iv => undef );
}

{
    $conf->data->set( iv => 'long int' );
    auto::format::_set_intvalfmt($conf);
    is($conf->data->get( 'intvalfmt' ), '%ld',
        "intvalfmt set as expected");
    # reset for next test
    $conf->data->set( iv => undef );
}

{
    $conf->data->set( iv => 'long long' );
    auto::format::_set_intvalfmt($conf);
    is($conf->data->get( 'intvalfmt' ), '%lld',
        "intvalfmt set as expected");
    # reset for next test
    $conf->data->set( iv => undef );
}

{
    $conf->data->set( iv => 'long long int' );
    auto::format::_set_intvalfmt($conf);
    is($conf->data->get( 'intvalfmt' ), '%lld',
        "intvalfmt set as expected");
    # reset for next test
    $conf->data->set( iv => undef );
}

{
    my $type = 'foobar';
    $conf->data->set( iv => $type );
    eval { auto::format::_set_intvalfmt($conf); };
    like($@,
        qr/Can't find a printf-style format specifier for type '$type'/, #'
        "Got expected error message");
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

auto_format-01.t - test config::auto::format

=head1 SYNOPSIS

    % prove t/steps/auto_format-01.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::auto::format.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::format, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
