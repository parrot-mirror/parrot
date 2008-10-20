#! perl
# Copyright (C) 2001-2008, The Perl Foundation.
# $Id$

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );

use Test::More;
use File::Temp 'tempfile';

use Parrot::Test tests => 65;
use Parrot::Config;

=head1 NAME

t/pmc/sub.t - Subroutine PMCs

=head1 SYNOPSIS

    % prove t/pmc/sub.t

=head1 DESCRIPTION

Tests the creation and invocation of C<Sub>, C<Closure> and
C<Continuation> PMCs.

=cut

pasm_output_is( <<'CODE', <<'OUTPUT', "PASM subs - invokecc" );
    .const .Sub P0 = "func"

    set I5, 3
    set_args "0", I5
    invokecc P0
    print I5
    print "\n"
    end

.pcc_sub func:
    get_params "0", I5
    print I5
    print "\n"

    eq I5, 0, endfunc
    dec I5

.include "interpinfo.pasm"
    interpinfo P0, .INTERPINFO_CURRENT_SUB
    set_args "0", I5
    invokecc P0  # recursive invoke

endfunc:
    returncc
CODE
3
2
1
0
3
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "Continuation" );
    new P5, 'Integer'
    set P5, 3
    set_global "foo", P5
    new P1, 'Continuation'
    set_addr P1, endcont
endcont:
    get_global P4, "foo"
    print "here "
    print P4
    print "\n"
    unless P4, done
    dec P4
    set_global "foo", P4
    print "going to cont\n"
    clone P0, P1
    invokecc P0
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

pasm_output_is( <<'CODE', <<'OUTPUT', "definedness of Continuation" );
    new P1, 'Continuation'
    defined I1, P1
    print I1
    print "\n"
    set_addr P1, cont
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

pasm_output_is( <<'CODE', <<'OUTPUT', "pcc sub" );
    get_global P0, "_the_sub"
    defined I0, P0
    if I0, ok
    print "not "
ok:
    print "ok 1\n"
    invokecc P0
    say "back"
    end
.pcc_sub _the_sub:
    print "in sub\n"
    returncc
CODE
ok 1
in sub
back
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "pcc sub, tail call" );
    get_global P0, "_the_sub"
    defined I0, P0
    if I0, ok
    print "not "
ok:
    print "ok 1\n"
    invokecc P0
    say "back"
    end

.pcc_sub _the_sub:
    print "in sub\n"
    get_global P0, "_next_sub"
    get_addr I0, P0
    jump I0
    print "never here\n"

.pcc_sub _next_sub:
    print "in next sub\n"
    returncc
    print "never here\n"
    end
CODE
ok 1
in sub
in next sub
back
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "pcc sub perl::syn::tax" );
    get_global P0, "_the::sub::some::where"
    defined I0, P0
    if I0, ok
    print "not "
ok:
    print "ok 1\n"
    invokecc P0
    say "back"
    end
.pcc_sub _the::sub::some::where:
    print "in sub\n"
    returncc
CODE
ok 1
in sub
back
OUTPUT

my ($TEMP, $temp_pasm) = tempfile( SUFFIX => '.pasm', UNLINK => 1 );
print $TEMP <<'EOF';
  .pcc_sub _sub1:
  say "in sub1"
  end
EOF
close $TEMP;

pasm_output_is( <<"CODE", <<'OUTPUT', "load_bytecode call sub" );
.pcc_sub _main:
    say "main"
    load_bytecode "$temp_pasm"
    say "loaded"
    get_global P0, "_sub1"
    defined I0, P0
    if I0, ok1
    print "not "
ok1:
    say "found sub"
    invokecc P0
    say "never"
    end
CODE
main
loaded
found sub
in sub1
OUTPUT

($TEMP, $temp_pasm) = tempfile( SUFFIX => '.pasm', UNLINK => 1 );

print $TEMP <<'EOF';
  .pcc_sub _sub1:
  say "in sub1"
  returncc
EOF
close $TEMP;

pasm_output_is( <<"CODE", <<'OUTPUT', "load_bytecode call sub, ret" );
.pcc_sub _main:
    say "main"
    load_bytecode "$temp_pasm"
    say "loaded"
    get_global P0, "_sub1"
    defined I0, P0
    if I0, ok1
    print "not "
