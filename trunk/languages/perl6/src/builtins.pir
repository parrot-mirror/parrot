## $Id$

.namespace [ "" ]

.sub 'print'
    .param pmc list            :slurpy
    .local pmc iter

    iter = new .Iterator, list
  iter_loop:
    unless iter goto iter_end
    $P0 = shift iter
    print $P0
    goto iter_loop
  iter_end:
    .return (1)
.end


.sub 'say'
    .param pmc list            :slurpy
    'print'(list :flat)
    print "\n"
    .return (1)
.end


.sub 'list'
    .param pmc list            :slurpy
    .return (list)
.end


.sub 'use'
    .param pmc list            :slurpy
    .return ()
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


## exponentiation
.sub 'infix:**'
    .param num base
    .param num exp
    $N0 = pow base, exp
    .return ($N0)
.end


## symbolic unary
.sub 'prefix:!'
    .param pmc a
    $I0 = isfalse a
    .return ($I0)
.end


.sub 'prefix:+'
    .param pmc a
    $N0 = a
    .return ($N0)
.end


.sub 'prefix:-'
    .param pmc a
    $N0 = a
    $N0 = neg $N0
    .return ($N0)
.end


.sub 'prefix:~'
    .param pmc a
    $S0 = a
    .return ($S0)
.end


.sub 'prefix:?'
    .param pmc a
    $I0 = istrue a
    .return ($I0)
.end


## TODO: prefix:= prefix:* prefix:** prefix:~^ prefix:+^


.sub 'prefix:?^'
    .param pmc a
    $I0 = isfalse a
    .return ($I0)
.end


## TODO: prefix:^


## multiplicative
.sub 'infix:*'
    .param pmc a
    .param pmc b
    $P0 = mul a, b
    .return ($P0)
.end


.sub 'infix:/'
    .param pmc a
    .param pmc b
    $P0 = div a, b
    .return ($P0)
.end


.sub 'infix:%'
    .param num a
    .param num b
    $N0 = mod a, b
    .return ($N0)
.end


.sub 'infix:x'
    .param string a
    .param int b
    $S0 = repeat a, b
    .return ($S0)
.end


.sub 'infix:xx'
    .param string a
    .param int b
    $P0 = new ResizablePMCArray
  lp:
    unless b, ex
    push $P0, a
    dec b
    branch lp
  ex:
    .return ($P0)
.end


.sub 'infix:+&'
    .param int a
    .param int b
    $I0 = band a, b
    .return ($I0)
.end


.sub 'infix:+<'
    .param int a
    .param int b
    $I0 = shl a, b
    .return ($I0)
.end


.sub 'infix:+>'
    .param int a
    .param int b
    $I0 = shr a, b
    .return ($I0)
.end


.sub 'infix:~&'
    .param string a
    .param string b
    $S0 = bands a, b
    .return ($S0)
.end


## TODO: infix:~< infix:~>


## additive
.sub 'infix:+'
    .param pmc a
    .param pmc b
    $P0 = add a, b
    .return ($P0)
.end


.sub 'infix:-'
    .param pmc a
    .param pmc b
    $P0 = sub a, b
    .return ($P0)
.end


.sub 'infix:~'
    .param string a
    .param string b
    $S0 = concat a, b
    .return ($S0)
.end


.sub 'infix:+|'
    .param int a
    .param int b
    $I0 = bor a, b
    .return ($I0)
.end


.sub 'infix:+^'
    .param int a
    .param int b
    $I0 = bxor a, b
    .return ($I0)
.end


.sub 'infix:~|'
    .param string a
    .param string b
    $S0 = bors a, b
    .return ($S0)
.end


.sub 'infix:~^'
    .param string a
    .param string b
    $S0 = bxors a, b
    .return ($S0)
.end


.sub 'infix:?|'
    .param int a
    .param int b
    $I0 = bor a, b
    ## istrue_i_i doesn't exist
    $P0 = $I0
    $I0 = istrue $P0
    .return ($I0)
.end


.sub 'infix:?^'
    .param int a
    .param int b
    $I0 = bxor a, b
    ## istrue_i_i doesn't exist
    $P0 = $I0
    $I0 = istrue $P0
    .return ($I0)
.end


## TODO: infix:& infix:| infix:^


## named unary
.sub 'prefix:abs'
    .param pmc a
    $P0 = abs a
    .return ($P0)
.end


## nonchaining binary
## infix:but infix:does infix:cmp infix:<=> infix:.. infix:^.. infix:..^
## infix:^..^ infix:ff infix:^ff infix:ff^ infix:^ff^ infix:fff infix:^fff


## chaining binary
.sub 'infix:=='
    .param pmc a
    .param pmc b
    $I0 = cmp_num a, b
    $I0 = iseq $I0, 0
    .return ($I0)
.end


.sub 'infix:!='
    .param pmc a
    .param pmc b
    $I0 = cmp_num a, b
    $I0 = isne $I0, 0
    .return ($I0)
.end


