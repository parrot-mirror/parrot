# Copyright: 2005 The Perl Foundation.  All Rights Reserved.
# $Id$

import os
import sys
import re
import getopt

lib_path = os.path.join( os.path.dirname(sys.argv[0]), 'python', 'lib' )
sys.path.insert( 0, lib_path )
import antlr
import bc
import antlr2past

# Currently not used
class Visitor(antlr.ASTVisitor):
   def __init__(self,*args):
      super(Visitor,self).__init__(*args)
      self.level = 0
      if not args:
         self.cout = sys.stdout
         return
      if isinstance(args[0],file):
         self.cout = args[0]
         return
      assert 0

   def printf(self,fmt,*args):
      if not args:
          sys.stdout.write(fmt)
          return
      argv = tuple(args)
      self.cout.write(fmt % argv)

   def flush(self):
      self.cout.flush()

   def visit1(self,node):
      if not node:
         self.printf(" nil ")
         return

      c = node.getType()
      t = node.getText()
      k = node.getFirstChild()
      s = node.getNextSibling()
    
      self.printf("( <type: %s>",c)
      if t:
         self.printf("<text: %s> ",t)
      if k:
        self.visit1(k);
      self.printf("  )")
      if s:
        self.visit1(s);

   def visit(self,node):
      self.visit1(node);
      self.printf("\n")
      

