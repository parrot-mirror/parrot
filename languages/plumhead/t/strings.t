# $Id: arithmetics.t 15935 2006-12-03 11:25:00Z bernhard $

=head1 NAME

plumhead/t/strings.t - tests for Plumhead

=head1 DESCRIPTION

String testing.

=cut

# pragmata
use strict;
use warnings;
use 5.006_001;

use FindBin;
use lib "$FindBin::Bin/../lib", "$FindBin::Bin/../../../lib";

# core Perl modules
use Test::More     tests => 4;

# Parrot modules
use Parrot::Test;


language_output_is( 'Plumhead', <<'END_CODE', <<'END_EXPECTED', '== for equal strings' );
<?php
if ( 'asdf' == 'asdf' )
{
  echo "== for equal strings\n";
}
?>
END_CODE
== for equal strings
END_EXPECTED


language_output_is( 'Plumhead', <<'END_CODE', <<'END_EXPECTED', '== for unequal strings' );
<?php
if ( 'asdf' == 'jklö' )
{
}
else
{
  echo "== for unequal strings\n";
}
?>
END_CODE
== for unequal strings
END_EXPECTED


language_output_is( 'Plumhead', <<'END_CODE', <<'END_EXPECTED', '!= for equal strings' );
<?php
if ( 'asdf' != 'asdf' )
{
}
else
{
  echo "!= for equal strings\n";
}
?>
END_CODE
!= for equal strings
END_EXPECTED


language_output_is( 'Plumhead', <<'END_CODE', <<'END_EXPECTED', '!= for unequal strings' );
<?php
if ( 'asdf' != 'jklö' )
{
  echo "!= for unequal strings\n";
}
?>
END_CODE
!= for unequal strings
END_EXPECTED

