#!parrot
# Check generating header for parsed PMC

.include 'compilers/pmc/t/common.pir'

.sub 'main' :main
.include 'test_more.pir'
load_bytecode 'compilers/pmc/pmc.pbc'
    .local int total

    plan(0)
    .return()

    $S0 = _slurp('compilers/pmc/t/data/class00.pmc')
    .local pmc compiler
    compiler = compreg 'PMC'
    compiler.'parse'($S0, 'target'=>'past')

    $S0 = compiler.'generate_h_file'()
    like($S0, "'DO NOT EDIT THIS FILE'", "Warning generated")
.end


# Don't forget to update plan!

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
