#!perl
# Copyright (C) 2006, The Perl Foundation.
# $Id$

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More;
use Parrot::Test;

=head1 NAME

t/pmc/random.t - test the Random PMC


=head1 SYNOPSIS

	% prove t/pmc/random.t

=head1 DESCRIPTION

Tests the Random PMC.

=cut


pir_output_is(<<'CODE', <<'OUT', 'new');
.sub 'test' :main
	new P0, .Random
	print "ok 1\n"
.end
CODE
ok 1
OUT


# remember to change the number of tests :-)
BEGIN { plan tests => 1; }
