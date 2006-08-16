# Copyright (C) 2005-2006, The Perl Foundation.
# $Id$

=head1 NAME

bc/t/basic.t - tests for Parrot bc

=head1 DESCRIPTION

Very basic checks.

=cut

use strict;
use warnings;
use 5.006_001;

use FindBin;
use lib "$FindBin::Bin/../lib", "$FindBin::Bin/../../../lib";

use Parrot::Config (); 
use Parrot::Test;
use Test::More;

# A little helper to make setting up tests easier
sub run_tests {
    my ( $tests ) = @_;

    foreach ( @{$tests} ) {
        die "invalid test" unless ref( $_ ) eq 'ARRAY';
        die "invalid test" unless scalar(@{$_}) >= 2 || scalar(@{$_}) <= 5;
        my ( $bc_code, $expected, $desc, %options ) = @{$_};

        # bc should not keep waiting for input 
        $bc_code  .= "\nquit\n"; 

        # expected input can be set up as array reference
        if ( ref $expected ) {
            die "expected ARRAY reference" unless ref( $expected ) eq 'ARRAY';
            $expected = join( "\n", @{$expected} );
        }

        # use default description when '' or undef is set up
        $desc ||= "bc: $bc_code";

        language_output_is( 'bc', $bc_code, $expected . "\n", $desc, %options );
    }
}

