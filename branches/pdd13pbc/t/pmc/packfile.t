#!perl
# Copyright (C) 2006-2008, The Perl Foundation.
# $Id$

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More;
use Parrot::Test tests => 4;

=head1 NAME

t/pmc/packfile.t - test the Packfile PMC


=head1 SYNOPSIS

    % prove t/pmc/packfile.t

=head1 DESCRIPTION

Tests the Packfile PMC.

=cut


# constructor

pir_output_is( <<'CODE', <<'OUT', 'new' );
.sub 'test' :main
    $P0 = new 'Packfile'
    $I0 = defined $P0
    say $I0
.end
CODE
1
OUT


# get_integer_keyed_str

pir_output_is( <<'CODE', <<'OUT', 'get_integer_keyed_str' );
.sub main :main
    $P0 = new 'Packfile'
    $S0 = 'version_major'
    $I0 = $P0[$S0]
    say $I0
.end
CODE
0
OUT


# get_directory

pir_output_is( <<'CODE', <<'OUT', 'get_directory' );
.sub 'test' :main
    $P0 = new 'Packfile'
    $P1 = $P0.'get_directory'()
    $I0 = defined $P1
    say $I0
.end
CODE
1
OUT


# get_string gives us back what set_string_native got

pir_output_is( <<'CODE', <<'OUT', 'set_string_native -> get_string' );
.sub 'test' :main
    .include "stat.pasm"
    $S0 = "runtime/parrot/library/uuid.pbc"
    $I0 = stat $S0, .STAT_FILESIZE
    $P0 = open $S0, "<"
    $S0 = read $P0, $I0
    close $P0
    $P0 = new 'Packfile'
    $P0 = $S0
    $S1 = $P0
    $I0 = length $S0
    $I1 = length $S1
    eq $I0, $I1, OUT
    print "not "
    OUT:
    say "ok"
.end
CODE
ok
OUT


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
