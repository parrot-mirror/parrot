=head1 NAME

POST - Parrot opcode syntax tree

=head1 DESCRIPTION

This file implements the various opcode syntax tree nodes
for compiling programs in Parrot.

=cut

.namespace [ 'POST' ]

.sub '__onload' :load :init
    .local pmc base

    base = subclass 'PAST::Node', 'POST::Node'

    $P0 = subclass base, 'POST::Op'
    $P0 = subclass base, 'POST::Ops'
    $P0 = subclass base, 'POST::Sub'
    $P0 = subclass base, 'POST::Label'

    .local pmc pirtable
    pirtable = new 'Hash'
    pirtable['add'] = '%tP+'
    pirtable['sub'] = '%tP+'
    pirtable['mul'] = '%tP+'
    pirtable['div'] = '%tP+'
    pirtable['n_add'] = '%rP+'
    pirtable['n_sub'] = '%rP+'
    pirtable['n_mul'] = '%rP+'
    pirtable['n_div'] = '%rP+'
    pirtable['concat'] = '%tP~'
    pirtable['abs'] = '%t'
    pirtable['say'] = '%v'
    pirtable['print'] = '%v'
    pirtable['set'] = '%rP'
    pirtable['call'] = '%rPPPPPPPPPPPPPPPP'                # FIXME:
    pirtable['callmethod'] = '%rPPPPPPPPPPPPPPPP'          # FIXME:
    set_hll_global ['POST'], '%pirtable', pirtable
    .return ()
.end


=head1 POST Node types

=head2 POST::Node

C<POST::Node> is the base class for all POST nodes.  It's derived from class
C<PAST::Node> (see F<compilers/past-pm/PAST/Node.pir>).

=over 4

=item result([value])

Get/set

=cut

.namespace [ 'POST::Node' ]

.sub 'result' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag

    if has_value == 1 goto set_value
    value = self['result']
    unless null value goto end
    value = self.'unique'('$P')
    goto set_value_1
  set_value:
    $I0 = isa value, 'POST::Node'
    if $I0 == 0 goto set_value_1
    value = value.'result'()
  set_value_1:
    self['result'] = value
  end:
    .return (value)
.end


=item push_pirop(pirop [,arglist :slurpy] [,adverbs :slurpy :named])

=cut

.sub 'push_pirop' :method
    .param pmc pirop
    .param pmc arglist         :slurpy
    .param pmc adverbs         :slurpy :named
    if null adverbs goto no_adverbs
    adverbs['pirop'] = pirop
    $P0 = self.'push_new'('POST::Op', adverbs :flat :named)
    goto end
  no_adverbs:
    $P0 = self.'push_new'('POST::Op', 'pirop'=>pirop)
  end:
    $P0.'arglist'(arglist :flat)
    .return ($P0)
.end


.sub 'pir' :method
    .local pmc code
    code = self.'cpir'()
    # code = concat "    # POST::Node\n", code
    .return (code)
.end


=item cpir()

=cut

.sub 'cpir' :method
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

=head2 POST::Ops

C<POST::Ops> is a container of C<POST::Node>.

=over 4

=item pir()

=cut

.namespace [ 'POST::Ops' ]

.sub 'pir' :method
    .return self.'cpir'()
.end


=back

=head2 POST::Op

C<POST::Op> nodes represents any PIR opcodes.

=over 4

=item pirop([opcode])

Get/set

=cut

.namespace [ 'POST::Op' ]

.sub 'pirop' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .return self.'attr'('pirop', value, has_value)
.end

=item arglist(arglist)

=cut

.sub 'arglist' :method
    .param pmc arglist         :slurpy
    .local int argc
    argc = elements arglist
    $I0 = 0
  argc_loop:
    if $I0 >= argc goto argc_end
    $P0 = arglist[$I0]
    $I1 = isa $P0, 'POST::Node'
    if $I1 == 0 goto argc_next
    $S0 = $P0.'result'()
    arglist[$I0] = $S0
  argc_next:
    inc $I0
    if $I0 < argc goto argc_loop
  argc_end:
    self['arglist'] = arglist
    .return (arglist)
.end


=item pir()

=cut

.sub 'pir' :method
    .local pmc code, arglist
    code = self.'cpir'()
    arglist = self['arglist']
    .local string pirop
    pirop = self.'pirop'()
    if pirop == 'call' goto pir_call
    if pirop == 'callmethod' goto pir_callmethod
    if pirop == 'inline' goto pir_inline
    code.'emit'('    %n %,', arglist :flat, 'n'=>pirop)
    .return (code)

  pir_call:
    .local pmc result, name
    result = self.'result'()
    name = shift arglist
    code.'emit'('    %r = %n(%,)', arglist :flat, 'r'=>result, 'n'=>name)
    .return (code)

  pir_callmethod:
    .local pmc result, name, invocant
    result = self.'result'()
    name = shift arglist
    invocant = shift arglist
    code.'emit'('    %r = %i.%n(%,)', arglist :flat, 'r'=>result, 'i'=>invocant, 'n'=>name)
    .return (code)

  pir_inline:
    .local pmc result, inline
    result = self.'result'()
    inline = shift arglist
    code.'emit'(inline, arglist :flat, 'r'=>result, 't'=>result, 'u'=>result)
    .return (code)
.end


=back

=head2 POST::Label

C<POST::Label> nodes represent PIR labels.

