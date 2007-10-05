=head1 TITLE

Perl6Grammar - compiler for Perl 6 grammars

=head1 SYNOPSIS

Command-line:

    parrot Perl6Grammar.pir [options] file ...

From PIR:

    .local string grammar_source
    .local pmc pgc

    pgc = compreg 'PGE::Perl6Grammar'

    # Compile grammar_source to PIR
    $P1 = pgc(grammar_source, 'target' => 'PIR')

    # Compile and install grammar_source
    $P1 = pgc(grammar_source)

=head1 DESCRIPTION

This program takes a set of parser rules (i.e., a parser grammar)
specified in the input C<FILE>s, and compiles it into the PIR code
needed to execute the grammar.  This PIR code is then suitable for
inclusion or compilation into other larger programs.

=head2 Options

=over 4

=item --output=OUTFILE

Send the output to OUTFILE.  By default, output is directed to
the standard output.

=item --encoding=ENCODING

Encoding to use when reading input files.  Defaults to 'ascii', but
can also be set to 'iso-8859-1' or 'utf8'.

=back

=head2 Functions

=over 4

=item C<main(PMC args)>

Processes command line arguments, reads input files, dispatches
to appropriate PIR-generating subroutines, and then sends
the output to the correct output file.

=cut

.namespace [ 'PGE::Perl6Grammar::Compiler' ]

.sub 'main' :main
    .param pmc args
    .local pmc pgc

    pgc = compreg 'PGE::Perl6Grammar'
    pgc.'command_line'(args, 'target'=>'PIR', 'combine'=>1)
    .return ()
.end


.sub '__onload' :load :init
    load_bytecode 'PGE.pbc'
    load_bytecode 'PGE/Text.pbc'
    load_bytecode 'PGE/Util.pbc'
    load_bytecode 'Parrot/HLLCompiler.pbc'

    .local pmc p6regex
    p6regex = compreg 'PGE::Perl6Regex'

    $P0 = get_hll_global ['PGE::Perl6Regex'], 'regex'
    set_hll_global ['PGE::Perl6Grammar'], 'regex', $P0

    $S0 = "<?ident> [ '::' <?ident> ]*"
    p6regex($S0, 'grammar'=>'PGE::Perl6Grammar', 'name'=>'name')

    $S0 = "[ '#' \\N* | \\s+ | <?pod_comment> ]* :::"
    p6regex($S0, 'grammar'=>'PGE::Perl6Grammar', 'name'=>'ws')

    $S0 = <<'      END_POD_COMMENT_RULE'
      ^^ '=' [ [ cut \h*: | end [\h\N*]? ]
           | for [ \h\N+: ] \n [ \N+\n ]*:
           | \w\N*: \n .*? \n '=' [ cut \h*: | end [\h\N*:]? ]
           ]
           [\n|$]
      END_POD_COMMENT_RULE
    p6regex($S0, 'grammar'=>'PGE::Perl6Grammar', 'name'=>'pod_comment')

    $S0 = <<'      END_ARG_RULE'
      $<category>:=[\w+\:]?
      [  \' (<-[']>*:) \'
      | '"' (<-["]>*:) '"'
      | '(' (<-[)]>*:) ')'
      | '<' (<-[>]>*:) '>'
      | '«' (<-[»]>*:) '»'
      | (\S+)
      ]
      END_ARG_RULE
    p6regex($S0, 'grammar'=>'PGE::Perl6Grammar', 'name'=>'arg')

    $S0 = <<'      STMT_PARSE'
        $<cmd>:=(grammar) <name> [ 'is' $<inherit>:=<name> ]? ';'?
      | $<cmd>:=(regex|token|rule)
          $<name>:=<arg>
          $<optable>:=(is optable)?
          [ \{<regex>\} | <?PGE::Util::die: unable to parse regex> ]
      | [multi]? $<cmd>:=(proto)
          $<name>:=<arg>
          ( is $<trait>:=[\w+]['('<arg>')']? )*
          [ \{ <-[}]>*: \} | ';' | <?PGE::Util::die: missing proto/sub body> ]
      | [$|<PGE::Util::die: unrecognized statement>]
      STMT_PARSE
    $P0 = p6regex($S0, 'grammar'=>'PGE::Perl6Grammar', 'name'=>'statement', 'w'=>1)


    ##   create the PGE::Perl6Grammar compiler object
    .local pmc pgc
    $P99 = subclass 'HLLCompiler', 'PGE::Perl6Grammar::Compiler'
    pgc = new [ 'PGE::Perl6Grammar::Compiler' ]
    pgc.'language'('PGE::Perl6Grammar')
