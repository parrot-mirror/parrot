#! perl -w
# Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
# $Id$

=head1 NAME

t/library/pge.t - Grammar Engine tests

=head1 SYNOPSIS

	% perl -Ilib t/library/pge.t

=cut

use strict;

use Parrot::Test tests => 6;

# 1
pir_output_is(<<'CODE', <<'OUT', "character class membership");

.sub _main
    load_bytecode "library/PGE/Class.pir"

    .local pmc vowels
    .local pmc new_sub

    find_global new_sub, "PGE::Class::Discrete", "new"
    vowels = new_sub("aeiou")

    $I1 = vowels["o"]
    if $I1 goto OK1
    print "not "
OK1:
    print "ok 1\n"

    $I2 = vowels["q"]
    unless $I2 goto OK2
    print "not "
OK2:
    print "ok 2\n"

    end
.end
CODE
ok 1
ok 2
OUT

# 2
pir_output_is(<<'CODE', <<'OUT', "character class membership: method form");

.sub _main
    load_bytecode "library/PGE/Class.pir"

    .local pmc vowels
    .local pmc new_sub
    find_global new_sub, "PGE::Class::Discrete", "new"
    vowels = new_sub("aeiou")

    $I1 = vowels.matches("o")
    if $I1 goto OK1
    print "not "
OK1:
    print "ok 1\n"

    $I2 = vowels.matches("q")
    unless $I2 goto OK2
    print "not "
OK2:
    print "ok 2\n"

    end
.end
CODE
ok 1
ok 2
OUT

# 3
pir_output_is(<<'CODE', <<'OUT', "RegCounter");

.sub _main
    load_bytecode "library/PGE/RegCounter.pir"
    
    .local pmc rc
    $P0 = find_global "PGE::RegCounter", "new"
    rc = $P0()

    rc.declare("foo", "$I")
    rc.declare("bar", "$P")
    rc.declare("baz", "$I")

    $S0 = rc["foo"]
    print $S0
    print "\n"

    $S0 = rc["bar"]
    print $S0
    print "\n"

    $S0 = rc["baz"]
    print $S0
    print "\n"

    $S0 = rc["bar"]
    print $S0
    print "\n"

    .local pmc ch
    ch = rc.next()

    ch.declare("bar", "$P")
    ch.declare("baz", "$P")
    ch.declare("quux", "_L")

    $S0 = ch["bar"]
    print $S0
    print "\n"

    $S0 = ch["baz"]
    print $S0
    print "\n"

    $S0 = ch["quux"]
    print $S0
    print "\n"

    $S0 = ch["bar"]
    print $S0
    print "\n"

    $S0 = rc["bar"]
    print $S0
    print "\n"

    $S0 = rc["baz"]
    print $S0
    print "\n"
.end
CODE
$I0
$P1
$I2
$P1
$P3
$P4
_L5
$P3
$P1
$I2
OUT

pir_output_is(<<'CODE', <<'OUT', "Glob, wildcards");

.sub _main
  load_bytecode "library/PGE.pbc"
  load_bytecode "library/PGE/Glob.pir"

  .local pmc rule
  $P0 = find_global "PGE", "glob"
  (rule, $P1, $P2) = $P0("b?n*a")

  $P1 = rule("banana")
  if $P1 goto ok1
  print "not "
ok1:
  print "ok1\n"

  $P1 = rule("bznza")
  if $P1 goto ok2
  print "not "
ok2:
  print "ok2\n"

  $P1 = rule("bana")
  if $P1 goto ok3
  print "not "
ok3:
  print "ok3\n"

  $P1 = rule("bnana")
  unless $P1 goto ok4
  print "not "
ok4:
  print "ok4\n"


  (rule, $P1, $P2) = $P0("?n?*")

  $P1 = rule("bnan")
  if $P1 goto ok5
  print "not "
ok5:
  print "ok5\n"

  $P1 = rule("ana")
  if $P1 goto ok6
  print "not "