ok1:
    say "found sub"
    invokecc P0
    say "back"
    end
CODE
main
loaded
found sub
in sub1
back
OUTPUT

($TEMP, $temp_pasm) = tempfile( SUFFIX => '.pasm', UNLINK => 1 );

print $TEMP <<'EOF';
  .pcc_sub _sub1:
  say "in sub1"
  returncc
  .pcc_sub _sub2:
  say "in sub2"
  returncc
EOF
close $TEMP;

pasm_output_is( <<"CODE", <<'OUTPUT', "load_bytecode call different subs, ret" );
.pcc_sub _main:
    say "main"
    load_bytecode "$temp_pasm"
    say "loaded"
    get_global P0, "_sub1"
    defined I0, P0
    if I0, ok1
    print "not "
ok1:
    say "found sub1"
    set P10, P0
    invokecc P0
    say "back"
    get_global P0, "_sub2"
    defined I0, P0
    if I0, ok2
    print "not "
ok2:
    say "found sub2"
    invokecc P0
    say "back"
    set P0, P10
    invokecc P0
    say "back"
    end
CODE
main
loaded
found sub1
in sub1
back
found sub2
in sub2
back
in sub1
back
OUTPUT

my (undef, $temp_pbc)  = tempfile( SUFFIX => '.pbc', UNLINK => 1 );

system(".$PConfig{slash}parrot$PConfig{exe}", '-o', $temp_pbc, $temp_pasm);

pir_output_is( <<"CODE", <<'OUTPUT', "load_bytecode Sx" );
.sub main :main
    \$S0 = '$temp_pasm'
    load_bytecode \$S0
    _sub1()
    \$S0 = '$temp_pbc'
    load_bytecode \$S0
    _sub2()
.end
CODE
in sub1
in sub2
OUTPUT

pasm_output_is( <<"CODE", <<'OUTPUT', "load_bytecode PBC call different subs, ret" );
.pcc_sub _main:
    say "main"
    load_bytecode "$temp_pasm"
    say "loaded"
    get_global P0, "_sub1"
    defined I0, P0
    if I0, ok1
    print "not "
ok1:
    say "found sub1"
    set P10, P0
    invokecc P0
    say "back"
    get_global P0, "_sub2"
    defined I0, P0
    if I0, ok2
    print "not "
ok2:
    say "found sub2"
    invokecc P0
    say "back"
    set P0, P10
    invokecc P0
    say "back"
    end
CODE
main
loaded
found sub1
in sub1
back
found sub2
in sub2
back
in sub1
back
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "equality of closures" );
.pcc_sub main:
      .const .Sub P3 = "f1"
      newclosure P0, P3
      clone P1, P0
      eq P0, P1, OK1
      print "not "
OK1:  print "ok 1\n"

      .const .Sub P4 = "f2"
      newclosure P2, P4
      eq P0, P2, BAD2
      branch OK2
BAD2: print "not "
OK2:  print "ok 2\n"
      end

.pcc_sub :outer(main) f1:
      print "Test\n"
      end

.pcc_sub :outer(main) f2:
      new P1, 'Undef'
      end
CODE
ok 1
ok 2
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "equality of subs" );
      .const .Sub P0 = "f1"
      clone P1, P0
      eq P0, P1, OK1
      print "not "
OK1:  print "ok 1\n"

      .const .Sub P2 = "f2"
      clone P1, P0
      eq P0, P2, BAD2
      branch OK2
BAD2: print "not "
OK2:  print "ok 2\n"
      end

.pcc_sub f1:
      print "Test\n"
      end

.pcc_sub f2:
      new P1, 'Undef'
      end
CODE
ok 1
ok 2
OUTPUT

pasm_output_is( <<'CODE', <<'OUT', "MAIN pragma, syntax only" );
.pcc_sub :main _main:
    print "ok\n"
    end
CODE
ok
OUT

($TEMP, $temp_pasm) = tempfile( SUFFIX => '.pasm', UNLINK => 1 );

