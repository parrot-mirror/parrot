#! parrot
# Copyright (C) 2006, The Perl Foundation.
# $Id$

=head1 NAME

t/pmc/addrregistry.t - test AddrRegistry PMC

=head1 SYNOPSIS

    % prove t/pmc/addrregistry.t

=head1 DESCRIPTION

Tests the AddrRegistry PMC.

=cut

.sub main :main
    # load this library
    load_bytecode 'library/Test/More.pir'

    # get the testing functions
    .local pmc exports, curr_namespace, test_namespace
    curr_namespace = get_namespace
    test_namespace = get_namespace [ "Test::More" ]
    exports = split " ", "plan diag ok is is_deeply like isa_ok"

    test_namespace."export_to"(curr_namespace, exports)

    plan(1)

    new P0, .AddrRegistry
    ok(1, 'Instantiated .AddrRegistry')
.end

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
