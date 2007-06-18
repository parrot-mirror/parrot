#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 141-auto_readline.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib );
use_ok('config::auto::readline');

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

141-auto_readline.t - test config::auto::readline

=head1 SYNOPSIS

    % prove t/configure/141-auto_readline.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::auto::readline.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::readline, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
