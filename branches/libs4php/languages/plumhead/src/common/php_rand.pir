# Copyright (C) 2008, The Perl Foundation.
# $Id$

=head1 NAME

php_rand.pir - PHP rand Standard Library

=head1 DESCRIPTION

=head2 Functions

=over 4

=cut

=item C<int getrandmax(void)>

Returns the maximum value a random number can have

=cut

.sub 'getrandmax'
    not_implemented()
.end

=item C<int mt_getrandmax(void)>

Returns the maximum value a random number from Mersenne Twister can have

=cut

.sub 'mt_getrandmax'
    not_implemented()
.end

=item C<int mt_rand([int min, int max])>

Returns a random number from Mersenne Twister

=cut

.sub 'mt_rand'
    not_implemented()
.end

=item C<void mt_srand([int seed])>

Seeds Mersenne Twister random number generator

=cut

.sub 'mt_srand'
    not_implemented()
.end

=item C<int rand([int min, int max])>

Returns a random number

=cut

.sub 'rand'
    not_implemented()
.end

=item C<void srand([int seed])>

Seeds random number generator

=cut

.sub 'srand'
    not_implemented()
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
