#! perl
# Copyright (C) 2001-2005, The Perl Foundation.
# $Id$

use strict;
use warnings;
use File::Temp qw( tempdir );
use Test::More tests =>  2;
use lib qw( ./lib ./t/doc/searchops );
use IO::CaptureOutput qw( capture );
use Parrot::Docs::SearchOps qw(
    search_all_ops_files
);
use samples qw( $core $debug $mangled $string );

my %samples = (
    core    => { text => $core,      file => q|core.ops|      },
    debug   => { text => $debug,     file => q|debug.ops|     },
    mangled => { text => $mangled,   file => q|mangled.ops|   },
    string  => { text => $string,    file => q|string.ops|    },
);

my $wrap_width = 70;
my $opsdir = q{t/doc/searchops};

{
    my $tdir = tempdir();
    foreach my $g (keys %samples) {
        open my $IN, '>', qq{$tdir/$samples{$g}{file}}
            or die "Unable to open $samples{$g}{file} for writing";
        print $IN $samples{$g}{text};
        close $IN or die "Unable to close $samples{$g}{file} after writing";
    }
    my $pattern = q{concat};
    my $total_identified;
    my ($stdout, $stderr);
    capture(
        sub { $total_identified = search_all_ops_files(
                $pattern, $wrap_width, $tdir ); },
        \$stdout,
        \$stderr,
    );
    unlike($stdout, qr/n_concat\(foobar/,
        "Badly formtted entry excluded from display, as expected");
    is($total_identified, 8, "Got expected total number of ops for $pattern");
}

=head1 NAME

t/doc/searchops-02.t - test subroutines used in tools/docs/search-ops.pl

=head1 SYNOPSIS

    % prove t/doc/searchops-02.t

=head1 DESCRIPTION

This test demonstrates that a pattern such as C<concat> will pick up both
C<concat> and C<n_concat> functions.  It also demonstrates that an .ops file
with a function header not followed by a description will not print the
header.

=cut


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