print $TEMP <<'EOF';
  .pcc_sub :load _sub1:
  say "in sub1"
  returncc
EOF
close $TEMP;

pasm_output_is( <<"CODE", <<'OUTPUT', 'load_bytecode :load' );
.pcc_sub _main:
    say "main"
    load_bytecode "$temp_pasm"
    say "back"
    end
CODE
main
in sub1
back
OUTPUT

($TEMP, $temp_pasm) = tempfile( SUFFIX => '.pasm', UNLINK => 1 );

print $TEMP <<'EOF';
  .pcc_sub _error:
  say "error"
  .pcc_sub :load _sub1:
  say "in sub1"
  returncc
EOF
close $TEMP;

pasm_output_is( <<"CODE", <<'OUTPUT', 'load_bytecode :load second sub' );
.pcc_sub _main:
    say "main"
    load_bytecode "$temp_pasm"
    say "back"
    end
CODE
main
in sub1
back
OUTPUT

system(".$PConfig{slash}parrot$PConfig{exe}", '-o', $temp_pbc, $temp_pasm );

pasm_output_is( <<"CODE", <<'OUTPUT', 'load_bytecode :load in pbc' );
.pcc_sub _main:
    say "main"
    load_bytecode "$temp_pbc"
    say "back"
    end
CODE
main
in sub1
back
OUTPUT

($TEMP, $temp_pasm) = tempfile( SUFFIX => '.pasm', UNLINK => 1 );

print $TEMP <<'EOF';
  .pcc_sub :load _sub1:
  say "in sub1"
  returncc
  .pcc_sub _sub2:
  print "in sub2\n"
  returncc
EOF
close $TEMP;

pasm_output_is( <<"CODE", <<'OUTPUT', "load_bytecode autorun first" );
.pcc_sub _main:
    say "main"
    load_bytecode "$temp_pasm"
    say "loaded"
    get_global P0, "_sub2"
    invokecc P0
    say "back"
    end
CODE
main
in sub1
loaded
in sub2
back
OUTPUT

system(".$PConfig{slash}parrot$PConfig{exe}", '-o', $temp_pbc, $temp_pasm );

pasm_output_is( <<"CODE", <<'OUTPUT', "load_bytecode autorun first in pbc" );
.pcc_sub _main:
    say "main"
    load_bytecode "$temp_pbc"
    say "loaded"
    get_global P0, "_sub2"
    invokecc P0
    say "back"
    end
CODE
main
in sub1
loaded
in sub2
back
OUTPUT

($TEMP, $temp_pasm) = tempfile( SUFFIX => '.pasm', UNLINK => 1 );

print $TEMP <<'EOF';
  .pcc_sub _sub1:
  say "in sub1"
  returncc
  .pcc_sub :load _sub2:
  print "in sub2\n"
  returncc
EOF
close $TEMP;

pasm_output_is( <<"CODE", <<'OUTPUT', "load_bytecode autorun second" );
.pcc_sub _main:
    say "main"
    load_bytecode "$temp_pasm"
    say "loaded"
    get_global P0, "_sub1"
    invokecc P0
    say "back"
    end
CODE
main
in sub2
loaded
in sub1
back
OUTPUT

system(".$PConfig{slash}parrot$PConfig{exe}", '-o', $temp_pbc, $temp_pasm );

pasm_output_is( <<"CODE", <<'OUTPUT', "load_bytecode autorun second in pbc" );
.pcc_sub _main:
    say "main"
    load_bytecode "$temp_pbc"
    say "loaded"
    get_global P0, "_sub1"
    invokecc P0
    say "back"
    end
CODE
main
in sub2
loaded
in sub1
back
OUTPUT

($TEMP, $temp_pasm) = tempfile( SUFFIX => '.pasm', UNLINK => 1 );

print $TEMP <<'EOF';
  .pcc_sub :load _sub1:
  say "in sub1"
  returncc
  .pcc_sub :load _sub2:
  print "in sub2\n"
  returncc
EOF
close $TEMP;

pasm_output_is( <<"CODE", <<'OUTPUT', "load_bytecode autorun both" );
.pcc_sub _main:
    say "main"
    load_bytecode "$temp_pasm"
    say "loaded"
    get_global P0, "_sub1"
    invokecc P0
    say "back"
    end
