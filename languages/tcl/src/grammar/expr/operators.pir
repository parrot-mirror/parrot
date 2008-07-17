# $Id$

=head1 NAME

src/grammar/expr/operators.pir - [expr] operator definitions.

=head2 Prefix Operators

=cut

.HLL 'Tcl', ''
.namespace []

# unary plus
.sub 'prefix:+' :multi(String)
    .param pmc a

    .local pmc toNumber
    toNumber = get_root_global ['_tcl'], 'toNumber'

    push_eh is_string
      a = toNumber(a)
    pop_eh

    .return(a)

is_string:
    if a == '' goto empty_string
    die "can't use non-numeric string as operand of \"+\""

empty_string:
    die "can't use empty string as operand of \"+\""
.end

.sub 'prefix:+' :multi(pmc)
    .param pmc a
    .return(a)
.end

# unary minus
.sub 'prefix:-' :multi(String)
    .param pmc a

    .local pmc toNumber
    toNumber  = get_root_global ['_tcl'], 'toNumber'

    push_eh is_string
      a = toNumber(a)
    pop_eh
    $S0 = typeof a
    if $S0 == "TclInt" goto is_int

    $N0 = a
    $N0 = neg $N0
    .return($N0)

is_int:
    $I0 = a
    $I0 = neg $I0
    .return($I0)

is_string:
    if a == '' goto empty_string
    die "can't use non-numeric string as operand of \"-\""

empty_string:
    die "can't use empty string as operand of \"-\""
.end

.sub 'prefix:-' :multi(pmc)
    .param pmc a
    .local pmc b
    b = clone a
    b = -b
    .return(b)
.end

# bit-wise NOT
.sub 'prefix:~' :multi(String)
    .param pmc a

    .local pmc toNumber
    toNumber = get_root_global ['_tcl'], 'toNumber'

    push_eh is_string
      a = toNumber(a)
    pop_eh

    $S0 = typeof a
    if $S0 == 'TclFloat' goto cant_use_float

    $I0 = a
    $I0 = bnot $I0
    .return($I0)

cant_use_float:
    die "can't use floating-point value as operand of \"~\""

is_string:
    if a == '' goto empty_string
    die "can't use non-numeric string as operand of \"~\""

empty_string:
    die "can't use empty string as operand of \"~\""
.end

.sub 'prefix:~' :multi(Float)
    die "can't use floating-point value as operand of \"~\""
.end

.sub 'prefix:~' :multi(pmc)
    .param int a
    $I0 = bnot a
    .return ($I0)
.end

# logical NOT
.sub 'prefix:!' :multi(String)
    .param pmc a

    .local pmc __boolean
    __boolean = get_root_global ['_tcl'], '__boolean'

    push_eh is_string
      a = __boolean(a)
    pop_eh

    $I0 = a
    $I0 = not $I0
    .return($I0)

is_string:
    if a == '' goto empty_string
    die "can't use non-numeric string as operand of \"!\""

empty_string:
    die "can't use empty string as operand of \"!\""
.end

.sub 'prefix:!' :multi(pmc)
    .param int a
    $I0 = not a
    .return ($I0)
.end

=head2 Infix Operators

&&, || (and ?:) are handled during the PGE transformation stage.

=cut

# this is used to make double-quoted strings work
# (they're a series of captures that need to be concatenated)
.sub 'infix:concat'
    .param pmc a
    .param pmc b

    $S0 = a
    $S1 = b
    $S0 = $S0 . $S1

    $P0 = new 'TclString'
    $P0 = $S0
    .return($P0)
.end

.sub 'infix:**'
    .param pmc a
    .param pmc b

    .local pmc toNumber
    toNumber = get_root_global ['_tcl'], 'toNumber'

    push_eh is_string
      a = toNumber(a)
      b = toNumber(b)
    pop_eh

    if a == 0 goto zero

    $P0 = new 'TclFloat'
    $P0 = pow a, b
    .return ($P0)

is_string:
    if a == '' goto empty_string
    if b == '' goto empty_string
    die "can't use non-numeric string as operand of \"**\""

empty_string:
    die "can't use empty string as operand of \"**\""

zero:
    if b < 0 goto zero_with_neg
    if b == 0 goto zero_with_zero
    .return(0)

zero_with_zero:
    .return(1)
zero_with_neg:
     die 'exponentiation of zero by negative power'
.end

.sub 'infix:*'
    .param pmc a
    .param pmc b

    .local pmc toNumber
    toNumber = get_root_global ['_tcl'], 'toNumber'

    push_eh is_string
      a = toNumber(a)
      b = toNumber(b)
      $P0 = new 'TclFloat'
      $P0 = mul a, b
    pop_eh
    .return ($P0)

