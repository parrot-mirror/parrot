#!tcl

# Copyright (C) 2004-2006, The Perl Foundation.
# $Id$

source lib/test_more.tcl
plan 6

is [concat] {} {concat nothing}
is [concat a] {a} {concat one thing}
is [concat a b] {a b} {concat two things}

is [concat a [list b]] {a b} {concat sub list of one}
is [concat a [list b c]] {a b c} {concat sub list of one}
is [concat a [list b c [list d e]]] {a b c {d e}} {concat sub sub list of one}
