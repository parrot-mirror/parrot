#! perl

# Copyright (C) 2008, The Perl Foundation.
# $Id$

=head1 NAME

cola/t/examples.t - Test examples in F<cola/examples>

=head1 SYNOPSIS

        % prove languages/cola/t/examples.t

=head1 DESCRIPTION

Test the examples in F<cola/examples>.

=head1 SEE ALSO

F<languages/jako/t/examples.t>

=head1 AUTHOR

Bernhard Schmalhofer - <Bernhard.Schmalhofer@gmx.de>

=cut

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../../lib";

use Test::More        tests => 2;
use Parrot::Config;
use File::Spec        ();

# Set up expected output for examples
my %expected = (
    'mandelbrot' => << 'END_EXPECTED',
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

    'fib' => << 'END_EXPECTED',
Algorithm F2 (Fibonacci's function)
  Calculating fib(24) = ...
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
  ... = 46368
END_EXPECTED
);

my $cola_dir  = File::Spec->catfile( $FindBin::Bin,
                                     File::Spec->updir() );
my $parrot    = File::Spec->catfile( File::Spec->updir(),
                                     File::Spec->updir(),
                                     $PConfig{test_prog} );

while ( my ( $example, $expected ) = each %expected ) {
    system( "cd $cola_dir; ./colacc examples/$example.cola" );
    is( `cd $cola_dir; $parrot a.pir`, $expected );
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
