#! perl
# Copyright (C) 2001-2005, The Perl Foundation.
# $Id$

use strict;
use warnings;
use Test::More tests =>  2;
use lib qw( ./lib );
use IO::CaptureOutput qw( capture );
use Parrot::Docs::SearchOps qw(
    search_all_ops_files
);

my $wrap_width = 70;
my $opsdir = q{t/doc/searchops};

{
    my $pattern = q{chopn};
    my $total_identified;
    my ($stdout, $stderr);
    capture(
        sub { $total_identified = search_all_ops_files(
                $pattern, $wrap_width, $opsdir ); },
        \$stdout,
        \$stderr,
    );
    unlike($stdout, qr/NAME/,
        "Badly formtted entry excluded from display, as expected");
    is($total_identified, 2, "Got expected total number of ops for $pattern");
}

=head1 NAME

t/doc/searchops-03.t - test subroutines used in tools/docs/search-ops.pl

=head1 SYNOPSIS

    % prove t/doc/searchops-03.t

=head1 DESCRIPTION

This test demonstrates that an .ops file with a C<=head1 NAME> paragraph not
followed by another paragraph will not print the 'NAME' paragraph.

=cut