is_string:
    if a == '' goto empty_string
    if b == '' goto empty_string
    die "can't use non-numeric string as operand of \"*\""

empty_string:
    die "can't use empty string as operand of \"*\""
.end

.sub 'infix:/'
    .param pmc a
    .param pmc b

    .local pmc toNumber
    toNumber = get_root_global ['_tcl'], 'toNumber'

    push_eh is_string
      a = toNumber(a)
      b = toNumber(b)
    pop_eh

    if b == 0 goto divide_by_zero

    $P0 = new 'TclFloat'
    $P0 = div a, b
    .return($P0)

divide_by_zero:
    $P0 = new 'TclList'
    $P0[0] = 'ARITH'
    $P0[1] = 'DIVZERO'
    $S0 = 'divide by zero'
    $P0[2] = $S0
    tcl_error $S0,  $P0

is_string:
    if a == '' goto empty_string
    if b == '' goto empty_string
    die "can't use non-numeric string as operand of \"/\""

empty_string:
    die "can't use empty string as operand of \"/\""
.end

.sub 'infix:%'
    .param pmc a
    .param pmc b

    .local pmc toNumber
    toNumber = get_root_global ['_tcl'], 'toNumber'

    push_eh is_string
      a = toNumber(a)
      b = toNumber(b)
    pop_eh

    $I0 = isa a, 'TclFloat'
    if $I0 goto is_float
    $I0 = isa b, 'TclFloat'
    if $I0 goto is_float

    $P0 = new 'TclInt'
    $P0 = mod a, b
    .return($P0)

is_string:
    if a == '' goto empty_string
    if b == '' goto empty_string
    die "can't use non-numeric string as operand of \"%\""

empty_string:
    die "can't use empty string as operand of \"%\""

is_float:
    die "can't use floating-point value as operand of \"%\""
.end

.sub 'infix:+'
    .param pmc a
    .param pmc b

    .local pmc toNumber
    toNumber = get_root_global ['_tcl'], 'toNumber'

    push_eh is_string
      a = toNumber(a)
      b = toNumber(b)
      $P0 = new 'TclFloat'
      $P0 = a + b
    pop_eh
    .return($P0)

is_string:
    if a == '' goto empty_string
    if b == '' goto empty_string
    die "can't use non-numeric string as operand of \"+\""

empty_string:
    die "can't use empty string as operand of \"+\""
.end

.sub 'infix:-'
    .param pmc a
    .param pmc b

    .local pmc toNumber
    toNumber = get_root_global ['_tcl'], 'toNumber'

    push_eh is_string
      a = toNumber(a)
      b = toNumber(b)
      $P0 = new 'TclFloat'
      $P0 = a - b
    pop_eh
    .return($P0)

is_string:
    if a == '' goto empty_string
    if b == '' goto empty_string
    die "can't use non-numeric string as operand of \"-\""

empty_string:
    die "can't use empty string as operand of \"-\""
.end

# left shift
.sub 'infix:<<'     :multi(Float, pmc)
  die "can't use floating-point value as operand of \"<<\""
.end

.sub 'infix:<<'     :multi(pmc, Float)
  die "can't use floating-point value as operand of \"<<\""
.end

.sub 'infix:<<'     :multi(Integer, Integer)
    .param int a
    .param int b

    $I0 = shl a, b
    .return($I0)
.end

.sub 'infix:<<'     :multi(pmc, pmc)
    .param pmc a
    .param pmc b

    .local pmc toNumber
    toNumber = get_root_global ['_tcl'], 'toNumber'

    push_eh is_string
      a = toNumber(a)
      b = toNumber(b)
    pop_eh

    $I0 = isa a, 'Float'
    if $I0 goto is_float
    $I0 = isa b, 'Float'
    if $I0 goto is_float

    $I0 = a
    $I1 = b
    $I0 = shl $I0, $I1
    .return ($I0)

is_string:
    if a == '' goto empty_string
    if b == '' goto empty_string
    die "can't use non-numeric string as operand of \"<<\""

empty_string:
    die "can't use empty string as operand of \"<<\""

is_float:
  die "can't use floating-point value as operand of \"<<\""
.end

# right shift
.sub 'infix:>>'     :multi(Float, pmc)
  die "can't use floating-point value as operand of \">>\""
.end

.sub 'infix:>>'     :multi(pmc, Float)
  die "can't use floating-point value as operand of \">>\""
.end

.sub 'infix:>>'     :multi(Integer, Integer)
    .param int a
    .param int b
    $I0 = shr a, b
    .return ($I0)
