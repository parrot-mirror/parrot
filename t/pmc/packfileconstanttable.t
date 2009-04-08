#!parrot
# Copyright (C) 2009, Parrot Foundation.
# $Id$

=head1 NAME

t/pmc/packfileconstanttable.t - test the PackfileConstantTable PMC


=head1 SYNOPSIS

    % prove t/pmc/packfileconstanttable.t

=head1 DESCRIPTION

Tests the PackfileConstantTable PMC.

=cut

# Having some known data would be helpful, here.  For now, just make sure
# the values returned from get_type look right, and that the corresponding
# fetches for the found types don't crash.


.sub 'main' :main
.include 'test_more.pir'
	'plan'(10)

	'test_sanity'()
	'test_elements'()
	'test_get'()
	'test_set'()
.end



# sanity check we have a PackfileConstantTable
.sub 'test_sanity'
    .local pmc pf, pfdir, pftable
    .local string name
    pf      = _pbc()
    pfdir   = pf.'get_directory'()
    pftable = pfdir[2]
    name    = typeof pftable
    $I0 = cmp name, "PackfileConstantTable"
	$I0 = not $I0
	ok($I0, "PackfileConstantTable sanity check")
.end


# PackfileConstantTable.elements
.sub 'test_elements'
    .local pmc pf, pfdir, pftable
    .local int size
    pf      = _pbc()
    pfdir   = pf.'get_directory'()
    pftable = pfdir[2]
    size    = elements pftable
	ok(size, "PackfileConstantTable.elements returns non-zero")
.end


# PackfileConstantTable.get_type and PackfileConstantTable.get_*_keyed_int
.sub 'test_get'
    .local pmc pf, pfdir, pftable
    .local int size, this, type
    pf      = _pbc()
    pfdir   = pf.'get_directory'()
    pftable = pfdir[2]
    size    = elements pftable
    this    = 0
  loop:
    type = pftable.'get_type'(this)
    eq type, 0x00, next
    eq type, 0x6E, const_num
    eq type, 0x73, const_str
    eq type, 0x70, const_pmc
    eq type, 0x6B, const_key
    goto bad
  const_num:
    $N0 = pftable[this]
    goto next
  const_str:
    $S0 = pftable[this]
    goto next
  const_pmc:
    $P0 = pftable[this]
    goto next
  const_key:
    $P0 = pftable[this]
    $S0 = typeof $P0
    eq $S0, 'Key', next
    $S0 = concat 'constant Key with wrong type: ', $S0
	ok(0, $S0)
	.return()

  next:
    this = this + 1
    ge this, size, done
    goto loop
    gt size, 0, done

  done:
    ok(1, 'PackfileConstantTable.get_*_int works')
	.return()
  bad:
	ok(0, 'Unknown constant type')
	.return()
.end

# Test setting constants into PackfileConstantTable
.sub 'test_set'
	.local pmc ct
	.local int size
	ct = new ['PackfileConstantTable']

	# Initial PackfileConstantTable is empty
	size = elements ct
	is(size, 0, "Empty PackfileConstantTable created")

	# Set first string
	ct[0] = "string"
	$I0 = elements ct
	is($I0, 1, "String element added")
	
	ct[1] = 1.0
	$I0 = elements ct
	is($I0, 2, "Number elements added")

	$P0 = new 'Integer'
	$P0 = 42
	ct[2] = $P0
	$I0 = elements ct
	is($I0, 3, "PMC elements added")

    # Check types of created constants
    $I0 = ct.'get_type'(0)
    is($I0, 0x73, "First element is string")
    $I0 = ct.'get_type'(1)
    is($I0, 0x6E, "Second element is number")
    $I0 = ct.'get_type'(2)
    is($I0, 0x70, "Third element is PMC")

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
