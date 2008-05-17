#!./parrot
# Copyright (C) 2001-2008, The Perl Foundation.
# $Id$

=head1 NAME

t/library/p6object.t -- P6object tests

=head1 SYNOPSIS

    % prove t/library/p6object.t

=head1 DESCRIPTION

=cut

.sub 'main' :main
    load_bytecode 'library/Test/More.pbc'

    .local pmc exports, curr_namespace, test_namespace
    curr_namespace = get_namespace
    test_namespace = get_namespace ['Test';'More']
    exports        = split ' ', 'plan diag ok nok is isa_ok'

    test_namespace.'export_to'(curr_namespace, exports)

    ##  set our plan
    .local int plan_tests
    plan(27)

    ##  make sure we can load the P6object library
    push_eh load_failed
    load_bytecode 'P6object.pir'
    pop_eh
    ok(1, 'load_bytecode')

    ##  test the P6metaclass protoobject itself
    .local pmc metaproto
    metaproto = get_hll_global 'P6metaclass'
    isa_ok(metaproto, 'P6metaclass', 'P6metaclass protoobject')
    isa_ok(metaproto, 'P6protoobject', 'P6metaclass protoobject')
    $P0 = metaproto.'WHAT'()
    $I0 = issame metaproto, $P0
    ok($I0, 'P6metaclass.WHAT identity')
    $S0 = $P0
    is($S0, 'P6metaclass', 'P6metaclass.WHAT eq "P6metaclass"')
    $P0 = metaproto.'HOW'()
    isa_ok($P0, 'P6metaclass', 'P6metaclass.HOW()')
    $I0 = defined metaproto
    nok($I0, 'P6metaclass protoobject undefined')

    ##  register an existing PMCProxy class
    .local pmc hashproto
    hashproto = metaproto.register('Hash')
    isa_ok(hashproto, 'Hash', 'Hash from register()')
    isa_ok(hashproto, 'P6protoobject', 'Hash from register()')
    $P0 = get_hll_global 'Hash'
    $I0 = issame hashproto, $P0
    ok($I0, 'Hash =:= Hash from register()')
    $P0 = hashproto.'WHAT'()
    $I0 = issame hashproto, $P0
    ok($I0, 'Hash.WHAT identity')
    $S0 = hashproto
    is($S0, 'Hash', 'Hash.WHAT eq "Hash"')
    $P0 = hashproto.'HOW'()
    isa_ok($P0, 'P6metaclass', 'Hash.HOW')
    $I0 = defined metaproto
    nok($I0, 'Hash protoobject undefined')

    ##  instantiate from the protoobject (PMCProxy)
    .local pmc hash
    hash = hashproto.'new'()
    isa_ok(hash, 'Hash', 'return from Hash.new()')
    $I0 = isa hash, 'P6protoobject'
    nok($I0, 'hash not isa P6protoobject')
    ##  verify that it really is a Hash (PMCProxy) and not some subclass
    $P0 = typeof hash
    $S0 = typeof $P0
    is($S0, 'PMCProxy', 'return from Hash.new() has PMCProxy type')
    $P0 = hash.'WHAT'()
    $I0 = issame hashproto, $P0
    ok($I0, 'hash.WHAT =:= Hash')
    $P0 = hash.'HOW'()
    $P1 = hashproto.'HOW'()
    $I0 = issame $P0, $P1
    ok($I0, 'hash.HOW =:= Hash.HOW')
    ##  make sure it's defined
    $I0 = defined hash
    ok($I0, 'hash defined')

    ##  create a new standalone class, derived from P6object
    .local pmc abcproto
    abcproto = metaproto.'new_class'('ABC')
    isa_ok(abcproto, 'ABC', 'return from .new_class()')
    isa_ok(abcproto, 'P6object', 'return from .new_class()')
    isa_ok(abcproto, 'P6protoobject', '.return from .new_class()')
    $P0 = get_hll_global 'ABC'
    $I0 = issame abcproto, $P0
    ok($I0, 'ABC =:= ABC from .new_class()')
    $P0 = abcproto.'WHAT'()
    $I0 = issame abcproto, $P0
    ok($I0, 'ABC.WHAT identity')
    $S0 = abcproto
    is($S0, 'ABC', 'ABC.WHAT eq "ABC"')
    $I0 = defined metaproto
    nok($I0, 'ABC protoobject undefined')
    .return ()

    ##  try the default .new method on ABC protoobject
    .local pmc abc
    abc = abcproto.'new'()
    isa_ok(abc, 'ABC', 'return from ABC.new()')
    $P0 = abc.'WHAT'()
    $I0 = issame abcproto, $P0
    ok($I0, 'abc.WHAT =:= ABC')
    $P0 = abc.'HOW'()
    $P1 = abcproto.'HOW'()
    $I0 = issame $P0, $P1
    ok($I0, 'abc.HOW =:= ABC.HOW')
    $I0 = defined abc
    ok($I0, 'abc defined')

  load_failed:
    ok(0, "load_bytecode 'P6object.pir' failed -- skipping tests")
    .return ()
.end
