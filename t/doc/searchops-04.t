#! perl
# Copyright (C) 2001-2005, The Perl Foundation.
# $Id$

use strict;
use warnings;
use File::Basename;
use File::Copy;
use File::Temp qw( tempdir );
use Test::More tests =>  4;
use lib qw( ./lib );
use IO::CaptureOutput qw( capture );
use Parrot::Docs::SearchOps qw(
    search_all_ops_files
);

my $wrap_width = 70;
my $opsdir = q{t/doc/searchops};

{
    my $tdir = tempdir();
    my @opsfiles = grep { ! /mangled/ } glob("$opsdir/*.ops");
    foreach my $f (@opsfiles) {
        my $base = basename($f);
        ok( (copy $f, qq{$tdir/$base}),
            "Copied file correctly in preparation for testing");
    }
    my $pattern = q{};
    my $total_identified;
    my ($stdout, $stderr);
    capture(
        sub { $total_identified = search_all_ops_files(
                $pattern, $wrap_width, $tdir ); },
        \$stdout,
        \$stderr,
    );
    is($total_identified, 12, "Got expected total number of ops for --all");
}

=head1 NAME

t/doc/searchops-04.t - test subroutines used in tools/docs/search-ops.pl

=head1 SYNOPSIS

    % prove t/doc/searchops-04.t

=head1 DESCRIPTION

This test demonstrates what happens when the C<--all> option is provided to
F<tools/docs/search-ops.pl>.

=cut
