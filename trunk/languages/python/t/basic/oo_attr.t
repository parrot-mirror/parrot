# $Id$

use strict;
use lib '../../lib';

use Parrot::Test tests => 6;

sub test {
    language_output_is('python', $_[0], '', $_[1]);
}

test(<<'CODE', 'object is');
if __name__ == '__main__':
    print "a" is "b"
    i=5
    print i is i
    if i is i:
	print "ok"
    if not i is 2:
	print "ok"
CODE

test(<<'CODE', 'object id');
if __name__ == '__main__':
    i=5
    j=6
    print id(i) == id(i)
    print id(i) != id(j)
CODE

test(<<'CODE', 'func attribs');
def f(x):
    print x
if __name__ == '__main__':
    print "a".__repr__()
    print dict.fromkeys("abc")
    it = iter("abcde")
    print it.next()
    print f("Ok")
CODE

test(<<'CODE', 'str.lower()');
if __name__ == '__main__':
    print "AbCYZ".lower()
CODE

test(<<'CODE', 'object attr');
class C(object):
    def f(self):
	print self.i

def main():
    c = C()
    c.i=2
    c.f()

main()
CODE

test(<<'CODE', 'override __repr__');

class C(int):
    def __repr__(self):
	return "C(%d)" % self.i

def main():
    c = C()
    c.i = 2
    print `c`

main()
CODE
