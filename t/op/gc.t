#! perl -w

use Parrot::Test tests => 5;

output_is( <<'CODE', '1', "sweep" );
      interpinfo I1, 2   # How many DOD runs have we done already?
      sweep
      interpinfo I2, 2   # Should be one more now
      sub I3, I2, I1
      print I3
      end
CODE

output_is( <<'CODE', '1', "collect" );
      interpinfo I1, 3   # How many garbage collections have we done already?
      collect
      interpinfo I2, 3   # Should be one more now
      sub I3, I2, I1
      print I3
      end
CODE

output_is( <<'CODE', <<'OUTPUT', "collectoff/on" );
      interpinfo I1, 3
      collectoff
      collect
      interpinfo I2, 3
      sub I3, I2, I1
      print I3
      print "\n"

      collecton
      collect
      interpinfo I4, 3
      sub I6, I4, I2
      print I6
      print "\n"

      end
CODE
0
1
OUTPUT

output_is( <<'CODE', <<'OUTPUT', "Nested collectoff/collecton" );
      interpinfo I1, 3
      collectoff
      collectoff
      collecton
      collect           # This shouldn't do anything...
      interpinfo I2, 3
      sub I3, I2, I1
      print I3
      print "\n"

      collecton
      collect           # ... but this should
      interpinfo I4, 3
      sub I6, I4, I2
      print I6
      print "\n"

      end
CODE
0
1
OUTPUT

output_is(<<'CODE', <<OUTPUT, "sweepoff with newpmcs");
    print "starting\n"

    sweepoff
    set I0, 0

LOOP: new P0, .PerlString
    set P0, "ABC"
    save P0
    inc I0
    lt I0, 127, LOOP

    print "ending\n"
	
    end
CODE
starting
ending
OUTPUT
