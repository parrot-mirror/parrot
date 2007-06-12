
=head1 Parrot::Pmc2c::Null Instance Methods

=over 4

=cut

package Parrot::Pmc2c::PMC::Null;
use base 'Parrot::Pmc2c::PMC';
use strict;
use warnings;
use Parrot::Pmc2c::UtilFunctions qw( gen_ret );

=item C<body($method, $line, $out_name)>

Returns the C code for the method body. C<$line> is used to accumulate
the number of lines, C<$out_name> is the name of the output file we are
generating.

The C<Null> PMC throws an execption for all methods.

=back

=cut

sub pre_method_gen {
    my ( $self ) = @_;
    
    # vtable methods
    foreach my $method ( @{ $self->vtable->methods } ) {
        my $vt_method_name = $method->name;
        next unless $self->normal_unimplemented_vtable($vt_method_name);
        my $new_default_method = $method->clone({ 
                parent_name => $self->name, 
                type        => Parrot::Pmc2c::Method::VTABLE,
          });

        my $ret = "";
        $ret = gen_ret($method);
        my $output = <<EOC;
    real_exception(interp, NULL, NULL_REG_ACCESS, "Null PMC access in $vt_method_name()");
EOC
        $output .= $ret if $ret;
        $new_default_method->body(Parrot::Pmc2c::Emitter->text($output));
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
