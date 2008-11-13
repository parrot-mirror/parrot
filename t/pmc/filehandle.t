#!perl
# Copyright (C) 2006-2008, The Perl Foundation.
# $Id$

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More;
use Parrot::Test tests => 8;

=head1 NAME

t/pmc/filehandle.t - test the FileHandle PMC

=head1 SYNOPSIS

    % prove t/pmc/filehandle.t

=head1 DESCRIPTION

Tests the FileHandle PMC.

=cut

# L<PDD22/I\/O PMC API/=item new>
pir_output_is( <<'CODE', <<'OUT', 'new' );
.sub 'test' :main
    new P0, 'FileHandle'
    say "ok 1 - $P0 = new 'FileHandle'"
.end
CODE
ok 1 - $P0 = new 'FileHandle'
OUT

# L<PDD22/I\/O PMC API/=item open.*=item close>
pir_output_is( <<'CODE', <<'OUT', 'open and close - synchronous' );
.sub 'test' :main
    $P1 = new 'FileHandle'
    $P1.open('README')
    say 'ok 1 - $P1.open($S1)'

    $P1.close()
    say 'ok 2 - $P1.close()'

    $P3 = new 'FileHandle'
    $P3.open('README', 'rw')
    say 'ok 3 - $P3.open($S1, $S2) # rw mode'
    $P3.close()

    $P3.open()
    say 'ok 4 - $P3.open()         # reopening'
    $P3.close()

  test_5:
    $P5 = new 'FileHandle'
    push_eh eh_bad_file_1
    $P5.open('bad_file')
    pop_eh

  test_6:
    $P6 = new 'FileHandle'
    push_eh eh_bad_file_2
    $P6.open('bad_file', 'r')
    pop_eh

  test_7:
    $P7 = new 'FileHandle'
    $P7.open('new_file', 'w')
    say 'ok 7 - $P7.open($S1, $S2) # new file, write mode succeeds'

    goto end

  eh_bad_file_1:
    say 'ok 5 - $P5.open($S1)      # with bad file'
    goto test_6

  eh_bad_file_2:
    say "ok 6 - $P6.open($S1, $S2) # with bad file"
    goto test_7

  end:
.end
CODE
ok 1 - $P1.open($S1)
ok 2 - $P1.close()
ok 3 - $P3.open($S1, $S2) # rw mode
ok 4 - $P3.open()         # reopening
ok 5 - $P5.open($S1)      # with bad file
ok 6 - $P6.open($S1, $S2) # with bad file
ok 7 - $P7.open($S1, $S2) # new file, write mode succeeds
OUT

# should be in the PIR code
unlink 'new_file';

# RT #46827 test open file, close file, delete file, reopen previously opened stream

SKIP: {
    skip 'no asynch calls yet' => 1;

    pir_output_is( <<'CODE', <<'OUT', 'open and close - asynchronous' );
.sub 'test' :main
    $P1 = # RT #46831 create a callback here
    $P0 = new 'FileHandle'

    $P0.open('README')
    say 'ok 1 - $P0.open($S1)'

    $P0.close()
    say 'ok 2 - $P0.close($P1)'

    $P0.open('README', 'rw')
    say 'ok 3 - $P0.open($S1, $S2)'

    $P0.close()
    $P0.open()
    say 'ok 4 - $P0.open()'

  cleanup:
    $P0.close()
.end
CODE
ok 1 - $P0.open($S1)
ok 2 - $P0.close()
ok 3 - $P0.open($S1, $S2)
ok 4 - $P0.open()
OUT
}

# L<PDD22/I\/O PMC API/=item read>
pir_output_is(
    <<'CODE', <<'OUT', 'read - synchronous' );
.sub 'test' :main
    $P0 = new 'FileHandle'
    $P0.open('README')

    $S0 = $P0.read(14) # bytes
    if $S0 == 'This is Parrot' goto ok_1
    print 'not '
  ok_1:
    say 'ok 1 - $S0 = $P1.read($I2)'

    $S0 = $P0.read(9)  # bytes
    if $S0 == ', version' goto ok_2
    print 'not '
  ok_2:
    say 'ok 2 - $S0 = $P1.read($I2) # again on same stream'
