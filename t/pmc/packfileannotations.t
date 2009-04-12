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
    plan(4)
    test_sanity()
    test_handling_directory()
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

