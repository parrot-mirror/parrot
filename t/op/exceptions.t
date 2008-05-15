#! perl
# Copyright (C) 2001-2008, The Perl Foundation.
# $Id$

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More;
use Parrot::Test tests => 33;

=head1 NAME

t/pmc/exception.t - Exception Handling

=head1 SYNOPSIS

    % prove t/pmc/exception.t

=head1 DESCRIPTION

Tests C<Exception> and C<Exception_Handler> PMCs.

=cut

pasm_output_is( <<'CODE', <<'OUTPUT', "push_eh label - pop_eh" );
    push_eh _handler
    print "ok 1\n"
    pop_eh
    print "ok 2\n"
    end
_handler:
    end
CODE
ok 1
ok 2
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "push_eh eh - pop_eh" );
    new P29, 'Exception_Handler'
    push_eh P29
    print "ok 1\n"
    pop_eh
    print "ok 2\n"
    end
CODE
ok 1
ok 2
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "push_eh - throw" );
    print "main\n"
    push_eh _handler
    new P30, 'Exception'
    throw P30
    print "not reached\n"
    end
_handler:
    print "caught it\n"
    end
CODE
main
caught it
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "push_eh eh - throw" );
    print "main\n"
    new P29, 'Exception_Handler'
    set_addr P29, _handler
    push_eh P29
    new P30, 'Exception'
    throw P30
    print "not reached\n"
    end
_handler:
    print "caught it\n"
    end
CODE
main
caught it
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "get_results" );
    print "main\n"
    push_eh handler
    new P1, 'Exception'
    set P1, "just pining"
    throw P1
    print "not reached\n"
    end
handler:
    get_results "0,0", P0, S0
    print "caught it\n"
    typeof S1, P0
    print S1
    print "\n"
    print S0
    print "\n"
    null P5
    end

CODE
main
caught it
Exception
just pining
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "get_results - be sure registers are ok" );
# see also #38459
    print "main\n"
    new P0, 'Integer'
    push_eh handler
    new P1, 'Exception'
    set P1, "just pining"
    throw P1
    print "not reached\n"
    end
handler:
    get_results "0,0", P1, S0
    inc P0
    print "ok\n"
    end

CODE
main
ok
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', ".get_results() - PIR" );
.sub main :main
    print "main\n"
    push_eh _handler
    new P1, 'Exception'
    set P1, "just pining"
    throw P1
    print "not reached\n"
    end
_handler:
    .local pmc e
    .local string s
    .get_results (e, s)
    print "caught it\n"
    typeof S1, e
    print S1
    print "\n"
    print s
    print "\n"
    null P5
.end
CODE
main
caught it
Exception
just pining
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "push_eh - throw - message" );
    print "main\n"
    push_eh _handler

    new P30, 'Exception'
    set P30, "something happend"
    throw P30
    print "not reached\n"
    end
_handler:
    get_results "0,0", P5, S0
    print "caught it\n"
    print S0
    print "\n"
    end
CODE
main
caught it
something happend
OUTPUT

pasm_error_output_like( <<'CODE', <<'OUTPUT', "throw - no handler" );
    new P0, 'Exception'
    set P0, "something happend"
    throw P0
    print "not reached\n"
    end
CODE
/something happend/
OUTPUT

pasm_error_output_like( <<'CODE', <<'OUTPUT', "throw - no handler, no message" );
    push_eh _handler
    new P0, 'Exception'
    pop_eh
    throw P0
    print "not reached\n"
    end
_handler:
    end
CODE
/No exception handler and no message/
OUTPUT

pasm_error_output_like( <<'CODE', <<'OUTPUT', "throw - no handler, no message" );
    new P0, 'Exception'
    throw P0
    print "not reached\n"
    end
CODE
/No exception handler and no message/
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "2 exception handlers" );
    print "main\n"
    push_eh _handler1
    push_eh _handler2

    new P30, 'Exception'
    set P30, "something happend"
    throw P30
    print "not reached\n"
    end
_handler1:
    get_results "0,0", P5, S0
    print "caught it in 1\n"
    print S0
    print "\n"
    end
_handler2:
    get_results "0,0", P0, S0
    print "caught it in 2\n"
    print S0
    print "\n"
    end
CODE
main
caught it in 2
something happend
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "2 exception handlers, throw next", todo => "deprecate rethrow" );
    print "main\n"
    push_eh _handler1
    push_eh _handler2

    new P30, 'Exception'
    set P30, "something happend"
    throw P30
    print "not reached\n"
    end
_handler1:
    get_results "0,0", P5, S0
    print "caught it in 1\n"
    print S0
    print "\n"
    end
_handler2:
    get_results "0,0", P5, S0
    print "caught it in 2\n"
    print S0
    print "\n"
    # throw P5	# XXX rethrow?
    end
CODE
main
caught it in 2
something happend
caught it in 1
something happend
OUTPUT

pasm_output_is( <<'CODE', <<OUT, "die" );
    push_eh _handler
    die 3, 100
    print "not reached\n"
    end
_handler:
    print "caught it\n"
    end
