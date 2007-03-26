#!perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More;
use Parrot::Test tests => 4;

=head1 NAME

t/pmc/exporter.t - test the Exporter PMC

=head1 SYNOPSIS

    % prove t/pmc/exporter.t

=head1 DESCRIPTION

Tests the Exporter PMC.

=cut

# L<PDD17/Exporter PMC>
# TODO fix smartlinks once this is specced
pir_output_is( <<'CODE', <<'OUT', 'new' );
.sub 'test' :main
    $P0 = new .Exporter
    say 'ok 1 - $P0 = new .Exporter'

    $I0 = isa $P0, 'Exporter'
    if $I0 goto ok_2
    print 'not '
  ok_2:
    say "ok 2 - isa $P0, 'Exporter'"
.end
CODE
ok 1 - $P0 = new .Exporter
ok 2 - isa $P0, 'Exporter'
OUT


pir_output_is( <<'CODE', <<'OUT', 'source', todo => 'broken' );
.sub 'test' :main
    new $P0, .Exporter
    $P1 = $P0.'source'()
    if $P1 == '' goto ok_1
    print 'not '
  ok_1:
    say 'ok 1 - source() with no args returns source namespace, which is empty at first'

    # get a NameSpace PMC for testing
    # TODO replace with make_namespace, when implemented
    .local pmc ns
    ns = get_namespace ['Eponymous']

    $P0.'source'(ns)
    $P1 = $P0.'source'()
    if $P1 == 'Eponymous' goto ok_2
    print 'not '
  ok_2:
    say 'ok 2 - source() with args sets source namespace'

    $P1 = clone ns

    push_eh ok_3
    $P0.'source'(ns, $P1)
    clear_eh

    print 'not '
  ok_3:
    say 'ok 3 - source() with too many args fails'

.end
CODE
ok 1 - source() with no args returns source namespace, which is empty at first
ok 2 - source() with args sets source namespace
ok 3 - source() with too many args fails
OUT
# TODO test passing non-namespace pmc


pir_output_is( <<'CODE', <<'OUT', 'destination', todo => 'broken' );
.sub 'test' :main
    new $P0, .Exporter
    $P1 = $P0.'destination'()
    if $P1 == '' goto ok_1
    print 'not '
  ok_1:
    say 'ok 1 - destination() with no args returns destination namespace, which is empty at first'

    # get a NameSpace PMC for testing
    # TODO replace with make_namespace, when implemented
    .local pmc ns
    ns = get_namespace ['Eponymous']

    $P0.'destination'(ns)
    $P1 = $P0.'destination'()
    if $P1 == 'Eponymous' goto ok_2
    print 'not '
  ok_2:
    say 'ok 2 - destination() with args sets destination namespace'

    $P1 = clone ns

    push_eh ok_3
    $P0.'destination'(ns, $P1)
    clear_eh

    print 'not '
  ok_3:
    say 'ok 3 - destination() with too many args fails'

.end


# TODO replace with make_namespace, when implemented
.namespace ['Eponymous']
.sub 'Eponymous' :anon
.end
CODE
ok 1 - destination() with no args returns destination namespace, which is empty at first
ok 2 - destination() with args sets destination namespace
ok 3 - destination() with too many args fails
OUT
# TODO test passing non-namespace pmc


pir_output_is( <<'CODE', <<'OUT', 'globals' );
.sub 'test' :main
    $P0 = new .Exporter

    $P1 = $P0.'globals'()
    $I0 = does $P1, 'array'
    if $I0 goto ok_1
    print 'not '
  ok_1:
    say 'ok 1 - globals() with no args returns globals array'

    $I0 = $P1
    if $I0 == 0 goto ok_2
    print 'not '
  ok_2:
    say 'ok 2 - ...which is empty at first'

    # create an array to store globals in
    $P99 = new .ResizableStringArray

    $P0.'globals'($P99)
    $P1 = $P0.'globals'()
    $I99 = $P99
    $I1 = $P1
    unless $I1 == $I99 goto nok_3
    unless $I1 == 0 goto ok_3
    goto ok_3
  nok_3:
    print 'not '
  ok_3:
    say 'ok 3 - globals() with args sets globals array (empty array)'

    $P99 = push 'Alex'
    $P99 = push 'Prince'

    $P0.'globals'($P99)
    $P1 = $P0.'globals'()
    $I99 = $P99
    $I1 = $P1
    unless $I1 == $I99 goto nok_4
    unless $I1 == 2 goto nok_4
    $S0 = pop $P1
    unless $S0 == 'Prince' goto nok_4
    $S0 = pop $P1
    unless $S0 == 'Alex' goto nok_4
    goto ok_4
  nok_4:
    print 'not '
  ok_4:
    say 'ok 4 - globals() with args sets globals array (array with two values)'


    $P98 = clone $P99

    push_eh ok_5
    $P0.'globals'($P99, $P98)
    clear_eh

    print 'not '
  ok_5:
    say 'ok 5 - globals() with too many args fails'

.end
CODE
ok 1 - globals() with no args returns globals array
ok 2 - ...which is empty at first
ok 3 - globals() with args sets globals array (empty array)
ok 4 - globals() with args sets globals array (array with two values)
ok 5 - globals() with too many args fails
OUT


## TODO add_global


## TODO import




# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
