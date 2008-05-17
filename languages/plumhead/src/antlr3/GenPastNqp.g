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

gen_past_nqp 
  : {
      System.out.println( 
          "\n"
        + "# Do not edit this file.\n"
        + "# This file has been generated by GenPastNqp.g.\n"
        + "\n"
        + "sub php_entry ()\n"
        + "{\n"
        + "    PAST::Block.new(\n"
      );
    }
    ^( PROGRAM node* )
    {
      System.out.println( 
          "\n"
        + "    );\n"
        + "}\n"
      );
    }
  ;

node
  : {
      System.out.println( 
          "    PAST::Op.new(                                                   \n"
        + "       :name( 'echo' ),                                             \n"
      );
    }
    ^( ECHO node )
    {
      System.out.println(  
          "    ),                                                            \n"
      );
    }
  | {
      System.out.println( 
          "    PAST::Op.new(                                                   \n"
        + "       :name( 'var_dump' ),                                             \n"
      );
    }
    ^( VAR_DUMP node )
    {
      System.out.println(  
          "    ),                                                            \n"
      );
    }
  | NOQUOTE_STRING
    {
      String noquote = $NOQUOTE_STRING.text;
      noquote = noquote.replace( "\n", "\\n" );
      System.out.println( 
          " # NOQUOTE_STRING \n"
        + "     PAST::Val.new(                                              \n"
        + "         :returns( 'String' ),                                   \n"
        + "         :value(" + noquote + ")                                 \n"
        + "      ),                                                         \n"
      );
    }
  | SINGLEQUOTE_STRING
    {
      String singlequote = $SINGLEQUOTE_STRING.text;
      singlequote = singlequote.replace( "\n", "\\n" );
      System.out.println( 
          " # SINGLEQUOTE_STRING \n"
        + "     PAST::Val.new(                                              \n"
        + "         :returns( 'String' ),                                   \n"
        + "         :value(" + singlequote + ")                             \n"
        + "      ),                                                         \n"
      );
    }
  | DOUBLEQUOTE_STRING
    {
      String doublequote = $DOUBLEQUOTE_STRING.text;
      doublequote = doublequote.replace( "\n", "\\n" );
      System.out.println( 
          " # DOUBLEQUOTE_STRING \n"
        + "     PAST::Val.new(                                              \n"
        + "         :returns( 'String' ),                                   \n"
        + "         :value(" + doublequote + ")                          \n"
        + "      ),                                                         \n"
      );
    }
  | NUMBER
    {
      System.out.println( 
          "     PAST::Val.new(                                              \n"
        + "         :returns( 'Float' ),                                    \n"
        + "         :value('" + $NUMBER.text + "')                          \n"
        + "      ),                                                         \n"
      );
    }
  | INTEGER
    {
      System.out.println( 
          "     PAST::Val.new(                                              \n"
        + "         :returns( 'Integer' ),                                  \n"
        + "         :value('" + $INTEGER.text + "')                         \n"
        + "      ),                                                         \n"
      );
    }
  | ^( infix=( PLUS | MINUS | MUL_OP | BITWISE_OP )
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
         System.out.println( 
             "    PAST::Op.new(\n"
           + "        :pirop( '" + pirop + "' ),\n"
           + "        :name( 'infix:" + infix + "' ),\n"
         );
       } node node )
    {
      System.out.print( 
          "    ),\n"
      );
    }
  | ^( prefix=PREFIX
       {
         System.out.println( 
             "    PAST::Op.new(                                                   \n"
           + "        :name( 'prefix:" + $prefix.text + "' ),                     \n"
         );
       }  node )
    {
      System.out.print( 
          "      ),                                                            \n"
      );
    }
  | {
      System.out.print( 
          "                                                                   \n"
      );
    }
    ^( REL_OP node node )
    {
      // Todo. This is not nice, handle pirops in Plumhead.g
      String name = $REL_OP.text;
      if      ( name.equals( "==" ) )  { name = "eq"; }
      else if ( name.equals( "!=" ) )  { name = "ne"; }
      name = "infix:" + name;
    }
  | {
      System.out.print( 
          "                                                                   \n"
      );
    }
    ^( IF node node node? )
    {
      System.out.print( 
          "                                                                   \n"
      );
    }
  | {
      System.out.print( 
          "                                                                       \n"
        + "        PAST::Stmts.new(                                               \n"
      );
    }
    ^( STMTS node* )
    {
      System.out.print( 
          "        ),                                                             \n"
      );
    }
  | {
      System.out.print( 
          "                                                                   \n"
      );
    }
    ^( ASSIGN_OP node node )
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
      System.out.print( 
          "                                                                  \n"
      );
    }
    ^( ARRAY node )
    {
      System.out.println( 
          "                                                                  \n"
      );
    }
  ;
