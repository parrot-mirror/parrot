=back

=head2 Parrot::Pmc2c::SharedRef Instance Methods

=over 4

=cut

package Parrot::Pmc2c::SharedRef;
use base 'Parrot::Pmc2c::Ref';

=item C<prederef($method)>

Returns code that will lock the PMC for calling the underlying
implementation of $method.

=cut

sub prederef {
    my ( $self, $method ) = @_;
    return 'LOCK_PMC(interp, pmc);';
}

=item C<postderef($method)>

Returns the unlocking code.

=cut

sub postderef {
    my ( $self, $method ) = @_;
    return 'UNLOCK_PMC(interp, pmc);';
}

=back

=head2 Parrot::Pmc2c::default Instance Methods

=over 4

=cut

1;
