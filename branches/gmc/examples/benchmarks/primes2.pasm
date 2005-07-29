# Copyright (C) 2001-2003 The Perl Foundation.  All rights reserved.
# $Id$

=head1 NAME

examples/benchmarks/primes2.pasm - Calculate prime numbers < 10000

=head1 SYNOPSIS

    % time ./parrot examples/benchmarks/primes2.pasm

=head1 DESCRIPTION

Calculates all the prime numbers up to 10000 and prints out the number
of primes and the last one found.

=cut

new P1, .PerlInt
set P1, 0
new P3, .PerlInt
set P3, 0
new P4, .PerlInt
set P4, 5000
new P6, .PerlInt
new P7, .PerlInt

LOOP:
  save P1
  bsr PRIMECHECK
  restore P9
  unless P9, NOTPRIME
#ISPRIME:
  inc P6
  assign P7, P1
NOTPRIME:
  inc P1
  ne P1,P4, LOOP

DONE:
  print"N primes calculated to "
  print P1
  print " is "
  print P6
  print "\n"
  print "last is: "
  print P7
  print "\n"
  end

PRIMECHECK:
 saveall
 restore P5
 lt P5,1,ret0
new P6, .PerlInt
 assign P6,P5
 dec P6
NLOOP:
  le P6, 1, ret1
new P7, .PerlInt
  cmod P7, P5, P6
  eq P7, 0, ret0
  dec P6
  branch NLOOP
  # is prime
ret1:
  new P0, .PerlInt
  set P0, 1
  save P0
  restoreall
  ret
ret0:
  new P0, .PerlInt
  set P0, 0
  save P0
  restoreall
  ret

=head1 SEE ALSO

F<examples/benchmarks/primes.c>,
F<examples/benchmarks/primes.pasm>,
F<examples/benchmarks/primes.pl>,
F<examples/benchmarks/primes2_i.pasm>,
F<examples/benchmarks/primes2.c>,
F<examples/benchmarks/primes2.py>.

=cut

