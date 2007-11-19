#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 061-initialize.t

use strict;
use warnings;

use Test::More tests =>  7;
use Carp;
use lib qw( lib t/configure/testlib );
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Initialize;

my $args = process_options(
    {
        argv => [q{--debugging=0}, q{--profile}, q{--m=32}],
        mode => q{configure},
    }
);
my $init = Parrot::Configure::Initialize->new($args);
ok(defined $init,
    "Parrot::Configure::Initialize returned defined value");
isa_ok($init, "Parrot::Configure::Initialize");
ok($init->init_defaults(), 'init_defaults() completed okay');

# Next 3 tests cheat by breaking encapsulation.
is($init->{debugging}, 0, "Got expected value for 'debugging'");
is($init->{cc_debug}, q{ -pg }, "Got expected value for 'cc_debug'");
is($init->{options}->{m}, 32, "Got expected value for 'm'");

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

061-initialize.t - Test Parrot::Configure::Initialize.

=head1 SYNOPSIS

    % prove t/configure/061-initialize.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test Parrot::Configure::Initialize::Defaults in the
case where command-line options have been provided.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure, Parrot::Configure::Initialize,
Parrot::Configure::Initialize::Defaults, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:


