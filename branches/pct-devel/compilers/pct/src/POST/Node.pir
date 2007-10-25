=head1 NAME

POST - Parrot opcode syntax tree

=head1 DESCRIPTION

This file implements the various opcode syntax tree nodes
for compiling programs in Parrot.

=cut

.namespace [ 'POST' ]

.sub '__onload' :load :init
    .local pmc protomaker, base

    ##  create POST classes
    protomaker = new 'Protomaker'
    $P0 = get_class 'PAST::Node'
    base = protomaker.'new_subclass'($P0 , 'POST::Node')
    $P0  = protomaker.'new_subclass'(base, 'POST::Op')
    $P0  = protomaker.'new_subclass'(base, 'POST::Ops')
    $P0  = protomaker.'new_subclass'(base, 'POST::Val')
    $P0  = protomaker.'new_subclass'(base, 'POST::Var')
    $P0  = protomaker.'new_subclass'(base, 'POST::Label')
    $P0  = protomaker.'new_subclass'(base, 'POST::Sub')

    ##  initialize %pirsig with opcode argument types
    .local pmc pirsig
    pirsig = new 'Hash'
    pirsig['n_add'] = 'PP+'
    pirsig['n_sub'] = 'PP+'
    pirsig['n_mul'] = 'PP+'
    pirsig['n_div'] = 'PP+'
    set_hll_global ['POST'], '%pirsig', pirsig

    .return ()
.end


=head1 POST Node types

=head2 POST::Node

C<POST::Node> is the base class for all POST nodes.  It's derived from class
C<PAST::Node> (see F<compilers/pct/src/PAST/Node.pir>).

=over 4

=item result([value] [, argtype :named('argtype')])

Get/set the result for this node.

=cut

.namespace ['POST::Node']

.sub 'result' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .param string argtype      :optional :named('argtype')
    .param int has_argtype     :opt_flag

    .local pmc result
    result = self.'attr'('result', value, has_value)
    #  if setting the result, we're done
    unless has_value goto coerce_result
    .return (result)

  coerce_result:
    #  if querying result, see if we need to delegate call
    $I0 = isa result, 'POST::Node'
    if $I0 == 0 goto have_result
    result = result.'result'()
  have_result:
    .return (result, '')
.end

=back

=head2 POST::Ops

C<POST::Ops> contains an array of POST nodes to be evaluated in
sequence.

=over 4

=item pir()

=cut

.namespace ['POST::Ops']

.sub 'pir' :method
    .local pmc code, iter
    code = new 'CodeString'
    iter = self.'iterator'()
  iter_loop:
    unless iter goto iter_end
    .local pmc cpost
    cpost = shift iter
    $P0 = cpost.'pir'()
    code .= $P0
    goto iter_loop
  iter_end:
    .return (code)
.end

=back

=head2 POST::Op

C<POST::Op> node represent operations to be performed.
Arguments to the operation are given by child nodes
(which are assumed to have been evaluated prior to
evaluating the C<POST::Op> node).

=cut

.namespace ['POST::Op']

.sub 'pir' :method
    .local string pirop
    pirop = self.'pirop'()

    .local pmc code
    code = new 'CodeString'

    #  get operation's signature
    .local string pirsig
    $P0 = get_hll_global ['POST'], '%pirsig'
    pirsig = $P0[pirop]
    if pirsig goto have_pirsig
    pirsig = 'vPPPPPPPPPPPPPPPP'
  have_pirsig:

    # evaluate children nodes according to signature
    .local pmc iter, arglist
    .local int argindex
    arglist = new 'ResizableStringArray'
    argindex = 1
    iter = self.'iterator'()
  iter_loop:
    unless iter goto iter_end
    .local pmc cpost
    cpost = shift iter
    $S0 = substr pirsig, argindex, 1
    ($S1, $P1) = cpost.'result'('argtype'=>$S0)
    push arglist, $S1
    code .= $P1
    inc argindex
    goto iter_loop
  iter_end:

    # determine result
    .local string result
    result = ''
    $S0 = substr pirsig, 0, 1
    $I0 = index "0123456789PSIN", $S0
    if $I0 > 9 goto psin_result
    if $I0 >= 0 goto arg_result
    if $S0 == 'v' goto have_result
    result = code.'unique'('$P')
    unshift arglist, result
    if $S0 != 'u' goto have_result
    code.'emit'("    %r = new 'Undef'", 'r'=>result)
    goto have_result
  arg_result:
    result = arglist[$I0]
    goto have_result
  psin_result:
    $S0 = concat '$', $S0
    result = code.'unique'($S0)
    unshift arglist, result
  have_result:
    self.'result'(result)

    code.'emit'("    %n %,", arglist :flat, 'n'=>pirop)
    .return (code)
