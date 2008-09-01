## $Id$

=head1 NAME

src/builtins/cmp.pir - Cardinal comparison builtins
Swiped from Rakudo.

=head1 Functions

=over 4

=cut

.namespace []


.sub 'prefix:?' :multi(_)
    .param pmc a
    if a goto a_true
    $P0 = get_hll_global ['Bool'], 'False'
    .return ($P0)
  a_true:
    $P0 = get_hll_global ['Bool'], 'True'
    .return ($P0)
.end

.sub 'infix:==' :multi(_,_)
    .param num a
    .param num b
    $I0 = iseq a, b
    .return 'prefix:?'($I0)
.end

.sub 'infix:==' :multi(CardinalArray,CardinalArray)
    .param pmc a
    .param pmc b
    .local int i
    $I1 = a.elems()
    $I2 = b.elems()
    ne $I1, $I2, fail
    i = 0
  loop:
    unless i < $I1 goto success
    $P0 = a[i]
    $P1 = b[i]
    $I0 = 'infix:=='($P0,$P1)
    inc i
    if $I0 goto loop
  fail:
    .return (0)
  success:
    .return (1)
.end


.sub 'infix:!=' :multi(_,_)
    .param pmc a
    .param pmc b
    $I0 = 'infix:=='(a, b)
    $I0 = not $I0
    .return 'prefix:?'($I0)
.end


.sub 'infix:<' :multi(_,_)
    .param num a
    .param num b
    $I0 = islt a, b
    .return 'prefix:?'($I0)
.end


.sub 'infix:<=' :multi(_,_)
    .param num a
    .param num b
    $I0 = isle a, b
    .return 'prefix:?'($I0)
.end


.sub 'infix:>' :multi(_,_)
    .param num a
    .param num b
    $I0 = isgt a, b
    .return 'prefix:?'($I0)
.end


.sub 'infix:>=' :multi(_,_)
    .param num a
    .param num b
    $I0 = isge a, b
    .return 'prefix:?'($I0)
.end


.sub 'infix:<=>'
    .param pmc a
    .param pmc b
    $I0 = cmp_num a, b
    .return ($I0)
.end


=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
