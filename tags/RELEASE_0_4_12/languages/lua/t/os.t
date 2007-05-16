#! perl
# Copyright (C) 2006-2007, The Perl Foundation.
# $Id$

=head1 NAME

t/os.t - Lua Operating System Library

=head1 SYNOPSIS

    % perl -I../lib -Ilua/t lua/t/os.t

=head1 DESCRIPTION

Tests Lua Operating System Library
(implemented in F<languages/lua/lib/luaos.pir>).

See "Lua 5.1 Reference Manual", section 5.8 "Operating System Facilities",
L<http://www.lua.org/manual/5.1/manual.html#5.8>.

See "Programming in Lua", section 22 "The Operating System Library".

=cut

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin";

use Parrot::Test tests => 19;
use Test::More;

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function os.date' );
d = os.date("!*t", 0)
print(d.year, d.month, d.day, d.hour, d.min, d.sec)
print(d.wday, d.yday, d.isdst)
CODE
1970	1	1	0	0	0
5	1	false
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function os.date' );
print(os.date("!%d/%m/%y %H:%M:%S", 0))
CODE
01/01/70 00:00:00
OUTPUT

language_output_like( 'lua', << 'CODE', << 'OUTPUT', 'function os.date' );
print(os.date("%H:%M:%S"))
CODE
/^\d\d:\d\d:\d\d/
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function os.difftime' );
print(os.difftime(1234, 1200))
print(os.difftime(1234))
CODE
34
1234
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function os.execute' );
cmd = "perl -e \"print 'test'; exit(2)\""
r = os.execute(cmd)
print(r)
CODE
test2
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function os.execute' );
r = os.execute()
print(r)
CODE
1
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function os.exit' );
print("reached")
os.exit()
print("not reached")
CODE
reached
OUTPUT

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function os.getenv' );
print(os.getenv("PARROT_TMP"))
CODE
nil
OUTPUT

$ENV{PARROT_TMP} = "GETENV_PARROT";

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function os.getenv' );
print(os.getenv("PARROT_TMP"))
CODE
GETENV_PARROT
OUTPUT

open my $X, '>', '../file.rm';
print {$X} 'file to remove';
close $X;

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function os.remove' );
r = os.remove("file.rm")
print(r)
CODE
true
OUTPUT

ok( !-e '../file.rm', 'Test that the file is removed' );
unlink('../file.rm') if ( -e '../file.rm' );

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function os.remove' );
r, msg = os.remove("file.rm")
print(r)
print(msg)
CODE
nil
file.rm: No such file or directory
OUTPUT

open $X, '>', '../file.old';
print {$X} 'file to rename';
close $X;

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function os.rename' );
r = os.rename("file.old", "file.new")
print(r)
CODE
true
OUTPUT

ok( !-e '../file.old', 'Test that old file is missing' );
ok( -e '../file.new', 'Test that new file is here' );
unlink('../file.old') if ( -e '../file.old' );
unlink('../file.new') if ( -e '../file.new' );

language_output_is( 'lua', << 'CODE', << 'OUTPUT', 'function os.rename' );
r, msg = os.rename("file.old", "file.new")
print(r)
print(msg)
CODE
nil
file.old: No such file or directory
OUTPUT

language_output_like( 'lua', << 'CODE', << 'OUTPUT', 'function os.time' );
print(os.time())
CODE
/^\d+/
OUTPUT

language_output_like( 'lua', << 'CODE', << 'OUTPUT', 'function os.time' );
print(os.time(nil))
CODE
/^\d+/
OUTPUT

language_output_like( 'lua', << 'CODE', << 'OUTPUT', 'function os.time (missing field)' );
print(os.time({}))
CODE
/^[^:]+: [^:]+:\d+: field 'day' missing in date table\nstack traceback:\n/
OUTPUT

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

