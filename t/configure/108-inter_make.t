#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 108-inter_make.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib );
use_ok('config::inter::make');

=for hints_for_testing Since inter::make probes for the make program found on
a particular OS, it will probably be difficult to achieve high branch or
condition coverage.  Check latest reports of Parrot configuration tools
testing coverage to see where your time is best devoted.  You will have to
determine a way to test a user's response to a prompt. #'  In the course of
writing tests, you should try to resolve RT 43171.

=cut

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

108-inter_make.t - test config::inter::make

=head1 SYNOPSIS

    % prove t/configure/108-inter_make.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::inter::make.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::inter::make, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