.end


.sub 'compile' :method
    .param pmc source
    .param pmc adverbs         :slurpy :named

    .local pmc nstable, namespace
    nstable = new 'Hash'
    namespace = new 'String'
    $P0 = new 'Hash'
    $P1 = new 'CodeString'
    $P0['optable'] = $P1
    $P1 = new 'CodeString'
    $P0['rule'] = $P1
    nstable[''] = $P0

    # get our initial match object
    .local pmc match
    $P0 = get_hll_global ['PGE'], 'Match'
    match = $P0.'new'(source, 'grammar'=>'PGE::Perl6Grammar')

    .local pmc stmtrule
    stmtrule = get_hll_global ['PGE::Perl6Grammar'], 'statement'

  stmt_loop:
    match = stmtrule(match)
    unless match goto stmt_end
    unless match > '' goto stmt_end
    $S0 = match['cmd']
    concat $S0, '_stmt'
    $P0 = find_name $S0
    $P0(match, namespace, nstable)
    goto stmt_loop
  stmt_end:

    .local pmc initpir, rulepir, iter, ns
    .local string namespace
    initpir = new 'CodeString'
    rulepir = new 'CodeString'
    iter = new 'Iterator', nstable
  iter_loop:
    unless iter goto iter_end
    namespace = shift iter
    ns = iter[namespace]
    $P0 = ns['rule']
    rulepir .= $P0
    if namespace == 'PGE::Grammar' goto ns_optable
    if namespace == '' goto ns_optable
    .local string inherit
    inherit = ns['inherit']
    $S0 = initpir.unique('onload_')
    initpir.emit(<<'        CODE', namespace, inherit, $S0)
          ## namespace %0
          push_eh %2
          $P0 = subclass '%1', '%0'
          clear_eh
        %2:
        CODE
  ns_optable:
    $P0 = ns['optable']
    if $P0 == '' goto iter_loop
    initpir.emit("          optable = new 'PGE::OPTable'")
    initpir.emit("          set_hll_global ['%0'], '$optable', optable", namespace)
    initpir .= $P0
    goto iter_loop
  iter_end:

    .local pmc out
    out = new 'CodeString'
    if initpir == '' goto out_rule
    out.emit("      .sub '__onload' :load :init")
    out.emit("          .local pmc optable")
    out .= initpir
    out.emit("          .return ()")
    out.emit("      .end")
  out_rule:
    out .= rulepir

    .local string target
    target = adverbs['target']
    target = downcase target
    if target != 'pir' goto compile_pir
    .return (out)

  compile_pir:
    $P0 = compreg 'PIR'
    .return $P0(out)
.end


.sub 'grammar_stmt'
    .param pmc stmt
    .param pmc namespace
    .param pmc nstable

    ##   get the grammar name
    .local string name, inherit
    name = stmt['name']
    inherit = 'PGE::Grammar'
    $P0 = stmt['inherit']
    if null $P0 goto have_inherit
    inherit = $P0[0]
  have_inherit:

    ##   set the new namespace, and create any nstable entries
    ##   if needed.
    assign namespace, name
    name = clone name
    $I0 = exists nstable[name]
    if $I0 goto end
    .local pmc ns
    ns = new 'Hash'
    ns['inherit'] = inherit
    $P1 = new 'CodeString'
    ns['optable'] = $P1
    $P1 = new 'CodeString'
    ns['rule'] = $P1
    nstable[name] = ns

  end:
    .return ()
