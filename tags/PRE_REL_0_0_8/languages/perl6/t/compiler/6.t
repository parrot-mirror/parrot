#!perl

use strict;
use P6C::TestCompiler tests => 6;

##############################
output_is(<<'CODE', <<'OUT', "foreach 1");
sub main() {
    foreach (1..5) {
	print $_, "\n";
    }
}

CODE
1
2
3
4
5
OUT

##############################
output_is(<<'CODE', <<'OUT', "foreach 2");
sub main() {
    my $x = 0;
    foreach my $x (1..5) {
	print $x, "\n";
    }
}
CODE
1
2
3
4
5
OUT

##############################
output_is(<<'CODE', <<'OUT', "foreach 3");
sub main() {
    my @x = 0..4;
    foreach my $x (@x) {
	print $x, "\n";
	@x[4 - $x] = 'foo';
    }
}
CODE
0
1
2
foo
foo
OUT

##############################
output_is(<<'CODE', <<'OUT', "loop 1");
sub main() {
    my $i = 2;
    loop (my $i = 0; $i < 5; $i++) {
	print $i, "\n";
    }
    print $i, "\n";
}
CODE
0
1
2
3
4
2
OUT

##############################
output_is(<<'CODE', <<'OUT', "loop 2");
sub main() {
    my $i = 2;
    loop (; $i < 5; $i++) {
	print $i, "\n";
    }
    print $i, "\n";
}
CODE
2
3
4
5
OUT

##############################
output_is(<<'CODE', <<'OUT', "loop 3");
sub main() {
    loop (my $i = 2; $i < 2; $i++) {
	print $i, "\n";
    }
    my $i = 0;
    loop (; $i < 5;) {
	$i = $i + 2;
	print $i, "\n";
    }
    print $i, "\n";
}
CODE
2
4
6
6
OUT
