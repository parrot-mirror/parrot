#! perl -w

use strict;
use lib 'lib';
use Digest::MD5 qw(md5_hex);
use Data::Dumper;
use Parrot::OpLib::core;

my $len = 10;
my $fingerprint = md5_hex join "\n", map {
  join '_', $_->{NAME}, @{$_->{ARGS}}
} @$Parrot::OpLib::core::ops;

print << "EOF";
/*
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically from 'core.ops' 
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

  print << 'EOF';
/* fingerprint checking is only in enabled in development versions */

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