ok6:
  print "ok6\n"

  $P1 = rule("an")
  unless $P1 goto ok7
  print "not "
ok7:
  print "ok7\n"

.end
CODE
ok1
ok2
ok3
ok4
ok5
ok6
ok7
OUT

pir_output_is(<<'CODE', <<'OUT', "Glob, character classes");

.sub _main
  load_bytecode "library/PGE.pbc"
  load_bytecode "library/PGE/Glob.pir"

  .local pmc rule
  $P0 = find_global "PGE", "glob"
  (rule, $P1, $P2) = $P0("[go]range")

  $P1 = rule("orange")
  if $P1 goto ok1
  print "not "
ok1:
  print "ok1\n"

  $P1 = rule("grange")
  if $P1 goto ok2
  print "not "
ok2:
  print "ok2\n"

  $P1 = rule("ggrange")
  unless $P1 goto ok3
  print "not "
ok3:
  print "ok3\n"

  $P1 = rule("borange")
  unless $P1 goto ok4
  print "not "
ok4:
  print "ok4\n"

  $P1 = rule("arange")
  unless $P1 goto ok5
  print "not "
ok5:
  print "ok5\n"

  (rule, $P1, $P2) = $P0("[^0-9]")

  $P1 = rule("a")
  if $P1 goto ok6
  print "not "
ok6:
  print "ok6\n"

  $P1 = rule("4")
  unless $P1 goto ok7
  print "not "
ok7:
  print "ok7\n"

  $P1 = rule("0")
  unless $P1 goto ok8
  print "not "
ok8:
  print "ok8\n"

  $P1 = rule("9")
  unless $P1 goto ok9
  print "not "
ok9:
  print "ok9\n"

  $P1 = rule("4a")
  unless $P1 goto ok10
  print "not "
ok10:
  print "ok10\n"

  $P1 = rule("aa")
  unless $P1 goto ok11
  print "not "
ok11:
  print "ok11\n"

.end
CODE
ok1
ok2
ok3
ok4
ok5
ok6
ok7
ok8
ok9
ok10
ok11
OUT

pir_output_is(<<'CODE', <<'OUT', "Glob, alternate");

.sub _main
  load_bytecode "library/PGE.pbc"
  load_bytecode "library/PGE/Glob.pir"

  .local pmc rule
  $P0 = find_global "PGE", "glob"
  (rule, $P1, $P2) = $P0("{app,bet,cod}a")

  $P1 = rule("appa")
  if $P1 goto ok1
  print "not "
ok1:
  print "ok1\n"

  $P1 = rule("coda")
  if $P1 goto ok2
  print "not "
ok2:
  print "ok2\n"

  $P1 = rule("beta")
  if $P1 goto ok3
  print "not "
ok3:
  print "ok3\n"

  $P1 = rule("bet")
  unless $P1 goto ok4
  print "not "
ok4:
  print "ok4\n"

  $P1 = rule("alfa")
  unless $P1 goto ok5
  print "not "
ok5:
  print "ok5\n"

  (rule, $P1, $P2) = $P0("*{1,two,three}")

  $P1 = rule("1")
  if $P1 goto ok6
  print "not "
ok6:
  print "ok6\n"

  $P1 = rule("ptwo")
  if $P1 goto ok7
  print "not "
ok7:
  print "ok7\n"

  $P1 = rule("al")
  unless $P1 goto ok8
  print "not "
ok8:
  print "ok8\n"

  $P1 = rule("three")
  if $P1 goto ok9
  print "not "
ok9:
  print "ok9\n"

  $P1 = rule("twop")
  unless $P1 goto ok10
  print "not "
ok10:
  print "ok10\n"

  $P1 = rule("1atwo")
  if $P1 goto ok11
  print "not "
ok11:
  print "ok11\n"

.end
CODE
ok1
ok2
ok3
ok4
ok5
ok6
ok7
ok8
ok9
ok10
ok11
OUT

# vim: ft=imc :
