#! perl -w
# Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
# $Id$

=head1 NAME

build_tools/parrot_config_c.pl - Create parrot_config.c

=head1 SYNOPSIS

    % perl build_tools/parrot_config_c.pl > src/parrot_config.c

=head1 DESCRIPTION

Create F<src/parrot_config.c> with relevant runtime information like install
prefix.

=cut


use strict;
use lib 'lib';
use Parrot::Config;

my $prefix = $PConfig{'prefix'};
$prefix = "" unless defined $prefix;

print << "EOF";
/*
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically by $0.
 *
 * Any changes made here will be lost!
 *
 */

#include <parrot/parrot.h>

static const char* runtime_prefix = \"$prefix\";

const char*
Parrot_get_runtime_prefix(Interp *interpreter, STRING **prefix_str)
{
    static STRING *s;
    static int init_done;
    static const char *prefix;

    if (!*runtime_prefix)
	return NULL;
    if (!init_done) {
	init_done = 1;
	prefix = runtime_prefix;
	s = const_string(interpreter, runtime_prefix);
	if (!Parrot_stat_info_intval(interpreter, s, STAT_EXISTS))
	    prefix = NULL;
    }
    if (prefix_str)
	*prefix_str = s;
    return prefix;
}

EOF


