## $Id$

=head1 NAME

src/classes/Nil.pir - Nil objects

=head1 DESCRIPTION

=cut

.namespace []

.sub '' :anon :load :init
    .local pmc p6meta, nilproto
    p6meta = get_hll_global ['Perl6Object'], '$!P6META'
    nilproto = p6meta.'new_class'('Nil', 'parent'=>'Failure')
.end

=head2 Context methods

=over

=item 'list'

=cut

.namespace ['Nil']
.sub 'list' :method
    $P0 = new 'List'
    .return ($P0)
.end

=back

=head2 Coercion methods

=over

=item Scalar

=cut

.sub 'Scalar' :method
    $P0 = new 'Failure'
    .return ($P0)
.end

=back
 
=head2 Methods 

=item 'shift'

=cut

.sub 'shift' :method :vtable('shift_pmc')
    .return (self)
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

