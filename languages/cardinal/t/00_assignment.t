#!perl

# Copyright (C) 2006, The Perl Foundation.

use strict;
use warnings;
use lib qw(t . lib ../lib ../../lib ../../../lib);
use Parrot::Test tests => 5;

language_output_is( 'cardinal', <<'CODE', <<'OUT', 'integer assignment' );
a=1
puts a
CODE
OUT

language_output_is( 'cardinal', <<'CODE', <<'OUT', 'double quoted string assignment' );
a="Double quoted string"
puts a
CODE
OUT

language_output_is( 'cardinal', <<'CODE', <<'OUT', 'single quoted string assignment' );
a='Single quoted string'
puts a
CODE
OUT

language_output_is( 'cardinal', <<'CODE', <<'OUT', 'global variable assignment' );
$a='$a'
puts $a
CODE
OUT

language_output_is( 'cardinal', <<'CODE', <<'OUT', 'global variable assignment' );
$A='$A'
puts $A
CODE
OUT

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
