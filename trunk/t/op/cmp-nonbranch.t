#!parrot
# Copyright (C) 2006, The Perl Foundation.
# $Id$

=head1 NAME

t/op/cmp-nonbranch.t - Non-branching conditionals

=head1 SYNOPSIS

        % prove t/op/cmp-nonbranch.t

=head1 DESCRIPTION

Tests all non-branching conditional operators.

=cut


.const int TESTS = 88


.macro IMPORT( lib, subname )
    import_sub = find_global .lib, .subname
    store_global .subname, import_sub
.endm

.macro EXP()
  exp_nok:
    exp = 0
    ret
  exp_ok:
    exp = 1
    ret
.endm

.macro TEST()
  test:
    is( res, exp, desc )
    ret
.endm

.macro SET_DESC(op)
    desc = .op
.endm

.macro CONCAT_RES()
    S98 = I1
    concat res, S98
.endm


.sub 'main' :main
    load_bytecode 'Test/More.pir'

    .local pmc import_sub
    .IMPORT( 'Test::More', 'plan' )

    .local string res, exp, desc


    'plan'(TESTS)

    'issame'()
    'isntsame'()
    'istrue'()
    'isfalse'()
    'isnull'()
    'isgt'()
    'isge'()
    'isle'()
    'islt'()
    'iseq'()
    'isne'()
    'cmp'()
.end


.sub 'issame'
    load_bytecode 'Test/More.pir'
    .local pmc import_sub
    .IMPORT( 'Test::More', 'is' )

    .local int exp, res
    .local string desc
    .SET_DESC('issame')

  init:
    $P0 = new .Integer
    $P1 = new .String
    bsr exp_nok
    bsr test_it   # not ok
    $P0 = new .String
    bsr test_it   # not ok
    bsr exp_ok
    $P1 = $P0
    bsr test_it   # ok
    $P0 = new .Null
    $P1 = new .Null
    bsr test_it   # ok -- Null is a singleton
    .return ()

    .EXP()
  test_it:
    res = issame $P0, $P1
    .TEST()
.end


.sub 'isntsame'
    load_bytecode 'Test/More.pir'
    .local pmc import_sub
    .IMPORT( 'Test::More', 'is' )

    .local int exp, res
    .local string desc
    .SET_DESC('isntsame')

  init:
    $P0 = new .Integer
    $P1 = new .String
    bsr exp_ok
    bsr test_it   # ok
    $P0 = new .String
    bsr test_it   # ok
    $P1 = $P0
    bsr exp_nok
    bsr test_it   # not ok
    $P0 = new .Null
    $P1 = new .Null
    bsr test_it   # not ok -- Null is a singleton
    .return ()

    .EXP()
  test_it:
    res = isntsame $P0, $P1
    .TEST()
.end


.sub 'istrue'
    load_bytecode 'Test/More.pir'
    .local pmc import_sub
    .IMPORT( 'Test::More', 'is' )

    .local int exp, res
    .local string desc
    .SET_DESC('istrue')

  init:
    $P0 = new .Integer
    $P0 = 0
    bsr exp_nok
    bsr test_it   # not ok
    $P0 = 1
    bsr exp_ok
    bsr test_it   # ok
    .return ()

    .EXP()
  test_it:
    res = istrue $P0
    .TEST()
.end


.sub 'isfalse'
    load_bytecode 'Test/More.pir'
    .local pmc import_sub
    .IMPORT( 'Test::More', 'is' )

    .local int exp, res
    .local string desc
    .SET_DESC('isfalse')

  init:
    $P0 = new .Integer
    $P0 = 0
    bsr exp_ok
    bsr test_it   # ok
    $P0 = 1
    bsr exp_nok
    bsr test_it   # not ok
    .return ()

    .EXP()
  test_it:
    res = isfalse $P0
    .TEST()
.end


.sub 'isnull'
    load_bytecode 'Test/More.pir'
    .local pmc import_sub
    .IMPORT( 'Test::More', 'is' )

    .local int exp, res
    .local string desc
    .SET_DESC('isnull')

  init:
    $S0 = 'FUBAR'
    bsr exp_ok
    bsr test_it
    $S0 = 'Null' # this is a valid pmc type -- you can't trick parrot :)
    bsr exp_nok
    bsr test_it
    $S0 = 'Integer'
    bsr test_it
    .return ()

    .EXP()
  test_it:
    res = 0
    push_eh fubar
    $I1 = find_type $S0
    new $P0, $I1
    clear_eh
    goto test

  fubar:
    res = isnull $P0
    .TEST()
