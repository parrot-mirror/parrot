# Copyright (C) 2008, The Perl Foundation.
# $Id$

=head1 NAME

lib/bitlib.pir - bitwise operations library

=head1 DESCRIPTION

bitlib is a library for Lua 5.1 that provides bitwise operations.

See original on L<http://luaforge.net/projects/bitlib/>

The library provides the constant C<bit.bits> that gives the number of bits
that can be used in bitwise operations, and the following functions:

=head2 Functions

=over 4

=cut

.HLL 'Lua', 'lua_group'
.namespace [ 'bitlib' ]

.sub '__onload' :anon :load
#    print "__onload bitlib\n"
    .const .Sub entry = 'luaopen_bitlib'
    set_hll_global 'luaopen_bitlib', entry
.end

.const string MYNAME = 'bit'

.sub 'luaopen_bitlib'

#    print "luaopen_bitlib\n"

    .local pmc _lua__GLOBAL
    _lua__GLOBAL = get_hll_global '_G'

    new $P1, 'LuaString'

    .local pmc _bitlib
    new _bitlib, 'LuaTable'
    set $P1, MYNAME
    _lua__GLOBAL[$P1] = _bitlib

    lua_register($P1, _bitlib)

    new $P2, 'LuaNumber'
    $I0 = _get_bits()
    set $P2, $I0
    set $P1, 'bits'
    _bitlib[$P1] = $P2

    .const .Sub _bitlib_cast = 'cast'
    _bitlib_cast.'setfenv'(_lua__GLOBAL)
    set $P1, 'cast'
    _bitlib[$P1] = _bitlib_cast

    .const .Sub _bitlib_bnot = 'bnot'
    _bitlib_bnot.'setfenv'(_lua__GLOBAL)
    set $P1, 'bnot'
    _bitlib[$P1] = _bitlib_bnot

    .const .Sub _bitlib_band = 'band'
    _bitlib_band.'setfenv'(_lua__GLOBAL)
    set $P1, 'band'
    _bitlib[$P1] = _bitlib_band

    .const .Sub _bitlib_bor = 'bor'
    _bitlib_bor.'setfenv'(_lua__GLOBAL)
    set $P1, 'bor'
    _bitlib[$P1] = _bitlib_bor

    .const .Sub _bitlib_bxor = 'bxor'
    _bitlib_bxor.'setfenv'(_lua__GLOBAL)
    set $P1, 'bxor'
    _bitlib[$P1] = _bitlib_bxor

    .const .Sub _bitlib_lshift = 'lshift'
    _bitlib_lshift.'setfenv'(_lua__GLOBAL)
    set $P1, 'lshift'
    _bitlib[$P1] = _bitlib_lshift

    .const .Sub _bitlib_rshift = 'rshift'
    _bitlib_rshift.'setfenv'(_lua__GLOBAL)
    set $P1, 'rshift'
    _bitlib[$P1] = _bitlib_rshift

    .const .Sub _bitlib_arshift = 'arshift'
    _bitlib_arshift.'setfenv'(_lua__GLOBAL)
    set $P1, 'arshift'
    _bitlib[$P1] = _bitlib_arshift

    .return (_bitlib)
.end

.sub '_get_bits' :anon
    .local int bits
    .include 'sysinfo.pasm'
    sysinfo $I0, .SYSINFO_PARROT_INTSIZE
    $I0 *= 8
    bits = $I0 - 1
    .local int max
    $I0 = 0
    $I0 = bnot $I0
    max = shr $I0, 1
    unless bits == 63 goto L1
    bits = 53
    max = shr max, 10
  L1:
    new $P0, 'Integer'
    set $P0, max
    set_hll_global ['bit'], 'BIT_MAX', $P0
    .return (bits)
.end

