#! parrot
# Copyright (C) 2007, The Perl Foundation.
# $Id$

=head1 NAME

t/pmc/role.t - test the Role PMC

=head1 SYNOPSIS

    % prove t/pmc/role.t

=head1 DESCRIPTION

Tests the Role PMC.

=cut

# L<PDD15/Role PMC API>
# TODO fix smartlinks once this is specced

.sub main :main
    # load this library
    load_bytecode 'library/Test/More.pir'

    # get the testing functions
    .local pmc exports, curr_namespace, test_namespace
    curr_namespace = get_namespace
    test_namespace = get_namespace [ "Test::More" ]
    exports = split " ", "plan diag ok is is_deeply like isa_ok"

    test_namespace."export_to"(curr_namespace, exports)

    plan(5)

    
    $P0 = new 'Role'
    ok(1, 'Role type exists') # or we've already died.


    $I0 = isa $P0, 'Role'
    is($I0, 1, 'isa Role')


    $P0 = new 'Hash'
    $P0['name'] = 'Wob'
    $P1 = new 'Role', $P0
    ok(1, 'Created a Role initialized with a Hash')

    $P2 = $P1.inspect('name')
    $S0 = $P2
    $I0 = $S0 == 'Wob'
    ok($I0, 'Role name was set correctly')


    $P2 = $P1.inspect('namespace')
    $S0 = $P2
    $I0 = $S0 == 'Wob'
    ok($I0, 'Role namespace was set correctly')
.end

## TODO add more tests as this is documented and implemented

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
