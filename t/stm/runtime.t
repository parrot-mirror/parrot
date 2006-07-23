#! perl
# Copyright (C) 2006 The Perl Foundation.
# $Id: ref.t 12842 2006-05-30 16:52:42Z creiss $

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More;
use Parrot::Test tests => 3;

pir_output_is(<<'CODE', <<'OUTPUT', "choice (one thread)");
.sub do_choice
    .param pmc values
    .lex 'values', values

    .local pmc _choice_one
    .local pmc _choice_two
    .const .Sub choice_one = 'choice_one'
    .const .Sub choice_two = 'choice_two'
    _choice_one = newclosure choice_one
    _choice_two = newclosure choice_two
    .local pmc _choice
    _choice = find_global 'STM', 'choice'
    .return _choice(_choice_one, _choice_two)
.end

.sub choice_one :outer(do_choice)
    .local pmc values
    values = find_lex 'values'
    .local pmc what
    what = values[0]
    what = what.'get_update'()
    if what == 1 goto need_retry
    what = 1
    .return (1)
need_retry:
    .local pmc retry
    retry = find_global 'STM', 'retry'
    retry()
.end

.sub choice_two :outer(do_choice)
    .local pmc values
    values = find_lex 'values'
    .local pmc what
    .local pmc the_value
    what = values[1]
    the_value = what.'get_read'()
    if the_value == 1 goto need_retry
    the_value = new Integer
    the_value = 1
    what.'set'(the_value)
    .return (2)
need_retry:
    .local pmc retry
    retry = find_global 'STM', 'retry'
    retry()
.end

.sub main :main
    .local pmc thread_one
    .local pmc thread_two
    thread_one = new ParrotThread
    thread_two = new ParrotThread

    load_bytecode 'STM.pbc'

    .local pmc values
    values = new FixedPMCArray
    values = 2
    $P0 = new Integer
    $P0 = 0
    $P0 = new STMVar, $P0
    values[0] = $P0
    $P0 = new Integer
    $P0 = 0
    $P0 = new STMVar, $P0
    values[1] = $P0
    .local pmc _thread_main
    _thread_main = global 'do_choice'

    $I0 = _thread_main(values)
    $I1 = _thread_main(values)
    $I2 = $I0 + $I1
    if $I2 != 3 goto fail
    if $I0 == 1 goto okay
    if $I1 == 1 goto okay
fail:
    print 'not ok '
    print $I1
    print ', '
    print $I2
    print "\n"
    end
okay:
    print "ok\n"
.end
CODE
ok
OUTPUT

pir_output_is(<<'CODE', <<'OUTPUT', "choice (multiple threads)\n");
.sub do_choice
    .param pmc values
    .lex 'values', values

    .local pmc _choice_one
    .local pmc _choice_two
    .const .Sub choice_one = 'choice_one'
    .const .Sub choice_two = 'choice_two'
    _choice_one = newclosure choice_one
    _choice_two = newclosure choice_two
    .local pmc _choice
    _choice = find_global 'STM', 'choice'
    $I0 = _choice(_choice_one, _choice_two)
    .return ($I0)
.end

.sub choice_one :outer(do_choice)
    .local pmc values
    values = find_lex 'values'
    .local pmc what
    what = values[0]
    what = what.'get_update'()
    if what == 1 goto need_retry
    what = 1
    .return (1)
need_retry:
    .local pmc retry
    retry = find_global 'STM', 'retry'
    retry()
.end

.sub choice_two :outer(do_choice)
    .local pmc values
    values = find_lex 'values'
    .local pmc what
    .local pmc the_value
    what = values[1]
    the_value = what.'get_read'()
    if the_value == 1 goto need_retry
    the_value = new Integer
    the_value = 1
    what.'set'(the_value)
    .return (2)
need_retry:
    .local pmc retry
    retry = find_global 'STM', 'retry'
    retry()
.end

.sub _wakeup_func
    .param pmc values
    .local pmc what
    sleep 1
    what = values[0]
    what.'set'(0)
.end

.sub wakeup_func
    .param pmc values
    .local pmc transaction
    .local pmc real_sub
    transaction = find_global 'STM', 'transaction'
    real_sub = global '_wakeup_func'
    transaction(real_sub, values)
    .return (0)
.end

.sub main :main
    .local pmc thread_one
    .local pmc thread_two
    .local pmc thread_three
    .local pmc wakeup_thread
    thread_one = new ParrotThread
    thread_two = new ParrotThread
    thread_three = new ParrotThread
    wakeup_thread = new ParrotThread

    load_bytecode 'STM.pbc'

    .local pmc values
    values = new FixedPMCArray
    values = 2
    $P0 = new Integer
    $P0 = 0
    $P0 = new STMVar, $P0
    values[0] = $P0
    $P0 = new Integer
    $P0 = 0
    $P0 = new STMVar, $P0
    values[1] = $P0
    .local pmc _thread_main
    _thread_main = global 'do_choice'
    thread_one.'run_clone'(_thread_main, values)
    thread_two.'run_clone'(_thread_main, values)
    thread_three.'run_clone'(_thread_main, values)
    .local pmc _wakeup_thread_main
    _wakeup_thread_main = global 'wakeup_func'
    wakeup_thread.'run_clone'(_wakeup_thread_main, values)
    $I0 = thread_one.'join'()
    $I1 = thread_two.'join'()
    $I2 = thread_three.'join'()
    wakeup_thread.'join'()

    if $I0 < 1 goto fail
    if $I1 < 1 goto fail
    if $I2 < 1 goto fail
    if $I0 > 2 goto fail
    if $I1 > 2 goto fail
    if $I2 > 2 goto fail
    .local int num_ones
    num_ones = 0
    if $I0 != 1 goto zero_two
    inc num_ones
