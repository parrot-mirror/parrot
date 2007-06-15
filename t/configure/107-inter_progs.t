#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 107-inter_progs.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib );
use_ok('config::inter::progs');

pass("Completed all tests in maketest.pl");

################### DOCUMENTATION ###################

=head1 NAME

107-inter_progs.t - test config::inter::progs

=head1 SYNOPSIS

    % prove t/configure/107-inter_progs.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::inter::progs.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::inter::progs, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
