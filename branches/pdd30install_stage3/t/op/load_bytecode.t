#!perl
# Copyright (C) 2006-2009, The Perl Foundation.
# $Id$

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More;
use Parrot::Test tests => 8;

=head1 NAME

t/op/load_bytecode.t - loading bytecode tests

=head1 SYNOPSIS

        % prove t/op/load_bytecode.t

=head1 DESCRIPTION

Tests the C<load_bytecode> operation.

=cut

pir_error_output_like( <<'CODE', <<'OUTPUT', "load_bytecode on NULL" );
.sub main :main
    load_bytecode $S0
.end
CODE
/no file name/
OUTPUT

pir_error_output_like( <<'CODE', <<'OUTPUT', "load_bytecode on directory" );
.sub main :main
    load_bytecode 't'
.end
CODE
/t' is a directory/
OUTPUT

pir_error_output_like( <<'CODE', <<'OUTPUT', "load_bytecode on non-existent file" );
.sub main :main
        load_bytecode 'no_file_by_this_name'
.end
CODE
/"load_bytecode" couldn't find file 'no_file_by_this_name'/
OUTPUT

pir_output_like( <<'CODE', <<'OUTPUT', "load_bytecode with full path" );
.sub main :main
        load_bytecode 'runtime/parrot/library/Test/More.pir'
        say 1
.end
CODE
/1/
OUTPUT

pir_output_like( <<'CODE', <<'OUTPUT', "load_bytecode with path search" );
.sub main :main
        load_bytecode 'Test/More.pir'
        say 1
.end
CODE
/1/
OUTPUT

pir_output_like( <<'CODE', <<'OUTPUT', "load_bytecode with extension fallback" );
.sub main :main
        load_bytecode 'Test/More'
        say 1
.end
CODE
/1/
OUTPUT

pir_output_like( <<'CODE', <<'OUTPUT', "load_bytecode dir+file ambiguity" );
.sub main :main
        load_bytecode 'Test/Builder'
        say 1
.end
CODE
/1/
OUTPUT

open F, ">test_1.pir.pasm"; print F ""; close F;
pir_error_output_like( <<'CODE', <<'OUTPUT', "load_bytecode skip extension search" );
.sub main :main
        load_bytecode 'test_1.pir'
.end
CODE
/"load_bytecode" couldn't find file 'test_1.pir'/
OUTPUT
unlink "test_1.pir.pasm";

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
