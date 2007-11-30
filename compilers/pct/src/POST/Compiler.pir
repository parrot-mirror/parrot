=head1 NAME

POST::Compiler - Compiler for POST trees

=head1 DESCRIPTION

POST::Compiler defines a compiler that converts a POST tree into
either PIR or executable bytecode.

=head1 METHODS

=over

=cut

.namespace [ 'POST::Compiler' ]

.sub '__onload' :load :init
    $P0 = get_hll_global 'Protomaker'
    ($P1, $P2) = $P0.'new_subclass'('PCT::HLLCompiler', 'POST::Compiler', '$!code')
    $P2.'language'('POST')
    $P0 = new 'String'
    set_global '$?NAMESPACE', $P0
    .return ()
.end


.sub 'compile' :method
    .param pmc post
    .param pmc adverbs         :slurpy :named

    ##  create a separate instance for this compilation
    $P0 = new 'POST::Compiler'

    ##  start with empty code
    .local pmc code
    code = new 'CodeString'
    self.'code'(code)

    ##  if the root node isn't a Sub, wrap it
    $I0 = isa post, 'POST::Sub'
    if $I0 goto have_sub
    $P0 = get_hll_global ['POST'], 'Sub'
    post = $P0.'new'(post, 'name'=>'anon')
  have_sub:

    ##  now generate the pir
    self.'pir'(post)

    ##  and return whatever code was generated
    .return self.'code'()
.end

=item code([str])

Get/set the code generated by this compiler.

=cut

.sub 'code' :method
    .param pmc code            :optional
    .param int has_code        :opt_flag

    if has_code goto set_code
    code = getattribute self, '$!code'
    .return (code)
  set_code:
    setattribute self, '$!code', code
    .return (code)
.end


=item pir_children(node)

Return generated PIR for C<node> and all of its children.

=cut

.sub 'pir_children' :method
    .param pmc node
    .local pmc code, iter
    code = new 'CodeString'
    iter = node.'iterator'()
  iter_loop:
    unless iter goto iter_end
    .local pmc cpost
    cpost = shift iter
    $P0 = self.'pir'(cpost)
    code .= $P0
    goto iter_loop
  iter_end:
    .return (code)
.end


=item pir(Any node)

Return generated pir for any POST::Node.  Returns
the generated pir of C<node>'s children.

=cut

.sub 'pir' :method :multi(_,_)
    .param pmc node
    .return self.'pir_children'(node)
.end


=item pir(POST::Op node)

Return pir for an operation node.

=cut

.sub 'pir' :method :multi(_,['POST::Op'])
    .param pmc node

    ##  determine the type of operation
    .local string pirop
    pirop = node.'pirop'()

    ##  determine if we're storing result
    .local string result
    result = node.'result'()
    unless result goto have_result
    concat result, ' = '
  have_result:

    ##  get list of arguments to operation
    .local pmc arglist
    arglist = node.'get_array'()

    ##  get format and arguments based on pirop
    .local string fmt, name, invocant
    if pirop == 'call' goto pirop_call
    if pirop == 'callmethod' goto pirop_callmethod
    if pirop == 'return' goto pirop_return
    if pirop == 'inline' goto pirop_inline

  pirop_opcode:
    fmt = "    %n %,"
    name = pirop
    goto pirop_emit

  pirop_call:
    fmt = "    %r%n(%,)"
    name = shift arglist
    goto pirop_emit

  pirop_callmethod:
    fmt = "    %r%i.%n(%,)"
    name = shift arglist
    invocant = shift arglist
    goto pirop_emit

  pirop_return:
    fmt = "    .return (%,)"
    goto pirop_emit

  pirop_inline:
    fmt = node.'inline'()
    result = node.'result'()
    goto pirop_emit

  pirop_emit:
    .local pmc code
    code = new 'CodeString'
    code.'emit'(fmt, arglist :flat, 'r'=>result, 'n'=>name, 'i'=>invocant)
    .return (code)
.end


=item pir(POST::Label node)

Generate a label.

=cut

.sub 'pir' :method :multi(_, ['POST::Label'])
    .param pmc node
    .local string code, value
    value = node.'result'()
    code = '  '
    code .= value
    code .= ":\n"
    .return (code)
.end


=item pir(POST::Sub node)

Generate PIR for C<node>, storing the result into the compiler's
C<$!code> attribute and returning any code needed to look up
the sub.

=cut

.sub 'pir' :method :multi(_, ['POST::Sub'])
    .param pmc node

    .local pmc code
    code = new 'CodeString'

    .local string name
    name = node.'name'()
    name = code.'escape'(name)

    .local string flags
    flags = ''

    .local pmc outerpost
    .local string outer
    outer = ''
    outerpost = node.'outer'()
    if null outerpost goto have_outer
    unless outerpost goto have_outer
    outer = outerpost.'name'()
    outer = code.'escape'(outer)
    flags = concat ' :outer(', outer
    concat flags, ')'
  have_outer:

    $S0 = node.'blocktype'()
    if $S0 != 'method' goto have_method
    flags = ' :method'                           # FIXME: RT#47794
    # concat flags, ' :method'                   # FIXME: RT#47794
  have_method:

    .local pmc ns, outerns
    outerns = get_global '$?NAMESPACE'
    ns = outerns
    $P0 = node.'namespace'()
    unless $P0 goto have_ns
    ns = code.'key'($P0)
    set_global '$?NAMESPACE', ns
  have_ns:
    code.'emit'("\n.namespace %0", ns)

    code.'emit'(".sub %0%1", name, flags)
    .local pmc paramlist
    paramlist = node['paramlist']
    if null paramlist goto paramlist_done
    .local pmc iter
    iter = new 'Iterator', paramlist
  param_loop:
    unless iter goto paramlist_done
    $P0 = shift iter
    if null $P0 goto param_loop
    code .= $P0
    goto param_loop
  paramlist_done:

    $P0 = self.'pir_children'(node)
    code .= $P0
    code.'emit'(".end\n")
    $P0 = self.'code'()
    code .= $P0
    self.'code'(code)

    set_global '$?NAMESPACE', outerns

    code = new 'CodeString'
    .return (code)
.end

=back

=head1 AUTHOR

Patrick Michaud <pmichaud@pobox.com> is the author and maintainer.
Please send patches and suggestions to the Parrot porters or
Perl 6 compilers mailing lists.

=head1 HISTORY

2007-11-21  Significant refactor as part of Parrot Compiler Toolkit

=head1 COPYRIGHT

Copyright (C) 2006-2007, The Perl Foundation.

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
