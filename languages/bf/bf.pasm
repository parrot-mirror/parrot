# $Id$
# A Brainfuck interpreter
# By Leon Brocard <acme@astray.com>
#
# See http://www.catseye.mb.ca/esoteric/bf/
# for more information on this silly language

  # Get the brainfuck source file into S0
  set S0, P0[1]
  if S0, SOURCE
  set S0, P0[0]
  print "usage: ./parrot "
  print S0
  print " file.bf\n"
  end

  # Read the file into S1
SOURCE:
  open P1, S0, "<"
SOURCE_LOOP:
  readline S2, P1
  concat S1, S2
  if S2, SOURCE_LOOP
  close P1

  length I30, S1

  # Initialise

  set I0, 0          # Our PC
  new P0, .PerlArray # Our memory
  set I1, 0          # Our pointer

  # The main interpreter loop
INTERP:
  substr S0, S1, I0, 1
  ne S0, "+", NOTPLUS
  set I2, P0[I1]
  inc I2
  set P0[I1], I2
  branch NEXT

NOTPLUS:
  ne S0, "-", NOTMINUS
  set I2, P0[I1]
  dec I2
  set P0[I1], I2
  branch NEXT

NOTMINUS:
  ne S0, ">", NOTGT
  inc I1
  branch NEXT

NOTGT:
  ne S0, "<", NOTLT
  dec I1
  branch NEXT

NOTLT:
  ne S0, "[", NOTOPEN

  set I2, P0[I1]
  if I2, NEXT
  set I2, 0 # "depth"

OPEN_LOOP:
  inc I0
  substr S2, S1, I0, 1
  ne S2, "[", OPEN_NOTOPEN
  inc I2
  branch OPEN_LOOP
OPEN_NOTOPEN:
  ne S2, "]", OPEN_LOOP
  eq I2, 0, NEXT
  dec I2
  branch OPEN_LOOP

NOTOPEN:
  ne S0, "]", NOTCLOSE
  set I2, 0 # "height"

CLOSE_LOOP:
  dec I0
  substr S2, S1, I0, 1
  ne S2, "]", CLOSE_NOTCLOSE
  inc I2
  branch CLOSE_LOOP
CLOSE_NOTCLOSE:
  ne S2, "[", CLOSE_LOOP
  eq I2, 0, INTERP
  dec I2
  branch CLOSE_LOOP

NOTCLOSE:
  ne S0, ".", NOTDOT
  set I2, P0[I1]
  chr S31, I2
  print S31
  branch NEXT

NOTDOT:
  ne S0, ",", NEXT
  getstdin P30
  readline S31, P30
  ord I2, S31
  set P0[I1], I2
  branch NEXT

NEXT:
  inc I0
  le I0, I30, INTERP
  end