my @tests = (
       # single non-negative integer 
       [ '1', [ 1 ], 'positive int 1',                       with_antlr3 => 1  ],
       [ '0', [ 0 ], 'zero',                                 with_antlr3 => 1  ],
       [ '2', [ 2 ], 'positive int',                         with_antlr3 => 1  ],
       [ '12345678', [ 12345678 ], 'another positive int',   with_antlr3 => 1  ],

       # single negative integer 
       [ '-1', [ -1 ], 'negative one',                       with_antlr3 => 1  ],
       [ '-12345678', [ -12345678 ], 'another negative int', with_antlr3 => 1  ],

       # multiple lines
       [ "1\n2", [ 1, 2 ], 'two lines',                      with_antlr3 => 1  ],
       [ "1\n2\n3\n4\n\n5\n6\n7", [ 1, 2, 3, 4, 5, 6, 7 ], 'seven lines', with_antlr3 => 1 ],

       # comments 
       [ '/* */7', 7, 'one line comment',                    with_antlr3 => 1  ],
       [ "/* line1 \n line2 \n line 3 */    2  ", 2, 'multi line comment', with_antlr3 => 1 ],
       [ "/* line1 \n line2 \n line 3 */   -3  ", -3, 'multi line comment', with_antlr3 => 1 ],

       # Strings 
       [ qq{1;2;"asdf"   ;  3    }, [ 1, 2, 'asdf3' ], 'string', with_antlr3 => 1 ],
       [ q{1;2;"'a's'd'f'"   ;  3    }, [ 1, 2, "'a's'd'f'3" ], 'string with embedded single quote', with_antlr3 => 1 ],
       [ q{1;2;"as\df"   ;  3    }, [ 1, 2, 'as\df3' ], 'string with embedded backslash', with_antlr3 => 1 ],
       [ qq{1;2;" asdf\n  jklm\n   rtzu\n"   ;  3    }, [ 1, 2, ' asdf', '  jklm', '   rtzu', 3 ], undef, with_antlr3 => 1 ],

       # empty lines
       [ "\n-1", '-1', 'single newline', with_antlr3 => 1, ],
       [ "        \n    \n  -  1   \n    2", [ -1, 2 ], 'multiple empty lines', with_antlr3 => 1, ],

       # positive and negative Integers
       #[ '+1', '1', 'unary +', ], Surprise, there is no unary + in POSIX bc
       [ '-1', '-1', 'unary -', with_antlr3 => 1, ],
       [ '0', '0', '0 without sign',       with_antlr3 => 1, ],
       [ '-0', '0', 'negative 0', with_antlr3 => 1, ],
       [ '1', '1', undef, with_antlr3 => 1, ],
       [ '-10', '-10', undef, with_antlr3 => 1, ],
       [ '123456789', '123456789', undef, with_antlr3 => 1, ],
       [ '-123456789', '-123456789', undef, with_antlr3 => 1, ],
       [ '0001', '1', undef, with_antlr3 => 1, ],
       [ '-0001', '-1', undef, with_antlr3 => 1, ],

       # floats
       [ '.1 + 1', '1.1', 'float with leading dot', with_antrl3 => 1, ],
       [ '-1.0001', '-1.0001', undef, with_antlr3 => 0, ], 
       [ '1.2', '1.2', undef, with_antlr3 => 1, ],     # prints 1.200000 in ANTLR3 version
       [ '1.2 *2 - 2.0 + 3', '3.4', undef, with_antlr3 => 1, ],

       # binary PLUS
       [ '1 + 2', '3', 'two summands', with_antlr3 => 1, ],
       [ '1 + 2 + 3', '6', 'three summands', with_antlr3 => 1, ],
       [ '1 + 0 + 3', '4', 'three summands including 0', with_antlr3 => 1, ],
       [ '1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 + 11 + 12 + 13 + 14', '105', 'Gauss was right', with_antlr3 => 1, ],

       # binary MINUS
       [ '2 - 1', '1', undef, with_antlr3 => 1, ],
       [ '1 - 1', '0', undef, with_antlr3 => 1, ],
       [ '1 - 2', '-1', undef, with_antlr3 => 1, ],
       [ '-1 - -2', '1', undef, with_antlr3 => 0, ],
       [ '-1 + -2 - -4 + 10', '11', undef, with_antlr3 => 0, ],

       # multiplication
       [ '2 * 2', '4', undef, with_antlr3 => 1, ],

       # division
       [ '2 / 2', '1', undef, with_antlr3 => 1, ],

       # modulus
       [ '2 % 2', '0', undef, with_antlr3 => 1, ],
       [ '3 % 2', '1', undef, with_antlr3 => 1, ],

       # precedence of mul, diff, mod
       [ '2 / 2 + .1', '1.1', undef, with_antlr3 => 1, ],
       [ '2 * 2 + .4', '4.4', undef, with_antlr3 => 1, ],
       [ '.1 - 6 / 2', '-2.9', undef, with_antlr3 => 1, ],
       [ '2 % 2 + 4', '4', undef, with_antlr3 => 1, ],

       # parenthesis
       [ '  ( 1 ) ', '1', 'one in parenthesis', with_antlr3 => 1, ],
       [ '  ( 1 + 2 ) - 3 ', '0', undef, with_antlr3 => 1, ],
       [ '  ( 1 + 2 ) - ( 5  + 1 - 2 ) + 7 - ( 8 - 100 ) ', '98', undef, with_antlr3 => 1, ],
       [ '  ( 1 + 2 ) * 3 ', '9', undef, with_antlr3 => 1, ],
       [ '  ( 1 * 2 ) * 3 ', '6', undef, with_antlr3 => 1, ],
       [ '  ( 1 * 2 ) + 3 ', '5' , undef, with_antlr3 => 1, ],
       [ '  ( 1 * 2 ) + ( ( ( ( 3 + 4 ) + 5 ) * 6 ) * 7 ) ', '506', undef, with_antlr3 => 1, ],

       # semicolons
       [ '; 1', [1], undef, with_antlr3 => 1, ],
       [ ';;   ;1', [1], undef, with_antlr3 => 1, ],
       [ '1;', [1], 'semicolon at end of line', with_antlr3 => 1, ],
       [ '1;;', [1], undef, with_antlr3 => 1, ],
       [ '1;  ; ; ;;', [1], 'semicolon at end of line', with_antlr3 => 1, ],
       [ '1; 2', [1, 2], 'two expressions seperated by a semicolon', with_antlr3 => 1, ],
       [ '1;;;;; ;    ; 2', [1, 2], undef, with_antlr3 => 1, ],
       [ '1+1+1; 2 + 2 + 2  ;  3 + 3 -1 + 3 +1', [3, 6, 9], '3 additive expression with semicolons', with_antlr3 => 1, ],
       [ '1+1*1; 2+2*2', [2, 6], undef, with_antlr3 => 1, ],
       [ '3-3/3; 4+4%4;  5-5+5', [2, 4, 5], undef, with_antlr3 => 1, ],

       # keyword quit
       [ "1; 2\nquit\n 3", [1, 2], 'int after quit', with_antlr3 => 1, ],

       # named expressions
       [ "a", [0], 'uninitialized a', with_antlr3 => 1, ],
       [ "a;b;c;d;x;y;z", [ (0) x 7 ], 'more uninitialized vars', with_antlr3 => 1, ],
       [ "a; a = 1; a", [0,1], 'assign number to lexical', with_antlr3 => 1, ],
       [ "a; a = 1 + 1; a", [0,2], 'assign number to expression', with_antlr3 => 1, ],
       [ 'a; b; a = 4; b = 5; c = 6; "a = "; a;  "b = "; b;  "c = "; c', [ 0, 0, 'a = 4', 'b = 5', 'c = 6' ], 'assign several lexicals', with_antlr3 => 1 ], 
       [ 'a; b; a = 4; b = a; c = 1; "a = "; a;  "b = "; b;  "c = "; c', [ 0, 0, 'a = 4', 'b = 4', 'c = 1' ], 'assign lexical to lexical', with_antlr3 => 1 ], 
       [ 'a  + 1', [ 1 ], 'expression with named', with_antlr3 => 1 ], 
       [ 'a = 4; b = a  + 1; "a = "; a;  "b = "; b ', [ 'a = 4', 'b = 5', ], 'assign lexical to expression with lexical', with_antlr3 => 1 ], 

       # increment and decrement 
       [ "a = a + 1; a ; a", [1,1], undef, with_antlr3 => 1, ],
       [ "++a; a", [1,1], undef, with_antlr3 => 0, ],
       [ "a; a = 1; a; ++a; a", [0,1,2,2], 'increment', with_antlr3 => 0, ],
       [ "a; a = 1; a; --a; a", [0,1,0,0], 'decrement', with_antlr3 => 0, ],

       # If 
       [ "1; if ( 1 ) 2; 3", [1,2,3], 'if with a true condition' ],
       [ "1; if ( 0 ) 2; 3", [1,3], 'if with a true condition' ],
       [ "1; if ( 1 < 2 ) 2; 3", [1, 2, 3], 'if with a relational operator' ],

       # If with '<'
       [ "1; if ( 3 + 4 < 8*2 - 10 ) 2; 3", [1, 3] ],
       [ "1; if ( 3 + 4 < 8*2 - 9 ) 2; 3", [1, 3] ],
       [ "1; if ( 3 + 4 < 8*2 + 10 ) 2; 3", [1, 2, 3] ],

       # If with '<='
       [ "1; if ( 3 + 4 <= 8*2 - 10 ) 2; 3", [1, 3] ],
       [ "1; if ( 3 + 4 <= 8*2 - 9 ) 2; 3", [1, 2, 3] ],
       [ "1; if ( 3 + 4 <= 8*2 + 10 ) 2; 3", [1, 2, 3] ],
       # If with '==', still TODO
       [ "1; if ( 3 + 4 == 8*2 - 10 ) 2; 3", [1, 3] ],
       [ "1; if ( 3 + 4 == 8*2 - 9 ) 2; 3", [1, 2, 3] ],
       [ "1; if ( 3 + 4 == 8*2 + 10 ) 2; 3", [1, 3] ],
       # If with '!='
       [ "1; if ( 3 + 4 != 8*2 - 10 ) 2; 3", [1, 2, 3] ],
       [ "1; if ( 3 + 4 != 8*2 - 9 ) 2; 3", [1, 3] ],
       [ "1; if ( 3 + 4 != 8*2 + 10 ) 2; 3", [1, 2, 3] ],
       # If with '>='
       [ "1; if ( 3 + 4 >= 8*2 - 10 ) 2; 3", [1, 2, 3] ],
       [ "1; if ( 3 + 4 >= 8*2 - 9 ) 2; 3", [1, 2, 3] ],
       [ "1; if ( 3 + 4 >= 8*2 + 10 ) 2; 3", [1, 3] ],

       # If with '>'
       [ "1; if ( 3 + 4 > 8*2 - 10 ) 2; 3", [1, 2, 3] ],
       [ "1; if ( 3 + 4 > 8*2 - 9 ) 2; 3", [1, 3] ],
       [ "1; if ( 3 + 4 > 8*2 + 10 ) 2; 3", [1, 3] ],
   );

#@tests = ( qq{1;2;" asdf\n  jklm\n   rtzu\n"   ;  3    }, [ 1, 2, ' asdf', '  jklm', '   rtzu', 3 ], undef, with_antlr3 => 1 ], );

my @todo_tests
    = ( # floats
        [ '.1', '.1', 'Parrot bc says 0.1', with_antlr3 => 1, ],
        [ '-.1', '-.1', 'Parrot bc says -0.1', with_antlr3 => 1,],
        [ '-1.0000001', '-1.0000001', 'probably limited precission of Float PMC', with_antlr3 => 1, ],

        # keyword quit
        [ "0\n1; 2; quit;  3", [ 0 ], 'is that correct in GNU bc?', with_antlr3 => 1, ],
      );

# @tests = ( [ qq{1;2;"asdf"   ;  3    }, [ 1, 2, 'asdf3' ], 'string', with_antlr3 => 1 ], );

if ( $Parrot::Config::PConfig{has_python} ) {
  plan tests => scalar(@tests) + scalar(@todo_tests);
}
else {
  plan skip_all => 'ANTLR2 based bc needs Python';
}

run_tests(\@tests);

TODO:
{
    local $TODO = 'not implemented';
    run_tests( \@todo_tests );
}; 
