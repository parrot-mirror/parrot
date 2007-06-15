#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 150-gen_config_h.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib );
use_ok('config::gen::config_h');

pass("Completed all tests in maketest.pl");

################### DOCUMENTATION ###################

=head1 NAME

150-gen_config_h.t - test config::gen::config_h

=head1 SYNOPSIS

    % prove t/configure/150-gen_config_h.t

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
