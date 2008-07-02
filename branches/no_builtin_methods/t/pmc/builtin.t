#! parrot
# Copyright (C) 2001-2008, The Perl Foundation.
# $Id$

=head1 NAME

t/pmc/builtin.t - Builtin Methods

=head1 SYNOPSIS

    % prove t/pmc/builtin.t

=head1 DESCRIPTION

Tests builtin opcode-like methods.

=cut

.sub main :main
    .include 'include/test_more.pir'

    plan(10)

    three_ways_to_call_a_method()

    ## XXX skip() fails: Null PMC access in invoke()
    # skip( 1, 'bound methods - n/y' )
    # bound_methods()
    # parrot_io_puts()

.end

.sub three_ways_to_call_a_method
    .local pmc x, y, cl, m
    x = new 'Float'
    x = 1.0
    # opcode syntax
    y = cos x
    is( y, 0.540302, 'opcode syntax' )
    # function call syntax
    y = "cos"(x)
    is( y, 0.540302, 'function call syntax' )
    # method call
    y = x."cos"()
    is( y, 0.540302, 'method call syntax' )
.end

## skip bound methods - n/y
.sub bound_methods
    .local pmc x, y, cl, m
    x = new 'Float'
    x = 1.0

    # bound object method
    m = getattribute x, "cos"	# m = x.cos
    y = m()
    is( y, 0.540302, 'bound obj method' )

    cl = get_class "Float"
    y = cl."cos"(x)
    is( y, 0.540302, 'class method' )

    # bound class method
    m = getattribute cl, "cos"	# m = Float.cos
    y = m(x)
    is( y, 0.540302, 'bound class method' )
.end

## skip bound methods - n/y
.sub parrot_io_puts
    .local pmc o, m, cl
    o = getstdout
    $I0 = o."puts"("ok 1\n")
    puts $I0, o, "ok 2\n"
    $I0 = "puts"(o, "ok 3\n")
    m = getattribute o, "puts"
    $I0 = m("ok 4\n")
    cl = get_class "ParrotIO"
    $I0 = cl."puts"(o, "ok 5\n")
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
