#! perl
# Copyright (C) 2001-2009, The Perl Foundation.
# $Id$

use strict;
use warnings;

use Carp;
use Test::More;
use ExtUtils::Manifest qw(maniread);
use lib qw( lib );
use Parrot::Config;
use Parrot::Test::Pod::Util qw(
    identify_files_for_POD_testing
    oreilly_summary_malformed
);

BEGIN {
    eval 'use Pod::Simple';
    if ($@) {
        plan skip_all => 'Pod::Simple not installed';
        exit;
    }
}

plan tests => 1;

# RT #44437 this should really be using src_dir instead of build_dir but it
# does not exist (yet)
my $build_dir    = $PConfig{build_dir};
#print STDERR $build_dir, "\n";

croak "Cannot run test if build_dir does not yet exist"
    unless -d $build_dir;
croak "Test cannot be run unless MANIFEST exists in build dir"
    unless -f "$build_dir/MANIFEST";
croak "Test cannot be run unless MANIFEST exists in build dir"
    unless -f "$build_dir/MANIFEST.generated";

my $manifest     = maniread("$build_dir/MANIFEST");
my $manifest_gen = maniread("$build_dir/MANIFEST.generated");

my $need_testing_ref = identify_files_for_POD_testing( {
    argv            => [ @ARGV ],
    manifest        => $manifest,
    manifest_gen    => $manifest_gen,
    build_dir       => $build_dir,
    second_analysis => \&oreilly_summary_malformed,
} );

my @failed_syntax;

foreach my $file ( @{ $need_testing_ref } ) {
    # skip files with valid POD;
    # report whatever is not skipped
    unless (file_pod_ok($file)) {
        push @failed_syntax, $file;
    }
}

my $bad_syntax_files        = join( "\n", @failed_syntax );

# only ok if everything passed
is( $bad_syntax_files, q{}, 'Pod syntax correct' );

diag("You should use podchecker to check the failed files.\n")
    if $bad_syntax_files;

#################### SUBROUTINES ####################

# Pulled from Test::Pod
sub file_pod_ok {
    my $file    = shift;
    my $checker = Pod::Simple->new;

    $checker->output_string( \my $trash );      # Ignore any output
    $checker->parse_file($file);

    return !$checker->any_errata_seen;
}

=head1 NAME

t/codingstd/pod_syntax.t - Pod document syntax tests

=head1 SYNOPSIS

    # test all files
    % prove t/codingstd/pod_syntax.t

    # test specific files
    % perl t/codingstd/pod_syntax.t perl_module.pm perl_file.pl

=head1 DESCRIPTION

Tests the Pod syntax for all files listed in F<MANIFEST> and
F<MANIFEST.generated> that appear to contain Pod markup. If any files
contain invalid POD markup, they are reported in the test output.
Use C<podchecker> to ferret out individual issues.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
