#!./parrot

# $Id$

=head1 NAME

plumhead.pir - three variants of PHP on Parrot

=head1 SYNOPSIS

   ./parrot languages/plumhead/plumhead.pbc t.php

   ./parrot languages/plumhead/plumhead.pbc --variant=pct t.php

   ./parrot languages/plumhead/plumhead.pbc --variant=phc t.php

   ./parrot languages/plumhead/plumhead.pbc --variant=antlr t.php

=head1 DESCRIPTION

Driver for four variants of PHP on Parrot.

=head1 Variants

=head2 Plumhead pct

Parse PHP with the Parrot compiler toolkit. This is the default variant.

=head2 Plumhead phc

Take XML from phc and transform it with XSLT to PIR setting up PAST.
Run the PAST with the help of PCT.

=head2 Plumhead antlr

Parse PHP with Java based parser and tree parser, generated from ANTLR3 grammars.

=head1 SEE ALSO

F<languages/plumhead/docs>

=head1 AUTHOR

Bernhard Schmalhofer - L<Bernhard.Schmalhofer@gmx.de>

=cut


.namespace [ 'Plumhead' ]

.const string VERSION = "0.0.1"

.include "library/dumper.pir"

.sub '__onload' :load :init
    load_bytecode 'PGE.pbc'
    load_bytecode 'PGE/Text.pbc'
    load_bytecode 'PGE/Util.pbc'
    load_bytecode 'PGE/Dumper.pbc'

    load_bytecode 'PCT.pbc'

    load_bytecode 'languages/plumhead/src/common/plumheadlib.pbc'

    load_bytecode 'CGI/QueryHash.pbc'
    load_bytecode 'MIME/Base64.pbc'
    load_bytecode 'dumper.pbc'
    load_bytecode 'Getopt/Obj.pbc'

    # import PGE::Util::die into Plumhead::Grammar
    $P0 = get_hll_global ['PGE::Util'], 'die'
    set_hll_global ['Plumhead::Grammar'], 'die', $P0

    .local pmc plumhead_compiler
    plumhead_compiler = new [ 'PCT::HLLCompiler' ]
    plumhead_compiler.'language'('Plumhead')
    plumhead_compiler.'parsegrammar'('Plumhead::Grammar')
    plumhead_compiler.'astgrammar'('Plumhead::PAST::Grammar')

.end

.sub plumhead :main
    .param pmc argv
    # _dumper( argv )

    .local string rest
    .local pmc    opt
    ( opt, rest ) = parse_options(argv)

    .local string source_fn
    source_fn = opt['f']
    if source_fn goto GOT_PHP_SOURCE_FN
        source_fn = rest
GOT_PHP_SOURCE_FN:

    .local string cmd, err_msg
    .local int ret

    .local string variant
    variant = opt['variant']

    if variant == 'antlr3'    goto VARIANT_ANTLR3
    if variant == 'pct'       goto VARIANT_PCT
    if variant == 'phc'       goto VARIANT_PHC
    $I0 = defined opt['run-nqp']
    if $I0                    goto RUN_NQP

VARIANT_PCT:
    # the default variant
    # look for subs in other namespaces
    .local pmc parse_get_sub, parse_post_sub
    parse_get_sub  = get_hll_global [ 'CGI'; 'QueryHash' ], 'parse_get'
    parse_post_sub = get_hll_global [ 'CGI'; 'QueryHash' ], 'parse_post'

    # the superglobals
    .local pmc superglobal_GET
    ( superglobal_GET ) = parse_get_sub()
    set_hll_global '$_GET', superglobal_GET
    # be compatible with PHC variant
    set_hll_global '_GET', superglobal_GET
    #'_dumper'( superglobal_GET, 'GET' )

    .local pmc superglobal_POST
    ( superglobal_POST ) = parse_post_sub()
    set_hll_global '$_POST', superglobal_POST
    # be compatible with PHC variant
    set_hll_global '_POST', superglobal_POST
    #'_dumper'( superglobal_POST, 'POST' )

    err_msg = 'Compiling and executing with pct failed'
    .local pmc plumhead_compiler
    plumhead_compiler = compreg 'Plumhead'

    .local string target
    target = opt['target']
    unless target goto got_no_target
        .return plumhead_compiler.'evalfiles'(source_fn, 'target' => target )
    got_no_target:
    .return plumhead_compiler.'evalfiles'( source_fn )

