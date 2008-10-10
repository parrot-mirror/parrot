#!./parrot
# Copyright (C) 2001-2008, The Perl Foundation.
# $Id$

=head1 NAME

t/library/p6object.t -- P6object tests

=head1 SYNOPSIS

    % prove t/library/p6object.t

=head1 DESCRIPTION

Testing Perl 6 objects.

=cut

.sub 'main' :main
    load_bytecode 'library/Test/More.pbc'

    .local pmc exports, curr_namespace, test_namespace
    curr_namespace = get_namespace
    test_namespace = get_namespace ['Test';'More']
    exports        = split ' ', 'plan diag ok nok is todo'
    test_namespace.'export_to'(curr_namespace, exports)

    ##  set our plan
    plan(232)

    ##  make sure we can load the P6object library
    push_eh load_fail
    load_bytecode 'P6object.pbc'
    pop_eh
    ok(1, 'load_bytecode')
    goto load_success

  load_fail:
    ok(0, "load_bytecode 'P6object.pir' failed -- skipping tests")
    .return ()

  load_success:
    ##  test the P6metaclass protoobject itself
    .local pmc p6meta
    p6meta = get_hll_global 'P6metaclass'
    p6obj_tests(p6meta, 'P6metaclass', 'isa'=>'P6metaclass')

    ##  register an existing PMCProxy-based class
    .local pmc hashproto, hashobj
    $P0 = p6meta.'register'('Hash')
    hashproto = get_hll_global 'Hash'
    is_same($P0, hashproto, 'return from .register =:= Hash')
    hashobj = p6obj_tests(hashproto, 'Hash', 'isa'=>'Hash')
    ##  make sure class of hash object is still a PMCProxy
    isa_nok(hashobj, 'P6object', 'Hash_obj')
    $P0 = typeof hashobj
    $S0 = typeof $P0
    is($S0, 'PMCProxy', '< typeof Hash_obj > returns PMCProxy instance')
    ##  make sure Hash objects don't get a .new method
    $I0 = can hashobj, 'new'
    nok($I0, '! < can Hash_obj, "new" >')

    ##  create a new standalone class by name
    .local pmc abcproto, abcobj, abcmeta
    $P0 = p6meta.'new_class'('ABC')
    abcproto = get_hll_global 'ABC'
    is_same($P0, abcproto, 'return from .new_class =:= ABC')
    $P0 = split ' ', 'P6object'
    abcobj = p6obj_tests(abcproto, 'ABC', 'isa'=>'ABC P6object', 'can'=>'foo')
    ##  make sure negative tests for 'can' work
    $I0 = can abcobj, 'bar'
    nok($I0, '! <can ABC_obj, "bar" >')
    $P0 = abcobj.'HOW'()
    $I0 = $P0.'can'(abcobj, 'bar')
    nok($I0, '! ABC_obj.^can("bar")')
    ##  make sure abcobj didn't get a .new method
    $I0 = can abcobj, 'new'
    nok($I0, '! <can ABC_obj, "new" >')

    ##  create new class by namespace
    .local pmc ghins, ghiproto, ghiobj
    ghins = get_hll_namespace ['GHI']
    $P0 = p6meta.'new_class'(ghins)
    ghiproto = get_hll_global 'GHI'
    ghiobj = p6obj_tests(ghiproto, 'GHI', 'can'=>'foo')

    ##  create a subclass called DEF1 from 'ABC'
    .local pmc defproto, defobj
    $P0 = p6meta.'new_class'('DEF1', 'parent'=>'ABC')
    defproto = get_hll_global 'DEF1'
    is_same($P0, defproto, 'return from .new_class =:= DEF1')
    defobj = p6obj_tests(defproto, 'DEF1', 'isa'=>'DEF1 ABC P6object')

    ##  create a subclass called DEF2 from ABC proto
    $P0 = p6meta.'new_class'('DEF2', 'parent'=>abcproto)
    defproto = get_hll_global 'DEF2'
    is_same($P0, defproto, 'return from .new_class =:= DEF2')
    defobj = p6obj_tests(defproto, 'DEF2', 'isa'=>'DEF2 ABC P6object')

    ##  create a subclass of a PMC called MyInt
    .local pmc myintproto, myintobj, myintmeta
    $P0 = p6meta.'new_class'('MyInt', 'parent'=>'Integer')
    myintproto = get_hll_global 'MyInt'
    is_same($P0, myintproto, 'return from .new_class =:= MyInt')
    myintobj = p6obj_tests(myintproto, 'MyInt', 'isa'=>'MyInt Integer P6object')

    ##  map Integer PMC objects to MyInt class, don't inherit from MyInt
    .local pmc integerobj, integermeta
    p6meta.'register'('Integer', 'protoobject'=>myintproto)
    integerobj = new 'Integer'
    $S0 = typeof integerobj
    is($S0, 'Integer', '< new "Integer" > still gives Integer PMC')
    $P0 = integerobj.'WHAT'()
    is_same($P0, myintproto, 'Integer_obj.WHAT =:= MyInt')
    integermeta = integerobj.'HOW'()
    myintmeta = myintobj.'HOW'()
    is_same(integermeta, myintmeta, 'Integer_obj.HOW =:= MyInt.HOW')
    $I0 = can myintobj, 'foo'
    ok($I0, '< can MyInt_obj, "foo" >')
    $I0 = can integerobj, 'foo'
    nok($I0, '! < can Integer_obj, "foo" >')

    ##  map ResizablePMCArray objects to List class, inherit from List
    .local pmc listproto, listobj, rpaobj
    listproto = p6meta.'new_class'('List', 'parent'=>'ResizablePMCArray')
    p6meta.'register'('ResizablePMCArray', 'parent'=>listproto, 'proto'=>listproto)
    listobj = new 'List'
    $I0 = can listobj, 'foo'
    ok($I0, '< can List_obj, "foo" >')
    rpaobj = new 'ResizablePMCArray'
    ok($I0, '< can ResizablePMCArray_obj, "foo" >')
    $P0 = rpaobj.'HOW'()
    $I0 = $P0.'can'(rpaobj, 'foo')
    ok($I0, '< ResizablePMCArray_obj.^can("foo") >')
    $I0 = $P0.'isa'(rpaobj, listproto)
    todo($I0, '< ResizablePMCArray_obj.^isa(List) >', 'UNIMPL?')

    ##  create class with a different proto name
    .local pmc myobjectproto
    $P0 = p6meta.'new_class'('MyObject', 'name'=>'Object')
    myobjectproto = get_hll_global 'Object'
    p6obj_tests(myobjectproto, 'MyObject', 'classname'=>'Object', 'isa'=>'P6object')
    $P0 = get_hll_global 'MyObject'
    $I0 = isa $P0, 'P6protoobject'
    nok($I0, ".new_class didn't store proto as MyObject")

    ##  create class with ::-style name
    .local pmc jklproto, jklobj
    $P0 = p6meta.'new_class'('Foo::JKL')
    jklproto = get_hll_global ['Foo'], 'JKL'
    is_same($P0, jklproto, 'return from .new_class =:= Foo::JKL')
    $P0 = get_hll_global 'Foo::JKL'
    isa_nok($P0, 'P6protoobject', '["Foo::JKL"]')
    p6obj_tests(jklproto, 'Foo::JKL', 'shortname'=>'JKL', 'isa'=>'P6object', 'can'=>'foo')

