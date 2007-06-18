#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 104-init_miniparrot.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib );
use_ok('config::init::miniparrot');

=for hints_for_testing This file ought to test what happens when you first
create a Parrot::Configure object, populate it with default settings as in
init::defaults, then override those settings per init::miniparrot.

=cut

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

104-init_miniparrot.t - test config::init::miniparrot

=head1 SYNOPSIS

    % prove t/configure/104-init_miniparrot.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::init::miniparrot.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::init::miniparrot, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
