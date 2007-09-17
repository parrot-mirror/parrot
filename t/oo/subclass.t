#!perl
# Copyright (C) 2007, The Perl Foundation.
# $Id: new.t 21204 2007-09-12 04:15:39Z allison $

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More;
use Parrot::Test tests => 17;

=head1 NAME

t/oo/new.t - Test OO subclassing (instantiation)

=head1 SYNOPSIS

    % prove t/oo/subclass.t

=head1 DESCRIPTION

Tests OO features related to subclassing.

=cut

pir_output_is( <<'CODE', <<'OUT', 'instantiate subclass from class object');
.sub main :main
    $P0 = newclass "Pre"
    $P1 = subclass "Pre", "Foo"
    $S1 = typeof $P1
    say $S1

    $I3 = isa $P1, "Class"
    print $I3
    print "\n"

    $P2 = new $P1

    $S1 = typeof $P2
    say $S1

    $I3 = isa $P2, "Foo"
    print $I3
    print "\n"

    $I3 = isa $P2, "Object"
    print $I3
    print "\n"
.end
CODE
Class
1
Foo
1
1
OUT

pir_output_is( <<'CODE', <<'OUT', 'manually create anonymous class object');
.sub main :main
    $P1 = new "Class"
    $S1 = typeof $P1
    say $S1

    $I3 = isa $P1, "Class"
    print $I3
    print "\n"

    $P2 = new $P1

    $S1 = typeof $P2
    print "'"
    print $S1
    print "'\n"

    $I3 = isa $P2, "Foo"
    print $I3
    print "\n"

    $I3 = isa $P2, "Object"
    print $I3
    print "\n"
.end
CODE
Class
1
''
0
1
OUT

pir_output_is( <<'CODE', <<'OUT', 'manually create named class object');
.sub main :main
    $P1 = new "Class"
    $P1.name("Foo")
    $S1 = typeof $P1
    say $S1

    $I3 = isa $P1, "Class"
    print $I3
    print "\n"

    $P2 = new $P1

    $S1 = typeof $P2
    say $S1

    $I3 = isa $P2, "Foo"
    print $I3
    print "\n"

    $I3 = isa $P2, "Object"
    print $I3
    print "\n"
.end
CODE
Class
1
Foo
1
1
OUT

pir_output_is( <<'CODE', <<'OUT', 'instantiate from class object method');
.sub main :main
    $P0 = newclass "Pre"
    $P1 = subclass "Pre", "Foo"
    $P2 = $P1.'new'()

    $S1 = typeof $P2
    say $S1

    $I3 = isa $P2, "Foo"
    print $I3
    print "\n"

    $I3 = isa $P2, "Object"
    print $I3
    print "\n"
.end
CODE
Foo
1
1
OUT

pir_output_is( <<'CODE', <<'OUT', 'instantiate from string name');
.sub main :main
    $P0 = newclass "Pre"
    $P1 = subclass "Pre", "Foo"
    $P2 = new 'Foo'

    $S1 = typeof $P2
    say $S1

    $I3 = isa $P2, "Foo"
    print $I3
    print "\n"

    $I3 = isa $P2, "Object"
    print $I3
    print "\n"
.end
CODE
Foo
1
1
OUT

pir_output_is( <<'CODE', <<'OUT', 'instantiate from string register name');
.sub main :main
    $P0 = newclass "Pre"
    $P1 = subclass "Pre", "Foo"
    $S1 = 'Foo'
    $P2 = new $S1

    $S1 = typeof $P2
    say $S1

    $I3 = isa $P2, "Foo"
    print $I3
    print "\n"

    $I3 = isa $P2, "Object"
    print $I3
    print "\n"
.end
CODE
Foo
1
1
OUT

