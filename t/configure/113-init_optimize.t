#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 113-init_optimize.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib );
use_ok('config::init::optimize');

=for hints_for_testing Check latest reports of Parrot configuration tools
testing coverage to see where your time available for writing tests is spent.
You may need to create some dummy optimizations to boost test coverage.  Note
the comment in POD:  "Should this be part of config/inter/progs.pm?"

=cut

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

113-init_optimize.t - test config::init::optimize

=head1 SYNOPSIS

    % prove t/configure/113-init_optimize.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::init::optimize.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::init::optimize, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
