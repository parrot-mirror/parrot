#! parrot
# Common functions for various Packfile* PMCs tests.
# Return test filename
# Currently parrot doesn't support system independent PBCs. So, cross your
# fingers and try different filename for binary-dependent tests...

.sub '_filename'
    .local string filename
    filename = 't/native_pbc/number_1.pbc'
    .return (filename)
.end

# common pbc loading function
.sub '_pbc'
    .include "stat.pasm"
    .include "interpinfo.pasm"
    .local pmc pf, pio
    pf   = new ['Packfile']
    #$S0  = interpinfo .INTERPINFO_RUNTIME_PREFIX
    #$S0 .= "/runtime/parrot/library/uuid.pbc"
    $S0 = '_filename'()
    pio  = open $S0, 'r'
    $S0  = pio.'readall'()
    close pio
    pf   = $S0
    .return(pf)
.end



# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

