#! perl

use Parrot::Test tests => 5;

output_is(<<'CODE', <<OUTPUT, "simple set / get");
	new P0, PerlHash
	set S0, "one"
	set S1, "two"

	set P0, 1, S0		# $P0{one} = 1
	set P0, 2, S1		# $P0{two} = 2

	set I0, P0, S0
	set I1, P0, S1

	print I0
	print "\n"
	print I1
	print "\n"
    end
CODE
1
2
OUTPUT

output_is(<<'CODE', <<OUTPUT, "hash keys with nulls in them");
	new P0, PerlHash
	set S0, "parp\0me"
	set S1, "parp\0you"

	set P0, 1, S0		# $P0{parp\0me} = 1
	set P0, 2, S1		# $P0{parp\0you} = 2

	set I0, P0, S0
	set I1, P0, S1

	print I0
	print "\n"
	print I1
	print "\n"
    end
CODE
1
2
OUTPUT

output_is(<<'CODE', <<OUTPUT, "nearly the same hash keys");
	new P0, PerlHash
	set S0, "a\0"
	set S1, "\0a"

	set P0, 1, S0
	set P0, 2, S1

	set I0, P0, S0
	set I1, P0, S1

	print I0
	print "\n"
	print I1
	print "\n"

	end
CODE
1
2
OUTPUT

output_is(<<'CODE', <<OUTPUT, "The same hash keys");
	new P0, PerlHash
	set S0, "Happy"
	set S1, "Happy"

	set P0, 1, S0
	set I0, P0, S0
	print I0
	print "\n"

	set P0, 2, S1
	set I1, P0, S1

	print I1
	print "\n"

	end
CODE
1
2
OUTPUT

output_is(<<'CODE', <<OUTPUT, "size of the hash");
	new P0, PerlHash
	
	set P0, 1, 1
	set I0, P0
	print I0
	print "\n"	

	set P0, 1, 2
	set I0, P0
	print I0
	print "\n"	

	set P0, 1, 1
	set I0, P0
	print I0
	print "\n"	

	end
CODE
1
2
2
OUTPUT

1;
