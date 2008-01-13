#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# gen_config_h-01.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( lib );
use_ok('config::gen::config_h');

=for hints_for_testing (At last!  A config/ package with somewhat
adequate documentation!)  Consider testing the content of the files
which the POD claims the module creates.

=cut

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

gen_config_h-01.t - test config::gen::config_h

=head1 SYNOPSIS

    % prove t/steps/gen_config_h-01.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::gen::config_h.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::gen::config_h, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
