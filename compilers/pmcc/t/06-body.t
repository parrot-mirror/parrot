#! ../../parrot
# Check generating header for parsed PMC

.include 't/common.pir'

.sub 'main' :main
    .include 'test_more.pir'
    load_bytecode 'pmcc.pbc'
    .local int total

    plan(4)

    .local string filename

    filename = 't/data/class08.pmc'
    $S0 = _slurp(filename)
    
    check_one_file(filename, $S0, "'DO NOT EDIT THIS FILE'", "Warning generated")
    check_one_file(filename, $S0, "'PMC * Parrot_Integer_instantiate(PARROT_INTERP, PMC *sig)'", "VTable method generated")
    check_one_file(filename, $S0, "'Integer.instantiate: unhandled initializer'", "VTable body generated")

    $S0 = _slurp('t/data/class14.pmc')
    check_one_file(filename, $S0, "'Small_Object_Pool *List_chunks'", "class_init body almost preserved")
.end

# Check genrated header.
# Parse passed string, generate header, check against supplied pattern
.sub 'check_one_file'
    .param string name
    .param string source
    .param string pattern
    .param string message

    .local pmc emitter, capture
    (emitter, capture) = get_emitter_and_capture(name, source, 'past')
    $S0 = emitter.'generate_c_file'(capture)
    say $S0
    like($S0, pattern, message)
.end

# Don't forget to update plan!

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
