=head1 NAME

PCT::Node - base class for PAST and POST nodes

=head1 DESCRIPTION

This file implements the base class for abstract syntax tree (PAST)
and opcode syntax tree (POST) nodes in the Parrot Compiler Toolkit.

=cut

.namespace [ 'PCT';'Node' ]

.sub 'onload' :anon :load :init
    ##   create the PCT::Node base class
    ##   FIXME: Eventually we want this to be a subclass of
    ##   Capture, but as of now Capture isn't working so we
    ##   use the Capture_PIR class for now.
    load_bytecode 'Parrot/Capture_PIR.pbc'

    .local pmc p6meta
    p6meta = new 'P6metaclass'
    p6meta.'new_class'('PCT::Node', 'parent'=>'Capture_PIR')

    $P0 = new 'Integer'
    $P0 = 10
    set_hll_global ['PCT';'Node'], '$!serno', $P0

    .return ()
.end

=head1 PCT::Node

C<PCT::Node> is the base class for all PAST and POST nodes.  It's
derived from class C<Capture>, so that it has both array and hash
components.  The array component is used to maintain a node's children,
while the hash component contains the attributes of the node.  In general
we provide and use accessor methods for a node's attributes, instead
of accessing the hash component directly.

Every PAST/POST node has C<name>, C<source>, and C<pos> attributes.
The C<name> attribute is the node's name, if any, while C<source>
and C<pos> are used to identify the location in the original source
code for the node.  The C<source> and C<pos> values are generally
set by the C<node> method below.

Other node attributes are generally defined by subclasses of C<PCT::Node>.

=over 4

=item init([child1, child2, ..., ] [attr1=>val1, attr2=>val2, ... ])

Initialize a node with the given children and attributes.
Adds each child to the node (using the C<push> method, below) and
calls the appropriate accessor method for each attribute.
And returns the node.

=cut

.sub 'init' :method
    .param pmc children        :slurpy
    .param pmc adverbs         :slurpy :named

    .local pmc iter
    iter = new 'Iterator', children
  children_loop:
    unless iter goto children_end
    $P0 = shift iter
    push self, $P0
    goto children_loop
  children_end:

    iter = new 'Iterator', adverbs
  adverbs_loop:
    unless iter goto adverbs_end
    $S0 = shift iter
    $P0 = iter[$S0]
    $P1 = find_method self, $S0
    self.$P1($P0)
    goto adverbs_loop
  adverbs_end:
  end:
    .return (self)
.end


=item new([child1, child2, ..., ] [attr1=>val1, attr2=>val2, ...])

Create a new PAST node of initialized with the given
children and attributes.  Returns the newly created node.

=cut

.sub 'new' :method
    .param pmc children        :slurpy
    .param pmc adverbs         :slurpy :named

    $P0 = self.'HOW'()
    $P0 = getattribute $P0, 'parrotclass'
    $P1 = new $P0
    $P1.'init'(children :flat, adverbs :flat :named)
    .return ($P1)
.end


=item clone

Create and returns a clone of a PAST node.

=cut

.sub 'clone' :vtable :method
    .local pmc res
    $S0 = typeof self
    $P0 = split ';', $S0
    res = new $P0
    .local pmc iter
    iter = self.'iterator'()
  iter_child_loop:
    unless iter goto iter_child_end
    $P0 = shift iter
    $P1 = clone $P0
    res.'push'($P1)
    goto iter_child_loop
  iter_child_end:
    iter = new 'Iterator', self
  iter_attr_loop:
    unless iter goto iter_attr_end
    $S0 = shift iter
    $P0 = iter[$S0]
    res[$S0] = $P0
    goto iter_attr_loop
  iter_attr_end:
    .return (res)
.end


=item unshift(child)

Add C<child> to the beginning of the invocant's list of children.

=item shift()

Remove the first child from the invocant's list of children.
Returns the child.

=item push(child)

