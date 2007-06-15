#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 121-auto_alignptrs.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib );
use_ok('config::auto::alignptrs');

pass("Completed all tests in maketest.pl");

################### DOCUMENTATION ###################

=head1 NAME

121-auto_alignptrs.t - test config::auto::alignptrs

=head1 SYNOPSIS

    % prove t/configure/121-auto_alignptrs.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::auto::alignptrs.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::alignptrs, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
