# $Id$

use strict;

use Parrot::Test tests => 3;

sub test {
    language_output_is('python', $_[0], '', $_[1]);
}

test(<<'CODE', 'func()');
def foo():
	print 0.1, 0.02
	print 1.1, 1.02

if __name__ == "__main__":
	foo()
CODE

test(<<'CODE', 'func(a, b)');
def foo(a,b):
	c = 3
	print a,b,c

if __name__ == "__main__":
	a = 1
	b = 2
	foo(a, b)
	print foo(1, 2)
CODE

test(<<'CODE', 'func(a, b=x, c=y)');
def foo(a,b="x",c=3+4):
	print a,b,c

if __name__ == "__main__":
	a = 1
	b = 2
	foo(a)
	foo(a, b)
	foo(a, b, 2)
CODE
