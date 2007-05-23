
=head1 Parrot::Pmc2c::default Instance Methods

=over 4

=cut

package Parrot::Pmc2c::PMCEmitter::default;
use strict;
use warnings;
use Data::Dumper;
use Parrot::Pmc2c::UtilFunctions qw( gen_ret );
use base qw( Parrot::Pmc2c::PMCEmitter );

=item C<pre_method_gen()>

Always true.

=cut

sub pre_method_gen {
    my ( $self ) = @_;
    
    # vtable methods
    foreach my $method ( @{ $self->vtable->methods } ) {
        my $vt_method_name = $method->name;
        next if $vt_method_name eq 'class_init';
        unless ( $self->implements_vtable($vt_method_name) ) {
            my $new_default_method = $method->clone();

            my $ret = "";
            $ret = gen_ret($method);
            $new_default_method->body(<<"EOC");
    cant_do_method(interp, pmc, "$vt_method_name");$ret
EOC
            $new_default_method->type(Parrot::Pmc2c::Method::VTABLE);
            $self->add_method($new_default_method);
        }
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
