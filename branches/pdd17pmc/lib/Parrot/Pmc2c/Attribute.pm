# Copyright (C) 2008, The Perl Foundation.
# $Id$

package Parrot::Pmc2c::Attribute;

use strict;
use warnings;

sub new {
    my ( $class, $self_hash ) = @_;
    my $self = {
        (
            name      => "",
            type      => "",
            modifiers => []
            %{ $self_hash || {} }
        )
    };

    # this is usually wrong, but *something* calls new on an object somewhere
    bless $self, $class;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

