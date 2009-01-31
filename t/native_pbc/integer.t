#! perl
# Copyright (C) 2001-2005, The Perl Foundation.
# $Id$

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More;

use Parrot::Test tests => 3;

=head1 NAME

t/native_pbc/integer.t - Integers

=head1 SYNOPSIS

        % prove t/native_pbc/integer.t

=head1 DESCRIPTION

Tests word-size/float-type/endian-ness for different architectures.

=cut

=begin comment

See t/native_pbc/number.t for additional comments

Test files on different architectures are generated by:

  $ parrot -o i.pbc -a - <<EOF
  print 0x10203040
  end
  EOF
  $ mv i.pbc t/native_pbc/integer_${N}.pbc

The output of

  $ pdump -h i.pbc

should be included for reference.

=cut

# execute the file t/native_pbc/integer_1.pbc
#
# HEADER => [
#         wordsize  = 4   (interpreter's wordsize/INTVAL = 4/4)
#         byteorder = 0   (interpreter's byteorder       = 0)
#         floattype = 0   (interpreter's NUMVAL_SIZE     = 8)
#         parrot-version 0.9.0, bytecode-version 3.34
#         UUID type = 0, UUID size = 0
#         no endianize, no opcode, no numval transform
#         dirformat = 1
# ]
pbc_output_is( undef, '270544960', "i386 32 bit opcode_t, 32 bit intval" )
    or diag "May need to regenerate t/native_pbc/integer_1.pbc; read test file";

# HEADER => [
#         wordsize  = 4   (interpreter's wordsize/INTVAL = 4/4)
#         byteorder = 1   (interpreter's byteorder       = 1)
#         floattype = 0   (interpreter's NUMVAL_SIZE     = 8)
#         parrot-version 0.9.0, bytecode-version 3.34
#         UUID type = 0, UUID size = 0
#         no endianize, no opcode, no numval transform
#         dirformat = 1
# ]
pbc_output_is(undef, '270544960', "PPC BE 32 bit opcode_t, 32 bit intval")
    or diag "May need to regenerate t/native_pbc/integer_2.pbc; read test file";

# HEADER => [
#         wordsize  = 8   (interpreter's wordsize/INTVAL = 8/8)
#         byteorder = 0   (interpreter's byteorder       = 0)
#         floattype = 0   (interpreter's NUMVAL_SIZE     = 8)
#         parrot-version 0.9.0, bytecode-version 3.34
#         UUID type = 0, UUID size = 0
#         no endianize, no opcode, no numval transform
#         dirformat = 1
# ]
pbc_output_is( undef, '270544960', "x86_64 double float 64 bit opcode_t" )
    or diag "May need to regenerate t/native_pbc/integer_3.pbc; read test file";

# Formerly following tests had been set up:
# pbc_output_is(undef, '270544960', "little-endian 64-bit tru64");
# pbc_output_is(undef, '270544960', "big-endian 64-bit irix");

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
