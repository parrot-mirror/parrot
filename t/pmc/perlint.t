#! perl -w
# Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
# $Id$

=head1 NAME

t/pmc/perlint.t - Perl Integers

=head1 SYNOPSIS

	% perl -Ilib t/pmc/perlint.t

=head1 DESCRIPTION

Tests the PerlInt PMC. Checks Perl-specific integer behaviour.

=cut

use Parrot::Test tests => 30;
use Parrot::PMC '%pmc_types';
my $perlint = $pmc_types{'PerlInt'};
my $ok = '"ok 1\n"';
my $fp_equality_macro = <<'ENDOFMACRO';
.macro fp_eq (	J, K, L )
	save	N0
	save	N1
	save	N2

	set	N0, .J
	set	N1, .K
	sub	N2, N1,N0
	abs	N2, N2
	gt	N2, 0.000001, .$FPEQNOK

	restore N2
	restore	N1
	restore	N0
	branch	.L
.local $FPEQNOK:
	restore N2
	restore	N1
	restore	N0
.endm
.macro fp_ne(	J,K,L)
	save	N0
	save	N1
	save	N2

	set	N0, .J
	set	N1, .K
	sub	N2, N1,N0
	abs	N2, N2
	lt	N2, 0.000001, .$FPNENOK

	restore	N2
	restore	N1
	restore	N0
	branch	.L
.local $FPNENOK:
	restore	N2
	restore	N1
	restore	N0
.endm
ENDOFMACRO

warn "failed to get type of PerlInt!" unless defined $perlint;

output_is(<<"CODE", <<'OUTPUT', ".PerlInt == $perlint");
# type
    set I0, .PerlInt
    eq I0,$perlint,ok_1
    print "value of .PerlInt is "
    print I0
    print " and not $perlint\\nnot "
ok_1:
    print $ok
    end
CODE
ok 1
OUTPUT

output_is(<<"CODE", <<'OUTPUT', "type");
    new P0,.PerlInt
# type
    typeof I0,P0
    eq I0,$perlint,ok_1
    print "not "
ok_1:
    print $ok
    end
CODE
ok 1
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "inheritance");
    new P0,.PerlInt
# clone
    set P0, 10
    clone P1, P0
    set P1, 20
    set I0, P0
    eq I0,10,ok_1
    print "not "
ok_1:
    print "ok 1\n"
    set I0, P1
    eq I0,20,ok_2
    print "not "
ok_2:
    print "ok 2\n"
    end
CODE
ok 1
ok 2
OUTPUT


output_is(<<'CODE', <<'OUTPUT', "bor");
    new P0, .PerlInt
    set P0, 0b11110000
    bor P0, 0b00001111
    print P0
    print "\n"

    new P1, .PerlInt
    set P0, 0
    set P1, 12
    bor P0, P1
    print P0
    print "\n"

    new P1, .PerlNum
    set P1, 47.11
    set P0, 7
    bor P1, P0, 8
    print P1
    print "\n"

    new P2, .PerlString
    set P2, "String"
    set P0, 128
    set P1, 1
    bor P2, P0, P1
    print P2
    print "\n"

    new P4, .PerlUndef
    set P0, 12
    set P1, 24
    bor P4, P0, P1
    print P4
    print "\n"
    end
CODE
255
12
15
129
28
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "bxor");
    new P0, .PerlInt
    set P0, 0b11111000
    bxor P0, 0b00011111
    print P0
    print "\n"

    new P1, .PerlInt
    set P0, 16
    set P1, 31
    bxor P0, P1
    print P0
    print "\n"

    new P1, .PerlNum
    set P1, 47.11
    set P0, 7
    bxor P1, P0, 7
    print P1
    print "\n"

    new P2, .PerlString
    set P2, "String"
    set P0, 127
    set P1, 1
    bxor P2, P0, P1
    print P2
    print "\n"

    new P4, .PerlUndef
    set P0, 200
    set P1, 100
    bxor P4, P0, P1
    print P4
    print "\n"
    end
