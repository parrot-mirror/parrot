#! perl

use Parrot::Test tests => 11;
use Test::More;

output_is(<<'CODE', <<OUTPUT, "simple set / get");
	new P0, .PerlHash
	set S0, "one"
	set S1, "two"

	set P0, S0, 1		# $P0{one} = 1
	set P0, S1, 2		# $P0{two} = 2

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

output_is(<<'CODE', <<OUTPUT, "more than one PerlHash");
	new P0, .PerlHash
	set S0, "key"
	set P0, S0, 1
		
        new P1, .PerlHash
        set S1, "another_key"
        set P1, S1, 2

	set I0, P0, S0
	set I1, P1, S1

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
	new P0, .PerlHash
	set S0, "parp\0me"
	set S1, "parp\0you"

	set P0, S0, 1		# $P0{parp\0me} = 1
	set P0, S1, 2		# $P0{parp\0you} = 2

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
	new P0, .PerlHash
	set S0, "a\0"
	set S1, "\0a"

	set P0, S0, 1
	set P0, S1, 2

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
	new P0, .PerlHash
	set S0, "Happy"
	set S1, "Happy"

	set P0, S0, 1
	set I0, P0, S0
	print I0
	print "\n"

	set P0, S1, 2
	set I1, P0, S1

	print I1
	print "\n"

	end
CODE
1
2
OUTPUT

output_is(<<'CODE', <<OUTPUT, "size of the hash");
	new P0, .PerlHash
	
	set P0, 0, 1
	set I0, P0
	print I0
	print "\n"	

	set P0, 1, 1
	set I0, P0
	print I0
	print "\n"	

	set P0, 0, 1
	set I0, P0
	print I0
	print "\n"	

	end
CODE
1
2
2
OUTPUT


# NB Next test depends on "key2" hashing to zero, which it does with
# the current algorithm; if the algorithm changes, change the test!

output_is(<<'CODE', <<OUTPUT, "key that hashes to zero");
        new P0, .PerlHash
        set S0, "key2"
        set P0, S0, 1
        set I0, P0, S0
	print I0
	print "\n"	
	end
CODE
1
OUTPUT

output_is(<<CODE, <<OUTPUT, "Initial PerlHash tests");
	new	P0, .PerlHash

	set	P0, "foo", -7
	set	P0, "bar", 3.5
	set	P0, "baz", "value"

	set	I0, P0, "foo"
	set	N0, P0, "bar"
	set	S0, P0, "baz"

	eq	I0,-7,OK_1
	print	"not "
OK_1:	print	"ok 1\\n"
	eq	N0,3.500000,OK_2
	print	N0
OK_2:	print	"ok 2\\n"
	eq	S0,"value",OK_3
	print	S0
OK_3:	print	"ok 3\\n"

	end
CODE
ok 1
ok 2
ok 3
OUTPUT

output_is(<<CODE, <<OUTPUT, "stress test: loop(set, check)");
	new	P0, .PerlHash

        set I0, 200
        set S0, "mikey"
        set P0, S0, "base"
        concat S1, S0, "s"
        set P0, S1, "bases"
        set S2, I0
        concat S1, S0, S2
        set P0, S1, "start"
        set S3, P0, "mikey"
        print S3
        print "\\n"
        set S3, P0, "mikeys"
        print S3
        print "\\n"
        set S3, P0, "mikey200"
        print S3
        print "\\n"
LOOP:
        eq I0, 0, DONE
        sub I0, I0, 1
        set S2, I0
        concat S1, S0, S2
        concat S4, S0, S2
        eq S1, S4, L1
        print "concat mismatch: "
        print S1
        print " vs "
        print S4
        print "\\n"
L1:
        set P0, S1, I0
        set I1, P0, S1
        eq I0, I1, L2
        print "lookup mismatch: "
        print I0
        print " vs "
        print I1
        print "\\n"
L2:
        branch LOOP
DONE:
        set I0, P0, "mikey199"
        print I0
        print "\\n"
        set I0, P0, "mikey117"
        print I0
        print "\\n"
        set I0, P0, "mikey1"
        print I0
        print "\\n"
        set I0, P0, "mikey23"
        print I0
        print "\\n"
        set I0, P0, "mikey832"
        print I0
        print "\\n"
        end
CODE
base
bases
start
199
117
1
23
0
OUTPUT

# Check all values after setting all of them
output_is(<<CODE, <<OUTPUT, "stress test: loop(set), loop(check)");
	new	P0, .PerlHash

        set I0, 200
        set S0, "mikey"
SETLOOP:
        eq I0, 0, DONE
        sub I0, I0, 1
        set S2, I0
        concat S1, S0, S2
        set P0, S1, I0
        branch SETLOOP

        set I0, 200
GETLOOP:
        eq I0, 0, DONE
        sub I0, I0, 1
        set S2, I0
        concat S1, S0, S2
        set I1, P0, S1
        eq I0, I1, L2
        print "lookup mismatch: "
        print I0
        print " vs "
        print I1
        print "\\n"
L2:
        branch GETLOOP

DONE:
        print "done\\n"
        end
CODE
done
OUTPUT

SKIP: { skip("Trying to do multidimensional hashes. This will change.",1);
output_is(<<CODE, <<OUTPUT, "String as keys");
        new P0,.PerlHash
        new P1,.PerlArray
        new P2,.PerlArray
        set P1[4],"string"
        set P0,"one",P1
        set P2,P0,"one"
        set S0,P2[4]
        print S0
        print "\\n"
        end   
CODE
string
OUTPUT
}

1;