.sub 'infix:<'
    .param pmc a
    .param pmc b
    $I0 = cmp_num a, b
    $I0 = islt $I0, 0
    .return ($I0)
.end


.sub 'infix:<='
    .param pmc a
    .param pmc b
    $I0 = cmp_num a, b
    $I0 = isle $I0, 0
    .return ($I0)
.end


.sub 'infix:>'
    .param pmc a
    .param pmc b
    $I0 = cmp_num a, b
    $I0 = isgt $I0, 0
    .return ($I0)
.end


.sub 'infix:>='
    .param pmc a
    .param pmc b
    $I0 = cmp_num a, b
    $I0 = isge $I0, 0
    .return ($I0)
.end


## TODO: infix:~~ infix:!~ infix:=~


.sub 'infix:eq'
    .param pmc a
    .param pmc b
    $I0 = cmp_str a, b
    $I0 = iseq $I0, 0
    .return ($I0)
.end


.sub 'infix:ne'
    .param pmc a
    .param pmc b
    $I0 = cmp_str a, b
    $I0 = isne $I0, 0
    .return ($I0)
.end


.sub 'infix:lt'
    .param pmc a
    .param pmc b
    $I0 = cmp_str a, b
    $I0 = islt $I0, 0
    .return ($I0)
.end


.sub 'infix:le'
    .param pmc a
    .param pmc b
    $I0 = cmp_str a, b
    $I0 = isle $I0, 0
    .return ($I0)
.end


.sub 'infix:gt'
    .param pmc a
    .param pmc b
    $I0 = cmp_str a, b
    $I0 = isgt $I0, 0
    .return ($I0)
.end


.sub 'infix:ge'
    .param pmc a
    .param pmc b
    $I0 = cmp_str a, b
    $I0 = isge $I0, 0
    .return ($I0)
.end


## TODO: infix:=:= infix:===


## tight and
## TODO: infix:&&


## tight or
## TODO: infix:|| infix:^^ infix://



## ternary
## TODO: ternary:?? !!


## assignment
.sub 'infix:='
    .param pmc a
    .param pmc b
    a = b
    .return (a)
.end


## TODO: infix::= infix:::= infix:.=


.sub 'infix:~='
    .param string a
    .param string b
    concat a, b
    .return (a)
.end


.sub 'infix:+='
    .param pmc a
    .param pmc b
    a += b
    .return (a)
.end


.sub 'infix:-='
    .param pmc a
    .param pmc b
    a -= b
    .return (a)
.end


.sub 'infix:*='
    .param pmc a
    .param pmc b
    a *= b
    .return (a)
.end


.sub 'infix:/='
    .param pmc a
    .param pmc b
    a /= b
    .return (a)
.end


.sub 'infix:%='
    .param pmc a
    .param pmc b
    a %= b
    .return (a)
.end


.sub 'infix:x='
    .param pmc a
    .param pmc b
    repeat a, a, b
    .return (a)
.end


## TODO: infix:Y=
.sub 'infix:**='
    .param pmc a
    .param pmc b
    a = a ** b
    .return (a)
.end


## TODO: infix:xx= infix:||= infix:&&= infix://= infix:^^=


.sub 'infix:+<='
    .param pmc a
    .param pmc b
    a <<= b
    .return (a)
.end


.sub 'infix:+>='
    .param pmc a
    .param pmc b
    a >>= b
    .return (a)
.end


.sub 'infix:+&='
    .param pmc a
    .param pmc b
    band a, b
    .return (a)
.end


.sub 'infix:+|='
    .param pmc a
    .param pmc b
    bor a, b
    .return (a)
.end


.sub 'infix:+^='
    .param pmc a
    .param pmc b
    bxor a, b
    .return (a)
.end


.sub 'infix:~&='
    .param pmc a
    .param pmc b
    a = bands a, b
    .return (a)
.end


.sub 'infix:~|='
    .param pmc a
    .param pmc b
    bors a, b
    .return (a)
.end


.sub 'infix:~^='
    .param pmc a
    .param pmc b
    bxors a, b
    .return (a)
.end


.sub 'infix:?&='
    .param pmc a
    .param pmc b
    band a, b
    $I0 = istrue a
    a = $I0
    .return (a)
.end


.sub 'infix:?|='
    .param pmc a
    .param pmc b
    bor a, b
    $I0 = istrue a
    a = $I0
    .return (a)
.end


.sub 'infix:?^='
    .param pmc a
    .param pmc b
    bxor a, b
    $I0 = istrue a
    a = $I0
    .return (a)
.end


## TODO: infix:|= infix:&= infix:^=


.sub 'die'
    .param pmc list            :slurpy
    .local pmc iter
    .local string message

    message = ''
    iter = new .Iterator, list
  iter_loop:
    unless iter goto iter_end
    $P0 = shift iter
    $S0 = $P0
    message .= $S0
    goto iter_loop
  iter_end:
    $P0 = new .Exception
    $P0['_message'] = message
    throw $P0
    .return ()
.end

## vim: expandtab sw=4
