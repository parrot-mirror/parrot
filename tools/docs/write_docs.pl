#! perl
# Copyright (C) 2001-2003, The Perl Foundation.
# $Id$

=head1 NAME

tools/docs/write_docs.pl - Write HTML documentation

=head1 SYNOPSIS

    % perl tools/docs/write_docs.pl [--silent] [--delete]

=head1 DESCRIPTION

This script writes the HTML documentation for Parrot.

=cut

use strict;
use warnings;
use lib 'lib';
use Getopt::Long;
use Parrot::Docs::Section::Parrot;

my ($silent, $delete);

die unless GetOptions('silent' => \$silent, 'delete' => \$delete);

my $docs = Parrot::Docs::Section::Parrot->new;

$docs->write_docs($silent, $delete);

exit 0;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
