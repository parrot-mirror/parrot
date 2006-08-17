#!/usr/bin/perl

use strict;
use lib qw(tcl/lib ./lib ../lib ../../lib ../../../lib);
use Parrot::Test tests => 27;
use Test::More;

language_output_is("tcl",<<'TCL',<<OUT,"leading spacex2 should be ok");
   puts Parsing
TCL
Parsing
OUT

language_output_is("tcl",<<'TCL',<<OUT,"double quoting words, puts");
 puts "Parsing"
TCL
Parsing
OUT

language_output_is("tcl",<<'TCL',<<OUT,"simple block quoting");
 puts {Parsing}
TCL
Parsing
OUT

language_output_is("tcl",<<'TCL',<<OUT,"bare words should be allowed");
 puts Parsing
TCL
Parsing
OUT

language_output_is("tcl",<<'TCL',<<OUT,"hash isn't a comment if it only starts a word (not a command)");
 puts #whee
 exit ;
TCL
#whee
OUT

language_output_is("tcl",<<'TCL',<<OUT,"no arg command");
 puts {test}
 exit
 puts {bar}
TCL
test
OUT

language_output_is("tcl",<<'TCL',<<OUT,"no arg command with semicolon");
 puts {test}
 exit;
 puts {bar}
TCL
test
OUT

language_output_is("tcl",<<'TCL',<<OUT,"no arg command with spaced semicolon");
 puts {test}
 exit ;
TCL
test
OUT

language_output_is("tcl",<<'TCL',<<'OUT',"\$ is only a variable if it's followed by \\w or {");
set x $
puts $x
TCL
$
OUT

language_output_is("tcl",<<'TCL',<<'OUT',"semi-colon in a string");
puts ";"
TCL
;
OUT

language_output_is("tcl",<<'TCL',<<'OUT',"variables and procs with same name");
set a 2
a
TCL
invalid command name "a"
OUT

language_output_is("tcl",<<'TCL',<<'OUT',"comments must *start* commands (doesn't)");
puts 4 # comment
TCL
bad argument "comment": should be "nonewline"
OUT

language_output_is("tcl",<<'TCL',<<'OUT',"comments must *start* commands (does)");
# comment
puts 1
TCL
1
OUT

language_output_is("tcl",<<'TCL',<<'OUT',"comments with a blank line in between");
#one

#two
puts foo
TCL
foo
OUT

language_output_is("tcl",<<'TCL',<<'OUT',"comments must *start* commands (does), with whitespace");
 # comment
 puts 1
TCL
1
OUT

language_output_is("tcl",<<'TCL',<<'OUT',"comments end on newline, not ;");
 # comment ; puts 1
 puts 2
TCL
2
OUT

language_output_is("tcl",<<'TCL',<<'OUT',"two comments in a row should work");
 # comment1
 # comment2
 puts 2
TCL
2
OUT

language_output_is("tcl",<<'TCL',<<'OUT',"extra characters after close-quote");
  list "a"a
TCL
extra characters after close-quote
OUT

language_output_is("tcl",<<'TCL',<<'OUT',"extra characters after close-brace");
  list {a}a
TCL
extra characters after close-brace
OUT

language_output_is("tcl",<<'TCL',<<'OUT',"subcommands with semicolons");
  puts [set a [set b 1; set c 2]]
TCL
2
OUT

language_output_is("tcl",<<'TCL',<<'OUT',"GC bug?");
  for {set i 1} {$i < 100} {incr i} {}
  puts ok
TCL
ok
OUT

language_output_is("tcl",<<'TCL',<<'OUT',"compiler bug with reusing registers");
  set x " \{"
  puts [list [catch {lappend x "a"} msg] $msg]
TCL
1 {unmatched open brace in list}
OUT

language_output_is("tcl",<<'TCL',<<'OUT',"{} command");
  proc {} {} {puts ok}
  {}
TCL
ok
OUT

{

  # Note - we need to keep the path around for windows
  my $path = $ENV{PATH};
  local undef %ENV;
  $ENV{PATH}   = $path; 
  $ENV{cow}    = 'moo';
  $ENV{pig}    = 'oink';
  $ENV{cowpig} = 'moink';

SKIP: {
  skip("pending parray fix", 1);

language_output_is("tcl",<<'TCL',<<"OUT","reading environment variables");
  parray env
TCL
env(PATH)   = $path
env(cow)    = moo
env(cowpig) = moink
env(pig)    = oink
OUT
}
}

language_output_is("tcl", <<'TCL', <<'OUT', "args checking from inlined commands");
  proc incr {} { puts ok }
  incr
TCL
ok
OUT

language_output_is('tcl', <<'TCL', <<'OUT', 'order of arguments with __integer conversion');
set x 0012
puts [list $x [incr x]]
TCL
0012 11
OUT

language_output_is('tcl', <<'TCL', <<'OUT', 'make sure list value can be overridden by a string value');
  set value [list a b c]
  set value 2
  puts $value
TCL
2
OUT
