#!perl
use strict;
use TestCompiler tests => 3;
use Test::More qw(skip);

##############################
output_is(<<'CODE', <<'OUT', "eval pasm");
.sub _test
	$S0 = 'set S1, "in eval\n"'
	concat $S0, "\n"
	concat $S0, "print S1\nend\n"
	compreg $P0, "PASM"
	compile P0, $P0, $S0
	invoke
	print "back\n"
	end
.end
CODE
in eval
back
OUT

output_is(<<'CODE', <<'OUT', "eval pir");
.sub _test
	$S1 = ".sub _foo\n"
	concat $S1, '$S1 = "42\n"'
	concat $S1, "\nprint $S1\nend\n"
	concat $S1, "\n.end\n"
	compreg $P0, "PIR"
	compile P0, $P0, $S1
	invoke
	print "back\n"
	noop	# filler to avoid realloc of code ;-)
	end
.end
CODE
42
back
OUT

SKIP: {
  skip("not yet: jump to different code seg", 1);
output_is(<<'CODE', <<'OUT', "intersegment branch");
# #!/usr/bin/perl -w
# my $i= 5;
# LAB:
#    $i++;
#    eval("goto LAB if ($i==6)");
#    print "$i\n";
#
# 7
#####

.sub _test
    I1 = 5
    $S0 = ".sub _e\nif I1 == 6 goto LAB\nend\n.end\n"
    compreg P2, "PIR"
    compile P0, P2, $S0
LAB:
    inc I1
    invoke
    print I1
    print "\n"
    end
.end
CODE
7
OUT
}

