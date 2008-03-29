#! parrot
# Copyright (C) 2001-2008, The Perl Foundation.
# $Id$

=head1 NAME

t/op/info.t - Info Ops

=head1 SYNOPSIS

    % prove t/op/info.t

=head1 DESCRIPTION

Tests the information finding operations.

=cut

.sub main :main
    .include 'include/test_more.pir'

    plan(1)

    P0 = new 'ResizablePMCArray'
    I0 = typeof P0

    find_type I1, "ResizablePMCArray"
    is (I0, I1, 'find_type matches dot syntax')
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
