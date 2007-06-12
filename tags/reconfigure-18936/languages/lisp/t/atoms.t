# $Id$

=head1 NAME

lisp/t/atoms.t - tests for Parrot Common Lisp

=head1 DESCRIPTION

Basic types.

=cut

# pragmata
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib", "$FindBin::Bin/../../../lib";

# core Perl modules
use Test::More; 

# Parrot modules
use Parrot::Test;

my @test_cases = (
    [ q{ 1 },
      1,
      'integer 1'
    ],
    [ q{ -2 },
      -2,
      'integer -2'
    ],
    [ q{ (- 3) },
      -3,
      '3 negated'
    ],
    [ q{ 0 },
      0,
      'zero'
    ],
    [ q{ nil },
      'NIL',
      'false'
    ],
    [ q{ t },
      'T',
      'true'
    ],
);

Test::More::plan( tests => scalar @test_cases );

foreach ( @test_cases )
{
     my ( $code, $out, $desc ) = @{ $_ };

     language_output_is( 'Lisp', "( print $code )", $out . "\n", $desc );
}
