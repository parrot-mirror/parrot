#! perl
# Copyright (C) 2001-2009, The Perl Foundation.
# $Id$

use strict;
use warnings;

use Carp;
use Test::More;
use lib qw( lib );
BEGIN {
    eval 'use Parrot::Test::Pod::Util';
    if ($@) {
        plan skip_all => 'Prerequisites for Parrot::Test::Pod::Util not satisfied';
        exit;
    }
}

plan tests => 2;

my $self = Parrot::Test::Pod::Util->new( {
    argv => [ @ARGV ],
} );
ok( defined $self, "Parrot::Test::Pod::Util returned defined value" );

my $need_testing_ref = $self->identify_files_for_POD_testing( {
    second_analysis => 'oreilly_summary_malformed',
} );

my @empty_description;

foreach my $file ( @{ $need_testing_ref } ) {
    # check DESCRIPTION section on valid POD files
    if ( file_pod_ok($file) and empty_description($file) ) {
        push @empty_description, $file;
    }
}

my $empty_description_files = join( "\n", sort @empty_description);
my $nempty_description      = scalar( @empty_description );

TODO: {
    local $TODO = "not quite done yet";
    is(
        $empty_description_files,
        q{},
        'All Pod files have non-empty DESCRIPTION sections'
    );
}

diag("\nFound $nempty_description files without DESCRIPTION sections.\n")
    if $nempty_description;

#################### SUBROUTINES ####################

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

=head1 t/codingstd/pod_description.t

Identify files lacking 'Description' section in their POD

=head2 SYNOPSIS

    # test all files
    % prove t/codingstd/pod_description.t

    # test specific files
    % perl t/codingstd/pod_description.t perl_module.pm perl_file.pl

=head2 DESCRIPTION

Tests the Pod syntax for all files listed in F<MANIFEST> and
F<MANIFEST.generated> that appear to contain Pod markup. If any files
contain with valid POD markup lack C<DESCRIPTION> sections, list them.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
