## $Id$

=head1 NAME

src/builtins/cmp.pir - Perl6 comparison builtins

=head1 Functions

=over 4

=cut

.namespace

.sub 'infix:=='
    .param pmc a
    .param pmc b
    $I0 = cmp_num a, b
    $I0 = iseq $I0, 0
    .return ($I0)
.end


.sub 'infix:!='
    .param pmc a
    .param pmc b
    $I0 = cmp_num a, b
    $I0 = isne $I0, 0
    .return ($I0)
.end


.sub 'infix:<'
    .param pmc a
    .param pmc b
    $I0 = cmp_num a, b
    $I0 = islt $I0, 0
    .return ($I0)
.end


.sub 'infix:<='
    .param pmc a
    .param pmc b
    $I0 = cmp_num a, b
    $I0 = isle $I0, 0
    .return ($I0)
.end


.sub 'infix:>'
    .param pmc a
    .param pmc b
    $I0 = cmp_num a, b
    $I0 = isgt $I0, 0
    .return ($I0)
.end


.sub 'infix:>='
    .param pmc a
    .param pmc b
    $I0 = cmp_num a, b
    $I0 = isge $I0, 0
    .return ($I0)
.end


.sub 'infix:eq'
    .param string a
    .param string b
    $I0 = iseq a, b
    .return ($I0)
.end


.sub 'infix:ne'
    .param string a
    .param string b
    $I0 = isne a, b
    .return ($I0)
.end


.sub 'infix:lt'
    .param string a
    .param string b
    $I0 = islt a, b
    .return ($I0)
.end


.sub 'infix:le'
    .param string a
    .param string b
    $I0 = isle a, b
    .return ($I0)
.end


.sub 'infix:gt'
    .param string a
    .param string b
    $I0 = isgt a, b
    .return ($I0)
.end


.sub 'infix:ge'
    .param string a
    .param string b
    $I0 = isge a, b
    .return ($I0)
.end


## TODO: infix:=:= infix:===


=back

=cut


## vim: expandtab sw=4
