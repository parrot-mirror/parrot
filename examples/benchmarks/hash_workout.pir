# Copyright (C) 2009, Parrot Foundation.
# $Id: hello.pir 42904 2009-12-06 07:16:50Z dukeleto $

# This benchmark is intended to put a lot of pressure on hashes so we can
# measure how various optimization approaches affect overall performance.

.sub main
    'run_benchmark'("million_inserts")
    'run_benchmark'("million_deletes")
    'run_benchmark'('million_clones_1')
    'run_benchmark'('million_clones_2')
.end

.sub 'run_benchmark'
    .param string testname
    .local num starttime
    .local num endtime

    starttime = time
    $P0 = get_global testname
    $P0()
    endtime = time
    'display_results'(testname, starttime, endtime)
.end

.sub 'display_results'
    .param string name
    .param num starttime
    .param num endtime
    .local num diff
    diff = endtime - starttime

    print "Test: "
    say name
    print "Start Time: "
    say starttime
    print "End Time: "
    say endtime
    print "Total Time: "
    say diff
    say ""
.end

# In this test, we add a million items to the hash. This tests the performance
# of the resize/reallocate algorithms. It also, unavoidably, tests GC
# performance in string allocations.
.sub 'million_inserts'
    $P0 = new ['Hash']
    $I0 = 0

    # We're using a single value PMC for all inserts to try and reduce the
    # effect of GC pressure on the benchmark
    $P1 = box 1
  loop_top:

    $S0 = $I0
    $P0[$S0] = $P1
    inc $I0
    unless $I0 > 1000000 goto loop_top
    say $I0
.end

# This test rapidly inserts and deletes. The hash should never resize, so we
# can avoid the overhead of resize/reallocate stuff. It's a basic test for
# hash throughput
.sub 'million_deletes'
    $P0 = new ['Hash']
    $I0 = 0

    # We're using a single value PMC for all inserts to try and reduce the
    # effect of GC pressure on the benchmark
    $P1 = box 1

    # First, put one element in the hash
    $I0 = 0
    $S0 = $I0
    $P0[$S0] = $P1
    $I0 = 1

    # Tight loop, delete the last item and add a new item. We only ever have
    # one item in the hash, so we don't need to worry about allocs.
  delete_loop_top:
    delete $P0[$S0]
    $S0 = $I0
    $P0[$S0] = $P1
    inc $I0
    unless $I0 > 1000000 goto delete_loop_top
    say $I0
.end

# We create a million clones of a 1-element hash to test clone performance
.sub 'million_clones_1'
    $P0 = new ['Hash']
    $P0["A"] = 1

    $I0 = 0
  loop_top:
    $P1 = clone $P0
    inc $I0
    unless $I0 > 1000000 goto loop_top
    say $I0
.end

# We create a million clones of a multi-element hash. The hash is larger
# than the number of initial buckets, so every clone will need to resize.
.sub 'million_clones_2'
    $P0 = new ['Hash']
    $P0["A"] = 1
    $P0["B"] = 2
    $P0["C"] = 3
    $P0["D"] = 4
    $P0["E"] = 5
    $P0["F"] = 6

    $I0 = 0
  loop_top:
    $P1 = clone $P0
    inc $I0
    unless $I0 > 1000000 goto loop_top
    say $I0
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