CODE
231
15
0
126
172
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "band");
    new P0, .PerlInt
    set P0, 0b10101010
    band P0, 0b10011001
    print P0
    print "\n"

    new P1, .PerlInt
    new P2, .PerlInt
    set P1, 255
    set P2, 29
    band P1, P2
    print P1
    print "\n"

    new P3, .PerlNum
    set P3, 3.14
    set P1, 0b00001111
    set P2, 0b00001100
    band P3, P1, P2
    print P3
    print "\n"

    new P3, .PerlString
    set P3, "Foo"
    band P3, P1, 0b00001100
    print P3
    print "\n"

    new P3, .PerlUndef
    set P1, 100
    set P2, 100
    band P3, P1, P2
    print P3
    print "\n"
    end
CODE
136
29
12
12
100
OUTPUT




output_is(<<'CODE', <<'OUTPUT', "bnot");
    new P0, .PerlInt
    set P0, 0b10101010

# We use band in these tests to null out the high bits, and make the
# tests independent of the size of our INTVALs
    bnot P0, P0
    band P0, 0b01010101
    print P0
    print "\n"

    new P1, .PerlInt
    set P0, 0b01100110
    bnot P1, P0
    band P1, 0b10011001
    print P1
    print "\n"

    new P1, .PerlNum
    set P0, 0b00001111
    bnot P1, P0
    band P1, 0b11110000
    print P1
    print "\n"

    new P1, .PerlString
    set P0, 0b00110011
    bnot P1, P0
    band P1, 0b11001100
    print P1
    print "\n"

    new P1, .PerlUndef
    set P0, 0b00000000
    bnot P1, P0
    band P1, 0b11111111
    print P1
    print "\n"

    end
CODE
85
153
240
204
255
OUTPUT

# shl/shr tests adapted from t/op/bitwise.t

output_is(<<'CODE', <<'OUTPUT', "shr (>>)");
    new P0, .PerlInt
    new P1, .PerlInt
    new P2, .PerlInt
    new P3, .PerlInt
    set P0, 0b001100
    set P1, 0b010100
    set P2, 1
    set P3, 2

    new P4, .PerlInt
    new P5, .PerlNum
    new P6, .PerlString
    new P7, .PerlUndef

    shr P4, P0, P2
    shr P5, P0, P3
    shr P6, P1, P2
    shr P7, P1, 2

    print P4
    print "\n"
    print P5
    print "\n"
    print P6
    print "\n"
    print P7
    print "\n"

    set P0, 0b001100
    set P1, 0b010100
    shr P0, P2
    shr P1, 2
    print P0
    print "\n"
    print P1
    print "\n"
    end
CODE
6
3
10
5
6
5
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "shl (<<)");
    new P0, .PerlInt
    new P1, .PerlInt
    new P2, .PerlInt
    new P3, .PerlInt
    set P0, 0b001100
    set P1, 0b010100
    set P2, 1
    set P3, 2

    new P4, .PerlInt
    new P5, .PerlNum
    new P6, .PerlString
    new P7, .PerlUndef

    shl P4, P0, P2
    shl P5, P0, P3
    shl P6, P1, P2
    shl P7, P1, 2

    print P4
    print "\n"
    print P5
    print "\n"
    print P6
    print "\n"
    print P7
    print "\n"

    set P0, 0b001100
    set P1, 0b010100
    shl P0, P2
    shl P1, 2
    print P0
    print "\n"
    print P1
    print "\n"
    end
CODE
24
48
40
80
24
80
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "inc/dec a PerlUndef");
    new P0, .PerlUndef
    new P1, .PerlUndef
    inc P0
    print P0
    inc P0
    print P0
    dec P1
    print P1
    dec P1
    print P1
    print "\n"
    end
CODE
12-1-2
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "divide gives int if possible");
    new P0, .PerlInt
    new P1, .PerlInt
    new P2, .PerlUndef
    set P0, 12
    set P1, 2
    div P2, P0, P1
    print P2
    print "\n"
    div P2, P1
    print P2
    print "\n"
    div P2, 2
    print P2
    print "\n"
    end
CODE
6
3
1.500000
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "division by zero, #1");
    new P0, .PerlInt
    new P1, .PerlInt
    new P2, .PerlUndef
    set P0, 12
    set P1, 0
    div P2, P0, P1
    end
CODE
division by zero!
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "division by zero, #2");
    new P0, .PerlInt
    new P1, .PerlUndef
    new P2, .PerlUndef
    set P0, 12
    div P2, P0, P1
    end
