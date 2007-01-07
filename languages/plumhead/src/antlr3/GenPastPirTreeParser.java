// $ANTLR 3.0b5 src/antlr3/GenPastPir.g 2007-01-07 18:14:31

  import java.util.regex.*;


import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;import java.util.Stack;
import java.util.List;
import java.util.ArrayList;

public class GenPastPirTreeParser extends TreeParser {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "PROGRAM", "SEA", "CODE_START", "CODE_END", "WS", "STRING", "ECHO", "INTEGER", "NUMBER", "MINUS", "PLUS", "MUL_OP", "REL_OP", "';'", "'('", "')'"
    };
    public static final int CODE_START=6;
    public static final int INTEGER=11;
    public static final int MINUS=13;
    public static final int ECHO=10;
    public static final int WS=8;
    public static final int NUMBER=12;
    public static final int EOF=-1;
    public static final int STRING=9;
    public static final int REL_OP=16;
    public static final int MUL_OP=15;
    public static final int PLUS=14;
    public static final int SEA=5;
    public static final int CODE_END=7;
    public static final int PROGRAM=4;

        public GenPastPirTreeParser(TreeNodeStream input) {
            super(input);
        }
        

    public String[] getTokenNames() { return tokenNames; }
    public String getGrammarFileName() { return "src/antlr3/GenPastPir.g"; }


      // used for generating unique register names
      public static int reg_num = 200;



    // $ANTLR start gen_pir_past
    // src/antlr3/GenPastPir.g:28:1: gen_pir_past : ^( PROGRAM ( node["past_stmts"] )* ) ;
    public void gen_pir_past() throws RecognitionException {   
        try {
            // src/antlr3/GenPastPir.g:29:5: ( ^( PROGRAM ( node[\"past_stmts\"] )* ) )
            // src/antlr3/GenPastPir.g:29:5: ^( PROGRAM ( node[\"past_stmts\"] )* )
            {

                  System.out.println( 
                      "#!/usr/bin/env parrot                                             \n"
                    + "                                                                  \n"
                    + "# Do not edit this file.                                          \n"
                    + "# This file has been generated by GenPastPir.xsl                  \n"
                    + "                                                                  \n"
                    + ".sub 'php_init' :load :init                                       \n"
                    + "                                                                  \n"
                    + "  load_bytecode 'languages/plumhead/src/common/plumheadlib.pbc'   \n"
                    + "  load_bytecode 'PAST-pm.pbc'                                     \n"
                    + "  load_bytecode 'MIME/Base64.pbc'                                 \n"
                    + "  load_bytecode 'dumper.pbc'                                      \n"
                    + "  load_bytecode 'CGI/QueryHash.pbc'                               \n"
                    + "                                                                  \n"
                    + ".end                                                              \n"
                    + "                                                                  \n"
                    + ".sub plumhead :main                                               \n"
                    + "                                                                  \n"
                    + "    # look for subs in other namespaces                           \n"
                    + "    .local pmc parse_get_sub, parse_post_sub   \n"
                    + "    parse_get_sub  = get_global [ 'CGI'; 'QueryHash' ], 'parse_get'         \n"
                    + "    parse_post_sub = get_global [ 'CGI'; 'QueryHash' ], 'parse_post'        \n"
                    + "                                                                  \n"
                    + "    # the superglobals                                            \n"
                    + "    .local pmc superglobal_GET                                    \n"
                    + "    ( superglobal_GET ) = parse_get_sub()                         \n"
                    + "    set_global '_GET', superglobal_GET                            \n"
                    + "                                                                  \n"
                    + "    .local pmc superglobal_POST                                   \n"
                    + "    ( superglobal_POST ) = parse_post_sub()                       \n"
                    + "    set_global '_POST', superglobal_POST                          \n"
                    + "                                                                  \n"
                    + "    # The root node of PAST.                                      \n"
                    + "    .local pmc past_node_id2244466                                \n"
                    + "    past_node_id2244466  = new 'PAST::Block'                      \n"
                    + "    past_node_id2244466.init('name' => 'plumhead_main')           \n"
                    + "                                                                  \n"
                    + "  # start of generic node                                         \n"
                    + "  .local pmc past_stmts                                           \n"
                    + "  past_stmts = new 'PAST::Stmts'                                  \n"
                    + "                                                                  \n"
                    + "  .sym pmc past_temp                                              \n"
                    + "                                                                  \n"
                  );
                
            match(input,PROGRAM,FOLLOW_PROGRAM_in_gen_pir_past75); 

            if ( input.LA(1)==Token.DOWN ) {
                match(input, Token.DOWN, null); 
                // src/antlr3/GenPastPir.g:75:16: ( node[\"past_stmts\"] )*
                loop1:
                do {
                    int alt1=2;
                    int LA1_0 = input.LA(1);
                    if ( ((LA1_0>=STRING && LA1_0<=ECHO)||(LA1_0>=NUMBER && LA1_0<=REL_OP)) ) {
                        alt1=1;
                    }


                    switch (alt1) {
                	case 1 :
                	    // src/antlr3/GenPastPir.g:75:16: node[\"past_stmts\"]
                	    {
                	    pushFollow(FOLLOW_node_in_gen_pir_past77);
                	    node("past_stmts");
                	    _fsp--;


                	    }
                	    break;

                	default :
                	    break loop1;
                    }
                } while (true);


                match(input, Token.UP, null); 
            }

                  System.out.println( 
                      "                                                                  \n"
                    + "                                                                  \n"
                    + "  past_node_id2244466.'push'( past_stmts )                        \n"
                    + "  null past_stmts                                                 \n"
                    + "  # end of generic node                                           \n"
                    + "                                                                  \n"
                    + "    # '_dumper'(past_node_id2244466, 'past')                      \n"
                    + "    # '_dumper'(superglobal_POST , 'superglobal_POST')            \n"
                    + "    # '_dumper'(superglobal_GET , 'superglobal_GET')              \n"
                    + "                                                                  \n"
                    + "    # .local pmc post                                             \n"
                    + "    # post = past_node_id2244466.'compile'( 'target' => 'post' )  \n"
                    + "    # '_dumper'(post, 'post')                                     \n"
                    + "                                                                  \n"
                    + "    # .local pmc pir                                              \n"
                    + "    # pir = past_node_id2244466.'compile'( 'target' => 'pir' )    \n"
                    + "    # print pir                                                   \n"
                    + "                                                                  \n"
                    + "    .local pmc eval_past                                          \n"
                    + "    eval_past = past_node_id2244466.'compile'( )                  \n"
                    + "    eval_past()                                                   \n"
                    + "    # '_dumper'(eval, 'eval')                                     \n"
                    + "                                                                  \n"
                    + ".end                                                              \n"
                    + "                                                                  \n"
                    + "                                                                  \n"
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


    // $ANTLR start node
    // src/antlr3/GenPastPir.g:108:1: node[String reg_mother] : ( ^( ECHO node["past_echo"] ) | STRING | NUMBER | ^(infix= (PLUS|MINUS|MUL_OP|REL_OP) node[reg] node[reg] ) );
    public void node(String reg_mother) throws RecognitionException {   
        CommonTree infix=null;
        CommonTree STRING1=null;
        CommonTree NUMBER2=null;

        try {
            // src/antlr3/GenPastPir.g:109:5: ( ^( ECHO node[\"past_echo\"] ) | STRING | NUMBER | ^(infix= (PLUS|MINUS|MUL_OP|REL_OP) node[reg] node[reg] ) )
            int alt2=4;
            switch ( input.LA(1) ) {
            case ECHO:
                alt2=1;
                break;
            case STRING:
                alt2=2;
                break;
            case NUMBER:
                alt2=3;
                break;
            case MINUS:
            case PLUS:
            case MUL_OP:
            case REL_OP:
                alt2=4;
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("108:1: node[String reg_mother] : ( ^( ECHO node[\"past_echo\"] ) | STRING | NUMBER | ^(infix= (PLUS|MINUS|MUL_OP|REL_OP) node[reg] node[reg] ) );", 2, 0, input);

                throw nvae;
            }

            switch (alt2) {
                case 1 :
                    // src/antlr3/GenPastPir.g:109:5: ^( ECHO node[\"past_echo\"] )
                    {

                          System.out.println( 
                              "  # start of ECHO node                                            \n"
                            + "  .local pmc past_echo                                            \n"
                            + "  past_echo = new 'PAST::Op'                                      \n"
                            + "      past_echo.'attr'( 'name', 'echo', 1 )                       \n"
                          );
                        
                    match(input,ECHO,FOLLOW_ECHO_in_node109); 

                    match(input, Token.DOWN, null); 
                    pushFollow(FOLLOW_node_in_node111);
                    node("past_echo");
                    _fsp--;


                    match(input, Token.UP, null); 

                          System.out.println( 
                              "                                                                  \n"
                            + "  " + reg_mother + ".'push'( past_echo )                    \n"
                            + "  null past_echo                                                  \n"
                            + "  # end of ECHO node                                              \n"
                          );
                        

                    }
                    break;
                case 2 :
                    // src/antlr3/GenPastPir.g:126:5: STRING
                    {
                    STRING1=(CommonTree)input.LT(1);
                    match(input,STRING,FOLLOW_STRING_in_node126); 

                          String without_anno = STRING1.getText();
                          without_anno = without_anno.replace( "start_sea", "\"" );
                          without_anno = without_anno.replace( "end_sea", "\"" );
                          without_anno = without_anno.replace( "\n", "\\n" );
                          System.out.println( 
                              "                                                                  \n"
                            + "  # start of STRING                                               \n"
                            + "  past_temp = new 'PAST::Val'                                     \n"
                            + "      past_temp.'attr'( 'name', " + without_anno + ", 1 )         \n"
                            + "      past_temp.'attr'( 'ctype', 's~', 1 )                        \n"
                            + "      past_temp.'attr'( 'vtype', '.String', 1 )                   \n"
                            + "  " + reg_mother + ".'push'( past_temp )                    \n"
                            + "  null past_temp                                                  \n"
                            + "  # end of STRING                                                 \n"
                            + "                                                                  \n"
                          );
                        

                    }
                    break;
                case 3 :
                    // src/antlr3/GenPastPir.g:145:5: NUMBER
                    {
                    NUMBER2=(CommonTree)input.LT(1);
                    match(input,NUMBER,FOLLOW_NUMBER_in_node138); 

                          System.out.println( 
                              "                                                                  \n"
                            + "  # start of NUMBER                                               \n"
                            + "  past_temp = new 'PAST::Val'                                     \n"
                            + "      past_temp.'attr'( 'name', '" + NUMBER2.getText() + "', 1 )       \n"
                            + "      past_temp.'attr'( 'ctype', 'n+', 1 )                        \n"
                            + "      past_temp.'attr'( 'vtype', '.Float', 1 )                    \n"
                            + "  " + reg_mother + ".'push'( past_temp )                    \n"
                            + "  null past_temp                                                  \n"
                            + "  # end of NUMBER                                                 \n"
                          );
                        

                    }
                    break;
                case 4 :
                    // src/antlr3/GenPastPir.g:159:5: ^(infix= (PLUS|MINUS|MUL_OP|REL_OP) node[reg] node[reg] )
                    {

                          reg_num++;
                          String reg = "reg_" + reg_num;
                          System.out.print( 
                              "                                                                   \n"
                            + "    # entering PLUS | MINUS | MUL_OP | REL_OP                      \n"
                            + "      .sym pmc " + reg + "                                         \n"
                            + "      " + reg + " = new 'PAST::Op'                                 \n"
                          );
                        
                    infix=(CommonTree)input.LT(1);
                    if ( (input.LA(1)>=MINUS && input.LA(1)<=REL_OP) ) {
                        input.consume();
                        errorRecovery=false;
                    }
                    else {
                        MismatchedSetException mse =
                            new MismatchedSetException(null,input);
                        recoverFromMismatchedSet(input,mse,FOLLOW_set_in_node162);    throw mse;
                    }


                    match(input, Token.DOWN, null); 
                    pushFollow(FOLLOW_node_in_node178);
                    node(reg);
                    _fsp--;

                    pushFollow(FOLLOW_node_in_node181);
                    node(reg);
                    _fsp--;


                    match(input, Token.UP, null); 

                          // Todo. This is not nice, handl pirops in Plumhead.g
                          String pirop = infix.getText();
                          if      ( pirop.equals( "+" ) )  { pirop = "n_add"; }
                          else if ( pirop.equals( "-" ) )  { pirop = "n_sub"; }
                          else if ( pirop.equals( "*" ) )  { pirop = "n_mul"; }
                          else if ( pirop.equals( "/" ) )  { pirop = "n_div"; }
                          else if ( pirop.equals( "%" ) ) { pirop = "n_mod"; }
                          
                          System.out.print( 
                              "  " + reg + ".'attr'( 'pirop', '" + pirop + "' , 1 )               \n"
                            + "  " + reg_mother + ".'push'( " + reg + " )                   \n"
                            + "      null " + reg + "                                             \n"
                            + "    # leaving ( PLUS | MINUS | MUL | DIV )                         \n"
                          );
                        

                    }
                    break;

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
    // $ANTLR end node


 

    public static final BitSet FOLLOW_PROGRAM_in_gen_pir_past75 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_node_in_gen_pir_past77 = new BitSet(new long[]{0x000000000001F608L});
    public static final BitSet FOLLOW_ECHO_in_node109 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_node_in_node111 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_STRING_in_node126 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_NUMBER_in_node138 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_node162 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_node_in_node178 = new BitSet(new long[]{0x000000000001F600L});
    public static final BitSet FOLLOW_node_in_node181 = new BitSet(new long[]{0x0000000000000008L});

}