.end

.sub 'pirop' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .return self.'attr'('pirop', value, has_value)
.end

=back

=head2 POST::Val

C<POST::Val> nodes represent constant values in PIR.

=over 4

=item value([value])

Get/set the constant value for this node.

=cut

.namespace [ 'POST::Val' ]

.sub 'value' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .return self.'attr'('value', value, has_value)
.end

.sub 'pir' :method
     .return ('')
.end

.sub 'result' :method
    .param string argtype      :optional :named('argtype')
    .param int has_argtype     :opt_flag

    .local pmc code, value
    code = new 'CodeString'
    value = self.'value'()

    unless has_argtype goto p_result
    if argtype == '+' goto nc_result

  p_result:
    .local string result, vtype
    result = code.'unique'('$P')
    vtype = typeof value
    $I0 = isa value, 'String'
    unless $I0 goto esc_value
    value = code.'escape'(value)
  esc_value:
    vtype = code.'escape'(vtype)
    code.'emit'("    %r = new %0\n    assign %r, %1", vtype, value, 'r'=>result)
    .return (result, code)

  nc_result:
    $N0 = value
    .return ($N0, code)
.end


=head2 POST::Sub

C<POST::Sub> nodes represent PIR subroutines.

=over 4

=item pir()

Generate PIR for this subroutine.

=cut

.namespace [ 'POST::Sub' ]

.sub 'pir' :method
    .local pmc code
    code = new 'CodeString'

    .local string name
    name = self.'name'()
    name = code.'escape'(name)
  have_name:
    .local string outer
    .local pmc outerpost
    outer = ''
    outerpost = self.'outer'()
    if null outerpost goto have_outer
    unless outerpost goto have_outer
    outer = outerpost.'name'()
    outer = code.'escape'(outer)
    outer = concat ':outer(', outer
    outer = concat outer, ')'
  have_outer:
    .local string pragma
    pragma = self.'pragma'()
  have_pragma:
    code.'emit'("\n.sub %0 %1 %2", name, outer, pragma)
    .local pmc iter, cpost
    iter = self.'iterator'()
  iter_loop:
    unless iter goto iter_end
    cpost = shift iter
    $P1 = cpost.'pir'()
    code .= $P1
    goto iter_loop
  iter_end:
    code.'emit'(".end\n")
    $P0 = get_hll_global ['POST'], '$!subpir'
    code .= $P0
    set_hll_global ['POST'], '$!subpir', code

    code = new 'CodeString'
    $S0 = self.'blocktype'()
    if $S0 == 'declaration' goto skip_declaration
    code.'emit'("    $P0 = find_name %0", name)
  skip_declaration:
    .return (code)
.end

=item outer([outer])

Get/set the C<POST::Sub> that is the outer lexical scope of the
current sub.

=cut

.sub 'outer' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .return self.'attr'('outer', value, has_value)
.end

=item pragma([pragma])

Get/set any pragmas for the current sub node.

=cut

.sub 'pragma' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .return self.'attr'('pragma', value, has_value)
.end

=item blocktype([type])

=cut

.sub 'blocktype' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .return self.'attr'('blocktype', value, has_value)
.end


