#! perl
# Copyright (C) 2006 The Perl Foundation.
# $Id$
use warnings;
use strict;
use lib qw( . lib ../lib ../../lib );
use Parrot::Test tests => 2;


my $library = <<'CODE';

# STM fixed-sized, array-based queue.
# attributes:
#   head: index of next element to read
#   tail: index of next element to add
#   used: index of number of items used
#   array: fixed-sized array of STMVars.

.namespace ['STMQueue']

.sub __onload :immediate 
    .local pmc class
    class = newclass 'STMQueue'
    addattribute class, 'head'
    addattribute class, 'tail'
    addattribute class, 'used'
    addattribute class, 'array'
    .return()
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
    .local pmc i
    .local pmc tmp
    .local pmc used
    .local pmc ret
    .local int length
tx:
    stm_start
    used = self['used']
    used = used.'get_read'()
    if used != 0 goto have_items
    
    unless blockp goto no_block
    # FIXME: probably should throw exception instead
    # of going to no_block
    stm_wait no_block 
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
    inc i
    i = i % length
    tmp.'set'(i)
    tmp = getattribute self, 'used'
    used = used - 1
    tmp.'set'(used)
skip_remove:

    stm_commit tx
    branch normal_return

no_block:
    ret = new Undef
    stm_abort
normal_return:
    .return (ret) 
.end

.sub addTail :method
    .param pmc what
    .param int blockp

    .local pmc i
    .local pmc used
    .local int length
    .local int ret

    .local pmc tmp

    ret = 1
tx:
    stm_start

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
    inc i
    i = i % length

    tmp = getattribute self, 'tail'
    tmp.'set'(i)

    stm_commit tx

is_full:
    unless blockp goto no_block
    stm_wait error
    branch tx

no_block:
    stm_abort
error:
    ret = 0
    .return (ret)
.end

.sub __clone :method
    .local pmc result
    .local pmc length

    __onload() # XXX FIXME workaround?
    $P0 = getattribute self, 'array'
    $I0 = $P0
    length = new Integer
    length = $I0
    $I1 = typeof self
    result = new $I1, length
    
    $P0 = getattribute self, 'array'
    $P1 = clone $P0
    setattribute result, 'array', $P1
    $P0 = getattribute self, 'head'
    setattribute result, 'head', $P0
    $P0 = getattribute self, 'tail'
    setattribute result, 'tail', $P0
    $P0 = getattribute self, 'used'
    setattribute result, 'used', $P0
    .return (result)
.end
CODE

pir_output_is(<<'CODE' . $library, <<'OUTPUT', "Single-threaded case");
.sub main :main
    .local pmc queue

    $I0 = find_type 'STMQueue'
    $P0 = new Integer
    $P0 = 10
    queue = new $I0, $P0


    queue.'addTail'(0, 0)
    queue.'addTail'(1, 0)
    queue.'addTail'(2, 0)
    queue.'addTail'(3, 0)
    $I0 = queue.'fetchHead'(1, 1)
    $I1 = queue.'fetchHead'(1, 1)
    $I2 = queue.'fetchHead'(1, 1)
    $I3 = queue.'fetchHead'(1, 1)

    print $I0
    print $I1
    print $I2
    print $I3
    print "\n"
.end

CODE
0123
OUTPUT


pir_output_is(<<'CODE' . $library, <<'OUTPUT', "Add in one thread, remove in the other");

.sub adder
    .param pmc queue
    .local int i
    i = 0
loop:
    queue.'addTail'(i, 1)
    inc i
    if i < 10 goto loop
.end

.sub remover
    .param pmc queue
    .local int i
    .local int failed
    .local pmc got
    failed = 0 
    i = 1
loop:
    got = queue.'fetchHead'(1, 1)
    print "got "
    print got
    print "\n"
    inc i
    if i < 10 goto loop
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

    _add = global "adder"
    _remove = global "remover"

    addThread = new ParrotThread
    removeThread = new ParrotThread
    $I0 = find_type 'STMQueue'
    $P0 = new Integer
    $P0 = 2 
    queue = new $I0, $P0

    addThreadId = addThread
    removeThreadId = removeThread

    addThread.'thread3'(_add, queue)
    removeThread.'thread3'(_remove, queue)
    addThread.'join'()
    removeThread.'join'()
.end

CODE
got 0
got 1
got 2
got 3
got 4
got 5
got 6
got 7
got 8
got 9
OUTPUT
