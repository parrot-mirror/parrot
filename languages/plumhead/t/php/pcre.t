#! perl
# Copyright (C) 2008, The Perl Foundation.
# $Id$

=head1 NAME

t/php/pcre.t - Library pcre

=head1 SYNOPSIS

    % perl -I../lib plumhead/t/php/pcre.t

=head1 DESCRIPTION

Tests PHP Library pcre
(implemented in F<languages/plumhead/src/common/php_pcre.pir>).

See L<http://www.php.net/manual/en/ref.pcre.php>.

=cut

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use Test::More     tests => 2;
use Parrot::Test;


language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'preg_match()' );
<?php
  echo preg_match('/b/', 'abc'), "\n";
  echo preg_match('/b/', 'aaa'), "\n";
  echo preg_match('{b}', 'abc'), "\n";
  echo preg_match('/b/i', 'ABC'), "\n";
?>
CODE
1
0
1
1
OUTPUT

language_output_is( 'Plumhead', <<'CODE', <<'OUTPUT', 'preg_quote()' );
<?php
  echo preg_quote('{}[]()'), "\n";
?>
CODE
\{\}\[\]\(\)
OUTPUT

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
