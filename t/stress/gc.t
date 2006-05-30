#! perl -w
# Copyright (C) 2001-2003, The Perl Foundation.
# $Id$

=head1 NAME

t/stress/gc.t - Garbage Collection

=head1 SYNOPSIS

	% perl -Ilib t/stress/gc.t

=head1 DESCRIPTION

Tests garbage collection.

=cut

use Parrot::Test tests => 1;
use Test::More;
use Parrot::PMC qw(%pmc_types);

pasm_output_is(<<'CODE', <<'OUTPUT', "arraystress");
	print "starting\n"
	new P0, .Integer
	print "ending\n"
	end
CODE
starting
ending
OUTPUT

1;