CODE
caught it
OUT

pasm_output_is( <<'CODE', <<OUT, "die, error, severity" );
    push_eh _handler
    die 3, 100
    print "not reached\n"
    end
_handler:
    get_results "0,0", P5, S0
    print "caught it\n"
    set I0, P5['severity']
    print "severity "
    print I0
    print "\n"
    end
CODE
caught it
severity 3
OUT

pasm_error_output_like( <<'CODE', <<OUT, "die - no handler" );
    die 3, 100
    print "not reached\n"
    end
_handler:
    print "caught it\n"
    end
CODE
/No exception handler and no message/
OUT

pasm_output_is( <<'CODE', '', "exit exception" );
    noop
    exit 0
    print "not reached\n"
    end
CODE

pasm_output_is( <<'CODE', <<'OUTPUT', "push_eh - throw" );
    print "main\n"
    push_eh handler
    print "ok\n"
    new P30, 'Exception'
    throw P30
    print "not reached\n"
    end
handler:
    print "caught it\n"
    end
CODE
main
ok
caught it
OUTPUT
1;

pasm_output_is( <<'CODE', <<'OUTPUT', "pushmark" );
    pushmark 10
    print "ok 1\n"
    popmark 10
    print "ok 2\n"
    end
CODE
ok 1
ok 2
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "pushmark nested" );
    pushmark 10
    pushmark 11
    print "ok 1\n"
    popmark 11
    popmark 10
    print "ok 2\n"
    end
CODE
ok 1
ok 2
OUTPUT

pasm_error_output_like( <<'CODE', <<'OUTPUT', "pushmark - pop wrong one" );
    pushmark 10
    print "ok 1\n"
    popmark 500
    print "never\n"
    end
CODE
/Mark 500 not found/
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "pushaction, throw" );
    push_eh handler
    print "ok 1\n"
    .const .Sub P10 = "action"
    pushaction P10
    print "ok 2\n"
    new P10, 'Exception'
    throw P10
    print "never\n"
handler:
    print "ok 3\n"
    end
.pcc_sub action:
    get_params "0", I5
    print "in action I5 = "
    print I5
    print "\n"
    returncc
CODE
ok 1
ok 2
in action I5 = 1
ok 3
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', 'cleanup global:  continuation' );
.sub main :main
    .local pmc outer, cont
    outer = new 'String'
    outer = "Outer value\n"
    set_global ['Foo'; 'Bar'], "test", outer
    new cont, 'Continuation'
    set_addr cont, endcont
    set_global ['Foo'; 'Bar'], "exit", cont
    show_value()
    test1()
    print "skipped.\n"
endcont:
    show_value()
.end
.sub test1
    .local pmc test1_binding, old_value, cleanup
    .lex "old_value", old_value
    test1_binding = new 'String'
    test1_binding = "Inner value\n"
    old_value = get_global ['Foo'; 'Bar'], "test"
    .const .Sub test1_cleanup_sub = "test1_cleanup"
    cleanup = newclosure test1_cleanup_sub
    pushaction cleanup
    set_global ['Foo'; 'Bar'], "test", test1_binding
    show_value()
    test2()
    show_value()
.end
.sub test1_cleanup :outer(test1)
    .local pmc old_value
    print "[in test1_cleanup]\n"
    find_lex old_value, "old_value"
    set_global ['Foo'; 'Bar'], "test", old_value
.end
.sub test2
    .local pmc test2_binding, exit
    test2_binding = new 'String'
    test2_binding = "Innerer value\n"
    set_global ['Foo'; 'Bar'], "test", test2_binding
    show_value()
    exit = get_global ['Foo'; 'Bar'], "exit"
    exit()
.end
.sub show_value
    .local pmc value
    value = get_global ['Foo'; 'Bar'], "test"
    print value
.end
CODE
Outer value
Inner value
Innerer value
[in test1_cleanup]
Outer value
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', 'cleanup global:  throw' );
.sub main :main
    .local pmc outer
    outer = new 'String'
    outer = "Outer value\n"
    set_global ['Foo'; 'Bar'], "test", outer
    push_eh eh
    show_value()
    test1()
    print "skipped.\n"
eh:
    .local pmc exception
    .get_results (exception, $S0)
    print "Error: "
    print exception
    print "\n"
last:
    show_value()
.end
.sub test1
    .local pmc test1_binding, old_value, cleanup
    .lex "old_value", old_value
    test1_binding = new 'String'
    test1_binding = "Inner value\n"
    old_value = get_global ['Foo'; 'Bar'], "test"
    .const .Sub test1_cleanup_sub = "test1_cleanup"
    cleanup = newclosure test1_cleanup_sub
    pushaction cleanup
    set_global ['Foo'; 'Bar'], "test", test1_binding
    show_value()
    test2()
    show_value()
.end
.sub test1_cleanup :outer(test1)
    .local pmc old_value
    print "[in test1_cleanup]\n"
    find_lex old_value, "old_value"
    set_global ['Foo'; 'Bar'], "test", old_value
