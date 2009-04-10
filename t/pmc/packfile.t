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

.include 't/pmc/packfile_common.pir'

.sub main :main
.include 'test_more.pir'

    plan(17)
    'test_new'()
    'test_get_string'()
    'test_set_string'()
    'test_get_integer'()
    'test_set_integer'()
    'test_get_directory'()
    'test_load'()
    'test_pack_fresh_packfile'()
    'test_pack'()
    # This test will crash on many platforms. See TT#545.
    #'test_synonyms'()
.end


# Packfile constructor
.sub 'test_new'
    .local pmc pf
    pf = new ['Packfile']
    $I0 = defined pf
    ok($I0, 'new')
.end


# Packfile.get_integer_keyed_str
.sub 'test_get_string'
    .local pmc pf
    pf = new ['Packfile']
    $S0 = pf["uuid"]
    ok(1, 'get_string(uuid)')
    
    # Requesting unknown key should throw exception
    push_eh unknown_key
    $S0 = pf["foo"]
    ok(0, "get_string_keyed_int return unknown key")
    .return ()

  unknown_key:
    pop_eh
    ok(1, "get_string_keyed_int handle unknown key properly")
    .return ()
.end

# Packfile.get_integer_keyed_str
.sub 'test_set_string'
    .local pmc pf
    pf = new ['Packfile']
    pf["uuid"] = "fe9ab64082e0f6bbbd7b1e8264127908"
    ok(1, 'set_string(uuid)')
    
    # Requesting unknown key should throw exception
    push_eh unknown_key
    pf["foo"] = "fe9ab64082e0f6bbbd7b1e8264127908"
    ok(0, "set_string_keyed_int set unknown key")
    .return ()

  unknown_key:
    pop_eh
    ok(1, "set_string_keyed_int handle unknown key properly")
    .return ()
.end




# Packfile.set_string_native, Packfile.get_integer_keyed_str
.sub 'test_get_integer'
    .local pmc pf
    pf  = _pbc()
    $I0 = pf["version_major"]
    ok(1, "get_integer_keyed_str(version_major)")

    $I1 = pf["version_minor"]
    ok(1, "get_integer_keyed_str(version_minor)")

    $I2 = pf["version_patch"]
    ok(1, "get_integer_keyed_str(version_patch)")

    # Requesting unknown key should throw exception
    push_eh unknown_key
    $I3 = pf["foo"]
    ok(0, "get_integer_keyed_str return unknown key")
    .return ()

  unknown_key:
    pop_eh
    ok(1, "get_integer_keyed_str handle unknown key properly")
    .return ()

.end


# Packfile.set_integer_keyed_str
.sub 'test_set_integer'
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

# Packfile.get_directory
.sub 'test_get_directory'
    .local pmc pf
    pf = new ['Packfile']
    $P0 = pf.'get_directory'()
    isa_ok($P0, 'PackfileDirectory')
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


# Packfile.set_string_native
# Check that packfile was loaded properly and set various attributes
.sub 'test_load'
    .local pmc pf
    pf = _pbc()

    # wordsize always greater than 0
    $I0 = pf["wordsize"]
    ok($I0, "Wordsize set")

    # We are living in post-1.0 era.
    $I0 = pf["version_major"]
    ok($I0, "version_major set")

    $I0 = pf["bytecode_major"]
    ok($I0, "bytecode_major set")
.end


# Create very simple Packfile and pack it
.sub 'test_pack_fresh_packfile'
    .local pmc pf, pfdir
    pf = new 'Packfile'
    pfdir = pf.'get_directory'()
    #$P0 = new 'PackfileConstantTable'
    #$P0[0] = 42.0
    $P0 = new 'PackfileFixupTable'
    pfdir["FIXUP_t/pmc/packfile.t"] = $P0

    $P1 = new 'PackfileRawSegment'
    pfdir["BYTECODE_t/pmc/packfile.t"] = $P1

    # Pack it
    $S0 = pf

    ok(1, "PackFile packed")

    pf = new 'Packfile'
    pf = $S0
    ok(1, "PackFile unpacked after pack")

    #$P1 = open "/tmp/1.pbc", "w"
    #$P1.'puts'($S0)
    #close $P1
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

# Test pack/set_string unpack/get_string equivalency
.sub 'test_synonyms'
    .local pmc pf
    pf = '_pbc'()

    $S0 = pf
    $S1 = pf.'pack'()
    $I0 = cmp $S0, $S1
    is($I0, 0, "pack and get_string are synonyms")

    # Unpack data in two ways
    $P0 = new ['Packfile']
    $P0 = $S0
    $P1 = new ['Packfile']
    $P1.'unpack'($S0)

    $S0 = $P0
    $S1 = $P1
    $I0 = cmp $S0, $S1
    is($I0, 0, "unpack and set_string are synonyms")
.end


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
