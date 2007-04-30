#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 03-revision_no_DEVELOPING.t

use strict;
use warnings;

use Test::More tests => 10;
use Carp;
use_ok( 'Cwd' );
use_ok( 'File::Copy' );
use_ok( 'File::Temp', qw| tempdir | );
use lib qw( . lib ../lib ../../lib );

my ($current, $config);

# Case 2:  DEVELOPING's non-existence is faked;  Parrot::Config available. #'
my $cwd = cwd();
my $reason =
    'Either file DEVELOPING does not exist or configuration has not completed (as evidenced by non-existence of Parrot::Config::Generated'; 

SKIP: {
    skip $reason, 6 if (
        (not -e 'DEVELOPING')
        or
        (not -e q{lib/Parrot/Config/Generated.pm} )
    );
    ok(move('DEVELOPING', 'xDEVELOPING'), "temporarily renaming DEVELOPING");
    require Parrot::Revision;
    no warnings qw(once);
    $current = $Parrot::Revision::current;
    like($current, qr/^\d+$/, "current revision is all numeric");
    is($current, 0,
        "If DEVELOPING does not exist (release version), \$current is set to zero.");
    $config = $Parrot::Revision::config;
    use warnings;
    like($config, qr/^\d+$/, "current revision is all numeric");
    isnt($current, $config, "current and config differ");
    ok(move('xDEVELOPING', 'DEVELOPING'), "restoring DEVELOPING");
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

03-revision_no_DEVELOPING.t - test Parrot::Revision

=head1 SYNOPSIS

    % prove t/postconfigure/03-revision_no_DEVELOPING.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test Parrot::Revision (F<lib/Parrot/Revision.pm>).

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