.end


.sub 'isgt'
    load_bytecode 'Test/More.pir'
    .local pmc import_sub
    .IMPORT( 'Test::More', 'is' )

    .local string exp, res
    .local string desc

    exp = '001'

    .SET_DESC('isgt_i_i_i')
    set I1, 111
    set I2, 222
    set I3, 333
    isgt I1, I2, I3
    .CONCAT_RES()
    set I2, I3
    isgt I1, I2, I3
    .CONCAT_RES()
    inc I2
    isgt I1, I2, I3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isgt_i_ic_i')
    set I1, 111
    set I3, 333
    isgt I1, 222, I3
    .CONCAT_RES()
    isgt I1, 333, I3
    .CONCAT_RES()
    isgt I1, 334, I3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isgt_i_i_ic')
    set I1, 111
    set I2, 222
    isgt I1, I2, 223
    .CONCAT_RES()
    isgt I1, I2, 222
    .CONCAT_RES()
    isgt I1, I2, 221
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isgt_i_ic_ic')
    set I1, 111
    isgt I1, 222, 223
    .CONCAT_RES()
    isgt I1, 222, 222
    .CONCAT_RES()
    isgt I1, 222, 221
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isgt_i_n_n')
    set I1, 111
    set N2, 2.22
    set N3, 3.33
    isgt I1, N2, N3
    .CONCAT_RES()
    set N2, N3
    isgt I1, N2, N3
    .CONCAT_RES()
    inc N2
    isgt I1, N2, N3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isgt_i_nc_n')
    set I1, 111
    set N3, 3.33
    isgt I1, 2.22, N3
    .CONCAT_RES()
    isgt I1, 3.33, N3
    .CONCAT_RES()
    isgt I1, 3.34, N3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isgt_i_n_nc')
    set I1, 111
    set N2, 2.22
    isgt I1, N2, 2.23
    .CONCAT_RES()
    isgt I1, N2, 2.22
    .CONCAT_RES()
    isgt I1, N2, 2.21
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isgt_i_nc_nc')
    set I1, 111
    isgt I1, 2.22, 2.23
    .CONCAT_RES()
    isgt I1, 2.22, 2.22
    .CONCAT_RES()
    isgt I1, 2.22, 2.21
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isgt_i_s_s')
    set I1, 111
    set S2, "Aaa"
    set S3, "Bbb"
    isgt I1, S2, S3
    .CONCAT_RES()
    set S2, S3
    isgt I1, S2, S3
    .CONCAT_RES()
    set S2, "Ccc"
    isgt I1, S2, S3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isgt_i_sc_s')
    set I1, 111
    set S3, "Bbb"
    isgt I1, "Aaa", S3
    .CONCAT_RES()
    isgt I1, "Bbb", S3
    .CONCAT_RES()
    isgt I1, "Ccc", S3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isgt_i_s_sc')
    set I1, 111
    set S2, "Bbb"
    isgt I1, S2, "Ccc"
    .CONCAT_RES()
    isgt I1, S2, "Bbb"
    .CONCAT_RES()
    isgt I1, S2, "Aaa"
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isgt_i_sc_sc')
    set I1, 111
    isgt I1, "Bbb", "Ccc"
    .CONCAT_RES()
    isgt I1, "Bbb", "Bbb"
    .CONCAT_RES()
    isgt I1, "Bbb", "Aaa"
    .CONCAT_RES()
    is( res, exp, desc)
.end


