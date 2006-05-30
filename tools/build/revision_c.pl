# Copyright (C) 2001-2003, The Perl Foundation. 
# $Id$

=head1 NAME

tools/build/revision_c.pl

=head1 DESCRIPTION

Creates F<src/revision.c> with current rev number taken from
F<.svn/entries> or F<.svk/entries> and config rev number of last
Parrot configure run.

=head1 SEE ALSO

F<config/gen/revision.pl>,
F<lib/Parrot/Revision.pm>,
F<include/parrot/config.h>

=cut

use strict;
use Parrot::Revision;

print <<"EOF";
/*
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically by $0.
 *
 * Any changes made here will be lost!
 *
 */

#include "parrot/config.h"

/* also in "parrot/embed.h" */
PARROT_API int Parrot_revision(void);
/* also in "parrot/misc.h" */
PARROT_API int Parrot_config_revision(void);

int Parrot_revision(void)
{
    return ${Parrot::Revision::current};
}

int Parrot_config_revision(void)
{
    return ${Parrot::Revision::config};
}

EOF
