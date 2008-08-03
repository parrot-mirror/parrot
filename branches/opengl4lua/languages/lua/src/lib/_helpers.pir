# Copyright (C) 2008, The Perl Foundation.
# $Id$

=head1 NAME

lib/_helpers.pir - library

=head1 DESCRIPTION

=head2 Functions

=over 4

=cut

.HLL 'Lua', 'lua_group'
.namespace [ 'Lua::_helpers'; 'Lua' ]

.sub '__onload' :anon :load
#    print "__onload _helpers\n"
    .const .Sub entry = 'luaopen__helpers'
    set_hll_global 'luaopen__helpers', entry
.end

.sub 'luaopen__helpers'

#    print "luaopen__helpers\n"

    .local pmc _lua__GLOBAL
    _lua__GLOBAL = get_hll_global '_G'

    new $P1, 'LuaString'

    .local pmc __helpers
    new __helpers, 'LuaTable'
    set $P1, '_helpers'
    _lua__GLOBAL[$P1] = __helpers

    lua_register($P1, __helpers)

    .const .Sub __helpers_lua_isboolean = 'lua_isboolean'
    set $P1, 'lua_isboolean'
    __helpers[$P1] = __helpers_lua_isboolean

    .const .Sub __helpers_lua_isfunction = 'lua_isfunction'
    set $P1, 'lua_isfunction'
    __helpers[$P1] = __helpers_lua_isfunction

    .const .Sub __helpers_lua_isnil = 'lua_isnil'
    set $P1, 'lua_isnil'
    __helpers[$P1] = __helpers_lua_isnil

    .const .Sub __helpers_lua_isnumber = 'lua_isnumber'
    set $P1, 'lua_isnumber'
    __helpers[$P1] = __helpers_lua_isnumber

    .const .Sub __helpers_lua_isstring = 'lua_isstring'
    set $P1, 'lua_isstring'
    __helpers[$P1] = __helpers_lua_isstring

    .const .Sub __helpers_lua_istable = 'lua_istable'
    set $P1, 'lua_istable'
    __helpers[$P1] = __helpers_lua_istable

    .const .Sub __helpers_lua_isuserdata = 'lua_isuserdata'
    set $P1, 'lua_isuserdata'
    __helpers[$P1] = __helpers_lua_isuserdata

    .return (__helpers)
.end


=item C<lua_isboolean (val)>

Returns 1 if the value has type boolean, and 0 otherwise.

=cut

.sub 'lua_isboolean'
    .param pmc val
    .local int res
    res = 0
    if null val goto L1
    res = isa val, 'LuaBoolean'
  L1:
    new $P0, 'LuaBoolean'
    set $P0, res
    .return ($P0)
.end


=item C<lua_isfunction (val)>

Returns 1 if the value is a function, and 0 otherwise.

=cut

.sub 'lua_isfunction'
    .param pmc val
    .local int res
    res = 0
    if null val goto L1
    res = isa val, 'LuaClosure'
    if res goto L1
    res = isa val, 'LuaFunction'
L1:
    new $P0, 'LuaBoolean'
    set $P0, res
    .return ($P0)
.end


=item C<lua_isnil (val)>

Returns 1 if the value is nil, and 0 otherwise.

=cut

.sub 'lua_isnil'
    .param pmc val
    .local int res
    res = 0
    if null val goto L1
    res = isa val, 'LuaNil'
  L1:
    new $P0, 'LuaBoolean'
    set $P0, res
    .return ($P0)
.end


=item C<lua_isnumber (val)>

Returns 1 if the value is a number or a string convertible to a number,
and 0 otherwise.

=cut

.sub 'lua_isnumber'
    .param pmc val
    .local int res
    res = 0
    if null val goto L1
    res = isa val, 'LuaNumber'
    if res goto L1
    $P0 = val.'tonumber'()
    res = isa $P0, 'LuaNumber'
L1:
    new $P0, 'LuaBoolean'
    set $P0, res
    .return ($P0)
.end


=item C<lua_isstring (val)>

Returns 1 if the value is a string or a number (which is always convertible
to a string), and 0 otherwise.

=cut

.sub 'lua_isstring'
    .param pmc val
    .local int res
    res = 0
    if null val goto L1
    res = isa val, 'LuaString'
    if res goto L1
    res = isa val, 'LuaNumber'
L1:
    new $P0, 'LuaBoolean'
    set $P0, res
    .return ($P0)
.end


=item C<lua_istable (val)>

Returns 1 if the value is a table, and 0 otherwise.

=cut

.sub 'lua_istable'
    .param pmc val
    .local int res
    res = 0
    if null val goto L1
    res = isa val, 'LuaTable'
  L1:
    new $P0, 'LuaBoolean'
    set $P0, res
    .return ($P0)
.end


=item C<lua_isuserdata (val)>

Returns 1 if the value is a userdata, and 0 otherwise.

=cut

.sub 'lua_isuserdata'
    .param pmc val
    .local int res
    res = 0
    if null val goto L1
    res = isa val, 'LuaUserdata'
  L1:
    new $P0, 'LuaBoolean'
    set $P0, res
    .return ($P0)
.end


=back

=head1 AUTHORS

Francois Perrad

=cut


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
