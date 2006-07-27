#!/usr/bin/perl

use strict;
use lib qw(t . lib ../lib ../../lib ../../../lib);
use Parrot::Test tests => 1;

language_output_is('cardinal', <<'CODE', <<'OUT', 'simple conditional test');
puts(1+2) if true
CODE
3
OUT
