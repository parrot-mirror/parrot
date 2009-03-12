#! perl
# Copyright (C) 2001-2007, Parrot Foundation.
# $Id$

=head1 NAME

tools/build/pbcversion_h.pl - Create pbcversion.h

=head1 SYNOPSIS

    % perl tools/build/pbcversion_h.pl > include/parrot/pbcversion.h

=head1 DESCRIPTION

The F<PBC_COMPAT> file is used to maintain Parrot bytecode compatibility. This
script extracts the latest major and minor bytecode version numbers and places
them in a header file.

=cut

use warnings;
use strict;
use lib 'lib';
use Parrot::BuildUtil;

my ( $major, $minor ) = Parrot::BuildUtil::get_bc_version();

unless ( defined $major && defined $minor ) {
    die "No bytecode version found in 'PBC_COMPAT'.";
}

print << "EOF";
/* ex: set ro:
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically from 'PBC_COMPAT'
 * by $0.
 *
 * Any changes made here will be lost!
 *
 */

#ifndef PARROT_PBCVERSION_H_GUARD
#define PARROT_PBCVERSION_H_GUARD

#define PARROT_PBC_MAJOR $major
#define PARROT_PBC_MINOR $minor

#endif /* PARROT_PBCVERSION_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 *   buffer-read-only: t
 * End:
 * vim: expandtab shiftwidth=4:
 */
EOF


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
