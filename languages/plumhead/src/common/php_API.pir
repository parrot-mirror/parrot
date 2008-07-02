# Copyright (C) 2008, The Perl Foundation.
# $Id$

=head1 NAME

php_api.pir - PHP API Library

=head1 DESCRIPTION

=head2 Functions

=over 4

=cut

.include 'languages/plumhead/src/common/php_MACRO.pir'

.sub '__onload' :anon :load :init
    # symbol table for constants
    new $P0, 'Hash'
    set_hll_global 'php_constants', $P0
.end

=item C<error>

=cut

.sub 'error'
    .param int level
    .param pmc args :slurpy
    .local string msg
    msg = join '', args
    msg .= "\n"
    printerr msg
.end


=item C<get_module_version>

DUMMY IMPLEMENTATION.

=cut

.sub 'get_module_version'
    .param string ext
    .return ('')
.end


=item C<parse_parameters>

STILL INCOMPLETE (see parse_arg_impl).

=cut

.sub 'parse_parameters'
   .param string fmt
   .param pmc args :slurpy
    .local int num_args
    .local int min_num_args
    .local int max_num_args
    num_args = args
    min_num_args = -1
    max_num_args = 0
    $P0 = split '', fmt
  L1:
    unless $P0 goto L2
    $S0 = shift $P0
    $I0 = index 'ldsbraoOzZChf', $S0
    unless $I0 > -1 goto L3
    inc max_num_args
    goto L1
  L3:
    unless $S0 == '|' goto L4
    min_num_args = max_num_args
    goto L1
  L4:
    $I0 = index '!/', $S0
    if $I0 > -1 goto L1
    $P0 = getinterp
    $P1 = $P0['sub', 1]
    error(E_WARNING, $P1, '(): bad type specifier while parsing parameters')
    .return (0)
  L2:
    unless min_num_args < 0 goto L5
    min_num_args = max_num_args
  L5:
    if num_args < min_num_args goto L6
    if num_args > max_num_args goto L6
    goto L7
  L6:
    $P0 = getinterp
    $P1 = $P0['sub', 1]
    unless min_num_args == max_num_args goto L8
    $S1 = 'exactly'
    goto L9
  L8:
    unless num_args < min_num_args goto L10
    $S1 = 'at least'
    goto L9
  L10:
    $S1 = 'at most'
  L9:
    unless num_args < min_num_args goto L11
    $I2 = min_num_args
    goto L12
  L11:
    $I2 = max_num_args
  L12:
    unless $I2 == 1 goto L13
    $S3 = ''
    goto L14
  L13:
    $S3 = 's'
  L14:
    error(E_WARNING, $P1, '() expects ', $S1, ' ', $I2, ' parameter', $S3, ', ', num_args, ' given')
    .return (0)
  L7:
    .local int ifmt, iarg
    ifmt = 0
    iarg = 0
  L21:
    unless iarg < num_args goto L22
    $P0 = args[iarg]
    $S0 = substr fmt, ifmt, 1
    unless $S0 == '|' goto L23
    inc ifmt
  L23:
    $I1 = iarg + 1
    ($I0, $P0, ifmt) = parse_arg($I1, $P0, fmt, ifmt)
    if $I0 goto L24
    .return (0)
  L24:
    args[iarg] = $P0
    inc iarg
    goto L21
  L22:
    .return (1, args :flat)
.end

.sub 'parse_arg' :anon
    .param int iarg
    .param pmc arg
    .param string fmt
    .param int ifmt
    .local string expected_type
    (expected_type, $P1, $I2) = parse_arg_impl(arg, fmt, ifmt)
    if expected_type == '' goto L1
    $P0 = getinterp
    $P1 = $P0['sub', 2]
    $S3 = typeof arg
    error(E_WARNING, $P1, '() expects parameter ', iarg, ' to be ', expected_type, ', ', $S3, ' given')
    .return (0)
  L1:
    .return (1, $P1, $I2)
.end