CODE
main
in sub1
in sub2
loaded
in sub1
back
OUTPUT

system(".$PConfig{slash}parrot$PConfig{exe}", '-o', $temp_pbc, $temp_pasm );

pasm_output_is( <<"CODE", <<'OUTPUT', "load_bytecode autorun both in pbc" );
.pcc_sub _main:
    say "main"
    load_bytecode "$temp_pbc"
    say "loaded"
    get_global P0, "_sub1"
    invokecc P0
    say "back"
    end
CODE
main
in sub1
in sub2
loaded
in sub1
back
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', ':main pragma' );
.pcc_sub _first:
    print "first\n"
    returncc
.pcc_sub :main _main:
    say "main"
    end
CODE
main
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', 'two :main pragmas' );
.pcc_sub _first:
    print "first\n"
    returncc
.pcc_sub :main _main:
    say "main"
    end
.pcc_sub :main _second:
    print "second\n"
    returncc
CODE
main
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', ':main pragma call subs' );
.pcc_sub _first:
    print "first\n"
    returncc
.pcc_sub _second:
    print "second\n"
    returncc
.pcc_sub :main _main:
    say "main"
    get_global P0, "_first"
    invokecc P0
    get_global P0, "_second"
    invokecc P0
    end
CODE
main
first
second
OUTPUT

pir_error_output_like( <<'CODE', <<'OUTPUT', "implicit :main with wrong # args." );
.sub a
  .param int op1
  .param int op2
.end
CODE
/too few arguments passed \(1\) - 2 params expected/
OUTPUT

pir_error_output_like( <<'CODE', <<'OUTPUT', "explicit :main with wrong # args." );
.sub a :main
  .param int op1
  .param int op2
.end
CODE
/too few arguments passed \(1\) - 2 params expected/
OUTPUT

($TEMP, $temp_pasm) = tempfile();
print $TEMP <<'EOF';
.sub _sub1 :load
  say "in sub1"
  returncc
.end
EOF
close $TEMP;

pasm_output_is( <<"CODE", <<'OUTPUT', 'load_bytecode :load first sub - pir' );
.pcc_sub _main:
    say "main"
    load_bytecode "$temp_pasm"
    say "back"
    end
CODE
main
in sub1
back
OUTPUT

($TEMP, $temp_pasm) = tempfile();
print $TEMP <<'EOF';
.sub _foo
  print "error\n"
.end

# :load or other pragmas are only evaluated on the first
# instruction of a compilation unit
.sub _sub1 :load
  say "in sub1"
  returncc
.end
EOF
close $TEMP;

pasm_output_is( <<"CODE", <<'OUTPUT', 'load_bytecode :load second sub - pir' );
.pcc_sub _main:
    say "main"
    load_bytecode "$temp_pasm"
    say "back"
    end
CODE
main
in sub1
back
OUTPUT

($TEMP, my $temp_pir) = tempfile( SUFFIX => '.pir', UNLINK => 1 );

print $TEMP <<'EOF';
.sub _foo
  print "error\n"
.end
.sub _sub1
  say "in sub1"
  returncc
.end
EOF
close $TEMP;

pasm_output_is( <<"CODE", <<'OUTPUT', 'load_bytecode no :load - pir' );
.pcc_sub _main:
    say "main"
    load_bytecode "$temp_pir"
    say "back"
    end
CODE
main
back
OUTPUT

# This is the behavior of Parrot 0.4.3
# RT #46817 Should there be a warning ?
pir_output_is( <<'CODE', '', 'warn on in main' );
.sub _main :main
.include "warnings.pasm"
    warningson .PARROT_WARNINGS_UNDEF_FLAG
    _f1()
.end
.sub _f1
    $P0 = new 'Undef'
    print $P0
.end
CODE

pir_output_is( <<'CODE', <<'OUTPUT', "warn on in sub" );
.sub _main :main
.include "warnings.pasm"
    _f1()
    $P0 = new 'Undef'
    print $P0
    print "ok\n"
.end
.sub _f1
    warningson .PARROT_WARNINGS_UNDEF_FLAG
