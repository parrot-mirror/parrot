#!./parrot

# check literals

print '1..7'

0
1
12

#123l
#1234L



print 'ok 1'


01
02
03
04
05
06
07

print 'ok 2'

0x1
0x2
0x3
0x4
0x5
0x6
0x7
0x8
0x9
0xa
0xA
0xb
0xB
0xc
0xC
0xd
0xD
0xe
0xE
0xf
0xF
0xdeadbeef

print 'ok 3'

#3.14
#10.
#.001
#1e100
#
#3.14e-10
#0e0
#0E0
#

print 'ok',

print 4

#3.14j
#10.j
#10j
#.001j
#1e100j
#3.14e-10j
#1J

print 'ok 5'

# prefix:+
print 'ok', +6
x = +7
print 'ok', x
