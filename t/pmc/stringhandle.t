#!perl
# Copyright (C) 2006-2008, The Perl Foundation.
# $Id: stringhandle.t 33695 2008-12-09 05:16:33Z allison $

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );

use Test::More;
use Parrot::Test tests => 17;
use Parrot::Test::Util 'create_tempfile';
use Parrot::Test::Util 'create_tempfile';

=head1 NAME

t/pmc/stringhandle.t - test the StringHandle PMC

=head1 SYNOPSIS

    % prove t/pmc/stringhandle.t

=head1 DESCRIPTION

Tests the StringHandle PMC.

=cut

# L<PDD22/I\/O PMC API/=item new>
pir_output_is( <<'CODE', <<'OUT', 'new' );
.sub 'test' :main
    new $P0, 'StringHandle'
    say "ok 1 - $P0 = new 'StringHandle'"
.end
CODE
ok 1 - $P0 = new 'StringHandle'
OUT

my (undef, $temp_file) = create_tempfile( UNLINK => 1 );

# L<PDD22/I\/O PMC API/=item open.*=item close>
pir_output_is( <<"CODE", <<'OUT', 'open and close - synchronous' );
.sub 'test' :main
    \$P1 = new 'StringHandle'
    \$P1.'open'('README')
    say 'ok 1 - \$P1.open(\$S1)'

    \$P1.'close'()
    say 'ok 2 - \$P1.close()'

    \$P3 = new 'StringHandle'
    \$P3.'open'('$temp_file', 'rw')
    say 'ok 3 - \$P3.open(\$S1, \$S2) # rw mode'
    \$P3.'close'()

    \$P3.'open'()
    say 'ok 4 - \$P3.open()         # reopening'
    \$P3.'close'()

  test_7:
    \$P7 = new 'StringHandle'
    \$P7.'open'('$temp_file', 'w')
    say 'ok 7 - \$P7.open(\$S1, \$S2) # new file, write mode succeeds'

    goto end

  end:
.end
CODE
ok 1 - $P1.open($S1)
ok 2 - $P1.close()
ok 3 - $P3.open($S1, $S2) # rw mode
ok 4 - $P3.open()         # reopening
ok 7 - $P7.open($S1, $S2) # new file, write mode succeeds
OUT

# RT #46827 test open file, close file, delete file, reopen previously opened stream

