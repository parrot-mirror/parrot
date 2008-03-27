// Copyright (C) 2006-2008, The Perl Foundation.
// $Id$

// Transform ANTLR PAST to PIR that sets up a PAST data structure
// Let the Parrot Compiler Tools handle the execution.
// Jumpstarted by languages/bc/grammar/antlr_3/antlr_past2pir_past.g 

tree grammar GenPastPir;

options
{
  ASTLabelType = CommonTree;
  tokenVocab   = Plumhead;      // Token file is found because of '-lib' option
}


@header 
{
  import java.util.regex.*;
}

@members
{
  // used for generating unique register names
  public static int reg_num = 200;
}

gen_pir_past 
  : {
      System.out.println( 
          "#!/usr/bin/env parrot                                                  \n"
        + "                                                                       \n"
        + "# Do not edit this file.                                               \n"
        + "# This file has been generated by GenPastPir.g                         \n"
        + "                                                                       \n"
        + ".sub 'php_init' :load :init                                            \n"
        + "                                                                       \n"
        + "    load_bytecode 'PGE.pbc'                                            \n"
        + "    load_bytecode 'PGE/Text.pbc'                                       \n"
        + "    load_bytecode 'PGE/Util.pbc'                                       \n"
        + "    load_bytecode 'PGE/Dumper.pbc'                                     \n"
        + "    load_bytecode 'PCT.pbc'                                            \n"
        + "    load_bytecode 'languages/plumhead/src/common/plumheadlib.pbc'      \n"
        + "    load_bytecode 'MIME/Base64.pbc'                                    \n"
        + "    load_bytecode 'dumper.pbc'                                         \n"
        + "    load_bytecode 'CGI/QueryHash.pbc'                                  \n"
        + "                                                                       \n"
        + ".end                                                                   \n"
        + "                                                                       \n"
        + "                                                                       \n"
        + ".sub plumhead :main                                                    \n"
        + "                                                                       \n"
        + "    # look for subs in other namespaces                                \n"
        + "    .local pmc decode_base64_sub, parse_get_sub, parse_post_sub        \n"
        + "    decode_base64_sub = get_global [ 'MIME'; 'Base64' ], 'decode_base64'  \n"
        + "    parse_get_sub     = get_global [ 'CGI'; 'QueryHash' ], 'parse_get'    \n"
        + "    parse_post_sub    = get_global [ 'CGI'; 'QueryHash' ], 'parse_post'   \n"
        + "                                                                       \n"
        + "    # the superglobals                                                 \n"
        + "    .local pmc superglobal_GET                                         \n"
        + "    ( superglobal_GET ) = parse_get_sub()                              \n"
        + "    set_global '_GET', superglobal_GET                                 \n"
        + "                                                                       \n"
        + "    .local pmc superglobal_POST                                        \n"
        + "    ( superglobal_POST ) = parse_post_sub()                            \n"
        + "    set_global '_POST', superglobal_POST                               \n"
        + "                                                                       \n"
        + "    # The root node of PAST.                                           \n"
        + "    .local pmc past_root                                               \n"
        + "    past_root  = new 'PAST::Block'                                     \n"
        + "    past_root.init('name' => 'plumhead_main')                          \n"
        + "                                                                       \n"
        + "    .local pmc past_stmts                                              \n"
        + "    past_stmts = new 'PAST::Stmts'                                     \n"
        + "                                                                       \n"
        + "    .local pmc past_temp                                               \n"
        + "    .local pmc past_name                                               \n"
        + "    .local pmc past_if_op                                              \n"
        + "                                                                       \n"
      );
    }
    ^( PROGRAM node["past_stmts"]* )
    {
      System.out.println( 
          "                                                                  \n"
        + "                                                                  \n"
        + "    past_root.'push'( past_stmts )                                \n"
        + "                                                                  \n"
        + "    .local pmc past_compiler                                      \n"
        + "    past_compiler = new [ 'PCT::HLLCompiler' ]                    \n"
        + "    $P0 = split ' ', 'post pir evalpmc'                           \n"
        + "    past_compiler.'stages'( $P0 )                                 \n"
        + "    past_compiler.'eval'(past_root)                               \n"
        + "                                                                  \n"
        + ".end                                                              \n"
        + "                                                                  \n"
      );
    }
  ;

