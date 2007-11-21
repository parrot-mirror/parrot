=head1 NAME

PAST::Compiler - PAST Compiler

=head1 DESCRIPTION

PAST::Compiler implements a basic compiler for PAST nodes.
By default PAST::Compiler transforms a PAST tree into POST,
and then invokes POST::Compiler on the resulting POST tree.

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

=head2 Compiler methods

=over 4

=item compile(node, ['target'=>target, ...])

Compile the abstract syntax tree given by C<past> into the form
given by C<target>.  Current targets include "past", "post", "pir";
if no C<target> is supplied then the abstract syntax tree is compiled
to executable code (but not executed).

=cut

.sub 'compile' :method
    .param pmc past
    .param pmc options         :slurpy :named

    .local pmc blockpast
    blockpast = get_global '@?BLOCK'
    unless null blockpast goto have_blockpast
    blockpast = new 'ResizablePMCArray'
    set_global '@?BLOCK', blockpast
  have_blockpast:
    .return self.'post'(past)
.end

=item post_children(node [, 'signature'=>signature] )

Return the POST representation of evaluating all of C<node>'s
children in sequence.  The C<signature> option is a string of
characters that allow the caller to suggest the type of
result that should be returned by each child:

    *     Anything
    P     PMC register
    +     PMC, numeric register, or numeric constant
    ~     PMC, string register, or string constant
    :     Argument (same as '*'), possibly with :named or :flat

The first character of C<signature> is ignored (return type),
thus C<v~P*> says that the first child needs to be something
in string context, the second child should be a PMC, and the
third and subsequent children can be any value they wish.

=cut

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

=back

=head2 Methods on C<PAST::Node> arguments

The methods below are used to transform PAST nodes into their
POST equivalents.

=head3 Defaults

=over 4

=item post(node)

Return a POST representation of C<node>.  Note that C<post> is
a multimethod based on the type of its first argument, this is
the method that is called when no other methods match.

If C<node> is an instance of C<PAST::Node>  (meaning that none
of the other C<post> multimethods were invoked), then return
the POST representation of C<node>'s children, with the result
of the node being the result of the last child.

If C<node> revaluates to false, return an empty POST node.

Otherwise, C<node> is treated as a string, and a POST node
is returned to create a new object of the type given by C<node>.
This is useful for vivifying values with a simple type name
instead of an entire PAST structure.

=cut

.sub 'post' :method :multi(_, _)
    .param pmc node
    .param pmc options         :slurpy :named

    .local pmc ops
    $I0 = isa node, 'PAST::Node'
    if $I0 goto from_past
    unless node goto from_nothing
  from_string:
    .local string result
    $P0 = get_hll_global ['PAST'], 'Op'
    result = $P0.'unique'('$P')
    $S0 = $P0.'escape'(node)
    .return $P0.'new'(result, $S0, 'pirop'=>'new', 'result'=>result)

  from_nothing:
    $P0 = get_hll_global ['PAST'], 'Ops'
    result = $P0.'unique'('$P')
    .return $P0.'new'('node'=>node, 'result'=>result)

  from_past:
    $P0 = node.'get_array'()
    $I0 = elements $P0
    $S0 = repeat '*', $I0
    concat $S0, 'P'
    ops = self.'post_children'(node, 'signature'=>$S0)
    $P0 = ops[-1]
    ops.'result'($P0)
    .return (ops)
.end

=back

=head3 C<PAST::Block>

=over 4

=item post(PAST::Block node)

Return the POST representation of a C<PAST::Block>.

=cut

