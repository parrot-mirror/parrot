package Parrot::Pmc2c::PMCEmitter::deleg_pmc;
use base 'Parrot::Pmc2c::PMCEmitter';
use strict;
use warnings;
use Parrot::Pmc2c::UtilFunctions qw( gen_ret );

=item C<body($method,)>

Returns the C code for the method body.

Overrides the default implementation to direct all unknown methods to
the PMC in the first attribute slot.

=back

=cut

sub pre_method_gen {
    my ( $self ) = @_;

    # vtable methods
    foreach my $method ( @{ $self->vtable->methods } ) {
        my $vt_method_name = $method->name;
        next unless $self->normal_unimplemented_vtable($vt_method_name);
        my $new_default_method = $method->clone();

        my $n    = 0;
        my @args = grep { $n++ & 1 ? $_ : 0 } split / /, $method->parameters;
        my $arg  = @args ? ", " . join( ' ', @args ) : '';
        my $ret  = gen_ret( $method, "VTABLE_$vt_method_name(interp, attr$arg)" );
        $new_default_method->body(Parrot::Pmc2c::Emitter->text(<<"EOC"));
    PMC *attr = get_attrib_num(PMC_data_typed(pmc, SLOTTYPE *), 0);
    $ret
EOC

        $new_default_method->type(Parrot::Pmc2c::Method::VTABLE);
        $self->add_method($new_default_method);
    }
return 1;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
