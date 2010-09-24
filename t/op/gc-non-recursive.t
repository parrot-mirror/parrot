#!./parrot
# Copyright (C) 2010, Parrot Foundation.
# $Id$

=head1 NAME

t/op/gc-non-recursive.t - test for marking very large linked-list

=head1 SYNOPSIS

    % prove t/op/gc-non-recursive.t

=head1 DESCRIPTION

See http://trac.parrot.org/parrot/ticket/1723

=cut


.sub 'main' :main
    .include 'test_more.pir'

    .local pmc iterclass, intclass

    iterclass = newclass ['RangeIter']
    addattribute iterclass, '$!value'
    addattribute iterclass, '$!nextIter'
    intclass = subclass ['Integer'], 'Int'

    .local pmc head, next
    head = new iterclass
    $P0 = new intclass
    setattribute head, '$!value', $P0

    next = head
  loop:
    ($I0, next) = next.'reify'()
    if $I1 < 10000000 goto loop
    sweep 1
    ok(1, "Marking of large list doesn't exaust C stack")
    done_testing()
.end


.namespace ['RangeIter']

.sub 'reify' :method
    .local pmc value, nextiter
    value = getattribute self, '$!value'
    nextiter = new ['RangeIter']
    setattribute self, '$!nextIter', nextiter
    $P0 = add value, 1.0
    setattribute nextiter, '$!value', $P0
    .return ($P0, nextiter)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