.sub 'post' :method :multi(_, ['PAST::Block'])
    .param pmc node
    .param pmc options         :slurpy :named

    ##  add current block node to @?BLOCK
    .local pmc blockpast
    blockpast = get_global '@?BLOCK'
    unshift blockpast, node

    .local string name
    name = node.'name'()
    if name goto have_name
    name = node.'unique'('_block')
  have_name:

    ##  determine the outer POST::Sub for the new one
    .local pmc outerpost
    outerpost = get_global '$?SUB'
    
    ##  create a POST::Sub node for this block
    .local string blocktype
    blocktype = node.'blocktype'()
    .local pmc bpost
    $P0 = get_hll_global ['POST'], 'Sub'
    bpost = $P0.'new'('node'=>node, 'name'=>name, 'outer'=>outerpost, 'blocktype'=>blocktype)
    set_global '$?SUB', bpost

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

    ##  restore previous outer scope
    set_global '$?SUB', outerpost

    ##  handle calls to immediate blocks
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
    ##  remove current block from @?BLOCK
    $P99 = shift blockpast
    .return (bpost)
.end

=back

=head3 C<PAST::Op>

=over 4

=item post(PAST::Op node)

Return the POST representation of a C<PAST::Op> node.  Normally
this is handled by redispatching to a method corresponding to
the node's "pasttype" attribute.

=cut

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


=item pirop(PAST::Op node)

Return the POST representation of a C<PAST::Op> node with
a 'pasttype' of 'pirop'.

=cut

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


=item call(PAST::Op node)

=item callmethod(PAST::Op node)

Return the POST representation of a C<PAST::Op> node
with a 'pasttype' attribute of either 'call' or 'callmethod'.

=cut

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


=item if(PAST::Op node)

=item unless(PAST::Op node)

Return the POST representation of C<PAST::Op> nodes with
a 'pasttype' of if/unless.

=cut

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


=item bind(PAST::Op node)

Return the POST representation of a C<PAST::Op>
node with a 'pasttype' of bind.

=cut

.sub 'bind' :method :multi(_, ['PAST::Op'])
    .param pmc node
    .param pmc options         :slurpy :named

    .local pmc ops, lpast, rpast, lpost, rpost
    lpast = node[0]
    rpast = node[1]

    $P0 = get_hll_global ['POST'], 'Ops'
    ops = $P0.'new'('node'=>node)
    rpost = self.'post'(rpast, 'rtype'=>'P')
    ops.'push'(rpost)
    lpost = self.'bindop'(lpast, rpost)
    ops.'push'(lpost)
    ops.'result'(lpost)
    .return (ops)
.end
    

=item inline(PAST::Op node)

Return the POST representation of a C<PAST::Op>
node with a 'pasttype' of inline.

=cut

.sub 'inline' :method :multi(_, ['PAST::Op'])
    .param pmc node
    .param pmc options         :slurpy :named

    .local pmc ops
    ops = self.'post_children'(node, 'signature'=>'vP')

    .local string inline
    inline = node.'inline'()

    .local string result
    result = ''
    $I0 = index inline, '%r'
    unless $I0 goto have_result
    result = ops.'unique'('$P')
    ops.'result'(result)
  have_result:

    .local pmc arglist
    arglist = ops.'get_array'()
    ops.'push_pirop'('inline', arglist :flat, 'inline'=>inline, 'result'=>result)
    .return (ops)
.end

=back

=head3 C<PAST::Var>

=item scope(PAST::Var node)

Helper function to return the scope of a variable given by C<node>.
The scope is determined by the node's C<scope> attribute if set,
otherwise search outward through the symbol tables of any lexical
blocks to determine the scope.

=cut

.sub 'scope' :method :multi(_, ['PAST::Var'])
    .param pmc node
    .local pmc scope
    scope = node.'scope'()
    if scope goto end

    .local string name
    name = node.'name'()
    .local pmc iter, bpast
    $P0 = get_global '@?BLOCK'
    iter = new 'Iterator', $P0
  iter_loop:
    unless iter goto end
    .local pmc bpast, symbol
    bpast = shift iter
    symbol = bpast.'symbol'(name)
    unless symbol goto iter_loop
    scope = symbol['scope']
    unless scope goto iter_loop
  end:
    .return (scope)
.end



