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
use Tie::File;
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

my $cwd = cwd();
my $sk = q{MANIFEST.SKIP};
my $print_str = $mani->prepare_manifest_skip();
ok($print_str, "prepare_manifest_skip() returned");

# 1
{
    my $tdir = tempdir( CLEANUP => 1 );
    chdir $tdir or
        croak "Unable to change to temporary directory for testing";
    copy(qq{$cwd/$sk}, qq{$tdir/$sk})
        or croak "Unable to copy $sk to tempdir";
    ok(-f $sk, "$sk found in tempdir");
    my $need_for_skip = $mani->determine_need_for_manifest_skip($print_str);
    ok(! $need_for_skip, "No need to regenerate $sk");
    chdir $cwd or
        croak "Unable to change back from temporary directory after testing";
}

# 2
{
    my $tdir = tempdir( CLEANUP => 1 );
    chdir $tdir or
        croak "Unable to change to temporary directory for testing";
    copy(qq{$cwd/$sk}, qq{$tdir/$sk})
        or croak "Unable to copy $sk to tempdir";
    ok(-f $sk, "$sk found in tempdir");
    my @lines;
    tie @lines, 'Tie::File', qq{$tdir/$sk}
        or croak "Unable to tie to $sk in tempdir";
    for (1..10) {
        if ( defined($lines[-1]) ) {
            pop @lines;
        }
    }
    untie @lines or croak "Unable to untie from $sk";
    my $need_for_skip = $mani->determine_need_for_manifest_skip($print_str);
    ok($need_for_skip, "Need to regenerate $sk");
    ok( $mani->print_manifest_skip($print_str),
        "print_manifest_skip() returned true");
    ok(  -f $sk,
        "$sk has been created in tempdir");
    chdir $cwd or
        croak "Unable to change back from temporary directory after testing";
}

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

