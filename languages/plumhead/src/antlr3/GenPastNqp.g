// Copyright (C) 2006-2008, The Perl Foundation.
// $Id$

// Transform ANTLR PAST to NQP that sets up a PAST data structure
// Let the Parrot Compiler Tools handle the execution.

tree grammar GenPastNqp;

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
  // used for generating unique register names, TODO: remove
  public static int reg_num = 200;
}

gen_past_nqp 
  : {
      System.out.println( 
          "#!/usr/bin/env parrot                                                  \n"
        + "                                                                       \n"
        + "# Do not edit this file.                                               \n"
        + "# This file has been generated by GenPastNqp.g                         \n"
        + "                                                                       \n"
        + "sub php_entry ()                                                       \n"
        + "{                                                                      \n"
        + "    PAST::Block.new(                                                   \n"
        + "        PAST::Stmts.new(                                               \n"
        + "                                                                       \n"
        + "               PAST::Op.new(                                           \n"
        + "                 :name( 'echo' ),                                      \n"
        + "                                                                       \n"
        + "                     PAST::Op.new(                                     \n"
        + "                     :pirop( 'n_mod' ),                                \n"
        + "                     :name( 'infix:\%' ),                               \n"
        + "                                                                       \n"
        + "                           PAST::Val.new(                              \n"
        + "                         :returns( 'Integer' ),                        \n"
        + "                         :value( '2' ),                                \n"
        + "                     ),                                                \n"
        + "                                                                       \n"
        + "                           PAST::Val.new(                              \n"
        + "                         :returns( 'Integer' ),                        \n"
        + "                         :value( '2' ),                                \n"
        + "                     ),                                                \n"
        + "                                                                       \n"
        + "                     ),                                                \n"
        + "                                                                       \n"
        + "               ),                                                      \n"
        + "                                                                       \n"
        + "               PAST::Op.new(                                           \n"
        + "                 :name( 'echo' ),                                      \n"
        + "                                                                       \n"
        + "                     PAST::Val.new(                                    \n"
        + "                     :returns( 'String' ),                             \n"
        + "                     :value( decode_base64( 'Cg==' ) ),                \n"
        + "                 ),                                                    \n"
        + "                                                                       \n"
        + "               ),                                                      \n"
        + "                                                                       \n"
        + "                                                                       \n"
        + "        )                                                              \n"
        + "    );                                                                 \n"
      );
    }
    ^( PROGRAM node["past_stmts"]* )
    {
      System.out.println( 
          "                                                                       \n"
        + "}                                                                      \n"
      );
    }
  ;

node[String reg_mother]
  : {
      System.out.println( 
          "                                                                  \n"
      );
    }
    ^( ECHO node["past_echo"] )
    {
      System.out.println( 
          "                                                                  \n"
      );
    }
  | {
      System.out.println( 
          "                                                                  \n"
      );
    }
    ^( VAR_DUMP node["past_var_dump"] )
    {
      System.out.println( 
          "                                                                  \n"
      );
    }
  | NOQUOTE_STRING
    {
      String noquote = $NOQUOTE_STRING.text;
      noquote = noquote.replace( "\n", "\\n" );
      System.out.println( 
          "                                                                  \n"
      );
    }
  | SINGLEQUOTE_STRING
    {
      String singlequote = $SINGLEQUOTE_STRING.text;
      singlequote = singlequote.replace( "\n", "\\n" );
      System.out.println( 
          "                                                                  \n"
      );
    }
  | DOUBLEQUOTE_STRING
    {
      String doublequote = $DOUBLEQUOTE_STRING.text;
      doublequote = doublequote.replace( "\n", "\\n" );
      System.out.println( 
          "                                                                  \n"
      );
    }
  | NUMBER
    {
      System.out.println( 
          "                                                                  \n"
      );
    }
  | INTEGER
    {
      System.out.println( 
          "                                                                  \n"
      );
    }
  | {
      reg_num++;
      String reg = "reg_" + reg_num;
      System.out.print( 
          "                                                                   \n"
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

      System.out.print(  " " ); 
    }
  | {
      reg_num++;
      String reg = "reg_" + reg_num;
      System.out.print( 
          "                                                                   \n"
      );
    }
    ^( prefix=PREFIX node[reg] )
    {
      // Todo. This is not nice, handle pirops in Plumhead.g
      String op = $prefix.text;
      
      String name = op;
      name = "prefix:" + name;

      System.out.print( 
          "                                                                   \n"
      );
    }
  | {
      reg_num++;
      String reg = "reg_" + reg_num;
      System.out.print( 
          "                                                                   \n"
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
      );
    }
  | {
      reg_num++;
      String reg_exp   = "reg_expression_" + reg_num;
      System.out.print( 
          "                                                                   \n"
      );
    }
    ^( IF node["past_if_op"] node["past_if_op"] node["past_if_op"]? )
    {
      System.out.print( 
          "                                                                   \n"
      );
    }
  | {
      reg_num++;
      String reg_stmts = "reg_stmts_" + reg_num;
      System.out.print( 
          "                                                                   \n"
      );
    }
    ^( STMTS node[reg_stmts]* )
    {
      System.out.print( " " ); 
    }
  | {
      reg_num++;
      String reg_assign = "reg_assign_" + reg_num;
      System.out.print( 
          "                                                                   \n"
      );
    }
    ^( ASSIGN_OP node[reg_assign] node[reg_assign] )
    {
      System.out.println( 
          "                                                                  \n"
      );
    }
  | SCALAR
    {
      System.out.println( 
          "                                                                  \n"
      );
    }
  | {
      reg_num++;
      String reg_array = "reg_array_" + reg_num;
      System.out.print( 
          "                                                                  \n"
      );
    }
    ^( ARRAY node[reg_array] )
    {
      System.out.println( 
          "                                                                  \n"
      );
    }
  ;