=for never

    isa_ok(mnoproto, 'Float', 'MNO proto')
    isa_ok(mnoproto, 'ABC', 'MNO proto')
    isa_ok(mnoproto, 'P6object', 'MNO proto')
    isa_ok(mnoproto, 'P6protoobject', 'MNO proto')
    mno = mnoproto.'new'()
    isa_ok(mno, 'Float', 'MNO object')
    isa_ok(mno, 'ABC', 'MNO object')
    isa_ok(mno, 'P6object', 'MNO object')
    $I0 = isa mno, 'P6protoobject'
    nok($I0, 'MNO object not isa P6protoobject')

    ##  create a subclass from a protoobject reference
    .local pmc pqrproto, pqr
    p6meta.'new_class'('PQR', 'parent'=>mnoproto)
    pqrproto = get_hll_global 'PQR'
    isa_ok(pqrproto, 'PQR', 'PQR proto')
    isa_ok(pqrproto, 'MNO', 'PQR proto')
    isa_ok(pqrproto, 'Float', 'PQR proto')

    ##  use the :name option to set a class name
    .local pmc p6objproto, p6obj
    p6meta.'new_class'('Perl6Object', 'name'=>'Object')
    p6objproto = get_hll_global 'Object'
    isa_ok(p6objproto, 'Perl6Object', 'Object proto')
    isa_ok(p6objproto, 'P6object', 'Object proto')
    isa_ok(p6objproto, 'P6protoobject', 'Object proto')
    $S0 = p6objproto
    is($S0, 'Object', 'Object.WHAT eq "Object"')
    $P0 = get_hll_global 'Perl6Object'
    isa_nok($P0, 'P6protoobject', 'Perl6Object')
    p6obj = p6objproto.'new'()
    isa_ok(p6obj, 'Perl6Object', 'Object instance')
    $P0 = p6obj.'WHAT'()
    $I0 = issame $P0, p6objproto
    ok($I0, 'obj.WHAT =:= Object.WHAT')

    ## make sure it works for array-based names
    .local pmc stuproto
    $P0 = split '::', 'Foo::STU'
    $P0 = p6meta.'new_class'($P0)
    stuproto = get_hll_global ['Foo'], 'STU'
    $I0 = issame stuproto, $P0
    ok($I0, 'Foo::STU proto =:= return value from .new_class()')
    $P0 = get_class ['Foo';'STU']
    isa_ok(stuproto, $P0, 'Foo::STU proto')
    isa_ok(stuproto, 'P6object', 'Foo::STU proto')
    isa_ok(stuproto, 'P6protoobject', 'Foo::STU proto')
    $P0 = stuproto.'WHAT'()
    $I0 = issame stuproto, $P0
    ok($I0, 'Foo::STU proto .WHAT identity')
    $S0 = stuproto
    is($S0, 'STU', 'Foo::STU.WHAT eq "STU"')
    $P0 = stuproto.'HOW'()
    isa_ok($P0, 'P6metaclass', 'Foo::STU proto .HOW')
    $I0 = defined stuproto
    nok($I0, 'Foo::STU proto undefined')

    ##  remapping ResizablePMCArray to List
    .local pmc listproto
    listproto = p6meta.'new_class'('List', 'parent'=>'ResizablePMCArray')
    p6meta.'register'('ResizablePMCArray', 'parent'=>listproto, 'protoobject'=>listproto)
    $P0 = new 'List'
    $I0 = can $P0, 'elems'
    ok($I0, 'List can elems')
    $P0 = new 'ResizablePMCArray'
    $I0 = can $P0, 'elems'
    ok($I0, 'ResizablePMCArray inherits List methods')

    ##  building a class from another hll namespace
    $P0 = get_root_namespace ['foo';'XYZ';'Bar']
    .local pmc barproto, barobj
    barproto = p6meta.'new_class'($P0)
    $P0 = get_root_global ['foo';'XYZ'], 'Bar'
    $I0 = issame $P0, barproto
    ok($I0, 'XYZ::Bar protoobject created in foo HLL namespace')
    $P0 = get_hll_global ['XYZ'], 'Bar'
    $I0 = isnull $P0
    ok($I0, 'XYZ::Bar protoobject not created in parrot HLL namespace')
    barobj = barproto.'new'()
    $S0 = barobj.'hello'()
    is($S0, 'XYZ::Bar::hello', 'method call to XYZ::Bar object works')

    .local pmc wtfproto, dostuff
    dostuff = get_root_global ['foo'], 'dostuff'
    wtfproto = dostuff(p6meta)
    $P0 = get_root_global ['foo';'WTF'], 'Lol'
    $I0 = issame $P0, wtfproto
    ok($I0, 'WTF::Lol protoobject created in foo HLL namespace')

