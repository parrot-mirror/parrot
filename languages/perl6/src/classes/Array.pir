## $Id$

=head1 NAME

src/classes/Array.pir - Perl 6 Array class and related functions

=cut

.namespace []
.sub '' :anon :load :init
    .local pmc p6meta, arrayproto
    p6meta = get_hll_global ['Perl6Object'], '$!P6META'
    arrayproto = p6meta.'new_class'('Perl6Array', 'parent'=>'List', 'name'=>'Array')
    arrayproto.'!MUTABLE'()

    $P0 = get_hll_namespace ['Perl6Array']
    '!EXPORT'('pop push shift unshift', 'from'=>$P0)
.end

=head2 Context methods

=over

=item item()

Return Array in item context (i.e., self)

=cut

.namespace ['Perl6Array']
.sub 'item' :method
    .return (self)
.end

=back

=head2 Coercion methods

=over

=item Array

.sub 'Array' :method
    .return (self)
.end

=back

=head2 Methods

=item pop()

Remove the last item from the array and return it.

=cut

.sub 'pop' :method :multi(Perl6Array)
    .local pmc x
    unless self goto empty
    x = pop self
    goto done
  empty:
    x = '!FAIL'('Undefined value popped from empty array')
  done:
    .return (x)
.end


=item push(args :slurpy)

Add C<args> to the end of the Array.

=cut

.sub 'push' :method :multi(Perl6Array)
    .param pmc args :slurpy
    args.'!flatten'()
    $I0 = elements self
    splice self, args, $I0, 0
    .tailcall self.'elems'()
.end


=item shift()

Shift the first item off the array and return it.

=cut

.sub 'shift' :method :multi(Perl6Array)
    .local pmc x
    unless self goto empty
    x = shift self
    goto done
  empty:
    x = '!FAIL'('Undefined value shifted from empty array')
  done:
    .return (x)
.end


=item unshift(args :slurpy)

Adds C<args> to the beginning of the Array.

=cut

.sub 'unshift' :method :multi(Perl6Array)
    .param pmc args :slurpy
    args.'!flatten'()
    splice self, args, 0, 0
    .tailcall self.'elems'()
.end

=back

=head2 Operators

=over

=item circumfix:[]

Create an array.

=cut

.namespace []
.sub 'circumfix:[ ]'
    .param pmc values          :slurpy
    .tailcall values.'Array'()
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
