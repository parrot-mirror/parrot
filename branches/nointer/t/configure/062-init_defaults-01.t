#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 062-init_defaults-01.t

use strict;
use warnings;

use Test::More tests =>  4;
use Carp;
use lib qw( lib t/configure/testlib );
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Initialize;

my $args = process_options(
    {
        argv => [],
        mode => q{configure},
    }
);
my $init = Parrot::Configure::Initialize->new($args);
ok(defined $init,
    "Parrot::Configure::Initialize returned defined value");
isa_ok($init, "Parrot::Configure::Initialize");
ok($init->init_defaults(), 'init_defaults() completed okay');

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

062-init_defaults-01.t - Test Parrot::Configure::Initialize.

=head1 SYNOPSIS

    % prove t/configure/062-init_defaults-01.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test Parrot::Configure::Initialize::Defaults in the
case where no command-line options have been provided.

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


