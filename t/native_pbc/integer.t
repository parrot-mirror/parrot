#! perl
# Copyright (C) 2001-2010, Parrot Foundation.
# $Id$

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More;
use Parrot::Config;
use Parrot::BuildUtil;

use Parrot::Test skip_all => 'pending robust testing strategy, TT #357';
#use Parrot::Test tests => 7;

=head1 NAME

t/native_pbc/integer.t - Integers

=head1 SYNOPSIS

        % prove t/native_pbc/integer.t

=head1 DESCRIPTION

Tests word-size/float-type/endian-ness for different architectures.

These tests usually only work on updated native pbc test files.
See F<tools/dev/mk_native_pbc> to create the platform-specific
native pbcs.

=head1 PLATFORMS

  _1   (4_le) i386 32 bit opcode_t, 4 byte intval, 8 byte double
       (linux-gcc-i386, freebsd-gcc, cygwin, ...)

  _2   (4_le) i386 32 bit opcode_t, 4 byte intval, 12 byte long double
       (linux-gcc-i386 or cygwin with --floatval="long double")

  _3   (4_be) PPC BE 32 bit opcode_t, 4 byte intval, 8 byte double
       (darwin-ppc or sparc32)

  _4   (8_le) x86_64 64 bit opcode_t, 8 byte intval, 8 byte double
       (linux-gcc-x86_64 resp. amd64, solaris-cc-64int)

  _5   (8_le) x86_64 64 bit opcode_t, 8 byte intval, 16 byte long double
       (linux-gcc-x86_64, solaris-cc-64int --floatval="long double")

  _6   (8_be) big-endian 64 bit opcode_t, 8 byte intval, 8 byte double
       (Sparc64/Solaris, MIPS irix or similar)

  _7   (8_be) big-endian 64 bit opcode_t, 8 byte intval, 16 byte long double
       (Sparc64/Solaris --floatval="long double")

  _8   (4_le) i386 32 bit opcode_t, 4 byte intval, 4 byte single float
       (linux-gcc-i386 or cygwin with --floatval="float")

=cut

=begin comment

See t/native_pbc/number.t for additional comments.
See tools/dev/mk_native_pbc to create the platform-specific native pbcs.

Test files on different architectures are generated by:

  $ parrot -o i.pbc -a - <<EOF
print 0x10203040
end
EOF

  $ mv i.pbc t/native_pbc/integer_${N}.pbc

The output of

  $ pbc_dump -h i.pbc

should be included for reference.

On test failures please add the output of

  $ ./pbc_dump -h t/native_pbc/number_${N}.pbc

into your report. We need your wordsize/floattype/endianess.

=cut

