## $Id$

=head1 NAME

src/classes/Scalar.pir - Perl 6 Array class and related functions

=head2 Object Methods

=cut

.namespace []

## for some reason we can't create the Perl6Scalar class as a subclass
## of Mutable+Any -- it generates segfaults.  So for now there's
## a perl6scalar.pmc that does it for us (and isn't a subclass of Any).
#.sub 'onload' :anon :load :init
#    .local pmc p6meta, scalarproto
#    p6meta = get_hll_global ['Perl6Object'], '$!P6META'
#    scalarproto = p6meta.'new_class'('Perl6Scalar', 'parent'=>'Mutable Any', 'name'=>'Scalar')
#.end


.sub 'infix:=' :multi(Perl6Scalar, _)
    .param pmc target
    .param pmc source
    $P0 = source.'item'()
    assign target, $P0
    .return (target)
.end