.end
CODE
ok 1 - $S0 = $P1.read($I2)
ok 2 - $S0 = $P1.read($I2) # again on same stream
OUT

# L<PDD22/I\/O PMC API/=item print>
pir_output_is( <<'CODE', <<'OUT', 'print - synchronous' );
.sub 'test' :main

    $P0 = new 'FileHandle'
    $P0.open('temp', 'w')

    $P0.print(123)
    say 'ok 1 - $P0.print($I1)'
    $P0.print(456.789)
    say 'ok 2 - $P0.print($N1)'
    $P0.print("squawk\n")
    say 'ok 3 - $P0.print($S1)'
    $P1 = new 'Integer'
    $P1 = 42
    $P0.print($P1)
    say 'ok 4 - $P0.print($P1)'

    $P0.close()

    $P1 = new 'FileHandle'
    $P1.open('temp', 'r')

    $S0 = $P1.read(3) # bytes
    if $S0 == "123" goto ok_5
    print 'not '
  ok_5:
    say 'ok 5 - read integer back from file'

    $S0 = $P1.read(16) # bytes
    if $S0 == "456.789squawk\n42" goto ok_6
    print $S0
    print "\n"
    print 'not '
  ok_6:
    say 'ok 6 - read string back from file'

    $P1.close()
.end
CODE
ok 1 - $P0.print($I1)
ok 2 - $P0.print($N1)
ok 3 - $P0.print($S1)
ok 4 - $P0.print($P1)
ok 5 - read integer back from file
ok 6 - read string back from file
OUT

# L<PDD22/I\/O PMC API/=item print.*=item readline>
pir_output_is(
    <<'CODE', <<'OUT', 'print, read, and readline - synchronous', todo => 'not yet implemented' );
.sub 'test' :main
    load_bytecode 'String/Utils.pbc'
    .local pmc chomp
               chomp = get_global ['String';'Utils'], 'chomp'

    $P0 = new 'FileHandle'
    $P0.open('README')

    $S0 = $P0.read(14) # bytes
    if $S0 == 'This is Parrot' goto ok_1
    print 'not '
  ok_1:
    say 'ok 1 - $S0 = $P1.read($I2)'

    $S0 = $P0.read(9)  # bytes
    if $S0 == ', version' goto ok_2
    print 'not '
  ok_2:
    say 'ok 2 - $S0 = $P1.read($I2)     # again on same stream'

    $P0.print(123)
    $P0.print(456.789)
    $P0.print("squawk\n")
    $P1 = new 'Integer'
    $P1 = 42
    $P0.print($P1)
    say 'ok 3 - $P0.print(${I,N,S,P}1)'

    $S0 = $P0.readline()
    $S0 = chomp( $S0 )
    if $S0 == '123456.789000squawk' goto ok_4
    print 'not '
  ok_4:
    say 'ok 4 - $S0 = $P1.readline($I2)'

    $S0 = $P0.readline()
    $S0 = chomp( $S0 )
    if $S0 == '42' goto ok_5
    print 'not '
  ok_5:
    say 'ok 5 - $S0 = $P1.readline($I2) # again on same stream'
.end
CODE
ok 1 - $S0 = $P1.read($I2)
ok 2 - $S0 = $P1.read($I2)     # again on same stream
ok 3 - $P0.print(${I,N,S,P}1)
ok 4 - $S0 = $P1.readline($I2)
ok 5 - $S0 = $P1.readline($I2) # again on same stream
OUT

# RT #46833 test reading/writing code points once supported

# RT #46835 test reading long chunks, eof, and across newlines

# RT #46837 pir_output_is( <<'CODE', <<'OUT', 'print, read, and readline - asynchronous', todo => 'not yet implemented' );

