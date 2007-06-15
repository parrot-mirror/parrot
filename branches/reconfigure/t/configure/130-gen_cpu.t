#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id: 03-steplist.t 18404 2007-05-03 01:26:50Z jkeenan $
# 130-gen_cpu.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib );
use_ok('config::gen::cpu');

pass("Completed all tests in maketest.pl");

################### DOCUMENTATION ###################

=head1 NAME

130-gen_cpu.t - test config::gen::cpu

=head1 SYNOPSIS

    % prove t/configure/130-gen_cpu.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::gen::cpu.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::gen::cpu, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
