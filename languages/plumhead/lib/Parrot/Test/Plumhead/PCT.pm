# $Id$

# Copyright (C) 2006-2007, The Perl Foundation.

package Parrot::Test::Plumhead::PCT;

# pragmata
use strict;
use warnings;

use base 'Parrot::Test::Plumhead';

# Generate output_is(), output_isnt() and output_like() in current package.
Parrot::Test::generate_languages_functions();

sub get_out_fn {
    my $self = shift;
    my ( $count, $options ) = @_;

    return Parrot::Test::per_test( '_pct.out', $count );
}

# Use PHP on the command line
sub get_test_prog {
    my $self = shift;
    my ( $count, $options ) = @_;

    my $lang_fn = Parrot::Test::per_test( '.php', $count );

    return "./parrot languages/plumhead/plumhead.pbc --variant=pct languages/${lang_fn}";
    #return "./parrot languages/plumhead/plumhead.pbc --variant=pct-with-nqp-actions languages/${lang_fn}";
}

# never skip the reference implementation
sub skip_why {
    my $self = shift;
    my ($options) = @_;

    return;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