my @archtest = qw(4_le 4_le 4_be 8_le 8_le 8_be 8_be 4_le);
sub this_arch {
    return $PConfig{intvalsize}
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
# all should pass
my $todo = {};
my $skip = {};

# expected result
my $output = '270544960';

# test_pbc_integer(1, "(4_le) i386 32 bit opcode_t, 4 byte intval, 8 byte double");
sub test_pbc_integer {
    my $id   = shift;
    my $desc = shift;
    my $file = "t/native_pbc/integer_$id.pbc";
    my $cvt = "$archtest[$id-1]=>$arch";
    my $skip_msg;
    # check if this a platform where we can produce the needed file
    if ($archtest[$id-1] eq $arch) {
        $skip_msg = "Want to help? Regenerate $file "
          . "with tools/dev/mk_native_pbc --noconf";
    }
    else {
        $skip_msg  = "$file is outdated. "
          . "Need $archtest[$id-1] platform.";
    }
    # check if skip or todo
  SKIP: {
    if ( $skip->{$id} ) {
        my $skip_msg = $skip->{$id};
        if (length $skip_msg > 2) {
            skip "$cvt $skip_msg", 1;
        }
        else {
            skip "$cvt not yet implemented", 1;
        }
    }
    elsif ( $todo->{$id} ) {
        skip $skip_msg, 1
          if ($bc ne bc_version($file));
        my $todo_msg = $todo->{$id};
        if (length $todo_msg > 2) {
            $todo_msg = "$cvt $todo_msg"
        }
        else {
            $todo_msg = "$cvt yet untested, TT #357. "
                       . "Please report success."
        }
        pbc_output_is( undef, $output, "$cvt $desc",
                       todo => "$todo_msg" );
    }
    else {
        skip $skip_msg, 1
          if ($bc ne bc_version($file));
        pbc_output_is( undef, $output, "$cvt $desc" );
    }
  }
}

# execute the file t/native_pbc/integer_1.pbc
#
# any ordinary intel 386 linux, cygwin, mingw, MSWin32, ...
# HEADER => [
#         wordsize  = 4   (interpreter's wordsize/INTVAL = 4/4)
#         byteorder = 0   (interpreter's byteorder       = 0)
#         floattype = 0   (interpreter's NUMVAL_SIZE     = 8)
#         parrot-version 0.9.1, bytecode-version 3.38
#         UUID type = 0, UUID size = 0
#         no endianize, no opcode, no numval transform
#         dirformat = 1
# ]
test_pbc_integer(1, "(4_le) i386 32 bit opcode_t, 4 byte intval, 8 byte double");

# adding --floatval="long double" --jitcapable=0
# HEADER => [
#         wordsize  = 4   (interpreter's wordsize/INTVAL = 4/4)
#         byteorder = 0   (interpreter's byteorder       = 0)
#         floattype = 1   (interpreter's NUMVAL_SIZE     = 12)
#         parrot-version 0.9.1, bytecode-version 3.38
#         UUID type = 0, UUID size = 0
#         no endianize, no opcode, no numval transform
#         dirformat = 1
# ]
test_pbc_integer(2, "(4_le) i386 32 bit opcode_t, 4 byte intval, 12 byte long double");

# darwin/ppc:
# HEADER => [
#         wordsize  = 4   (interpreter's wordsize/INTVAL = 4/4)
#         byteorder = 1   (interpreter's byteorder       = 1)
#         floattype = 0   (interpreter's NUMVAL_SIZE     = 8)
#         parrot-version 0.9.1, bytecode-version 3.38
#         UUID type = 0, UUID size = 0
#         no endianize, no opcode, no numval transform
#         dirformat = 1
# ]
test_pbc_integer(3, "(4_be) PPC BE 32 bit opcode_t, 4 byte intval, 8 byte double");

# any ordinary 64-bit intel unix:
# HEADER => [
#         wordsize  = 8   (interpreter's wordsize/INTVAL = 8/8)
#         byteorder = 0   (interpreter's byteorder       = 0)
#         floattype = 0   (interpreter's NUMVAL_SIZE     = 8)
#         parrot-version 0.9.1, bytecode-version 3.38
#         UUID type = 0, UUID size = 0
#         no endianize, no opcode, no numval transform
#         dirformat = 1
# ]
test_pbc_integer(4, "(8_le) i86_64 64 bit opcode_t, 8 byte intval, 8 byte double");

# adding --floatval="long double"
# HEADER => [
#         wordsize  = 8   (interpreter's wordsize/INTVAL = 8/8)
#         byteorder = 0   (interpreter's byteorder       = 0)
#         floattype = 2   (interpreter's NUMVAL_SIZE     = 16)
#         parrot-version 0.9.1, bytecode-version 3.38
#         UUID type = 0, UUID size = 0
#         no endianize, no opcode, no numval transform
#         dirformat = 1
# ]
test_pbc_integer(5, "(8_le) i86_64 64 bit opcode_t, 8 byte intval, 16 byte long double");

# ppc/mips -m64
# HEADER => [
#         wordsize  = 8   (interpreter's wordsize/INTVAL = 8/8)
#         byteorder = 1   (interpreter's byteorder       = 0)
#         floattype = 0   (interpreter's NUMVAL_SIZE     = 8)
#         parrot-version 0.9.1, bytecode-version 3.38
#         UUID type = 0, UUID size = 0
#         *need* endianize, no opcode, no numval transform
#         dirformat = 1
# ]
test_pbc_integer(6, "(8_be) big-endian 64 bit opcode_t, 8 byte intval, 8 byte double");

# ppc/mips -m64 --floatval="long double"
# HEADER => [
#         wordsize  = 8   (interpreter's wordsize/INTVAL = 8/8)
#         byteorder = 1   (interpreter's byteorder       = 0)
#         floattype = 2   (interpreter's NUMVAL_SIZE     = 8)
#         parrot-version 0.9.1, bytecode-version 3.38
#         UUID type = 0, UUID size = 0
#         *need* endianize, no opcode, no numval transform
#         dirformat = 1
# ]
test_pbc_integer(7, "(8_be) big-endian 64 bit opcode_t, 8 byte intval, 16 byte long double");

# i386 --floatval=float
#test_pbc_integer(8, "(4_le) i386 32 bit opcode_t, 4 byte intval, 4 byte single float");

# ppc -m32 --floatval=float
#test_pbc_number(9, "(4_le) big-endian 32 bit opcode_t, 4 byte intval, 4 byte single float");

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
