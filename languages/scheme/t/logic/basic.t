#! perl
# $Id$

# Copyright (C) 2001-2007, The Perl Foundation.

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";

use Test::More tests => 141;

use Parrot::Test;

###
### if
###

language_output_is( 'Scheme', <<'CODE', 1, 'basic if - Fail' );
(write (if (= 1 1) 1 0))
CODE

language_output_is( 'Scheme', <<'CODE', '"0 is true"', '0 is true' );
(write (if 0 "0 is true" "0 is false" ))
CODE

language_output_is( 'Scheme', <<'CODE', 1, 'basic if - Pass' );
(write (if (= 0 1) 0 1))
CODE

language_output_is( 'Scheme', <<'CODE', 7, 'slightly more complex if' );
(write (if (= 9 9) 7 -23))
CODE

# base types
# Every object is of exactly one base type
{
    # my @base_types 
    #     = qw( boolean pair symbol char string vector procedure null );
    my @base_types 
         = qw( boolean number string );
    my %object = (
        boolean    => [ q{#t},
                        q{#f},
                        q{(boolean? "hello")},
                      ],
        number     => [ q{-2},
                        q{-1},
                        q{-0},
                        q{0},
                        q{+0},
                        q{1},
                        q{+1},
                        q{2},
                        q{+2},
                        q{-0.0},
                        q{-0.1},
                        q{0.0},
                        q{0.1},
                        q{+0.0},
                        q{+0.1},
                      ],
        string     => [ q{"hello"},
                        q{""},
                      ],
    );
  
    foreach my $predicate ( @base_types ) {
        foreach my $expected_type ( @base_types ) {
            foreach my $object ( @{ $object{$expected_type} } ) {
                my ( $code, $expected );

                $code     = qq{ (write ($predicate? $object)) };
                $expected = $predicate eq $expected_type ?
                                '#t'
                                :
                                '#f';
                language_output_is( 'Scheme', $code, $expected, $code );

                $code     = qq{ (write (if ($predicate? $object) "true" "false")) };
                $expected = $predicate eq $expected_type ?
                                '"true"'
                                :
                                '"false"';
                language_output_is( 'Scheme', $code, $expected, $code );
            }
        }
    }
}

###
### and
###

language_output_is( 'Scheme', <<'CODE', 0, 'and 0' );
(write (and 0))
CODE

language_output_is( 'Scheme', <<'CODE', 1, 'and 1' );
(write (and 1))
CODE

language_output_is( 'Scheme', <<'CODE', '#t', 'and many #t' );
(write (and #t #t #t #t #t #t 2 #t 1 #t))
CODE

language_output_is( 'Scheme', <<'CODE', 3, 'basic and' );
(write (and 1 3))
CODE

language_output_is( 'Scheme', <<'CODE', 1, 'basic and' );
(write (and 0 1))
CODE

language_output_is( 'Scheme', <<'CODE', 0, 'basic and' );
(write (and 3 2 1 0))
CODE

language_output_is( 'Scheme', <<'CODE', 6, 'basic and' );
(write (and 1 2 3 4 5 6))
CODE

language_output_is( 'Scheme', <<'CODE', 4, 'and, 0 is true' );
(write (and 0 4))
CODE

language_output_is( 'Scheme', <<'CODE', '#f', 'and, 0 is true' );
(write (and 1 2 #f 4))
CODE

###
### or
###

language_output_is( 'Scheme', <<'CODE', 1, 'basic or - Pass' );
(write (or 1 1))
CODE

language_output_is( 'Scheme', <<'CODE', 0, 'basic or - Fail' );
(write (or 0 0))
CODE

###
### not
###

language_output_is( 'Scheme', <<'CODE', '#f', 'not 1' );
(write (not 1))
CODE

language_output_is( 'Scheme', <<'CODE', '#t', 'not #f' );
(write (not #f))
CODE

language_output_is( 'Scheme', <<'CODE', '#f', 'not 0' );
(write (not 0))
CODE

language_output_is( 'Scheme', <<'CODE', '#f', 'not #t' );
(write (not #t))
CODE

language_output_is( 'Scheme', <<'CODE', '#f', 'not true expression' );
(write (not (= 42 (* 21 2))))
CODE

language_output_is( 'Scheme', <<'CODE', '#t', 'not false expression' );
(write (not (= 43 (* 21 2))))
CODE

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
