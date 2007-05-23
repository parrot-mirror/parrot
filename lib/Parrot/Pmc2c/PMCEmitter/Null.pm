
=head1 Parrot::Pmc2c::Null Instance Methods

=over 4

=cut

package Parrot::Pmc2c::PMCEmitter::Null;
use base 'Parrot::Pmc2c::PMCEmitter';
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

sub gen_body {
    my ( $self, $method, ) = @_;
    my $methodname = $method->name;

    # existing methods get emitted
    if ( $self->SUPER::implements_vtable($methname) ) {
        return $self->SUPER::gen_body( $self->get_method($methodname));
    }

    my $decl = $method->decl( $self, 'CFILE' );
    my $ret = gen_ret($method);

    my $output = <<EOC;
${decl} {
    real_exception(interp, NULL, NULL_REG_ACCESS,
        "Null PMC access in $meth()");
EOC

    $output .= $ret if $ret;
    return $output .= "}\n";
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