=over 4

=item result([value])

Get/set

=cut

.namespace [ 'POST::Label' ]

.sub 'result' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    if has_value goto set_value
    value = self['value']
    unless null value goto end
    .local string name
    name = self.'name'()
    value = self.'unique'(name)
  set_value:
    self['value'] = value
  end:
    .return(value)
.end


=item pir()

=cut

.sub 'pir' :method
    .local string code
    .local string value
    value = self.'result'()
    code = '  '
    code .= value
    code .= ":\n"
    .return (code)
.end


=back

=head2 POST::Sub

C<POST::Sub> nodes represent PIR subroutines.

=over 4

=item pir()

=cut

.namespace [ 'POST::Sub' ]

.sub 'pir' :method
    $S0 = self.'compiler'()
    unless $S0 goto post_pir
    .return self.'hll_pir'()
  post_pir:
    .local string name
    name = self.'name'()
    name = self.'escape'(name)
    .local pmc outerpost
    .local string outer
    outer = ''
    outerpost = self.'outer'()
    if null outerpost goto have_outer
    unless outerpost goto have_outer
    outer = outerpost.'name'()
    outer = outerpost.'escape'(outer)
    outer = concat ':outer(', outer
    outer = concat outer, ')'
  have_outer:
    .local string pragma
    pragma = self.'pragma'()
    .local pmc code
    code = new 'CodeString'
    code.'emit'("\n.sub %0 %1 %2", name, outer, pragma)
    $P0 = self.'paramcode'()
    code .= $P0
    .local pmc iter, cpost
    iter = self.'iterator'()
  iter_loop:
    unless iter goto iter_end
    cpost = shift iter
    $P1 = cpost.'pir'()
    code .= $P1
    goto iter_loop
  iter_end:
    .local string value
    value = self.'result'()
    if value == '' goto no_return
    code.'emit'("    .return (%0)\n", value)
  no_return:
    code.'emit'(".end\n")
    $P0 = get_hll_global ['POST'], '$!subpir'
    code .= $P0
    set_hll_global ['POST'], '$!subpir', code

    code = new 'CodeString'
    $S0 = self.'blocktype'()
    if $S0 == 'declaration' goto skip_declaration
    code.'emit'("    %0 = find_name %1", value, name)
    if $S0 == 'END'         goto add_end_block
  skip_declaration:
    .return (code)
  add_end_block:
    $S1 = code.'unique'('$P')
    code.'emit'("    %0 = find_global '_perl6', '%BLOCKS'", $S1)
    code.'emit'("    %0 = %0['END']", $S1)
    code.'emit'("    push %0, %1", $S1, value)
    .return (code)
.end


.sub 'hll_pir' :method
    .local string compname, name
    compname = self.'compiler'()
    name = self.'name'()
    .local pmc adverbs
    adverbs = new 'Hash'
    adverbs['target'] = 'pir'
    adverbs['name'] = name
    adverbs['grammar'] = ''
    .local pmc outerpost
    outerpost = self.'outer'()
    unless outerpost goto have_outer
    $S0 = outerpost.'name'()
    adverbs['outer'] = $S0
  have_outer:
    .local pmc sourcecode, compiler, pircode
    sourcecode = self[0]
    compiler = compreg compname
    $I0 = isa compiler, 'Sub'
    if $I0 goto compile_sub
    pircode = compiler.'compile'(sourcecode, adverbs :flat :named)
    goto have_pircode
  compile_sub:
    pircode = compiler(sourcecode, adverbs :flat :named)
  have_pircode:
    $P0 = get_hll_global ['POST'], '$!subpir'
    pircode .= $P0
    set_hll_global ['POST'], '$!subpir', pircode
    .local string result
    result = self.'result'()
    name = self.'escape'(name)
    .local pmc code
    code = new 'CodeString'
    code.'emit'("    %0 = find_name %1", result, name)
    .return (code)
.end


=item outer([outer])

Get/set

=cut

.sub 'outer' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .return self.'attr'('outer', value, has_value)
.end


=item pragma([pragma])

Get/set

=cut

.sub 'pragma' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .return self.'attr'('pragma', value, has_value)
.end


=item blocktype([type])

Get/set

=cut

.sub 'blocktype' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .return self.'attr'('blocktype', value, has_value)
.end


=item paramcode([paramcode])

Get/set

=cut

.sub 'paramcode' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .return self.'attr'('paramcode', value, has_value)
.end


=item compiler([name])

Get/set

=cut

.sub 'compiler' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .return self.'attr'('compiler', value, has_value)
.end


=item push_param(STR regtype, STR pname, STR flags, INT has_flags)

=cut

.sub 'push_param' :method
    .param string regtype
    .param string pname
    .param string flags        :optional
    .param int has_flags       :opt_flag

    .local pmc paramcode
    paramcode = self.'paramcode'()
    if paramcode goto add_param
    paramcode = new 'CodeString'
    self.'paramcode'(paramcode)
  add_param:
    if has_flags goto have_flags
    flags = ''
  have_flags:
    paramcode.'emit'('    .param %0 %1    %2', regtype, pname, flags)
    .return ()
.end


=back

=head1 AUTHOR

Patrick Michaud <pmichaud@pobox.com> is the author and maintainer.
Please send patches and suggestions to the Parrot porters or
Perl 6 compilers mailing lists.

=cut


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
