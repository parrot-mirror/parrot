#! perl
# Copyright (C) 2009, The Perl Foundation.
# $Id$

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More;
use Parrot::Test;
use Parrot::Config;

plan tests => 3;

=head1 NAME

t/src/library.t - Library search functions

=head1 SYNOPSIS

    % prove t/src/library.t

=head1 DESCRIPTION

Test some library search functionality for load_bytecode and .include.
The library search path, directories versus missing extensions, finding files
without extensions.

  TT#123 remove more hard-coded runtime/ paths from libs
  TT#126 optimize load_bytecode, .include paths: no library/ and include/ prefix
  TT#127 do not stat extensions when an extension was already given.
         If the given string is a directory, do not fail, try the extensions instead.
         e.g. load_bytecode 'Test/Builder'
  TT#128 [TODO] Honor source filetype when a .pbc is present

We test this seperately, because core has another load_bytecode failure RT #39807,
tested in t/op/load_bytecode.t

=cut

c_output_is( <<'CODE', <<'OUTPUT', "Parrot_locate_runtime_file" );

#include <parrot/parrot.h>
#include <parrot/embed.h>

int
main(int argc, char* argv[])
{
    Interp *interp;
    int error_val;
    char *path;

    interp = Parrot_new(NULL);
    if (!interp) {
        return 1;
    }
    path = Parrot_locate_runtime_file(interp, "Data/Dumper.pir", PARROT_RUNTIME_FT_SOURCE);
    printf("%s\n", path);
    if (path) free(path);
    path = Parrot_locate_runtime_file(interp, "Data/Dumper.pbc", PARROT_RUNTIME_FT_PBC);
    printf("%s\n", path);
    if (path) free(path);
    path = Parrot_locate_runtime_file(interp, "Data/Dumper", PARROT_RUNTIME_FT_PBC);
    printf("%s\n", path);
    if (path) free(path);
    path = Parrot_locate_runtime_file(interp, "Data/Dumper.pir", PARROT_RUNTIME_FT_INCLUDE);
    printf("%s\n", path);
    if (path) free(path);
    path = Parrot_locate_runtime_file(interp, "library/Data/Dumper.pir", PARROT_RUNTIME_FT_INCLUDE);
    printf("%s\n", path);
    if (path) free(path);

    Parrot_exit(interp, 0);
    return 0;
}
CODE
./runtime/parrot/library/Data/Dumper.pir
./runtime/parrot/library/Data/Dumper.pbc
./runtime/parrot/library/Data/Dumper.pbc
(null)
./runtime/parrot/library/Data/Dumper.pir
OUTPUT

my $dynpath = "." . $PConfig{slash} .
  File::Spec->catfile("runtime","parrot","dynext","myops_ops")
  . $PConfig{load_ext};
c_output_is( <<'CODE', <<"OUTPUT", "FT_DYNEXT" );

#include <parrot/parrot.h>
#include <parrot/embed.h>

int
main(int argc, char* argv[])
{
    Interp *interp;
    char *path;
    STRING *result, *full_name, *wo_ext;
    INTVAL i, n;

    interp = Parrot_new(NULL);
    if (!interp) {
        return 1;
    }

    wo_ext = const_string(interp, "myops_ops");
    full_name = string_concat(interp, wo_ext, const_string(interp, PARROT_LOAD_EXT), 0);
    result = Parrot_locate_runtime_file_str(interp, full_name,
                                            PARROT_RUNTIME_FT_DYNEXT);
    if (result) {
        printf("%s\n", result->strstart);
    }
    else {
        if (!STREQ(PARROT_LOAD_EXT, PARROT_SHARE_EXT)) {
            full_name = string_concat(interp, wo_ext, const_string(interp, PARROT_SHARE_EXT), 0);
            result = Parrot_locate_runtime_file_str(interp, full_name,
                                                    PARROT_RUNTIME_FT_DYNEXT);
        }
        printf("%s\n", result->strstart);
    }

    path = Parrot_locate_runtime_file(interp, "not_existing_op", PARROT_RUNTIME_FT_INCLUDE);
    printf("%s\n", path);
    if (path) free(path);

    Parrot_exit(interp, 0);
    return 0;
}
CODE
$dynpath
(null)
OUTPUT

c_output_is( <<'CODE', <<'OUTPUT', "FT_SOURCE, FT_PIR", 'todo' => 'TT #128 force pir')

#include <parrot/parrot.h>
#include <parrot/embed.h>

int
main(int argc, char* argv[])
{
    Interp *interp;
    int error_val;
    char *path;

    interp = Parrot_new(NULL);
    if (!interp) {
        return 1;
    }

    path = Parrot_locate_runtime_file(interp, "Data/Dumper", PARROT_RUNTIME_FT_SOURCE);
    printf("%s\n", path);
    if (path) free(path);
    path = Parrot_locate_runtime_file(interp, "Data/Dumper", PARROT_RUNTIME_FT_PIR);
    printf("%s\n", path);
    if (path) free(path);

    Parrot_exit(interp, 0);
    return 0;
}
CODE
./runtime/parrot/library/Data/Dumper.pir
./runtime/parrot/library/Data/Dumper.pir
OUTPUT


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
