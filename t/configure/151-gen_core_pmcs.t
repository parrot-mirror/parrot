#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 151-gen_core_pmcs.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib );
use_ok('config::gen::core_pmcs');

=for hints_for_testing (At last!  A config/ package with somewhat adequate
documentation!)  Consider testing the content of the files which the POD
claims the module creates.

=cut

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

151-gen_core_pmcs.t - test config::gen::core_pmcs

=head1 SYNOPSIS

    % prove t/configure/151-gen_core_pmcs.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::gen::core_pmcs.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::gen::core_pmcs, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
