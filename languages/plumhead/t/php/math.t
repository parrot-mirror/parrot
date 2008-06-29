#! perl
# Copyright (C) 2008, The Perl Foundation.
# $Id$

=head1 NAME

t/php/math.t - Standard Library math

=head1 SYNOPSIS

    % perl -I../lib plumhead/t/php/math.t

=head1 DESCRIPTION

Tests PHP Standard Library math
(implemented in F<languages/plumhead/src/common/php_math.pir>).

See L<http://www.php.net/manual/en/ref.math.php>.

=cut

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use Test::More     tests => 32;
use Parrot::Test;

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'abs', todo => 'broken in PCT variant' );
<?php
  echo abs(-3), "\n";
  echo abs(-3.14), "\n";
  echo abs(TRUE), "\n";
  echo abs(NULL), "\n";
  echo abs('0x03'), "\n";
  echo abs('-3'), "\n";
  echo abs('-3.14'), "\n";
  echo abs(' 0x03'), "\n";
  echo abs(' -3'), "\n";
  echo abs(' -3.14'), "\n";
  echo abs(' 0x03 '), "\n";
  echo abs(' -3 '), "\n";
  echo abs(' -3.14 '), "\n";
  echo abs('str'), "\n";
  echo abs(' str'), "\n";
  echo abs(' str '), "\n";
  $hello['world'] = 'hi';
  echo abs($hello), "\n";
?>
CODE
3
3.14
1
0
3
3
3.14
3
3
3.14
3
3
3.14
0
0
0

OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'acos' );
<?php
  echo acos(0.5), "\n";
?>
CODE
/^1\.047/
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'asin' );
<?php
  echo asin(0.5), "\n";
?>
CODE
/^0\.523/
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'atan' );
<?php
  echo atan(0.5), "\n";
?>
CODE
/^0\.463/
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'atan2' );
<?php
  echo atan2(1, 2), "\n";
?>
CODE
/^0\.463/
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'base_convert' );
<?php
  echo base_convert(126, 10, 16), "\n";
?>
CODE
7e
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'bindec' );
<?php
  echo bindec('0101'), "\n";
?>
CODE
5
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'ceil' );
<?php
  echo ceil(3.14), "\n";
?>
CODE
4
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'cos' );
<?php
  echo cos(0.5), "\n";
?>
CODE
/^0\.877/
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'cosh' );
<?php
  echo cosh(0.5), "\n";
?>
CODE
/^1\.127/
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'decbin' );
<?php
  echo decbin(126), "\n";
?>
CODE
1111110
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'dechex' );
<?php
  echo dechex(126), "\n";
?>
CODE
7e
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'decoct' );
<?php
  echo decoct(126), "\n";
?>
CODE
176
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'deg2rad' );
<?php
  echo deg2rad(90), "\n";
?>
CODE
/^1\.570/
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'exp' );
<?php
  echo exp(0.5), "\n";
?>
CODE
/^1\.648/
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'floor' );
<?php
  echo floor(3.14), "\n";
?>
CODE
3
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'fmod' );
<?php
  echo fmod(3.14, 2.5), "\n";
?>
CODE
0.64
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'hexdec' );
<?php
  echo hexdec('7E'), "\n";
?>
CODE
126
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'hypot' );
<?php
  echo hypot(1, 2), "\n";
?>
CODE
/^2\.236/
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'log' );
<?php
  echo log(10), "\n";
?>
CODE
/^2\.302/
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'log' );
<?php
  echo log(10, 2), "\n";
?>
CODE
/^3\.321/
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'log10' );
<?php
  echo log10(100), "\n";
?>
CODE
2
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'octdec' );
<?php
  echo octdec('0777'), "\n";
?>
CODE
511
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'pi' );
<?php
  echo pi(), "\n";
?>
CODE
/^3\.14/
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'pow' );
<?php
  echo pow(2, 3), "\n";
  echo pow(1.5, 2), "\n";
?>
CODE
8
2.25
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'rad2deg' );
<?php
  echo rad2deg(0.5), "\n";
?>
CODE
/^28\.6/
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'round' );
<?php
  echo round(3.14159), "\n";
  echo round(3.14159, 2), "\n";
  echo round(3.14159, 4), "\n";
?>
CODE
3
3.14
3.1416
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'sin' );
<?php
  echo sin(0.5), "\n";
?>
CODE
/^0\.479/
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'sinh' );
<?php
  echo sinh(0.5), "\n";
?>
CODE
/^0\.521/
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'sqrt' );
<?php
  echo sqrt(0.5), "\n";
?>
CODE
/^0\.707/
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'tan' );
<?php
  echo tan(0.5), "\n";
?>
CODE
/^0\.546/
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'tanh' );
<?php
  echo tanh(0.5), "\n";
?>
CODE
/^0\.462/
OUTPUT

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
