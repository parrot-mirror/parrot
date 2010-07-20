#!./parrot
# Copyright (C) 2010, Parrot Foundation.
# $Id$

.sub main
    .include 'test_more.pir'

    plan(9)

    tasks_run_in_order()
    task_send_recv()
    task_kill()
    task_wait()

    $P0 = get_global 'exit0'
    $P1 = new 'Task', $P0
    schedule $P1

again:
    goto again
.end

.sub tasks_run_in_order
    $P0 = new 'Integer', 0
    set_global 'N', $P0

    $P0 = get_global 'task1'
    $P1 = new 'Task', $P0
    schedule $P1

    $P0 = get_global 'sub1'
    schedule $P0

    $P0 = get_global 'task2'
    $P1 = new 'Task', $P0
    schedule $P1

    sleep 0.01
.end

.sub task1
    $P0 = get_global 'N'
    is($P0, 0, "Task ran in order (0)")

    $P0 = 1
    set_global 'N', $P0
.end

.sub sub1
    $P0 = get_global 'N'
    is($P0, 1, "Implicit task ran in order (2)")

    $P0 = 2
    set_global 'N', $P0
.end

.sub task2
    $P0 = get_global 'N'
    is($P0, 2, "Task ran in order (3)")

    $P0 = 3
    set_global 'N', $P0
.end

.sub task_send_recv
    $P0 = get_global 'recv_msg'
    $P1 = new 'Task', $P0
    $P2 = new 'String'
    $P2 = "Hai"
    $P1.'send'($P2)
    schedule $P1
.end

.sub task_kill
    $P0 = get_global 'task_to_kill'
    $P1 = new 'Task', $P0
    schedule $P1
    sleep 0.001
    $P1.'kill'()
    sleep 0.1
    ok(1, "task_to_kill killed")
.end

.sub task_to_kill
    ok(1, "task_to_kill running")
    sleep 0.05
    ok(0, "task_to_kill wasn't killed")
.end

.sub recv_msg
    $P0 = recv
    $P1 = new 'String'
    $P1 = "Hai"
#is($P0, $P1, "Got message")
    skip("Chandon TODO: Message Passing")
.end

.sub task_wait
    $P0 = get_global 'wait_sub1'
    $P1 = new 'Task', $P0
    schedule $P1

    wait $P1
    ok(1, "After wait")
.end

.sub wait_sub1
    ok(1, "in wait_sub1")
.end

.sub exit0
    ok(1, "Pre-empt and exit")
    exit 0
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
