#! perl
# Copyright (C) 2001-2007, Parrot Foundation.
# $Id$

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More;
use Parrot::Config;
use Parrot::BuildUtil;

use Parrot::Test tests => 7;

=head1 NAME

t/native_pbc/number.t - Floating-Point Numbers

=head1 SYNOPSIS

        % prove t/native_pbc/number.t

=head1 DESCRIPTION

Tests word-size/float-type/endian-ness for different architectures.

These tests usually only work on updated native pbc test files.
See F<tools/dev/mk_native_pbc> to create the platform-specific
native pbcs.

=head1 PLATFORMS

  _1   i386 32 bit opcode_t, 32 bit intval, 8 byte double
       (linux-gcc-i386, freebsd-gcc, cygwin, ...)

  _2   i386 32 bit opcode_t, 32 bit intval, 12 byte long double
       (linux-gcc-i386 or cygwin with --floatval="long double")

  _3   PPC BE 32 bit opcode_t, 32 bit intval, 8 byte double
       (darwin-ppc)

  _4   x86_64 64 bit opcode_t, 64 bit intval, 8 byte double
       (linux-gcc-x86_64 resp. amd64, solaris-cc-64int)

  _5   x86_64 64 bit opcode_t, 64 bit intval, 16 byte long double
       (linux-gcc-x86_64, solaris-cc-64int --floatval="long double")

  _6   big-endian 64 bit opcode_t, 64 bit intval, 8 byte double
       (Sparc64/Solaris, MIPS irix or similar)

  _7   big-endian 64 bit opcode_t, 64 bit intval, 16 byte long double
       (Sparc64/Solaris --floatval="long double")

=cut

# tt #357: need better testmatrix for coverage overview
# float conversion src: left-side (pbc) to dest: upper-side (platform)
# 1: tested ok, 0: fails (skip), ?: not yet tested (todo)
my $testmatrix = <<EOF;
       8_le 12_le 16_le 8_be 16_be
8_le     1     1    ?     ?     ?
12_le    1     1    ?     ?     ?
16_le    1     1    1     ?     ?
8_be     1     1    ?     1     ?
16_be    1     1    1     ?     1
EOF

=begin comment

# these are PBC files generated from t/op/number_1.pasm with
# different architectures
# if your wordsize/floattype/endianess is not covered here
# please add it:

  $ ./parrot -o n.pbc t/op/number_1.pasm
  $ make pbc_dump
  $ ./pbc_dump -h n.pbc
  $ mv n.pbc t/native_pbc/number_$(N).pbc

# then
# - increase number of tests
# - include the pbc_dump header info for reference
# - put the file into MANIFEST
# - add the file as binary (svn add) and commit it
# thanks -leo and reini

On test failures please add the output of

  $ ./pbc_dump -h t/native_pbc/number_${N}.pbc

into your report. We need your wordsize/floattype/endianess.

=cut

#	8_le 12_le 16_le 8_be 16_be
#8_le     1     1    ?     ?     ?
#12_le    1     1    ?     ?     ?
#16_le    1     1    1     ?     ?
#8_be     1     1    ?     1     ?
#16_be    1     1    1     ?     1
my $destarch = { '8_le'  => [1,4], '12_le' => [2], '16_le' => [5],
                 '8_be'  => [3,6], '16_be' => [7] };
# the reverse: which tests for which arch
my @archtest = qw(8_le 12_le 8_be 8_le 16_le 8_be 16_be);
# @todo lists of tests for your architecture.
# e.g. for arch 8_le => tests (8_be) => todo (3 6)
sub generate_skip_list {
    my $arch = shift;
    my $check = shift;
    my %skip;
    my @lines = split /\n/, $testmatrix;
    my @dest  = split /\s+/, shift @lines;
    shift @dest unless $dest[0];
    my $i = 0;
    my %cols  = map { $_ => $i++ } @dest;
    my $col   = $cols{$arch};      # the column for our arch
    for my $s (@lines) {
        my @s  = split /\s+/, $s;
        my $pbc = shift @s;
        if ($s[$col] eq $check) {
            for (@{$destarch->{$pbc}}) { $skip{$_}++ }
        }
    }
    \%skip
}
# 16_le
sub this_arch {
    return $PConfig{numvalsize}
      . "_"
      . (substr($PConfig{byteorder},0,2) eq '12' ? "le" : "be");
}

sub bc_version($) {
    my $f = shift;
    my $b;
    open my $F, "<", "$f" or return "Can't open $f: $!";
    binmode $F;
    seek $F, 14, 0;
    read $F, $b, 8;
    my ($bc_major, $bc_minor) = unpack "cc", $b;
    return ($bc_major . "." . $bc_minor);
}
my ( $bc_major, $bc_minor ) = Parrot::BuildUtil::get_bc_version();
my $bc = ($bc_major . "." . $bc_minor);
my $arch = this_arch();
my $todo = generate_skip_list($arch, '?');
my $skip = generate_skip_list($arch, '0');

