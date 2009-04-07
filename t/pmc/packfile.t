#! parrot
# Copyright (C) 2006-2008, Parrot Foundation.
# $Id$

=head1 NAME

t/pmc/packfile.t - test the Packfile PMC


=head1 SYNOPSIS

    % prove t/pmc/packfile.t

=head1 DESCRIPTION

Tests the Packfile PMC.

=cut


.sub main :main
.include 'test_more.pir'

    plan(7)
    'test_new'()
    'test_get_integer'()
    'test_get_directory'()
    'test_get_integer_keyed_str'()
    'test_set_integer_keyed_str'()
    'test_get_directory'()
    'test_pack'()
.end


# Packfile constructor
.sub 'test_new'
    .local pmc pf
    pf = new ['Packfile']
    $I0 = defined pf
    ok($I0, 'new')
.end


# Packfile.get_integer_keyed_str

.sub 'test_get_integer'
    .local pmc pf
    pf = new ['Packfile']
    $S0 = 'version_major'
    $I0 = pf[$S0]
    ok($I0, 'get_integer_keyed_str')
.end


# Packfile.get_directory
.sub 'test_get_directory'
    .local pmc pf
    pf = new ['Packfile']
    $P1 = pf.'get_directory'()
    $S0 = typeof $P1
    $I0 = cmp $S0, 'PackfileDirectory'
    $I0 = not $I0 # cmp returns 0 when arguments are equal
    ok($I0, 'get_directory')
.end


# Packfile.set_string_native, Packfile.get_integer_keyed_str
.sub 'test_get_integer_keyed_str'
    .local pmc pf
    pf   = _pbc()
    $S0  = "version_major"
    $I0  = pf[$S0]
    $S0  = "version_minor"
    $I1  = pf[$S0]
    $S0  = "version_patch"
    $I2  = pf[$S0]

    ok(1, "get_integer_keyed_str")
.end


# Packfile.set_integer_keyed_str
.sub 'test_set_integer_keyed_str'
    .local pmc pf
    pf  = _pbc()
    $S1 = 'version_major'
    $I0 = pf[$S1]
    $I1 = $I0
    inc $I1
    pf[$S1] = $I1
    $I2 = pf[$S1]
    $I3 = cmp $I0, $I2
    $I3 = cmp $I3, 0
    ok($I3, 'set_integer_keyed_str version bumped')
.end

# PackfileSegment.pack (via subclass PackfileDirectory)
.sub 'test_get_directory'
    .local pmc pf, pfdir
    pf    = _pbc()
    pfdir = pf.'get_directory'()
    $S0   = pfdir.'pack'()
    $I0   = length $S0
    $I1 = cmp $I0, 0
    ok($I1, 'get_directory')
.end

# Packfile.pack.
# Check that unpack-pack produce correct result.
.sub 'test_pack'
    .local string filename, first
    $S0 = '_filename'()
    $P0 = open $S0, 'r'

    first = $P0.'readall'()

    .local pmc packfile
    packfile = new 'Packfile'
    packfile = first

    # Packed file should be exactly the same as loaded
    .local string second
    # Pack
    second = packfile
    
    $I0 = cmp first, second
    $I0 = not $I0
    todo($I0, 'pack produced same result twice')
.end

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
