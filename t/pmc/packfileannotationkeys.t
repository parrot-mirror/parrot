#!parrot
# Copyright (C) 2006-2009, Parrot Foundation.

=head1 NAME

t/pmc/packfileannotationkeys.t - test the PackfileAnnotationKeys PMC


=head1 SYNOPSIS

    % prove t/pmc/packfileannotationkeys.t

=head1 DESCRIPTION

Tests the PackfileAnnotationKeys PMC.

=cut


# Packfile constructor
.sub 'test' :main
.include 'test_more.pir'
    .local pmc pf

    plan(5)

    pf = new ['PackfileAnnotationKeys']
    $I0 = defined pf
    ok($I0, "PackfileAnnotationKeys created")

.end
