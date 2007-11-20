=head1 NAME

PAST::Compiler - PAST Compiler

=head1 DESCRIPTION

PAST::Compiler implements a basic compiler for PAST nodes.
By default PAST::Compiler transforms a PAST tree into POST,
and then invokes POST::Compiler on the resulting POST tree.

=over

=cut

.namespace [ 'PAST::Compiler' ]

.sub '__onload' :load :init
    $P99 = subclass 'PCT::HLLCompiler', 'PAST::Compiler'
    $P0 = new 'PAST::Compiler'
    $P0.'language'('PAST')

    .local pmc piropsig
    piropsig = new 'Hash'
    piropsig['n_add'] = 'PP+'
    piropsig['n_sub'] = 'PP+'
    piropsig['n_mul'] = 'PP+'
    piropsig['n_div'] = 'PP+'
    set_global '%piropsig', piropsig

    .return ()
.end


=item compile(node, ['target'=>target, ...])

Compile the abstract syntax tree given by C<past> into the form
given by C<target>.  Current targets include "past", "post", "pir";
if no C<target> is supplied then the abstract syntax tree is compiled
to executable code (but not executed).

=cut

.sub 'compile' :method
    .param pmc past
    .param pmc options         :slurpy :named

    .return self.'post'(past)
.end


.sub 'post_children' :method
    .param pmc node
    .param pmc options         :slurpy :named

    .local pmc ops
    $P0 = get_hll_global ['POST'], 'Ops'
    ops = $P0.'new'('node'=>node)

    ##  get any conversion types
    .local string signature
    signature = options['signature']
    if signature goto have_signature
    signature = '**'
  have_signature:
    .local int sigmax, sigidx
    sigmax = length signature
    dec sigmax

    ##  if the signature contains a ':', then we're doing 
    ##  flagged arguments (:flat, :named)
    $I0 = index signature, ':'
    if $I0 < 0 goto nocolon
    .local pmc posargs, namedargs
    posargs = new 'ResizableStringArray'
    namedargs = new 'ResizableStringArray'
  nocolon:

    .local pmc iter
    .local string rtype
    .local int sigidx
    iter = node.'iterator'()
    sigidx = 1
    rtype = substr signature, sigidx, 1
  iter_loop:
    unless iter goto iter_end
    .local pmc cpast, cpost
    cpast = shift iter
    cpost = self.'post'(cpast, 'rtype'=>rtype)
    ops.'push'(cpost)
    if rtype != ':' goto iter_rtype
    .local pmc npast, npost
    npast = cpast.'named'()
    if npast goto iter_named
    push posargs, cpost
    goto iter_rtype
  iter_named:
    npost = self.'post'(npast, 'rtype'=>'~')
    ops.'push'(npost)
    $S0 = cpost
    $S1 = npost
    concat $S0, ' :named('
    concat $S0, $S1
    concat $S0, ')'
    push namedargs, $S0
  iter_rtype:
    unless sigidx < sigmax goto iter_loop
    inc sigidx
    rtype = substr signature, sigidx, 1
    goto iter_loop
  iter_end:
    .return (ops, posargs, namedargs)
.end


.sub 'post' :method :multi(_, _)
    .param pmc node
    .param pmc options         :slurpy :named
    $P0 = node.'get_array'()
    $I0 = elements $P0
    $S0 = repeat '*', $I0
    concat $S0, 'P'
    .local pmc ops
    ops = self.'post_children'(node, 'signature'=>$S0)
    $P0 = ops[-1]
    ops.'result'($P0)
    .return (ops)
.end


.sub 'post' :method :multi(_, ['PAST::Block'])
    .param pmc node
    .param pmc options         :slurpy :named

    .local string name
    name = node.'name'()
    if name goto have_name
    name = node.'unique'('_block')
  have_name:

    .local string blocktype
    blocktype = node.'blocktype'()

    ##  create a POST::Sub node for this block
    .local pmc bpost
    $P0 = get_hll_global ['POST'], 'Sub'
    bpost = $P0.'new'('node'=>node, 'name'=>name, 'blocktype'=>blocktype)

    ##  all children but last can return anything, last returns PMC
    $P0 = node.'get_array'()
    $I0 = elements $P0
    $S0 = repeat '*', $I0
    concat $S0, 'P'
    ##  convert children to post
    .local pmc ops
    ops = self.'post_children'(node, 'signature'=>$S0)
    bpost.'push'(ops)
    ##  result of last child is return from block
    $P0 = ops[-1]
    bpost.'push_pirop'('return', $P0)

    unless blocktype == 'immediate' goto block_done
    .local string rtype, result
    result = ''
    rtype = options['rtype']
    if rtype == '*' goto have_result
    result = bpost.'unique'('$P')
  have_result:
    $P0 = get_hll_global ['POST'], 'Ops'
    bpost = $P0.'new'(bpost, 'node'=>node, 'result'=>result)
    name = bpost.'escape'(name)
    bpost.'push_pirop'('call', name, 'result'=>result)
  block_done:
    .return (bpost)
.end
    

