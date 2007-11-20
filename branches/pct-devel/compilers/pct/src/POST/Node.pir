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
    $P0  = protomaker.'new_subclass'(base, 'POST::Label')
    $P0  = protomaker.'new_subclass'(base, 'POST::Sub')
    .return ()
.end


=head1 POST Node types

=head2 POST::Node

C<POST::Node> is the base class for all POST nodes.  It's derived from class
C<PAST::Node> (see F<compilers/pct/src/PAST/Node.pir>).

=over 4

=item result([value])

Get/set

=cut

.namespace [ 'POST::Node' ]

=item result([value])

Get or set the result value of this node.  If the result value
is set to another POST node, then that node's result is used
as the result of the current node.

=cut

.sub 'result' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag

    if has_value == 1 goto set_value
    value = self['result']
    if null value goto result_null
    $I0 = isa value, 'POST::Node'
    if $I0 goto result_node
    .return (value)
  result_node:
    .return value.'result'()
  result_null:
    .return ('')
  set_value:
    self['result'] = value
    .return (value)
.end


=item get_string()   # vtable method

Returns the result of the current node as a string.

=cut

.sub 'get_string' :vtable :method
    $S0 = self.'result'()
    .return ($S0)
.end


=item push_pirop(pirop [,arglist :slurpy] [,adverbs :slurpy :named])

Shortcut for creating and adding a new POST::Op node with opcode 
C<pirop> and any supplied arguments or options.  Returns the
newly created node.

=cut

.sub 'push_pirop' :method
    .param pmc pirop
    .param pmc arglist         :slurpy
    .param pmc adverbs         :slurpy :named
    adverbs['pirop'] = pirop
    $P0 = get_hll_global ['POST'], 'Op'
    $P1 = $P0.'new'(arglist :flat, adverbs :flat :named)
    self.'push'($P1)
    .return ($P1)
.end


=item escape(str)

Return C<str> as a PIR constant string.

=cut

.sub 'escape' :method
    .param string str
    $P0 = new 'CodeString'
    str = $P0.'escape'(str)
    .return (str)
.end


=head2 POST::Op

C<POST::Op> nodes represents any PIR opcodes.

=over 4

=item pirop([opcode])

Get/set the opcode type for this node.

=cut

.namespace [ 'POST::Op' ]

.sub 'pirop' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .return self.'attr'('pirop', value, has_value)
.end


.namespace [ 'POST::Label' ]

.sub 'result' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    if has_value goto set_value
    value = self['result']
    unless null value goto end
    .local string name
    name = self.'name'()
    value = self.'unique'(name)
  set_value:
    self['result'] = value
  end:
    .return (value)
.end


.namespace [ 'POST::Sub' ]

.sub 'blocktype' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .return self.'attr'('blocktype', value, has_value)
.end


