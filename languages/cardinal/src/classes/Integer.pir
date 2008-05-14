## $Id$

=head1 TITLE

CardinalInteger - Cardinal integers

=cut

.namespace [ 'CardinalInteger' ]


=head1 SUBROUTINES

=over 4

=item onload

=cut

.sub 'onload' :anon :init :load
    $P0 = subclass 'Integer', 'CardinalInteger'
    #$P1 = get_hll_global 'Any'
    #$P1 = $P1.HOW()
    #addparent $P0, $P1
    $P1 = get_hll_global ['CardinalObject'], 'make_proto'
    $P1($P0, 'CardinalInteger')
    $P1('Integer', 'CardinalInteger')
.end


=item ACCEPTS()

=cut

.sub 'ACCEPTS' :method
    .param num topic
    .return 'infix:=='(topic, self)
.end


=item clone()

=cut

.sub 'clone' :method :vtable
    .local pmc clone_type
    clone_type = self.HOW()
    $P0 = clone_type.'new'()
    $P0 = self
    .return($P0)
.end


=item perl()

Returns a Perl representation of the CardinalInteger.

=cut

.sub 'perl' :method
    $S0 = self
    .return($S0)
.end


=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
