#! perl -w

use Parrot::Test tests => 10;
use Test::More;

output_is(<<'CODE', <<'OUTPUT', "PASM subs - newsub");
    print "main\n"
    newsub .Sub, .Continuation, _func, _ret
    invoke
_ret:
    print "back\n"
    end
_func:
    print "func\n"
    invoke P1
CODE
main
func
back
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "PASM subs - newsub 2");
    print "main\n"
    newsub P0, .Sub, _func
    invokecc
    print "back\n"
    end
_func:
    print "func\n"
    invoke P1
CODE
main
func
back
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "PASM subs - invokecc");
    new P0, .Sub
    set_addr I3, func
    set P0, I3

    set I5, 3
    save I5

    invokecc

    restore I5
    print I5
    print "\n"
    end

func:
    print I5
    print "\n"

    eq I5, 0, endfunc
    dec I5

    save P1
    invokecc   # recursive invoke
    restore P1

endfunc:
    invoke P1
CODE
3
2
1
0
3
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "PASM subs - invokecc_p");
    new P0, .Sub
    set_addr I3, func
    set P0, I3

    set I5, 3
    save I5

    invokecc P0

    restore I5
    print I5
    print "\n"
    end

func:
    print I5
    print "\n"

    eq I5, 0, endfunc
    dec I5

    save P1
    invokecc P0  # recursive invoke
    restore P1

endfunc:
    invoke P1
CODE
3
2
1
0
3
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "Continuation");
    new P5, .PerlInt
    set P5, 3
    store_global "foo", P5
    new P1, .Continuation
    set_addr I0, endcont
    set P1, I0
endcont:
    find_global P4, "foo"
    print "here "
    print P4
    print "\n"
    unless P4, done
    dec P4
    store_global "foo", P4
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

output_is(<<'CODE', <<'OUTPUT', "definedness of Continuation");
    new P1, .Continuation
    defined I1, P1
    print I1
    print "\n"
    set_addr I0, cont
    set P1, I0
    defined I1, P1
    print I1
    print "\n"
    end

cont:
    print "I'm a very boring continuation"
    end

CODE
0
1
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "PASM sub as closure");
    # sub foo {
    #     my ($n) = @_;
    #     sub {$n += shift}
    # }
    # my $f = foo(5);
    # print &$f(3), "\n";
    # print &$f(3), "\n";
    # print &$f(3), "\n";
main:

    new P0, .Sub
    set_addr I3, foo
    set P0, I3

    new P5, .PerlInt
    set P5, 5

    invokecc
    set P0, P5	# the closure

    new P5, .PerlInt
    set P5, 3

    pushbottomp	# preserve P regs
    invokecc
    save P5	# result in P5
    popbottomp
    restore P2

    print P2
    print "\n"

    pushbottomp	# preserve P regs
    invokecc
    save P5	# result in P5
    popbottomp
    restore P2

    print P2
    print "\n"

    pushbottomp	# preserve P regs
    invokecc
    save P5	# result in P5
    popbottomp
    restore P2

    print P2
    print "\n"

    end

# foo takes a number n (P5) and returns a sub (in P5) that takes
# a number i (P5) and returns n incremented by i.
foo:
    new_pad 0
    store_lex 0, "n", P5
    new P5, .Sub	# P5 has now the lexical "n" in the pad
    set_addr I3, f
    set P5, I3
    invoke P1		# ret

# expects arg in P5, returns incremented result in P5
f:
    find_lex P2, "n"	# invoke-ing the Sub pushes the lexical pad
    			# of the closure on the pad stack
    add P2, P5		# n += shift, the lexical is incremented
    new P5, .PerlInt
    set P5, P2
    invoke P1		# ret

CODE
8
11
14
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "PASM subs - tail invoke");
    new P0, .Sub
    set_addr I3, func1
    set P0, I3

    invokecc
    print "done\n"
    end

func1:
    print "in func1\n"

    new P0, .Sub
    set_addr I3, func2
    set P0, I3

    invoke    # tail invoke (reuses context already in P1)
    print "this should not be called\n"
    end

func2:
    print "in func2\n"
    invoke P1

CODE
in func1
in func2
done
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "PASM subs - tail invoke with newsub");
    newsub P0, .Sub, func1

    invokecc
    print "done\n"
    end

func1:
    print "in func1\n"

    newsub P0, .Sub, func2

    invoke    # tail invoke (reuses context already in P1)
    print "this should not be called\n"
    # XXX this end is here for JIT/i386
    end

func2:
    print "in func2\n"
    invoke P1

CODE
in func1
in func2
done
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "sub calling a sub");
    print "main\n"
    newsub .Sub, .Continuation, _func1, ret1
    invoke
ret1:
    print "back\n"
    end

_func1:
    print "func1\n"
    pushbottomp
    newsub .Sub, .Continuation, _func2, ret2
    invoke
ret2:
    popbottomp
    print "func1\n"
    invoke P1

_func2:
    print "func2\n"
    invoke P1

CODE
main
func1
func2
func1
back
OUTPUT

1;
