#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 127-auto_format.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib );
use_ok('config::auto::format');

=for hints_for_testing The documentation of the package being tested is
insufficient; please try to improve it.  Check latest reports of Parrot
configuration tools testing coverage to see where your time available for
writing tests is spent.  Try to write tests which will trigger the 'die'
statements in the package being tested.  They can be caught in 'eval' blocks
and then the error messages can be examined with Test::More::like().

=cut

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

127-auto_format.t - test config::auto::format

=head1 SYNOPSIS

    % prove t/configure/127-auto_format.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::auto::format.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::format, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
