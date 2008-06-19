# Copyright (C) 2008, The Perl Foundation.
# $Id$

=head1 NAME

php_md5.pir - PHP md5 Standard Library

=head1 DESCRIPTION

=head2 Functions

=over 4

=cut

=item C<string md5(string str, [ bool raw_output])>

Calculate the md5 hash of a string

=cut

.sub 'md5'
    not_implemented()
.end

=item C<string md5_file(string filename [, bool raw_output])>

Calculate the md5 hash of given filename

=cut

.sub 'md5_file'
    not_implemented()
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
