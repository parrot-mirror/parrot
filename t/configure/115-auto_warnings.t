#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 115-auto_warnings.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( lib );
use_ok('config::auto::warnings');

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

115-auto_warnings.t - test config::auto::warnings

=head1 SYNOPSIS

    % prove t/configure/115-auto_warnings.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::auto::warnings.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::warnings, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
