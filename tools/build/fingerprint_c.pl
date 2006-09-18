#! perl
# Copyright (C) 2001-2003, The Perl Foundation.
# $Id$

=head1 NAME

tools/build/fingerprint_c.pl - Create fingerprint.c

=head1 SYNOPSIS

    % perl tools/build/fingerprint_c.pl > src/fingerprint.c

=head1 DESCRIPTION

The F<PBC_COMPAT> file is used to maintain Parrot bytecode
compatability. During the build process it is parsed by
F<fingerprint_c.pl> to produce a fingerprint of the state of Parrot.

Note that this is only done for development versions of Parrot, i.e. the
file F<DEVELOPING> exists. Releases include a non-dynamic fingerprint.c.

=cut

use warnings;
use strict;
use lib 'lib';
use Digest::Perl::MD5 qw(md5_hex);

my $compat_file = 'PBC_COMPAT';
open IN, $compat_file or die "Can't read $compat_file";
my @lines = <IN>;
close IN;

my $len = 10;
my $fingerprint = md5_hex join "\n", grep { ! /^#/ } @lines;

print << "EOF";
/* ex: set ro:
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically from '$compat_file'
 * by $0.
 *
 * Any changes made here will be lost!
 *
 */

#include <string.h>
#include <parrot/packfile.h>

EOF

if (-e 'DEVELOPING') {

print "/* $fingerprint */\n";
print "static const unsigned char fingerprint[] = {\n";
for my $i (0..$len-1) {
  print '    0x', substr ($fingerprint, $i*2, 2), ",\n";
}
print "};\n";

print << "EOF";

int
PackFile_check_fingerprint (void *cursor)
{
    return memcmp (cursor, fingerprint, $len) == 0;
}

size_t
PackFile_write_fingerprint (void *cursor)
{
    memcpy (cursor, fingerprint, $len);
    return $len;
}
EOF

} else { # !DEVELOPING

  print << "EOF";
/* fingerprint checking is only enabled in development versions */

int
PackFile_check_fingerprint (void *cursor)
{
    return 1;
}

size_t
PackFile_write_fingerprint (void *cursor)
{
    memset (cursor, 0, $len);
    return $len;
}
EOF

} # endif DEVELOPING

# Local Variables:
# mode: cperl
# cperl-indent-level: 4
# fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
