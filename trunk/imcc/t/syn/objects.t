#!perl
use strict;
use TestCompiler tests => 10;

##############################
# Parrot Calling Conventions


output_is(<<'CODE', <<'OUT', "meth call syntax");

.sub _main
    .local pmc class
    .local pmc obj
    newclass class, "Foo"
    find_type $I0, "Foo"
    new obj, $I0
    obj._meth()
    obj->_meth()
    print "done\n"
    end
.end

.namespace [ "Foo" ]
.sub _meth
    print "in meth\n"
.end
CODE
in meth
in meth
done
OUT

output_is(<<'CODE', <<'OUT', "meth call syntax m.o(arg)");
.sub _main
    .local pmc class
    .local pmc obj
    newclass class, "Foo"
    find_type $I0, "Foo"
    new obj, $I0
    $P0 = new PerlString
    $P0 = "ok\n"
    obj. _meth($P0)
    print "done\n"
    end
.end

.namespace [ "Foo" ]
.sub _meth
    .param pmc s
    print "in meth\n"
    print s
.end
CODE
in meth
ok
done
OUT

output_is(<<'CODE', <<'OUT', "meth call ret = o.m(arg)");
.sub _main
    .local pmc class
    .local pmc obj
    newclass class, "Foo"
    find_type $I0, "Foo"
    new obj, $I0
    $P0 = new PerlString
    $P0 = "ok\n"
    $S0 = obj._meth($P0)
    print $S0
    end
.end

.namespace [ "Foo" ]
.sub _meth
    .param pmc s
    print "in meth\n"
    print s
    .pcc_begin_return
    .return "done\n"
    .pcc_end_return
.end
CODE
in meth
ok
done
OUT

output_is(<<'CODE', <<'OUT', "meth call syntax");
.sub _main
    .local pmc class
    .local pmc obj
    .local string meth
    meth = "_meth"
    newclass class, "Foo"
    find_type $I0, "Foo"
    new obj, $I0
    obj."_meth"()
    obj->meth()
    set S10, "_meth"
    obj->S10()
    set $S10, "_meth"
    obj->$S10()
    print "done\n"
    end
.end
.namespace [ "Foo" ]
.sub _meth
    print "in meth\n"
.end
CODE
in meth
in meth
in meth
in meth
done
OUT

output_is(<<'CODE', <<'OUT', "initializer");
.sub _main
    newclass P1, "Foo"
    subclass P2, P1, "Bar"
    subclass P3, P2, "Baz"
    find_type I1, "Baz"
    new P3, I1
    find_global P0, "_sub"
    invokecc
    print "done\n"
    end
.end

.namespace ["Foo"]
.sub __init
    print "foo_init\n"
.end

.namespace ["Bar"]
.sub __init
    print "bar_init\n"
.end

.namespace ["Baz"]
.sub __init
    print "baz_init\n"
.end

.namespace [""]	# main again
.sub _sub
    print "in sub\n"
.end
CODE
foo_init
bar_init
baz_init
in sub
done
OUT

output_is(<<'CODE', <<'OUT', "meth call syntax - method, self");

.sub _main
    .local pmc class
    .local pmc obj
    newclass class, "Foo"
    find_type $I0, "Foo"
    new obj, $I0
    obj._meth()
    print "done\n"
    end
.end

.namespace [ "Foo" ]
.sub _meth method
    print "in meth\n"
    isa $I0, self, "Foo"
    if $I0, ok
    print "not "
ok:
    print "ok\n"
.end
CODE
in meth
ok
done
OUT

output_is(<<'CODE', <<'OUT', "explicit meth call syntax");

.sub _main
    .local pmc class
    .local pmc obj
    newclass class, "Foo"
    find_type $I0, "Foo"
    new obj, $I0
    .pcc_begin prototyped
    .invocant obj
    .meth_call "_meth"
    .pcc_end
    print "done\n"
    end
.end

.namespace [ "Foo" ]
.sub _meth
    print "in meth\n"
.end
CODE
in meth
done
OUT

output_is(<<'CODE', <<'OUT', "explicit meth call syntax, meth var");

.sub _main
    .local pmc class
    .local pmc obj
    .local string meth
    newclass class, "Foo"
    find_type $I0, "Foo"
    new obj, $I0
    meth = "_meth"
    .pcc_begin prototyped
    .invocant obj
    .meth_call meth
    .pcc_end
    print "done\n"
    end
.end

.namespace [ "Foo" ]
.sub _meth
    print "in meth\n"
.end
CODE
in meth
done
OUT
output_is(<<'CODE', <<'OUT', "explicit meth call syntax, args");

.sub _main
    .local pmc class
    .local pmc obj
    newclass class, "Foo"
    find_type $I0, "Foo"
    new obj, $I0
    .pcc_begin prototyped
    .arg "hello"
    .arg "\n"
    .invocant obj
    .meth_call "_meth"
    .result $S0
    .pcc_end
    print $S0
    print "done\n"
    end
.end

.namespace [ "Foo" ]
.sub _meth
    .param string p1
    .param string p2
    print "in meth\n"
    print p1
    print p2
    .pcc_begin_return
    .return "ok\n"
    .pcc_end_return
.end
CODE
in meth
hello
ok
done
OUT

output_is(<<'CODE', <<'OUT', "explicit meth call syntax, retcont");

.sub _main
    .local pmc class
    .local pmc obj
    newclass class, "Foo"
    find_type $I0, "Foo"
    new obj, $I0
    .local pmc retc
    newsub retc, .RetContinuation, label
    .pcc_begin prototyped
    .invocant obj
    .meth_call "_meth", retc
label:
    .pcc_end
    print "done\n"
    end
.end

.namespace [ "Foo" ]
.sub _meth
    print "in meth\n"
.end
CODE
in meth
done
OUT