.end

.sub 'regex_stmt'
    .param pmc stmt
    .param pmc namespace
    .param pmc nstable

    ##   get the regex name
    .local string name
    $P0 = stmt['name']
    $S0 = $P0['category']
    $S1 = $P0[0]
    name = concat $S0, $S1

    ##   set compile adverbs
    .local pmc adverbs
    adverbs = new 'Hash'
    adverbs['grammar'] = namespace
    adverbs['name'] = name

    ##   handle options for 'token' and 'rule' commands
    $S0 = stmt['cmd']
    if $S0 == 'regex' goto with_adverbs
    adverbs['ratchet'] = 1
    if $S0 == 'token' goto with_adverbs
    adverbs['words'] = 1
  with_adverbs:

    $I0 = exists stmt['optable']
    if $I0 goto rulepir_optable
    ##   compile the rule to pir
    .local pmc p6regex, regex, rulepir
    p6regex = compreg 'PGE::Perl6Regex'
    regex = stmt['regex']
    rulepir = p6regex(regex, 'target'=>'PIR', adverbs :flat :named)
    goto with_rulepir
  rulepir_optable:
    ##   this is a special rule generated via the 'is optable' trait
    rulepir = new 'CodeString'
    rulepir.emit(<<'      END', namespace, name)
      .namespace [ "%0" ]
      .sub "%1"
        .param pmc mob
        .param pmc adverbs :named :slurpy
        $P0 = get_hll_global ["%0"], "$optable"
        .return $P0.'parse'(mob, 'rulename'=>"%1", adverbs :named :flat)
      .end
      END
  with_rulepir:

    ##   add to set of rules
    .local pmc code
    $P0 = nstable[namespace]
    code = $P0['rule']
    code.emit("\n## <%0::%1>\n", namespace, name)
    code .= rulepir
    .return ()
.end

.sub 'token_stmt'
    .param pmc stmt
    .param pmc namespace
    .param pmc nstable
    .return 'regex_stmt'(stmt, namespace, nstable)
.end

.sub 'rule_stmt'
    .param pmc stmt
    .param pmc namespace
    .param pmc nstable
    .return 'regex_stmt'(stmt, namespace, nstable)
.end


.sub 'proto_stmt'
    .param pmc stmt
    .param pmc namespace
    .param pmc nstable

    .local string name
    $P0 = stmt['name']
    $S0 = $P0['category']
    $S1 = $P0[0]
    name = concat $S0, $S1

    .local pmc optable
    $P0 = nstable[namespace]
    optable = $P0['optable']

    ##   build the list of traits
    .local pmc iter
    .local string traitlist
    $P0 = stmt[0]
    iter = new 'Iterator', $P0
    traitlist = ''
  trait_loop:
    unless iter goto trait_end
    .local pmc t
    t = shift iter
    .local string trait, arg
    trait = t['trait']
    $P0 = t['arg']
    if null $P0 goto trait_arg_null
    ##   convert parsed arg to single string
    $P0 = $P0[0]
    $S0 = $P0['category']
    $S1 = $P0[0]
    arg = concat $S0, $S1
    if arg == '' goto trait_arg_null
    ##   args starting with & are symbol lookups
    $S0 = substr arg, 0, 1
    if $S0 != '&' goto trait_arg
    arg = substr arg, 1
    goto trait_sub
  trait_arg:
    if trait == 'parsed' goto trait_sub
    arg = concat "'", arg
    arg = concat arg, "'"
    goto trait_arg_done
  trait_sub:
    optable.emit("          $P0 = get_hll_global ['%0'], '%1'", namespace, arg)
    arg = '$P0'
    goto trait_arg_done
  trait_arg_null:
    arg = '1'
  trait_arg_done:
    concat traitlist, ", '"
    concat traitlist, trait
    concat traitlist, "'=>"
    concat traitlist, arg
    goto trait_loop
  trait_end:
    optable.emit("          optable.newtok('%0'%1)", name, traitlist)
  .return ()
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