pir_output_is( <<'CODE', <<'OUT', 'instantiate from string PMC name');
.sub main :main
    $P0 = newclass "Pre"
    $P1 = subclass "Pre", "Foo"
    $P3 = new 'String'
    $P3 = 'Foo'
    $P2 = new $P3

    $S1 = typeof $P2
    say $S1

    $I3 = isa $P2, "Foo"
    print $I3
    print "\n"

    $I3 = isa $P2, "Object"
    print $I3
    print "\n"
.end
CODE
Foo
1
1
OUT

pir_output_is( <<'CODE', <<'OUT', 'instantiate from key name');
.sub main :main
    $P0 = newclass "Pre"
    $P1 = subclass "Pre", ['Foo';'Bar']
    $S1 = typeof $P1
    say $S1

    $I3 = isa $P1, "Class"
    print $I3
    print "\n"

    $P2 = new ['Foo';'Bar']

    $S1 = typeof $P2
    say $S1

    $I3 = isa $P2, 'Bar'
    print $I3
    print "\n"

    $I3 = isa $P2, "Object"
    print $I3
    print "\n"
.end
CODE
Class
1
Foo;Bar
1
1
OUT

pir_output_is( <<'CODE', <<'OUT', 'instantiate from key PMC name', todo=>'create non-constant key');
.sub main :main
    $P0 = newclass "Pre"
    $P1 = subclass "Pre", ['Foo';'Bar']
    $S1 = typeof $P1
    say $S1

    $I3 = isa $P1, "Class"
    print $I3
    print "\n"

    # How do you set the value of a non-constant key PMC?
    $P3 = new 'Key'

    $P2 = new $P3

    $S1 = typeof $P2
    say $S1

    $I3 = isa $P2, 'Bar'
    print $I3
    print "\n"

    $I3 = isa $P2, "Object"
    print $I3
    print "\n"
.end
CODE
Class
1
Foo;Bar
1
1
OUT

pir_output_is( <<'CODE', <<'OUT', 'instantiate from class object with init');
.sub main :main
    $P0 = newclass "Pre"
    $P1 = subclass "Pre", "Foo"
    addattribute $P1, 'data'
    $P3 = new 'Hash'
    $P4 = new 'String'
    $P4 = "data for Foo\n"
    $P3['data'] = $P4

    $P2 = new $P1, $P3

    $S1 = typeof $P2
    say $S1

    $I3 = isa $P2, "Foo"
    print $I3
    print "\n"

    $I3 = isa $P2, "Object"
    print $I3
    print "\n"

    $P5 = getattribute $P2, 'data'
    print $P5
.end
CODE
Foo
1
1
data for Foo
OUT

pir_output_is( <<'CODE', <<'OUT', 'instantiate from string name with init');
.sub main :main
    $P0 = newclass "Pre"
    $P1 = subclass "Pre", "Foo"
    addattribute $P1, 'data'
    $P3 = new 'Hash'
    $P4 = new 'String'
    $P4 = "data for Foo\n"
    $P3['data'] = $P4

    $P2 = new 'Foo', $P3

    $S1 = typeof $P2
    say $S1

    $I3 = isa $P2, "Foo"
    print $I3
    print "\n"

    $I3 = isa $P2, "Object"
    print $I3
    print "\n"

    $P5 = getattribute $P2, 'data'
    print $P5
.end
CODE
Foo
1
1
data for Foo
OUT

pir_output_is( <<'CODE', <<'OUT', 'instantiate from string register name with init');
.sub main :main
    $P0 = newclass "Pre"
    $P1 = subclass "Pre", "Foo"
    addattribute $P1, 'data'
    $P3 = new 'Hash'
    $P4 = new 'String'
    $P4 = "data for Foo\n"
    $P3['data'] = $P4

    $S1 = 'Foo'
    $P2 = new $S1, $P3

    $S1 = typeof $P2
    say $S1

    $I3 = isa $P2, "Foo"
    print $I3
    print "\n"

    $I3 = isa $P2, "Object"
    print $I3
    print "\n"

    $P5 = getattribute $P2, 'data'
    print $P5
