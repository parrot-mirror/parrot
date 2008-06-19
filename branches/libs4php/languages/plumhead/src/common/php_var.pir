# Copyright (C) 2008, The Perl Foundation.
# $Id$

=head1 NAME

php_var.pir - PHP var Standard Library

=head1 DESCRIPTION

=head2 Functions

=over 4

=cut

=item C<void debug_zval_dump(mixed var)>

Dumps a string representation of an internal zend value to output.

=cut

.sub 'debug_zval_dump'
    not_implemented()
.end

=item C<int memory_get_peak_usage([real_usage])>

Returns the peak allocated by PHP memory

=cut

.sub 'memory_get_peak_usage'
    not_implemented()
.end

=item C<int memory_get_usage([real_usage])>

Returns the allocated by PHP memory

=cut

.sub 'memory_get_usage'
    not_implemented()
.end

=item C<string serialize(mixed variable)>

Returns a string representation of variable (which can later be unserialized)

=cut

.sub 'serialize'
    not_implemented()
.end

=item C<mixed unserialize(string variable_representation)>

Takes a string representation of variable and recreates it

=cut

.sub 'unserialize'
    not_implemented()
.end

=item C<void var_dump(mixed var)>

Dumps a string representation of variable to output

=cut

#.sub 'var_dump'
#    not_implemented()
#.end

=item C<mixed var_export(mixed var [, bool return])>

Outputs or returns a string representation of a variable

=cut

.sub 'var_export'
    not_implemented()
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
