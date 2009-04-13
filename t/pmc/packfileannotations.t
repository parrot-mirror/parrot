#!parrot
# Copyright (C) 2006-2009, Parrot Foundation.


=head1 NAME

t/pmc/packfileannotations.t - test the PackfileAnnotations PMC


=head1 SYNOPSIS

    % prove t/pmc/packfileannotations.t

=head1 DESCRIPTION

Tests the PackfileAnnotations PMC.

=cut

.sub 'main' :main
.include 'test_more.pir'
    plan(5)
    test_sanity()
    test_handling_directory()
    test_unpack()
.end


# Packfile constructor
.sub 'test_sanity'
    .local pmc pf
    pf = new ['PackfileAnnotations']
    $I0 = defined pf
    ok($I0, "PackfileAnnotations created")
.end

# Annotations should propogate ConstantTable to Keys.
.sub 'test_handling_directory'
    .local pmc keys, anns, pfdir

    anns = new 'PackfileAnnotations'
    keys = anns.'get_key_list'()
    $I0 = defined keys
    ok($I0, "Keys created")
    $P0 = keys.'get_constant_table'()
    $I0 = defined $P0
    is($I0, 0, "    without ConstantTable")

    pfdir = new 'PackfileDirectory'
    $P0 = new 'PackfileConstantTable'
    # Order does matter
    pfdir['CONSTANTS'] = $P0
    pfdir['ANNOTATIONS'] = anns
    $P0 = keys.'get_constant_table'()
    $I0 = defined $P0
    ok($I0, 'PackfileConstantTable found and propogated to Keys')
.end

# PackfileAnnotations unpack from PBC
.sub 'test_unpack'
    .local pmc pf, pfdir, pfanns, it

    $P0 = open 't/native_pbc/annotations.pbc'
    $S0 = $P0.'readall'()
    pf = new 'Packfile'
    pf = $S0

    # Find annotations
    pfdir = pf.'get_directory'()
    it = iter pfdir
  loop:
    unless it goto fail
    $S0 = shift it
    $P0 = pfdir[$S0]
    $I0 = isa $P0, 'PackfileAnnotations'
    unless $I0 goto loop
    ok(1, "PackfileAnnotations unpacked")

    .return()

  fail:
    ok(0, "PackfileAnnotations wasn't found in Directory")
.end
