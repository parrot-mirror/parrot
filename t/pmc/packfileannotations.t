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
    plan(1)
    test_sanity()
.end


# Packfile constructor
.sub 'test_sanity'
    .local pmc pf
    pf = new ['PackfileAnnotations']
    $I0 = defined pf
    ok($I0, "PackfileAnnotations created")
.end
