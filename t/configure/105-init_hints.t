#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 105-init_hints.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib );
use_ok('config::init::hints');

=for hints_for_testing init::hints functions as a loader for the OS-specific
hints file in config/init/hints/ as well as for any locally installed
hints file.  So a dummy local hints file should probably be created in a
temporary directory, then have its loading be tested.

=cut

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

105-init_hints.t - test config::init::hints

=head1 SYNOPSIS

    % prove t/configure/105-init_hints.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::init::hints.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::init::hints, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