.sub 'isge'
    load_bytecode 'Test/More.pir'
    .local pmc import_sub
    .IMPORT( 'Test::More', 'is' )

    .local string exp, res
    .local string desc

    exp = '011'

    .SET_DESC('isge_i_i_i')
    set I1, 111
    set I2, 222
    set I3, 333
    isge I1, I2, I3
    .CONCAT_RES()
    set I2, I3
    isge I1, I2, I3
    .CONCAT_RES()
    inc I2
    isge I1, I2, I3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isge_i_ic_i')
    set I1, 111
    set I3, 333
    isge I1, 222, I3
    .CONCAT_RES()
    isge I1, 333, I3
    .CONCAT_RES()
    isge I1, 334, I3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isge_i_i_ic')
    set I1, 111
    set I2, 222
    isge I1, I2, 223
    .CONCAT_RES()
    isge I1, I2, 222
    .CONCAT_RES()
    isge I1, I2, 221
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isge_i_ic_ic')
    set I1, 111
    isge I1, 222, 223
    .CONCAT_RES()
    isge I1, 222, 222
    .CONCAT_RES()
    isge I1, 222, 221
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isge_i_n_n')
    set I1, 111
    set N2, 2.22
    set N3, 3.33
    isge I1, N2, N3
    .CONCAT_RES()
    set N2, N3
    isge I1, N2, N3
    .CONCAT_RES()
    inc N2
    isge I1, N2, N3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isge_i_nc_n')
    set I1, 111
    set N3, 3.33
    isge I1, 2.22, N3
    .CONCAT_RES()
    isge I1, 3.33, N3
    .CONCAT_RES()
    isge I1, 3.34, N3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isge_i_n_nc')
    set I1, 111
    set N2, 2.22
    isge I1, N2, 2.23
    .CONCAT_RES()
    isge I1, N2, 2.22
    .CONCAT_RES()
    isge I1, N2, 2.21
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isge_i_nc_nc')
    set I1, 111
    isge I1, 2.22, 2.23
    .CONCAT_RES()
    isge I1, 2.22, 2.22
    .CONCAT_RES()
    isge I1, 2.22, 2.21
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isge_i_s_s')
    set I1, 111
    set S2, "Aaa"
    set S3, "Bbb"
    isge I1, S2, S3
    .CONCAT_RES()
    set S2, S3
    isge I1, S2, S3
    .CONCAT_RES()
    set S2, "Ccc"
    isge I1, S2, S3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isge_i_sc_s')
    set I1, 111
    set S3, "Bbb"
    isge I1, "Aaa", S3
    .CONCAT_RES()
    isge I1, "Bbb", S3
    .CONCAT_RES()
    isge I1, "Ccc", S3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isge_i_s_sc')
    set I1, 111
    set S2, "Bbb"
    isge I1, S2, "Ccc"
    .CONCAT_RES()
    isge I1, S2, "Bbb"
    .CONCAT_RES()
    isge I1, S2, "Aaa"
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isge_i_sc_sc')
    set I1, 111
    isge I1, "Bbb", "Ccc"
    .CONCAT_RES()
    isge I1, "Bbb", "Bbb"
    .CONCAT_RES()
    isge I1, "Bbb", "Aaa"
    .CONCAT_RES()
    is( res, exp, desc)
.end


.sub 'isle'
    load_bytecode 'Test/More.pir'
    .local pmc import_sub
    .IMPORT( 'Test::More', 'is' )

    .local string exp, res
    .local string desc

    exp = '110'

    .SET_DESC('isle_i_i_i')
    set I1, 111
    set I2, 222
    set I3, 333
    isle I1, I2, I3
    .CONCAT_RES()
    set I2, I3
    isle I1, I2, I3
    .CONCAT_RES()
    inc I2
    isle I1, I2, I3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isle_i_ic_i')
    set I1, 111
    set I3, 333
    isle I1, 222, I3
    .CONCAT_RES()
    isle I1, 333, I3
    .CONCAT_RES()
    isle I1, 334, I3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isle_i_i_ic')
    set I1, 111
    set I2, 222
    isle I1, I2, 223
    .CONCAT_RES()
    isle I1, I2, 222
    .CONCAT_RES()
    isle I1, I2, 221
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isle_i_ic_ic')
    set I1, 111
    isle I1, 222, 223
    .CONCAT_RES()
    isle I1, 222, 222
    .CONCAT_RES()
    isle I1, 222, 221
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isle_i_n_n')
    set I1, 111
    set N2, 2.22
    set N3, 3.33
    isle I1, N2, N3
    .CONCAT_RES()
    set N2, N3
    isle I1, N2, N3
    .CONCAT_RES()
    inc N2
    isle I1, N2, N3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isle_i_nc_n')
    set I1, 111
    set N3, 3.33
    isle I1, 2.22, N3
    .CONCAT_RES()
    isle I1, 3.33, N3
    .CONCAT_RES()
    isle I1, 3.34, N3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isle_i_n_nc')
    set I1, 111
    set N2, 2.22
    isle I1, N2, 2.23
    .CONCAT_RES()
    isle I1, N2, 2.22
    .CONCAT_RES()
    isle I1, N2, 2.21
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isle_i_nc_nc')
    set I1, 111
    isle I1, 2.22, 2.23
    .CONCAT_RES()
    isle I1, 2.22, 2.22
    .CONCAT_RES()
    isle I1, 2.22, 2.21
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isle_i_s_s')
    set I1, 111
    set S2, "Aaa"
    set S3, "Bbb"
    isle I1, S2, S3
    .CONCAT_RES()
    set S2, S3
    isle I1, S2, S3
    .CONCAT_RES()
    set S2, "Ccc"
    isle I1, S2, S3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isle_i_sc_s')
    set I1, 111
    set S3, "Bbb"
    isle I1, "Aaa", S3
    .CONCAT_RES()
    isle I1, "Bbb", S3
    .CONCAT_RES()
    isle I1, "Ccc", S3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isle_i_s_sc')
    set I1, 111
    set S2, "Bbb"
    isle I1, S2, "Ccc"
    .CONCAT_RES()
    isle I1, S2, "Bbb"
    .CONCAT_RES()
    isle I1, S2, "Aaa"
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isle_i_sc_sc')
    set I1, 111
    isle I1, "Bbb", "Ccc"
    .CONCAT_RES()
    isle I1, "Bbb", "Bbb"
    .CONCAT_RES()
    isle I1, "Bbb", "Aaa"
    .CONCAT_RES()
    is( res, exp, desc)
