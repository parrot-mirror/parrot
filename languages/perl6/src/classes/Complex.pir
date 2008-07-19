## $Id$

=head1 TITLE

Complex - Perl 6 complex numbers

=head1 DESCRIPTION

=head2 Methods

=over 4

=item onload

Implementation is a bit different from other basic objects (Int...) because
'Complex' is also the name of the builtin Parrot PMC.

=cut

.namespace [ 'Perl6Complex' ]

.sub 'onload' :anon :init :load
    .local pmc p6meta, complexproto
    p6meta = get_hll_global ['Perl6Object'], '$!P6META'
    complexproto = p6meta.'new_class'('Perl6Complex', 'parent'=>'Complex Any', 'name'=>'Complex')
    p6meta.'register'('Complex', 'parent'=>complexproto, 'protoobject'=>complexproto)

    $P0 = get_hll_namespace ['Perl6Complex']
    '!EXPORT'('exp log polar sqrt', 'from'=>$P0)
.end

=item perl()

Returns a Perl representation of the Complex.

=cut

.sub 'perl' :method
    $S0 = self
    .return ($S0)
.end

=back

=head2 Subs

=over 4

=item exp

=cut

.sub 'exp' :method :multi('Complex')
    $P0 = exp self
    .return ($P0)
.end

=item log

=cut

.sub 'log' :method :multi('Complex')
    $P0 = ln self
    .return ($P0)
.end

=item polar

=cut

.sub 'polar' :method :multi('Complex')
    .local num real, imag, magnitude, angle
    real = self[0]
    imag = self[1]
    $N0 = real * real
    $N1 = imag * imag
    $N2 = $N0 + $N1
    magnitude = sqrt $N2
    angle = atan imag, real
    .return 'list'(magnitude, angle)
.end

=item sqrt

=cut

.sub 'sqrt' :method :multi('Complex')
    $P0 = sqrt self
    .return ($P0)
.end



=back

=head2 Operators

=over 4

=item postfix:i

=cut

.namespace []

.sub 'postfix:i' :multi(_)
    .param pmc a
    .local pmc proto
    $P0 = new 'Complex'
    $P0[1] = 1.0
    mul $P0, $P0, a
    .return ($P0)
.end


=item infix:+

=cut

.sub 'infix:+' :multi('Complex', _)
    .param pmc a
    .param pmc b
    $P0 = new 'Complex'
    add $P0, a, b
    .return ($P0)
.end

.sub 'infix:+' :multi(_, 'Complex')
    .param pmc a
    .param pmc b
    $P0 = new 'Complex'
    add $P0, a, b
    .return ($P0)
.end

=item prefix:+

=cut

.sub 'prefix:+' :multi('Complex')
    .param pmc a
    .return (a)
.end

=item infix:-

=cut

.sub 'infix:-' :multi('Complex', _)
    .param pmc a
    .param pmc b
    $P0 = new 'Complex'
    sub $P0, a, b
    .return ($P0)
.end

.sub 'infix:-' :multi(_, 'Complex')
    .param pmc a
    .param pmc b
    $P0 = new 'Complex'
    sub $P0, a, b
    .return ($P0)
.end

=item prefix:-

=cut

.sub 'prefix:-' :multi('Complex')
    .param pmc a
    a = neg a
    .return (a)
.end


=item infix:*

=cut

.sub 'infix:*' :multi('Complex', _)
    .param pmc a
    .param pmc b
    $P0 = new 'Complex'
    mul $P0, a, b
    .return ($P0)
.end

.sub 'infix:*' :multi(_, 'Complex')
    .param pmc a
    .param pmc b
    $P0 = new 'Complex'
    mul $P0, a, b
    .return ($P0)
.end


=item infix:/

=cut

.sub 'infix:/' :multi('Complex', _)
    .param pmc a
    .param pmc b
    $P0 = new 'Complex'
    div $P0, a, b
    .return ($P0)
.end

.sub 'infix:/' :multi(_, 'Complex')
    .param pmc a
    .param pmc b
    $P0 = new 'Complex'
    div $P0, a, b
    .return ($P0)
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
