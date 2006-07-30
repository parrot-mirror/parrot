// $ANTLR 3.0b3 grammar/antlr_3/antlr_past2pir_past.g 2006-07-30 19:01:26

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;import java.util.Stack;
import java.util.List;
import java.util.ArrayList;

public class AntlrPast2PirPast extends TreeParser {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "PROGRAM", "PLUS", "MINUS", "NUMBER", "INTEGER", "ML_COMMENT", "WS", "'quit'"
    };
    public static final int INTEGER=8;
    public static final int MINUS=6;
    public static final int EOF=-1;
    public static final int WS=10;
    public static final int NUMBER=7;
    public static final int PLUS=5;
    public static final int ML_COMMENT=9;
    public static final int PROGRAM=4;

        public AntlrPast2PirPast(TreeNodeStream input) {
            super(input);
        }
        

    public String[] getTokenNames() { return tokenNames; }
    public String getGrammarFileName() { return "grammar/antlr_3/antlr_past2pir_past.g"; }


      // used for generating unique register names
      public static int reg_num = 100;



    // $ANTLR start gen_pir_past
    // grammar/antlr_3/antlr_past2pir_past.g:21:1: gen_pir_past : ^( PROGRAM ( expression["stmts"] )+ ) ;
    public void gen_pir_past() throws RecognitionException {   
        try {
            // grammar/antlr_3/antlr_past2pir_past.g:22:5: ( ^( PROGRAM ( expression[\"stmts\"] )+ ) )
            // grammar/antlr_3/antlr_past2pir_past.g:22:5: ^( PROGRAM ( expression[\"stmts\"] )+ )
            {

                  System.out.println( 
                      "#!/usr/bin/env parrot                                             \n"
                    + "                                                                  \n"
                    + "# Do not edit this file.                                          \n"
                    + "# This file has been generated by Bc.java.                        \n"
                    + "                                                                  \n"
                    + "# entering 'gen_pir_past'                                         \n"
                    + ".sub bc :main                                                     \n"
                    + "  load_bytecode 'languages/punie/lib/ASTGrammar.pir'              \n"
                    + "  load_bytecode 'languages/punie/lib/PunieOpLookup.pir'           \n"              
                    + "  load_bytecode 'TGE.pbc'                                         \n"
                    + "  load_bytecode 'PAST.pbc'                                        \n"
                    + "  load_bytecode 'languages/punie/lib/POST.pir'                    \n"
                    + "  load_bytecode 'languages/punie/lib/OSTGrammar.pir'              \n"
                    + "                                                                  \n"
                    + "  # set up named registers                                        \n"
                    + "  .sym pmc stmts                                                  \n"
                    + "  stmts = new 'PAST::Stmts'                                       \n"
                    + "                                                                  \n"
                    + "  .sym pmc reg_expression_stmt                                    \n"
                    + "  .sym pmc reg_expression_topexp                                  \n"
                    + "  .sym pmc reg_expression_op                                      \n"
                    + "  .sym pmc reg_expression_exp                                     \n"
                    + "  .sym pmc reg_expression_stmt                                    \n"
                    + "  .sym pmc reg_expression_newline                                 \n"
                    + "                                                                  \n"
                    + "  .sym pmc reg_temp                                               \n"
                    + "                                                                  \n"
                    + "  .sym pmc reg_adding_expression_op                               \n"
                  );
                
            match(input,PROGRAM,FOLLOW_PROGRAM_in_gen_pir_past65); 

            match(input, Token.DOWN, null); 
            // grammar/antlr_3/antlr_past2pir_past.g:54:15: ( expression[\"stmts\"] )+
            int cnt1=0;
            loop1:
            do {
                int alt1=2;
                int LA1_0 = input.LA(1);
                if ( ((LA1_0>=PLUS && LA1_0<=NUMBER)) ) {
                    alt1=1;
                }


                switch (alt1) {
            	case 1 :
            	    // grammar/antlr_3/antlr_past2pir_past.g:54:15: expression[\"stmts\"]
            	    {
            	    pushFollow(FOLLOW_expression_in_gen_pir_past67);
            	    expression("stmts");
            	    _fsp--;


            	    }
            	    break;

            	default :
            	    if ( cnt1 >= 1 ) break loop1;
                        EarlyExitException eee =
                            new EarlyExitException(1, input);
                        throw eee;
                }
                cnt1++;
            } while (true);


            match(input, Token.UP, null); 

                  System.out.print( 
                      "                                                                  \n"
                    + "  # say 'AST tree dump:'                                          \n"
                    + "  # stmts.dump()                                                  \n"
                    + "                                                                  \n"
                    + "  # Compile the abstract syntax tree                              \n"
                    + "  # down to an opcode syntax tree                                 \n"
                    + "  .sym string ost_tg_src                                          \n"
                    + "  .sym pmc tge_compiler                                           \n"
                    + "  .sym pmc ost_grammar, ost_builder, ost                          \n"
                    + "  tge_compiler = new 'TGE::Compiler'                              \n"
                    + "  ost_tg_src = _slurp_file('languages/punie/lib/OSTGrammar.tg')   \n"
                    + "  ost_grammar = tge_compiler.'compile'(ost_tg_src)                \n"
                    + "  ost_builder = ost_grammar.apply(stmts)                          \n"
                    + "  ost = ost_builder.get('result')                                 \n"
                    + "  unless ost goto ERR_NO_OST                                      \n"
                    + "                                                                  \n"
                    + "  # Compile the OST down to PIR                                   \n"
                    + "  .sym string pir_tg_src                                          \n"
                    + "  .sym pmc pir_grammar, pir_builder, pir                          \n"
                    + "  pir_tg_src = _slurp_file('languages/punie/lib/PIRGrammar.tg')   \n"
                    + "  pir_grammar = tge_compiler.'compile'(pir_tg_src)                \n"
                    + "  pir_builder = pir_grammar.apply(ost)                            \n"
                    + "  pir = pir_builder.get('result')                                 \n"
                    + "  unless pir goto ERR_NO_PIR                                      \n"
                    + "                                                                  \n"
                    + "  # execute                                                       \n"
                    + "  .sym pmc pir_compiler, pir_compiled                             \n"
                    + "  pir_compiler = compreg 'PIR'                                    \n"
                    + "  pir_compiled = pir_compiler( pir )                              \n"
                    + "  pir_compiled()                                                  \n"
                    + "  say ''                                                          \n"
                    + "  goto CLEANUP                                                    \n"
                    + "                                                                  \n"
                    + "  ERR_NO_OST:                                                     \n"
                    + "    say 'Unable to construct OST.'                                \n"
                    + "    goto CLEANUP                                                  \n"
                    + "                                                                  \n"
                    + "  ERR_NO_PIR:                                                     \n"
                    + "    say 'Unable to construct PIR.'                                \n"
                    + "    goto CLEANUP                                                  \n"
                    + "                                                                  \n"
                    + "  CLEANUP:                                                        \n"
                    + ".end                                                              \n"
                    + "                                                                  \n"
                    + ".sub _slurp_file                                                  \n"
                    + "  .param string filename                                          \n"
                    + "                                                                  \n"
                    + "  .sym pmc filehandle                                             \n"
                    + "  .sym string content                                             \n"
                    + "  filehandle = open filename, '<'                                 \n"
                    + "  unless filehandle goto ERR_NO_FILE                              \n"
                    + "  content = read filehandle, 65535                                \n"
                    + "  close filehandle                                                \n"
                    + "                                                                  \n"
                    + "  .return ( content )                                             \n"
                    + "                                                                  \n"
                    + "  ERR_NO_FILE:                                                    \n"
                    + "    print 'Unable to open file: '                                 \n"
                    + "    say filename                                                  \n"
                    + "    end                                                           \n"
                    + "                                                                  \n"
                    + ".end                                                              \n"
                    + "# leaving 'gen_pir_past'                                          \n"
                  );
                

            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end gen_pir_past


    // $ANTLR start expression
    // grammar/antlr_3/antlr_past2pir_past.g:124:1: expression[String reg_mother] : adding_expression["reg_expression_exp"] ;
    public void expression(String reg_mother) throws RecognitionException {   
        try {
            // grammar/antlr_3/antlr_past2pir_past.g:125:5: ( adding_expression[\"reg_expression_exp\"] )
            // grammar/antlr_3/antlr_past2pir_past.g:125:5: adding_expression[\"reg_expression_exp\"]
            {

                  System.out.print( 
                      "                                                                  \n"
                    + "  # entering 'expression'                                         \n"
                    + "    reg_expression_stmt = new 'PAST::Stmt'                        \n"
                    + "      reg_expression_topexp = new 'PAST::Exp'                     \n"
                    + "        reg_expression_op = new 'PAST::Op'                        \n"
                    + "        reg_expression_op.'op'( 'print' )                         \n"
                    + "          reg_expression_exp = new 'PAST::Exp'                    \n"
                  );
                
            pushFollow(FOLLOW_adding_expression_in_expression97);
            adding_expression("reg_expression_exp");
            _fsp--;


                  System.out.print( 
                      "                                                                  \n"
                    + "        reg_expression_op.'add_child'( reg_expression_exp )       \n"
                    + "      reg_expression_topexp.'add_child'( reg_expression_op )      \n"
                    + "    reg_expression_stmt.'add_child'( reg_expression_topexp )      \n"
                    + "  " + reg_mother + ".'add_child'( reg_expression_stmt ) \n"
                    + "                                                                  \n"
                    + "  # Now print a newline                                           \n"
                    + "    reg_expression_stmt = new 'PAST::Stmt'                        \n"
                    + "      reg_expression_topexp = new 'PAST::Exp'                     \n"
                    + "        reg_expression_op = new 'PAST::Op'                        \n"
                    + "          reg_expression_exp = new 'PAST::Exp'                    \n"
                    + "            reg_expression_newline = new 'PAST::Val'              \n"
                    + "            reg_expression_newline.value( '\\n' )                 \n"
                    + "            reg_expression_newline.valtype( 'strqq' )             \n"
                    + "          reg_expression_exp.'add_child'( reg_expression_newline )\n"
                    + "        reg_expression_op.'add_child'( reg_expression_exp )       \n"
                    + "        reg_expression_op.'op'( 'print' )                         \n"
                    + "      reg_expression_topexp.'add_child'( reg_expression_op )      \n"
                    + "    reg_expression_stmt.'add_child'( reg_expression_topexp )      \n"
                    + "  " + reg_mother + ".'add_child'( reg_expression_stmt )\n"
                    + "  # leaving 'expression'                                          \n"
                  );
                

            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end expression


    // $ANTLR start integer
    // grammar/antlr_3/antlr_past2pir_past.g:165:1: integer[ String reg_mother ] : NUMBER ;
    public void integer(String reg_mother) throws RecognitionException {   
        CommonTree NUMBER1=null;

        try {
            // grammar/antlr_3/antlr_past2pir_past.g:166:5: ( NUMBER )
            // grammar/antlr_3/antlr_past2pir_past.g:166:5: NUMBER
            {
            NUMBER1=(CommonTree)input.LT(1);
            match(input,NUMBER,FOLLOW_NUMBER_in_integer119); 

                  System.out.print(     
                      "                                                                \n"
                    + "# entering 'integer'                                            \n"
                    + "reg_temp = new 'PAST::Val'                                      \n"
                    + "reg_temp.value( " + NUMBER1.getText() + " )                             \n"
                    + "reg_temp.valtype( 'num' )                                       \n"
                    + reg_mother + ".'add_child'( reg_temp )                  \n"
                    + "null reg_temp                                                   \n"
                    + "# leaving 'integer'                                             \n"
                  );
                

            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end integer


    // $ANTLR start adding_expression
    // grammar/antlr_3/antlr_past2pir_past.g:181:1: adding_expression[String reg_mother] : ( integer[ mother_for_int ] | ^(plus_or_minus= (PLUS|MINUS) adding_expression[reg] adding_expression[reg] ) ) ;
    public void adding_expression(String reg_mother) throws RecognitionException {   
        CommonTree plus_or_minus=null;

        try {
            // grammar/antlr_3/antlr_past2pir_past.g:182:5: ( ( integer[ mother_for_int ] | ^(plus_or_minus= (PLUS|MINUS) adding_expression[reg] adding_expression[reg] ) ) )
            // grammar/antlr_3/antlr_past2pir_past.g:182:5: ( integer[ mother_for_int ] | ^(plus_or_minus= (PLUS|MINUS) adding_expression[reg] adding_expression[reg] ) )
            {

                  System.out.print( 
                      "                                                                  \n"
                    + "  # entering 'adding_expression'                                  \n"
                  );
                  // Why can't I say:   integer[ reg_mother ] ???
                  String mother_for_int = reg_mother;
                
            // grammar/antlr_3/antlr_past2pir_past.g:190:5: ( integer[ mother_for_int ] | ^(plus_or_minus= (PLUS|MINUS) adding_expression[reg] adding_expression[reg] ) )
            int alt2=2;
            int LA2_0 = input.LA(1);
            if ( (LA2_0==NUMBER) ) {
                alt2=1;
            }
            else if ( ((LA2_0>=PLUS && LA2_0<=MINUS)) ) {
                alt2=2;
            }
            else {
                NoViableAltException nvae =
                    new NoViableAltException("190:5: ( integer[ mother_for_int ] | ^(plus_or_minus= (PLUS|MINUS) adding_expression[reg] adding_expression[reg] ) )", 2, 0, input);

                throw nvae;
            }
            switch (alt2) {
                case 1 :
                    // grammar/antlr_3/antlr_past2pir_past.g:190:7: integer[ mother_for_int ]
                    {
                    pushFollow(FOLLOW_integer_in_adding_expression147);
                    integer( mother_for_int );
                    _fsp--;


                    }
                    break;
                case 2 :
                    // grammar/antlr_3/antlr_past2pir_past.g:192:7: ^(plus_or_minus= (PLUS|MINUS) adding_expression[reg] adding_expression[reg] )
                    {

                            reg_num++;
                            String reg = "reg_" + reg_num;
                            System.out.print( 
                                "                                                                \n"
                              + "    # entering '( PLUS | MINUS ) adding_expression adding_expression'       \n"
                              + "      .sym pmc " + reg + "                                      \n"
                              + "      " + reg + " = new 'PAST::Op'                              \n"
                            );
                          
                    plus_or_minus=(CommonTree)input.LT(1);
                    if ( (input.LA(1)>=PLUS && input.LA(1)<=MINUS) ) {
                        input.consume();
                        errorRecovery=false;
                    }
                    else {
                        MismatchedSetException mse =
                            new MismatchedSetException(null,input);
                        recoverFromMismatchedSet(input,mse,FOLLOW_set_in_adding_expression178);    throw mse;
                    }


                    match(input, Token.DOWN, null); 
                    pushFollow(FOLLOW_adding_expression_in_adding_expression186);
                    adding_expression(reg);
                    _fsp--;

                    pushFollow(FOLLOW_adding_expression_in_adding_expression189);
                    adding_expression(reg);
                    _fsp--;


                    match(input, Token.UP, null); 

                            System.out.print( 
                                "      " + reg + ".'op'( 'infix:" + plus_or_minus.getText() + "' )   \n"
                              + "    reg_temp = new 'PAST::Exp'                                  \n"
                              + "    reg_temp.'add_child'( " + reg + " )                         \n"
                              + "      null " + reg + "                                          \n"
                              + "  " + reg_mother + ".'add_child'( reg_temp ) \n"
                              + "    null reg_temp                                               \n"
                              + "    # leaving '( PLUS | MINUS ) adding_expression adding_expression'        \n"
                            );
                          

                    }
                    break;

            }


                  System.out.print( 
                      "  # leaving 'adding_expression'                                   \n"
                  );
                

            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end adding_expression


 

    public static final BitSet FOLLOW_PROGRAM_in_gen_pir_past65 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_expression_in_gen_pir_past67 = new BitSet(new long[]{0x00000000000000E8L});
    public static final BitSet FOLLOW_adding_expression_in_expression97 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_NUMBER_in_integer119 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_integer_in_adding_expression147 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_adding_expression178 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_adding_expression_in_adding_expression186 = new BitSet(new long[]{0x00000000000000E0L});
    public static final BitSet FOLLOW_adding_expression_in_adding_expression189 = new BitSet(new long[]{0x0000000000000008L});

}