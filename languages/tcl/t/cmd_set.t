#!/usr/bin/perl

use strict;
use lib qw(tcl/t t . ../lib ../../lib ../../../lib);
use Parrot::Test tests => 5;
use vars qw($TODO);

my($tcl,$expected);

$tcl = <<'EOTCL';
 set a 2
 puts $a
EOTCL
$expected = "2\n";
language_output_is("tcl",$tcl,$expected,"set");

$tcl = <<'EOTCL';
 set a 1
 puts [set a]
EOTCL
$expected = "1\n";
language_output_is("tcl",$tcl,$expected,"get");

$tcl = <<'EOTCL';
 puts -nonewline $a
EOTCL
$expected = "can't read \"a\": no such variable\n";
language_output_is("tcl",$tcl,$expected,"missing lexical");

$tcl = <<'EOTCL';
 set b 1
 set b(c) 2
EOTCL
$expected = "can't set \"b(c)\": variable isn't array\n";
language_output_is("tcl",$tcl,$expected,"not an array");

TODO: {
local $TODO = "bugs";
language_output_is("tcl",<<'TCL',<<'OUT',"variable that looks like an array");
set x(0) 44
puts ${x(0)}
TCL
44
OUT
}
