#! perl -w

use Parrot::Test tests => 3;
use Test::More;

output_is(<<'CODE', <<'OUTPUT', "PASM subs");
    new P0, .Sub
    set_addr I3, func
    set P0, I3
    set I5, 3
    save I5
    invoke
    print "done 1\n"
    set I5, 1
    clone P1, P0
    set P0, P1
    save I5
    invoke
    print "done 2\n"
    end

func:
    pushi
    restore I5
    print I5
    print "\n"
    eq I5, 0, endfunc
    dec I5
    save I5
    invoke
    inc I5
    print I5
    print " done\n"
endfunc:
    popi
    ret
CODE
3
2
1
0
1 done
2 done
3 done
done 1
1
0
1 done
done 2
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "Continuations");
    new P5, .PerlInt
    set P5, 3
    store_global P5, "foo"
    new P1, .Continuation
    set_addr I0, endcont
    set P1, I0
endcont:
    find_global P4, "foo"
    print "here "
    print P4
    print "\n"
    set P2, P1
    set P2, P2
    unless P4, done
    dec P4
    store_global P4, "foo"
    print "going to cont\n"
    clone P0, P1
    invoke
done:
    print "done\n"
    end

CODE
here 3
going to cont
here 2
going to cont
here 1
going to cont
here 0
done
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "Coroutines");
    new P0, .Coroutine
    set_addr I0, co2
    set P0, I0
co1:
    set I1, 4
    print "start 1\n"
co1_loop:
    invoke
    print "back  1\n"
    dec I1
    ne I1, 0, co1_loop
    print "done\n"
    end

co2:
    print "start 2\n"
    new P5, .Coroutine
    set_addr I0, co3
    set P5, I0
    set P6, P0
co2_loop:
    invoke
    print "back  2\n"
    set P0, P5
    invoke
    print "back  2b\n"
    set P0, P6
    branch co2_loop

co3:
    print "start 3\n"
    new P7, .Coroutine
    set_addr I0, co2_loop
    set P7, I0
    set P8, P0
co3_loop:
    invoke
    print "back  3\n"
    set P0, P7
    invoke
    print "back  3b\n"
    set P0, P8
    branch co3_loop

CODE
start 1
start 2
back  1
back  2
start 3
back  2b
back  1
back  2
back  3
back  3b
back  2b
back  1
back  2
back  3
back  2
back  2b
back  1
done
OUTPUT