.end


.sub 'islt'
    load_bytecode 'Test/More.pir'
    .local pmc import_sub
    .IMPORT( 'Test::More', 'is' )

    .local string exp, res
    .local string desc

    exp = '100'

    .SET_DESC('islt_i_i_i')
    set I1, 111
    set I2, 222
    set I3, 333
    islt I1, I2, I3
    .CONCAT_RES()
    set I2, I3
    islt I1, I2, I3
    .CONCAT_RES()
    inc I2
    islt I1, I2, I3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('islt_i_ic_i')
    set I1, 111
    set I3, 333
    islt I1, 222, I3
    .CONCAT_RES()
    islt I1, 333, I3
    .CONCAT_RES()
    islt I1, 334, I3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('islt_i_i_ic')
    set I1, 111
    set I2, 222
    islt I1, I2, 223
    .CONCAT_RES()
    islt I1, I2, 222
    .CONCAT_RES()
    islt I1, I2, 221
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('islt_i_ic_ic')
    set I1, 111
    islt I1, 222, 223
    .CONCAT_RES()
    islt I1, 222, 222
    .CONCAT_RES()
    islt I1, 222, 221
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('islt_i_n_n')
    set I1, 111
    set N2, 2.22
    set N3, 3.33
    islt I1, N2, N3
    .CONCAT_RES()
    set N2, N3
    islt I1, N2, N3
    .CONCAT_RES()
    inc N2
    islt I1, N2, N3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('islt_i_nc_n')
    set I1, 111
    set N3, 3.33
    islt I1, 2.22, N3
    .CONCAT_RES()
    islt I1, 3.33, N3
    .CONCAT_RES()
    islt I1, 3.34, N3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('islt_i_n_nc')
    set I1, 111
    set N2, 2.22
    islt I1, N2, 2.23
    .CONCAT_RES()
    islt I1, N2, 2.22
    .CONCAT_RES()
    islt I1, N2, 2.21
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('islt_i_nc_nc')
    set I1, 111
    islt I1, 2.22, 2.23
    .CONCAT_RES()
    islt I1, 2.22, 2.22
    .CONCAT_RES()
    islt I1, 2.22, 2.21
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('islt_i_s_s')
    set I1, 111
    set S2, "Aaa"
    set S3, "Bbb"
    islt I1, S2, S3
    .CONCAT_RES()
    set S2, S3
    islt I1, S2, S3
    .CONCAT_RES()
    set S2, "Ccc"
    islt I1, S2, S3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('islt_i_sc_s')
    set I1, 111
    set S3, "Bbb"
    islt I1, "Aaa", S3
    .CONCAT_RES()
    islt I1, "Bbb", S3
    .CONCAT_RES()
    islt I1, "Ccc", S3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('islt_i_s_sc')
    set I1, 111
    set S2, "Bbb"
    islt I1, S2, "Ccc"
    .CONCAT_RES()
    islt I1, S2, "Bbb"
    .CONCAT_RES()
    islt I1, S2, "Aaa"
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('islt_i_sc_sc')
    set I1, 111
    islt I1, "Bbb", "Ccc"
    .CONCAT_RES()
    islt I1, "Bbb", "Bbb"
    .CONCAT_RES()
    islt I1, "Bbb", "Aaa"
    .CONCAT_RES()
    is( res, exp, desc)
