#! perl
# Copyright (C) 2001-2005, The Perl Foundation.
# $Id$

use strict;
use warnings;
use Test::More qw(no_plan); # tests =>  1;
use lib qw( ./lib );
use IO::CaptureOutput qw( capture );
use Parrot::Docs::SearchOps qw(
    Usage
);

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
