## $Id: list.pir 15768 2006-11-22 19:38:04Z pmichaud $

=head1 NAME

src/classes/List.pir - Perl 6 List class

=head1 Functions

=over 4

=cut

.namespace

.sub '__onload' :load :init
    $P0 = subclass 'ResizablePMCArray', 'List'
.end

# FIXME:  The 'clone' opcode doesn't seem to naturally work
# for subclasses of ResizablePMCArray, so we write our own here.
# FIXME:  #2 - iterators don't properly work for subclasses
# of ResizablePMCArray (RT #40958), so we have to enumerate the
# elements by index.

.namespace [ 'List' ]

.sub '__clone' :method
    $P0 = new 'List'
    $I1 = elements self
    $I0 = 0
  loop:
    if $I0 >= $I1 goto end
    $P1 = self[$I0]
    $P0[$I0] = $P1
    inc $I0
    goto loop
  end:
    .return ($P0)
.end


.sub '__get_string' :method
    $S0 = ''
    $I1 = elements self
    if $I1 < 1 goto end
    $I0 = 1
    $S0 = self[0]
  loop:
    if $I0 >= $I1 goto end
    $S1 = self[$I0]
    $S0 = concat $S0, ' '
    $S0 .= $S1
    inc $I0
    goto loop
  end:
    .return ($S0)
.end


.sub 'elems' :method
    $I0 = elements self
    .return ($I0)
.end


=back

=cut

## vim: expandtab sw=4
