#! parrot
# Copyright (C) 2009, Parrot Foundation.
# $Id$

=head1 NAME

t/pmc/packfiledirectory.t - test the PackfileDirectory PMC


=head1 SYNOPSIS

    % prove t/pmc/packfiledirectory.t

=head1 DESCRIPTION

Tests the PackfileDirectory PMC.

=cut

.sub 'main' :main
.include 'test_more.pir'
    plan(13)

    'test_typeof'()
    'test_elements'()
    'test_get_iter'()
    'test_set_pmc_keyed_str'()
.end

# PackfileDirectory.typeof
.sub 'test_typeof'
    .local pmc pf
    pf = new ['Packfile']
    $P1 = pf.'get_directory'()
    isa_ok($P1, 'PackfileDirectory', 'PackfileDirectory.get_directory')
.end


# PackfileDirectory.elements
.sub 'test_elements'
    .local pmc pf, pfdir
    pf    = _pbc()
    pfdir = pf.'get_directory'()
    $I0   = elements pfdir
    is($I0, 5, 'PackfileDirectory.elements')
.end


# PackfileDirectory.get_iter
.sub 'test_get_iter'
    .local pmc pf, pfdir, it, expected
    .local string name

    # expected contains all expected segment "prefixes" with count
    expected = new 'Hash'
    expected["BYTECODE"] = 2
    expected["FIXUP"]    = 1
    expected["CONSTANT"] = 1
    expected["PIC"]      = 1

    pf    = _pbc()
    pfdir = pf.'get_directory'()
    $I0   = elements pfdir
    it    = iter pfdir
  loop:
    unless it goto done
    name = shift it

    # Get prefix
    $P0 = split '_', name
    $S0 = shift $P0
    $I0 = expected[$S0]
    ok($I0, $S0)
    # Decrease expectation count
    dec $I0
    expected[$S0] = $I0

    $P1 = pfdir[name]
    isa_ok($P1, 'PackfileSegment')
    goto loop
  done:
    .return ()
.end

## PackfileDirectory.get_string_keyed_int
.sub 'test_get_string_keyed_int'
    .local pmc pf, pfdir
    .local pmc expected
    expected = new 'ResizableStringArray'
    push expected, 'BYTECODE'
    push expected, 'FIXUP'
    push expected, 'CONSTANT'
    push expected, 'PIC'
    push expected, 'BYTECODE'

    pf    = _pbc()
    pfdir = pf.'get_directory'()
    $I0   = elements pfdir
    $I1   = 0
  loop:
    $S0   = pfdir[$I1]
    $P0   = split '_', $S0
    $S0   = shift $P0
    $S1   = shift expected
    $I3   = cmp $S0, $S1
    is($I3, 0, 'PackfileDirectory.get_string_keyed_int')
    inc $I1
    eq $I0, $I1, done
    goto loop
  done:
    .return()
.end


## PackfileDirectory.set_pmc_keyed_str
.sub 'test_set_pmc_keyed_str'
    .local pmc pf, pfdir, seg
    pf    = _pbc()
    pfdir = pf.'get_directory'()
    seg   = new [ 'PackfileRawSegment' ]

    # Adding segment with same name replaces old one
    $I0 = elements pfdir
    $P0 = iter pfdir
    $S0 = shift $P0
    pfdir[$S0] = $P0
    $I1   = elements pfdir
    is($I0, $I1, "Segment with old name was added")
    goto done

    # Add segment with new name
  add_new:
    seg = new [ 'PackfileRawSegment' ]
    $S0 = 'BYTECODE_foo'
    pfdir[$S0] = $P0
    $I1   = elements pfdir
    inc $I0
    is($I0, $I1, "New segment added")

  done:
    .return()
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
# vim: expandtab shiftwidth=4:
