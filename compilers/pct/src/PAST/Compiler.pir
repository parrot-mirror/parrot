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
    piropsig['n_mod'] = 'PP+'
    piropsig['n_neg'] = 'PP'
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
    .return self.'post'(past, 'rtype'=>'*')
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
    .local pmc posargs, namedargs
    null posargs
    null namedargs
    $I0 = index signature, ':'
    if $I0 < 0 goto nocolon
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
    if null posargs goto iter_rtype
    if rtype != ':' goto iter_pos
    .local pmc npast, npost
    npast = cpast.'named'()
    unless npast goto iter_pos
  iter_named:
    npost = self.'post'(npast, 'rtype'=>'~')
    ops.'push'(npost)
    $S0 = cpost
    $S1 = npost
    concat $S0, ' :named('
    concat $S0, $S1
    concat $S0, ')'
    push namedargs, $S0
    goto iter_rtype
  iter_pos:
    push posargs, cpost
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
    $P0 = get_hll_global ['POST'], 'Op'
    result = $P0.'unique'('$P')
    $S0 = $P0.'escape'(node)
    .return $P0.'new'(result, $S0, 'pirop'=>'new', 'result'=>result)

  from_nothing:
    $P0 = get_hll_global ['POST'], 'Ops'
    result = $P0.'unique'('$P')
    .return $P0.'new'('result'=>result)

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
    .local pmc ns
    ns = node.'namespace'()
    .local pmc bpost
    $P0 = get_hll_global ['POST'], 'Sub'
    bpost = $P0.'new'('node'=>node, 'name'=>name, 'outer'=>outerpost, 'blocktype'=>blocktype, 'namespace'=>ns)
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

    ##  get a result register if we need it
    .local string rtype, result
    result = ''
    rtype = options['rtype']
    if rtype == '*' goto have_result
    result = bpost.'unique'('$P')
  have_result:

    name = bpost.'escape'(name)
    $I0 = defined ns
    unless $I0 goto have_ns_key
    $P0 = new 'CodeString'
    ns = $P0.'key'(ns)
  have_ns_key:

    if blocktype == 'immediate' goto block_immediate
    if rtype == '*' goto block_done
    $P0 = get_hll_global ['POST'], 'Ops'
    bpost = $P0.'new'(bpost, 'node'=>node, 'result'=>result)
    if ns goto block_decl_ns
    bpost.'push_pirop'('get_global', result, name, 'result'=>result)
    goto block_done
  block_decl_ns:
    bpost.'push_pirop'('get_hll_global', result, ns, name, 'result'=>result)
    goto block_done

  block_immediate:
    $P0 = get_hll_global ['POST'], 'Ops'
    bpost = $P0.'new'(bpost, 'node'=>node, 'result'=>result)
    if ns goto block_immediate_ns
    $S0 = bpost.'unique'('$P')
    bpost.'push_pirop'('get_global', $S0, name)
    bpost.'push_pirop'('newclosure', $S0, $S0)
    bpost.'push_pirop'('call', $S0, 'result'=>result)
    goto block_done
  block_immediate_ns:
    $S0 = bpost.'unique'('$P')
    bpost.'push_pirop'('get_hll_global', $S0, ns, name, 'result'=>$S0)
    bpost.'push_pirop'('call', $S0, 'result'=>result)

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

    ##  see if we set first child's lvalue
    $I0 = node.'lvalue'()
    unless $I0 goto have_lvalue
    $P0 = node[0]
    if null $P0 goto have_lvalue
    $P0.'lvalue'($I0)
  have_lvalue:

    .local string pasttype
    pasttype = node.'pasttype'()
    unless pasttype goto post_pirop
    $P0 = find_method self, pasttype
    .return self.$P0(node, options :flat :named)

  post_pirop:
    .local pmc pirop
    pirop = node.'pirop'()
    unless pirop goto post_call
    .return self.'pirop'(node, options :flat :named)

  post_call:
    .return self.'call'(node, options :flat :named)
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
    (ops, posargs, namedargs) = self.'post_children'(node, 'signature'=>'vP:')
  children_done:

    .local string result, rtype
    result = ''
    rtype = options['rtype']
    if rtype == '*' goto result_done
    result = ops.'unique'('$P')
    ops.'result'(result)
  result_done:

    .local string pasttype
    pasttype = node.'pasttype'()
    if pasttype goto have_pasttype
    pasttype = 'call'
  have_pasttype:
    ops.'push_pirop'(pasttype, posargs :flat, namedargs :flat, 'result'=>result)
    .return (ops)
.end

.sub 'callmethod' :method :multi(_, ['PAST::Op'])
    .param pmc node
    .param pmc options         :slurpy :named
    .return self.'call'(node, options :flat :named)
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


=item for(PAST::Op node)

Return the PAST representation of the C<for> loop given
by C<node>.

=cut

