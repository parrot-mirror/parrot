# $Id$

require Parrot::Test;

package Parrot::Test::Regex;

use strict;
use warnings;

use Data::Dumper;
use File::Basename;
use File::Spec::Functions;
use Parrot::Config;

=head1 NAME

Test/Regex.pm - Testing routines specific to 'regex'.

=head1 DESCRIPTION

Does the same a 'languages/regex/test.pl'

=cut

my $PARROT_EXE = File::Spec->catfile( File::Spec->updir(), $PConfig{test_prog} );

sub run_spec {
    my ($spec_fh) = @_;

    my $pattern = <$spec_fh>;
    chomp($pattern);

    $_ = <$spec_fh>;
    my @spec;
    while (1) {
        my ( $input, $output );

        last                  if !defined $_;
        die "INPUT: expected" if !/^INPUT:/;

        # Gather input, look for OUTPUT:
        $input = q{};
        undef $output;
        while (<$spec_fh>) {
            $output = q{}, last if /^OUTPUT:/;
            $input .= $_;
        }
        chomp($input);
        die "EOF during INPUT section" if !defined($output);

        # Gather output
        while (<$spec_fh>) {
            last if /^INPUT:/;
            $output .= $_;
        }

        push @spec, { input => $input, output => $output };
    }

    Test::More::plan( tests => scalar(@spec) );

    generate_regular($pattern);

    foreach (@spec) {
        process( $_->{input}, $_->{output} );
    }

    return 0;
}

sub generate_regular_pir {
    my ( $filename, $pattern ) = @_;
    my $PIR;
    open( $PIR, '>', $filename ) or die "create $filename: $!";

    my $ctx = {};
    my $trees = Regex::expr_to_tree( $pattern, $ctx, DEBUG => 0 );

    my $driver = Regex::Driver->new( 'pir', emit_main => 1 );

    print $PIR <<"END";
# Regular expression test
# Generated by $0
# Pattern >>$pattern<<

END

    $driver->output_header($PIR);

    for my $tree (@$trees) {
        $driver->output_rule( $PIR, '_regex', $tree, $ctx, DEBUG => 0 );
    }

    close $PIR;
}

sub generate_pbc {
    my ( $pir, $pbc ) = @_;
    my $status = system( $PARROT_EXE, '-o', $pbc, $pir );
    if ( !defined($status) || $status ) {
        die "assemble failed with status " . ( $? >> 8 );
    }
}

sub generate_regular {
    my ($pattern) = @_;

    generate_regular_pir( 'test_regex.pir', $pattern );
    generate_pbc( 'test_regex.pir', 'test_regex.pbc' );
}

sub process {
    my ( $input, $output ) = @_;

    my $actual_output = `$PARROT_EXE test_regex.pbc '$input'`;
    Test::More::is( $actual_output, $output );

    return;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
