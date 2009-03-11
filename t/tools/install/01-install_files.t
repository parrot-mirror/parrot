#! perl
# Copyright (C) 2007, Parrot Foundation.
# $Id$
# 01-install_files.t

use strict;
use warnings;

use Test::More tests =>  1;
use Carp;
use File::Temp qw( tempdir );
use lib qw( lib );
use Parrot::Install qw(
    install_files
    create_directories
    lines_to_files
);
use IO::CaptureOutput qw( capture );

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

01-install_files.t - test subroutines exported by C<Parrot::Install>

=head1 SYNOPSIS

    % prove t/tools/install/01-install_files.t

=head1 DESCRIPTION

The files in this directory test functionality used by
F<tools/dev/install_files.pl> and F<tools/dev/install_dev_files.pl> and
exported by F<lib/Parrot/Install.pm>.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Install, F<tools/dev/install_files.pl>, F<tools/dev/install_dev_files.pl>

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
