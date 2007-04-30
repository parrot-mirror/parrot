#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 02-revision.t

use strict;
use warnings;

use Test::More tests =>  7;
use Carp;
use_ok( 'Cwd' );
use_ok( 'File::Copy' );
use_ok( 'File::Temp', qw| tempdir | );
use lib qw( . lib ../lib ../../lib );
use Parrot::Revision;

my ($current, $config);

# Case 1:  DEVELOPING exists; Parrot::Config available.
my $reason =
    'Either file DEVELOPING does not exist or configuration has not completed (as evidenced by non-existence of Parrot::Config::Generated';
SKIP: {
    skip $reason, 3 if (
        (not -e 'DEVELOPING')
        or
        (not -e q{lib/Parrot/Config/Generated.pm} )
    );
    $current = $Parrot::Revision::current;
    like($current, qr/^\d+$/, "current revision is all numeric");
    $config = $Parrot::Revision::config;
    like($config, qr/^\d+$/, "current revision is all numeric");
    is($current, $config, "current and config are identical");
} # end SKIP block

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

02-revision.t - test Parrot::Revision

=head1 SYNOPSIS

    % prove t/postconfigure/02-revision.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test aspects of Parrot::Revision
(F<lib/Parrot/Revision.pm>) which presume that configuration has been
completed.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
