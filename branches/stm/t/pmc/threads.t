#! perl
# Copyright: 2001-2005 The Perl Foundation.  All Rights Reserved.
# $Id$

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More;
use Parrot::Test;

=head1 NAME

t/pmc/threads.t - Threads

=head1 SYNOPSIS

	% prove t/pmc/threads.t

=head1 DESCRIPTION

Tests running threads. All tests skipped unless running on known-good
platform.

=cut

my %platforms = map {$_=>1} qw/
    aix
    cygwin
    darwin
    dec_osf
    freebsd
    hpux
    irix
    linux
    openbsd
    MSWin32
/;

if ($^O eq "cygwin" ) {
    my @uname = split / /, qx'uname -v';

    if ($uname[0] eq "2004-09-04" ) {
	plan skip_all => "This cygwin version is known to fail the thread tests";
	exit;
    }
}
if ($platforms{$^O}) {
   plan tests => 11;
}
else {
   # plan skip_all => "No threading yet or test not enabled for '$^O'";
   plan skip_all => "Needs COPY for argument passing";
}


pasm_output_is(<<'CODE', <<'OUTPUT', "interp identity");
    getinterp P2
    clone P3, P2
    eq P3, P2, ok1
    print "not"
ok1:
    print "ok 1\n"
    new P4, .ParrotThread
    ne P4, P2, ok2
    print "not"
ok2:
    print "ok 2\n"
    end
CODE
ok 1
ok 2
OUTPUT

pir_output_is(<<'CODE', <<'OUTPUT', "thread type 1");
.sub main :main
    .local pmc threadfunc
    .local pmc thread
    I5 = 10
    threadfunc = global "foo"
    thread = new .ParrotThread
    thread.'thread1'(threadfunc)

    sleep 1
    print "main "
    print I5
    print "\n"
    # get tid of thread
    $I0 = thread 
    # wait for it
    thread.'join'()
.end

.sub foo 
    # check if vars are fresh
    inc I5
    print "thread "
    print I5
    print "\n"
    set I3, 0   # no retval
    returncc	# ret and be done with thread
.end
# output from threads could be reversed
CODE
thread 1
main 10
OUTPUT

pir_output_is(<<'CODE', <<'OUTPUT', "thread type 2");
.sub main :main
    set I5, 10
    .local pmc thread
    .local pmc threadsub
    S5 = " interp\n"
    P6 = new .String
    P6 = 'from '

    print "ok 1\n"
    threadsub = global "foo"
    thread = new .ParrotThread
    thread.'thread2'(threadsub, P6)
    sleep 1 # to let the thread run
    print P6
    print I5
    print S5
    thread.'join'()
.end

.sub foo
    .param pmc passed
    inc I5
    S5 = " thread\n"
    passed = 'hello from '
    print passed
    print I5
    print S5
    $P0 = getinterp
    $S0 = typeof $P0
    print $S0
    print ' tid '
    $I0 = $P0
    print $I0
    print "\n"
.end
CODE
ok 1
hello from 1 thread
ParrotThread tid 1
from 10 interp
OUTPUT

pir_output_is(<<'CODE', <<'OUTPUT', 'thread - kill');
.sub main :main
    .local pmc threadsub
    .local pmc thread
    bounds 1	# assert slow core -S and -g are fine too
    threadsub = global "foo"
    thread = new .ParrotThread
    $I0 = thread
    print 'start '
    print $I0
    print "\n"
    thread.'thread3'(threadsub)

    sleep 1 # to let the thread run

    thread.'kill'()

    print "done\n"
.end

.sub foo
    print "in thread\n"
    # run an endles loop
lp:
    noop
    branch lp
.end
CODE
start 1
in thread
done
OUTPUT
    

pir_output_is(<<'CODE', <<'OUTPUT', "join, get retval");
.sub _main
    .const int MAX = 1000
    .sym pmc kid
    .sym pmc Adder
    Adder = global '_add'
    kid = new ParrotThread
    .sym pmc from
    from = new Integer
    from = 0
    .sym pmc to
    to = new Integer
    to = MAX
    kid.'thread3'(Adder, Adder, from, to)

    .local pmc result
    result = kid.'join'()
    print result
    print "\n"
    # sum = n * (n + 1)/2
    .sym pmc Mul
    Mul = new Integer
    assign Mul, to
    inc Mul
    Mul = to * Mul
    Mul = Mul / 2
    print Mul
    print "\n"
    end
.end

.sub _add
   .param pmc sub
   .param pmc from
   .param pmc to
   .sym   pmc sum
   sum = new Integer
loop:
    add sum, from
    inc from
    le from, to, loop

    .pcc_begin_return
    .return sum
    .pcc_end_return
.end
CODE
500500
500500
OUTPUT