.sub 'for' :method :multi(_, ['PAST::Op'])
    .param pmc node
    .param pmc options         :slurpy :named

    .local pmc ops
    $P0 = get_hll_global ['POST'], 'Ops'
    ops = $P0.'new'('node'=>node)

    .local pmc looplabel, endlabel
    $P0 = get_hll_global ['POST'], 'Label'
    $S0 = ops.'unique'('for_')
    looplabel = $P0.'new'('result'=>$S0)
    $S0 = concat $S0, 'end'
    endlabel = $P0.'new'('result'=>$S0)

    .local pmc collpast, collpost
    collpast = node[0]
    collpost = self.'post'(collpast, 'rtype'=>'P')
    ops.'push'(collpost)

    .local string iter
    iter = ops.'unique'('$P')
    ops.'result'(iter)
    ops.'push_pirop'('if_null', collpost, endlabel)        ## FIXME
    ops.'push_pirop'('new', iter, '"Iterator"', collpost)
    ops.'push'(looplabel)
    ops.'push_pirop'('unless', iter, endlabel)

    .local string nextval
    nextval = ops.'unique'('$P')
    ops.'push_pirop'('shift', nextval, iter)

    .local pmc subpast, subpost
    subpast = node[1]
    subpost = self.'post'(subpast, 'rtype'=>'P')
    ops.'push'(subpost)
    ops.'push_pirop'('newclosure', subpost, subpost)
    ops.'push_pirop'('call', subpost, nextval)
    ops.'push_pirop'('goto', looplabel)
    ops.'push'(endlabel)
    .return (ops)
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

    .local string scope
    lpast.lvalue(1)
    scope = self.'scope'(lpast)
    $P0 = find_method self, scope
    lpost = self.$P0(lpast, rpost)
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

=over 4

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


.sub 'vivify' :method
    .param pmc node
    .param pmc ops
    .param pmc fetchop
    .param pmc storeop

    .local pmc viviself, vivipost, vivilabel
    viviself = node.'viviself'()
    vivipost = self.'post'(viviself)
    ops.'result'(vivipost)
    ops.'push'(fetchop)
    unless viviself goto vivipost_done
    $P0 = get_hll_global ['POST'], 'Label'
    vivilabel = $P0.'new'('name'=>'vivify_')
    ops.'push_pirop'('unless_null', ops, vivilabel)
    ops.'push'(vivipost)
    $I0 = node.'lvalue'()
    unless $I0 goto vivipost_stored
    ops.'push'(storeop)
  vivipost_stored:
    ops.'push'(vivilabel)
  vivipost_done:
    .return (ops)
.end


.sub 'post' :method :multi(_, ['PAST::Var'])
    .param pmc node
    .param pmc options         :slurpy :named

    .local string scope
    scope = self.'scope'(node)
    $P0 = find_method self, scope
    .return self.$P0(node)
.end


.sub 'parameter' :method :multi(_, ['PAST::Var'])
    .param pmc node

    ##  get the current sub
    .local pmc subpost
    subpost = get_global '$?SUB'

    ##  determine lexical, register, and parameter names
    .local string name, named, pname, has_pname
    name = node.'name'()
    named = node.'named'()
    pname = subpost.'unique'('param_')
    has_pname = concat 'has_', pname

    ##  returned post node
    .local pmc ops
    $P0 = get_hll_global ['POST'], 'Ops'
    ops = $P0.'new'('node'=>node, 'result'=>pname)

    ##  handle optional params
    .local pmc viviself, vivipost, vivilabel
    viviself = node.'viviself'()
    unless viviself goto param_required
    vivipost = self.'post'(viviself)
    $P0 = get_hll_global ['POST'], 'Label'
    vivilabel = $P0.'new'('name'=>'optparam_')
    subpost.'add_param'(pname, 'named'=>named, 'optional'=>1)
    ops.'push_pirop'('if', has_pname, vivilabel)
    ops.'push'(vivipost)
    ops.'push_pirop'('set', ops, vivipost)
    ops.'push'(vivilabel)

  param_required:
    subpost.'add_param'(pname, 'named'=>named)
    name = ops.'escape'(name)
    ops.'push_pirop'('.lex', name, ops)
    .return (ops)
.end