.end

.sub 'infix:>>'     :multi(pmc, pmc)
    .param pmc a
    .param pmc b

    .local pmc toNumber
    toNumber = get_root_global ['_tcl'], 'toNumber'

    push_eh is_string
      a = toNumber(a)
      b = toNumber(b)
    pop_eh

    $I0 = isa a, 'Float'
    if $I0 goto is_float
    $I0 = isa b, 'Float'
    if $I0 goto is_float

    $I0 = a
    $I1 = b
    $I0 = shr $I0, $I1
    .return ($I0)

is_string:
    if a == '' goto empty_string
    if b == '' goto empty_string
    die "can't use non-numeric string as operand of \">>\""

empty_string:
    die "can't use empty string as operand of \">>\""

is_float:
    die "can't use floating-point value as operand of \">>\""
.end

# *ALL* operands
.sub 'infix:<'     # boolean less than
    .param pmc a
    .param pmc b

    .local pmc toNumber
    toNumber = get_root_global ['_tcl'], 'toNumber'
    push_eh is_string
      $P0 = toNumber(a)
      $P1 = toNumber(b)
      $I0 = islt $P0, $P1
    pop_eh
    .return ($I0)

is_string:
    $I0 = islt a, b
    .return($I0)
.end

# *ALL* operands
.sub 'infix:>'     # boolean greater than
    .param pmc a
    .param pmc b

    .local pmc toNumber
    toNumber = get_root_global ['_tcl'], 'toNumber'
    push_eh is_string
      $P0 = toNumber(a)
      $P1 = toNumber(b)
      $I0 = isgt $P0, $P1
    pop_eh
    .return($I0)

is_string:
    $I0 = isgt a, b
    .return ($I0)
.end

# *ALL* operands
.sub 'infix:<='    # boolean less than or equal
    .param pmc a
    .param pmc b

    .local pmc toNumber
    toNumber = get_root_global ['_tcl'], 'toNumber'

    push_eh is_string
      $P0 = toNumber(a)
      $P1 = toNumber(b)
      $I0 = isle $P0, $P1
    pop_eh
    .return($I0)

is_string:
    $I0 = isle a, b
    .return ($I0)
.end

# *ALL* operands
.sub 'infix:>='    # boolean greater than or equal
    .param pmc a
    .param pmc b

    .local pmc toNumber
    $P0 = get_root_namespace
    toNumber = $P0['_tcl'; 'toNumber']

    push_eh is_string
      $P0 = toNumber(a)
      $P1 = toNumber(b)
      $I0 = isge $P0, $P1
    pop_eh
    .return($I0)

is_string:
    $I0 = isge a, b
    .return ($I0)
.end

# *ALL* operands
.sub 'infix:=='    # boolean equal
    .param pmc a
    .param pmc b

    .local pmc toNumber
    $P0 = get_root_namespace
    toNumber = $P0['_tcl'; 'toNumber']

    push_eh is_string
      $P0 = toNumber(a)
      $P1 = toNumber(b)
      $I0 = iseq $P0, $P1
    pop_eh
    .return($I0)

is_string:
    $S0 = a
    $S1 = b
    $I0 = iseq $S0, $S1
    .return ($I0)
.end

# *ALL* operands
.sub 'infix:!='    # boolean not equal
    .param pmc a
    .param pmc b

    .local pmc toNumber
    $P0 = get_root_namespace
    toNumber = $P0['_tcl'; 'toNumber']

    push_eh is_string
      $P0 = toNumber(a)
      $P1 = toNumber(b)
      $I0 = isne $P0, $P1
    pop_eh
    .return($I0)

is_string:
    $S0 = a
    $S1 = b
    $I0 = isne $S0, $S1
    .return ($I0)
.end

.sub 'infix:eq'    # string equality
    .param string a
    .param string b
    $I0 = iseq a, b
    .return ($I0)
.end

.sub 'infix:ne'    # string inequality
    .param pmc a
    .param pmc b

    $S0 = a
    $S1 = b
    $I0 = isne $S0, $S1
    .return ($I0)
.end


# bitwise AND
.sub 'infix:&'     :multi(String, String)
  .param pmc a
  .param pmc b

  .local pmc toInteger
  toInteger = get_root_global ['_tcl'], 'toInteger'

  push_eh is_string
    a = toInteger(a)
    b = toInteger(b)
  pop_eh

  $I0 = a
  $I1 = b
  $I0 = band $I0, $I1
  .return($I0)

is_string:
    if a == '' goto empty_string
    if b == '' goto empty_string
    die "can't use non-numeric string as operand of \"&\""

empty_string:
    die "can't use empty string as operand of \"&\""