zero_two:
    if $I1 != 1 goto one_two
    inc num_ones
one_two:
    if $I2 != 1 goto two_two
    inc num_ones
two_two:
    if num_ones != 2 goto fail
    print "ok\n"
    end
fail:
    print "not ok\n"
    print 'I0 = '
    print $I0
    print '; I1 = '
    print $I1
    print '; I2 = '
    print $I2
    print "\n"
.end
CODE
ok
OUTPUT

pir_output_is(<<'CODE', <<'OUTPUT', "queue adapted for the runtime");
.const int MAX = 5000
.const int SIZE = 100


# attributes:
#   head: index of next element to read
#   tail: index of next element to add
#   used: index of number of items used
#   array: fixed-sized array of STMVars.

.namespace ['STMQueue']

.sub __onload 
    .local pmc class
    $I0 = find_type 'STMQueue'
    if $I0 goto done
    class = newclass 'STMQueue'
    addattribute class, 'head'
    addattribute class, 'tail'
    addattribute class, 'used'
    addattribute class, 'array'
    .return()
done:
.end

.sub __init :method
    .param int length

    .local pmc tmpint
    .local pmc stmv

    tmpint = new Integer
    tmpint = 0
    stmv = new STMVar, tmpint
    setattribute self, 'head', stmv
    stmv = new STMVar, tmpint
    setattribute self, 'used', stmv
    stmv = new STMVar, tmpint
    setattribute self, 'tail', stmv
    
    # create array
    .local pmc array
    array = new Array
    array = length
    .local int i
    i = 0
loop:
    stmv = new STMVar
    array[i] = stmv
    inc i
    if i < length goto loop
    setattribute self, 'array', array
.end

.sub fetchHead :method
    .param int removep
    .param int blockp

    $P0 = find_global 'STM', 'transaction'
    $P1 = global '_fetchHead'
    .return $P0($P1, self, removep, blockp)
.end

.sub _fetchHead :method
    .param int removep
    .param int blockp
    .local pmc i
    .local pmc tmp
    .local pmc used
    .local pmc ret
    .local int length
    used = getattribute self, 'used'
    used = used.'get_read'()
    if used != 0 goto have_items
    
    unless blockp goto no_block
    $P0 = find_global 'STM', 'retry'
    $P0()

have_items:
    tmp = getattribute self, 'head'
    i = tmp.'get_read'()
    tmp = getattribute self, 'array'
    tmp = tmp[i]
    ret = tmp.'get_read'()
    
    unless removep goto skip_remove
    tmp = getattribute self, 'head'
    $P0 = getattribute self, 'array'
    length = $P0
    i = clone i
    inc i
    i = i % length
    tmp.'set'(i)
    tmp = getattribute self, 'used'
    used = clone used
    used = used - 1
    tmp.'set'(used)
skip_remove:
    branch normal_return

no_block:
    ret = new Undef
    $P0 = find_global 'STM', 'give_up'
    $P0()
normal_return:
    .return (ret) 
.end

.sub addTail :method
    .param pmc what
    .param int blockp

    $P0 = find_global 'STM', 'transaction'
    $P1 = global '_addTail'
    $P2 = $P0($P1, self, what, blockp)
    .return ($P2)
.end

.sub _addTail :method
    .param pmc what
    .param int blockp

    .local pmc i
    .local pmc used
    .local int length
    .local int ret

    .local pmc tmp

    ret = 1
    i = getattribute self, 'tail'
    i = i.'get_read'()
    used = getattribute self, 'used'
    used = used.'get_update'()
    $P0 = getattribute self, 'array'
    length = $P0

    if used == length goto is_full

    inc used

    tmp = getattribute self, 'array'
    tmp = tmp[i]
    tmp.'set'(what)
    i = clone i
    inc i
    i = i % length

    tmp = getattribute self, 'tail'
    tmp.'set'(i)

    branch do_ret

is_full:
    unless blockp goto no_block
    $P0 = find_global 'STM', 'retry'
    $P0()

no_block:
    $P0 = find_global 'STM', 'give_up'
    $P0()
error:
    ret = 0
do_ret:
    .return (ret)
.end
.sub adder
    .param pmc queue
    .local int i
    
    i = 0
loop:
    queue.'addTail'(i, 1)
    inc i
    if i < MAX goto loop
.end

.sub remover
    .param pmc queue
    .local int i
    .local int failed
    .local pmc got

    failed = 0 
    i = 0
loop:
    got = queue.'fetchHead'(1, 1)
    if got != i goto not_okay
    inc i
    if i < MAX goto loop
    print "ok\n"
    .return ()
not_okay:
    print "not ok\n"
.end

.sub main :main
    .local pmc addThread
    .local pmc removeThread
    .local pmc queue
    .local pmc me

    .local pmc _add
    .local pmc _remove

    .local pmc copy
     
    .local int addThreadId
    .local int removeThreadId

    load_bytecode 'STM.pbc'

    $P0 = find_global 'STMQueue', '__onload'
    $P0()

    _add = global "adder"
    _remove = global "remover"

    addThread = new ParrotThread
    removeThread = new ParrotThread
    $I0 = find_type 'STMQueue'
    $P0 = new Integer
    $P0 = SIZE 
    queue = new $I0, $P0

    # addThreadId = addThread
    # removeThreadId = removeThread

    addThread.'run_clone'(_add, queue)
    removeThread.'run_clone'(_remove, queue)
    removeThread.'join'()
    addThread.'join'()
.end
CODE
ok
OUTPUT