.end
CODE
Foo
1
1
data for Foo
OUT

pir_output_is( <<'CODE', <<'OUT', 'instantiate from string PMC name with init');
.sub main :main
    $P0 = newclass "Pre"
    $P1 = subclass "Pre", "Foo"
    addattribute $P1, 'data'
    $P3 = new 'Hash'
    $P4 = new 'String'
    $P4 = "data for Foo\n"
    $P3['data'] = $P4

    $P6 = new 'String'
    $P6 = 'Foo'
    $P2 = new $P6, $P3

    $S1 = typeof $P2
    say $S1

    $I3 = isa $P2, "Foo"
    print $I3
    print "\n"

    $I3 = isa $P2, "Object"
    print $I3
    print "\n"

    $P5 = getattribute $P2, 'data'
    print $P5
.end
CODE
Foo
1
1
data for Foo
OUT

pir_output_is( <<'CODE', <<'OUT', 'instantiate from key name with init', todo=>'init keyed');
.sub main :main
    $P0 = newclass "Pre"
    $P1 = subclass "Pre", ['Foo';'Bar']
    addattribute $P1, 'data'

    $P3 = new 'Hash'
    $P4 = new 'String'
    $P4 = "data for Foo;Bar\n"
    $P3['data'] = $P4

    $P2 = new ['Foo';'Bar'], $P3

    $S1 = typeof $P2
    say $S1

    $I3 = isa $P2, 'Bar'
    print $I3
    print "\n"

    $I3 = isa $P2, "Object"
    print $I3
    print "\n"

    $P5 = getattribute $P2, 'data'
    print $P5
.end
CODE
Foo;Bar
1
1
data for Foo;Bar
OUT

pir_output_is( <<'CODE', <<'OUT', 'declare subclasses within other namespaces');
.namespace [ 'other' ]
.sub main :main
    $P0 = newclass 'Pre'
    $P99 = subclass 'Pre', 'Foo'
    $P99 = subclass 'Pre', 'Bar'

    $P1 = new 'Foo'
    $P1.'blue'()
.end

.namespace [ 'Foo' ]
.sub 'blue' :method
    say 'foo blue'
    $P1 = new 'Bar'
    $P1.'blue'()
.end


.namespace [ 'Bar' ]
.sub 'blue' :method
    say 'bar blue'
.end
CODE
foo blue
bar blue
OUT

pir_output_is( <<'CODE', <<'OUT', 'call inherited methods');
.namespace [ 'other' ]
.sub main :main
    $P0 = newclass 'Parent'
    $P0 = subclass 'Parent', 'Foo'

    $P1 = new 'Foo'
    $P1.'green'()
.end

.namespace [ 'Parent' ]
.sub 'green' :method
    say 'parent green'
.end
CODE
parent green
OUT

pir_output_is( <<'CODE', <<'OUT', 'call inherited init vtable overrides');
.sub main :main
    $P99 = newclass 'Foo'
    $P99 = subclass 'Foo', 'Bar'
    addattribute $P99, 'storage'
    $P1 = new 'Bar'
    $P1.'say_strings'()
.end

.namespace [ 'Bar' ]
.sub 'init' :method :vtable
    say 'Bar init'
    self.'add_string'('first string')
    self.'add_string'('second string')
    self.'add_string'('third string')
.end

.namespace [ 'Foo' ]
.sub 'init' :method :vtable
    say 'Foo init'
    $P1 = new .ResizablePMCArray
    setattribute self, 'storage', $P1
.end

.sub 'add_string' :method
    .param string newstring
    $P1 = getattribute self, 'storage'
    push $P1, newstring
.end

.sub 'say_strings' :method
    $P1 = getattribute self, 'storage'
    $S3 = join "\n", $P1
    say $S3
.end
CODE
Foo init
Bar init
first string
second string
third string
OUT


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
