#!tcl

# Copyright (C) 2004-2007, The Perl Foundation.
# $Id$

source lib/test_more.tcl
plan 3

eval_is {
 proc joe {} {
   set a 10
   return $a
   set a 20
 }
 joe
} 10 {simple return with value}

eval_is {
 proc joe {} {
   return
 }
 joe
} {} {simple return with no value}

eval_is {
  proc joe {} { return -code error "bad args" }
  joe
  puts foo
} {bad args} {-code error}
