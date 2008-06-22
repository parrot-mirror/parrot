# Copyright (C) 2008, The Perl Foundation.
# $Id$

=head1 NAME

php_math.pir - PHP math Standard Library

=head1 DESCRIPTION

=head2 Functions

=over 4

=cut

=item C<int abs(int number)>

Return the absolute value of the number

NOT IMPLEMENTED.

=cut

.sub 'abs'
    not_implemented()
.end

=item C<float acos(float number)>

Return the arc cosine of the number in radians

NOT IMPLEMENTED.

=cut

.sub 'acos'
    not_implemented()
.end

=item C<float acosh(float number)>

Returns the inverse hyperbolic cosine of the number, i.e. the value whose hyperbolic cosine is number

NOT IMPLEMENTED.

=cut

.sub 'acosh'
    not_implemented()
.end

=item C<float asin(float number)>

Returns the arc sine of the number in radians

NOT IMPLEMENTED.

=cut

.sub 'asin'
    not_implemented()
.end

=item C<float asinh(float number)>

Returns the inverse hyperbolic sine of the number, i.e. the value whose hyperbolic sine is number

NOT IMPLEMENTED.

=cut

.sub 'asinh'
    not_implemented()
.end

=item C<float atan(float number)>

Returns the arc tangent of the number in radians

NOT IMPLEMENTED.

=cut

.sub 'atan'
    not_implemented()
.end

=item C<float atan2(float y, float x)>

Returns the arc tangent of y/x, with the resulting quadrant determined by the signs of y and x

NOT IMPLEMENTED.

=cut

.sub 'atan2'
    not_implemented()
.end

=item C<float atanh(float number)>

Returns the inverse hyperbolic tangent of the number, i.e. the value whose hyperbolic tangent is number

NOT IMPLEMENTED.

=cut

.sub 'atanh'
    not_implemented()
.end

=item C<string base_convert(string number, int frombase, int tobase)>

Converts a number in a string from any base <= 36 to any base <= 36

NOT IMPLEMENTED.

=cut

.sub 'base_convert'
    not_implemented()
.end

=item C<int bindec(string binary_number)>

Returns the decimal equivalent of the binary number

NOT IMPLEMENTED.

=cut

.sub 'bindec'
    not_implemented()
.end

=item C<float ceil(float number)>

Returns the next highest integer value of the number

NOT IMPLEMENTED.

=cut

.sub 'ceil'
    not_implemented()
.end

=item C<float cos(float number)>

Returns the cosine of the number in radians

NOT IMPLEMENTED.

=cut

.sub 'cos'
    not_implemented()
.end

=item C<float cosh(float number)>

Returns the hyperbolic cosine of the number, defined as (exp(number) + exp(-number))/2

NOT IMPLEMENTED.

=cut

.sub 'cosh'
    not_implemented()
.end

=item C<string decbin(int decimal_number)>

Returns a string containing a binary representation of the number

NOT IMPLEMENTED.

=cut

.sub 'decbin'
    not_implemented()
.end

=item C<string dechex(int decimal_number)>

Returns a string containing a hexadecimal representation of the given number

NOT IMPLEMENTED.

=cut

.sub 'dechex'
    not_implemented()
.end

=item C<string decoct(int decimal_number)>

Returns a string containing an octal representation of the given number

NOT IMPLEMENTED.

=cut

.sub 'decoct'
    not_implemented()
.end

=item C<float deg2rad(float number)>

Converts the number in degrees to the radian equivalent

NOT IMPLEMENTED.

=cut

.sub 'deg2rad'
    not_implemented()
.end

=item C<float exp(float number)>

Returns e raised to the power of the number

NOT IMPLEMENTED.

=cut

.sub 'exp'
    not_implemented()
.end

=item C<float expm1(float number)>

Returns exp(number) - 1, computed in a way that accurate even when the value of number is close to zero

NOT IMPLEMENTED.

=cut

.sub 'expm1'
    not_implemented()
