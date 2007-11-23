#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 062-init_defaults-02.t

use strict;
use warnings;

use Test::More tests =>  6;
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

# Next 2 tests cheat by breaking encapsulation.
is($init->get('debugging'), 0, "Got expected value for 'debugging'");
is($init->get('cc_debug'), q{ -pg }, "Got expected value for 'cc_debug'");

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

062-init_defaults-02.t - Test Parrot::Configure::Initialize.

=head1 SYNOPSIS

    % prove t/configure/062-init_defaults-02.t

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