.end


.sub 'iseq'
    load_bytecode 'Test/More.pir'
    .local pmc import_sub
    .IMPORT( 'Test::More', 'is' )

    .local string exp, res
    .local string desc

    exp = '010'

    .SET_DESC('iseq_i_i_i')
    set I1, 111
    set I2, 222
    set I3, 333
    iseq I1, I2, I3
    .CONCAT_RES()
    set I2, I3
    iseq I1, I2, I3
    .CONCAT_RES()
    inc I2
    iseq I1, I2, I3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('iseq_i_ic_i')
    set I1, 111
    set I3, 333
    iseq I1, 222, I3
    .CONCAT_RES()
    iseq I1, 333, I3
    .CONCAT_RES()
    iseq I1, 334, I3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('iseq_i_i_ic')
    set I1, 111
    set I2, 222
    iseq I1, I2, 223
    .CONCAT_RES()
    iseq I1, I2, 222
    .CONCAT_RES()
    iseq I1, I2, 221
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('iseq_i_ic_ic')
    set I1, 111
    iseq I1, 222, 223
    .CONCAT_RES()
    iseq I1, 222, 222
    .CONCAT_RES()
    iseq I1, 222, 221
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('iseq_i_n_n')
    set I1, 111
    set N2, 2.22
    set N3, 3.33
    iseq I1, N2, N3
    .CONCAT_RES()
    set N2, N3
    iseq I1, N2, N3
    .CONCAT_RES()
    inc N2
    iseq I1, N2, N3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('iseq_i_nc_n')
    set I1, 111
    set N3, 3.33
    iseq I1, 2.22, N3
    .CONCAT_RES()
    iseq I1, 3.33, N3
    .CONCAT_RES()
    iseq I1, 3.34, N3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('iseq_i_n_nc')
    set I1, 111
    set N2, 2.22
    iseq I1, N2, 2.23
    .CONCAT_RES()
    iseq I1, N2, 2.22
    .CONCAT_RES()
    iseq I1, N2, 2.21
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('iseq_i_nc_nc')
    set I1, 111
    iseq I1, 2.22, 2.23
    .CONCAT_RES()
    iseq I1, 2.22, 2.22
    .CONCAT_RES()
    iseq I1, 2.22, 2.21
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('iseq_i_s_s')
    set I1, 111
    set S2, "Aaa"
    set S3, "Bbb"
    iseq I1, S2, S3
    .CONCAT_RES()
    set S2, S3
    iseq I1, S2, S3
    .CONCAT_RES()
    set S2, "Ccc"
    iseq I1, S2, S3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('iseq_i_sc_s')
    set I1, 111
    set S3, "Bbb"
    iseq I1, "Aaa", S3
    .CONCAT_RES()
    iseq I1, "Bbb", S3
    .CONCAT_RES()
    iseq I1, "Ccc", S3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('iseq_i_s_sc')
    set I1, 111
    set S2, "Bbb"
    iseq I1, S2, "Ccc"
    .CONCAT_RES()
    iseq I1, S2, "Bbb"
    .CONCAT_RES()
    iseq I1, S2, "Aaa"
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('iseq_i_sc_sc')
    set I1, 111
    iseq I1, "Bbb", "Ccc"
    .CONCAT_RES()
    iseq I1, "Bbb", "Bbb"
    .CONCAT_RES()
    iseq I1, "Bbb", "Aaa"
    .CONCAT_RES()
    is( res, exp, desc)
.end


