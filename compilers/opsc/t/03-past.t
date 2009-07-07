#! ../../parrot

# "Comprehensive" test for creating PAST for op.
# Parse single op and check various aspects of created PAST.

.sub 'main'
    .include 'test_more.pir'
    load_bytecode 'opsc.pbc'

    plan(14)

    .local pmc compiler, past
    .local string buf
    buf = <<"END"
/*
THE HEADER
*/

VERSION = PARROT_VERSION;

inline op foo(out INT, in PMC, inconst NUM) :flow :deprecated {
    foo # We don't handle anything in C<body> during parse/past.
}
END

    compiler = compreg 'Ops'
    past = compiler.'compile'(buf, 'target'=>'past')
    ok(1, "PAST::Node created")

    $P0 = past['header']
    $S0 = $P0.'inline'()
    like($S0, 'HEADER', 'Header parsed')

    $P0 = past['ops']
    $P0 = $P0.'list'()
    $I0 = $P0
    is($I0, 1, 'We have 1 op')

    # Check op
    .local pmc op
    op = $P0[0]
    $S0 = op['name']
    is($S0, 'foo', "Name parsed")

    # Check op flags
    $P1 = op['flags']
    $I0 = $P1['flow']
    ok($I0, ':flow flag parsed')
    
    $I0 = $P1['deprecated']
    ok($I0, ':deprecated flag parsed')

    $I0 = $P1
    is($I0, 2, "And there is only 2 flags")

    # Check op params
    $P1 = op['parameters']
    $P1 = $P1.'list'()
    $I0 = $P1
    is($I0, 3, "Got 3 parameters")

    $P2 = $P1[0]
    $S0 = $P2['direction']
    is($S0, 'out', 'First direction is correct')
    $S0 = $P2['type']
    is($S0, 'INT', 'First type is correct')

    $P2 = $P1[1]
    $S0 = $P2['direction']
    is($S0, 'in', 'Second direction is correct')
    $S0 = $P2['type']
    is($S0, 'PMC', 'Second type is correct')

    $P2 = $P1[2]
    $S0 = $P2['direction']
    is($S0, 'inconst', 'Third direction is correct')
    $S0 = $P2['type']
    is($S0, 'NUM', 'Third type is correct')


.end

# Don't forget to update plan!

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
