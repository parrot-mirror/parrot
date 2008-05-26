#! perl
# Copyright (C) 2001-2005, The Perl Foundation.
# $Id$

use strict;
use warnings;
use Cwd;
use File::Basename;
use File::Copy;
use File::Temp qw( tempdir );
use Test::More qw(no_plan); # tests =>  1;
use lib qw( ./lib );
use IO::CaptureOutput qw( capture );
use Parrot::Docs::SearchOps qw(
    search_all_ops_files
    Usage
);

{
    my ($stdout, $stderr);
    capture(
        \&Usage,
        \$stdout,
        \$stderr,
    );
    like($stdout,
        qr/^\s*tools\/docs\/search-ops\.pl\ssome_ops_pattern/,
        "Got expected start to usage message",
    );
}

my $cwd = cwd();
{
    my @pseudo_ops = glob("t/doc/searchops/*.ops"); 
    my $tdir = tempdir();
    for my $p (@pseudo_ops) {
        my $base = basename($p);
        ok( ( copy $p, qq{$tdir/$base} ),
            "Able to copy $base to set up testing");
    }
    my $pattern = q{load};
    my $wrap_width = 70;
    my $opsdir = $tdir;
    my $total_identified;
    
    {
        my ($stdout, $stderr);
        capture(
            sub { $total_identified = search_all_ops_files(
                    $pattern, $wrap_width, $opsdir ); },
            \$stdout,
            \$stderr,
        );
        like($stdout,
            qr/pseudo-core\.ops.*?\(2 matches\).*?pseudo-debug\.ops.*?\(1 match\)/s,
            "Got expected output",
        );
        like($stdout,
            qr/load_bytecode.*?loadlib.*?debug_load/s,
            "Got expected output",
        );
        is($total_identified, 3, "Got expected total number of ops");
    }
}

=head1 NAME

t/doc/searchops-01.t - test subroutines used in tools/docs/search-ops.pl

=head1 SYNOPSIS

    % prove t/doc/searchops-01.t

=head1 DESCRIPTION

TK

=cut


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