my $output = << 'END_OUTPUT';
1
4
16
64
256
1024
4096
16384
65536
262144
1048576
4194304
16777216
67108864
268435456
1073741824
4294967296
17179869184
68719476736
274877906944
1099511627776
4398046511104
17592186044416
70368744177664
281474976710656
1.12589990684262e+15
END_OUTPUT

# test_pbc_number(1, "i386 8-byte double float, 32 bit opcode_t");
sub test_pbc_number {
    my $id   = shift;
    my $desc = shift;
    my $cvt = "$archtest[$id-1]=>$arch";
    my $skip_msg;
    # check if this a platform where we can produce the needed file
    if ($archtest[$id-1] eq $arch) {
        $skip_msg = "Want to help? Regenerate t/native_pbc/number_$id.pbc "
          . "with tools/dev/mk_native_pbc --noconf";
    }
    else {
        $skip_msg  = "t/native_pbc/number_$id.pbc is outdated. "
          . "Need $archtest[$id-1] platform.";
    }
    # check if skip or todo
  SKIP: {
    if ( $skip->{$id} ) {
        skip "$cvt not yet implemented", 1
    }
    elsif ( $todo->{$id} ) {
        skip $skip_msg, 1
          if ($bc ne bc_version("t/native_pbc/number_$id.pbc"));
        pbc_output_is( undef, $output, "$cvt $desc",
                       todo => "$cvt yet untested, TT #357. "
                       . "Please report success." );
    }
    else {
        skip $skip_msg, 1
          if ($bc ne bc_version("t/native_pbc/number_$id.pbc"));
        pbc_output_is( undef, $output, "$cvt $desc" );
    }
  }
}

# execute t/native_pbc/number_*.pbc
#
# any ordinary intel 386 linux, cygwin, mingw, MSWin32, ...
# HEADER => [
#         wordsize  = 4   (interpreter's wordsize/INTVAL = 4/4)
#         byteorder = 0   (interpreter's byteorder       = 0)
#         floattype = 0   (interpreter's NUMVAL_SIZE     = 8)
#         parrot-version 0.9.1, bytecode-version 3.36
#         UUID type = 0, UUID size = 0
#         no endianize, no opcode, no numval transform
#         dirformat = 1
# ]
test_pbc_number(1, "i386 8-byte double float, 32 bit opcode_t");

# HEADER => [
#         wordsize  = 4   (interpreter's wordsize/INTVAL = 4/4)
#         byteorder = 0   (interpreter's byteorder       = 0)
#         floattype = 1   (interpreter's NUMVAL_SIZE     = 12)
#         parrot-version 0.9.1, bytecode-version 3.36
#         UUID type = 0, UUID size = 0
#         no endianize, no opcode, no numval transform
#         dirformat = 1
# ]
test_pbc_number(2, "i386 12-byte long double float, 32 bit opcode_t");

# darwin/ppc:
# HEADER => [
#         wordsize  = 4   (interpreter's wordsize/INTVAL = 4/4)
#         byteorder = 1   (interpreter's byteorder       = 1)
#         floattype = 0   (interpreter's NUMVAL_SIZE     = 8)
#         parrot-version 0.9.0, bytecode-version 3.34
#         UUID type = 0, UUID size = 0
#         no endianize, no opcode, no numval transform
#         dirformat = 1
# ]
test_pbc_number(3, "PPC double float 32 bit BE opcode_t");

# any ordinary 64-bit intel unix:
# HEADER => [
#         wordsize  = 8   (interpreter's wordsize/INTVAL = 8/8)
#         byteorder = 0   (interpreter's byteorder       = 0)
#         floattype = 0   (interpreter's NUMVAL_SIZE     = 8)
#         parrot-version 0.9.1, bytecode-version 3.36
#         UUID type = 0, UUID size = 0
#         no endianize, no opcode, no numval transform
#         dirformat = 1
# ]
test_pbc_number(4, "i86_64 LE 64 bit opcode_t, 8-byte double");

# i86_64 with floatval='long double'
# HEADER => [
#         wordsize  = 8   (interpreter's wordsize/INTVAL = 8/8)
#         byteorder = 0   (interpreter's byteorder       = 0)
#         floattype = 2   (interpreter's NUMVAL_SIZE     = 16)
#         parrot-version 0.9.0, bytecode-version 3.34
#         UUID type = 0, UUID size = 0
#         no endianize, no opcode, no numval transform
#         dirformat = 1
# ]
test_pbc_number(5, "i86_64 LE 64 bit opcode_t, long double");

# PowerPC64 -m64
# HEADER => [
#         wordsize  = 8   (interpreter's wordsize/INTVAL = 8/8)
#         byteorder = 1   (interpreter's byteorder       = 0)
#         floattype = 0   (interpreter's NUMVAL_SIZE     = 8)
#         parrot-version 0.9.1, bytecode-version 3.35
#         UUID type = 0, UUID size = 0
#         *need* endianize, no opcode, no numval transform
#         dirformat = 1
# ]
test_pbc_number(6, "big-endian 64-bit, 8-byte double");

# PowerPC64 --floatval="long double"
test_pbc_number(7, "big-endian 64-bit, 16-byte long double");

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