SKIP: {
	skip("detatch broken on $^O", 1) if ($^O =~ /MSWin32/);
pir_output_like(<<'CODE', <<'OUTPUT', "detach");
.sub main :main
    .local pmc foo
    .local pmc queue
    .local pmc thread
    foo = global '_foo'
    queue = new .TQueue # flag for when the thread is done
    thread = new .ParrotThread
    thread.'thread3'(foo, queue)
    
    thread.'detach'()
wait:
    defined $I0, queue
    if $I0 == 0 goto wait
    print "done\n"
.end

.sub _foo
    .param pmc queue
    print "thread\n"
    sleep 0.1
    $P1 = new .Integer
    push queue, $P1
.end
CODE
/(done\nthread\n)|(thread\ndone\n)/
OUTPUT
}

pir_output_is(<<'CODE', <<'OUTPUT', "share a PMC");
.sub main :main
    .local pmc foo
    foo = global "_foo"
    .local pmc to_share
    to_share = new Integer
    .local pmc shared_ref
    shared_ref = new SharedRef, to_share
    shared_ref = 20
    .local pmc thread
    thread = new ParrotThread
    thread.'thread3'(foo, shared_ref)

    sleep 0.1 # to let the thread run
    
    .local pmc result
    thread.'join'()
    print "done\n"
    print shared_ref
    print "\n"
.end

.sub _foo
    .param pmc shared_ref
    print "thread\n"
    print shared_ref
    print "\n"
    inc shared_ref
.end
CODE
thread
20
done
21
OUTPUT

pir_output_is(<<'CODE', <<'OUT', "multi-threaded");
.sub main :main
    .local pmc queue
    queue = new TQueue
    .local pmc tmpInt
    tmpInt = new Integer
    tmpInt = 1
    push queue, tmpInt
    tmpInt = new Integer
    tmpInt = 2
    push queue, tmpInt
    tmpInt = new Integer
    tmpInt = 3
    push queue, tmpInt
    
    .local pmc thread
    thread = new ParrotThread
    .local pmc foo
    foo = global '_foo'
    thread.'thread3'(foo, queue)
    thread.'join'()
    print "done main\n"
.end

.sub _foo
    .param pmc queue
    $I0 = queue
    print $I0
    print "\n"
loop:
    $I0 = queue
    if $I0 == 0 goto done 
    shift $P0, queue
    print $P0
    print "\n"
    branch loop
done:
    print "done thread\n"
.end
CODE
3
1
2
3
done thread
done main
OUT

pir_output_is(<<'CODE', <<'OUT', 'multi-threaded strings via SharedRef');
.sub main :main
    .local pmc queue
    .local pmc tmp_string
    .local pmc shared_ref

    queue = new TQueue
    tmp_string = new String
    tmp_string = "ok 1\n"
    shared_ref = new SharedRef, tmp_string
    push queue, shared_ref
    tmp_string = new String
    tmp_string = "ok 2\n"
    shared_ref = new SharedRef, tmp_string
    push queue, shared_ref
    tmp_string = new String
    tmp_string = "ok 3\n"
    shared_ref = new SharedRef, tmp_string
    push queue, shared_ref

    .local pmc thread
    .local pmc foo

    thread = new ParrotThread
    foo = global '_foo'
    thread.'thread3'(foo, queue)
    thread.'join'()
    print "done main\n"
.end

.sub _foo
    .param pmc queue
    $I0 = queue
    print $I0
    print "\n"
loop:
    $I0 = queue
    if $I0 == 0 goto done
    shift $P0, queue
    print $P0
    branch loop
done:
    print "done thread\n"
.end
CODE
3
ok 1
ok 2
ok 3
done thread
done main
OUT

SKIP: {
skip("no shared Strings yet", 2);
pasm_output_is(<<'CODE', <<'OUT', "thread safe queue strings 1");
    new P10, .TQueue
    print "ok 1\n"
    set I0, P10
    print I0
    print "\n"
    new P7, .String
    set P7, "ok 2\n"
    push P10, P7
    new P7, .String
    set P7, "ok 3\n"
    push P10, P7
    set I0, P10
    print I0
    print "\n"

    shift P8, P10
    print P8
    shift P8, P10
    print P8
    end
CODE
ok 1
0
2
ok 2
ok 3
OUT

pasm_output_is(<<'CODE', <<'OUT', "multi-threaded strings");
    new P10, .TQueue
    new P7, .String
    set P7, "ok 1\n"
    push P10, P7
    new P7, .String
    set P7, "ok 2\n"
    push P10, P7
    new P7, .String
    set P7, "ok 3\n"
    push P10, P7
    set P6, P10

    find_global P5, "_foo"
    new P2, .ParrotThread
    callmethod "thread3"
    set I5, P2
    getinterp P2
    callmethod "join"
    print "done main\n"
    end

.pcc_sub _foo:
    set I0, P6
    print I0
    print "\n"
loop:
    set I0, P6
    unless I0, ex
    shift P8, P6
    print P8
    branch loop
ex:
    print "done thread\n"
    returncc
CODE
3
ok 1
ok 2
ok 3
done thread
done main
OUT
}
