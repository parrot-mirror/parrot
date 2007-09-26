#!perl
# Copyright (C) 2007, The Perl Foundation.
# $Id: new.t 21204 2007-09-12 04:15:39Z allison $

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More;
use Parrot::Test tests => 3;

=head1 NAME

t/oo/proxy.t - Test OO class proxies.

=head1 SYNOPSIS

    % prove t/oo/proxy.t

=head1 DESCRIPTION

Tests OO features related to creating and using class proxies.

=cut

pir_output_is( <<'CODE', <<'OUT', 'typeof a low-level object');
.sub main :main
    $P0 = new 'String'
    $S1 = typeof $P0
    say $S1
    $P1 = typeof $P0

    $I3 = isa $P1, "PMCProxy"
    print $I3
    print "\n"
.end
CODE
String
1
OUT

pir_output_is( <<'CODE', <<'OUT', 'typeof a high-level object');
.sub main :main
    $P0 = newclass "Foo"
    $P0 = new "Foo"
    $S1 = typeof $P0
    say $S1
    $P1 = typeof $P0

    $I3 = isa $P1, "PMCProxy"
    print $I3
    print "\n"
    $I3 = isa $P1, "Foo"
    print $I3
    print "\n"
.end
CODE
Foo
0
1
OUT

pir_output_is( <<'CODE', <<'OUT', 'typeof a Class object');
.sub main :main
    $P0 = newclass "Foo"
    $S1 = typeof $P0
    say $S1
    $P1 = typeof $P0

    $I3 = isa $P1, "PMCProxy"
    print $I3
    print "\n"
.end
CODE
Class
1
OUT

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
