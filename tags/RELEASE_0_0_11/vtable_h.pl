#!/usr/bin/perl

# $Id$
use lib 'lib';
use Parrot::Vtable;

my $vtable = parse_vtable();

open OUT, ">include/parrot/vtable.h" or die $!;

print OUT <<'EOF';
/*
** !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
**
** This file is generated automatically from 'vtable.tbl' by vtable_h.pl
*/

#if !defined(PARROT_VTABLE_H_GUARD)
#define PARROT_VTABLE_H_GUARD

#include "parrot/parrot.h"

#define VTABLE_SIZE 512

#define YOU_LOSE_VTABLE NULL

EOF

print OUT vtbl_defs($vtable);

print OUT "\n";

print OUT vtbl_struct($vtable);

print OUT vtbl_macros($vtable);

print OUT "\n#endif\n";

