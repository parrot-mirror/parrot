#!perl

# Copyright (C) 2006-2007, The Perl Foundation.
# $Id$

use strict;
use warnings;
use lib qw( lib ../lib ../../lib jvm jvm/t );

use JavaCTesting;

use Test::More tests => 3;

## Testing class for this file.
die unless compile_java( "t.class", <<'JAVA');
namespace Testing
{
using System;

    class mummy
    {
        public int test()
        {
            return 666;
        }
    }

    class baby : mummy
    {
        public new int test()
        {
            return 42;
        }
    }

    class Test
    {
        public int test_call(mummy x)
        {
            return x.test();
        }
    }
}
CSHARP

## Attempt to translate.
ok( translate( "t.class", "t.pbc" ), 'translate' );

## Tests.
is( run_pir(<<'PIR'), <<'OUTPUT', 'mummy' );
.sub main
	.local pmc obj1, obj2
	load_bytecode "t.pbc"
	obj1 = new [ "Testing" ; "Test" ]
    obj2 = new [ "Testing" ; "mummy" ]
	$I0 = obj1.test_call(obj2)
    print $I0
    print "\n"
.end
PIR
666
OUTPUT

is( run_pir(<<'PIR'), <<'OUTPUT', 'baby' );
.sub main
	.local pmc obj1, obj2
	load_bytecode "t.pbc"
	obj1 = new [ "Testing" ; "Test" ]
    obj2 = new [ "Testing" ; "baby" ]
	$I0 = obj1.test_call(obj2)
    print $I0
    print "\n"
.end
PIR
42
OUTPUT

## Clean up.
unlink qw(t.class t.pbc);

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
