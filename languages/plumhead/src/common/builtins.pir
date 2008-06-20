# $Id$

# a helper for the PHC variant
.sub 'decode_base64'
    .param pmc args :slurpy
    .return base64_decode(args :flat)
.end

.sub 'print_newline'
    say ''
.end

# steal builtins from Perl6
.sub 'print'
    .param pmc list            :slurpy
    .local pmc iter

    iter = new .Iterator, list
  iter_loop:
    unless iter goto iter_end
    $P0 = shift iter
    print $P0
    goto iter_loop

  iter_end:
    .return (1)
.end

# steal builtins from Perl6
# TODO: put that into php_builtins.pir
.sub 'echo'
    .param pmc list            :slurpy

    .local pmc iter
    iter = new .Iterator, list
  iter_loop:
    unless iter goto iter_end
    $P0 = shift iter
    print $P0
    goto iter_loop

  iter_end:
    .return (1)
.end

.sub 'prefix:-' :multi(Float)
    .param pmc a

    $N0 = a
    $N0 = neg $N0

    .return ($N0)
.end

.sub 'prefix:-' :multi(Integer)
    .param int a

    $I0 = neg a

    .return ($I0)
.end

.sub 'prefix:-' :multi(PMC)
    .param pmc a

    $N0 = a
    $N0 = neg $N0

    .return ($N0)
.end


.sub 'infix:+&'
    .param int a
    .param int b

    $I0 = band a, b

    .return ($I0)
.end

.sub 'infix:+|'
    .param int a
    .param int b

    $I0 = bor a, b

    .return ($I0)
.end

.sub 'infix:+^'
    .param int a
    .param int b

    $I0 = bxor a, b

    .return ($I0)
.end


.sub 'infix:<'
    .param pmc a
    .param pmc b

    $I0 = cmp_num a, b
    $I0 = islt $I0, 0

    .return ($I0)
.end


.sub 'infix:<='
    .param pmc a
    .param pmc b

    $I0 = cmp_num a, b
    $I0 = isle $I0, 0

    .return ($I0)
.end

.sub 'infix:=='
    .param pmc a
    .param pmc b

    $I0 = cmp_num a, b
    $I0 = iseq $I0, 0

    .return ($I0)
.end

.sub 'infix:!='
    .param pmc a
    .param pmc b

    $I0 = cmp_num a, b
    $I0 = isne $I0, 0

    .return ($I0)
.end

.sub 'infix:eq'
    .param pmc a
    .param pmc b

    $I0 = cmp_str a, b
    $I0 = iseq $I0, 0

    .return ($I0)
.end

.sub 'infix:ne'
    .param pmc a
    .param pmc b

    $I0 = cmp_str a, b
    $I0 = isne $I0, 0

    .return ($I0)
.end

.sub 'infix:>='
    .param pmc a
    .param pmc b

    $I0 = cmp_num a, b
    $I0 = isge $I0, 0

    .return ($I0)
.end


.sub 'infix:>'
    .param pmc a
    .param pmc b

    $I0 = cmp_num a, b
    $I0 = isgt $I0, 0

    .return ($I0)
.end


.sub 'infix:!='
    .param pmc a
    .param pmc b

    $I0 = cmp_num a, b
    $I0 = isne $I0, 0

    .return ($I0)
.end

.sub 'infix:.' :multi( PMC, PMC )
    .param pmc a
    .param pmc b

    .local pmc c
    c = new 'String'
    c = concat a, b

    .return (c)
.end

.sub 'infix:.' :multi( PMC, String )
    .param pmc a
    .param string b

    .local pmc c
    c = new 'String'
    c = concat a, b
    #c = 'multi PMC, String'

    .return (c)
.end

.sub 'infix:.' :multi( PMC )
    .param pmc a

    .return (a)
.end

.sub 'infix:.' :multi( String, PMC )
    .param string a
    .param pmc b

    .local pmc c, d
    c = new 'String'
    c = a
    d = new 'String'
    d = concat c, b

    .return (d)
.end

.sub 'infix:|'
    .param int a
    .param int b

    $I0 = bor a, b

    .return ($I0)
.end

.sub 'infix:&'
    .param int a
    .param int b

    $I0 = band a, b

    .return ($I0)
.end

.sub 'infix:~'
    .param string a
    .param string b

    $S0 = concat a, b

    .return ($S0)
.end

.sub 'error_reporting'
  .return()
.end


.include 'languages/plumhead/src/common/php_standard.pir'

.sub '__onload' :anon :load
    $P0 = subclass 'Boolean', 'PhpBoolean'
    $P0 = subclass 'Float', 'PhpFloat'
    $P0 = subclass 'Integer', 'PhpInteger'
    $P0 = subclass 'String', 'PhpString'
    $P0 = subclass 'Undef', 'PhpUndef'
.end

.namespace [ 'PhpBoolean' ]

.sub 'name' :vtable :method
    .return ('boolean')
.end

.sub 'get_string' :vtable :method
    unless self goto L1
    .return ('1')
  L1:
    .return ('')
.end


.namespace [ 'PhpFloat' ]

.sub 'name' :vtable :method
    .return ('double')
.end


.namespace [ 'PhpInteger' ]

.sub 'name' :vtable :method
    .return ('integer')
.end


.namespace [ 'PhpString' ]

.sub 'name' :vtable :method
    .return ('string')
.end


.namespace [ 'PhpUndef' ]

.sub 'name' :vtable :method
    .return ('NULL')
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
