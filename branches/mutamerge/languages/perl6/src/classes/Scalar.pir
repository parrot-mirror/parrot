## $Id$

=head1 NAME

src/classes/Scalar.pir - Perl 6 Array class and related functions

=head2 Object Methods

=cut

.namespace []
.sub 'onload' :anon :load :init
    .local pmc p6meta, scalarproto
    p6meta = get_hll_global ['Perl6Object'], '$!P6META'
    scalarproto = p6meta.'new_class'('Perl6Scalar', 'parent'=>'Mutable Any', 'name'=>'Scalar')
.end


.sub 'infix:=' :multi(Perl6Scalar, _)
    .param pmc target
    .param pmc source
    $P0 = source.'item'()
    assign target, $P0
    .return (target)
.end


