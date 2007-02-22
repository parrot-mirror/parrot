#! perl
# Copyright (C) 2005-2006, The Perl Foundation.
# $Id$

=head1 NAME

t/basic.t - Lua Basic Library

=head1 SYNOPSIS

    % perl -I../lib -Ilua/t lua/t/basic.t

=head1 DESCRIPTION

Tests Lua Basic Library
(implemented in F<languages/lua/lib/luabasic.pir>).

See "Lua 5.1 Reference Manual", section 5.1 "Basic Functions",
L<http://www.lua.org/manual/5.1/manual.html#5.1>.

=cut

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin";

use Parrot::Test tests => 36;
use Test::More;

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function assert' );
v, msg = assert("text", "assert string")
print(v, msg)
assert({}, "assert table")
CODE
text	assert string
OUTPUT

language_output_like( 'lua', << 'CODE', << 'OUTPUT', 'function assert(false, msg)' );
assert(false, "ASSERTION TEST")
CODE
/ASSERTION TEST/
OUTPUT

language_output_like( 'lua', << 'CODE', << 'OUTPUT', 'function assert(false)' );
assert(false)
CODE
/assertion failed!/
OUTPUT

language_output_like( 'lua', << 'CODE', << 'OUTPUT', 'function assert(false, nil)' );
assert(false, nil)
CODE
/assertion failed!/
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function ipairs' );
a = {"a","b","c"}
local f, v, s = ipairs(a)
print(type(f), type(v), s)
s, v = f(a, s)
print(s, v)
s, v = f(a, s)
print(s, v)
s, v = f(a, s)
print(s, v)
s, v = f(a, s)
print(s, v)
CODE
function	table	0
1	a
2	b
3	c
nil	nil
OUTPUT

unlink('../foo.lua') if ( -f '../foo.lua' );
my $X;
open $X, '>', '../foo.lua';
print {$X} << 'CODE';
function foo (x)
    print(x)
end
CODE
close $X;

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function loadfile');
f = loadfile('foo.lua')
print(foo)
f()
foo("ok")
CODE
nil
ok
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function loadfile (stdin)', params => "< foo.lua" );
f = loadfile()
print(foo)
f()
foo("ok")
CODE
nil
ok
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function loadfile (no file)' );
f = loadfile("no_file.lua")
print(f)
CODE
nil
OUTPUT

unlink('../foo.lua') if ( -f '../foo.lua' );
open $X, '>', '../foo.lua';
print {$X} '?syntax error?';
close $X;

language_output_like( 'lua', << 'CODE', << 'OUTPUT', 'function loadfile (syntax error)');
f = loadfile('foo.lua')
print(f)
CODE
/nil$/
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function loadstring' );
f = loadstring("i = i + 1")
i = 0
f(); print(i)
f(); print(i)
CODE
1
2
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function loadstring' );
i = 32
local i = 0
f = loadstring("i = i + 1; print(i)")
g = function () i = i + 1; print(i) end
f()
g()
CODE
33
1
OUTPUT

language_output_like( 'lua', << 'CODE', << 'OUTPUT', 'function loadstring (syntax error)' );
f = loadstring("?syntax error?")
print(f)
CODE
/nil$/
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function next (array)' );
t = {"a","b","c"}
a = next(t, nil)
print(a)
a = next(t, 1)
print(a)
a = next(t, 2)
print(a)
a = next(t, 3)
print(a)
CODE
1
2
3
nil
OUTPUT

language_output_like( 'lua', << 'CODE', << 'OUTPUT', 'function next (no arg)' );
a = next()
print(a)
CODE
/table expected, got no value/
OUTPUT

language_output_like( 'lua', << 'CODE', << 'OUTPUT', 'function next (invalid key)' );
t = {"a","b","c"}
a = next(t, 6)
print(a)
CODE
/invalid key to 'next'/
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function next (unorderer)' );
t = {"a","b","c"}
a = next(t, 2)
print(a)
a = next(t, 1)
print(a)
a = next(t, 3)
print(a)
CODE
3
2
nil
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function pairs' );
a = {"a","b","c"}
local f, v, s = pairs(a)
print(type(f), type(v), s)
s = f(v, s)
print(s)
s = f(v, s)
print(s)
s = f(v, s)
print(s)
s = f(v, s)
print(s)
CODE
function	table	nil
1
2
3
nil
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function pcall' );
r = pcall(assert, true)
print(r)
r, msg = pcall(assert, false, "catched")
print(r, msg)
r = pcall(assert)
print(r)
CODE
true
false	catched
false
OUTPUT