=cut

    .local pmc hll_tests
    hll_tests = get_root_global ['myhll'], 'hll_tests'
    hll_tests()

    .return ()
.end


=head1 SUBROUTINES

=over 4

=item p6obj_tests(proto, class [, options])

Run a sequence of standard tests on a protoobject.  As part of the
tests it also creates an instance using the C<.new> method of
C<proto>, does some tests on the instance, and returns it.
The available options include:

    shortname    the name expected from stringifying the protoobject
    typename     the name expected from C<typeof>
    isa          a list of classes to test for "isa" semantics

=cut

.sub 'p6obj_tests'
    .param pmc proto
    .param pmc class
    .param pmc options         :slurpy :named

    .local string classname, shortname, typename
    classname = hash_default(options, 'classname', class)
    shortname = hash_default(options, 'shortname', classname)
    typename =  hash_default(options, 'typename',  classname)

    .local string msg

    isa_ok(proto, 'P6protoobject', classname)

    msg = 'concat'('< get_string ', classname, ' > eq "', shortname, '"')
    $S0 = proto
    is($S0, shortname, msg)

    msg = 'concat'('< typeof ', classname, ' > eq "', typename, '"')
    $S0 = typeof proto
    is($S0, typename, msg)

    msg = 'concat'('< defined ', classname, ' >')
    $I0 = defined proto
    nok($I0, msg)

    msg = 'concat'(classname, '.WHAT identity')
    $P0 = proto.'WHAT'()
    is_same(proto, $P0, msg)

    .local pmc meta
    msg = 'concat'(classname, '.HOW')
    meta = proto.'HOW'()
    isa_ok(meta, 'P6metaclass', msg)

    .local pmc obj, objmeta
    ##  skip object creation and tests for P6metaclass
    null obj
    $I0 = isa proto, 'P6metaclass'
    if $I0 goto obj_done

    .local string objname
    objname = 'concat'(shortname, '_obj')

    obj = proto.'new'()
    isa_nok(obj, 'P6Protoobject', objname)

    msg = 'concat'(objname, '.WHAT =:= ', classname)
    $P0 = obj.'WHAT'()
    is_same($P0, proto, msg)

    msg = 'concat'(objname, '.HOW =:= ', classname, '.HOW')
    objmeta = obj.'HOW'()
    is_same(objmeta, meta, msg)

    msg = 'concat'(objname, '.^isa(', classname, ')')
    $I0 = objmeta.'isa'(obj, proto)
    ok($I0, msg)

  obj_done:

    ##  test 'isa' semantics
    .local pmc isalist
    $P0 = hash_default(options, 'isa', class)
    unless $P0 goto isa_done
    isalist = qw($P0)
    .local pmc isaiter, isatest
    isaiter = iter isalist
  isa_loop:
    unless isaiter goto isa_done
    isatest = shift isaiter
    isa_ok(proto, isatest, classname)
    msg = 'concat'(classname, '.^isa("', isatest, '")')
    $I0 = meta.'isa'(proto, isatest)
    ok($I0, msg)
    if null obj goto isa_loop
    isa_ok(obj, isatest, objname)
    msg = 'concat'(objname, '.^isa("', isatest, '")')
    $I0 = meta.'isa'(obj, isatest)
    ok($I0, msg)
    goto isa_loop
  isa_done:

    ## test 'can' semantics
    .local pmc canlist
    $P0 = hash_default(options, 'can', '')
    unless $P0 goto can_done
    canlist = qw($P0)
    .local pmc caniter
    .local string cantest
    caniter = iter canlist
  can_loop:
    unless caniter goto can_done
    cantest = shift caniter
    msg = 'concat'('< can ', classname, ', "', cantest, '" >')
    $I0 = can proto, cantest
    ok($I0, msg)
    msg = 'concat'(classname, '.^can("', cantest, '")')
    $I0 = meta.'can'(proto, cantest)
    ok($I0, msg)
    msg = 'concat'('< can ', objname, ', "', cantest, '" >')
    if null obj goto can_loop
    $I0 = can obj, cantest
    ok($I0, msg)
    msg = 'concat'(objname, '.^can("', cantest, '")')
    $I0 = meta.'can'(obj, cantest)
    ok($I0, msg)
    goto can_loop
  can_done:

    .return (obj)
