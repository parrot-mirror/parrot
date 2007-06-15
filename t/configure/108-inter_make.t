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

pass("Completed all tests in maketest.pl");

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
