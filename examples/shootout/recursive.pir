#!./parrot
#
# Ack by Leopold Toetsch
# Fib and Tak by Joshua Isom
# modified default value to n=3. Karl Forner
# ./parrot -Oc -R cgp-jit recursive.pir N

.sub main :main
	.param pmc argv
	.local int argc, n
	argc = argv
	n = 3
	unless argc == 2 goto argsok
	$S0 = argv[1]
	n = $S0
argsok:
    $P0 = getinterp
    $P0.'recursion_limit'(100000)

	.local pmc array
	array = new 'FixedFloatArray'
	array = 11

	dec n

	$I0 = n + 1
	$I1 = ack(3, $I0)
	array[0] = $I0
	array[1] = $I1

	$N0 = 28.0 + n
	array[2] = $N0
	$N0 = FibNum($N0)
	array[3] = $N0

	$I0 = n * 3
	$I1 = n * 2
	array[4] = $I0
	array[5] = $I1
	array[6] = n
	$I0 = TakInt($I0, $I1, n)
	array[7] = $I0

	$I0 = FibInt(3)
	array[8] = $I0

	$N0 = TakNum(3.0, 2.0, 1.0)
	array[9] = $N0

	$S0 = sprintf <<"END", array
Ack(3,%d): %d
Fib(%.1f): %.1f
Tak(%d,%d,%d): %d
Fib(3): %d
Tak(3.0,2.0,1.0): %.1f
END
	print $S0
.end

.sub ack
	.param int x
	.param int y
	if x goto a1
	$I0 = y + 1
	.return ($I0)
a1:
	if y goto a2
	$I0 = x - 1
	$I1 = 1
	.tailcall ack($I0, $I1)
a2:
	$I2 = y - 1
	$I3 = ack(x, $I2)
	$I4 = x - 1
	.tailcall ack($I4, $I3)
.end

.sub FibInt
	.param int n
	unless n < 2 goto endif
	.return(1)
endif:
	.local int tmp
	tmp = n - 2
	$I0 = FibInt(tmp)
	tmp = n - 1
	$I1 = FibInt(tmp)
	$I0 += $I1
	.return($I0)
.end

.sub FibNum
	.param num n
	unless n < 2 goto endif
	.return(1.0)
endif:
	.local num tmp
	tmp = n - 2
	$N0 = FibNum(tmp)
	tmp = n - 1
	$N1 = FibNum(tmp)
	$N0 += $N1
	.return($N0)
.end

.sub TakNum
	.param num x
	.param num y
	.param num z
	unless y >= x goto endif
	.return(z)
endif:
	.local num tmp
	tmp = x - 1.0
	$N0 = TakNum(tmp, y, z)
	tmp = y - 1.0
	$N1 = TakNum(tmp, z, x)
	tmp = z - 1.0
	$N2 = TakNum(tmp, x, y)
	.tailcall TakNum($N0, $N1, $N2)
.end

.sub TakInt
	.param int x
	.param int y
	.param int z
	unless y >= x goto endif
	.return(z)
endif:
	.local int tmp
	tmp = x - 1
	$I0 = TakInt(tmp, y, z)
	tmp = y - 1
	tmp = TakInt(tmp, z, x)
	dec z
	z = TakInt(tmp, x, y)
	.tailcall TakInt($I0, tmp, z)
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
