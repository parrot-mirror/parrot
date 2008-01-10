#! perl -pi
# $Id$
# Copyright (C) 2008, The Perl Foundation.

=head1 NAME

tools/dev/vtablize.pl - Update PMCs to new format

=head1 SYNOPSIS

    % perl tools/dev/vtablize.pl *.pmc

=head1 DESCRIPTION

This script modifies a PMC definition file in place to mark all vtable function
declarations with the leading C<VTABLE> keyword. It was used to update all core
PMCs as part of the implementation of PDD 17 on PMCs, and will be useful in
updating HLL-specific and user-defined PMCs when we change the C<VTABLE>
keyword to be required. Once all conversions are completed, this script can be
deleted.

=head1 SEE ALSO

docs/pdds/pdd17_pmc.pod

=cut


s/^(\s*)(void init\(\) {)/$1VTABLE $2/;
s/^(\s*)(void init_pmc\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*instantiate\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*new_from_string\(STRING \*\w*, INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void morph\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void mark\(\) {)/$1VTABLE $2/;
s/^(\s*)(void destroy\(\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*pmc_namespace\(\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*getprop\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void setprop\(STRING \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void delprop\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*getprops\(\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL type\(\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL type_keyed\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL type_keyed_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL type_keyed_str\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(UINTVAL subtype\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(STRING \*name\(\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*clone\(\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*clone_pmc\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*find_method\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL get_integer\(\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL get_integer_keyed\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL get_integer_keyed_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL get_integer_keyed_str\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(FLOATVAL get_number\(\) {)/$1VTABLE $2/;
s/^(\s*)(FLOATVAL get_number_keyed\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(FLOATVAL get_number_keyed_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(FLOATVAL get_number_keyed_str\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL get_bool\(\) {)/$1VTABLE $2/;
s/^(\s*)(STRING \*get_string\(\) {)/$1VTABLE $2/;
s/^(\s*)(STRING \*get_string_keyed\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(STRING \*get_string_keyed_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(STRING \*get_string_keyed_str\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(STRING \*get_repr\(\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*get_pmc\(\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*get_pmc_keyed\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*get_pmc_keyed_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*get_pmc_keyed_str\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*get_bignum\(\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*slice\(PMC \*\w*, INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void \*get_pointer\(\) {)/$1VTABLE $2/;
s/^(\s*)(void \*get_pointer_keyed\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void \*get_pointer_keyed_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void \*get_pointer_keyed_str\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_integer_native\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_integer_same\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_integer_keyed\(PMC \*\w*, INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_integer_keyed_int\(INTVAL \w*, INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_integer_keyed_str\(STRING \*\w*, INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_number_native\(FLOATVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_number_same\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_number_keyed\(PMC \*\w*, FLOATVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_number_keyed_int\(INTVAL \w*, FLOATVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_number_keyed_str\(STRING \*\w*, FLOATVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_bignum_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_bignum_num\(FLOATVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_bignum_str\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_string_native\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void assign_string_native\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_string_same\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_string_keyed\(PMC \*\w*, STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_string_keyed_int\(INTVAL \w*, STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_string_keyed_str\(STRING \*\w*, STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_pmc\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void assign_pmc\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_pmc_keyed\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_pmc_keyed_int\(INTVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_pmc_keyed_str\(STRING \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_pointer\(void \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_pointer_keyed\(PMC \*\w*, void \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_pointer_keyed_int\(INTVAL \w*, void \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_pointer_keyed_str\(STRING \*\w*, void \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_bool\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL elements\(\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL pop_integer\(\) {)/$1VTABLE $2/;
s/^(\s*)(FLOATVAL pop_float\(\) {)/$1VTABLE $2/;
s/^(\s*)(STRING \*pop_string\(\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*pop_pmc\(\) {)/$1VTABLE $2/;
s/^(\s*)(void push_integer\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void push_float\(FLOATVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void push_string\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void push_string\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL shift_integer\(\) {)/$1VTABLE $2/;
s/^(\s*)(FLOATVAL shift_float\(\) {)/$1VTABLE $2/;
s/^(\s*)(STRING \*shift_string\(\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*shift_pmc\(\) {)/$1VTABLE $2/;
s/^(\s*)(void unshift_integer\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void unshift_float\(FLOATVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void unshift_string\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void unshift_string\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*add\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*add_int\(INTVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*add_float\(FLOATVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_add\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_add_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_add_float\(FLOATVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*subtract\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*subtract_int\(INTVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*subtract_float\(FLOATVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_subtract\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_subtract_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_subtract_float\(FLOATVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*multiply\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*multiply_int\(INTVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*multiply_float\(FLOATVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_multiply\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_multiply_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_multiply_float\(FLOATVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*divide\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*divide_int\(INTVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*divide_float\(FLOATVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_divide\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_divide_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_divide_float\(FLOATVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*floor_divide\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*floor_divide_int\(INTVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*floor_divide_float\(FLOATVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_floor_divide\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_floor_divide_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_floor_divide_float\(FLOATVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*modulus\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*modulus_int\(INTVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*modulus_float\(FLOATVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_modulus\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_modulus_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_modulus_float\(FLOATVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*cmodulus\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*cmodulus_int\(INTVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*cmodulus_float\(FLOATVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_cmodulus\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_cmodulus_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_cmodulus_float\(FLOATVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*pow\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*pow_int\(INTVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*pow_float\(FLOATVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_pow\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_pow_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_pow_float\(FLOATVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void increment\(\) {)/$1VTABLE $2/;
s/^(\s*)(void decrement\(\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*absolute\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_absolute\(\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*neg\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_neg\(\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_or\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_or_int\(INTVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_or\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_or_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_xor\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_xor_int\(INTVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_xor\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_xor_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_ors\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_ors_str\(STRING \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_ors\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_ors_str\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_xors\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_xors_str\(STRING \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_xors\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_xors_str\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_and\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_and_int\(INTVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_and\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_and_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_ands\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_ands_str\(STRING \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_ands\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_ands_str\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_not\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_not\(\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_nots\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_nots\(\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_shl\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_shl_int\(INTVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_shl\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_shl_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_shr\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_shr_int\(INTVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_shr\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_shr_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_lsr\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*bitwise_lsr_int\(INTVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_lsr\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_bitwise_lsr_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL is_equal\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL is_equal_num\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL is_equal_string\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL is_same\(const PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL cmp\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL cmp_num\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL cmp_string\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*logical_or\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*logical_xor\(PMC \*\w*, PMC \*\w*\) {)/$2VTABLE $2/;
s/^(\s*)(PMC \*logical_and\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*logical_not\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_logical_not\(\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*concatenate\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*concatenate_str\(STRING \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_concatenate\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_concatenate_str\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*repeat\(PMC \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*repeat_int\(INTVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_repeat\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void i_repeat_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void substr\(INTVAL \w*, INTVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(STRING \*substr_str\(INTVAL \w*, INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL exists_keyed\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL exists_keyed_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL exists_keyed_str\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL defined\(\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL defined_keyed\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL defined_keyed_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL defined_keyed_str\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void delete_keyed\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void delete_keyed_int\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(void delete_keyed_str\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*nextkey_keyed\(PMC \*\w*, INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*nextkey_keyed_int\(INTVAL \w*, INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*nextkey_keyed_str\(STRING \*\w*, INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*get_iter\(\) {)/$1VTABLE $2/;
s/^(\s*)(opcode_t \*invoke\(void \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL can\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL does\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL isa\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL isa_pmc\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*get_attr\(INTVAL \w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*get_attr_str\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*get_attr_keyed\(PMC \*\w*, STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_attr\(INTVAL \w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_attr_str\(STRING \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void set_attr_keyed\(PMC \*\w*, STRING \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void add_role\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void remove_role\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void add_parent\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void remove_parent\(PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*get_class\(\) {)/$1VTABLE $2/;
s/^(\s*)(INTVAL class_type\(\) {)/$1VTABLE $2/;
s/^(\s*)(void add_attribute\(STRING \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void remove_attribute\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void add_method\(STRING \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void remove_method\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void add_vtable_override\(STRING \*\w*, PMC \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void remove_vtable_override\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*inspect\(\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*inspect_str\(STRING \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void freeze\(visit_info \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void thaw\(visit_info \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void thaw_finish\(visit_info \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void visit\(visit_info \*\w*\) {)/$1VTABLE $2/;
s/^(\s*)(void share\(\) {)/$1VTABLE $2/;
s/^(\s*)(PMC \*share_ro\(\) {)/$1VTABLE $2/;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