.sub 'package' :method :multi(_, ['PAST::Var'])
    .param pmc node
    .param pmc bindpost        :optional
    .param int has_bindpost    :opt_flag

    .local pmc ops, fetchop, storeop
    $P0 = get_hll_global ['POST'], 'Ops'
    ops = $P0.'new'('node'=>node)

    .local string name
    name = node.'name'()
    name = ops.'escape'(name)

    $P0 = get_hll_global ['POST'], 'Op'
    .local pmc ns
    ns = node.'namespace'()
    $I0 = defined ns
    if $I0 goto package_hll
    if has_bindpost goto package_bind
    fetchop = $P0.'new'(ops, name, 'pirop'=>'get_global')
    storeop = $P0.'new'(name, ops, 'pirop'=>'set_global')
    .return self.'vivify'(node, ops, fetchop, storeop)
  package_bind:
    .return $P0.'new'(name, bindpost, 'pirop'=>'set_global', 'result'=>bindpost)

  package_hll:
    if ns goto package_ns
    if has_bindpost goto package_hll_bind
    fetchop = $P0.'new'(ops, name, 'pirop'=>'get_hll_global')
    storeop = $P0.'new'(name, ops, 'pirop'=>'set_hll_global')
    .return self.'vivify'(node, ops, fetchop, storeop)
  package_hll_bind:
    .return $P0.'new'(name, bindpost, 'pirop'=>'set_hll_global', 'result'=>bindpost)

  package_ns:
    $P1 = new 'CodeString'
    ns = $P1.'key'(ns)
    if has_bindpost goto package_ns_bind
    fetchop = $P0.'new'(ops, ns, name, 'pirop'=>'get_hll_global')
    storeop = $P0.'new'(ns, name, ops, 'pirop'=>'set_hll_global')
    .return self.'vivify'(node, ops, fetchop, storeop)
  package_ns_bind:
    .return $P0.'new'(ns, name, bindpost, 'pirop'=>'set_hll_global', 'result'=>bindpost)
.end


.sub 'lexical' :method :multi(_, ['PAST::Var'])
    .param pmc node
    .param pmc bindpost        :optional
    .param int has_bindpost    :opt_flag

    .local string name
    $P0 = get_hll_global ['POST'], 'Ops'
    name = node.'name'()
    name = $P0.'escape'(name)

    .local int isdecl
    isdecl = node.'isdecl'()

    if has_bindpost goto lexical_bind

  lexical_post:
    if isdecl goto lexical_decl
    .local pmc ops, fetchop, storeop
    ops = $P0.'new'('node'=>node)
    $P0 = get_hll_global ['POST'], 'Op'
    fetchop = $P0.'new'(ops, name, 'pirop'=>'find_lex')
    storeop = $P0.'new'(name, ops, 'pirop'=>'store_lex')
    .return self.'vivify'(node, ops, fetchop, storeop)

  lexical_decl:
    .local pmc viviself
    viviself = node.'viviself'()
    ops = self.'post'(viviself, 'rtype'=>'P')
    ops.'push_pirop'('.lex', name, ops)
    .return (ops)

  lexical_bind:
    $P0 = get_hll_global ['POST'], 'Op'
    if isdecl goto lexical_bind_decl
    .return $P0.'new'(name, bindpost, 'pirop'=>'store_lex', 'result'=>bindpost)
  lexical_bind_decl:
    .return $P0.'new'(name, bindpost, 'pirop'=>'.lex', 'result'=>bindpost)
.end


.sub 'keyed' :method :multi(_, ['PAST::Var'])
    .param pmc node
    .param pmc bindpost        :optional
    .param int has_bindpost    :opt_flag

    .local pmc ops
    $P0 = get_hll_global ['POST'], 'Ops'
    ops = $P0.'new'('node'=>node)

    .local pmc keypast, keypost
    keypast = node[1]
    keypost = self.'post'(keypast, 'rtype'=>'*')
    ops.'push'(keypost)

    .local pmc basepast, basepost
    basepast = node[0]
    $P0 = basepast.'viviself'()
    if $P0 goto have_baseviviself
    $P0 = node.'vivibase'()
    unless $P0 goto have_baseviviself
    basepast.'viviself'($P0)
  have_baseviviself:

    #  if the keyed node is an lvalue, its base is an lvalue also
    $I0 = node.'lvalue'()
    unless $I0 goto have_lvalue
    basepast.lvalue($I0)
  have_lvalue:

    basepost = self.'post'(basepast, 'rtype'=>'P')
    ops.'push'(basepost)
    .local string name
    $S0 = basepost.'result'()
    name = concat $S0, '['
    $S0 = keypost.'result'()
    concat name, $S0
    concat name, ']'
    .local pmc fetchop, storeop
    $P0 = get_hll_global ['POST'], 'Op'
    if has_bindpost goto keyed_bind
    fetchop = $P0.'new'(ops, name, 'pirop'=>'set')
    storeop = $P0.'new'(name, ops, 'pirop'=>'set')
    .return self.'vivify'(node, ops, fetchop, storeop)
  keyed_bind:
    ops.'push_pirop'('set', name, ops)
    .return (ops)
.end


=back

=head3 C<PAST::Val>

=over 4

=item post(PAST::Val node [, 'rtype'=>rtype])

Return the POST representation of the constant value given
by C<node>.  The C<rtype> parameter advises the method whether
the value may be returned directly as a PIR constant or needs
to have a PMC generated containing the constant value.

=cut

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

Copyright (C) 2006-2007, The Perl Foundation.

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