language_output_like( 'lua', << 'CODE', << 'OUTPUT', 'function pcall (incomplete)' );
r, msg = pcall(assert)
print(msg)
CODE
/value expected/
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function rawequal (true)' );
t = {}
a = t
print(rawequal(nil, nil))
print(rawequal(false, false))
print(rawequal(3, 3))
print(rawequal("text", "text"))
print(rawequal(t, a))
print(rawequal(print, print))
CODE
true
true
true
true
true
true
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function rawequal (false)' );
t = {}
print(rawequal(nil, 2))
print(rawequal(false, true))
print(rawequal(false, 2))
print(rawequal(3, 2))
print(rawequal(3, "2"))
print(rawequal("text", "2"))
print(rawequal("text", 2))
print(rawequal(t, {}))
print(rawequal(t, 2))
print(rawequal(print, format))
print(rawequal(print, 2))
CODE
false
false
false
false
false
false
false
false
false
false
false
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function rawget' );
t = {a = "letter a", b = "letter b"}
print(rawget(t, "a"))
CODE
letter a
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function rawset' );
t = {}
assert(rawset(t, "a", "letter a") == t)
print(t.a)
CODE
letter a
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function select' );
print(select("#"))
print(select("#","a","b","c"))
print(select(1,"a","b","c"))
print(select(3,"a","b","c"))
print(select(5,"a","b","c"))
CODE
0
3
a	b	c
c

OUTPUT

language_output_like( 'lua', << 'CODE', << 'OUTPUT', 'function select (out of range)' );
print(select(0,"a","b","c"))
CODE
/index out of range/
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function type' );
print(type("Hello world"))
print(type(10.4*3))
print(type(print))
print(type(type))
print(type(true))
print(type(nil))
print(type(io.stdin))
print(type(type(X)))
CODE
string
number
function
function
boolean
nil
userdata
string
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function type' );
print(type(a))
a = 10
print(type(a))
a = "a string!!"
print(type(a))
a = print
a(type(a))
print(type(function () end))
CODE
nil
number
string
function
function
OUTPUT

language_output_like( 'lua', << 'CODE', << 'OUTPUT', 'function type (no arg)' );
type()
CODE
/value expected/
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function type' );
a = 12.34
t = type(a)
print(a)
print(t)
CODE
12.34
number
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function tonumber' );
r = tonumber("text12")
print(type(r), r)
r = tonumber("12text")
print(type(r), r)
r = tonumber(3.14)
print(type(r), r)
r = tonumber("3.14")
print(type(r), r)
r = tonumber("  3.14  ")
print(type(r), r)
r = tonumber(111, 2)
print(type(r), r)
r = tonumber("111", 2)
print(type(r), r)
r = tonumber("  111  ", 2)
print(type(r), r)
a = {}
r = tonumber(a)
print(type(r), r)
CODE
nil	nil
nil	nil
number	3.14
number	3.14
number	3.14
number	7
number	7
number	7
nil	nil
OUTPUT

language_output_like( 'lua', << 'CODE', << 'OUTPUT', 'function tonumber (no arg)' );
tonumber()
CODE
/value expected/
OUTPUT

language_output_like( 'lua', << 'CODE', << 'OUTPUT', 'function tonumber (bad base)' );
r = tonumber("111", 200)
print(type(r), r)
CODE
/base out of range/
OUTPUT

language_output_like( 'lua', << 'CODE', << 'OUTPUT', 'function tostring (no arg)' );
tostring()
CODE
/value expected/
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function unpack' );
print(unpack{})
print(unpack{"a"})
print(unpack{"a","b","c"})
print((unpack{"a","b","c"}))
print(unpack({"a","b","c","d","e"},2,4))
print(unpack({"a","b","c"},2,4))
CODE

a
a	b	c
a
b	c	d
b	c	nil
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function xpcall' );
r = xpcall(assert, nil)
print(r)
CODE
false
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function xpcall (backtrace)' );
function backtrace ()
    return 'not a back trace'
end

r, m = xpcall(assert, backtrace)
print(r, m)
CODE
false	not a back trace
OUTPUT

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

