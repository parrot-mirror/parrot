#! perl
# Copyright (C) 2001-2009, The Perl Foundation.
# $Id$

use strict;
use warnings;

use Carp;
use Test::More;
use ExtUtils::Manifest qw(maniread);
use Storable qw(nstore retrieve);
use lib qw( lib );
use Parrot::Config;
use Parrot::Test::Pod::Util qw(
    identify_files_for_POD_testing
);

BEGIN {
    eval 'use Pod::Simple';
    if ($@) {
        plan skip_all => 'Pod::Simple not installed';
        exit;
    }
}

plan tests => 2;

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

my (@failed_syntax, @empty_description);

foreach my $file ( @{ $need_testing_ref } ) {
    # skip files with valid POD
    if (file_pod_ok($file)) {
        #check DESCRIPTION section on valid POD files
        push @empty_description, $file if empty_description($file);
    }
    else {
        # report whatever is not skipped
        push @failed_syntax, $file;
    }
}

my $bad_syntax_files        = join( "\n", @failed_syntax );
my $empty_description_files = join( "\n", @empty_description);
my $nempty_description      = scalar( @empty_description );

# only ok if everything passed
is( $bad_syntax_files, q{}, 'Pod syntax correct' );

TODO: {
    local $TODO = "not quite done yet";
    is(
        $empty_description_files,
        q{},
        'All Pod files have non-empty DESCRIPTION sections'
    );
}

diag("You should use podchecker to check the failed files.\n")
    if $bad_syntax_files;

diag("Found $nempty_description files without DESCRIPTION sections.\n")
    if $nempty_description;

#################### SUBROUTINES ####################

sub oreilly_summary_malformed {
    my ($files_needing_analysis, $build_dir) = @_;
    my $sto = q{.pod_examinable_oreilly_summary_malformed.sto};
    if ( -e $sto ) {
        eval { $files_needing_analysis = retrieve($sto) };
        if ($@) {
            croak "$sto exists on disk but could not retrieve from it";
        }
        else {
            return $files_needing_analysis;
        }
    }
    else {
        SECOND_FILE: foreach my $file ( keys %{ $files_needing_analysis } ) {
            my $full_file = qq|$build_dir/$file|;
        
            # Skip the book, because it uses extended O'Reilly-specific POD
            if ($full_file =~ m{docs/book/}) {
                delete $files_needing_analysis->{ $file };
                next SECOND_FILE;
            }
        
            # skip POD generating scripts
            if ($full_file =~ m/ops_summary\.pl/) {
                delete $files_needing_analysis->{ $file };
                next SECOND_FILE;
            }
        
            # skip file which includes malformed POD for other testing purposes
            if ($full_file =~ m{
                    t/tools/dev/searchops/samples\.pm
                    |
                    languages/pod/test\.pod
                }x
            ) {
                delete $files_needing_analysis->{ $file };
                next SECOND_FILE;
            }
        }
    }
    nstore $files_needing_analysis, $sto;
    return $files_needing_analysis;
}

# Pulled from Test::Pod
sub file_pod_ok {
    my $file    = shift;
    my $checker = Pod::Simple->new;

    $checker->output_string( \my $trash );      # Ignore any output
    $checker->parse_file($file);

    return !$checker->any_errata_seen;
}

sub empty_description {
    my $file = shift;

    use Pod::Simple::PullParser;
    my $parser = Pod::Simple::PullParser->new;
    $parser->set_source( $file );
    my $description = $parser->get_description;

    if ( $description =~ m{^\s*$}m ) {
        return 1;
    }

    return 0;
}


=head1 NAME

t/codingstd/pod.t - Pod document syntax tests

=head1 SYNOPSIS

    # test all files
    % prove t/codingstd/pod.t

    # test specific files
    % perl t/codingstd/pod.t perl_module.pm perl_file.pl

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
