# Copyright (C) 2008, The Perl Foundation.
# $Id$

=head1 NAME

php_base64.pir - PHP base64 Standard Library

=head1 DESCRIPTION

=head2 Functions

=over 4

=cut

=item C<string base64_decode(string str[, bool strict])>

Decodes string using MIME base64 algorithm

=cut

.sub 'base64_decode'
    not_implemented()
.end

=item C<string base64_encode(string str)>

Encodes string using MIME base64 algorithm

=cut

.sub 'base64_encode'
    not_implemented()
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
