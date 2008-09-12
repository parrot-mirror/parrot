#! parrot
# Copyright (C) 2001-2007, The Perl Foundation.
# $Id$

=head1 NAME

t/pmc/boolean.t - Boolean Ops

=head1 SYNOPSIS

    % prove t/pmc/boolean.t

=head1 DESCRIPTION

Tests C<Boolean> PMC. Checks comparison and logic operations for various
type combinations.

=cut

.sub main :main
    .include 'include/test_more.pir'
    plan(28)
    init_int_tests()
    num_tests()
    string_tests()
    pmc_to_pmc_tests()
    boolean_as_conditional()
    logic_operations()
    negation_tests()
    interface_check()
.end

.sub init_int_tests
    new $P0, 'Boolean'

    set $I0, $P0
    is($I0, 0,  "Boolean defaults to false")

    set $I0, 1
    set $P0, $I0
    set $I1, $P0
    is($I1, 1, "Boolean converts 1 to true")

    set $P0, -4
    set $I0, $P0
    is($I0, 1, "Boolean converts negative int to true")
.end

.sub num_tests

    new $P0, 'Boolean'
    set $N0, 0
    set $P0, $N0
    set $I0, $P0
    is($I0, 0, "Boolean converts num 0 to false")

    set $N0, 0.001
    set $P0, $N0
    set $I0, $P0
    is($I0, 1, "Boolean converts non-0 num to true")
.end

.sub string_tests
    new $P0, 'Boolean'

    set $S0, "0"
    set $P0, $S0
    set $I0, $P0
    is($I0, 0, "Boolean converts string '0' to false")

    set $S0, "foo"
    set $P0, $S0
    set $I0, $P0
    is($I0, 1, "Boolean converts string 'foo' to true")

    set $S0, ""
    set $P0, $S0
    set $I0, $P0
    is($I0, 0, "Boolean converts empty string to false")
.end

.sub pmc_to_pmc_tests
    new $P0, 'Boolean'
    new $P1, 'Boolean'

    set $P0, 1
    clone $P1, $P0
    set $I0, $P1
    is($I0, 1, "cloned Boolean has correct value")

    set $P0, 0
    set $I0, $P1
    is($I0, 1, "cloned Boolean is not a reference")

    set $P1, 0
    set $I0, $P1
    is($I0, 0, "cloned Boolean can change value")
.end

.sub boolean_as_conditional
    new $P0, 'Boolean'

    set $P0, 1
    if $P0, OK_1
    ok(0, "Boolean is broken as a conditional")
    goto end
OK_1:
    ok(1, "Boolean works as a conditional")
end:
.end

.sub logic_operations
    new $P0, 'Boolean'
    new $P1, 'Boolean'
    new $P2, 'Boolean'

    set $P0, 1
    set $P1, 0
    or $P2, $P0, $P1
    is($P2, 1, "1|0 == 1 for Booleans")

    #$P0 = 0, $P1 = 1, $P2 = 1
    or $P2, $P1, $P1
    is($P2, 0, "0|0 == 0 for Booleans")

    #$P0 = 0, $P1 = 1, $P2 = 0
    and $P2, $P0, $P1
    is($P2, 0, "0&1 == 0 for Booleans")

    set $P0, 0
    set $P1, 0
    and $P2, $P0, $P1
    is($P2, 0, "0&0 == 0 for Booleans")

    #$P0 = 0, $P1 = 0, $P2 = 0
    not $P1, $P1
    is($P1, 1, "!0 == 1 for Booleans")

    #$P0 = 0, $P1 = 1, $P2 = 0
    not $P0, $P0
    and $P2, $P0, $P1
    is($P2, 1, "1&1 == 1 for Booleans")

    #$P0 = 1, $P1 = 1, $P2 = 1
    xor $P2, $P0, $P1
    is($P2, 0, "1xor1 == 0 for Booleans")

    #$P0 = 1, $P1 = 1, $P2 = 0
    not $P0, $P0
    xor $P2, $P0, $P1
    is($P2, 1, "0xor1 == 1 for Booleans")

    #$P0 = 0, $P1 = 1, $P2 = 1
    not $P1, $P1
    xor $P2, $P0, $P1
    is($P2, 0, "0xor0 == 0 for Booleans")

.end

.sub negation_tests
    new $P0, 'Boolean'
    new $P1, 'Boolean'

    set $P0, 1
    neg $P1, $P0
    is($P1, 1, "negated Boolean true is still true")

    set $P0, 0
    neg $P1, $P0
    is($P1, 0, "negated Boolean false is still false")

    set $P0, 1
    neg $P0
    is($P0, 1, "in-place negated Boolean true is still true")

    set $P0, 0
    neg $P0
    is($P0, 0, "in-place negated Boolean false is still false")
.end

.sub interface_check
    .local pmc p
    .local int b

    p = new 'Boolean'
    does b, p, "scalar"
    is(b, 1, "Boolean does scalar")
    does b, p, "boolean"
    is(b, 1, "Boolean does boolean (big suprise there)")
    does b, p, "no_interface"
    is(b, 0, "Boolean doesn't do no_interface")
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
