#! perl
# Copyright (C) 2001-2005, The Perl Foundation.
# $Id$

use strict;
use warnings;
use File::Temp qw( tempdir );
use Test::More tests =>  5;
use lib qw( ./lib ./t/tools/dev/searchops );
use IO::CaptureOutput qw( capture );
use Parrot::SearchOps qw(
    search_all_ops_files
    help
);
use samples qw( $core $debug $mangled $string );

my %samples = (
    core    => { text => $core,      file => q|core.ops|      },
    debug   => { text => $debug,     file => q|debug.ops|     },
    mangled => { text => $mangled,   file => q|mangled.ops|   },
    string  => { text => $string,    file => q|string.ops|    },
);

{
    my ($stdout, $stderr);
    capture(
        \&help,
        \$stdout,
        \$stderr,
    );
    like($stdout,
        qr/^\s*perl\stools\/dev\/search-ops\.pl.*?ops_pattern/s,
        "Got expected start to help message",
    );
    like($stdout,
        qr/Given a valid Perl 5 regex as an argument/s,
        "Got expected line from body of help message",
    );
}

my $wrap_width = 70;
my $opsdir = q{t/tools/dev/searchops};

{
    my $tdir = tempdir();
    foreach my $g (keys %samples) {
        open my $IN, '>', qq{$tdir/$samples{$g}{file}}
            or die "Unable to open $samples{$g}{file} for writing";
        print $IN $samples{$g}{text};
        close $IN or die "Unable to close $samples{$g}{file} after writing";
    }
    my $pattern = q{load};
    my $total_identified;
    my ($stdout, $stderr);
    capture(
        sub { $total_identified = search_all_ops_files(
                $pattern, $wrap_width, $tdir ); },
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
    is($total_identified, 3, "Got expected total number of ops for $pattern");
}

=head1 NAME

t/tools/dev/searchops-01.t - test subroutines used in tools/dev/search-ops.pl

=head1 SYNOPSIS

    % prove t/tools/dev/searchops-01.t

=head1 DESCRIPTION

This file tests the basic operation of Parrot::SearchOps and
demonstrates that it will match patterns in more than one file.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