# L<PDD22/I\/O PMC API/=item record_separator>
pir_output_is( <<'CODE', <<'OUT', 'record_separator', todo => 'not yet implemented' );
.sub 'test' :main
    $P0 = new 'FileHandle'

    $S0 = $P0.record_separator()
    if $S0 == "\n" goto ok_1
    print 'not '
  ok_1:
    say 'ok 1 - $S0 = $P1.record_separator() # default'

    $S99 = 'abc'
    $P0.record_separator($S99)
    $S0 = $P0.record_separator()
    if $S0 == $S99 goto ok_2
    print 'not '
  ok_2:
    say 'ok 2 - $P0.record_separator($S1)'

    $P0.print(123)
    $S0 = $P0.record_separator()
    $P0.print($S0)
    $P0.print(456)

    $S0 = $P0.readline()
    if $S0 == '123abc' goto ok_3
    print 'not '
  ok_3:
    say 'ok 3 - $P0.record_separator() # .readline works as expected'
.end
CODE
ok 1 - $S0 = $P1.record_separator() # default
ok 2 - $P0.record_separator($S1)
ok 3 - $P0.record_separator() # .readline works as expected
OUT

# L<PDD22/I\/O PMC API/=item buffer_type>
pir_output_is( <<'CODE', <<'OUT', 'buffer_type', todo => 'not yet implemented' );
.sub 'test' :main
    .include 'io_buffer_types.pasm'

    $P0 = new 'FileHandle'

    $P0.buffer_type('unbuffered')
    $I0 = $P0.buffer_type()
    if $I0 == PIO_NONBUF goto ok_1
    print 'not '
  ok_1:
    say 'ok 1 - $I0 = $P1.buffer_type() # PIO_NONBUF'

    $P0.buffer_type(PIO_NONBUF)
    $S0 = $P0.buffer_type()
    if $S0 == 'unbuffered' goto ok_2
    print 'not '
  ok_2:
    say 'ok 2 - $S0 = $P1.buffer_type() # PIO_NONBUF'

    $P0.buffer_type('line-buffered')
    $I0 = $P0.buffer_type()
    if $I0 == PIO_LINEBUF goto ok_3
    print 'not '
  ok_3:
    say 'ok 3 - $I0 = $P1.buffer_type() # PIO_LINEBUF'

    $P0.buffer_type(PIO_LINEBUF)
    $S0 = $P0.buffer_type()
    if $S0 == 'line-buffered' goto ok_4
    print 'not '
  ok_4:
    say 'ok 4 - $S0 = $P1.buffer_type() # PIO_LINEBUF'

    $P0.buffer_type('full-buffered')
    $I0 = $P0.buffer_type()
    if $I0 == PIO_FULLBUF goto ok_5
    print 'not '
  ok_5:
    say 'ok 5 - $I0 = $P1.buffer_type() # PIO_FULLBUF'

    $P0.buffer_type(PIO_FULLBUF)
    $S0 = $P0.buffer_type()
    if $S0 == 'full-buffered' goto ok_6
    print 'not '
  ok_6:
    say 'ok 6 - $S0 = $P1.buffer_type() # PIO_FULLBUF'
.end
CODE
ok 1 - $I0 = $P1.buffer_type() # PIO_NONBUF
ok 2 - $S0 = $P1.buffer_type() # PIO_NONBUF
ok 3 - $I0 = $P1.buffer_type() # PIO_LINEBUF
ok 4 - $S0 = $P1.buffer_type() # PIO_LINEBUF
ok 5 - $I0 = $P1.buffer_type() # PIO_FULLBUF
ok 6 - $S0 = $P1.buffer_type() # PIO_FULLBUF
OUT

# RT #46839 test effects of buffer_type, not just set/get

# RT #46841
# L<PDD22/I\/O PMC API/=item buffer_size>
# NOTES: try setting positive, zero, negative int
# perform print and read ops
# change buffer size while it contains data
# try with all 'buffer_type' modes

# RT #46843
# L<PDD22/I\/O PMC API/=item get_fd>
# NOTES: this is going to be platform dependent

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
