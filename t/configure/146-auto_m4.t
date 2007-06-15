#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 146-auto_m4.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib );
use_ok('config::auto::m4');

pass("Completed all tests in maketest.pl");

################### DOCUMENTATION ###################

=head1 NAME

146-auto_m4.t - test config::auto::m4

=head1 SYNOPSIS

    % prove t/configure/146-auto_m4.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::auto::m4.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::m4, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