.sub 'isne'
    load_bytecode 'Test/More.pir'
    .local pmc import_sub
    .IMPORT( 'Test::More', 'is' )

    .local string exp, res
    .local string desc

    exp = '101'

    .SET_DESC('isne_i_i_i')
    set I1, 111
    set I2, 222
    set I3, 333
    isne I1, I2, I3
    .CONCAT_RES()
    set I2, I3
    isne I1, I2, I3
    .CONCAT_RES()
    inc I2
    isne I1, I2, I3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isne_i_ic_i')
    set I1, 111
    set I3, 333
    isne I1, 222, I3
    .CONCAT_RES()
    isne I1, 333, I3
    .CONCAT_RES()
    isne I1, 334, I3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isne_i_i_ic')
    set I1, 111
    set I2, 222
    isne I1, I2, 223
    .CONCAT_RES()
    isne I1, I2, 222
    .CONCAT_RES()
    isne I1, I2, 221
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isne_i_ic_ic')
    set I1, 111
    isne I1, 222, 223
    .CONCAT_RES()
    isne I1, 222, 222
    .CONCAT_RES()
    isne I1, 222, 221
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isne_i_n_n')
    set I1, 111
    set N2, 2.22
    set N3, 3.33
    isne I1, N2, N3
    .CONCAT_RES()
    set N2, N3
    isne I1, N2, N3
    .CONCAT_RES()
    inc N2
    isne I1, N2, N3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isne_i_nc_n')
    set I1, 111
    set N3, 3.33
    isne I1, 2.22, N3
    .CONCAT_RES()
    isne I1, 3.33, N3
    .CONCAT_RES()
    isne I1, 3.34, N3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isne_i_n_nc')
    set I1, 111
    set N2, 2.22
    isne I1, N2, 2.23
    .CONCAT_RES()
    isne I1, N2, 2.22
    .CONCAT_RES()
    isne I1, N2, 2.21
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isne_i_nc_nc')
    set I1, 111
    isne I1, 2.22, 2.23
    .CONCAT_RES()
    isne I1, 2.22, 2.22
    .CONCAT_RES()
    isne I1, 2.22, 2.21
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isne_i_s_s')
    set I1, 111
    set S2, "Aaa"
    set S3, "Bbb"
    isne I1, S2, S3
    .CONCAT_RES()
    set S2, S3
    isne I1, S2, S3
    .CONCAT_RES()
    set S2, "Ccc"
    isne I1, S2, S3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isne_i_sc_s')
    set I1, 111
    set S3, "Bbb"
    isne I1, "Aaa", S3
    .CONCAT_RES()
    isne I1, "Bbb", S3
    .CONCAT_RES()
    isne I1, "Ccc", S3
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isne_i_s_sc')
    set I1, 111
    set S2, "Bbb"
    isne I1, S2, "Ccc"
    .CONCAT_RES()
    isne I1, S2, "Bbb"
    .CONCAT_RES()
    isne I1, S2, "Aaa"
    .CONCAT_RES()
    is( res, exp, desc)

    res = ''
    .SET_DESC('isne_i_sc_sc')
    set I1, 111
    isne I1, "Bbb", "Ccc"
    .CONCAT_RES()
    isne I1, "Bbb", "Bbb"
    .CONCAT_RES()
    isne I1, "Bbb", "Aaa"
    .CONCAT_RES()
    is( res, exp, desc)
.end


.sub 'cmp'
    load_bytecode 'Test/More.pir'
    .local pmc import_sub
    .IMPORT( 'Test::More', 'is' )

    .local string exp, res
    .local string desc
    .SET_DESC('isnull')

  init:
    set I0, 10
    cmp I1, I0, 9
    set N0, -2.4
    cmp I2, -2.4, N0
    set S0, "Bruhaha"
    cmp I3, S0, "Crumbum"
    new P0, .Integer
    new P1, .Integer
    set P0, 452
    set P1, -15
    cmp I4, P0, P1


    exp = <<'EXP'
1
0
-1
1
1
0
-1
EXP

  test_it:
    S99 = I1
    concat res, S99
    concat res, "\n"
    S99 = I2
    concat res, S99
    concat res, "\n"
    S99 = I3
    concat res, S99
    concat res, "\n"
    S99 = I4
    concat res, S99
    concat res, "\n"

    set I5, 9
    set I6, 10
    set I7, 11
    cmp I1, I0, I5
    cmp I2, I0, I6
    cmp I3, I0, I7
    S99 = I1
    concat res, S99
    concat res, "\n"
    S99 = I2
    concat res, S99
    concat res, "\n"
    S99 = I3
    concat res, S99
    concat res, "\n"

    is(exp, res, desc)
.end

