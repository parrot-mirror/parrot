# Copyright (C) 2008, The Perl Foundation.
# $Id$

=head1 NAME

lib/_helpers.pir - library

=head1 DESCRIPTION

=head2 Functions

=over 4

=cut

.HLL 'Lua', 'lua_group'
#.namespace [ 'Lua::_helpers'; 'Lua' ]

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


=back

=head1 AUTHORS

Francois Perrad

=cut


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