.end
CODE
ok
OUTPUT

# RT #46819 This is the behavior of Parrot 0.4.3
# It looks like core PMCs never emit warning.
# Look in perlundef.t for a more sane test of 'warningson' in subs
pir_output_is( <<'CODE', <<'OUTPUT', "warn on in sub, turn off in f2" );
.sub _main :main
.include "warnings.pasm"
    _f1()
    $P0 = new 'Undef'
    say "back"
    print $P0
    print "ok\n"
.end
.sub _f1
    warningson .PARROT_WARNINGS_UNDEF_FLAG
    _f2()
    $P0 = new 'Undef'
    print $P0
.end
.sub _f2
    warningsoff .PARROT_WARNINGS_UNDEF_FLAG
.end
CODE
back
ok
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "sub names" );
.pcc_sub main:
    .include "interpinfo.pasm"
    interpinfo P20, .INTERPINFO_CURRENT_SUB
    print P20
    print "\n"
    get_global P0, "the_sub"
    invokecc P0
    interpinfo P20, .INTERPINFO_CURRENT_SUB
    print P20
    print "\n"
    end
.pcc_sub the_sub:
    interpinfo P20, .INTERPINFO_CURRENT_SUB
    print P20
    print "\n"
    interpinfo P1, .INTERPINFO_CURRENT_CONT
    returncc
CODE
main
the_sub
main
OUTPUT

pasm_output_is( <<'CODE', <<'OUTPUT', "sub names w MAIN" );
.pcc_sub dummy:
    print "never\n"
    noop
.pcc_sub :main main:
    .include "interpinfo.pasm"
    interpinfo P20, .INTERPINFO_CURRENT_SUB
    print P20
    print "\n"
    get_global P0, "the_sub"
    invokecc P0
    interpinfo P20, .INTERPINFO_CURRENT_SUB
    print P20
    print "\n"
    end
.pcc_sub the_sub:
    interpinfo P20, .INTERPINFO_CURRENT_SUB
    print P20
    print "\n"
    interpinfo P1, .INTERPINFO_CURRENT_CONT
    returncc
CODE
main
the_sub
main
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', "caller introspection via interp" );
.sub main :main
.include "interpinfo.pasm"
    # this test will fail when run with -Oc
    # as the call chain is cut down with tail calls
    foo()

    $P0 = get_hll_global ["Bar"], "foo"
    $P0()
    print "ok\n"
.end
.sub foo
    print "main foo\n"
    $P0 = get_hll_global ["Bar"], "bar"
    $P0()
.end
.namespace ["Bar"]
.sub bar
    print "Bar bar\n"
    $P1 = getinterp
    $P0 = $P1["sub"]
    print "subname: "
    print $P0
    print "\n"
    foo()
.end
.sub foo
    print "Bar foo\n"
    $P1 = getinterp
    $I0 = 0
    push_eh tb_end
tb_loop:
    $P0 = $P1["sub"; $I0]
    print "caller "
    print $I0
    print " "
    print $P0
    print "\n"
    inc $I0
    goto tb_loop
tb_end:
.end
CODE
main foo
Bar bar
subname: bar
Bar foo
caller 0 foo
caller 1 bar
caller 2 foo
caller 3 main
Bar foo
caller 0 foo
caller 1 main
ok
OUTPUT

{

    # the test has different output when run with --run-pbc (make testr)
    # actually not - compiling creates 2 'initial'
    #                running emts 'main'

    my $code = <<'CODE';
.sub optc :immediate :postcomp
    print "initial\n"
.end
.sub _main :main
    say "main"
.end
CODE
    my $descr = ':immediate :postcomp';
    if ( exists $ENV{TEST_PROG_ARGS} and $ENV{TEST_PROG_ARGS} =~ m/-r/ ) {
        pir_output_is( $code, <<'OUT', $descr );
initial
initial
main
OUT
    }
    else {
        pir_output_is( $code, <<'OUT', $descr );
initial
initial
main
OUT
    }
}

pir_output_like( <<'CODE', <<'OUTPUT', ':anon' );
.sub main :main
    "foo"()
    print "ok\n"
    $P0 = global "new"
    $I0 = defined $P0
    print $I0
    print "\n"
    $P0 = global "foo"
    unless null $P0 goto foo
    print "nofoo\n"
  foo:
