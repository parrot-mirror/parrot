#!perl
# Copyright (C) 2001-2007, The Perl Foundation.
# $Id$

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More;
use Parrot::Test tests => 24;

=head1 NAME

t/op/stacks.t - Stacks

=head1 SYNOPSIS

        % prove t/op/stacks.t

=head1 DESCRIPTION

Tests for stack operations, currently C<push*>, C<push_*_c> and C<pop*>
where C<*> is not C<p>.

=cut

# Tests for stack operations, currently push*, push_*_c and pop*
# where * != p.

# Assembler code is partially generated by subs at bottom of file

# This defines two macros:
# fp_eq N, N, LABEL
# fp_ne N, N, LABEL
# which will conditionally branch
# to LABEL if abs(n,n) < epsilon

my $fp_equality_macro = <<'ENDOFMACRO';
.macro fp_eq(J,K,L)
        save    N0
        save    N1
        save    N2

        set     N0, .J
        set     N1, .K
        sub     N2, N1,N0
        abs     N2, N2
        gt      N2, 0.000001, .$FPEQNOK

        restore N2
        restore N1
        restore N0
        branch  .L
.local $FPEQNOK:
        restore N2
        restore N1
        restore N0
.endm
.macro fp_ne(J,K,L)
        save    N0
        save    N1
        save    N2

        set     N0, .J
        set     N1, .K
        sub     N2, N1,N0
        abs     N2, N2
        lt      N2, 0.000001, .$FPNENOK

        restore N2
        restore N1
        restore N0
        branch  .L
.local $FPNENOK:
        restore N2
        restore N1
        restore N0
.endm
ENDOFMACRO

###############     Tests   ##################

# Test proper stack chunk handling
pasm_output_is( <<CODE, <<'OUTPUT', 'save_i & restore_i' );
        set     I3, 1

testloop:
        set     I0, 0
        set     I1, I3

saveloop:
        inc     I0
        save    I0
        ne      I0, I1, saveloop

restoreloop:
        restore I0
        ne      I0, I1, error
        dec     I1
        ne      I1, 0, restoreloop

        add     I3, I3, 1
        ne      I3, 769, testloop       # At least 3 stack chunks

        print   "OK\\n"
error:  end
CODE
OK
OUTPUT

# Rotate
pasm_output_is( <<"CODE", <<'OUTPUT', 'rotate 0' );
    set I0, 1
    save I0
    set I0, 2
    save I0
    rotate_up 0
    restore I0
    print I0
    print "\\n"
    end
CODE
2
OUTPUT

pasm_output_is( <<"CODE", <<'OUTPUT', 'rotate 1' );
    set I0, 1
    save I0
    set I0, 2
    save I0
    rotate_up 1
    restore I0
    print I0
    print "\\n"
    end
CODE
2
OUTPUT

pasm_output_is( <<"CODE", <<'OUTPUT', 'rotate 2' );
    set I0, 1
    save I0
    set I0, 2
    save I0
    rotate_up 2
    restore I0
    print I0
    print "\\n"
    end
CODE
1
OUTPUT

pasm_output_is( <<"CODE", <<'OUTPUT', 'rotate 3' );
    set I0, 1
    save I0
    set I0, 2
    save I0
    set I0, 3
    save I0
    rotate_up 3
    restore I0
    print I0
    restore I0
    print I0
    restore I0
    print I0
    print "\\n"
    end
CODE
213
OUTPUT

pasm_output_is( <<"CODE", <<'OUTPUT', 'rotate -1' );
    set I0, 1
    save I0
    set I0, 2
    save I0
    set I0, 3
    save I0
    rotate_up -1
    restore I0
    print I0
    restore I0
    print I0
    restore I0
    print I0
    print "\\n"
    end
CODE
321
OUTPUT

pasm_output_is( <<"CODE", <<'OUTPUT', 'rotate -2' );
    set I0, 1
    save I0
    set I0, 2
    save I0
    set I0, 3
    save I0
    rotate_up -2
    restore I0
    print I0
    restore I0
    print I0
    restore I0
    print I0
    print "\\n"
    end
CODE
231
OUTPUT

pasm_output_is( <<"CODE", <<'OUTPUT', 'rotate -3' );
    set I0, 1
    save I0
    set I0, 2
    save I0
    set I0, 3
    save I0
    rotate_up -3
    restore I0
    print I0
    restore I0
    print I0
    restore I0
    print I0
    print "\\n"
    end
CODE
132
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', 'rotate with a full stack chunk' );
      set I0, 0
FOO:  save I0
      inc I0
      lt I0, 256, FOO

      rotate_up 2

      restore I1
      print I1
      print "\n"
      end
CODE
254
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', 'rotate across stack chunk boundary' );
      set I0, 0
FOO:  save I0
      inc I0
      lt I0, 257, FOO

      rotate_up 2

      restore I1
      print I1
      print "\n"
      end
CODE
255
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', 'rotate by stack chunk size' );
      set I0, 0
FOO:  save I0
      inc I0
      lt I0, 300, FOO

      rotate_up -256

      restore I1
      print I1
      print "\n"
      end
CODE
44
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', 'rotate by more than stack chunk size' );
      set I0, 0
FOO:  save I0
      inc I0
      lt I0, 300, FOO

      rotate_up -257

      restore I1
      print I1
      print "\n"
      end
CODE
43
OUTPUT

pasm_error_output_is( <<"CODE", <<'OUTPUT', 'rotate up by more than stack size');
    set I0, 1
    save I0
    set I0, 2
    save I0
    rotate_up 3
    end
CODE
Stack too shallow!
OUTPUT