.end

.sub 'infix:&'     :multi(String, Integer)
  .param pmc a
  .param int b

  .local pmc toInteger
  toInteger = get_root_global ['_tcl'], 'toInteger'

  push_eh is_string
    a = toInteger(a)
  pop_eh

  $I0 = a
  $I0 = band $I0, b
  .return($I0)

is_string:
    if a == '' goto empty_string
    die "can't use non-numeric string as operand of \"&\""

empty_string:
    die "can't use empty string as operand of \"&\""
.end

.sub 'infix:&'     :multi(Integer, String)
  .param int a
  .param pmc b

  .local pmc toInteger
  toInteger = get_root_global ['_tcl'], 'toInteger'

  push_eh is_string
    b = toInteger(b)
  pop_eh

  $I0 = b
  $I0 = band a, $I0
  .return($I0)

is_string:
    if b == '' goto empty_string
    die "can't use non-numeric string as operand of \"&\""

empty_string:
    die "can't use empty string as operand of \"&\""
.end

.sub 'infix:&'     :multi(Float, String)
    .param pmc a
    .param pmc b

    .local pmc toInteger
    toInteger = get_root_global ['_tcl'], 'toInteger'

    push_eh is_string
        b = toInteger(b)
    pop_eh
    die "can't use floating-point value as operand of \"&\""

is_string:
    if b == '' goto empty_string
    die "can't use non-numeric string as operand of \"&\""

empty_string:
    die "can't use empty string as operand of \"&\""
.end

.sub 'infix:&'     :multi(String, Float)
    .param pmc a
    .param pmc b

    .local pmc toInteger
    toInteger = get_root_global ['_tcl'], 'toInteger'

    push_eh is_string
        a = toInteger(a)
    pop_eh
    die "can't use floating-point value as operand of \"&\""

is_string:
    if a == '' goto empty_string
    die "can't use non-numeric string as operand of \"&\""

empty_string:
    die "can't use empty string as operand of \"&\""
.end

.sub 'infix:&'     :multi(Float, pmc)
  die "can't use floating-point value as operand of \"&\""
.end

.sub 'infix:&'     :multi(pmc, Float)
  die "can't use floating-point value as operand of \"&\""
.end

.sub 'infix:&'     :multi(Integer, Integer)
    .param int a
    .param int b
    $I0 = band a, b
    .return ($I0)
.end


# bitwise exclusive OR
.sub 'infix:^'     :multi(String, String)
  .param pmc a
  .param pmc b

  .local pmc toInteger
  toInteger = get_root_global ['_tcl'], 'toInteger'

  push_eh is_string
    a = toInteger(a)
    b = toInteger(b)
  pop_eh

  $I0 = a
  $I1 = b
  $I0 = bxor $I0, $I1
  .return($I0)

is_string:
    if a == '' goto empty_string
    if b == '' goto empty_string
    die "can't use non-numeric string as operand of \"^\""

empty_string:
    die "can't use empty string as operand of \"^\""
.end

.sub 'infix:^'     :multi(String, Integer)
  .param pmc a
  .param int b

  .local pmc toInteger
  toInteger = get_root_global ['_tcl'], 'toInteger'

  push_eh is_string
    a = toInteger(a)
  pop_eh

  $I0 = a
  $I0 = bxor $I0, b
  .return($I0)

is_string:
    if a == '' goto empty_string
    die "can't use non-numeric string as operand of \"^\""

empty_string:
    die "can't use empty string as operand of \"^\""
.end

.sub 'infix:^'     :multi(Integer, String)
  .param int a
  .param pmc b

  .local pmc toInteger
  toInteger = get_root_global ['_tcl'], 'toInteger'

  push_eh is_string
    b = toInteger(b)
  pop_eh

  $I0 = b
  $I0 = bxor a, $I0
  .return($I0)

is_string:
    if b == '' goto empty_string
    die "can't use non-numeric string as operand of \"^\""

empty_string:
    die "can't use empty string as operand of \"^\""
.end

.sub 'infix:^'     :multi(Float, String)
    .param pmc a
    .param pmc b

    .local pmc toInteger
    toInteger = get_root_global ['_tcl'], 'toInteger'

    push_eh is_string
        b = toInteger(b)
    pop_eh
    die "can't use floating-point value as operand of \"^\""

is_string:
    if b == '' goto empty_string
    die "can't use non-numeric string as operand of \"^\""

empty_string:
    die "can't use empty string as operand of \"^\""
.end

