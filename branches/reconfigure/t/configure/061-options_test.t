#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 061-options_test.t

use strict;
use warnings;
use Carp;
use Cwd;
use Test::More qw(no_plan); # tests => 21;
use lib qw( lib );
use_ok(
    'Parrot::Configure::Options', qw|
        process_options
        |
);
use_ok("Parrot::Configure::Options::Test");

my ( $args, $opttest, %data );

$args = process_options(
    {
        argv => [
            q{--cc=/usr/bin/gcc-3.3},
            q{--test=configure},
            q{--ask},
            q{--configure_trace},
            q{--debugging},
            q{--fatal},
            q{--verbose},
        ],
        mode => q{configure},
    }
);
ok( defined $args, "process_options() returned successfully" );

$opttest = Parrot::Configure::Options::Test->new($args);
ok( defined $opttest, "Constructor returned successfully" );
%data = %$opttest;
is($data{cc}, q{/usr/bin/gcc-3.3}, "Option included in P::C::O::Test as expected");
ok($data{run_configure_tests}, "Option included in P::C::O::Test as expected");
ok(! exists $data{run_build_tests}, "Option excluded from P::C::O::Test as expected");
ok(! exists $data{ask}, "Option excluded from P::C::O::Test as expected");
ok(! exists $data{configure_trace}, "Option excluded from P::C::O::Test as expected");
ok(! exists $data{debugging}, "Option excluded from P::C::O::Test as expected");
ok(! exists $data{fatal}, "Option excluded from P::C::O::Test as expected");
ok(! exists $data{verbose}, "Option excluded from P::C::O::Test as expected");

$args = process_options(
    {
        argv => [
            q{--test=build},
            q{--nomanicheck},
            q{--silent},
            q{--fatal-step=inter::progs},
            q{--verbose-step=init::defaults},
        ],
        mode => q{configure},
    }
);
ok( defined $args, "process_options() returned successfully" );

$opttest = Parrot::Configure::Options::Test->new($args);
ok( defined $opttest, "Constructor returned successfully" );
%data = %$opttest;
ok(! exists $data{run_configure_tests},
    "Option excluded from P::C::O::Test as expected");
ok($data{run_build_tests}, "Option included in P::C::O::Test as expected");
ok($data{nomanicheck}, "Option included in P::C::O::Test as expected");
ok(! exists $data{silent}, "Option excluded from P::C::O::Test as expected");
ok(! exists $data{'fatal-step'}, "Option excluded from P::C::O::Test as expected");
ok(! exists $data{'verbose-step'}, "Option excluded from P::C::O::Test as expected");

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

061-options_test.t - test Parrot::Configure::Options::Test

=head1 SYNOPSIS

    % prove t/configure/061-options_test.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test Parrot::Configure::Options::Test methods.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure::Options, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
