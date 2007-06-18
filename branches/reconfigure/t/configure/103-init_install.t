#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 103-init_install.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib );
use_ok('config::init::install');

=for hints_for_testing This file ought to test what happens when you provide a
non-default directory to each of the options in config/init/install.  For
testing purposes, these directories probably do not have to be real.  You
should probably test the Parrot::Configure object before and after calling
runsteps() in order to verify that the non-defaults made it into the object.

=cut

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

103-init_install.t - test config::init::install

=head1 SYNOPSIS

    % prove t/configure/103-init_install.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::init::install.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::init::install, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
