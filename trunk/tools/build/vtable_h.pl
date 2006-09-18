#! perl
# Copyright (C) 2001-2003, The Perl Foundation.
# $Id$

=head1 NAME

tools/build/vtable_h.pl - Create the vtable header

=head1 SYNOPSIS

	% perl tools/build/vtable_h.pl

=head1 DESCRIPTION

This script creates F<include/parrot/vtable.h> from F<vtable.tbl>. It
uses C<Parrot::Vtable>.

=head1 SEE ALSO

=over 4

=item C<Parrot::Vtable>

=back

=cut

use strict;
use warnings;

use lib 'lib';
use Parrot::Vtable;

my $vtable = parse_vtable();

open OUT, ">include/parrot/vtable.h" or die $!;

print OUT <<'EOF';
/* ex: set ro:
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


# Local Variables:
# mode: cperl
# cperl-indent-level: 4
# fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