pasm_error_output_is( <<"CODE", <<'OUTPUT', 'rotate down by more than stack size');
    set I0, 1
    save I0
    set I0, 2
    save I0
    rotate_up -3
    end
CODE
Stack too shallow!
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', 'save/savec for strings' );
      set S0, "Foobar"
      savec S0
      chopn S0, 3
      print S0
      print "\n"
      restore S2
      print S2
      print "\n"

      set S1, "Foobar"
      save  S1
      chopn S1, 3
      print S1
      print "\n"
      restore S3
      print S3
      print "\n"
      end
CODE
Foo
Foobar
Foo
Foo
OUTPUT

pasm_output_is( <<CODE, <<OUTPUT, "save, restore" );
@{[ $fp_equality_macro ]}
        set     I0, 1
        save    I0
        set     I0, 2
        print   I0
        print   "\\n"
        restore I0
        print   I0
        print   "\\n"

        set     N0, 1.0
        save    N0
        set     N0, 2.0
        .fp_eq  (N0, 2.0, EQ1)
        print   "not "
EQ1:    print   "equal to 2.0\\n"
        restore N0
        .fp_eq  (N0, 1.0, EQ2)
        print   "not "
EQ2:    print   "equal to 1.0\\n"

        set     S0, "HONK\\n"
        save    S0
        set     S0, "HONK HONK\\n"
        print   S0
        restore S0
        print   S0

        save    123
        restore I0
        print   I0
        print   "\\n"

        save    3.14159
        restore N0
        .fp_eq  (N0, 3.14159, EQ3)
        print   "<kansas> not "
EQ3:    print   "equal to PI\\n"

        save    "All the world's people\\n"
        restore S0
        print   S0

        new     P0, .String
        set     P0, "never to escape\\n"
        save    P0
        new     P0, .String
        set     P0, "find themselves caught in a loop\\n"
        print   P0
        restore P0
        print   P0

        end
CODE
2
1
equal to 2.0
equal to 1.0
HONK HONK
HONK
123
equal to PI
All the world's people
find themselves caught in a loop
never to escape
OUTPUT

pasm_output_is( <<CODE, <<OUTPUT, "entrytype" );
        set     I0, 12
        set     N0, 0.1
        set     S0, "Difference Engine #2"
        new     P0, .String
        set     P0, "Shalmaneser"

        save    P0
        save    S0
        save    "Wintermute"
        save    N0
        save    1.23
        save    I0
        save    12

        print   "starting\\n"

        set     I1, 0
LOOP:   entrytype       I0, I1
        print   I0
        print   "\\n"
        inc     I1
        lt      I1, 7, LOOP

        print   "done\\n"
        end
CODE
starting
1
1
2
2
3
3
4
done
OUTPUT

pasm_error_output_is( <<CODE, <<OUTPUT, "entrytype, beyond stack depth" );
        save    12
        print   "ready\\n"
        entrytype       I0, 1
        print   "done\\n"
        end
CODE
ready
Stack Depth wrong
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "depth op" );
        depth I0
        print I0
        print "\n"

        save "Foo"
        depth I0
        print I0
        print "\n"
        restore S0

        set I1, 0
LOOP:   save I1
        inc I1
        lt I1, 1024, LOOP
        depth I0
        print I0
        print "\n"

        end
CODE
0
1
1024
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "saveall/restoreall" );
        set S0,"test ok"
        set N0,4.3
        set I0,6
        saveall
        set S0,"test not ok"
        set N0,4.1
        set I0,8
        restoreall
        print I0
        print "\n"
        print N0
        print "\n"
        print S0
        print "\n"
        end
CODE
6
4.300000
test ok
OUTPUT

pasm_output_is( <<CODE, <<'OUTPUT', "lookback" );
@{[ $fp_equality_macro ]}
        save 1
        save 1.0
        save "Foo"

        new P12, .Hash
        set P12["Apple"], "Banana"
        save P12

        lookback P0, 0
        lookback S0, 1
        lookback N0, 2
        lookback I0, 3

        set S2, P0["Apple"]
        eq S2, "Banana", OK1
        print "not "
OK1:    print "ok 1\\n"

        eq I0, 1, OK2
        print "not "
OK2:    print "ok 2\\n"

        .fp_eq (N0, 1.0, OK3)
        print "not "
OK3:    print "ok 3\\n"

        eq S0, "Foo", OK4
        print "not "
OK4:    print "ok 4\\n"

        lookback I1, -1
        lookback N1, -2
        lookback S1, -3
        lookback P1, -4

        eq I0, 1, OK5
        print "not "
OK5:    print "ok 5\\n"

        .fp_eq (N0, 1.0, OK6)
        print "not "
OK6:    print "ok 6\\n"

        eq S0, "Foo", OK7
        print "not "
OK7:    print "ok 7\\n"

        set S3, P1["Apple"]
        eq S3, "Banana", OK8
        print "not "
OK8:    print "ok 8\\n"

        end
CODE
ok 1
ok 2
ok 3
ok 4
ok 5
ok 6
ok 7
ok 8
OUTPUT

SKIP: {
    skip( "no stack limit currently", 3 );
    pasm_output_is( <<CODE, <<'OUTPUT', "check limit - User" );
lp:
        save I0
        branch lp
        end
CODE
Stack 'User' too deep
OUTPUT

    pasm_output_is( <<CODE, <<'OUTPUT', "check limit - Pad" );
lp:
        new_pad 0
        branch lp
        end
CODE
Stack 'Pad' too deep
OUTPUT

    pasm_output_is( <<CODE, <<'OUTPUT', "check limit - Control" );
lp:
        bsr lp
        end
CODE
Stack 'Control' too deep
OUTPUT
}
##############################

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