CODE
division by zero!
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "division by zero, #3");
    new P0, .PerlInt
    new P1, .PerlNum
    new P2, .PerlUndef
    set P0, 12
    set P1, 0.0
    div P2, P0, P1
    end
CODE
division by zero!
OUTPUT

output_is(<<'CODE', <<OUTPUT, "subtract native integer from PerlInt");
	new P0, .PerlInt
	new P1, .PerlInt
	set I0, 4000
	set P0, 123
	sub P1, P0, I0
	print P1
	print "\n"
	sub P0, P0, I0
	print P0
	print "\n"
        sub P0, -3876
	print P0
	print "\n"
	end
CODE
-3877
-3877
-1
OUTPUT

output_is(<<'CODE', <<OUTPUT, "multiply PerlInt with native integer");
	new P0, .PerlInt
	new P1, .PerlInt
	set I0, 4000
	set P0, 123
	mul P1, P0, I0
	print P1
	print "\n"
	mul P0, P0, I0
	print P0
	print "\n"
        mul P0, -1
	print P0
	print "\n"
        mul P0, 0
	print P0
	print "\n"
	end
CODE
492000
492000
-492000
0
OUTPUT

output_is(<<"CODE", <<OUTPUT, "divide PerlInt by native integer");
@{[ $fp_equality_macro ]}
	new P0, .PerlInt
	set I0, 4000
	set P0, 123
	div P0, P0, I0
	.fp_eq( P0, 0.03075, EQ1)
	print P0
	print "not "
EQ1:	print "ok 1"
	print "\\n"

        div P0, 5
        .fp_eq(P0, 0.00615, EQ2)
	print P0
	print "not "
EQ2:	print "ok 2"
	print "\\n"
	end
CODE
ok 1
ok 2
OUTPUT

#
# PerlInt and FLOATVAL, tests
#
output_is(<<"CODE", <<OUTPUT, "add native number to integer");
@{[ $fp_equality_macro ]}
	new P0, .PerlInt
	new P1, .PerlInt
	set N0, 4000.04
	set P0, 123
	add P1, P0, N0
	.fp_eq( P1, 4123.04, EQ1)
	print "not "
EQ1:	print "ok 1\\n"
	add P0, P0, N0
	.fp_eq( P0, 4123.04, EQ2)
        print "not "
EQ2:	print "ok 2\\n"
        new P0, .PerlInt
        set P0, 12
        add P0, 0.16
	.fp_eq( P0, 12.16, EQ3)
        print "not "
EQ3:	print "ok 3\\n"
	end
CODE
ok 1
ok 2
ok 3
OUTPUT

output_is(<<"CODE", <<OUTPUT, "subtract native number from integer");
@{[ $fp_equality_macro ]}
	new P0, .PerlInt
	new P1, .PerlInt
	set N0, 4000.04
	set P0, 123
	sub P1, P0, N0
	.fp_eq( P1, -3877.04, EQ1)
	print "not "
EQ1:	print "ok 1\\n"
	sub P0, P0, N0
	.fp_eq( P0, -3877.04, EQ2)
	print "not "
EQ2:	print "ok 2\\n"
        new P0, .PerlInt
        set P0, -3877
        sub P0, 23.01
	.fp_eq( P0, -3900.01, EQ3)
	print "not "
EQ3:	print "ok 3\\n"
	end
CODE
ok 1
ok 2
ok 3
OUTPUT

output_is(<<'CODE', <<OUTPUT, "multiply integer with native number");
	new P0, .PerlInt
	new P1, .PerlInt
	set N0, 4000.04
	set P0, 123
	mul P1, P0, N0
	print P1
	print "\n"
	mul P0, P0, N0
	print P0
	print "\n"

        new P0, .PerlInt
        set P0, 12
        mul P0, 25.5
	print P0
	print "\n"
	end
CODE
492004.920000
492004.920000
306
OUTPUT

output_is(<<"CODE", <<OUTPUT, "divide integer by native number");
@{[ $fp_equality_macro ]}
	new P0, .PerlInt
	set N0, 4000
	set P0, 123
	div P0, P0, N0

	.fp_eq( P0, 0.03074969250307496925, EQ1)
	print P0
	print "not "