.end

=item C<float floor(float number)>

Returns the next lowest integer value from the number

NOT IMPLEMENTED.

=cut

.sub 'floor'
    not_implemented()
.end

=item C<float fmod(float x, float y)>

Returns the remainder of dividing x by y as a float

NOT IMPLEMENTED.

=cut

.sub 'fmod'
    not_implemented()
.end

=item C<int hexdec(string hexadecimal_number)>

Returns the decimal equivalent of the hexadecimal number

NOT IMPLEMENTED.

=cut

.sub 'hexdec'
    not_implemented()
.end

=item C<float hypot(float num1, float num2)>

Returns sqrt(num1*num1 + num2*num2)

NOT IMPLEMENTED.

=cut

.sub 'hypot'
    not_implemented()
.end

=item C<bool is_finite(float val)>

Returns whether argument is finite

NOT IMPLEMENTED.

=cut

.sub 'is_finite'
    not_implemented()
.end

=item C<bool is_infinite(float val)>

Returns whether argument is infinite

NOT IMPLEMENTED.

=cut

.sub 'is_infinite'
    not_implemented()
.end

=item C<bool is_nan(float val)>

Returns whether argument is not a number

NOT IMPLEMENTED.

=cut

.sub 'is_nan'
    not_implemented()
.end

=item C<float log(float number, [float base])>

Returns the natural logarithm of the number, or the base log if base is specified

NOT IMPLEMENTED.

=cut

.sub 'log'
    not_implemented()
.end

=item C<float log10(float number)>

Returns the base-10 logarithm of the number

NOT IMPLEMENTED.

=cut

.sub 'log10'
    not_implemented()
.end

=item C<float log1p(float number)>

Returns log(1 + number), computed in a way that accurate even when the value of number is close to zero

NOT IMPLEMENTED.

=cut

.sub 'log1p'
    not_implemented()
.end

=item C<string number_format(float number [, int num_decimal_places [, string dec_seperator, string thousands_seperator]])>

Formats a number with grouped thousands

NOT IMPLEMENTED.

=cut

.sub 'number_format'
    not_implemented()
.end

=item C<int octdec(string octal_number)>

Returns the decimal equivalent of an octal string

NOT IMPLEMENTED.

=cut

.sub 'octdec'
    not_implemented()
.end

=item C<float pi(void)>

Returns an approximation of pi

NOT IMPLEMENTED.

=cut

.sub 'pi'
    not_implemented()
.end

=item C<number pow(number base, number exponent)>

Returns base raised to the power of exponent. Returns integer result when possible

NOT IMPLEMENTED.

=cut

.sub 'pow'
    not_implemented()
.end

=item C<float rad2deg(float number)>

Converts the radian number to the equivalent number in degrees

NOT IMPLEMENTED.

=cut

.sub 'rad2deg'
    not_implemented()
.end

=item C<float round(float number [, int precision])>

Returns the number rounded to specified precision

NOT IMPLEMENTED.

=cut

.sub 'round'
    not_implemented()
.end

=item C<float sin(float number)>

Returns the sine of the number in radians

NOT IMPLEMENTED.

=cut

.sub 'sin'
    not_implemented()
.end

=item C<float sinh(float number)>

Returns the hyperbolic sine of the number, defined as (exp(number) - exp(-number))/2

NOT IMPLEMENTED.

=cut

.sub 'sinh'
    not_implemented()
.end

=item C<float sqrt(float number)>

Returns the square root of the number

NOT IMPLEMENTED.

=cut

.sub 'sqrt'
    not_implemented()
.end

=item C<float tan(float number)>

Returns the tangent of the number in radians

NOT IMPLEMENTED.

=cut

.sub 'tan'
    not_implemented()
.end

=item C<float tanh(float number)>

Returns the hyperbolic tangent of the number, defined as sinh(number)/cosh(number)

NOT IMPLEMENTED.

=cut

.sub 'tanh'
    not_implemented()
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
