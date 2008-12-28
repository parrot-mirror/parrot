## $Id$

=head1 TITLE

Signature - Perl 6 Signature class

=head1 DESCRIPTION

This file sets up the Perl 6 C<Signature> class.

=head1 GUTS

This class will evolve over time as we understand signatures and how we will
expose there insides better. For now, a signature under the hood is just an
array of hashes, with each hash being a "descriptor" for something that is
bindable. Its keys are as follows.

* name - string holding the name of the thing we're binding to, if any
* type - the class or role type of the parameter; this references the actual
  type object rather than just naming it, and may well be parametric (but that
  will have been resolved already)
* constraints - any additional "where" refinement types on the parameter;
  will be a junction of types
* invocant - is this the invocant (as in, self for a method, not multi)
* multi_invocant - is this an invocant for the purpose of MMD
* optional - is this an optional parameter?
* slurpy - is this a slurpy parameter?

Again, this probably isn't definitive either, but it'll get us going.

=cut

.namespace ['Signature']

.sub 'onload' :anon :init :load
    load_bytecode 'PCT.pbc'
    .local pmc p6meta
    p6meta = get_hll_global ['Perl6Object'], '$!P6META'
    p6meta.'new_class'('Signature', 'parent'=>'Any', 'attr'=>'@!params')
.end

=head2 Methods

=over 4

=item !add_param( $varname, *%attr )

Add the attributes given by C<%attr> as the entry for C<$var> in
the Signature.

=cut

.sub '!add_param' :method
    .param string varname
    .param pmc attr            :slurpy :named

    attr['name'] = varname
    .local pmc params
    params = getattribute self, '@!params'
    unless null params goto have_params
    params = new 'List'
    setattribute self, '@!params', params
  have_params:
    push params, attr
.end

=item params

Get the array of parameter describing hashes.

=cut

.sub 'params' :method
    $P0 = getattribute self, "@!params"
    .return ($P0)
.end

=item perl

Gets a perl representation of the signature.

=cut

.sub 'perl' :method
    .local pmc s
    s = new 'Str'
    concat s, ':('

    # Output parameters.
    .local pmc params, param_iter, cur_param
    .local int last_was_multi_inv, want_colon, first
    last_was_multi_inv = 1
    want_colon = 0
    first = 1
    params = self.'params'()
    param_iter = iter params
  param_iter_loop:
    unless param_iter goto param_iter_loop_end
    cur_param = shift param_iter

    # If it's the first time, no separator.
    if first goto first_time
    if want_colon goto emit_colon
    $P0 = cur_param["multi_invocant"]
    if $P0 goto emit_comma
    unless last_was_multi_inv goto emit_comma
    concat s, ';; '
    last_was_multi_inv = 0
    goto separator_done
  emit_comma:
    concat s, ', '
    goto separator_done
  emit_colon:
    concat s, ': '
    goto separator_done
  first_time:
    first = 0
  separator_done:

    # First any nominal type.
    $P0 = cur_param["type"]
    if null $P0 goto any_type
    $P0 = $P0.'perl'()
    concat s, $P0
    goto type_done
  any_type:
    concat s, "Any"
  type_done:
    concat s, " "

    # If it's slurpy, the *.
    $P0 = cur_param["slurpy"]
    if null $P0 goto slurpy_done
    unless $P0 goto slurpy_done
    concat s, '*'
  slurpy_done:

    # Now the name.
    $P0 = cur_param["name"]
    concat s, $P0

    # If it's optional, the ?.
    $P0 = cur_param["optional"]
    if null $P0 goto optional_done
    unless $P0 goto optional_done
    concat s, '?'
  optional_done:

    # Now any constraints.
    $P0 = cur_param["constraints"]
    if null $P0 goto constraints_done
    unless $P0 goto constraints_done
    concat s, " where "
    $P0 = $P0.'perl'()
    concat s, $P0
  constraints_done:

    goto param_iter_loop
  param_iter_loop_end:

    # If we just had an invocant, need the colon.
    unless want_colon goto no_trailing_colon
    concat s, ':'
  no_trailing_colon:

    # XXX TODO: Return type, once we support those.

    # Done.
    concat s, ')'
    .return (s)
.end

=item !BIND_SIGNATURE

Analyze the signature of the caller, (re)binding the caller's
lexicals as needed and performing type checks.

=cut

.namespace []
.sub '!SIGNATURE_BIND'
    .include 'interpinfo.pasm'
    .local pmc callersub, callerlex, callersig
    $P0 = getinterp
    callersub = $P0['sub';1]
    callerlex = $P0['lexpad';1]
    getprop callersig, '$!signature', callersub
    if null callersig goto end
    .local pmc it
    $P0 = callersig.'params'()
    if null $P0 goto end
    it = iter $P0
  param_loop:
    unless it goto param_done
    .local pmc param
    param = shift it
    .local string name, sigil
    name = param['name']
    sigil = substr name, 0, 1
    .local pmc var
    var = callerlex[name]
    if sigil == '@' goto param_array
    var = 'Scalar'(var)
    callerlex[name] = var
    goto param_loop
  param_array:
    var = 'Array'(var)
    callerlex[name] = var
    goto param_loop
  param_done:
  end:
.end


=back

=cut



# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
