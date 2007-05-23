
=head1 Parrot::Pmc2c::delegate Instance Methods

=over 4

=cut

package Parrot::Pmc2c::PMCEmitter::delegate;
use base 'Parrot::Pmc2c::PMCEmitter';
use strict;
use warnings;

=item C<implements($method)>

True for vtables.

=cut

sub implements {
    my ( $self, $meth ) = @_;
    $self->implements_vtable($meth);
}

=item C<trans($type)>

Used in C<signature()> to normalize argument types.

=cut

sub trans {
    my ( $self, $type ) = @_;

    my $char = substr $type, 0, 1;
    return $1 if ( $char =~ /([ISP])/ );
    return 'N' if ( $char eq 'F' );
    return 'v' if ( $type eq 'void' );
    return '?';
}

=item C<signature($params)>

Returns the method signature for C<$params>.

=cut

sub signature {
    my ( $self, $method ) = @_;

    my $return_type = $method->return_type;
    my $n = 0;
    my ( @types, @args );

    for my $x (split / /, $method->parameters) {
        push @{ ($n++ & 1) ? \@args : \@types }, $x;
    }

    my $args = @args ? ", " . join( ' ', @args ) : '';
    my $sig = $self->trans($return_type) . join '', map { $self->trans($_) } @types;
    my $func_ret = '';
    my $method_suffix = '';

    if ( $return_type ne 'void' ) {
        $func_ret = "return ($return_type)";
        if ( $return_type !~ /\*/ ) { # PMC* and STRING* don't need a special suffix
            $method_suffix = "_ret" . lc substr $return_type, 0, 1;
            $method_suffix =~ s/_retu/_reti/; #change UINTVAl type to reti
        }
    }
    return ( $func_ret, $method_suffix, $args, $sig );
}
 
=item C<body($self)>

Returns the C code for the method body. C<$line> is used to accumulate
the number of lines, C<$out_name> is the name of the output file we are
generating.

The C<delegate> PMC redirects all methods to bytecode.

=back

=cut
sub pre_method_gen {
    my ( $self ) = @_;
    
    # vtable methods
    foreach my $method ( @{ $self->vtable->methods } ) {
        my $vt_method_name = $method->name;
        next if $vt_method_name eq 'class_init';
        unless ( $self->implements_vtable($vt_method_name) ) {
            my $new_default_method = $method->clone();
            my ( $func_ret, $ret_suffix, $args, $sig ) = $self->signature($method);

            my $body = <<EOC;

    STRING *meth = CONST_STRING(interp, "$vt_method_name");
    PMC *sub = Parrot_find_vtable_meth(interp, pmc, meth);
    if (PMC_IS_NULL(sub))
        vtable_meth_not_found(interp, pmc, "$vt_method_name");
    ${func_ret}Parrot_run_meth_fromc_args$ret_suffix(interp, sub, pmc, meth, "$sig"$args);
EOC
            $new_default_method->body($body);
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
