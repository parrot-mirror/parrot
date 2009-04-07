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
	plan(14)

	'test_typeof'()
	'test_elements'()
	'test_get_pmc_keyed_int'()
	'test_get_string_keyed_int'()
	'test_get_pmc_keyed_str'()
	'test_set_pmc_keyed_str'()
.end

# PackfileDirectory.typeof
.sub 'test_typeof'
    .local pmc pf
    pf = new ['Packfile']
    $P1 = pf.'get_directory'()
    $S0 = typeof $P1
    $I0 = cmp $S0, 'PackfileDirectory'
	$I0 = not $I0
	ok($I0, 'PackfileDirectory.get_directory')
.end


# PackfileDirectory.elements
.sub 'test_elements'
    .local pmc pf, pfdir
    pf    = _pbc()
    pfdir = pf.'get_directory'()
    $I0   = elements pfdir
    $I0   = 5 == $I0
	ok($I0, 'PackfileDirectory.elements')
.end


# PackfileDirectory.get_pmc_keyed_int
.sub 'test_get_pmc_keyed_int'
    .local pmc pf, pfdir
    pf    = _pbc()
    pfdir = pf.'get_directory'()
    $I0   = elements pfdir
    $I1   = 0
  loop:
    $P0   = pfdir[$I1]
    $I2   = defined $P0
    ok($I2, 'PackfileDirectory.get_pmc_keyed_int')
    inc $I1
    eq $I0, $I1, done
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
	$I3	  = cmp $S0, $S1
	$I3   = not $I3
	ok($I3, 'PackfileDirectory.get_string_keyed_int')
    inc $I1
	eq $I0, $I1, done
    goto loop
  done:
    .return()
.end


## PackfileDirectory.get_pmc_keyed_str
.sub 'test_get_pmc_keyed_str'
    .local pmc pf, pfdir
    pf    = _pbc()
    pfdir = pf.'get_directory'()
    $I0   = elements pfdir
    $I1   = 0
  loop:
    $P0 = pfdir[$I1]
    $S1 = pfdir[$I1]
    $P1 = pfdir[$S1]
    $S0 = typeof $P0
    $S1 = typeof $P1
    eq $S0, $S1, good
    goto error
  good:
    inc $I1
    eq $I0, $I1, done
    goto loop
  done:
    ok(1, 'PackfileDirectory.get_pmc_keyed_int')
    .return()
  error:
    ok(0, 'PackfileDirectory.get_pmc_keyed_int')
.end


## PackfileDirectory.set_pmc_keyed_str
.sub 'test_set_pmc_keyed_str'
    .local pmc pf, pfdir
    pf    = _pbc()
    pfdir = pf.'get_directory'()
    $P0   = new [ 'PackfileRawSegment' ]

	# Adding segment with same name replaces old one
	$I0   = elements pfdir
	$S0   = pfdir[0]
    pfdir[$S0] = $P0
    $I1   = elements pfdir
	if $I0 == $I1 goto add_new
	ok(0, "Segment with old name was added")
	goto done

	# Add segment with new name
  add_new:
	$P0   = new [ 'PackfileRawSegment' ]
	$S0	  = 'BYTECODE_foo'
	pfdir[$S0] = $P0
	$I1   = elements pfdir
	$I3   = $I0 != $I1
	ok($I3, "New segment added")

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
