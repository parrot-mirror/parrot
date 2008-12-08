## $Id$

=head1 NAME

src/builtins/inplace.pir - Inplace assignments

=head1 Functions

=over 4

=cut


.namespace []
.sub 'infix:=' :multi(_,_)
    .param pmc cont
    .param pmc source

    $I0 = isa source, 'ObjectRef'
    if $I0 goto have_source
    $I0 = can source, 'Scalar'
    if $I0 goto can_scalar
    ##  source comes from outside Rakudo's type system
    $I0 = does source, 'scalar'
    if $I0 goto have_source
    source = new 'ObjectRef', source
    goto have_source
  can_scalar:
    source = source.'Scalar'()
  have_source:
    .local pmc ro, type
    getprop ro, 'readonly', cont
    if null ro goto ro_ok
    unless ro goto ro_ok
    'die'('Cannot assign to readonly variable.')
  ro_ok:
    $I0 = defined source
    unless $I0 goto do_assign
    getprop type, 'type', cont
    if null type goto do_assign
    $I0 = type.'ACCEPTS'(source)
    if $I0 goto do_assign
    'die'("Type mismatch in assignment.")
  do_assign:
    eq_addr cont, source, skip_copy
    copy cont, source
  skip_copy:
    .return (cont)
.end

.sub 'infix:=' :multi(['Perl6Array'], _)
    .param pmc cont
    .param pmc source
    $I0 = isa cont, 'ObjectRef'
    unless $I0 goto cont_array
    # FIXME: use a :subid to directly lookup and call infix:=(_,_) above
    $P0 = get_hll_global 'Object'
    setref cont, $P0
    .tailcall 'infix:='(cont, source)

  cont_array:
    .local pmc list, it
    ## empty the array
    assign cont, 0
    source = source.'list'()
    source.'!flatten'()
    it = iter source
  array_loop:
    unless it goto array_done
    $P0 = shift it
    $P0 = $P0.'Scalar'()
    $P0 = clone $P0
    push cont, $P0
    goto array_loop
  array_done:
    .return (cont)
.end


.sub 'infix:=' :multi(['Perl6Hash'], _)
    .param pmc cont
    .param pmc source
    $I0 = isa cont, 'ObjectRef'
    unless $I0 goto cont_hash
    # FIXME: use a :subid to directly lookup and call infix:=(_,_) above
    $P0 = get_hll_global 'Object'
    setref cont, $P0
    .tailcall 'infix:='(cont, source)

  cont_hash:
    $P0 = source.'hash'()
    copy cont, $P0
    .return (cont)
.end


.sub '!REDUCEMETAOP'
    .param string opname
    .param pmc identity
    .param pmc args                # already :slurpy array by caller

    args.'!flatten'()
    if args goto reduce
    if identity == 'fail' goto fail
    .return (identity)

  fail:
    .tailcall '!FAIL'()

  reduce:
    opname = concat 'infix:', opname
    .local pmc opfunc
    opfunc = find_name opname
    .local pmc result
    result = shift args
  reduce_loop:
    unless args goto reduce_done
    $P0 = shift args
    result = opfunc(result, $P0)
    goto reduce_loop
  reduce_done:
    .return (result)
.end


.sub '!ASSIGNMETAOP'
    .param string opname
    .param pmc a
    .param pmc b

    $I0 = defined a
    if $I0 goto have_a
    $S0 = concat 'prefix:[', opname
    concat $S0, ']'
    $P1 = find_name $S0
    $P0 = $P1()
    'infix:='(a, $P0)
  have_a:

    opname = concat 'infix:', opname
    $P1 = find_name opname
    $P0 = $P1(a, b)
    'infix:='(a, $P0)
    .return (a)
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