.end

=item concat([args])

Concatenate several strings into a single string.

=cut

.sub 'concat'
    .param pmc args :slurpy
    $S0 = join '', args
    .return ($S0)
.end

=item qw(value)

If C<value> is already an array of some sort, return it, otherwise
split C<value> on spaces and return that.

=cut

.sub 'qw'
    .param pmc value 
    $I0 = does value, 'array'
    if $I0 goto done
    $S0 = value
    value = split ' ', $S0
  done:
    .return (value)
.end


=item hash_default(hash, key, default)

Return the entry in C<hash[key]> if it exists, otherwise return C<default>.

=cut

.sub 'hash_default'
    .param pmc hash
    .param string key
    .param pmc value
    $I0 = exists hash[key]
    unless $I0 goto done
    value = hash[key]
  done:
    .return (value)
.end

=item is_same(x, y, message)

Test for x and y being the same PMC.

=cut

.sub 'is_same'
    .param pmc x
    .param pmc y
    .param string msg
    $I0 = issame x, y
    ok($I0, msg)
.end

=item isa_ok(object, class, objectname)

=item isa_ok(object, class, objectname)

Test if C<object> is/isn't an instance of C<class> as reported
by the C<isa> opcode.  C<objectname> is used to generate the 
diagnostic message in output (i.e., it's not the actual 
diagnostic message).

