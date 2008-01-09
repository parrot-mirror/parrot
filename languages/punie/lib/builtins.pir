.namespace

.sub 'infix:=='
    .param pmc a
    .param pmc b
    $I1 = a
    $I2 = b
    $I3 = iseq $I1, $I2
    $P1 = new 'Integer'
    $P1 = $I3
    .return($P1)
.end

.sub 'infix:!='
    .param pmc a
    .param pmc b
    $I1 = a
    $I2 = b
    $I3 = isne $I1, $I2
    $P1 = new 'Integer'
    $P1 = $I3
    .return($P1)
.end

.sub 'infix:<'
    .param pmc a
    .param pmc b
    $I1 = a
    $I2 = b
    $I3 = islt $I1, $I2
    $P1 = new 'Integer'
    $P1 = $I3
    .return($P1)
.end

.sub 'infix:>'
    .param pmc a
    .param pmc b
    $I1 = a
    $I2 = b
    $I3 = isgt $I1, $I2
    $P1 = new 'Integer'
    $P1 = $I3
    .return($P1)
.end

.sub 'infix:<='
    .param pmc a
    .param pmc b
    $I1 = a
    $I2 = b
    $I3 = isle $I1, $I2
    $P1 = new 'Integer'
    $P1 = $I3
    .return($P1)
.end

.sub 'infix:>='
    .param pmc a
    .param pmc b
    $I1 = a
    $I2 = b
    $I3 = isge $I1, $I2
    $P1 = new 'Integer'
    $P1 = $I3
    .return($P1)
.end

.sub 'infix:eq'
    .param pmc a
    .param pmc b
    $S1 = a
    $S2 = b
    $I1 = iseq $S1, $S2
    $P1 = new 'Integer'
    $P1 = $I1
    .return($P1)
.end

.sub 'infix:ne'
    .param pmc a
    .param pmc b
    $S1 = a
    $S2 = b
    $I1 = isne $S1, $S2
    $P1 = new 'Integer'
    $P1 = $I1
    .return($P1)
.end

.sub 'infix:lt'
    .param pmc a
    .param pmc b
    $S1 = a
    $S2 = b
    $I1 = islt $S1, $S2
    $P1 = new 'Integer'
    $P1 = $I1
    .return($P1)
.end

.sub 'infix:gt'
    .param pmc a
    .param pmc b
    $S1 = a
    $S2 = b
    $I1 = isgt $S1, $S2
    $P1 = new 'Integer'
    $P1 = $I1
    .return($P1)
.end

.sub 'infix:le'
    .param pmc a
    .param pmc b
    $S1 = a
    $S2 = b
    $I1 = isle $S1, $S2
    $P1 = new 'Integer'
    $P1 = $I1
    .return($P1)
.end

.sub 'infix:ge'
    .param pmc a
    .param pmc b
    $S1 = a
    $S2 = b
    $I1 = isge $S1, $S2
    $P1 = new 'Integer'
    $P1 = $I1
    .return($P1)
.end

.sub 'infix:x'
    .param string a
    .param int b
    $S0 = repeat a, b
    .return ($S0)
.end

.sub 'infix:<<'
    .param int a
    .param int b
    $I0 = shl a, b
    $P0 = new 'Integer'
    $P0 = $I0
    .return ($P0)
.end

.sub 'infix:>>'
    .param int a
    .param int b
    $I0 = shr a, b
    $P0 = new 'Integer'
    $P0 = $I0
    .return ($P0)
.end

.sub 'infix:&'
    .param int a
    .param int b
    $I0 = band a, b
    $P0 = new 'Integer'
    $P0 = $I0
    .return ($P0)
.end

.sub 'infix:|'
    .param int a
    .param int b
    $I0 = bor a, b
    $P0 = new 'Integer'
    $P0 = $I0
    .return ($P0)
.end

.sub 'infix:^'
    .param int a
    .param int b
    $I0 = bxor a, b
    $P0 = new 'Integer'
    $P0 = $I0
    .return ($P0)
.end

## autoincrement
.sub 'postfix:++'
    .param pmc a
    $P0 = clone a
    inc a
    .return ($P0)
.end

.sub 'postfix:--'
    .param pmc a
    $P0 = clone a
    dec a
    .return ($P0)
.end


.sub 'prefix:++'
    .param pmc a
    inc a
    .return (a)
.end


.sub 'prefix:--'
    .param pmc a
    dec a
    .return (a)
.end

.sub 'prefix:-'
    .param pmc a
    $N0 = a
    $N0 = neg $N0
    .return ($N0)
.end

## not implemented yet!
.sub 'prefix:~'
    .param pmc a
    .return (a)
.end

.sub 'prefix:!'
    .param pmc a
    $P0 = a
    .return ($P0)
.end

.sub 'print'
    .param pmc list            :slurpy
    .local pmc iter

    iter = new 'Iterator', list
  iter_loop:
    unless iter goto iter_end
    $P0 = shift iter
    print $P0
    goto iter_loop
  iter_end:
    .return (1)
.end

.sub 'infix:,'
    .param pmc args            :slurpy
    .return (args)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