EQ1:	print "ok 1"
	print "\\n"

        new P0, .PerlInt
        set P0, 250
        div P0, 0.01
	.fp_eq( P0, 25000.0, EQ2)
        print P0
	print "not "
EQ2:	print "ok 2"
	print "\\n"
	end
CODE
ok 1
ok 2
OUTPUT

#
# PerlInt and INTVAL tests
#
output_is(<<'CODE', <<OUTPUT, "add native integer to PerlInt");
	new P0, .PerlInt
	new P1, .PerlInt
	set I0, 4000
	set P0, 123
	add P1, P0, I0
	print P1
	print "\n"
	add P0, P0, I0
	print P0
	print "\n"
        add P0, 20
	print P0
	print "\n"
	end
CODE
4123
4123
4143
OUTPUT

output_is(<<'CODE', <<OUTPUT, "logical or");
        new P0, .PerlInt
        new P1, .PerlInt
        new P2, .PerlInt
        set P0, 10
        set P1, 20
        or P2, P1, P0
        eq P2, 20, OK1
        print P2
        print "not "
OK1:    print "ok 1\n"
        set P1, 0
        or P2, P1, P0
        eq P2, 10, OK2
        print P2
        print "not "
OK2:    print "ok 2\n"
        end
CODE
ok 1
ok 2
OUTPUT

output_is(<<"CODE", <<OUTPUT, "logical or with Num/Str/Undef");
@{[ $fp_equality_macro ]}
        new P0, .PerlNum
        new P1, .PerlInt
        new P2, .PerlInt
        set P0, 10.5
        set P1, 20
        or P2, P1, P0
        eq P2, 20, OK1
        print P2
        print "not "
OK1:    print "ok 1\\n"
        set P1, 0
        or P2, P1, P0
        .fp_eq(P2, 10.5, OK2)
        print P2
        print "not "
OK2:    print "ok 2\\n"

        new P0, .PerlString
        set P0, "ND3"
        set P1, 30
        or P2, P1, P0
        eq P2, 30, OK3
        print P2
        print "not "
OK3:    print "ok 3\\n"
        set P1, 0
        or P2, P1, P0
        set S2, P2
        eq S2, "ND3", OK4
        print P2
        print "not "
OK4:    print "ok 4\\n"

        new P0, .PerlUndef
        set P1, 40
        or P2, P1, P0
        eq P2, 40, OK5
        print P2
        print "not "
OK5:    print "ok 5\\n"
        set P1, 0
        or P2, P1, P0
        defined I2, P2
        eq I2, 0, OK6
        print P2
        print "not "
OK6:    print "ok 6\\n"
        end
CODE
ok 1
ok 2
ok 3
ok 4
ok 5
ok 6
OUTPUT

output_is(<<'CODE', <<OUTPUT, "logical xor");
        new P0, .PerlInt
        new P1, .PerlInt
        new P2, .PerlInt
        set P0, 0
        set P1, 20
        xor P2, P1, P0
        eq P2, 20, OK1
        print P2
        print "not "
OK1:    print "ok 1\n"
        set P0, 10
        set P1, 0
        xor P2, P1, P0
        eq P2, 10, OK2
        print P2
        print "not "
OK2:    print "ok 2\n"
        set P0, 0
        set P1, 0
        xor P2, P1, P0
        unless P2, OK3
        print P2
        print "not "
OK3:    print "ok 3\n"
        set P0, 1
        set P1, 1
        xor P2, P1, P0
        unless P2, OK4
        print P2
        print "not "
OK4:    print "ok 4\n"
        end
CODE
ok 1
ok 2
ok 3
ok 4
OUTPUT

output_is(<<"CODE", <<OUTPUT, "logical xor with Num/Str/Undef");
@{[ $fp_equality_macro ]}
        new P0, .PerlNum
        new P1, .PerlInt
        new P2, .PerlInt
        set P0, 0.0
        set P1, 20
        xor P2, P1, P0
        eq P2, 20, OK1
        print P2
        print "not "
OK1:    print "ok 1\\n"
        set P0, 12.5
        set P1, 0
        xor P2, P1, P0
        .fp_eq(P2, 12.5, OK2)
        print P2
        print "not "
OK2:    print "ok 2\\n"
        set P0, 0.0
        set P1, 0
        xor P2, P1, P0
        unless P2, OK3
        print P2
        print "not "
