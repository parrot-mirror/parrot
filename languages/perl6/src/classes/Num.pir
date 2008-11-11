## $Id$

=head1 TITLE

Num - Perl 6 numbers

=head1 SUBROUTINES

=over 4

=item onload()

=cut

.namespace [ 'Num' ]

.sub 'onload' :anon :init :load
    .local pmc p6meta, numproto
    p6meta = get_hll_global ['Perl6Object'], '$!P6META'
    numproto = p6meta.'new_class'('Num', 'parent'=>'Float Any')
    p6meta.'register'('Float', 'parent'=>numproto, 'protoobject'=>numproto)
    
    # Override the proto's ACCEPT method so we also accept Ints.
    .const 'Sub' $P0 = "custom_ACCEPTS"
    $P1 = class numproto
    $P1.'add_method'('ACCEPTS', $P0)
.end

.sub 'custom_ACCEPTS' :anon :method
    .param pmc topic
    .local pmc topichow, topicwhat, parrotclass

    topichow = topic.'HOW'()
    topicwhat = topic.'WHAT'()

    # Check if we match Num type.
    parrotclass = topichow.'get_parrotclass'(self)
    $I0 = isa topicwhat, parrotclass
    if $I0 goto end
    $I0 = does topic, parrotclass
    if $I0 goto end

    # Check if we match Int type, which Num can also take.
    $P0 = get_hll_global 'Int'
    parrotclass = topichow.'get_parrotclass'($P0)
    $I0 = isa topicwhat, parrotclass
    if $I0 goto end
    $I0 = does topic, parrotclass

  end:
    .return ($I0)
.end


=item Scalar

This is a value type, so just returns itself.

=cut

.sub 'Scalar' :method
    .return (self)
.end


=item ACCEPTS()

=cut

.sub 'ACCEPTS' :method
    .param num topic
    .tailcall 'infix:=='(topic, self)
.end


=item perl()

Returns a Perl representation of the Num.

=cut

.sub 'perl' :method
    $S0 = self
    .return($S0)
.end


=item WHICH()

Returns the identify value.

=cut

.sub 'WHICH' :method
    $N0 = self
    .return ($N0)
.end


=item infix:===

Overridden for Num.

=cut

.namespace []
.sub 'infix:===' :multi(Float,Float)
    .param num a
    .param num b
    .tailcall 'infix:=='(a, b)
.end


=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
