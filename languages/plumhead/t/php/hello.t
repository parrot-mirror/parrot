# $Id$

=head1 NAME

plumhead/t/hello.t - tests for Plumhead

=head1 DESCRIPTION

A couple of 'Hello World' tests.

=cut

# pragmata
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../lib";

# core Perl modules
use Test::More     tests => 16;

# Parrot modules
use Parrot::Test;

language_output_is( 'Plumhead', <<'END_CODE', 'Hello, World!', 'sea without newline' );
Hello, World!<?php
?>
END_CODE

language_output_is( 'Plumhead', <<'END_CODE', <<'END_EXPECTED', 'sea with one newline' );
Hello, World!
<?php
?>
END_CODE
Hello, World!
END_EXPECTED

language_output_is( 'Plumhead', <<'END_CODE', <<'END_EXPECTED', 'sea with two newlines' );
Hello,
World!
<?php
?>
END_CODE
Hello,
World!
END_EXPECTED

language_output_is( 'Plumhead', <<'END_CODE', <<'END_EXPECTED', 'sea without following PHP code' );
Hello,
World!
END_CODE
Hello,
World!
END_EXPECTED

language_output_is( 'Plumhead', <<'END_CODE', <<'END_EXPECTED', 'sea without following PHP code' );
Hello,<?php
  ?> World!
<?php
?>
END_CODE
Hello, World!
END_EXPECTED

language_output_is( 'Plumhead', <<'END_CODE', <<'END_EXPECTED', 'hello' );
<?php
echo "Hello, World!\n";
?>
END_CODE
Hello, World!
END_EXPECTED

language_output_is( 'Plumhead', <<'END_CODE', <<'END_EXPECTED', 'hello' );
<?php
echo 'Hello, World!';
echo "\n";
?>
END_CODE
Hello, World!
END_EXPECTED


language_output_is( 'Plumhead', <<'END_CODE', 'Hello World', 'only alphanumic' );
<?php echo "Hello World"; ?>
END_CODE

language_output_is( 'Plumhead', <<'END_CODE', <<'END_EXPECTED', 'two echo statements' );
<?php
echo "Hello, ";
echo "World!\n";
?>
END_CODE
Hello, World!
END_EXPECTED

language_output_is( 'Plumhead', <<'END_CODE', <<'END_EXPECTED', 'two echo statements' );
<?php
echo "Hello, ";
?>Wo<?php
echo "rl";
?>d!
<?php
?>
END_CODE
Hello, World!
END_EXPECTED

TODO: {
    local $TODO = '< not handled correctly';

language_output_is( 'Plumhead', <<'END_CODE', <<'END_EXPECTED', 'hello with some HTML', todo => '< not handled correctly' );
<html>
<head>
  <title>Servus</title>
</head>
<body>
<pre>
<?php
echo "Hello, World!\n";
?>
</pre>
</body>
</html>
END_CODE
<html>
<head>
  <title>Servus</title>
</head>
<body>
<pre>
Hello, World!
</pre>
</body>
</html>
END_EXPECTED

}


language_output_is( 'Plumhead', <<'END_CODE', <<'END_EXPECTED', 'hello in a scalar' );
<?php
$h = "Hello, World!\n";
echo $h;
?>
END_CODE
Hello, World!
END_EXPECTED


language_output_is( 'Plumhead', <<'END_CODE', <<'END_EXPECTED', 'hello in a hash' );
<?php
$h["e"] = "Hello, World!\n";
echo $h["e"];
?>
END_CODE
Hello, World!
END_EXPECTED


language_output_is( 'Plumhead', <<'END_CODE', <<'END_EXPECTED', 'no semicolon befor CODE_END' );
<?php
echo 'Hello, ';
echo "World!\n"
?>
END_CODE
Hello, World!
END_EXPECTED


language_output_is( 'Plumhead', <<'END_CODE', <<'END_EXPECTED', 'concatenation of two strings', todo => 'currently broken' );
<?php
echo 'Hello, ' . "World!\n"
?>
END_CODE
Hello, World!
END_EXPECTED


language_output_is( 'Plumhead', <<'END_CODE', <<'END_EXPECTED', 'concatenation of four strings', todo => 'currently broken' );
<?php
echo 'Hell' . 'o, ' . 'World!' . "\n"
?>
END_CODE
Hello, World!
END_EXPECTED

