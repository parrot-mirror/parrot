#! perl
# Copyright: 2005 The Perl Foundation.  All Rights Reserved.
# $Id$

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More;
use Parrot::Test tests => 3;
use Parrot::Config;


=head1 NAME

t/examples/library.t - Test examples in F<examples/library>

=head1 SYNOPSIS

	% prove t/examples/library.t

=head1 DESCRIPTION

Test the examples in F<examples/library>.


=head1 SEE ALSO

F<t/examples/japh.t>

=cut


# Set up expected output for examples
my %expected
  = (
    'getopt_demo.pir'        =>  << 'END_EXPECTED',
Hi, I am 'getopt_demo.imc'.

You haven't passed the option '--bool'. This is fine with me.
You haven't passed the option '--string'. This is fine with me.
You haven't passed the option '--integer'. This is fine with me.
All args have been parsed.
END_EXPECTED
   );

while ( my ( $example, $expected ) = each %expected ) {
    example_output_is( "examples/library/$example", $expected );
}

my $PARROT = ".$PConfig{slash}$PConfig{test_prog}";

# For testing md5sum.pir we need to pass a filename
{
    my $md5sum_fn = "examples$PConfig{slash}library$PConfig{slash}md5sum.pir";
    my $sample_fn = "t$PConfig{slash}library$PConfig{slash}perlhist.txt";
    my $sum = `$PARROT $md5sum_fn $sample_fn`;
    is( $sum, "fb171bd1a17bf6cd08d73105ad738a35\t$sample_fn\n", $md5sum_fn );
}

# Testing pcre.imc with a simple pattern, if we have PCRE
my $cmd = ($^O =~ /MSWin32/) ? "pcregrep --version" : "pcre-config --version";
my $has_pcre = Parrot::Test::run_command($cmd, STDERR => '/dev/null') == 0;
SKIP:
{
    skip( "no pcre-config", 1 ) unless $has_pcre;
    my $pcre_fn = "examples$PConfig{slash}library$PConfig{slash}pcre.pir";
    my $test_out = `$PARROT $pcre_fn asdf as`;
    is( $test_out, << 'END_EXPECTED', $pcre_fn );
asdf =~ /as/
1 match(es):
as
END_EXPECTED
};
