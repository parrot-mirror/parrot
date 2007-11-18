#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 059-interactive.t

use strict;
use warnings;

use Test::More qw(no_plan); # tests => 12;
use Carp;
use lib qw( lib t/configure/testlib );
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::IO::Capture::Mini;
use_ok('Parrot::Configure::Interactive', qw| get_data_from_prompts | );

my $args;
eval { $args = get_data_from_prompts( [ 1..2 ] ); };
like($@, qr/^Argument to get_data_from_prompts\(\) must be hash ref/,
    "Got expected error message when supplying wrong type of argument");
{
    my $tie_out = tie *STDOUT, "Parrot::IO::Capture::Mini"
        or croak "Unable to tie";
    $args = get_data_from_prompts( {} );
    my @lines = $tie_out->READLINE;
    ok( @lines, "verbose output captured" );
    my $bigstr = join "\n", @lines;
    like($bigstr, qr/Okay, I'm going to start/s, "Got expected prompt");
}
untie *STDOUT;

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

059-interactive.t - Test Parrot::Configure::Interactive.

=head1 SYNOPSIS

    % prove t/configure/059-interactive.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test Parrot::Configure::Interactive.

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


