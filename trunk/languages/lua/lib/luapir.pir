# Copyright: 2005-2006 The Perl Foundation.  All Rights Reserved.
# $Id$

=head1 NAME

lib/luapir.pir - Lua PIR Library

=head1 DESCRIPTION

=head2 Functions

=over 4

=cut

.namespace [ "Lua" ]
.HLL "Lua", "lua_group"


=item C<argerror (extramsg)>

=cut

.sub argerror
    .param string extramsg
    error(extramsg)
.end


=item C<checkany (arg)>

=cut

.sub checkany
    .param pmc arg
    unless_null arg, L1
    argerror("value expected")
L1:
.end


=item C<checkforloop (start, limit, step)>

=cut

.sub checkforloop
    .param pmc start
    .param pmc limit
    .param pmc step
    .local pmc ret_start
    ret_start = start."tonumber"()
    if ret_start goto L1
    error("`for' initial value must be a number")
L1:    
    .local pmc ret_limit
    ret_limit = limit."tonumber"()
    if ret_limit goto L2
    error("`for' limit must be a number")
L2:    
    .local pmc ret_step
    ret_step = step."tonumber"()
    if ret_step goto L3
    error("`for' step must be a number")
L3:    
    .return (ret_start, ret_limit, ret_step)
.end


=item C<checknumber (arg)>

=cut

.sub checknumber
    .param pmc arg
    .local float val
    $S0 = "no value"
    if_null arg, L0
    $S0 = typeof arg
    $I0 = isa arg, "LuaNumber"
    unless $I0 goto L1
    val = arg
    .return (val)    
L1:
    $I0 = isa arg, "LuaString"
    unless $I0 goto L0
    $P0 = arg."tonumber"()
    $I0 = isa $P0, "LuaNumber"
    unless $I0 goto L0
    val = $P0
    .return (val)
L0:
    tag_error($S0, "number")    
.end


=item C<checkstring (arg)>

=cut

.sub checkstring
    .param pmc arg
    .local pmc val
    $S0 = "no value"
    if_null arg, L0
    $S0 = typeof arg
    $I0 = isa arg, "LuaString"
    unless $I0 goto L1
    val = arg
    .return (val)    
L1:
    $I0 = isa arg, "LuaNumber"
    unless $I0 goto L0
    val = arg."tostring"()
    .return (val)
L0:
    tag_error($S0, "string")    
.end


=item C<checktype (arg, type)>

=cut

.sub checktype
    .param pmc arg
    .param string type
    $S0 = "no value"       
    if_null arg, L0
    $S0 = typeof arg       
    if $S0 != type goto L0
    .return ()
L0:
    tag_error($S0, type)
.end


=item C<error (message)>

=cut

.sub error
    .param string message
    .local pmc ex
    ex = new .Exception
    ex["_message"] =  message
    throw ex
.end


=item C<getn (table)>

=cut

.sub getn
    .param pmc table
    .const .LuaString n = "n"
    $P0 = table[n]
    if_null $P0, L0
    $I0 = isa $P0, "LuaNumber"
    unless $I0, L0
    $I1 = $P0
    unless $I1 >= 0 goto L0
    .return ($I1)
L0:
    $I1 = 0
    new $P1, .LuaNumber
    $P1 = 1.0 
L1:
    $P0 = table[$P1]
    unless $P0 goto L2
    add $I1, 1
    add $P1, 1.0
    goto L1
L2:
    .return ($I1)
.end


=item C<mkarg (argv)>

Support variable number of arguments function call.

=cut

.sub mkarg
    .param pmc argv
    .local pmc ret
    .local pmc key
    .local pmc curr
    .local int argc
    .local int i
    new ret, .LuaTable
    new key, .LuaNumber
    key = 0
    if_null argv, L2
    argc = argv
    i = 0
L1:
    if i >= argc goto L2
    curr = argv[i]
    i = i + 1
    key = i
    ret[key] = curr
    goto L1
L2:
    .const .LuaString n = "n"
    ret[n] = key
    .return (ret)
.end


=item C<next (table, index)>

=cut

.sub next
    .param pmc table
    .param pmc index
    .local pmc value
    if index goto L1
    new index, .LuaNumber
    index = 0.0
L1:
    add index, 1.0
    value = table[index]
    unless value goto L2
    .return (index, value)    
L2:
    .return (value)		# nil
.end


=item C<not_implemented ()>

=cut

.sub not_implemented
    .local pmc ex
    ex = new .Exception
    ex["_message"] =  "not implemented"
    throw ex
.end


=item C<optint (arg)>

=cut

.sub optint
    .param pmc arg
    .param int default
    if_null arg, L0
    unless arg goto L0
    $I1 = checknumber(arg)
    .return ($I1)
L0:
    .return (default)
.end


=item C<optstring (arg)>

=cut

.sub optstring
    .param pmc arg
    .param string default
    if_null arg, L0
    unless arg goto L0
    $S0 = arg
    .return ($S0)
L0:
    .return (default)
.end


=item C<setn (table, n)>

=cut

.sub setn
    .param pmc table
    .param int n
    .const .LuaString key_n = "n"
    new $P0, .LuaNumber
    $P0 = n
    table[key_n] = $P0
.end


=item C<tag_error (got, expec)>

=cut

.sub tag_error
    .param string got
    .param string expec
    $S0 = expec 
    concat $S0, " expected, got "
    concat $S0, got
    argerror($S0)
.end


=item C<tconstruct (table, index, argv)>

=cut

.sub tconstruct
    .param pmc table
    .param pmc index
    .param pmc argv :slurpy
    .local int argc
    .local int i
    argc = argv
    i = 0
L1:
    if i >= argc goto L2
    $P0 = argv[i]
    table[index] = $P0
    add index, 1.0
    i = i + 1
    goto L1
L2:
    .return (table)
.end


=back

=head1 AUTHORS

Francois Perrad

=cut