.sub 'parse_arg_impl' :anon
    .param pmc arg
    .param string fmt
    .param int ifmt
    .local string c
    c = substr fmt, ifmt, 1
    inc ifmt
    .local int return_null
    return_null = 0
  L1:
    $S0 = substr fmt, ifmt, 1
    unless $S0 == '/' goto L2
    goto L3
  L2:
    unless $S0 == '!' goto L4
    return_null = 1
  L3:
    inc ifmt
    goto L1
  L4:
    .local pmc ret
    ret = arg
    unless c == 'l' goto not_long
    $I0 = isa arg, 'PhpInteger'
    if $I0 goto L5
    $I0 = isa arg, 'PhpUndef'
    if $I0 goto L11
    $I0 = isa arg, 'PhpFloat'
    if $I0 goto L11
    $I0 = isa arg, 'PhpBoolean'
    if $I0 goto L11
    goto L12
  L11:
    new ret, 'PhpInteger'
    $I0 = arg
    set ret, $I0
    goto L5
  L12:
    $I0 = isa arg, 'PhpString'
    unless $I0 goto L13
    $I0 = arg.'is_numeric'(-1)
    unless $I0 goto L13
    arg = arg.'to_number'()
    $I0 = isa arg, 'PhpFloat'
    if $I0 goto L11
    goto L5
  L13:
    .return ('long')
  not_long:
    unless c == 'd' goto not_double
    $I0 = isa arg, 'PhpFloat'
    if $I0 goto L5
    $I0 = isa arg, 'PhpUndef'
    if $I0 goto L21
    $I0 = isa arg, 'PhpInteger'
    if $I0 goto L21
    $I0 = isa arg, 'PhpBoolean'
    if $I0 goto L21
    goto L22
  L21:
    new ret, 'PhpFloat'
    $N0 = arg
    set ret, $N0
    goto L5
  L22:
    $I0 = isa arg, 'PhpString'
    unless $I0 goto L23
    $I0 = arg.'is_numeric'(-1)
    unless $I0 goto L23
    arg = arg.'to_number'()
    $I0 = isa arg, 'PhpInteger'
    if $I0 goto L21
    goto L5
  L23:
    .return ('double')
  not_double:
    unless c == 's' goto not_string
#    $I0 = isa arg, 'PhpString'
    $I0 = isa arg, 'String'
    if $I0 goto L5
    $I0 = isa arg, 'PhpUndef'
    if $I0 goto L31
    $I0 = isa arg, 'PhpFloat'
    if $I0 goto L31
    $I0 = isa arg, 'PhpInteger'
    if $I0 goto L31
    $I0 = isa arg, 'PhpBoolean'
    if $I0 goto L31
    $I0 = isa arg, 'PhpObject'
    if $I0 goto L31
    goto L32
  L31:
    new ret, 'PhpString'
    $S0 = arg
    set ret, $S0
    goto L5
  L32:
    .return ('string')
  not_string:
    unless c == 'b' goto not_boolean
    $I0 = isa arg, 'PhpBoolean'
    if $I0 goto L5
    $I0 = isa arg, 'PhpUndef'
    if $I0 goto L41
    $I0 = isa arg, 'PhpFloat'
    if $I0 goto L41
    $I0 = isa arg, 'PhpInteger'
    if $I0 goto L41
    $I0 = isa arg, 'PhpString'
    if $I0 goto L41
    goto L42
  L41:
    new ret, 'PhpBoolean'
    $I0 = istrue arg
    set ret, $I0
    goto L5
  L42:
    .return ('boolean')
  not_boolean:
    unless c == 'r' goto not_resource
    ###
    goto L5
  not_resource:
    unless c == 'a' goto not_array
    $I0 = isa arg, 'PhpArray'
    if $I0 goto L5
    $I0 = isa arg, 'PhpUndef'
    unless $I0 goto L61
    unless return_null goto L61
    goto L5
  L61:
    .return ('array')
  not_array:
    unless c == 'h' goto not_hash
    $I0 = isa arg, 'PhpArray'
    if $I0 goto L5
    $I0 = isa arg, 'PhpUndef'
    unless $I0 goto L71
    unless return_null goto L71
    goto L5
  L71:
    .return ('array')
  not_hash:
    unless c == 'o' goto not_object
    ###
    goto L5
  not_object:
    unless c == 'O' goto not_Object
    ###
    goto L5
  not_Object:
    unless c == 'C' goto not_Class
    ###
    goto L5
  not_Class:
    unless c == 'f' goto not_function
    ###
    goto L5
  not_function:
    unless c == 'z' goto not_mixed
    goto L5
  not_mixed:
    unless c == 'Z' goto not_Mixed
    goto L5
  not_Mixed:
    .return ('unknown')
  L5:
    .return ('', ret, ifmt)
.end


=item C<wrong_param_count>

=cut

.sub 'wrong_param_count'
    $P0 = getinterp
    $P1 = $P0['sub', 1]
    error(E_WARNING, 'Wrong parameter count for ', $P1, '()')
.end


=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