.macro MONADIC(op, a)
    .local pmc res
    .local int BIT_MAX
    $P0 = get_hll_global ['bit'], 'BIT_MAX'
    BIT_MAX = $P0
    $I1 = lua_checknumber(1, .a)
    .op $I0, $I1
    band $I0, BIT_MAX
    new res, 'LuaNumber'
    set res, $I0
    .return (res)
.endm

.macro VARIADIC(op, a, vararg)
    .local pmc res
    .local int BIT_MAX
    $P0 = get_hll_global ['bit'], 'BIT_MAX'
    BIT_MAX = $P0
    $I1 = lua_checknumber(1, .a)
    .local int i
    i = 2
  L1:
    unless .vararg goto L2
    $P0 = shift .vararg
    $I0 = lua_checknumber(i, $P0)
    .op $I1, $I0
    inc i
    goto L1
  L2:
    band $I1, BIT_MAX
    new res, 'LuaNumber'
    set res, $I1
    .return (res)
.endm

.macro LOGICAL_SHIFT(op, a, b)
    .local pmc res
    .local int BIT_MAX
    $P0 = get_hll_global ['bit'], 'BIT_MAX'
    BIT_MAX = $P0
    $I1 = lua_checknumber(1, .a)
    band $I1, BIT_MAX
    $I2 = lua_checknumber(2, .b)
    .op $I0, $I1, $I2
    band $I0, BIT_MAX
    new res, 'LuaNumber'
    set res, $I0
    .return (res)
.endm

.macro ARITHMETIC_SHIFT(op, a, b)
    .local pmc res
    .local int BIT_MAX
    $P0 = get_hll_global ['bit'], 'BIT_MAX'
    BIT_MAX = $P0
    $I1 = lua_checknumber(1, .a)
    $I2 = lua_checknumber(2, .b)
    .op $I0, $I1, $I2
    band $I0, BIT_MAX
    new res, 'LuaNumber'
    set res, $I0
    .return (res)
.endm


=item C<bit.cast (a)>

cast C<a> to the internally-used integer type

=cut

.sub 'cast' :anon
    .param pmc a :optional
    .param pmc extra :slurpy
    .MONADIC(set, a)
.end


=item C<bit.bnot (a)>

returns the one's complement of C<a>

=cut

.sub 'bnot' :anon
    .param pmc a :optional
    .param pmc extra :slurpy
     .MONADIC(bnot, a)
.end


=item C<bit.band (a, ...)>

returns the bitwise and of the w's

=cut

.sub 'band' :anon
    .param pmc a :optional
    .param pmc vararg :slurpy
    .VARIADIC(band, a, vararg)
.end


=item C<bit.bor (a, ...)>

returns the bitwise or of the w's

=cut

.sub 'bor' :anon
    .param pmc a :optional
    .param pmc vararg :slurpy
    .VARIADIC(bor, a, vararg)
.end


=item C<bit.bxor (a, ...)>

returns the bitwise exclusive or of the w's

=cut

.sub 'bxor' :anon
    .param pmc a :optional
    .param pmc vararg :slurpy
    .VARIADIC(bxor, a, vararg)
.end


=item C<bit.lshift (a, b)>

returns C<a> shifted left C<b> places

=cut

.sub 'lshift' :anon
    .param pmc a :optional
    .param pmc b :optional
    .param pmc extra :slurpy
    .ARITHMETIC_SHIFT(shl, a, b)
.end


=item C<bit.rshift (a, b)>

returns C<a> shifted right C<b> places

=cut

.sub 'rshift' :anon
    .param pmc a :optional
    .param pmc b :optional
    .param pmc extra :slurpy
    .LOGICAL_SHIFT(lsr, a, b)
.end


=item C<bit.arshift (a, b)>

returns C<a> shifted arithmetically right C<b> places

=cut

.sub 'arshift' :anon
    .param pmc a :optional
    .param pmc b :optional
    .param pmc extra :slurpy
    .ARITHMETIC_SHIFT(shr, a, b)
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