.end

.sub "foo" :anon
    print "foo\n"
    "new"()
.end

.sub "new"
    print "new\n"
.end
CODE
/^foo
new
ok
1
nofoo/
OUTPUT

($TEMP, my $l1_pir) = tempfile( SUFFIX => '.pir', UNLINK => 1 );
(my $l1_pbc         = $l1_pir) =~ s/\.pir/.pbc/;

print $TEMP <<'EOF';
.sub l11 :load
    print "l11\n"
.end

.sub l12 :load
    print "l12\n"
.end
EOF
close $TEMP;

($TEMP, my $l2_pir) = tempfile( SUFFIX => '.pir', UNLINK => 1 );
(my $l2_pbc         = $l2_pir) =~ s/\.pir/.pbc/;

print $TEMP <<'EOF';
.sub l21 :load
    print "l21\n"
.end

.sub l22 :load
    print "l22\n"
.end
EOF
close $TEMP;

system(".$PConfig{slash}parrot$PConfig{exe}", '-o', $l1_pbc, $l1_pir);
system(".$PConfig{slash}parrot$PConfig{exe}", '-o', $l2_pbc, $l2_pir);

pir_output_is( <<"CODE", <<'OUTPUT', 'multiple :load' );
.sub main :main
    say "main 1"
    load_bytecode "$l1_pir"
    load_bytecode "$l2_pir"
    say "main 2"
    load_bytecode "$l1_pbc"	# these have to be ignored
    load_bytecode "$l2_pbc"
    say "main 3"
.end
CODE
main 1
l11
l12
l21
l22
main 2
main 3
OUTPUT

unlink( $l1_pbc, $l2_pbc );

pir_output_is( <<'CODE', <<'OUTPUT', "immediate code as const" );
.sub make_pi :immediate :anon
    $N0 = atan 1.0, 1.0
    $N0 *= 4
    $P0 = new 'Float'
    $P0 = $N0
    .return ($P0)
.end

.sub main :main
    .const .Sub pi = "make_pi"
    print pi
    print "\n"
.end
CODE
3.14159265358979
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', "immediate code as const - obj" );
.sub make_obj :immediate :anon
    .local pmc cl, o
    cl = newclass "Foo"
    addattribute cl, 'x'
    o = new 'Foo'
    $P0 = new 'String'
    $P0 = "ok 1\n"
    setattribute o, 'x', $P0
    .return (o)
.end

.sub main :main
    .const .Sub o = "make_obj"
    $P0 = getattribute o, 'x'
    print $P0
.end

CODE
ok 1
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', "__get_regs_used 1" );
.sub main :main
    .local pmc m
    .include "interpinfo.pasm"
    m = interpinfo .INTERPINFO_CURRENT_SUB
    $I0 = m."__get_regs_used"('N')
    print $I0
    $I0 = m."__get_regs_used"('I')
    print $I0
    $I0 = m."__get_regs_used"('S')
    print $I0
    $I0 = m."__get_regs_used"('P')
    print $I0
    print "\n"
.end

CODE
0101
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', "__get_regs_used 2" );
.sub main :main
    foo()
.end
.sub foo
    .local pmc m
    .include "interpinfo.pasm"
    m = interpinfo .INTERPINFO_CURRENT_SUB
    set N0, 1.0
    set N7, 1.0
    add N7, N7, N0
    set I9, 1
    add I10, I9, I9
    $I0 = m."__get_regs_used"('N')
    print $I0
    $I0 = m."__get_regs_used"('I')
    print $I0
    $I0 = m."__get_regs_used"('S')
    print $I0
    $I0 = m."__get_regs_used"('P')
    print $I0
    print "\n"
.end


CODE
2301
OUTPUT

pir_output_like(
    <<"CODE", <<'OUTPUT', 'warn on in main', todo => "RT #46819 core undef doesn't warn here. Should it?" );
.sub 'test' :main
.include "warnings.pasm"
    warningson .PARROT_WARNINGS_UNDEF_FLAG
    _f1()