node[String reg_mother]
  : {
      System.out.println( 
          "                                                                  \n"
        + "  # start of ECHO node                                            \n"
        + "  .local pmc past_echo                                            \n"
        + "  past_echo = new 'PAST::Op'                                      \n"
      );
    }
    ^( ECHO node["past_echo"] )
    {
      System.out.println( 
          "                                                                  \n"
        + "  past_echo.'attr'( 'name', 'echo', 1 )                           \n"
        + "  " + $node.reg_mother + ".'push'( past_echo )                    \n"
        + "  # end of ECHO node                                              \n"
      );
    }
  | {
      System.out.println( 
          "                                                                  \n"
        + "  # start of VAR_DUMP node                                        \n"
        + "  .local pmc past_var_dump                                        \n"
        + "  past_var_dump = new 'PAST::Op'                                  \n"
      );
    }
    ^( VAR_DUMP node["past_var_dump"] )
    {
      System.out.println( 
          "                                                                  \n"
        + "  past_var_dump.'attr'( 'name', 'var_dump', 1 )                   \n"
        + "  " + $node.reg_mother + ".'push'( past_var_dump )                \n"
        + "  # end of VAR_DUMP node                                          \n"
      );
    }
  | NOQUOTE_STRING
    {
      String noquote = $NOQUOTE_STRING.text;
      noquote = noquote.replace( "\n", "\\n" );
      System.out.println( 
          "                                                                  \n"
        + "  # start of NOQUOTE_STRING                                       \n"
        + "  .local string val                                               \n"
        + "  val = \"" + noquote + "\"                                       \n"
        + "  past_temp = new 'PAST::Val'                                     \n"
        + "  .local pmc code_string                                          \n"
        + "  code_string = new 'CodeString'                                  \n"
        + "  ( val ) = code_string.'escape'( val )                           \n"
        + "      past_temp.'init'( 'value' => val, 'returns' => 'Undef' )    \n"
        + "  " + $node.reg_mother + ".'push'( past_temp )                    \n"
        + "  # end of NOQUOTE_STRING                                         \n"
        + "                                                                  \n"
      );
    }
  | SINGLEQUOTE_STRING
    {
      String singlequote = $SINGLEQUOTE_STRING.text;
      singlequote = singlequote.replace( "\n", "\\n" );
      System.out.println( 
          "                                                                  \n"
        + "  # start of SINGLEQUOTE_STRING                                   \n"
        + "  .local string val                                               \n"
        + "  val = " + singlequote + "                                       \n"
        + "  past_temp = new 'PAST::Val'                                     \n"
        + "  .local pmc code_string                                          \n"
        + "  code_string = new 'CodeString'                                  \n"
        + "  ( val ) = code_string.'escape'( val )                           \n"
        + "      past_temp.'init'( 'value' => val, 'returns' => 'Undef' )    \n"
        + "  " + $node.reg_mother + ".'push'( past_temp )                    \n"
        + "  # end of SINGLEQUOTE_STRING                                     \n"
        + "                                                                  \n"
      );
    }
  | DOUBLEQUOTE_STRING
    {
      String doublequote = $DOUBLEQUOTE_STRING.text;
      doublequote = doublequote.replace( "\n", "\\n" );
      System.out.println( 
          "                                                                  \n"
        + "  # start of DOUBLEQUOTE_STRING                                   \n"
        + "  .local string val                                               \n"
        + "  val = " + doublequote + "                                      \n"
        + "  past_temp = new 'PAST::Val'                                     \n"
        + "  .local pmc code_string                                          \n"
        + "  code_string = new 'CodeString'                                  \n"
        + "  ( val ) = code_string.'escape'( val )                           \n"
        + "      past_temp.'init'( 'value' => val, 'returns' => 'Undef' )    \n"
        + "  " + $node.reg_mother + ".'push'( past_temp )                    \n"
        + "  # end of DOUBLEQUOTE_STRING                                     \n"
        + "                                                                  \n"
      );
    }
  | NUMBER
    {
      System.out.println( 
          "                                                                  \n"
        + "  # start of NUMBER                                               \n"
        + "  past_temp = new 'PAST::Val'                                     \n"
        + "      past_temp.'attr'( 'value', '" + $NUMBER.text + "', 1 )      \n"
        + "      past_temp.'attr'( 'returns', 'Float', 1 )                   \n"
        + "  " + $node.reg_mother + ".'push'( past_temp )                    \n"
        + "  # end of NUMBER                                                 \n"
      );
    }
  | INTEGER
    {
      System.out.println( 
          "                                                                  \n"
        + "  # start of INTEGER                                              \n"
        + "  past_temp = new 'PAST::Val'                                     \n"
        + "      past_temp.'attr'( 'value', '" + $INTEGER.text + "', 1 )     \n"
        + "      past_temp.'attr'( 'returns', 'Integer', 1 )                 \n"
        + "  " + $node.reg_mother + ".'push'( past_temp )                    \n"
        + "  # end of INTEGER                                                \n"
      );
    }
  | {
      reg_num++;
      String reg = "reg_" + reg_num;
      System.out.print( 
          "                                                                   \n"
        + "    # entering PLUS | MINUS | MUL_OP | BITWISE_OP                  \n"
        + "      .local pmc " + reg + "                                       \n"
        + "      " + reg + " = new 'PAST::Op'                                 \n"
      );
    }
    ^( infix=( PLUS | MINUS | MUL_OP | BITWISE_OP ) node[reg] node[reg] )
    {
      // Todo. This is not nice, handle pirops in Plumhead.g
      String op = $infix.text;
      String pirop = "";
      if      ( op.equals( "+" ) )  { pirop = "n_add"; }
      else if ( op.equals( "-" ) )  { pirop = "n_sub"; }
      else if ( op.equals( "/" ) )  { pirop = "n_div"; }
      else if ( op.equals( "*" ) )  { pirop = "n_mul"; }
      else if ( op.equals( "\%" ) ) { pirop = "n_mod"; }
      
      String name = op;
      if      ( op.equals( "&" ) )  { name = "+&"; }
      else if ( op.equals( "|" ) )  { name = "+|"; }
      else if ( op.equals( "^" ) )  { name = "+^"; }
      name = "infix:" + name;

      System.out.print( 
          "  " + reg + ".'attr'( 'pirop', '" + pirop + "', 1 )                \n"
        + "  " + reg + ".'attr'( 'name',  '" + name + "' , 1 )                \n"
        + "  " + reg + ".'attr'( 'lvalue',  0 , 1 )                           \n"
        + "  " + $node.reg_mother + ".'push'( " + reg + " )                   \n"
        + "    # leaving PLUS | MINUS | MUL_OP | BITWISE_OP                   \n"
      );
    }
  | {
      reg_num++;
      String reg = "reg_" + reg_num;
      System.out.print( 
          "                                                                   \n"
        + "    # entering PREFIX                                              \n"
        + "      .local pmc " + reg + "                                       \n"
        + "      " + reg + " = new 'PAST::Op'                                 \n"
      );
    }
    ^( prefix=PREFIX node[reg] )
    {
      // Todo. This is not nice, handle pirops in Plumhead.g
      String op = $prefix.text;
      
      String name = op;
      name = "prefix:" + name;

      System.out.print( 
          "  " + reg + ".'attr'( 'name',  '" + name + "' , 1 )                \n"
        + "  " + $node.reg_mother + ".'push'( " + reg + " )                   \n"
        + "    # leaving PREFIX                                               \n"
      );
    }
  | {
      reg_num++;
      String reg = "reg_" + reg_num;
      System.out.print( 
          "                                                                   \n"
        + "    # entering REL_OP                                              \n"
        + "      .local pmc " + reg + "                                       \n"
        + "      " + reg + " = new 'PAST::Op'                                 \n"
      );
    }
    ^( REL_OP node[reg] node[reg] )
    {
      // Todo. This is not nice, handle pirops in Plumhead.g
      String name = $REL_OP.text;
      if      ( name.equals( "==" ) )  { name = "eq"; }
      else if ( name.equals( "!=" ) )  { name = "ne"; }
      name = "infix:" + name;
      
      System.out.print( 
          "  " + reg + ".'attr'( 'name', '" + name + "' , 1 )               \n"
        + "  " + $node.reg_mother + ".'push'( " + reg + " )                 \n"
        + "    # leaving REL_OL                                              \n"
      );
    }
  | {
      reg_num++;
      String reg_exp   = "reg_expression_" + reg_num;
      System.out.print( 
          "                                                                   \n"
        + "  # entering IF                                                    \n"
        + "      past_if_op = new 'PAST::Op'                                  \n"
        + "      past_if_op.'attr'( 'pasttype', 'if' , 1 )                    \n"
        + "        .local pmc " + reg_exp + "                                 \n"
        + "        " + reg_exp + " = new 'PAST::Block'                        \n"
        + "                                                                   \n"
      );
    }
    ^( IF node["past_if_op"] node["past_if_op"] node["past_if_op"]? )
    {
      System.out.print( 
          "                                                                   \n"
        + "  " + $node.reg_mother + ".'push'( past_if_op )                     \n"
        + "  # leaving IF                                                     \n"
      );
    }
  | {
      reg_num++;
      String reg_stmts = "reg_stmts_" + reg_num;
      System.out.print( 
          "                                                                   \n"
        + "    # entering STMTS                                               \n"
        + "        .local pmc " + reg_stmts + "                               \n"
        + "        " + reg_stmts + " = new 'PAST::Stmts'                      \n"
      );
    }
    ^( STMTS node[reg_stmts]* )
    {
      System.out.print( 
          "  " + $node.reg_mother + ".'push'( " + reg_stmts + " )             \n"
        + "  # leaving 'STMTS node*'                                          \n"
      );
    }
  | {
      reg_num++;
      String reg_assign = "reg_assign_" + reg_num;
      System.out.print( 
          "                                                                   \n"
        + "    # entering ASSIGN_OP                                           \n"
        + "    .local pmc " + reg_assign + "                                  \n"
        + "    " + reg_assign + " = new 'PAST::Op'                            \n"
        + "    " + reg_assign + ".init( 'name' => 'infix:=', 'pasttype' => 'assign' ) \n"
      );
    }
    ^( ASSIGN_OP node[reg_assign] node[reg_assign] )
    {
      System.out.print( 
          "  " + $node.reg_mother + ".'push'( " + reg_assign + " )            \n"
        + "  # leaving ASSIGN_OP                                              \n"
      );
    }
  | SCALAR
    {
      System.out.println( 
          "                                                                  \n"
        + "  # entering SCALAR                                               \n"
        + "  past_temp = new 'PAST::Var'                                     \n"
        + "      past_temp.'init'( 'name' => '" + $SCALAR.text + "', 'scope' => 'package', 'viviself' => 'Undef', 'lvalue' => 1 )      \n"
        + "  " + $node.reg_mother + ".'push'( past_temp )                    \n"
        + "  # leaving SCALAR                                                \n"
      );
    }
  | {
      reg_num++;
      String reg_array = "reg_array_" + reg_num;
      System.out.print( 
          "                                                                  \n"
        + "    # entering ARRAY                                              \n"
        + "    .local pmc " + reg_array + "                                  \n"
        + "    " + reg_array + " = new 'PAST::Var'                           \n"
        + "    " + reg_array + ".init( 'scope' => 'keyed', 'viviself' => 'Undef', 'lvalue' => 1 ) \n"
      );
    }
    ^( ARRAY node[reg_array] )
    {
      System.out.println( 
          "                                                                  \n"
        + "  past_name = new 'PAST::Var'                                     \n"
        + "  past_name.'init'( 'name' => '" + $ARRAY.text + "', 'scope' => 'package', 'viviself' => 'Hash', 'lvalue' => 1 )      \n"
        + "  # PAST has probably no unshift yet                              \n"
        + "  \$P0 = " + reg_array + ".'get_array'()                          \n"
        + "  unshift \$P0, past_name                                         \n"
        + "  " + $node.reg_mother + ".'push'( " + reg_array + " )            \n"
        + "  # leaving ARRAY                                                 \n"
      );
    }
  ;
