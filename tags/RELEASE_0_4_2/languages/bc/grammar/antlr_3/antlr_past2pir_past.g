// Copyright: 2006 The Perl Foundation.  All Rights Reserved.
// $Id$

// Transform ANTLR PAST to PIR that sets up PAST

tree grammar AntlrPast2PirPast;

options
{
  ASTLabelType = CommonTree;
  tokenVocab   = 'grammar/antlr_3/BcParser';
}

// XXX I can't find this in the generated Java code, a bug in ANTLR3 ea7?
@members 
{
  int asdf = 200;
}

gen_pir_past 
  :
  {
    String pirBefore
        =   "#!/usr/bin/env parrot\n"
          + "\n"
          + "# Do not edit this file.\n"
          + "# This file has been generated by Bc.java.\n"
          + "\n"
          + ".sub bc :main\n"
          + "  load_bytecode 'languages/punie/lib/PAST.pir'\n"
          + "  load_bytecode 'TGE.pbc'\n"
          + "  load_bytecode 'languages/punie/lib/POST.pir'\n"
          + "\n"
          + "  .local pmc stmts_children\n"
          + "  stmts_children = new PerlArray\n";

    System.out.println( pirBefore );    
  }
    ^(PROGRAM expr)
    {
      String pirAfter
        =   "               \$P20 = new 'PAST::Exp' \n"
          + "               \$P21 = new PerlArray \n"
          + "               push \$P21, \$P" + $expr.reg + " \n"
          + "               \$P20.set_node('1', 1, \$P21) \n"
          + "       \$P30 = new 'PAST::Op' \n"
          + "       \$P31 = new PerlArray \n"
          + "       push \$P31, \$P20 \n"
          + "       \$P30.set_node('1', 1, 'print' ,\$P31) \n"
          + "               \$P40 = new 'PAST::Exp' \n"
          + "               \$P41 = new PerlArray \n"
          + "               push \$P41, \$P30 \n"
          + "               \$P40.set_node('1', 1, \$P41) \n"
          + "  \$P50 = new 'PAST::Stmt' \n"
          + "  \$P51 = new PerlArray \n"
          + "  push \$P51, \$P40 \n"
          + "  \$P50.set_node('1', 1 ,\$P51) \n"
          + "  push stmts_children, \$P50 \n"
          + "               \$P60 = new 'PAST::Val' \n"
          + "               \$P60.set_node( '1', 0, '\\n' ) \n"
          + "               \$P60.valtype( 'strqq' ) \n"
          + "               \$P70 = new 'PAST::Exp' \n"
          + "               \$P71 = new PerlArray \n"
          + "               push \$P71, \$P60 \n"
          + "               \$P70.set_node('1', 1, \$P71) \n"
          + "       \$P80 = new 'PAST::Op' \n"
          + "       \$P81 = new PerlArray \n"
          + "       push \$P81, \$P70 \n"
          + "       \$P80.set_node('1', 1, 'print' ,\$P81) \n"
          + "               \$P90 = new 'PAST::Exp' \n"
          + "               \$P91 = new PerlArray \n"
          + "               push \$P91, \$P80 \n"
          + "               \$P90.set_node('1', 1, \$P91) \n"
          + "  \$P100 = new 'PAST::Stmt' \n"
          + "  \$P101 = new PerlArray \n"
          + "  push \$P101, \$P90 \n"
          + "  \$P100.set_node('1', 1 ,\$P101) \n"
          + "  push stmts_children, \$P100 \n"
          + "\n"
          + "  .local pmc stmts\n"
          + "  stmts = new 'PAST::Stmts'\n"
          + "  stmts.set_node('1', 1, stmts_children)\n"
          + "\n"
          + "  # Compile the abstract syntax tree down to an opcode syntax tree\n"
          + "  .local string ost_tg_source\n"
          + "  ost_tg_source = _slurp_file('languages/punie/lib/past2post.g')\n"
          + "  .local pmc ostgrammar\n"
          + "  ostgrammar = new 'TGE'\n"
          + "  ostgrammar.agcompile(ost_tg_source)\n"
          + "  .local pmc ostbuilder\n"
          + "  ostbuilder = ostgrammar.apply(stmts)\n"
          + "  .local pmc ost\n"
          + "  ost = ostbuilder.get('result')\n"
          + "  \$I0 = defined ost\n"
          + "  unless \$I0 goto err_no_ost # if OST fails stop\n"
          + "\n"
          + "  # Compile the OST down to PIR\n"
          + "  .local string pir_tg_source\n"
          + "  pir_tg_source = _slurp_file('languages/punie/lib/post2pir.g')\n"
          + "  .local pmc pirgrammar\n"
          + "  pirgrammar = new 'TGE'\n"
          + "  pirgrammar.agcompile(pir_tg_source)\n"
          + "  .local pmc pirbuilder\n"
          + "  pirbuilder = pirgrammar.apply(ost)\n"
          + "  .local pmc pir\n"
          + "  pir = pirbuilder.get('result')\n"
          + "  unless pir goto err_no_pir # if PIR not generated, stop\n"
          + "\n"
          + "  # Execute\n"
          + "  .local pmc pir_compiler\n"
          + "  .local pmc pir_compiled\n"
          + "  pir_compiler = compreg \"PIR\"\n"
          + "  pir_compiled = pir_compiler( pir )\n"
          + "\n"
          + "  pir_compiled()\n"
          + "\n"
          + "  print \"\\n\"\n"
          + "\n"
          + "  end\n"
          + "\n"
          + "  err_match_fail:\n"
          + "    print \"parse failed\\n\"\n"
          + "    goto cleanup\n"
          + "\n"
          + "  err_no_ast:\n"
          + "    print 'Unable to construct AST.'\n"
          + "    goto cleanup\n"
          + "\n"
          + "  err_no_ost:\n"
          + "    print 'Unable to construct OST.'\n"
          + "    goto cleanup\n"
          + "\n"
          + "  err_no_pir:\n"
          + "    print 'Unable to construct PIR.'\n"
          + "    goto cleanup\n"
          + "\n"
          + "  cleanup:\n"
          + ".end\n"
          + "\n"
          + ".sub _slurp_file\n"
          + "  .param string filename\n"
          + "  .local pmc filehandle\n"
          + "  filehandle = open filename, '<'\n"
          + "  unless filehandle goto err_no_file\n"
          + "  \$S1 = read filehandle, 65535\n"
          + "  close filehandle\n"
          + "  .return (\$S1)\n"
          + "  err_no_file:\n"
          + "    print 'Unable to open file: '\n"
          + "    print filename\n"
          + "    end\n"
          + ".end\n";

       System.out.print( pirAfter );    
    }
  ;

expr_int_1
  : INT
  ;


expr returns [int reg]
  @init
  {
    $reg = 10;
  }
  : expr_int_1
    {
      String pir
        =   "               \$P" + $reg + " = new 'PAST::Val' \n"
          + "               \$P" + $reg + ".set_node( '1', 0, " + $expr_int_1.text + " ) \n"
          + "               \$P" + $reg + ".valtype( 'num' ) \n";
      System.out.println( pir );    
    }
  ;