def main():
   """Convert bc source code to PIR
   
   Actually different strategies will be explored.
   One is the generate plain old PIR.
   The other idea is to generate PIR that sets up a PAST data structure
   that will somehow be executed. See 'languages/punie'.

   As far as command line options go, there is only '-l'.

   Did I mention that Python doc strings are more weird than POD?
   """
   
   # only one option: -l
   # first argument is the input file name
   (options, bc_filenames) = getopt.getopt(sys.argv[1:], 'l')
   # TODO: option checkint, consider option -l
   # TODO: allow multiple input files and STDIN
   bc_fn  = bc_filenames[0]
   bc_fh = open(bc_fn, 'r')
   regexp = re.compile( r"\.bc$" )
   pir_fh  = open( regexp.sub(".pir", bc_fn), 'w' )
   past_pir_fh = open( regexp.sub("_past.pir", bc_fn), 'w' )

   L = bc.BcLexer.Lexer(bc_fh) 
   P = bc.BcParser.Parser(L)
   P.setFilename(L.getFilename())

   ### Parse the input expression
   try:
      P.program()
   except antlr.ANTLRException, ex:
      print "*** error(s) while parsing."
      print ">>> exit(1)"
      sys.exit(1)

 
   # ast is generated because of the option "buildAST = true;" in bc_parser.g
   ast = P.getAST()
   
   if not ast:
      print "stop - no AST generated."
      sys.exit(0)
      
   visitor = Visitor()

   ###show tree
   sys.stdout = pir_fh
   print ""
   print "=begin comment"
   print ""
   print "AST after parsing " + bc_filenames[0] 
   print ""
   print "toStringList: " + ast.toStringList()
   print ""
   # print "visit>>"
   # print ""
   # visitor.visit(ast);
   # print "visit<<"
   # print ""
   print "=end comment"
   print ""

   BcW = bc.BcTreeWalker.Walker();
   BcW.gen_pir(ast);
   pir_ast = BcW.getAST()
   print ""
   print "=begin comment"
   print ""
   print "AST after being processed by TreeParser"
   print ""
   print "pir_ast.toStringList:" 
   print pir_ast.toStringList()
   print ""
   print "visit>>\n"
   #visitor.visit(pir_ast);
   print "visit<<"
   print ""
   print "=end comment"
   print ""
   print "=cut"
   print """
#!/usr/bin/env parrot

.sub "main" @MAIN
  .local int temp_int
  .local pmc a_lex, b_lex, c_lex, d_lex, e_lex, f_lex, g_lex, h_lex, i_lex, j_lex, k_lex, l_lex, m_lex, n_lex, o_lex, p_lex, q_lex, r_lex, s_lex, t_lex, u_lex, v_lex, w_lex, x_lex, y_lex, z_lex
   a_lex = new .Float
   b_lex = new .Float
   c_lex = new .Float
   d_lex = new .Float
   e_lex = new .Float
   f_lex = new .Float
   g_lex = new .Float
   h_lex = new .Float
   i_lex = new .Float
   j_lex = new .Float
   k_lex = new .Float
   l_lex = new .Float
   m_lex = new .Float
   n_lex = new .Float
   o_lex = new .Float
   p_lex = new .Float
   q_lex = new .Float
   r_lex = new .Float
   s_lex = new .Float
   t_lex = new .Float
   u_lex = new .Float
   v_lex = new .Float
   w_lex = new .Float
   x_lex = new .Float
   y_lex = new .Float
   z_lex = new .Float
   """
   print '# ' + pir_ast.toStringList();

   print """
.end
   """

   # Now dump PIR, that uses PAST
   # TODO: This is a dummy implementation right now
   BcW.gen_antlr_past(ast);
   antlr_past = BcW.getAST()
   sys.stdout = past_pir_fh
   Antlr2PastW = antlr2past.Antlr2PastTreeWalker.Walker();
   Antlr2PastW.gen_pir_past(antlr_past);
   past_pir_ast = Antlr2PastW.getAST()
   past_pir     = "# " +  past_pir_ast.toStringList();
   print """
# Do not edit this file.
# This file has been generated by bc.py.

.sub 'bc' :main
    load_bytecode 'languages/punie/lib/PAST.pir'
    load_bytecode "TGE.pbc"
    load_bytecode "languages/punie/lib/POST.pir"

    # START of PIR generated by anltr2past.g
"""
   print past_pir
   print """
    # END of PIR generated by anltr2past.g

    # print "\\n\\nPAST tree dump:\\n"
    # stmts.dump()

    # Compile the abstract syntax tree down to an opcode syntax tree
    .local string ost_tg_source
    ost_tg_source = _slurp_file('../punie/lib/past2post.g')
    .local pmc ostgrammar
    ostgrammar = new 'TGE'
    ostgrammar.agcompile(ost_tg_source)
    .local pmc ostbuilder
    ostbuilder = ostgrammar.apply(stmts)
    .local pmc ost
    ost = ostbuilder.get('result')
    $I0 = defined ost
    unless $I0 goto err_no_ost # if OST fails stop

#    print "\\n\\nOST tree dump:\\n"
#    ost.dump()

    # Compile the OST down to PIR
    .local string pir_tg_source
    pir_tg_source = _slurp_file('../punie/lib/post2pir.g')
    .local pmc pirgrammar
    pirgrammar = new 'TGE'
    pirgrammar.agcompile(pir_tg_source)
    .local pmc pirbuilder
    pirbuilder = pirgrammar.apply(ost)
    .local pmc pir
    pir = pirbuilder.get('result')
    unless pir goto err_no_pir # if PIR not generated, stop

    # print "\\n\\nPIR dump:\\n"
    # print pir

    # Execute
    .local pmc pir_compiler
    .local pmc pir_compiled
    pir_compiler = compreg "PIR"
    pir_compiled = pir_compiler( pir )

    pir_compiled()

    # TODO: There is probably no string support yet in PAST
    print "\\n"

    end

  err_match_fail:
    print "parse failed"
    goto cleanup

  err_no_ast:
    print "Unable to construct AST.\\n"

  err_no_ost:
    print "Unable to construct OST.\\n"

  err_no_pir:
    print "Unable to construct PIR.\\n"

  cleanup:
.end

.sub _slurp_file
    .param string filename
    .local pmc filehandle
    filehandle = open filename, "<"
    unless filehandle goto err_no_file
    $S1 = read filehandle, 65535
    close filehandle
    .return ($S1)

  err_no_file:
    print "Unable to open file "
    print filename
    print "\\n"
    end
.end

"""

if __name__ == "__main__":
   main()
