#perl -w

use Parrot::Test tests => 15;

output_is(<<'CODE', <<'OUTPUT', "shr_i_i (>>)");
	set I0, 0b001100
	set I1, 0b010100
	set I2, 1
	set I3, 2
	shr I4, I0, I2
	shr I2, I0, I2
	shr I1, I1, I3
	print I4
 	print "\n"
 	print I2
 	print "\n"
 	print I1
 	print "\n"
 	print I0
 	print "\n"
 	end
CODE
6
6
5
12
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "shr_i_ic (>>)");
	set	I0, 0b001100
	set	I1, 0b010100
	shr	I2, I0, 1
	shr	I1, I1, 2
	print	I2
	print	"\n"
	print	I1
	print	"\n"
	print	I0
	print	"\n"
	end
CODE
6
5
12
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "shr_ic_i (>>)");
 	set I0, 1
 	set I1, 2
 	shr I2, 0b001100, I0
 	shr I1, 0b010100, I1
 	print I2
 	print "\n"
 	print I1
 	print "\n"
 	end
CODE
6
5
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "shr_ic_ic (>>)");
 	shr I2, 0b001100, 1
 	shr I1, 0b010100, 2
 	print I2
 	print "\n"
 	print I1
 	print "\n"
 	end
CODE
6
5
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "shl_i_i (<<)");
 	set I0, 0b001100
 	set I1, 0b010100
 	set I2, 2
 	set I3, 1
 	shl I4, I0, I2
 	shl I2, I0, I2
 	shl I1, I1, I3
 	print I4
 	print "\n"
 	print I2
 	print "\n"
 	print I1
 	print "\n"
 	print I0
 	print "\n"
 	end
CODE
48
48
40
12
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "shl_i_ic (<<)");
 	set I0, 0b001100
 	set I1, 0b010100
 	shl I2, I0, 2
 	shl I1, I1, 1
 	print I2
 	print "\n"
 	print I1
 	print "\n"
 	print I0
 	print "\n"
 	end
CODE
48
40
12
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "shl_ic_i (<<)");
 	set I0, 2
 	set I1, 1
 	shl I2, 0b001100, I0
 	shl I1, 0b010100, I1
 	print I2
 	print "\n"
 	print I1
 	print "\n"
 	end
CODE
48
40
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "shl_ic_ic (<<)");
 	shl I2, 0b001100, 2
 	shl I1, 0b010100, 1
 	print I2
 	print "\n"
 	print I1
 	print "\n"
 	end
CODE
48
40
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "xor_i_i (^)");
	set	I0, 0b001100
	set	I1, 0b100110
	xor	I2, I0, I1
	print	I2
	print	"\n"
	xor	I1, I0, I1
	print	I1
	print	"\n"
	print	I0
	print	"\n"
	end
CODE
42
42
12
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "xor_i_ic (^)");
 	set I0, 0b001100
 	xor I2, I0, 0b100110
 	print I2
 	print "\n"
 	print I0
 	print "\n"
 	xor I0, I0, 0b100110
 	print I0
 	print "\n"
 	end
CODE
42
12
42
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "and_i_i (&)");
	set	I0, 0b001100
	set	I1, 0b010110
	and	I2, I0,I1
	print	I2
	print	"\n"
	and	I1,I0,I1
	print	I1
	print	"\n"
	print	I0
	print	"\n"
        end
CODE
4
4
12
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "and_i_ic (&)");
 	set I0, 0b001100
 	and I2, I0,0b010110
 	print I2
 	print "\n"
 	print I0
 	print "\n"
 	and I0,I0,0b010110
 	print I0
 	print "\n"
        end
CODE
4
12
4
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "or_i_i (|)");
 	set I0, 0b001100
 	set I1, 0b010110
 	or I2, I0,I1
 	print I2
 	print "\n"
 	or I1,I0,I1
 	print I1
 	print "\n"
 	print I0
 	print "\n"
        end
CODE
30
30
12
OUTPUT

output_is(<<'CODE', <<'OUTPUT', "or_i_ic (|)");
 	set I0, 0b001100
 	or I2, I0,0b010110
 	print I2
 	print "\n"
 	print I0
 	print "\n"
 	or I0,I0,0b010110
 	print I0
 	print "\n"
        end
CODE
30
12
30
OUTPUT

# use C<and> to only check low order bits, this should be platform nice
output_is(<<'CODE', <<'OUTPUT', "not_i (~)");
	set	I0, 0b001100
	set	I1, 0b001100
	set	I31, 0b111111
	not	I2, I0
	and	I2, I2, I31
	print	I2
	print	"\n"
	not	I1, I1
	and	I1, I1, I31
	print	I1
	print	"\n"
	print	I0
	print	"\n"
        end
CODE
51
51
12
OUTPUT
1;
