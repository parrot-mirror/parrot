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
            modifiers => [],
            %{ $self_hash || {} }
        )
    };

    # this is usually wrong, but *something* calls new on an object somewhere
    bless $self, $class;
}

# getters/setters
sub name {
    my ( $self, $value ) = @_;
    $self->{name} = $value if $value;
    return $self->{name};
}

=head1 C<generate_declaration>

Generate and emit the C code for an attribute declaration.

=cut

sub generate_declaration {
    my ( $self, $pmc ) = @_;
    my $h = $pmc->{emitter};
    my $decl = '    ' . $self->{type} . ' ' . $self->{name} . ";\n";
    $h->emit($decl);

    return 1;
}

=head1 C<generate_start>

Generate and emit the C code for the start of an attribute struct.

=cut

sub generate_start {
    my ( $self, $pmc ) = @_;
    my $h = $pmc->{emitter};
    my $name = $pmc->{name};
    $h->emit(<<"EOH");

/* $name PMC's underlying struct. */
typedef struct Parrot_${name} {
EOH

    return 1;
}

=head1 C<generate_end>

Generate and emit the C code for the end of an attribute struct.

=cut

sub generate_end {
    my ( $self, $pmc ) = @_;
    my $h    = $pmc->{emitter};
    my $name = $pmc->{name};
    my $ucname = uc($name);
    $h->emit(<<"EOH");
} Parrot_${name};

/* Macro to access underlying structure of a $name PMC. */
#define PARROT_${ucname}(o) ((Parrot_${name} *) PMC_data(o))

EOH

    return 1;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

