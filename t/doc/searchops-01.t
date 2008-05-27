#! perl
# Copyright (C) 2001-2005, The Perl Foundation.
# $Id$

use strict;
use warnings;
use Test::More tests =>  5;
use lib qw( ./lib );
use IO::CaptureOutput qw( capture );
use Parrot::Docs::SearchOps qw(
    search_all_ops_files
    help
);

{
    my ($stdout, $stderr);
    capture(
        \&help,
        \$stdout,
        \$stderr,
    );
    like($stdout,
        qr/^\s*perl\stools\/docs\/search-ops\.pl.*?ops_pattern/s,
        "Got expected start to help message",
    );
    like($stdout,
        qr/Given a valid Perl 5 regex as an argument/s,
        "Got expected line from body of help message",
    );
}

my $wrap_width = 70;
my $opsdir = q{t/doc/searchops};

{
    my $pattern = q{load};
    my $total_identified;
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
    is($total_identified, 3, "Got expected total number of ops for $pattern");
}

=head1 NAME

t/doc/searchops-01.t - test subroutines used in tools/docs/search-ops.pl

=head1 SYNOPSIS

    % prove t/doc/searchops-01.t

=head1 DESCRIPTION

This file tests the basic operation of Parrot::Docs::SearchOps and
demonstrates that it will match patterns in more than one file.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

