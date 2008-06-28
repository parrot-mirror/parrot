#! perl
# Copyright (C) 2008, The Perl Foundation.
# $Id$

=head1 NAME

t/php/string.t - Standard Library string

=head1 SYNOPSIS

    % perl -I../lib plumhead/t/php/string.t

=head1 DESCRIPTION

Tests PHP Standard Library string
(implemented in F<languages/plumhead/src/common/php_string.pir>).

See L<http://www.php.net/manual/en/ref.string.php>.

=cut

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use Test::More     tests => 11;
use Parrot::Test;

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'bin2hex' );
<?php
  echo bin2hex('Ab3'), "\n";
?>
CODE
416233
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'chr' );
<?php
  echo chr(65), "\n";
?>
CODE
A
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'ord' );
<?php
  echo ord('A'), "\n";
  echo ord(''), "\n";
?>
CODE
65
0
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'str_repeat' );
<?php
  echo str_repeat('Ab', 3), "\n";
  echo str_repeat('Ab', 0), "\n";
  echo str_repeat('Ab', 1), "\n";
  echo str_repeat('', 3), "\n";
?>
CODE
AbAbAb

Ab

OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'strchr' );
<?php
  echo strchr('abcdef', 'cd'), "\n";
  echo strchr('abcdef', 'g'), "\n";
?>
CODE
cdef

OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'strpos' );
<?php
  echo strpos('abcdef', 'cd'), "\n";
  echo strpos('abcdef', 'g'), "\n";
  echo strpos('abcabc', 'b', 3), "\n";
?>
CODE
2

4
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'strstr' );
<?php
  echo strstr('abcdef', 'cd'), "\n";
  echo strstr('abcdef', 'g'), "\n";
?>
CODE
cdef

OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'strtolower' );
<?php
  echo strtolower('aBc'), "\n";
?>
CODE
abc
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'strtoupper' );
<?php
  echo strtoupper('aBc'), "\n";
?>
CODE
ABC
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'substr' );
<?php
  echo substr('abcdef', 2), "\n";
  echo substr('abcdef', 2, 2), "\n";
  echo substr('abcdef', -2), "\n";
  echo substr('abcdef', -2, 1), "\n";
?>
CODE
cdef
cd
ef
e
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'ucfirst' );
<?php
  echo ucfirst('abc'), "\n";
?>
CODE
Abc
OUTPUT

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
