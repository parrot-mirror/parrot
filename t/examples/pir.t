#!perl
# Copyright (C) 2005-2009, Parrot Foundation.
# $Id$

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );

use Test::More;
use Parrot::Test tests => 18;
use Parrot::Config;

=head1 NAME

t/examples/pir.t - Test examples in F<examples/pir>

=head1 SYNOPSIS

    % prove t/examples/pir.t

=head1 DESCRIPTION

Test the examples in F<examples/pir>.

=head1 SEE ALSO

F<t/examples/pasm.t>

=head1 AUTHOR

Bernhard Schmalhofer - <Bernhard.Schmalhofer@gmx.de>

=cut

# Set up expected output for examples
my %expected = (
    'circle.pir' => << 'END_EXPECTED',
[H[2J[23;40H*[23;40H*[23;41H*[23;41H*[23;42H*[23;42H*[23;43H*[23;44H*[23;44H*[23;45H*[23;45H*[23;46H*[23;46H*[23;47H*[22;48H*[22;48H*[22;49H*[22;49H*[22;50H*[22;50H*[22;51H*[22;52H*[22;52H*[22;53H*[22;53H*[22;54H*[22;54H*[22;55H*[22;55H*[22;56H*[22;56H*[21;57H*[21;58H*[21;58H*[21;59H*[21;59H*[21;60H*[21;60H*[21;61H*[21;61H*[21;62H*[21;62H*[20;62H*[20;63H*[20;63H*[20;64H*[20;64H*[20;65H*[20;65H*[20;66H*[20;66H*[19;66H*[19;67H*[19;67H*[19;68H*[19;68H*[19;68H*[19;69H*[18;69H*[18;70H*[18;70H*[18;70H*[18;71H*[18;71H*[18;71H*[17;72H*[17;72H*[17;72H*[17;72H*[17;73H*[17;73H*[17;73H*[16;74H*[16;74H*[16;74H*[16;74H*[16;75H*[16;75H*[15;75H*[15;75H*[15;75H*[15;76H*[15;76H*[15;76H*[14;76H*[14;76H*[14;76H*[14;77H*[14;77H*[14;77H*[13;77H*[13;77H*[13;77H*[13;77H*[13;77H*[12;77H*[12;77H*[12;77H*[12;77H*[12;77H*[12;77H*[12;77H*[12;77H*[12;77H*[12;77H*[12;77H*[12;77H*[11;77H*[11;77H*[11;77H*[11;77H*[11;77H*[10;77H*[10;77H*[10;77H*[10;77H*[10;76H*[10;76H*[9;76H*[9;76H*[9;76H*[9;76H*[9;75H*[9;75H*[8;75H*[8;75H*[8;75H*[8;74H*[8;74H*[8;74H*[7;74H*[7;73H*[7;73H*[7;73H*[7;72H*[7;72H*[7;72H*[6;72H*[6;71H*[6;71H*[6;71H*[6;70H*[6;70H*[5;70H*[5;69H*[5;69H*[5;68H*[5;68H*[5;68H*[5;67H*[5;67H*[4;66H*[4;66H*[4;66H*[4;65H*[4;65H*[4;64H*[4;64H*[4;63H*[3;63H*[3;62H*[3;62H*[3;61H*[3;61H*[3;60H*[3;60H*[3;59H*[3;59H*[3;58H*[2;58H*[2;57H*[2;57H*[2;56H*[2;56H*[2;55H*[2;55H*[2;54H*[2;54H*[2;53H*[2;52H*[2;52H*[2;51H*[2;51H*[1;50H*[1;50H*[1;49H*[1;48H*[1;48H*[1;47H*[1;47H*[1;46H*[1;46H*[1;45H*[1;44H*[1;44H*[1;43H*[1;43H*[1;42H*[1;41H*[1;41H*[1;40H*[1;40H*[1;40H*[1;39H*[1;39H*[1;38H*[1;38H*[1;37H*[1;36H*[1;36H*[1;35H*[1;35H*[1;34H*[1;33H*[1;33H*[1;32H*[1;32H*[1;31H*[1;30H*[1;30H*[1;29H*[2;29H*[2;28H*[2;28H*[2;27H*[2;26H*[2;26H*[2;25H*[2;25H*[2;24H*[2;24H*[2;23H*[2;23H*[2;22H*[2;22H*[3;21H*[3;21H*[3;20H*[3;20H*[3;19H*[3;19H*[3;18H*[3;18H*[3;17H*[3;17H*[4;16H*[4;16H*[4;15H*[4;15H*[4;14H*[4;14H*[4;13H*[4;13H*[5;13H*[5;12H*[5;12H*[5;11H*[5;11H*[5;11H*[5;10H*[5;10H*[6;9H*[6;9H*[6;9H*[6;8H*[6;8H*[6;8H*[7;7H*[7;7H*[7;7H*[7;6H*[7;6H*[7;6H*[7;6H*[8;5H*[8;5H*[8;5H*[8;5H*[8;4H*[8;4H*[9;4H*[9;4H*[9;4H*[9;3H*[9;3H*[10;3H*[10;3H*[10;3H*[10;3H*[10;2H*[10;2H*[11;2H*[11;2H*[11;2H*[11;2H*[11;2H*[11;2H*[12;2H*[12;2H*[12;2H*[12;2H*[12;2H*[12;2H*[12;2H*[12;2H*[12;2H*[12;2H*[12;2H*[13;2H*[13;2H*[13;2H*[13;2H*[13;2H*[14;2H*[14;2H*[14;2H*[14;3H*[14;3H*[14;3H*[15;3H*[15;3H*[15;3H*[15;4H*[15;4H*[16;4H*[16;4H*[16;4H*[16;5H*[16;5H*[16;5H*[17;5H*[17;6H*[17;6H*[17;6H*[17;6H*[17;7H*[17;7H*[18;7H*[18;8H*[18;8H*[18;8H*[18;9H*[18;9H*[19;9H*[19;10H*[19;10H*[19;10H*[19;11H*[19;11H*[19;12H*[20;12H*[20;12H*[20;13H*[20;13H*[20;14H*[20;14H*[20;15H*[20;15H*[21;16H*[21;16H*[21;17H*[21;17H*[21;18H*[21;18H*[21;19H*[21;19H*[21;20H*[22;20H*[22;21H*[22;21H*[22;22H*[22;22H*[22;23H*[22;23H*[22;24H*[22;24H*[22;25H*[22;25H*[22;26H*[23;27H*[23;27H*[23;28H*[23;28H*[23;29H*[23;30H*[23;30H*[23;31H*[23;31H*[23;32H*[23;32H*[23;33H*[23;34H*[23;34H*[23;35H*[23;36H*[23;36H*[23;37H*[23;37H*[23;38H*[23;39H*[23;39H*[23;40H*[23;40H*[23;40H*[24;0H
END_EXPECTED
    'euclid.pir' => << 'END_EXPECTED',
Algorithm E (Euclid's algorithm)
The greatest common denominator of 96 and 64 is 32.
END_EXPECTED

    'hanoi.pir' => << 'END_EXPECTED',
Using default size 3 for tower.

       |        |       
 ====  |        |       
====== |        |   ==  

       |        |       
       |        |       
====== |  ====  |   ==  

       |        |       
       |   ==   |       
====== |  ====  |       

       |        |       
       |   ==   |       
       |  ====  | ======

       |        |       
       |        |       
  ==   |  ====  | ======

       |        |       
       |        |  ==== 
  ==   |        | ======

       |        |   ==  
       |        |  ==== 
       |        | ======

END_EXPECTED

    'io.pir' => << 'END_EXPECTED',
test4
test5
                                                                                                                                                                                                                                                                                                test1
test2
test3
END_EXPECTED

    'local_label.pir' => << 'END_EXPECTED',
Branching to '$ok' in macro 'TEST1'
Branched to '$ok' in macro 'TEST1'
After .TEST1 ()
Branching to '$ok' in macro 'TEST2'
Branched to '$ok' in macro 'TEST2'
Branched to 'non_local' in sub 'example'
END_EXPECTED

    'mandel.pir' => << 'END_EXPECTED',
................::::::::::::::::::::::::::::::::::::::::::::...............
...........::::::::::::::::::::::::::::::::::::::::::::::::::::::..........
........::::::::::::::::::::::::::::::::::,,,,,,,:::::::::::::::::::.......
.....:::::::::::::::::::::::::::::,,,,,,,,,,,,,,,,,,,,,,:::::::::::::::....
...::::::::::::::::::::::::::,,,,,,,,,,,,;;;!:H!!;;;,,,,,,,,:::::::::::::..
:::::::::::::::::::::::::,,,,,,,,,,,,,;;;;!!/>&*|& !;;;,,,,,,,:::::::::::::
::::::::::::::::::::::,,,,,,,,,,,,,;;;;;!!//)|.*#|>/!;;;;;,,,,,,:::::::::::
::::::::::::::::::,,,,,,,,,,,,;;;;;;!!!!//>|:    !:|//!!;;;;;,,,,,:::::::::
:::::::::::::::,,,,,,,,,,;;;;;;;!!/>>I>>)||I#     H&))>////*!;;,,,,::::::::
::::::::::,,,,,,,,,,;;;;;;;;;!!!!/>H:  #|              IH&*I#/;;,,,,:::::::
::::::,,,,,,,,,;;;;;!!!!!!!!!!//>|.H:                     #I>!!;;,,,,::::::
:::,,,,,,,,,;;;;!/||>///>>///>>)|H                         %|&/;;,,,,,:::::
:,,,,,,,,;;;;;!!//)& :;I*,H#&||&/                           *)/!;;,,,,,::::
,,,,,,;;;;;!!!//>)IH:,        ##                            #&!!;;,,,,,::::
,;;;;!!!!!///>)H%.**           *                            )/!;;;,,,,,::::
                                                          &)/!!;;;,,,,,::::
,;;;;!!!!!///>)H%.**           *                            )/!;;;,,,,,::::
,,,,,,;;;;;!!!//>)IH:,        ##                            #&!!;;,,,,,::::
:,,,,,,,,;;;;;!!//)& :;I*,H#&||&/                           *)/!;;,,,,,::::
:::,,,,,,,,,;;;;!/||>///>>///>>)|H                         %|&/;;,,,,,:::::
::::::,,,,,,,,,;;;;;!!!!!!!!!!//>|.H:                     #I>!!;;,,,,::::::
::::::::::,,,,,,,,,,;;;;;;;;;!!!!/>H:  #|              IH&*I#/;;,,,,:::::::
:::::::::::::::,,,,,,,,,,;;;;;;;!!/>>I>>)||I#     H&))>////*!;;,,,,::::::::
::::::::::::::::::,,,,,,,,,,,,;;;;;;!!!!//>|:    !:|//!!;;;;;,,,,,:::::::::
::::::::::::::::::::::,,,,,,,,,,,,,;;;;;!!//)|.*#|>/!;;;;;,,,,,,:::::::::::
:::::::::::::::::::::::::,,,,,,,,,,,,,;;;;!!/>&*|& !;;;,,,,,,,:::::::::::::
...::::::::::::::::::::::::::,,,,,,,,,,,,;;;!:H!!;;;,,,,,,,,:::::::::::::..
.....:::::::::::::::::::::::::::::,,,,,,,,,,,,,,,,,,,,,,:::::::::::::::....
........::::::::::::::::::::::::::::::::::,,,,,,,:::::::::::::::::::.......
...........::::::::::::::::::::::::::::::::::::::::::::::::::::::..........
END_EXPECTED

    'substr.pir' => << 'END_EXPECTED',

H
He
Hel
Hell
Hello
Hello 
Hello W
Hello Wo
Hello Wor
Hello Worl
Hello World
Hello Worl
Hello Wor
Hello Wo
Hello W
Hello 
Hello
Hell
Hel
He
H

END_EXPECTED

    'sudoku.pir' => << 'END_EXPECTED',
+---------+---------+---------+
| 1  .  . | .  .  . | .  .  . |
| .  .  2 | 7  4  . | .  .  . |
| .  .  . | 5  .  . | .  .  4 |
+---------+---------+---------+
| .  3  . | .  .  . | .  .  . |
| 7  5  . | .  .  . | .  .  . |
| .  .  . | .  .  9 | 6  .  . |
+---------+---------+---------+
| .  4  . | .  .  6 | .  .  . |
| .  .  . | .  .  . | .  7  1 |
| .  .  . | .  .  1 | .  3  . |
+---------+---------+---------+
init ok
+---------+---------+---------+
| 1  8  4 | 9  6  3 | 7  2  5 |
| 5  6  2 | 7  4  8 | 3  1  9 |
| 3  9  7 | 5  1  2 | 8  6  4 |
+---------+---------+---------+
| 2  3  9 | 6  5  7 | 1  4  8 |
| 7  5  6 | 1  8  4 | 2  9  3 |
| 4  1  8 | 2  3  9 | 6  5  7 |
+---------+---------+---------+
| 9  4  1 | 3  7  6 | 5  8  2 |
| 6  2  3 | 8  9  5 | 4  7  1 |
| 8  7  5 | 4  2  1 | 9  3  6 |
+---------+---------+---------+
solved
END_EXPECTED

    'make_hello_pbc.pir' => << 'END_EXPECTED',
Hello World
END_EXPECTED
);

# expected output of a quine is the quine itself
# TODO currently broken
# $expected{'quine_ord.pir'} = Parrot::Test::slurp_file("examples/pir/quine_ord.pir");

my %skips = (
    'make_hello_pbc.pir' => [ 1, "PackfileRawSegment no longer valid for bytecode" ],
);

while ( my ( $example, $expected ) = each %expected ) {
    my $skip = $skips{$example};
    if ($skip) {
        my ( $cond, $reason ) = @{$skip};
        if ( eval "$cond" ) {
            Test::More->builder->skip("$example $reason");
            next;
        }
    }
    example_output_is( "examples/pir/$example", $expected );
}

my $PARROT = ".$PConfig{slash}$PConfig{test_prog}";

# For testing life.pir, the number of generations should be small,
# because users should not get bored.
{
    my $life_fn = "examples$PConfig{slash}pir$PConfig{slash}life.pir";
    my $sum     = `$PARROT $life_fn 4`;
    like( $sum, qr/4 generations in/, 'life ran for 4 generations' );
}

# readline.pir expects something on standard input
{
    my $readline_pir_fn = "examples$PConfig{slash}pir$PConfig{slash}readline.pir";
    my $readline_tmp_fn = "test_readline.tmp";
    open( my $tmp, '>', $readline_tmp_fn );
    print $tmp join( "\n", 'first line', '', 'last line' );
    close $tmp;
    my $out = `$PARROT $readline_pir_fn < $readline_tmp_fn`;
    is( $out, << 'END_EXPECTED', 'print until first empty line' );
first line
END_EXPECTED
    unlink($readline_tmp_fn);
}

# uniq.pir expects a file that it can uniquify
{
    my $uniq_pir_fn = "examples$PConfig{slash}pir$PConfig{slash}uniq.pir";
    my $uniq_tmp_fn = "test_uniq.tmp";
    open( my $tmp, '>', $uniq_tmp_fn );
    print $tmp join( "\n", qw( a a a b b c d d d ) );
    print $tmp "\n";
    close $tmp;

    my $out = `$PARROT $uniq_pir_fn $uniq_tmp_fn`;
    is( $out, << 'END_EXPECTED', 'uniq' );
a
b
c
d
END_EXPECTED

    $out = `$PARROT $uniq_pir_fn -c $uniq_tmp_fn`;
    is( $out, << 'END_EXPECTED', 'uniq -c' );
      3 a
      2 b
      1 c
      3 d
END_EXPECTED

    $out = `$PARROT $uniq_pir_fn -d $uniq_tmp_fn`;
    is( $out, << 'END_EXPECTED', 'uniq -d' );
a
b
d
END_EXPECTED

    $out = `$PARROT $uniq_pir_fn -u $uniq_tmp_fn`;
    is( $out, << 'END_EXPECTED', 'uniq -u' );
c
END_EXPECTED

    unlink($uniq_tmp_fn);
}

## Added test this way, so we can have more interesting tests.
pir_output_is( <<'CODE', <<OUTPUT, "Test Levenshtein example" );
.include "examples/pir/levenshtein.pir"
.sub main :main
        $S1 = "purl"
        $S2 = "perl"
        $I1 = levenshtein($S1,$S2)
        print $I1
        print "\n"

        $S1 = "parrot"
        $S2 = "perl"
        $I1 = levenshtein($S1,$S2)
        print $I1
        print "\n"

        $S1 = "perl"
        $S2 = "perl"
        $I1 = levenshtein($S1,$S2)
        print $I1
        print "\n"

        $S1 = "perler"
        $S2 = "perl"
        $I1 = levenshtein($S1,$S2)
        print $I1
        print "\n"

        end
.end
CODE
1
4
0
2
OUTPUT

TODO:
{
    local $TODO = 'some examples not testable yet';

    fail('queens_r.pir');
    fail('thr_primes.pir');
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
