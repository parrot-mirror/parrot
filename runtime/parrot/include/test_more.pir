=head1 Purpose

contain all the boilerplate code for starting off a test written in PIR using
Test::More's subs.

Imports several subs into the current namespace from Test::More.

This is intended to be broadly usable. Feel free to use Test::More
directly, of course, but this provides a handy shortcut for setting up
simple test file written in parrot.

=cut

    load_bytecode 'runtime/parrot/library/Test/More.pbc'

    # get the testing functions
    .local pmc exports, curr_namespace, test_namespace
    curr_namespace = get_namespace
    test_namespace = get_root_namespace [ 'parrot'; 'Test'; 'More' ]
    exports = split " ", "plan diag ok nok is is_deeply like isa_ok skip isnt"

    test_namespace."export_to"(curr_namespace, exports)

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
