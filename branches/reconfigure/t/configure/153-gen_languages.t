#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 153-gen_languages.t

use strict;
use warnings;
use Test::More tests =>  2;
use Carp;
use lib qw( . lib ../lib ../../lib );
use_ok('config::gen::languages');

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

153-gen_languages.t - test config::gen::languages

=head1 SYNOPSIS

    % prove t/configure/153-gen_languages.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::gen::languages.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::gen::languages, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
