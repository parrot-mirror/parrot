#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$

use strict;
use warnings;

use File::Glob;
use File::Spec;

use Test::More;

my $pmc_dir  = File::Spec->catfile(qw( src pmc *.pmc ));
my @pmcs     = grep { contains_pccmethod($_) } glob($pmc_dir);
my $find_pmc = join( '|', map { s/\.pmc/\.dump/; $_ } @pmcs );
# need extra "\" on Windows
$find_pmc =~ s/\\/\\\\/g if $^O eq 'MSWin32';
my $find_rx  = qr/^($find_pmc) : (.*)/;

open( my $fh, '<', 'Makefile' ) or die "Can't read Makefile: $!\n";

plan( tests => scalar @pmcs );

while (<$fh>) {
    next unless /$find_rx/;
    my ($file) = $1;
    my ($dependencies) = $2;

    my $has_dep = 0;
    if ( $dependencies =~ /PCCMETHOD\.pm/ ) {
        $has_dep = 1;
    }

    ok( $has_dep, "$file should mark PCCMETHOD.pm dependency in Makefile" );
}

sub contains_pccmethod {
    my $file = shift;
    open( my $fh, '<', $file ) or die "Can't read '$file': $!\n";

    local $_;
    while (<$fh>) {
        next unless /PCCMETHOD/;
        return 1;
    }

    return;
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
