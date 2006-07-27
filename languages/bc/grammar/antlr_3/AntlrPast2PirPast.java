// $ANTLR 3.0b3 grammar/antlr_3/antlr_past2pir_past.g 2006-07-25 23:45:43

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;import java.util.Stack;
import java.util.List;
import java.util.ArrayList;

public class AntlrPast2PirPast extends TreeParser {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "PROGRAM", "PLUS", "MINUS", "INT", "ML_COMMENT", "WS", "'quit'"
    };
    public static final int MINUS=6;
    public static final int INT=7;
    public static final int EOF=-1;
    public static final int WS=9;
    public static final int PLUS=5;
    public static final int ML_COMMENT=8;
    public static final int PROGRAM=4;

        public AntlrPast2PirPast(TreeNodeStream input) {
            super(input);
        }
        

    public String[] getTokenNames() { return tokenNames; }
    public String getGrammarFileName() { return "grammar/antlr_3/antlr_past2pir_past.g"; }



    // $ANTLR start gen_pir_past
    // grammar/antlr_3/antlr_past2pir_past.g:15:1: gen_pir_past : ^( PROGRAM ( expr )+ ) ;
    public void gen_pir_past() throws RecognitionException {   
        try {
            // grammar/antlr_3/antlr_past2pir_past.g:17:3: ( ^( PROGRAM ( expr )+ ) )
            // grammar/antlr_3/antlr_past2pir_past.g:17:3: ^( PROGRAM ( expr )+ )
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
              
            match(input,PROGRAM,FOLLOW_PROGRAM_in_gen_pir_past59); 

            match(input, Token.DOWN, null); 
            // grammar/antlr_3/antlr_past2pir_past.g:44:13: ( expr )+
            int cnt1=0;
            loop1:
            do {
                int alt1=2;
                int LA1_0 = input.LA(1);
                if ( (LA1_0==INT) ) {
                    alt1=1;
                }


                switch (alt1) {
            	case 1 :
            	    // grammar/antlr_3/antlr_past2pir_past.g:44:13: expr
            	    {
            	    pushFollow(FOLLOW_expr_in_gen_pir_past61);
            	    expr();
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

    public static class expr_int_1_return extends TreeRuleReturnScope {
    };

    // $ANTLR start expr_int_1
    // grammar/antlr_3/antlr_past2pir_past.g:112:1: expr_int_1 : INT ;
    public expr_int_1_return expr_int_1() throws RecognitionException {   
        expr_int_1_return retval = new expr_int_1_return();
        retval.start = input.LT(1);

        try {
            // grammar/antlr_3/antlr_past2pir_past.g:114:3: ( INT )
            // grammar/antlr_3/antlr_past2pir_past.g:114:3: INT
            {
            match(input,INT,FOLLOW_INT_in_expr_int_185); 

            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
            retval.stop = input.LT(-1);

        }
        return retval;
    }
    // $ANTLR end expr_int_1


    // $ANTLR start expr
    // grammar/antlr_3/antlr_past2pir_past.g:118:1: expr returns [String reg] : expr_int_1 ;
    public String expr() throws RecognitionException {   
        String reg = null;

        expr_int_1_return expr_int_11 = null;



              reg = "reg_expr_1";
            
        try {
            // grammar/antlr_3/antlr_past2pir_past.g:124:3: ( expr_int_1 )
            // grammar/antlr_3/antlr_past2pir_past.g:124:3: expr_int_1
            {
            pushFollow(FOLLOW_expr_int_1_in_expr116);
            expr_int_11=expr_int_1();
            _fsp--;


                  String pir = 
                      "                                                                \n"
                    + "# entering 'expr_int_1'                                         \n"
                    + "reg_expr_1 = new 'PAST::Val'                                    \n"
                    + "reg_expr_1.value( " + input.toString(expr_int_11.start,expr_int_11.stop) + " )                    \n"
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

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return reg;
    }
    // $ANTLR end expr


 

    public static final BitSet FOLLOW_PROGRAM_in_gen_pir_past59 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_expr_in_gen_pir_past61 = new BitSet(new long[]{0x0000000000000088L});
    public static final BitSet FOLLOW_INT_in_expr_int_185 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_expr_int_1_in_expr116 = new BitSet(new long[]{0x0000000000000002L});

}