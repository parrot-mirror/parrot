#! perl
# Copyright (C) 2008, The Perl Foundation.
# $Id:  $

=head1 NAME

t/php/type.t - Standard Library type

=head1 SYNOPSIS

    % perl -I../lib plumhead/t/php/type.t

=head1 DESCRIPTION

Tests PHP Standard Library type
(implemented in F<languages/plumhead/src/common/php_type.pir>).

See L<http://www.php.net/manual/en/ref.type.php>.

=cut

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use Test::More     tests => 5;
use Parrot::Test;

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'gettype(TRUE)' );
<?php
  echo gettype(TRUE), "\n";
?>
CODE
boolean
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'gettype(NULL)' );
<?php
  echo gettype(NULL), "\n";
?>
CODE
NULL
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'gettype(42)' );
<?php
  echo gettype(42), "\n";
?>
CODE
integer
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'gettype(3.14)' );
<?php
  echo gettype(3.14), "\n";
?>
CODE
double
OUTPUT

TODO:
{
    local $TODO = 'update compiler';

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'gettype("str")' );
<?php
  echo gettype('str'), "\n";
?>
CODE
string
OUTPUT

}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