.end
.sub test2
    .local pmc test2_binding, exit
    test2_binding = new 'String'
    test2_binding = "Innerer value\n"
    set_global ['Foo'; 'Bar'], "test", test2_binding
    show_value()
    exit = new 'Exception'
    exit = "something happened"
    throw exit
.end
.sub show_value
    .local pmc value
    value = get_global ['Foo'; 'Bar'], "test"
    print value
.end
CODE
Outer value
Inner value
Innerer value
[in test1_cleanup]
Error: something happened
Outer value
OUTPUT

pir_error_output_like( <<'CODE', <<'OUTPUT', 'pop_eh out of context (1)' );
.sub main :main
    pushmark 1
    pop_eh
    print "no exceptions.\n"
.end
CODE
/No handler to delete./
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', 'pop_eh out of context (2)', todo => 'handler dynamic scope' );
.sub main :main
    .local pmc outer, cont
    push_eh handler
    test1()
    print "skipped.\n"
    goto done
handler:
    .local pmc exception
    .get_results (exception, $S0)
    print "Error: "
    print $S0
    print "\n"
done:
    print "done.\n"
.end
.sub test1
    .local pmc exit
    print "[in test1]\n"
    ## pop_eh is illegal here, and signals an exception.
    pop_eh
    print "[cleared]\n"
.end
CODE
[in test1]
Error: No handler to delete.
done.
OUTPUT

# stringification is handled by a vtable method, which runs in a second
# runloop. when an error in the method tries to go to a Error_Handler defined
# outside it, it winds up going to the inner runloop, giving strange results.
pir_output_is( <<'CODE', <<'OUTPUT', 'pop_eh out of context (2)', todo => 'runloop shenanigans' );
.sub main :main
        $P0 = get_hll_global ['Foo'], 'load'
        $P0()
        $P0 = new 'Foo'
        push_eh catch
        $S0 = $P0
        pop_eh
        say "huh?"
        .return()

catch:
        say "caught"
        .return()
.end

.namespace ['Foo']

.sub load
    $P0 = newclass 'Foo'
.end

.sub get_string :vtable :method
    $P0 = new 'Exception'
    throw $P0
.end
CODE
caught
OUTPUT

pir_error_output_like( <<'CODE', <<'OUTPUT', "pushaction - throw in main" );
.sub main :main
    print "main\n"
    .const .Sub at_exit = "exit_handler"
    pushaction at_exit
    $P0 = new 'Exception'
    throw $P0
    .return()
.end

.sub exit_handler
    .param int flag
    print "at_exit, flag = "
    say flag
.end
CODE
/^main
No exception handler/
OUTPUT

# exception handlers are still run in an inferior runloop, which messes up
# nonlocal exit from within handlers.
pir_output_like(
    <<'CODE', <<'OUTPUT', "pushaction: error while handling error", todo => 'runloop shenanigans' );
.sub main :main
    push_eh h
    print "main\n"
    .const .Sub at_exit = "exit_handler"
    pushaction at_exit
    $P1 = new 'Exception'
    throw $P1
    print "never 1\n"
h:
    ## this is never actually reached, because exit_handler throws an unhandled
    ## exception before the handler is entered.
    print "in outer handler\n"
.end

.sub exit_handler :outer(main)
    .param int flag
    print "at_exit, flag = "
    say flag
    $P2 = new 'Exception'
    throw $P2
    print "never 2\n"
.end
CODE
/^main
at_exit, flag = 1
No exception handler/
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', "exit_handler via exit exception" );
.sub main :main
    .local pmc a
    .lex 'a', a
    a = new 'Integer'
    a = 42
    push_eh handler
    exit 0
handler:
    .return exit_handler()
.end

.sub exit_handler :outer(main)
    say "at_exit"
    .local pmc a
    a = find_lex 'a'
    print 'a = '
    say a
.end
CODE
at_exit
a = 42
OUTPUT

## Regression test for r14697.  This probably won't be needed when PDD23 is
## fully implemented.
pir_error_output_like( <<'CODE', <<'OUTPUT', "invoke handler in calling sub", todo => 'deprecate rethrow' );
## This tests that error handlers are out of scope when invoked (necessary for
## rethrow) when the error is signalled in another sub.
.sub main :main
    push_eh handler
    broken()
    print "not reached.\n"
handler:
    .local pmc exception
    .get_results (exception, $S0)
    print "in handler.\n"
    print $S0
    print "\n"
    # rethrow exception
.end

.sub broken
    $P0 = new 'Exception'
    $P0 = "something broke"
    throw $P0
.end
CODE
/\Ain handler.
something broke
something broke
current inst/
OUTPUT

pir_error_output_like( <<'CODE', <<'OUTPUT', 'die_s' );
.sub main :main
    die 'We are dying str!'
.end
CODE
/We are dying str!/
OUTPUT
pir_error_output_like( <<'CODE', <<'OUTPUT', 'die_p' );
.sub main :main
    .local pmc msg
    msg = new 'String'
    msg = 'We are dying pmc!'
    die msg
.end
CODE
/We are dying pmc!/
OUTPUT

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