.sub 'post' :method :multi(_, ['PAST::Op'])
    .param pmc node
    .param pmc options         :slurpy :named

    .local string pasttype
    pasttype = node.'pasttype'()
    unless pasttype goto post_pirop
    $P0 = find_method self, pasttype
    .return self.$P0(node, options :flat :named)
 
  post_pirop:
    .return self.'pirop'(node, options :flat :named)
.end


.sub 'pirop' :method :multi(_, ['PAST::Op'])
    .param pmc node
    .param pmc options         :slurpy :named

    .local string pirop, signature
    pirop = node.'pirop'()
    $P0 = get_global '%piropsig'
    signature = $P0[pirop]
    if signature goto have_signature
    signature = 'vP'
  have_signature:

    .local pmc ops
    ops = self.'post_children'(node, 'signature'=>signature)

    .local string result
    result = ops.'unique'('$P')
    ops.'result'(result)

    .local pmc arglist
    arglist = ops.'get_array'()
    ops.'push_pirop'(pirop, result, arglist :flat)
    .return (ops)
.end


.sub 'call' :method :multi(_, ['PAST::Op'])
    .param pmc node
    .param pmc options         :slurpy :named

    .local pmc ops, posargs, namedargs
    .local string name
    name = node.'name'()
    unless name goto call_first_arg
    (ops, posargs, namedargs) = self.'post_children'(node, 'signature'=>'v:')
    name = ops.'escape'(name)
    unshift posargs, name
    goto children_done
  call_first_arg:
    (ops, posargs, namedargs) = self.'post_children'(node, 'signature'=>'v~:')
  children_done:

    .local string result, rtype
    result = ''
    rtype = options['rtype']
    if rtype == '*' goto result_done
    result = ops.'unique'('$P')
    ops.'result'(result)
  result_done:

    ops.'push_pirop'('call', posargs :flat, namedargs :flat, 'result'=>result)
    .return (ops)
.end


.sub 'if' :method :multi(_,['PAST::Op'])
    .param pmc node
    .param pmc options         :slurpy :named

    .local string pasttype
    pasttype = node.'pasttype'()
 
    .local pmc ops 
    $P0 = get_hll_global ['POST'], 'Ops'
    ops = $P0.'new'('node'=>node)

    .local pmc exprpast, thenpast, elsepast
    .local pmc exprpost, thenpost, elsepost
    exprpast = node[0]
    thenpast = node[1]
    elsepast = node[2]

    .local pmc thenlabel, endlabel
    $P0 = get_hll_global ['POST'], 'Label'
    $S0 = concat pasttype, '_'
    $S0 = ops.'unique'($S0)
    thenlabel = $P0.'new'('result'=>$S0)
    $S0 = concat $S0, '_end'
    endlabel = $P0.'new'('result'=>$S0)

    exprpost = self.'post'(exprpast, 'rtype'=>'P')
    ops.'push'(exprpost)
    ops.'result'(exprpost)
    ops.'push_pirop'(pasttype, exprpost, thenlabel)
    $I0 = defined elsepast
    unless $I0 goto else_done
    elsepost = self.'post'(elsepast, 'rtype'=>'P')
    ops.'push'(elsepost)
    ops.'push_pirop'('set', ops, elsepost)
  else_done:
    ops.'push_pirop'('goto', endlabel)
    ops.'push'(thenlabel)
    $I0 = defined thenpast
    unless $I0 goto then_done
    thenpost = self.'post'(thenpast, 'rtype'=>'P')
    ops.'push'(thenpost)
    ops.'push_pirop'('set', ops, thenpost)
  then_done:
    ops.'push'(endlabel)
    .return (ops)
.end


.sub 'unless' :method :multi(_, ['PAST::Op'])
    .param pmc node
    .param pmc options         :slurpy :named
    .return self.'if'(node, options :flat :named)
.end


.sub 'post' :method :multi(_, ['PAST::Val'])
    .param pmc node
    .param pmc options         :slurpy :named

    .local pmc ops
    $P0 = get_hll_global ['POST'], 'Ops'
    ops = $P0.'new'('node'=>node)

    .local pmc value
    .local int isstr
    value = node.'value'()
    isstr = isa value, 'String'

    .local string rtype
    rtype = options['rtype']
    if rtype == '+' goto result_num
    if rtype == 'P' goto result_pmc
    if rtype == '~' goto result_string
    unless isstr goto result_num
  result_string:
    value = ops.'escape'(value)
  result_num:
    ops.'result'(value)
    .return (ops)

  result_pmc:
    .local string result, vtype
    result = ops.'unique'('$P')
    vtype = typeof value
    vtype = ops.'escape'(vtype)
    unless isstr goto have_value
    value = ops.'escape'(value)
  have_value:
    ops.'push_pirop'('new', result, vtype)
    ops.'push_pirop'('assign', result, value)
    ops.'result'(result)
    .return (ops)
.end

    
=back

=head1 AUTHOR

Patrick Michaud <pmichaud@pobox.com> is the author and maintainer.
Please send patches and suggestions to the Parrot porters or
Perl 6 compilers mailing lists.

=head1 HISTORY

2006-11-20  Patrick Michaud added first draft of POD documentation.
2006-11-27  Significant refactor into separate modules.

=head1 COPYRIGHT

Copyright (C) 2006, The Perl Foundation.

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
