#! perl -w
# test WRT JIT register allocation
use Parrot::Test tests => 8;

output_is(<<'CODE', <<'OUTPUT', "sub_i_i_i 1,2,3 mapped");
set N0,0
set N1,1
set N2,2
sub N0,N1,N2
print N0
print "\n"
print N1
print "\n"
print N2
print "\n"
end
CODE
-1.000000
1.000000
2.000000
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "sub_i_i_i 1,2 mapped");
set N0,0
set N1,1
set N2,2
set N3,3
set N4,4
set N0,N1
set N2,N3
set N0,N1
set N2,N3
sub N0,N1,N4
print N0
print "\n"
print N1
print "\n"
print N4
print "\n"
end
CODE
-3.000000
1.000000
4.000000
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "sub_i_i_i 1,3 mapped");
set N0,0
set N1,1
set N2,2
set N3,3
set N4,4
set N0,N1
set N2,N3
set N0,N1
set N2,N3
sub N0,N4,N1
print N0
print "\n"
print N4
print "\n"
print N1
print "\n"
end
CODE
3.000000
4.000000
1.000000
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "sub_i_i_i 2,3 mapped");
set N0,0
set N1,1
set N2,2
set N3,3
set N4,4
set N0,N1
set N2,N3
set N0,N1
set N2,N3
sub N4,N0,N1
print N4
print "\n"
print N0
print "\n"
print N1
print "\n"
end
CODE
0.000000
1.000000
1.000000
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "sub_i_i_i 1 mapped");
set N0,0
set N1,1
set N2,2
set N3,3
set N4,4
set N0,N1
set N2,N3
set N0,N1
set N2,N3
sub N1,N5,N4
print N1
print "\n"
print N5
print "\n"
print N4
print "\n"
end
CODE
-4.000000
0.000000
4.000000
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "sub_i_i_i 2 mapped");
set N0,0
set N1,1
set N2,2
set N3,3
set N4,4
set N0,N1
set N2,N3
set N0,N1
set N2,N3
sub N5,N1,N4
print N5
print "\n"
print N1
print "\n"
print N4
print "\n"
end
CODE
-3.000000
1.000000
4.000000
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "sub_i_i_i 3 mapped");
set N0,0
set N1,1
set N2,2
set N3,3
set N4,4
set N0,N1
set N2,N3
set N0,N1
set N2,N3
sub N5,N4,N1
print N5
print "\n"
print N1
print "\n"
print N4
print "\n"
end
CODE
3.000000
1.000000
4.000000
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "sub_i_i_i 0 mapped");
set N0,0
set N1,1
set N2,2
set N3,3
set N4,4
set N0,N1
set N2,N3
set N0,N1
set N2,N3
sub N5,N6,N4
print N5
print "\n"
print N6
print "\n"
print N4
print "\n"
end
CODE
-4.000000
0.000000
4.000000
OUTPUT

