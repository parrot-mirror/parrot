#! perl
# $Id$
package main;
use strict;
use warnings;
use lib ( qw| lib | );
use Parrot::Manifest::Files;
use Parrot::Manifest::Skip;

my script = $0;

my $mani = Parrot::Manifest::Files->new($script);
$mani->prepare_manifest();
$mani->print_manifest();

my $skip = Parrot::Manifest::Skip->new($script);
$skip->prepare_manifest_skip();
$skip->print_manifest_skip();

=head1 NAME

tools/dev/mk_manifest_and_skip.pl - Recreate MANIFEST and MANIFEST.SKIP

=head1 SYNOPSIS

    % perl tools/dev/mk_manifest_and_skip.pl

=head1 DESCRIPTION

Recreates MANIFEST and MANIFEST.SKIP from the svn/svk directories.
So far tested with svn 1.2.0, svn 1.4.2, and svk 1.08.

=head1 SEE ALSO

Parrot::Manifest, Parrot::Manifest::Files, Parrot::Manifest::Skip.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