OK3:    print "ok 3\\n"
        set P0, 10.0
        set P1, 10
        xor P2, P1, P0
        unless P2, OK4
        print P2
        print "not "
OK4:    print "ok 4\\n"

        new P0, .PerlString
        set P0, ""
        set P1, 20
        xor P2, P1, P0
        eq P2, 20, OK5
        print P2
        print "not "
OK5:    print "ok 5\\n"
        set P0, "non-zero"
        set P1, 0
        xor P2, P1, P0
        set S2, P2
        eq S2, "non-zero", OK6
        print P2
        print "not "
OK6:    print "ok 6\\n"
        set P0, ""
        set P1, 0
        xor P2, P1, P0
        unless P2, OK7
        print P2
        print "not "
OK7:    print "ok 7\\n"
        set P0, "non-zero"
        set P1, 10
        xor P2, P1, P0
        unless P2, OK8
        print P2
        print "not "
OK8:    print "ok 8\\n"

        new P0, .PerlUndef
        set P1, 20
        xor P2, P1, P0
        eq P2, 20, OK9
        print P2
        print "not "
OK9:    print "ok 9\\n"
        set P1, 0
        xor P2, P1, P0
        eq P2, 0, OK10
        print P2
        print "not "
OK10:   print "ok 10\\n"
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
ok 9
ok 10
OUTPUT

output_is(<<'CODE', <<OUTPUT, "logical and");
        new P0, .PerlInt
        new P1, .PerlInt
        new P2, .PerlInt
        set P0, 10
        set P1, 20
        and P2, P1, P0
        eq P2, 10, OK1
        print P2
        print "not "
OK1:    print "ok 1\n"
        set P1, 0
        and P2, P1, P0
        eq P2, 0, OK2
        print P2
        print "not "
OK2:    print "ok 2\n"
        end
CODE
ok 1
ok 2
OUTPUT

output_is(<<"CODE", <<OUTPUT, "logical and with Num/Str/Undef");
@{[ $fp_equality_macro ]}
        new P0, .PerlNum
        new P1, .PerlInt
        new P2, .PerlInt
        set P0, 10.0
        set P1, 20
        and P2, P1, P0
        .fp_eq(P2, 10.0, OK1)
        print P2
        print "not "
OK1:    print "ok 1\\n"
        set P1, 0
        and P2, P1, P0
        eq P2, 0, OK2
        print P2
        print "not "
OK2:    print "ok 2\\n"

        new P0, .PerlString
        set P0, "kjuh"
        set P1, 20
        and P2, P1, P0
        set S2, P2
        eq S2, "kjuh", OK3
        print P2
        print "not "
OK3:    print "ok 3\\n"
        set P1, 0
        and P2, P1, P0
        eq P2, 0, OK4
        print P2
        print "not "
OK4:    print "ok 4\\n"

        new P0, .PerlUndef
        set P1, 20
        and P2, P1, P0
        defined I2, P2
        eq I2, 0, OK5
        print P2
        print "not "
OK5:    print "ok 5\\n"
        set P1, 0
        and P2, P1, P0
        defined I2, P2
        ne I2, 1, BAD6
        set I3, P2
        ne I3, 0, BAD6
        branch OK6
BAD6:   print P2
        print "not "
OK6:    print "ok 6\\n"
        end
CODE
ok 1
ok 2
ok 3
ok 4
ok 5
ok 6
OUTPUT

output_is(<< 'CODE', << 'OUTPUT', "check whether interface is done");
##PIR##
.sub _main
    .local pmc pmc1
    pmc1 = new PerlInt
    .local int bool1
    does bool1, pmc1, "scalar"
    print bool1
    print "\n"
    does bool1, pmc1, "no_interface"
    print bool1
    print "\n"
    end
.end
CODE
1
0
OUTPUT

output_is(<< 'CODE', << 'OUTPUT', "Fix for a minor problem");
##PIR##
.sub main @MAIN
    $P1 = new PerlInt
    $P1 = 5
    $P2 = new PerlNum
    $P2 = 0.2
    $P3 = new PerlNum
    $P3 = $P1 / $P2
    print $P3
    print "\n"
.end
CODE
25
OUTPUT