=cut

.sub 'isa_ok'
    .param pmc obj
    .param pmc class
    .param string objectname
    $S0 = 'concat'('< isa ', objectname, ', "', class, '" >')
    $I0 = 0
    if null obj goto done
    $I0 = isa obj, class
  done:
    ok($I0, $S0)
.end

.sub 'isa_nok'
    .param pmc obj
    .param pmc class
    .param string object_name
    $S0 = 'concat'('! < isa ', object_name, ', "', class, '" >')
    $I0 = 0
    if null obj goto done
    $I0 = isa obj, class
  done:
    nok($I0, $S0)
.end


.namespace ['ABC']
.sub 'foo' :method
    .return ('ABC::foo')
.end

.namespace ['GHI']
.sub 'foo' :method
    .return ('GHI::foo')
.end

.namespace ['MyInt']
.sub 'foo' :method
    .return ('MyInt::foo')
.end

.namespace ['List']
.sub 'foo' :method
    .return ('List::foo')
.end

.namespace ['Foo';'JKL']
.sub 'foo' :method
    .return ('Foo::JKL::foo')
.end

.HLL 'myhll', ''

.sub 'hll_tests'
    .local pmc exports, curr_namespace, root_namespace
    curr_namespace = get_namespace
    root_namespace = get_root_namespace ['parrot']
    exports        = split ' ', 'plan diag ok nok is todo is_same isa_ok isa_nok p6obj_tests'
    root_namespace.'export_to'(curr_namespace, exports)

    .local pmc p6meta
    p6meta = get_root_global ['parrot'], 'P6metaclass'

    ##  build HLL class using namespace
    .local pmc xyzns, xyzproto, xyzobj
    xyzns = get_hll_namespace ['XYZ']
    $P0 = p6meta.'new_class'(xyzns)
    xyzproto = get_hll_global 'XYZ'
    is_same($P0, xyzproto, 'return from .new_class =:= XYZ')
    $P0 = get_root_global ['parrot'], 'XYZ'
    $I0 = isnull $P0
    ok($I0, ".new_class didn't store ['parrot'], 'XYZ'")
    p6obj_tests(xyzproto, 'XYZ', 'isa'=>'XYZ P6object', 'can'=>'foo')

    ##  build HLL class using name
    .local pmc wxyproto, wxyobj
    $P0 = p6meta.'new_class'('WXY')
    wxyproto = get_hll_global 'WXY'
    is_same($P0, wxyproto, 'return from .new_class =:= WXY')
    $P0 = get_root_global ['parrot'], 'WXY'
    $I0 = isnull $P0
    ok($I0, ".new_class didn't store ['parrot'], 'WXY'")
    p6obj_tests(wxyproto, 'WXY', 'isa'=>'WXY P6object', 'can'=>'foo')
.end

.namespace ['XYZ']
.sub 'foo' :method
    .return ('XYZ::foo')
.end

.namespace ['WXY']
.sub 'foo' :method
    .return ('WXY::foo')
.end

=back

=cut
