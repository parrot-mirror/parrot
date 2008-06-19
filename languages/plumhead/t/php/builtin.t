#! perl
# Copyright (C) 2008, The Perl Foundation.
# $Id$

=head1 NAME

t/php/builtin.t - Standard Library

=head1 SYNOPSIS

    % perl -I../lib plumhead/t/php/builtin.t

=head1 DESCRIPTION

Tests PHP Standard Library
(implemented in F<languages/plumhead/src/common/php_builtin.pir>).

See L<http://www.php.net/manual/en/ref.?.php>.

=cut

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use Test::More     tests => 4;
use Parrot::Test;


language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'strlen()' );
<?php
  echo strlen('str'), "\n";
?>
CODE
3
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'strlen() empty string' );
<?php
  echo strlen(''), "\n";
?>
CODE
0
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'strlen() no arg' );
<?php
  echo strlen(), "\n";
?>
CODE
/Wrong parameter count for/
OUTPUT

language_output_like( 'Plumhead', <<'CODE', <<'OUTPUT', 'strlen() too many arg' );
<?php
  echo strlen('str', 42), "\n";
?>
CODE
/Wrong parameter count for/
OUTPUT


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
