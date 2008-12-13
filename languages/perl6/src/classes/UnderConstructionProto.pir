## $Id:$

=head1 TITLE

UnderConstructionProto.pir - the !UnderConstructionProto class

=head1 DESCRIPTION

Represents a class in the namespace that we're still in the process of
compiling.

=cut

.namespace ['Perl6' ; 'Compiler' ; 'UnderConstructionProto' ]

.sub 'onload' :anon :init :load
    .local pmc p6meta, proto
    p6meta = get_hll_global ['Perl6Object'], '$!P6META'
    proto = p6meta.'new_class'('Perl6::Compiler::UnderConstructionProto', 'parent'=>'Any', 'attr'=>'@!ns $!short_name $!metaclass')
    $P0 = get_hll_global 'Abstraction'
    p6meta.'add_role'($P0, 'to'=>proto)
.end


=head1 METHODS

=over

=item create

Creates a new UnderConstructionProto, puts it in the namespace and returns it.

=cut

.sub 'create' :method
    .param pmc ns
    .param pmc name

    # Create new instance.
    .local pmc ucproto
    ucproto = self.'new'()
    setattribute ucproto, '@!ns', ns
    setattribute ucproto, '$!short_name', name

    # Put in the namespace.
    $S0 = name
    set_hll_global ns, $S0, ucproto

    .return (ucproto)
.end


=item cleanup

Removes this UnderConstructionProto from the namespace.

=cut

.sub 'cleanup' :method
    .local pmc ns, name
    ns = getattribute self, '@!ns'
    name = getattribute self, '$!short_name'
    ns = get_hll_namespace ns
    $S0 = name
    delete ns[$S0]
.end


=item WHAT

Returns self.

=cut

.sub 'WHAT' :method
    .return (self)
.end


=item get_string (vtable method)

Returns the name of the class under construction.

=cut

.sub '' :vtable('get_string')
    $P0 = getattribute self, '$!short_name'
    .return ($P0)
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
