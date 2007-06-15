#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 111-auto_gcc.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib );
use_ok('config::auto::gcc');

pass("Completed all tests in maketest.pl");

################### DOCUMENTATION ###################

=head1 NAME

111-auto_gcc.t - test config::auto::gcc

=head1 SYNOPSIS

    % prove t/configure/111-auto_gcc.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::auto::gcc.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::gcc, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