SKIP: {
    skip 'no asynch calls yet' => 1;

    pir_output_is( <<'CODE', <<'OUT', 'open and close - asynchronous' );
.sub 'test' :main
    $P1 = # RT #46831 create a callback here
    $P0 = new 'StringHandle'

    $P0.'open'('README')
    say 'ok 1 - $P0.open($S1)'

    $P0.'close'()
    say 'ok 2 - $P0.close($P1)'

    $P0.'open'('README', 'rw')
    say 'ok 3 - $P0.open($S1, $S2)'

    $P0.'close'()
    $P0.'open'()
    say 'ok 4 - $P0.open()'

  cleanup:
    $P0.'close'()
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
    $P0 = new 'StringHandle'
    $P0.'open'('README')

    $S0 = $P0.'read'(14) # bytes
    if $S0 == 'This is Parrot' goto ok_1
    print 'not '
  ok_1:
    say 'ok 1 - $S0 = $P1.read($I2)'

    $S0 = $P0.'read'(9)  # bytes
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
pir_output_is( <<"CODE", <<'OUT', 'print - synchronous' );
.sub 'test' :main

    \$P0 = new 'StringHandle'
    \$P0.'open'('$temp_file', 'w')

    \$P0.'print'(123)
    say 'ok 1 - \$P0.print(\$I1)'
    \$P0.'print'(456.789)
    say 'ok 2 - \$P0.print(\$N1)'
    \$P0.'print'("squawk\\n")
    say 'ok 3 - \$P0.print(\$S1)'
    \$P1 = new 'Integer'
    \$P1 = 42
    \$P0.'print'(\$P1)
    say 'ok 4 - \$P0.print(\$P1)'

    \$P0.'close'()

    \$P1 = new 'StringHandle'
    \$P1.'open'('$temp_file', 'r')

    \$S0 = \$P1.'read'(3) # bytes
    if \$S0 == "123" goto ok_5
    print 'not '
  ok_5:
    say 'ok 5 - read integer back from file'

    \$S0 = \$P1.'read'(16) # bytes
    if \$S0 == "456.789squawk\\n42" goto ok_6
    say \$S0

    print 'not '
  ok_6:
    say 'ok 6 - read string back from file'

    \$P1.'close'()
.end
CODE
ok 1 - $P0.print($I1)
ok 2 - $P0.print($N1)
ok 3 - $P0.print($S1)
ok 4 - $P0.print($P1)
ok 5 - read integer back from file
ok 6 - read string back from file
OUT

(undef, $temp_file) = create_tempfile( UNLINK => 1 );

# L<PDD22/I\/O PMC API/=item print.*=item readline>
pir_output_is( <<"CODE", <<'OUT', 'readline - synchronous' );
.sub 'test' :main
    load_bytecode 'String/Utils.pbc'
    .local pmc chomp
               chomp = get_global ['String';'Utils'], 'chomp'

    \$P0 = new 'StringHandle'
    \$P0.'open'('$temp_file', 'w')
    \$P0.'print'("foobarbaz\\n42")
    \$P0.'close'()

    \$P1 = new 'StringHandle'
    \$P1.'open'('$temp_file')

    \$S0 = \$P1.'readline'()
    \$S0 = chomp( \$S0 )
    if \$S0 == 'foobarbaz' goto ok_1
    print 'not '
  ok_1:
    say 'ok 1 - \$S0 = \$P1.readline()'

    \$S0 = \$P1.'readline'()
    \$S0 = chomp( \$S0 )
    if \$S0 == '42' goto ok_2
    print 'not '
  ok_2:
    say 'ok 2 - \$S0 = \$P1.readline() # again on same stream'

    \$P1.'close'()
.end
CODE
ok 1 - $S0 = $P1.readline()
ok 2 - $S0 = $P1.readline() # again on same stream
OUT

my $LINES;
($LINES, $temp_file) = create_tempfile( UNLINK => 1 );

for my $counter (1 .. 10000) {
    print $LINES $counter, "\n";
}
close $LINES;

pir_output_is( <<"CODE", <<'OUT', 'readline 10,000 lines' );
.sub 'test' :main
    load_bytecode 'String/Utils.pbc'
    .local pmc chomp
               chomp = get_global ['String';'Utils'], 'chomp'
    .local string test_line
    .local pmc stringhandle
    .local int counter
    stringhandle = new 'StringHandle'
    stringhandle.'open'('$temp_file')

    counter = 0
  read_loop:
    inc counter 
    # read in the file one line at a time...
    \$I0 = stringhandle.'eof'()
    if \$I0 goto end_read_loop

    test_line = readline stringhandle
    if test_line == "" goto end_read_loop
    test_line = chomp( test_line )
    \$I1 = test_line
    if \$I1 == counter goto read_loop
      print "not "
## the following lines provide more extensive debugging
## output on a readline failure
#      print counter
#      print " = "
#      print \$I1
#      print "\\n"
#      counter = \$I1
#      goto read_loop

  end_read_loop:
    say 'ok 1 - read 10,000 lines'
    stringhandle.'close'()
.end
CODE
ok 1 - read 10,000 lines
OUT


# RT #46833 test reading/writing code points once supported

# RT #46835 test reading long chunks, eof, and across newlines

# RT #46837 pir_output_is( <<'CODE', <<'OUT', 'print, read, and readline - asynchronous', todo => 'not yet implemented' );

# L<PDD22/I\/O PMC API/=item record_separator>
pir_output_is( <<'CODE', <<'OUT', 'record_separator', todo => 'not yet implemented' );
.sub 'test' :main
    $P0 = new 'StringHandle'

    $S0 = $P0.'record_separator'()
    if $S0 == "\n" goto ok_1
    print 'not '
  ok_1:
    say 'ok 1 - $S0 = $P1.record_separator() # default'

    $S99 = 'abc'
    $P0.'record_separator'($S99)
    $S0 = $P0.'record_separator'()
    if $S0 == $S99 goto ok_2
    print 'not '
  ok_2:
    say 'ok 2 - $P0.record_separator($S1)'

    $P0.'print'(123)
    $S0 = $P0.'record_separator'()
    $P0.'print'($S0)
    $P0.'print'(456)

    $S0 = $P0.'readline'()
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
pir_output_is( <<'CODE', <<'OUT', 'buffer_type' );
.sub 'test' :main
    $P0 = new 'StringHandle'

    $P0.'buffer_type'('unbuffered')
    $S0 = $P0.'buffer_type'()
    if $S0 == 'unbuffered' goto ok_1
    print 'not '
  ok_1:
    say 'ok 1 - $S0 = $P1.buffer_type() # unbuffered'

    $P0.'buffer_type'('line-buffered')
    $S0 = $P0.'buffer_type'()
    if $S0 == 'line-buffered' goto ok_2
    print 'not '
  ok_2:
    say 'ok 2 - $S0 = $P1.buffer_type() # line-buffered'

    $P0.'buffer_type'('full-buffered')
    $S0 = $P0.'buffer_type'()
    if $S0 == 'full-buffered' goto ok_3
    print 'not '
  ok_3:
    say 'ok 3 - $S0 = $P1.buffer_type() # full-buffered'

.end
CODE
ok 1 - $S0 = $P1.buffer_type() # unbuffered
ok 2 - $S0 = $P1.buffer_type() # line-buffered
ok 3 - $S0 = $P1.buffer_type() # full-buffered
OUT

# RT #46839 test effects of buffer_type, not just set/get

# RT #46841
# L<PDD22/I\/O PMC API/=item buffer_size>
# NOTES: try setting positive, zero, negative int
# perform print and read ops
# change buffer size while it contains data
# try with all 'buffer_type' modes

(undef, $temp_file) = create_tempfile( UNLINK => 1 );

pir_output_is( <<"CODE", <<'OUT', 'buffer_size' );
.sub 'test' :main
    \$P0 = new 'StringHandle'

    \$P0.'buffer_type'('full-buffered')
    \$P0.'buffer_size'(42)
    say 'ok 1 - \$P0.buffer_size(42)     # set buffer size'

    \$I0 = \$P0.'buffer_size'()

    # The set buffer size is a minimum, the I/O subsystem may scale it upward
    # to a round block, so test that the buffer size is equal or greater than
    # the set size.
    if \$I0 >= 42 goto ok_2
    print 'not '
  ok_2:
    say 'ok 2 - \$I0 = \$P0.buffer_size() # get buffer size'

    \$P0.'open'('$temp_file', 'w')

    \$P0.'print'(1234567890)
    \$P0.'close'()

    \$P1 = new 'StringHandle'
    \$P1.'open'('$temp_file')

    \$S0 = \$P1.'readline'()

    if \$S0 == '1234567890' goto ok_3
    print 'not '
  ok_3:
    say 'ok 3 - \$S0 = \$P0.readline()    # buffer flushed'

    \$P1.'close'()

.end
CODE
ok 1 - $P0.buffer_size(42)     # set buffer size
ok 2 - $I0 = $P0.buffer_size() # get buffer size
ok 3 - $S0 = $P0.readline()    # buffer flushed
OUT

# L<PDD22/I\/O PMC API/=item encoding>
pir_output_is( <<'CODE', <<'OUT', 'encoding' );
.sub 'test' :main
    $P0 = new 'StringHandle'

    $P0.'encoding'('utf8')
    $S0 = $P0.'encoding'()
    if $S0 == 'utf8' goto ok_1
    print 'not '
  ok_1:
    say 'ok 1 - $S0 = $P1.encoding() # utf8'

.end
CODE
ok 1 - $S0 = $P1.encoding() # utf8
OUT

(undef, $temp_file) = create_tempfile( UNLINK => 1 );

pir_output_is( <<"CODE", <<'OUT', 'encoding - read/write' );
.sub 'test' :main
    \$P0 = new 'StringHandle'
    \$P0.'encoding'('utf8')

    \$P0.'open'('$temp_file', 'w')

    \$P0.'print'(1234567890)
    \$P0.'print'("\\n")
    \$S0 = iso-8859-1:"TÖTSCH" 
    \$P0.'print'(\$S0)
    \$P0.'close'()

    \$P1 = new 'StringHandle'
    \$P1.'encoding'('utf8')

    \$P1.'open'('$temp_file')

    \$S1 = \$P1.'readline'()
    if \$S1 == "1234567890\\n" goto ok_1
print \$S1
    print 'not '
  ok_1:
    say 'ok 1 - \$S1 = \$P1.readline() # read with utf8 encoding on'

    \$S2 = \$P1.'readline'()
    if \$S2 == \$S0 goto ok_2
print \$S2
    print 'not '
  ok_2:
    say 'ok 2 - \$S2 = \$P1.readline() # read iso-8859-1 string'

    \$P1.'close'()

.end
CODE
ok 1 - $S1 = $P1.readline() # read with utf8 encoding on
ok 2 - $S2 = $P1.readline() # read iso-8859-1 string
OUT


(undef, $temp_file) = create_tempfile( UNLINK => 1 );

# L<PDD22/I\/O PMC API/=item mode>
pir_output_is( <<'CODE', <<'OUT', 'mode' );
.sub 'test' :main
    $P0 = new 'StringHandle'

    $P0.'open'('README')
    $S0 = $P0.'mode'()

    if $S0 == 'r' goto ok_1
    print 'not '
  ok_1:
    say 'ok 1 - $S0 = $P0.mode() # get read mode'

    $P0.'close'()

.end
CODE
ok 1 - $S0 = $P0.mode() # get read mode
OUT

pir_output_is( <<"CODE", <<"OUTPUT", "readall - closed stringhandle" );
.sub main :main
    \$S0 = <<"EOS"
line 1
line 2
line 3
EOS
    .local pmc pio, pio2
    pio = new 'StringHandle'
    pio.'open'("$temp_file", "w")
    pio.'print'(\$S0)
    pio.'close'()
    pio2 = new 'StringHandle'
    \$S1 = pio2.'readall'('$temp_file')
    if \$S0 == \$S1 goto ok
    print "not "
ok:
    say "ok"
.end
CODE
ok
OUTPUT

pir_output_is( <<"CODE", <<"OUTPUT", "readall() - opened stringhandle" );
.sub main :main
    \$S0 = <<"EOS"
line 1
line 2
line 3
EOS
    .local pmc pio, pio2
    pio = new 'StringHandle'
    pio.'open'("$temp_file", "w")
    pio.'print'(\$S0)
    pio.'close'()

    pio2 = new 'StringHandle'
    pio2.'open'("$temp_file", "r")
    \$S1 = pio2.'readall'()
    if \$S0 == \$S1 goto ok
    print "not "
ok:
    say "ok"
.end
CODE
ok
OUTPUT

pir_output_is( <<"CODE", <<"OUTPUT", "readall() - utf8 on closed stringhandle" );
.sub 'main'
    .local pmc ifh
    ifh = new 'StringHandle'
    ifh.'encoding'('utf8')
   
    \$S0 = ifh.'readall'('$temp_file')

    \$I0 = encoding \$S0
    \$S1 = encodingname \$I0

    say \$S1
.end
CODE
utf8
OUTPUT

pir_output_is( <<"CODE", <<"OUTPUT", "readall() - utf8 on opened stringhandle" );
.sub 'main'
    .local pmc ifh
    ifh = new 'StringHandle'
    ifh.'encoding'('utf8')
    ifh.'open'('$temp_file')

    \$S0 = ifh.'readall'()

    \$I0 = encoding \$S0
    \$S1 = encodingname \$I0

    say \$S1
.end
CODE
utf8
OUTPUT

# RT #46843
# L<PDD22/I\/O PMC API/=item get_fd>
# NOTES: this is going to be platform dependent

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