Add C<child> to the end of the invocant's list of children.

=item pop()

Remove the last child from the invocant's list of children.
Returns the child.

=cut

.sub 'unshift' :method
    .param pmc value
    unshift self, value
.end

.sub 'shift' :method
    $P0 = shift self
    .return ($P0)
.end

.sub 'push' :method
    .param pmc value
    push self, value
.end

.sub 'pop' :method
    $P0 = pop self
    .return ($P0)
.end


=item push_new(class, [child1, child2, ..., ] [attr1=>val1, attr2=>val2, ...])

(Deprecated.)  Creates a new node of type C<class>, initializes it with the
given children and attributes, and adds it to the end of the invocant's
array of children.  Returns the newly created node.

=cut

.sub 'push_new' :method
    .param string class
    .param pmc children        :slurpy
    .param pmc adverbs         :slurpy :named
    $P0 = split '::', class
    $P0 = new $P0
    $P0.'init'(children :flat, adverbs :flat :named)
    push self, $P0
    .return ($P0)
.end


=item iterator( )

Returns a newly initialized iterator for the invocant's list of
children.

=cut

.sub 'iterator' :method
    .local pmc iter
    $P0 = self.'list'()
    iter = new 'Iterator', $P0
    iter = 0
    .return (iter)
.end


=item node([val])

Sets the invocant's C<source> and C<pos> attributes to those
of C<val>.  If C<val> is another PAST node, then C<source> and C<pos>
are simply copied from that node, otherwise C<val> is assumed to be
a C<Match> object and obtains source/position information from that.

=cut

.sub 'node' :method
    .param pmc node
    $I0 = isa node, ['PAST';'Node']
    if $I0 goto clone_past
  clone_pge:
    $S0 = node
    $I0 = node.'from'()
    self['source'] = $S0
    self['pos'] = $I0
    .return ()
  clone_past:
    $P0 = node['source']
    $P1 = node['pos']
    self['source'] = $P0
    self['pos'] = $P1
    .return ()
.end


=item name([value])

Accessor method -- sets/returns the C<name> attribute of the invocant.

=cut

.sub 'name' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .return self.'attr'('name', value, has_value)
.end


=item attr(STR attrname, PMC value, INT has_value)

Helper method for accessors.  If C<has_value> is true then set
the invocant's value of C<attrname> to C<value>.  Returns the
(resulting) value of C<attrname> in the invocant.

=cut

.sub 'attr' :method
    .param string attrname
    .param pmc value
    .param int has_value
    .param pmc default         :optional
    .param int has_default     :opt_flag
    if has_value goto setattr
    value = self[attrname]
    unless null value goto value_done
    unless has_default goto value_undef
    .return (default)
  value_undef:
    value = new 'Undef'
  value_done:
    .return (value)
  setattr:
    self[attrname] = value
    .return (value)
.end


=item unique([STR fmt])

Generate a unique number that can be used as an identifier.
If C<fmt> is provided, then it will be used as a prefix to the
unique number.

=cut

.sub 'unique' :method
    .param string fmt          :optional
    .param int has_fmt         :opt_flag

    if has_fmt goto unique_1
    fmt = ''
  unique_1:
    $P0 = get_global '$!serno'
    $S0 = $P0
    $S0 = concat fmt, $S0
    inc $P0
    .return ($S0)
.end


=back

=head1 AUTHOR

Patrick Michaud <pmichaud@pobox.com> is the author and maintainer.
Please send patches and suggestions to the Parrot porters or
Perl 6 compilers mailing lists.

=head1 HISTORY

2006-11-20  Patrick Michaud added first draft of POD documentation.
2007-11-21  Re-implementation with pdd26 compliance, compiler toolkit
2007-12-07  Refactor PAST::Node into separate PCT::Node component.

=head1 COPYRIGHT

Copyright (C) 2006-2008, The Perl Foundation.

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
