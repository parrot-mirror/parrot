#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 109-inter_lex.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib );
use_ok('config::inter::lex');

=for hints_for_testing Since inter::lex probes for the lex program found
on a particular OS, it will probably be difficult to achieve high branch
or condition coverage.  Check latest reports of Parrot configuration
tools testing coverage to see where your time is best devoted.  You will
have to determine a way to test a user response to a prompt.

=cut

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

109-inter_lex.t - test config::inter::lex

=head1 SYNOPSIS

    % prove t/configure/109-inter_lex.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::inter::lex.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::inter::lex, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
