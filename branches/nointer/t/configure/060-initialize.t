#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 060-initialize.t

use strict;
use warnings;

use Test::More qw(no_plan); # tests => 12;
use Carp;
use lib qw( lib t/configure/testlib );
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Initialize;
#use Parrot::IO::Capture::Mini;
#use_ok('Parrot::Configure::Initialize', qw| get_data_from_prompts | );

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

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

060-initialize.t - Test Parrot::Configure::Initialize.

=head1 SYNOPSIS

    % prove t/configure/060-initialize.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test Parrot::Configure::Initialize.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:


