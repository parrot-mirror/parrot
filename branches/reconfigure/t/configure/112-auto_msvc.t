#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 112-auto_msvc.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib );
use_ok('config::auto::msvc');

=for hints_for_testing This test may be meaningless if you are not on Windows.
Consider writing a SKIP block.  Check latest reports of Parrot configuration
tools testing coverage to see where your time available for writing tests is
spent.

=cut

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

112-auto_msvc.t - test config::auto::msvc

=head1 SYNOPSIS

    % prove t/configure/112-auto_msvc.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::auto::msvc.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::msvc, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
