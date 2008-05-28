#! perl
# Copyright (C) 2001-2005, The Perl Foundation.
# $Id$

use strict;
use warnings;
use File::Temp qw( tempdir );
use Test::More tests =>  1;
use lib qw( ./lib ./t/tools/dev/searchops );
use IO::CaptureOutput qw( capture );
use Parrot::SearchOps qw(
    search_all_ops_files
);
use samples qw( $core $debug $mangled $string );

my $wrap_width = 70;
my $opsdir = q{t/tools/dev/searchops};

my %samples = (
    core    => { text => $core,      file => q|core.ops|      },
    debug   => { text => $debug,     file => q|debug.ops|     },
    string  => { text => $string,    file => q|string.ops|    },
);

{
    my $tdir = tempdir();
    foreach my $g (keys %samples) {
        open my $IN, '>', qq{$tdir/$samples{$g}{file}}
            or die "Unable to open $samples{$g}{file} for writing";
        print $IN $samples{$g}{text};
        close $IN or die "Unable to close $samples{$g}{file} after writing";
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

t/tools/dev/searchops-04.t - test subroutines used in tools/dev/search-ops.pl

=head1 SYNOPSIS

    % prove t/tools/dev/searchops-04.t

=head1 DESCRIPTION

This test demonstrates what happens when the C<--all> option is provided to
F<tools/dev/search-ops.pl>.

=cut
