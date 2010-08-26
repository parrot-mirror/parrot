#!./parrot
# Copyright (C) 2010, Parrot Foundation.
# $Id$

=head1 NAME

t/op/gc-leaky-call.t - test for memory leaks in the Garbage Collector

=head1 SYNOPSIS

    % prove t/op/gc-leaky-call.t

=head1 DESCRIPTION

Tests that we actually do a GC mark and sweep after a large number of
function calls.

=cut

.include 'interpinfo.pasm'

.sub _main :main
    .include 'test_more.pir'

    plan(3)

    $S0 = interpinfo .INTERPINFO_GC_SYS_NAME
    if $S0 == "inf" goto dont_run_hanging_tests

    test_gc_mark_sweep()

    goto test_end
  dont_run_hanging_tests:
    ok(1, "#TODO - Test disabled on gc_inf")
    ok(1, "#TODO - Test disabled on gc_inf")
    ok(1, "#TODO - Test disabled on gc_inf")
  test_end:
.end

.sub test_gc_mark_sweep
    .local int counter

    counter = 0
  loop:
    consume()
    inc counter
    if counter < 1e6 goto loop

    $I1 = interpinfo.INTERPINFO_GC_COLLECT_RUNS
    $I2 = interpinfo.INTERPINFO_GC_MARK_RUNS
    $I3 = interpinfo.INTERPINFO_TOTAL_MEM_ALLOC

    $S1 = $I1
    $S0 = "performed " . $S1
    $S0 .= " (which should be >=1) GC collect runs"
    ok($I1,$S0)

    $S1 = $I2
    $S0 = "performed " . $S1
    $S0 .= " (which should be >=1) GC mark runs"
    ok($I2,$S0)

    $S1 = $I3
    $S0 = "allocated " . $S1
    $S0 .= " (which should be <= 2_000_000) bytes of memory"
    $I4 = isle $I3, 2000000
    ok($I4,$S0)
.end

.sub consume
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