.end
.sub _f1
    P0 = new 'Undef'
    print P0
.end
CODE
/uninit/
OUTPUT

pir_output_is( <<"CODE", <<'OUTPUT', 'warn on in sub' );
.sub 'test' :main
.include "warnings.pasm"
    _f1()
    P0 = new 'Undef'
    print P0
    say "ok"
.end
.sub _f1
    warningson .PARROT_WARNINGS_UNDEF_FLAG
.end
CODE
ok
OUTPUT

pir_output_like(
    <<"CODE", <<'OUTPUT', 'warn on in sub, turn off in f2', todo => "RT #46819 core undef doesn't warn here. Should it?" );
.sub 'test' :main
.include "warnings.pasm"
    _f1()
    P0 = new 'Undef'
    say "back"
    print P0
    say "ok"
.end
.sub _f1
    warningson .PARROT_WARNINGS_UNDEF_FLAG
    _f2()
    P0 = new 'Undef'
    print P0
.end
.sub _f2
    warningsoff .PARROT_WARNINGS_UNDEF_FLAG
.end
CODE
/uninit.*\n.*\nback\nok/
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', ':postcomp' );
.sub main :main
    say "main"
.end
.sub pc :postcomp
    print "pc\n"
.end
.sub im :immediate
    print "im\n"
.end
.sub pc2 :postcomp
    print "pc2\n"
.end
.sub im2 :immediate
    print "im2\n"
.end
CODE
im
im2
pc
pc2
main
OUTPUT

# see also #38964
pir_output_is( <<'CODE', <<'OUTPUT', 'unicode sub names, compilation' );
.sub unicode:"\u7777"
   print "ok\n"
.end
CODE
ok
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', 'unicode sub names, invocation' );
.sub unicode:"\u7777"
    print "ok\n"
.end

.sub test :main
    unicode:"\u7777"()
.end
CODE
ok
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', 'unicode sub names, dynamic' );
.sub unicode:"\u7777"
    print "ok\n"
.end

.sub test :main
    $P1 = find_name unicode:"\u7777"
    $P1()
.end
CODE
ok
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', 'unicode sub names' );
.sub unicode:"\u7777"
    print "ok\n"
.end

.sub test :main
    # unicode:"\u7777" ends up as a string nicode:"\u7777
    # (or it did, in r12860)
    $P1 = find_name 'nicode:"\u7777'
    unless null $P1 goto bad
    print "not found\n"
  bad:
.end
CODE
not found
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', 'unicode sub constant' );
.sub main :main
    .const .Sub s = unicode:"\u7777"
    s()
.end

.sub unicode:"\u7777"
   print "ok\n"
.end
CODE
ok
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', 'literal \u in sub name (not unicode)' );
.sub '\u2193'
    say 'ok'