VARIANT_PHC:
    err_msg = 'Creating XML-AST with phc failed'
    cmd = 'phc --dump-ast-xml '
    concat cmd, source_fn
    concat cmd, '> plumhead_phc_ast.xml'
    ret = spawnw cmd
    if ret goto ERROR

    err_msg = 'Creating XML-PAST with xsltproc failed'
    cmd = 'xsltproc languages/plumhead/src/phc/phc_xml_to_past_xml.xsl plumhead_phc_ast.xml > plumhead_phc_past.xml'
    ret = spawnw cmd
    if ret goto ERROR

    err_msg = 'Creating NQP with xsltproc failed'
    cmd = 'xsltproc languages/plumhead/src/phc/past_xml_to_past_nqp.xsl  plumhead_phc_past.xml  > plumhead_phc_past.nqp'
    ret = spawnw cmd
    if ret goto ERROR
    source_fn = 'plumhead_phc_past.nqp'
    goto RUN_NQP


VARIANT_ANTLR3:
    err_msg = 'Generating PAST from annotated PHP source failed'
    cmd = 'java PlumheadAntlr3 '
    concat cmd, source_fn
    source_fn = 'plumhead_antlr_past.nqp'
    concat cmd, ' '
    concat cmd, source_fn
    ret = spawnw cmd
    if ret goto ERROR
    goto RUN_NQP

RUN_NQP:
    # compile NQP to PIR
    err_msg = 'Executing NQP failed'
    .local string pir_fn
    .local int ret
    clone pir_fn, source_fn
    substr pir_fn, -3, 3, 'pir'
    cmd = "./parrot ./compilers/nqp/nqp.pbc --target=pir --output="
    concat cmd, pir_fn
    concat cmd, " "
    concat cmd, source_fn
    # say cmd
    ret = spawnw cmd

    # load the generated PIR
    #$S1 = concat "languages/eclectus/", pir_fn
    $S1 = concat "", pir_fn
    load_bytecode $S1

    .local pmc stmts
    ( stmts ) = php_entry()

    # compile and evaluate the PAST returned from scheme_entry()
    .local pmc past_compiler
    past_compiler = new [ 'PCT::HLLCompiler' ]
    $P0 = split ' ', 'post pir'
    past_compiler.'stages'( $P0 )
    $P1 = past_compiler.'eval'(stmts)
    #_dumper ($P1)
    $P0 = split ' ', 'evalpmc'
    past_compiler.'stages'( $P0 )
    past_compiler.'eval'( $P1 )

    exit 0

ERROR:
    printerr err_msg
    printerr "\n"
    # Clean up temporary files
    #.local pmc os
    #os = new .OS
    #os."rm"('plumhead_phc_ast.xml')
    #os."rm"('plumhead_phc_past.xml')
    #os."rm"('plumhead_phc_past.nqp')
    #os."rm"('plumhead_antlr_past.nqp')

FINISH:
   exit ret

.end


# get commandline options
.sub parse_options
    .param pmc argv

    .local string prog
    prog = shift argv

    # Specification of command line arguments.
    # --version, --debug, --inv=nnn, --builtin=name, --nc, --help
    .local pmc getopts
    getopts = new 'Getopt::Obj'
    push getopts, 'version'
    push getopts, 'debug'
    push getopts, 'help'
    push getopts, 'd:%'
    push getopts, 'r=s'
    push getopts, 'f=s'
    push getopts, 'C'
    push getopts, 'variant=s'          # switch between variants
    push getopts, 'target=s'           # relevant for 'Plumhead pct'
    push getopts, 'run-nqp'            # run the nqp generated by the phc and antlr variants

    .local pmc opt
    opt = getopts."get_options"(argv)

    $I0 = defined opt['version']
    unless $I0 goto n_ver
        print prog
        print " "
        print VERSION
        print "\n"
        end
n_ver:
    $I0 = defined opt['help']
    unless $I0 goto n_help
help:
    print "usage: "
    print prog
    print " [options...] [file]\n"
    print "see\n\tperldoc -F "
    print prog
    print "\nfor more\n"
    end

n_help:
    $I0 = defined opt['debug']
    unless $I0 goto n_deb
        print "debugging on\n"
n_deb:

    .local int argc
    .local string rest
    argc = elements argv
    if argc < 1 goto help
    dec argc
    rest = argv[argc]

    .return (opt, rest )
.end

.namespace [ 'Plumhead::Grammar' ]

.include 'src/pct/Plumhead/Grammar.pir'

.include 'src/pct/Plumhead_gen.pir'

.include 'src/pct/PlumheadPAST_gen.pir'

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
