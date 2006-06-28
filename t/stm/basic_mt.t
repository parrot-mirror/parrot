#! perl
# Copyright (C) 2006 The Perl Foundation.
# $Id: ref.t 12842 2006-05-30 16:52:42Z creiss $

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More;
use Parrot::Test tests => 3;

pir_output_is(<<'CODE', <<'OUTPUT', "wait (simple)");
.const int N = 50
.sub waiter
    .param pmc a

tx:
    stm_start
    if a < N goto retry
    a = -1
    stm_commit tx
    print "okay\n"
    .return ()
retry:
    stm_wait invalid
    goto tx
invalid:
    print "invalid (not okay)\n"
.end

.sub incr
    .param pmc a
    .local int i
    
    i = 0
loop:
    stm_start
    inc a
    stm_commit loop
    inc i
    if i < N goto loop
.end

.sub main :main
    .local pmc _incr
    .local pmc _waiter

    .local pmc iThr
    .local pmc wThr

    .local pmc a

    a = new Integer
    a = 0
    a = new STMRef, a

    _incr = global "incr"
    _waiter = global "waiter"

    wThr = new ParrotThread
    wThr.'run_clone'(_waiter, a)

    sleep 1 # let it really wait
    iThr = new ParrotThread
    iThr.'run_clone'(_incr, a)

    wThr.'join'()
    iThr.'join'()
.end
CODE
okay
OUTPUT


pir_output_like(<<'CODE', <<'OUTPUT', "get deadlock");
.const int N = 1000
.sub thread_task
    .param pmc a
    .param pmc b
    .local int i

    i = 0
    
loop:
    stm_start
    a = i
    b = i
    stm_commit loop
    # print "loop iteration "
    # print i
    # print "\n"
    inc i
    if i < N goto loop
    sleep 1 # workaround for thread death bug
.end

.sub main :main
    .local pmc a
    .local pmc b
    .local pmc _task
    .local pmc t1
    .local pmc t2

    a = new Integer
    a = new STMRef, a
    b = new Integer
    b = new STMRef, b

    _task = global "thread_task"
    
    t1 = new ParrotThread
    t2 = new ParrotThread
    t1.'run_clone'(_task, a, b)
    t2.'run_clone'(_task, b, a)

    t1.'join'()
    t2.'join'()

    print "okay\n"
.end
CODE
/okay/
OUTPUT

# This currently fails because we never actually invalidate the other
# transaction, we just let it keep ownership indefinitely
# The probable fix is that STM_wait should abort any outer transactions
# and do its waitlist magic (hopefully), then either (easier) consider all the outer
# transactions invalid unconditionally or (harder) replay as many of the 
# outer transaction write reservations as possible
pir_output_is(<<'CODE', <<'OUTPUT', "wait + invalidate outer transcation");
.const int N = 50
.sub waiter
    .param pmc a

tx:
    stm_start
    if a < N goto retry
    a = -1
    stm_commit tx
    print "okay\n"
    .return ()
retry:
    # we start a nested transcation here;
    # the only we we ill get out of this loop
    # is if stm_wait jumps to 'invalid'.
    stm_start
    stm_wait invalid
    goto retry 
invalid:
    stm_abort
    goto tx
.end

.sub incr
    .param pmc a
    .local int i
    
    i = 0
loop:
    stm_start
    inc a
    stm_commit loop
    inc i
    if i < N goto loop
.end

.sub main :main
    .local pmc _incr
    .local pmc _waiter

    .local pmc iThr
    .local pmc wThr

    .local pmc a

    a = new Integer
    a = 0
    a = new STMRef, a

    _incr = global "incr"
    _waiter = global "waiter"

    wThr = new ParrotThread
    wThr.'run_clone'(_waiter, a)

    sleep 1 # let it really wait
    iThr = new ParrotThread
    iThr.'run_clone'(_incr, a)

    wThr.'join'()
    iThr.'join'()
.end
CODE
okay
OUTPUT
