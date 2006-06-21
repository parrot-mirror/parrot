// Copyright (C) 2006, The Perl Foundation.
// $Id$

// Transform ANTLR PAST to PIR that sets up PAST and does the execution

tree grammar AntlrPast2PirPast;

options
{
  ASTLabelType = CommonTree;
  tokenVocab   = 'grammar/antlr_3/BcParser';
}

gen_pir_past 
  :
  {
    String pirBefore =
        "#!/usr/bin/env parrot                                             \n"
      + "                                                                  \n"
      + "# Do not edit this file.                                          \n"
      + "# This file has been generated by Bc.java.                        \n"
      + "                                                                  \n"
      + "  # entering gen_pir_past                                         \n"
      + ".sub bc :main                                                     \n"
      + "  load_bytecode 'languages/punie/lib/ASTGrammar.pir'              \n"
      + "  load_bytecode 'TGE.pbc'                                         \n"
      + "  load_bytecode 'PAST.pbc'                                        \n"
      + "  load_bytecode 'languages/punie/lib/POST.pir'                    \n"
      + "  load_bytecode 'languages/punie/lib/OSTGrammar.pir'              \n"
      + "                                                                  \n"
      + "  # set up register names                                         \n"
      + "  .sym pmc reg_expr_1, reg_expr_2, reg_expr_3, reg_expr_4         \n"
      + "  .sym pmc reg_expr_5, reg_expr_6, reg_expr_7, reg_expr_8         \n"
      + "  .sym pmc reg_expr_9, reg_expr_10                                \n"
      + "                                                                  \n"
      + "  # root of the AST                                               \n"
      + "  .sym pmc stmts                                                  \n"
      + "  stmts = new 'PAST::Stmts'                                       \n"
      + "                                                                  \n"
      ;
    System.out.println( pirBefore );    
  }
  ^(PROGRAM expr+ )
    {
      String pirAfter = 
          "                                                                \n"
        + "  # Compile the abstract syntax tree                            \n"
        + "  # down to an opcode syntax tree                               \n"
        + "  .sym string ost_tg_src                                        \n"
        + "  .sym pmc tge_compiler                                         \n"
        + "  .sym pmc ost_grammar, ost_builder, ost                        \n"
        + "  tge_compiler = new 'TGE::Compiler'                            \n"
        + "  ost_tg_src = _slurp_file('languages/punie/lib/OSTGrammar.tg') \n"
        + "  ost_grammar = tge_compiler.'compile'(ost_tg_src)              \n"
        + "  ost_builder = ost_grammar.apply(stmts)                        \n"
        + "  ost = ost_builder.get('result')                               \n"
        + "  unless ost goto ERR_NO_OST                                    \n"
        + "                                                                \n"
        + "  # Compile the OST down to PIR                                 \n"
        + "  .sym string pir_tg_src                                        \n"
        + "  .sym pmc pir_grammar, pir_builder, pir                        \n"
        + "  pir_tg_src = _slurp_file('languages/punie/lib/PIRGrammar.tg') \n"
        + "  pir_grammar = tge_compiler.'compile'(pir_tg_src)              \n"
        + "  pir_builder = pir_grammar.apply(ost)                          \n"
        + "  pir = pir_builder.get('result')                               \n"
        + "  unless pir goto ERR_NO_PIR                                    \n"
        + "                                                                \n"
        + "  # execute                                                     \n"
        + "  .sym pmc pir_compiler, pir_compiled                           \n"
        + "  pir_compiler = compreg 'PIR'                                  \n"
        + "  pir_compiled = pir_compiler( pir )                            \n"
        + "  pir_compiled()                                                \n"
        + "  say ''                                                        \n"
        + "  goto CLEANUP                                                  \n"
        + "                                                                \n"
        + "  ERR_NO_OST:                                                   \n"
        + "    say 'Unable to construct OST.'                              \n"
        + "    goto CLEANUP                                                \n"
        + "                                                                \n"
        + "  ERR_NO_PIR:                                                   \n"
        + "    say 'Unable to construct PIR.'                              \n"
        + "    goto CLEANUP                                                \n"
        + "                                                                \n"
        + "  CLEANUP:                                                      \n"
        + ".end                                                            \n"
        + "                                                                \n"
        + ".sub _slurp_file                                                \n"
        + "  .param string filename                                        \n"
        + "                                                                \n"
        + "  .sym pmc filehandle                                           \n"
        + "  .sym string content                                           \n"
        + "  filehandle = open filename, '<'                               \n"
        + "  unless filehandle goto ERR_NO_FILE                            \n"
        + "  content = read filehandle, 65535                              \n"
        + "  close filehandle                                              \n"
        + "                                                                \n"
        + "  .return ( content )                                           \n"
        + "                                                                \n"
        + "  ERR_NO_FILE:                                                  \n"
        + "    print 'Unable to open file: '                               \n"
        + "    say filename                                                \n"
        + "    end                                                         \n"
        + "                                                                \n"
        + ".end                                                            \n"
        + "# leaving gen_pir_past                                          \n"
        ;
      System.out.print( pirAfter );    
    }
  ;

expr_int_1
  :
  INT
  ;


expr returns [String reg]
  @init
    {
      $reg = "reg_expr_1";
    }
  :
  expr_int_1
    {
      String pir = 
          "                                                                \n"
        + "# entering 'expr_int_1'                                         \n"
        + "reg_expr_1 = new 'PAST::Val'                                    \n"
        + "reg_expr_1.value( " + $expr_int_1.text + " )                    \n"
        + "reg_expr_1.valtype( 'num' )                                     \n"
        + "# leaving expr                                                  \n"
        + "               reg_expr_2 = new 'PAST::Exp'                     \n"
        + "               reg_expr_2.'add_child'( reg_expr_1 )             \n"
        + "       reg_expr_3 = new 'PAST::Op'                              \n"
        + "       reg_expr_3.'add_child'( reg_expr_2 )                     \n"
        + "       reg_expr_3.'op'( 'print' )                               \n"
        + "               reg_expr_4 = new 'PAST::Exp'                     \n"
        + "               reg_expr_4.'add_child'( reg_expr_3 )             \n"
        + "  reg_expr_5 = new 'PAST::Stmt'                                 \n"
        + "  reg_expr_5.'add_child'( reg_expr_4 )                          \n"
        + "  stmts.'add_child'( reg_expr_5 )                               \n"
        + "               reg_expr_6 = new 'PAST::Val'                     \n"
        + "               reg_expr_6.value( '\\n' )                        \n"
        + "               reg_expr_6.valtype( 'strqq' )                    \n"
        + "               reg_expr_7 = new 'PAST::Exp'                     \n"
        + "               reg_expr_7.'add_child'( reg_expr_6 )             \n"
        + "       reg_expr_8 = new 'PAST::Op'                              \n"
        + "       reg_expr_8.'add_child'( reg_expr_7 )                     \n"
        + "       reg_expr_8.'op'( 'print' )                               \n"
        + "               reg_expr_9 = new 'PAST::Exp'                     \n"
        + "               reg_expr_9.'add_child'( reg_expr_8 )             \n"
        + "  reg_expr_10 = new 'PAST::Stmt'                                \n"
        + "  reg_expr_10.'add_child'( reg_expr_9 )                         \n"
        + "  stmts.'add_child'( reg_expr_10 )                              \n"
        + "# leaving 'expr_int_1'                                          \n"
        + "                                                                \n"
        ;
      System.out.println( pir );    
    }
  ;
