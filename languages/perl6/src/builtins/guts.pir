## $Id$

=head1 NAME

src/builtins/guts.pir - subs that are part of the internals, not for users

=head1 SUBS

=over 4

=item !EXPORT(symbols, from :named('from') [, to :named('to')] )

Export symbols in namespace C<from> to the namespace given by C<to>.
If C<to> isn't given, then exports into the HLL global namespace.
This function differs somewhat from Parrot's C<Exporter> PMC in that
it understands how to properly merge C<MultiSub> PMCs.

=cut

.namespace []
.sub '!EXPORT'
    .param string symbols
    .param pmc from            :named('from')
    .param pmc to              :named('to') :optional
    .param int has_to          :opt_flag

    if has_to goto have_to
    to = get_hll_namespace
  have_to:

    .local pmc list
    list = split ' ', symbols
  list_loop:
    unless list goto list_end
    .local string symbol
    .local pmc value
    symbol = shift list
    value = from[symbol]
    $I0 = isa value, 'MultiSub'
    unless $I0 goto store_value
    $P0 = to[symbol]
    if null $P0 goto store_value
    $I0 = isa $P0, 'MultiSub'
    unless $I0 goto err_type_conflict
    $I0 = elements $P0
    splice $P0, value, $I0, 0
    goto list_loop
  store_value:
    to[symbol] = value
    goto list_loop
  list_end:
    .return ()

  err_type_conflict:
    $S0 = concat "Unable to add Multisub '", symbol
    $S0 .= "' to existing value"
    die $S0
.end


=item !VAR

Helper function for implementing the VAR and .VAR macros.

=cut

.sub '!VAR'
    .param pmc variable
    $I0 = isa variable, 'Perl6Scalar'
    unless $I0 goto nothing
    $P0 = new 'MutableVAR', variable
    .return ($P0)
  nothing:
    .return (variable)
.end


=item !DOTYPECHECK

Checks that the value and the assignee are type-compatible and does the
assignment.

=cut

.sub '!DOTYPECHECK'
    .param pmc type
    .param pmc value
    .param pmc result
    $I0 = type.'ACCEPTS'(value)
    result = $I0
.end


=item !TYPECHECKPARAM

Checks the type of a parameter.

=cut

.sub '!TYPECHECKPARAM'
    .param pmc type
    .param pmc value
    $P0 = getinterp
    $P0 = $P0['lexpad';1]
    if null $P0 goto no_match_to_copy
    $P0 = $P0['$/']
    .lex "$/", $P0
  no_match_to_copy:

    $I0 = type.ACCEPTS(value)
    if $I0 goto ok
    'die'('Parameter type check failed')
ok:
.end


=item !SAMETYPE_EXACT

Takes two types and returns true if they match exactly (not accounting for any
subtyping relations, etc).

=cut

.sub '!SAMETYPE_EXACT'
    .param pmc t1
    .param pmc t2

    # If they have equal address, obviously the same.
    .local pmc t1meta, t2meta
    t1meta = t1.'HOW'()
    t2meta = t2.'HOW'()
    eq_addr t1meta, t2meta, same

    # If they are junctions, compare inside them recursively.
    $I0 = isa t1, 'Junction'
    unless $I0 goto not_junc
    $I1 = isa t2, 'Junction'
    unless $I0 == $I1 goto not_junc
    .local pmc j1, j2
    .local int max, i
    j1 = t1.'values'()
    j2 = t1.'values'()
    max = elements j1
    i = 0
  junc_loop:
    if i >= max goto junc_loop_end
    $P0 = j1[i]
    $P1 = j2[i]
    $I0 = '!SAMETYPE_EXACT'($P0, $P1)
    unless $I0 goto not_same
    inc i
    goto junc_loop
  junc_loop_end:
  not_junc:

  not_same:
    .return(0)
  same:
    .return (1)
.end


=item !keyword_class(name)

Internal helper method to create a class.

=cut

.sub '!keyword_class'
    .param string name
    .local pmc class, resolve_list, methods, iter

    # Create class.
    class = newclass name

    # Set resolve list to include all methods of the class.
    methods = inspect class, 'methods'
    iter = new 'Iterator', methods
    resolve_list = new 'ResizableStringArray'
  resolve_loop:
    unless iter goto resolve_loop_end
    $P0 = shift iter
    push resolve_list, $P0
    goto resolve_loop
  resolve_loop_end:
    class.resolve_method(resolve_list)

    .return(class)
.end

=item !keyword_role(name)

Internal helper method to create a role.

=cut

.sub '!keyword_role'
    .param string name
    .local pmc info, role

    # Need to make sure it ends up attached to the right
    # namespace.
    info = new 'Hash'
    info['name'] = name
    $P0 = new 'ResizablePMCArray'
    $P0[0] = name
    info['namespace'] = $P0

    # Create role.
    role = new 'Role', info

    # Stash in namespace.
    $P0 = new 'ResizableStringArray'
    set_hll_global $P0, name, role

    .return(role)
.end

=item !keyword_grammar(name)

Internal helper method to create a grammar.

=cut

.sub '!keyword_grammar'
    .param string name
    .local pmc info, grammar

    # Need to make sure it ends up attached to the right
    # namespace.
    info = new 'Hash'
    info['name'] = name
    $P0 = new 'ResizablePMCArray'
    $P0[0] = name
    info['namespace'] = $P0

    # Create grammar class..
    grammar = new 'Class', info

    .return(grammar)
.end

=item !keyword_does(class, role_name)

Internal helper method to implement the functionality of the does keyword.

=cut

.sub '!keyword_does'
    .param pmc class
    .param pmc role

    # Get Parrot to compose the role for us (handles the methods).
    addrole class, role

    # Parrot doesn't handle composing the attributes; we do that here for now.
    .local pmc role_attrs, class_attrs, ra_iter
    .local string cur_attr
    role_attrs = inspect role, "attributes"
    class_attrs = inspect class, "attributes"
    ra_iter = iter role_attrs
  ra_iter_loop:
    unless ra_iter goto ra_iter_loop_end
    cur_attr = shift ra_iter

    # Check that this attribute doesn't conflict with one already in the class.
    $I0 = exists class_attrs[cur_attr]
    unless $I0 goto no_conflict

    # We have a name conflict. Let's compare the types. If they match, then we
    # can merge the attributes.
    .local pmc class_attr_type, role_attr_type
    $P0 = class_attrs[cur_attr]
    if null $P0 goto conflict
    class_attr_type = $P0['type']
    if null class_attr_type goto conflict
    $P0 = role_attrs[cur_attr]
    if null $P0 goto conflict
    role_attr_type = $P0['type']
    if null role_attr_type goto conflict
    $I0 = '!SAMETYPE_EXACT'(class_attr_type, role_attr_type)
    if $I0 goto merge

  conflict:
    $S0 = "Conflict of attribute '"
    $S0 = concat cur_attr
    $S0 = concat "' in composition of role '"
    $S1 = role
    $S0 = concat $S1
    $S0 = concat "'"
    'die'($S0)

  no_conflict:
    addattribute class, cur_attr
  merge:
    goto ra_iter_loop
  ra_iter_loop_end:
.end

=item !keyword_has(class, attr_name, type)

Adds an attribute with the given name to the class or role.

=cut

.sub '!keyword_has'
    .param pmc class
    .param string attr_name
    .param pmc type
    class.'add_attribute'(attr_name, type)
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
