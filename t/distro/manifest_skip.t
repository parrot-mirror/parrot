#! perl
# Copyright (C) 2001-2005, The Perl Foundation.
# $Id$

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More tests => 2;

use Data::Dumper;
use File::Find qw(find);
use ExtUtils::Manifest;
# use Parrot::Distribution;
use Parrot::Distribution::ManifestSkip qw( gen_manifest_skip );
use Parrot::Revision;

=head1 NAME

t/distro/manifest_skip.t - sanity check the MANIFEST.SKIP file

=head1 SYNOPSIS

    % prove t/distro/manifest_skip.t

=head1 DESCRIPTION

Checks that the distribution and the MANIFEST.SKIP file agree.

=cut

my $manifest_skip = $ExtUtils::Manifest::MANIFEST . '.SKIP';

SKIP:
{

    # check that MANIFEST.SKIP is in sync with svn:ignore
    # An new MANIFEST.SKIP can be generated with tools/dev/gen_manifest_skip.pl
    skip 'Not a working copy' => 2
        unless ( $Parrot::Revision::svn_entries || `svk ls .` );

    diag "this may take a while...";

#    my $dist = Parrot::Distribution->new();
#    my @from_svn = grep { $_ && $_ !~ m/^#/ } @{ $dist->gen_manifest_skip() };
    my @from_svn = grep { $_ && $_ !~ m/^#/ } @{ gen_manifest_skip() };
    unshift @from_svn, '\B\.svn\b', '^debian$', '^debian/';    # added in gen_manifest_skip.pl
    open( *MANIFEST_SKIP, '<', $manifest_skip ) or die "Can't open $manifest_skip: $!";
    my @from_manifest_skip = grep { $_ ne "\n" && $_ !~ m/^#/ } (<*MANIFEST_SKIP>);
    close(*MANIFEST_SKIP);
    chomp(@from_manifest_skip);
    my ( $svn_miss, $manifest_skip_miss ) =
        list_diff( \@from_svn, \@from_manifest_skip );

    local $" = "\n\t"; # $"

    ok( !@$svn_miss, 'all files in MANIFEST.SKIP are also in svn:ignore' )
        or diag("File in MANIFEST.SKIP but not ignored by SVN:\n\t@$svn_miss");
    ok( !@$manifest_skip_miss, 'all svn:ignore files are in MANIFEST.SKIP' )
        or diag("Files ignored by SVN but not in MANIFEST.SKIP:\n\t@$manifest_skip_miss");
}

exit;


sub list_diff {
    my ( $a, $b ) = @_;

    my %elem;
    grep { $elem{$_}++ } @$a;
    grep { $elem{$_}-- } @$b;

    return ( [ sort grep { $elem{$_} < 0 } keys %elem ],
        [ sort grep { $elem{$_} > 0 } keys %elem ] );
}


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