.sub 'infix:^'     :multi(String, Float)
    .param pmc a
    .param pmc b

    .local pmc toInteger
    toInteger = get_root_global ['_tcl'], 'toInteger'

    push_eh is_string
        a = toInteger(a)
    pop_eh
    die "can't use floating-point value as operand of \"^\""

is_string:
    if a == '' goto empty_string
    die "can't use non-numeric string as operand of \"^\""

empty_string:
    die "can't use empty string as operand of \"^\""
.end

.sub 'infix:^'     :multi(Float, pmc)
  die "can't use floating-point value as operand of \"^\""
.end

.sub 'infix:^'     :multi(pmc, Float)
  die "can't use floating-point value as operand of \"^\""
.end

.sub 'infix:^'     :multi(Integer, Integer)
    .param int a
    .param int b
    $I0 = bxor a, b
    .return ($I0)
.end


# bitwise OR
.sub 'infix:|'     :multi(String, String)
  .param pmc a
  .param pmc b

  .local pmc toInteger
  toInteger = get_root_global ['_tcl'], 'toInteger'

  push_eh is_string
    a = toInteger(a)
    b = toInteger(b)
  pop_eh

  $I0 = a
  $I1 = b
  $I0 = bor $I0, $I1
  .return($I0)

is_string:
    if a == '' goto empty_string
    if b == '' goto empty_string
    die "can't use non-numeric string as operand of \"|\""

empty_string:
    die "can't use empty string as operand of \"|\""
.end

.sub 'infix:|'     :multi(String, Integer)
  .param pmc a
  .param int b

  .local pmc toInteger
  toInteger = get_root_global ['_tcl'], 'toInteger'

  push_eh is_string
    a = toInteger(a)
  pop_eh

  $I0 = a
  $I0 = bor $I0, b
  .return($I0)

is_string:
    if a == '' goto empty_string
    die "can't use non-numeric string as operand of \"|\""

empty_string:
    die "can't use empty string as operand of \"|\""
.end

.sub 'infix:|'     :multi(Integer, String)
  .param int a
  .param pmc b

  .local pmc toInteger
  toInteger = get_root_global ['_tcl'], 'toInteger'

  push_eh is_string
    b = toInteger(b)
  pop_eh

  $I0 = b
  $I0 = bor a, $I0
  .return($I0)

is_string:
    if b == '' goto empty_string
    die "can't use non-numeric string as operand of \"|\""

empty_string:
    die "can't use empty string as operand of \"|\""
.end

.sub 'infix:|'     :multi(Float, String)
    .param pmc a
    .param pmc b

    .local pmc toInteger
    toInteger = get_root_global ['_tcl'], 'toInteger'

    push_eh is_string
        b = toInteger(b)
    pop_eh
    die "can't use floating-point value as operand of \"|\""

is_string:
    if b == '' goto empty_string
    die "can't use non-numeric string as operand of \"|\""

empty_string:
    die "can't use empty string as operand of \"|\""
.end

.sub 'infix:|'     :multi(String, Float)
    .param pmc a
    .param pmc b

    .local pmc toInteger
    toInteger = get_root_global ['_tcl'], 'toInteger'

    push_eh is_string
        a = toInteger(a)
    pop_eh
    die "can't use floating-point value as operand of \"|\""

is_string:
    if a == '' goto empty_string
    die "can't use non-numeric string as operand of \"|\""

empty_string:
    die "can't use empty string as operand of \"|\""
.end

.sub 'infix:|'     :multi(Float, pmc)
  die "can't use floating-point value as operand of \"|\""
.end

.sub 'infix:|'     :multi(pmc, Float)
  die "can't use floating-point value as operand of \"|\""
.end

.sub 'infix:|'     :multi(Integer, Integer)
    .param int a
    .param int b
    $I0 = bor a, b
    .return ($I0)
.end


.sub 'infix:in'
    .param pmc elem
    .param pmc list

    .local pmc toList
    $P0 = get_root_namespace
    toList = $P0['_tcl'; 'toList']

    .local pmc iter
    list = toList(list)
    iter = new 'Iterator', list
loop:
    unless iter goto false
    $P0 = shift iter
    $I0 = 'infix:=='(elem, $P0)
    if $I0 goto true
    goto loop
true:
    .return(1)
false:
    .return(0)
.end

.sub 'infix:ni'
    .param pmc elem
    .param pmc list

    .local pmc toList
    $P0 = get_root_namespace
    toList = $P0['_tcl'; 'toList']

    .local pmc iter
    list = toList(list)
    iter = new 'Iterator', list
loop:
    unless iter goto true
    $P0 = shift iter
    $I0 = 'infix:=='(elem, $P0)
    if $I0 goto false
    goto loop
true:
    .return(1)
false:
    .return(0)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
