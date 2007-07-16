#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id: 02-add.t 19892 2007-07-15 14:26:43Z jkeenan $
# 02-add.t

use strict;
use warnings;

use Test::More qw(no_plan); # tests => 11;
use Carp;
use Cwd;
use File::Copy;
use File::Temp qw( tempdir );
use lib ( qw| lib | );
use_ok('Parrot::Manifest');

=pod

Plan:  To test whether the module correctly determines whether to regenerate
MANIFEST.SKIP or not, we will switch to a tempdir, create a dummy SKIP in that
dir, then hijack the proposed patterns to either add or subtract a pattern.

Similarly, we will create a dummy MANIFEST in a tempdir, then hijack
@status_output to add either an 'A' or a 'D' (or any other Subversion status
code).

=cut

my $script = $0;
my $mani = Parrot::Manifest->new( {
    script      => $script,
} );
isa_ok($mani, 'Parrot::Manifest');

pass("Completed all tests in $0");


################### DOCUMENTATION ###################

=head1 NAME

02-add.t - test C<Parrot::Manifest> constructor

=head1 SYNOPSIS

    % prove t/manifest/02-add.t

=head1 DESCRIPTION

The files in this directory test the publicly callable methods of
F<lib/Parrot/Manifest.pm> and packages which inherit from that package.

F<02-add.t> tests whether the Parrot::Manifest methods correctly add to the
MANIFEST those files scheduled for addition to the repository but not yet
committed.

=head1 AUTHOR

James E Keenan (jkeenan@cpan.org)

=head1 SEE ALSO

Parrot::Manifest, Parrot::Manifest::Files, Parrot::Manifest::Skip,
F<tools/dev/mk_manifest_and_skip.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