.sub 'post' :method :multi(_, ['PAST::Var'])
    .param pmc node
    .param pmc options         :slurpy :named

    .local pmc code
    code = new 'CodeString'

    ##  get post for any vivification
    ##  get a result register
    .local string result
    result = code.'unique'('$P')
    .local pmc viviself, vivipost
    viviself = node.'viviself'()
    $I0 = isa viviself, 'PAST::Node'
    if $I0 goto viviself_past
    if viviself goto viviself_string
    $P0 = get_hll_global ['POST'], 'Ops'
    vivipost = $P0.'new'('result'=>result)
    goto vivipost_done
  viviself_past:
    vivipost = self.'post'(viviself, 'rtype'=>'P')
    goto vivipost_done
  viviself_string:
    $P0 = get_hll_global ['POST'], 'Op'
    $S0 = $P0.'escape'(viviself)
    vivipost = $P0.'new'(result, $S1, 'pirop'=>'new', 'result'=>result, 'node'=>node)
  vivipost_done:
    
    ##  create a node for this lookup
    .local pmc ops
    $P0 = get_hll_global ['POST'], 'Ops'
    ops = $P0.'new'('result'=>vivipost, 'node'=>node)

    ##  determine variable scope and variable name
    .local string scope, name
    scope = self.'scope'(node)
    name = node.'name'()
    name = code.'escape'(name)

    .local pmc piropc, fetchop, storeop
    piropc = get_hll_global ['POST'], 'Op'
    if scope == 'package' goto post_package

  post_lexical:
    $I0 = node.'isdecl'()
    if $I0 goto post_lexical_decl
    fetchop = piropc.'new'(ops, name, 'pirop'=>'find_lex')
    storeop = piropc.'new'(name, ops, 'pirop'=>'store_lex')
    goto post_scope

  post_lexical_decl:
    ops.'push'(vivipost)
    ops.'push_pirop'('.lex', name, vivipost)
    .return (ops)

  post_package:
    .local pmc ns
    ns = node.'namespace'()
    if ns goto post_package_ns
    fetchop = piropc.'new'(ops, name, 'pirop'=>'get_global')
    storeop = piropc.'new'(name, ops, 'pirop'=>'set_global')
    goto post_scope

  post_package_ns:
    ns = code.'key'(ns)
    fetchop = piropc.'new'(ops, ns, name, 'pirop'=>'get_hll_global')
    storeop = piropc.'new'(ns, name, ops, 'pirop'=>'get_hll_global')
    goto post_scope

  post_scope:
    ops.'push'(fetchop)
    unless viviself goto post_done
    .local pmc vivilabel
    $P0 = get_hll_global ['POST'], 'Label'
    vivilabel = $P0.'new'('name'=>'vivify_')
    ops.'push_pirop'('unless_null', ops, vivilabel)
    ops.'push'(vivipost)
    .local int islvalue
    islvalue = node.'islvalue'()
    unless islvalue goto post_lvalue_done
    ops.'push'(storeop)
  post_lvalue_done:
    ops.'push'(vivilabel)
  post_done:
    .return (ops)
.end
 

.sub 'bindop' :method :multi(_, ['PAST::Var'], _)
    .param pmc node
    .param pmc bpost

    .local string scope
    scope = self.'scope'(node)

    .local string name
    name = node.'name'()
    name = bpost.'escape'(name)

    .local pmc pirop
    pirop = get_hll_global ['POST'], 'Op'

    if scope == 'lexical' goto bind_lexical

  bind_package:
    .return pirop.'new'(name, bpost, 'pirop'=>'set_global', 'result'=>bpost)

  bind_lexical:
    $I0 = node.'isdecl'()
    if $I0 goto bind_lexical_isdecl
    .return pirop.'new'(name, bpost, 'pirop'=>'store_lex', 'result'=>bpost)

  bind_lexical_isdecl:
    .return pirop.'new'(name, bpost, 'pirop'=>'.lex', 'result'=>bpost)
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