.end
CODE
ok
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', 'load_bytecode with .pir (RT #39807)' );
.sub main :main
    load_bytecode 'PGE.pbc'
    load_bytecode 'dumper.pir'
    load_bytecode 'PGE/Dumper.pir'

    $P0 = compreg 'PGE::P5Regex'
    $P1 = $P0('aabb*')
    $P2 = $P1('fooaabbbar')

    _dumper($P2)
.end
CODE
"VAR1" => PMC 'PGE;Match' => "aabbb" @ 3
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', 'load_bytecode with .pbc (RT #39807)' );
.sub main :main
    load_bytecode 'PGE.pbc'
    load_bytecode 'dumper.pbc'
    load_bytecode 'PGE/Dumper.pbc'

    $P0 = compreg 'PGE::P5Regex'
    $P1 = $P0('aabb*')
    $P2 = $P1('fooaabbbar')

    _dumper($P2)
.end
CODE
"VAR1" => PMC 'PGE;Match' => "aabbb" @ 3
OUTPUT

pir_error_output_like( <<'CODE', qr/Null PMC access in invoke()/, 'invoking null pmc' );
.sub main :main
    null $P0
    $P0()
.end
CODE

pir_output_is( <<'CODE', <<'OUTPUT', ":init" );
.sub a :init
    print "in inited\n"
.end

.sub main :main
    say "main"
.end
CODE
in inited
main
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', 'assign' );
.sub main :main
    $P0 = get_global 'ok'

    $P1 = new 'Undef'
    assign $P1, $P0

    $P1()
.end

.sub ok
    say "ok"
.end
CODE
ok
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', 'assign w/:outer' );
.sub main :main
    $P0 = get_global 'ok'

    $P1 = new 'Undef'
    assign $P1, $P0

    $P1()
.end

.sub ok :outer('main')
    say "ok"
.end
CODE
ok
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', 'get_namespace()' );
.sub main :main
    $P0 = get_global 'main'
    $P0 = $P0.'get_namespace'()
    $P0 = $P0.'get_name'()
    $S0 = join ';', $P0
    say $S0

    $P0 = get_global ['Foo'; 'Bar'], 'foo'
    $P0 = $P0.'get_namespace'()
    $P0 = $P0.'get_name'()
    $S0 = join ';', $P0
    say $S0
.end

.namespace ['Foo'; 'Bar']
.sub foo
    noop
.end
CODE
parrot
parrot;Foo;Bar
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', 'arity()' );
.sub main :main
    $P0 = get_global 'none'
    $I0 = $P0.arity()
    say $I0

    $P0 = get_global 'one'
    $I0 = $P0.arity()
    say $I0

    $P0 = get_global 'four'
    $I0 = $P0.arity()
    say $I0

    $P0 = get_global 'all_slurpy'
    $I0 = $P0.arity()
    say $I0

    $P0 = get_global 'some_optional'
    $I0 = $P0.arity()
    say $I0

    $P0 = get_global 'some_named'
    $I0 = $P0.arity()
    say $I0

    $P0 = get_global 'allsorts'
    $I0 = $P0.arity()
    say $I0
.end

.sub none
.end

.sub one
    .param int a
.end

.sub four
    .param int a
    .param pmc b
    .param string c
    .param num d
.end

.sub all_slurpy
    .param pmc s :slurpy
.end

.sub some_optional
    .param int a
    .param int b :optional
    .param int bo :opt_flag
    .param int c
.end

.sub some_named
    .param int a :named
    .param int b
    .param int c :named
.end

.sub allsorts
    .param int a :named
    .param int b :optional
    .param int bo :opt_flag
    .param int c
    .param pmc s :slurpy
.end
CODE
0
1
4
0
2
3
2
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', 'set_outer' );
.sub main :main
    $P0 = find_global "example_outer"
    $P1 = find_global "example_inner"
    $P1.set_outer($P0)
    $P0()
    $P1()
.end

.sub example_outer
    .lex "Foo", $P0
    $P0 = new 'String'
    $P0 = 'I can has outer?'
.end

.sub example_inner
    $P0 = find_lex "Foo"
    say $P0
.end
CODE
I can has outer?
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', ':outer with identical sub names' );
.sub 'main' :main
    $P0 = get_hll_global ['ABC'], 'outer'
    $P0('ABC lex')

    $P0 = get_hll_global ['DEF'], 'outer'
    $P0('DEF lex')
.end

.namespace ['ABC']
.sub 'outer' :lexid('abc_outer')
    .param pmc x
    .lex '$abc', x
    say 'ABC::outer'
    'inner'()
.end

.sub 'inner' :outer('abc_outer')
    say 'ABC::inner'
    $P0 = find_lex '$abc'
    say $P0
.end

.namespace ['DEF']
.sub 'outer' :lexid('def_outer')
    .param pmc x
    .lex '$def', x
    say 'DEF::outer'
    'inner'()
.end

.sub 'inner' :outer('def_outer')
    say 'DEF::inner'
    $P0 = find_lex '$def'
    say $P0
.end
CODE
ABC::outer
ABC::inner
ABC lex
DEF::outer
DEF::inner
DEF lex
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', ':lexid and identical string constants' );
.sub 'main'
    'foo'()
    'bar'()
.end

.sub 'foo'
    new $P0, "String"
    assign $P0, "abc"
    say $P0
.end

.sub 'bar'  :lexid("abc")
    new $P0, "String"
    assign $P0, "abc"
    say $P0
.end
CODE
abc
abc
OUTPUT

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
