#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 110-inter_yacc.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib );
use_ok('config::inter::yacc');

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

110-inter_yacc.t - test config::inter::yacc

=head1 SYNOPSIS

    % prove t/configure/110-inter_yacc.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::inter::yacc.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::inter::yacc, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
