
=head1 Parrot::Pmc2c::Standard Instance Methods

Standard behavior.

=over 4

=cut

package Parrot::Pmc2c::PMCEmitter::Standard;
use base 'Parrot::Pmc2c::PMCEmitter';
use strict;
use warnings;

=item C<body($method, $line, $out_name)>

Returns the C code for the method body. C<$line> is used to accumulate
the number of lines, C<$out_name> is the name of the output file we are
generating.

=back

=cut

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
