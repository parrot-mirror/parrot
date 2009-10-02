#! parrot
# Copyright (C) 2009, Patrick R. Michaud
# $Id$

=head1 NAME

t/compilers/pct/regex/04-protoregex.t -- basic protoregex tests

=head1 SYNOPSIS

    % prove t/compilers/pct/regex/04-protoregex.t

=cut

.sub 'main' :main
    load_bytecode 'Test/More.pbc'

    .local pmc exports, curr_namespace, test_namespace
    curr_namespace = get_namespace
    test_namespace = get_namespace ['Test';'More']
    exports        = split ' ', 'plan diag ok nok is todo'
    test_namespace.'export_to'(curr_namespace, exports)

    load_bytecode 'PCT/Regex.pbc'

    # create a grammar for us to test
    .local pmc p6meta, xyz
    p6meta = get_hll_global 'P6metaclass'
    xyz = p6meta.'new_class'('XYZ', 'parent'=>'Regex::Cursor')

    # add some symtokens
    xyz.'!symtoken_add'('term:sym<abc>', 'abc')
    xyz.'!symtoken_add'('infix:sym<+>', '+')
    xyz.'!symtoken_add'('infix:sym<->', '-')
    xyz.'!symtoken_add'('infix:sym<++>', '++')
    xyz.'!symtoken_add'('infix:sym<+->', '+-')
    xyz.'!symtoken_add'('term:sym<ab>', 'ab')
    xyz.'!symtoken_add'('term:sym<foo>', 'foo')

    # create a cursor for matching
    .local pmc cur
    cur = xyz.'!cursor_init'('abc++-')

    $I0 = p6meta.'isa'(cur, xyz)
    ok($I0, 'match cursor isa XYZ')

    .local pmc abc, match
    abc = cur.'term'()
    ok(abc, 'Matched <term> abc')
    match = abc.'MATCH'()
    ok(match, '?$/')
    $I0 = match.'from'()
    is($I0, 0, "$/.from")
    $I0 = match.'to'()
    is($I0, 3, "$/.to")
    $S0 = match['sym']
    is($S0, 'abc', "$<sym>")

    .local pmc op
    op = abc.'infix'()
    ok(op, 'Matched <infix> after abc')
    match = op.'MATCH'()
    ok(match, '?$/')
    $I0 = match.'from'()
    is($I0, 3, "$/.from")
    $I0 = match.'to'()
    is($I0, 5, "$/.to")
    $S0 = match['sym']
    is($S0, '++', "$<sym>")

    .local pmc op2
    op2 = op.'infix'()
    ok(op2, 'Matched <infix> after ++')
    match = op2.'MATCH'()
    ok(match, '?$/')
    $I0 = match.'from'()
    is($I0, 5, "$/.from")
    $I0 = match.'to'()
    is($I0, 6, "$/.to")
    $S0 = match['sym']
    is($S0, '-', "$<sym>")

    # add another protoregex, to make sure we recalculate protoregex table
    xyz.'!symtoken_add'('term:sym<abc+>', 'abc+')

    .local pmc abc, match
    abc = cur.'term'()
    ok(abc, 'Matched initial abc+ <term>')
    match = abc.'MATCH'()
    ok(match, '?$/')
    $I0 = match.'from'()
    is($I0, 0, "$/.from")
    $I0 = match.'to'()
    is($I0, 4, "$/.to")
    $S0 = match['sym']
    is($S0, 'abc+', "$<sym>")

    .local pmc op
    op = abc.'infix'()
    ok(op, 'Matched <infix> after abc+')
    match = op.'MATCH'()
    ok(match, '?$/')
    $I0 = match.'from'()
    is($I0, 4, "$/.from")
    $I0 = match.'to'()
    is($I0, 6, "$/.to")
    $S0 = match['sym']
    is($S0, '+-', "$<sym>")

    .local pmc op2
    op2 = op.'infix'()
    nok(op2, 'Failed <infix> match after +-')

    cur = xyz.'!cursor_init'('abd++-')

    abc = cur.'term'()
    ok(abc, 'Matched <term> ab')
    match = abc.'MATCH'()
    ok(match, '?$/')
    $I0 = match.'from'()
    is($I0, 0, "$/.from")
    $I0 = match.'to'()
    is($I0, 2, "$/.to")
    $S0 = match['sym']
    is($S0, 'ab', "$<sym>")
.end


.namespace ['XYZ']

.sub 'term' :method
    .tailcall self.'!protoregex'('term')
.end

.sub 'infix' :method
    .tailcall self.'!protoregex'('infix')
.end

