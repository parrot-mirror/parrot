# test include statement
.include "subflags.pir"

# test .HLL statement
.HLL "PIRC", "pircgroup"

.global x

.sub main
# test local declarations
    .local pmc x, y, z
    .local string a, b, c
    .local int i, j
    .local num pi

# test simple expressions
    i = 42
    pi = 3.14
    a = "Hello World"
    b = 'hello world'

# test conditional statements
    if x < y goto X
    unless y > x goto Y

# test multiple labels
X:
Y:
Z:
# test simple function call
    foo(1,2,3)
    .local pmc x, a, b, c
    x = foo(1, 2, 3)
    (a, b, c) = foo()
    $P0 = foo()
    P0 = foo()
    $S0 = foo()
    S0 = foo()
    $I0 = foo()
    I0 = foo()
    $N0 = foo()
    N0 = foo()

    .local pmc I
    .local int P, S, N
    I = P.bar()
    N = S.'bar'()


.end
#
# comments
.sub foo
    .param pmc args :slurpy
    .local int i
    i = args[0]
    print i



.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
