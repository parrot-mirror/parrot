## $Id$

=head1 NAME

src/classes/Scalar.pir - Perl 6 Array class and related functions

=head2 Object Methods

=cut

.namespace []

#.sub 'onload' :anon :load :init
#    .local pmc p6meta, scalarproto
#    $P0 = subclass 'Mutable', 'Perl6Scalar'
#.end

.sub 'infix:=' :multi(Perl6Scalar, _)
    .param pmc target
    .param pmc source
    $P0 = source.'item'()
    assign target, $P0
    .return (target)
.end


