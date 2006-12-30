// $ANTLR 3.0b5 src/antlr3/GenPastPir.g 2006-12-30 20:12:36

  import java.util.regex.*;


import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;import java.util.Stack;
import java.util.List;
import java.util.ArrayList;

public class GenPastPirTreeParser extends TreeParser {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "START_PHP", "END_PHP", "ARRAY", "FUNCTION", "PRINT", "PROGRAM", "STMTS", "VAR", "NEWLINE", "STRING", "LETTER", "INTEGER", "NUMBER", "MINUS", "PLUS", "MUL_OP", "ASSIGN_OP", "REL_OP", "INCR", "DECR", "Define", "Break", "Quit", "Length", "Return", "For", "If", "While", "Sqrt", "Scale", "Ibase", "Obase", "Auto", "ML_COMMENT", "WS", "';'", "'('", "')'", "'{'", "'}'", "'['", "']'", "','"
    };
    public static final int MINUS=17;
    public static final int LETTER=14;
    public static final int INCR=22;
    public static final int ARRAY=6;
    public static final int If=30;
    public static final int WS=38;
    public static final int DECR=23;
    public static final int NUMBER=16;
    public static final int Break=25;
    public static final int Sqrt=32;
    public static final int STRING=13;
    public static final int Ibase=34;
    public static final int START_PHP=4;
    public static final int Scale=33;
    public static final int MUL_OP=19;
    public static final int Define=24;
    public static final int Auto=36;
    public static final int Quit=26;
    public static final int STMTS=10;
    public static final int PROGRAM=9;
    public static final int NEWLINE=12;
    public static final int VAR=11;
    public static final int INTEGER=15;
    public static final int ASSIGN_OP=20;
    public static final int PRINT=8;
    public static final int FUNCTION=7;
    public static final int Obase=35;
    public static final int END_PHP=5;
    public static final int While=31;
    public static final int EOF=-1;
    public static final int REL_OP=21;
    public static final int PLUS=18;
    public static final int ML_COMMENT=37;
    public static final int Length=27;
    public static final int For=29;
    public static final int Return=28;

        public GenPastPirTreeParser(TreeNodeStream input) {
            super(input);
        }
        

    public String[] getTokenNames() { return tokenNames; }
    public String getGrammarFileName() { return "src/antlr3/GenPastPir.g"; }


      // used for generating unique register names
      public static int reg_num = 100;



    // $ANTLR start gen_pir_past
    // src/antlr3/GenPastPir.g:27:1: gen_pir_past : START_PHP ;
    public void gen_pir_past() throws RecognitionException {   
        try {
            // src/antlr3/GenPastPir.g:28:5: ( START_PHP )
            // src/antlr3/GenPastPir.g:28:5: START_PHP
            {

                  System.out.println( 
                      "#!/usr/bin/env parrot                                             \n"
                    + "                                                                  \n"
                    + "# Do not edit this file.                                          \n"
                    + "# This file has been generated by GenPastPir.xsl                  \n"
                    + "                                                                  \n"
                    + ".sub 'php_init' :load :init                                       \n"
                    + "                                                                  \n"
                    + "  load_bytecode 'languages/plumhead/plumheadlib.pbc'              \n"
                    + "  load_bytecode 'PAST-pm.pbc'                                     \n"
                    + "  load_bytecode 'MIME/Base64.pbc'                                 \n"
                    + "  load_bytecode 'dumper.pbc'                                      \n"
                    + "  load_bytecode 'CGI/QueryHash.pbc'                               \n"
                    + "                                                                  \n"
                    + ".end                                                              \n"
                    + "                                                                  \n"
                    + "                                                                  \n"
                    + "                                                                  \n"
                    + "                                                                  \n"
                    + "                                                                  \n"
                    + ".sub plumhead :main                                               \n"
                    + "                                                                  \n"
                    + "    # look for subs in other namespaces                           \n"
                    + "    .local pmc decode_base64_sub, parse_get_sub, parse_post_sub   \n"
                    + "    decode_base64_sub = get_global [ 'MIME'; 'Base64' ], 'decode_base64'    \n"
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
                    + "                                                                  \n"
                    + "                                                                  \n"
                    + "  # start of generic node                                         \n"
                    + "  .local pmc past_node_id2244469                                  \n"
                    + "  past_node_id2244469 = new 'PAST::Stmts'                         \n"
                    + "                                                                  \n"
                    + "                                                                  \n"
                    + "                                                                  \n"
                    + "  # start of generic node                                         \n"
                    + "  .local pmc past_node_id2244476                                  \n"
                    + "  past_node_id2244476 = new 'PAST::Op'                            \n"
                    + "                                                                  \n"
                    + "      past_node_id2244476.'attr'( 'name', 'echo', 1 )             \n"
                    + "                                                                  \n"
                    + "                                                                  \n"
                    + "                                                                  \n"
                    + "  # start of past:Val                                             \n"
                    + "  .local pmc past_node_id2244480                                  \n"
                    + "  past_node_id2244480 = new 'PAST::Val'                           \n"
                    + "                                                                  \n"
                    + "      .local string decoded                                       \n"
                    + "      decoded = decode_base64_sub( 'SGVsbG8sIFdvcmxkIQo=' )       \n"
                    + "      past_node_id2244480.'attr'( 'name', decoded, 1 )            \n"
                    + "      null decoded                                                \n"
                    + "                                                                  \n"
                    + "  past_node_id2244480.'attr'( 'ctype', 's~', 1 )                  \n"
                    + "                                                                  \n"
                    + "  past_node_id2244480.'attr'( 'vtype', '.String', 1 )             \n"
                    + "                                                                  \n"
                    + "  past_node_id2244476.'push'( past_node_id2244480 )               \n"
                    + "  # end of past:Val                                               \n"
                    + "                                                                  \n"
                    + "                                                                  \n"
                    + "                                                                  \n"
                    + "  past_node_id2244469.'push'( past_node_id2244476 )               \n"
                    + "  null past_node_id2244476                                        \n"
                    + "  # end of generic node                                           \n"
                    + "                                                                  \n"
                    + "                                                                  \n"
                    + "                                                                  \n"
                    + "  past_node_id2244466.'push'( past_node_id2244469 )               \n"
                    + "  null past_node_id2244469                                        \n"
                    + "  # end of generic node                                           \n"
                    + "                                                                  \n"
                    + "                                                                  \n"
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
                
            match(input,START_PHP,FOLLOW_START_PHP_in_gen_pir_past72); 

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
    // src/antlr3/GenPastPir.g:142:1: node[String reg_mother] : ( ^( PRINT node["reg_expression_exp"] ) | ^( FUNCTION LETTER ) | ^( ASSIGN_OP ^( VAR LETTER ) node["reg_assign_lhs"] ) | NUMBER | ^(infix= (PLUS|MINUS|MUL_OP|REL_OP) node[reg] node[reg] ) | ^( VAR LETTER ) | NEWLINE | STRING | ^( If node["reg_if_op"] node["reg_if_op"] ) | ^( STMTS ( node[reg_stmts] )* ) );
    public void node(String reg_mother) throws RecognitionException {   
        CommonTree infix=null;
        CommonTree LETTER1=null;
        CommonTree NUMBER2=null;
        CommonTree LETTER3=null;
        CommonTree STRING4=null;

        try {
            // src/antlr3/GenPastPir.g:143:5: ( ^( PRINT node[\"reg_expression_exp\"] ) | ^( FUNCTION LETTER ) | ^( ASSIGN_OP ^( VAR LETTER ) node[\"reg_assign_lhs\"] ) | NUMBER | ^(infix= (PLUS|MINUS|MUL_OP|REL_OP) node[reg] node[reg] ) | ^( VAR LETTER ) | NEWLINE | STRING | ^( If node[\"reg_if_op\"] node[\"reg_if_op\"] ) | ^( STMTS ( node[reg_stmts] )* ) )
            int alt2=10;
            switch ( input.LA(1) ) {
            case PRINT:
                alt2=1;
                break;
            case FUNCTION:
                alt2=2;
                break;
            case ASSIGN_OP:
                alt2=3;
                break;
            case NUMBER:
                alt2=4;
                break;
            case MINUS:
            case PLUS:
            case MUL_OP:
            case REL_OP:
                alt2=5;
                break;
            case VAR:
                alt2=6;
                break;
            case NEWLINE:
                alt2=7;
                break;
            case STRING:
                alt2=8;
                break;
            case If:
                alt2=9;
                break;
            case STMTS:
                alt2=10;
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("142:1: node[String reg_mother] : ( ^( PRINT node[\"reg_expression_exp\"] ) | ^( FUNCTION LETTER ) | ^( ASSIGN_OP ^( VAR LETTER ) node[\"reg_assign_lhs\"] ) | NUMBER | ^(infix= (PLUS|MINUS|MUL_OP|REL_OP) node[reg] node[reg] ) | ^( VAR LETTER ) | NEWLINE | STRING | ^( If node[\"reg_if_op\"] node[\"reg_if_op\"] ) | ^( STMTS ( node[reg_stmts] )* ) );", 2, 0, input);

                throw nvae;
            }

            switch (alt2) {
                case 1 :
                    // src/antlr3/GenPastPir.g:143:5: ^( PRINT node[\"reg_expression_exp\"] )
                    {

                          System.out.print( 
                              "                                                                  \n"
                            + "  # entering 'PRINT node'                                         \n"
                            + "    reg_expression_stmt = new 'PAST::Stmt'                        \n"
                            + "      reg_expression_topexp = new 'PAST::Exp'                     \n"
                            + "        reg_print_op = new 'PAST::Op'                             \n"
                            + "        reg_print_op.'op'( 'print' )                              \n"
                            + "          reg_expression_exp = new 'PAST::Exp'                    \n"
                          );
                        
                    match(input,PRINT,FOLLOW_PRINT_in_node94); 

                    match(input, Token.DOWN, null); 
                    pushFollow(FOLLOW_node_in_node96);
                    node("reg_expression_exp");
                    _fsp--;


                    match(input, Token.UP, null); 
                     
                          System.out.print( 
                              "                                                                   \n"
                            + "      reg_print_op.'add_child'( reg_expression_exp )               \n"
                            + "      reg_expression_topexp.'add_child'( reg_print_op      )       \n"
                            + "    reg_expression_stmt.'add_child'( reg_expression_topexp )       \n"
                            + "  " + reg_mother + ".'add_child'( reg_expression_stmt )      \n"
                            + "  # leaving 'PRINT node'                                           \n"
                          );
                        

                    }
                    break;
                case 2 :
                    // src/antlr3/GenPastPir.g:165:5: ^( FUNCTION LETTER )
                    {
                    match(input,FUNCTION,FOLLOW_FUNCTION_in_node113); 

                    match(input, Token.DOWN, null); 
                    match(input,LETTER,FOLLOW_LETTER_in_node115); 

                    match(input, Token.UP, null); 

                          // do nothing for now
                        

                    }
                    break;
                case 3 :
                    // src/antlr3/GenPastPir.g:169:5: ^( ASSIGN_OP ^( VAR LETTER ) node[\"reg_assign_lhs\"] )
                    {

                          System.out.print( 
                              "                                                                   \n"
                            + "  # entering 'assign'                                              \n"
                            + "    reg_assign_lhs = new 'PAST::Exp'                               \n"
                          );
                        
                    match(input,ASSIGN_OP,FOLLOW_ASSIGN_OP_in_node137); 

                    match(input, Token.DOWN, null); 
                    match(input,VAR,FOLLOW_VAR_in_node140); 

                    match(input, Token.DOWN, null); 
                    LETTER1=(CommonTree)input.LT(1);
                    match(input,LETTER,FOLLOW_LETTER_in_node142); 

                    match(input, Token.UP, null); 
                    pushFollow(FOLLOW_node_in_node145);
                    node("reg_assign_lhs");
                    _fsp--;


                    match(input, Token.UP, null); 

                          // TODO: strip String
                          System.out.print(     
                              "                                                                   \n"
                            + "    # entering 'ASSIGN_OP ^(VAR LETTER) node'                      \n"
                            + "      .sym pmc past_op                                             \n"
                            + "      past_op = new 'PAST::Op'                                     \n"
                            + "      past_op.'op'( 'infix:=' )                                    \n"
                            + "        .sym pmc past_var                                          \n"
                            + "        past_var = new 'PAST::Var'                                 \n"
                            + "        past_var.'varname'( '" + LETTER1.getText() + "' )               \n"
                            + "        past_var.'vartype'( 'scalar' )                             \n"
                            + "        past_var.'scope'( 'global' )                               \n"
                            + "      past_op.'add_child'( past_var )                              \n"
                            + "      past_op.'add_child'( reg_assign_lhs )                        \n"
                            + "    " + reg_mother + ".'add_child'( past_op )                \n"
                            + "    # leaving  'ASSIGN_OP named_expression NUMBER'                 \n"
                          );
                        

                    }
                    break;
                case 4 :
                    // src/antlr3/GenPastPir.g:196:5: NUMBER
                    {
                    NUMBER2=(CommonTree)input.LT(1);
                    match(input,NUMBER,FOLLOW_NUMBER_in_node160); 

                          System.out.print(     
                              "                                                                  \n"
                            + "# entering 'NUMBER'                                               \n"
                            + "reg_temp = new 'PAST::Val'                                        \n"
                            + "reg_temp.value( " + NUMBER2.getText() + " )                            \n"
                            + "reg_temp.valtype( 'num' )                                         \n"
                            + reg_mother + ".'add_child'( reg_temp )                       \n"
                            + "null reg_temp                                                     \n"
                            + "# leaving 'NUMBER'                                                \n"
                          );
                        

                    }
                    break;
                case 5 :
                    // src/antlr3/GenPastPir.g:209:5: ^(infix= (PLUS|MINUS|MUL_OP|REL_OP) node[reg] node[reg] )
                    {

                          reg_num++;
                          String reg = "reg_" + reg_num;
                          System.out.print( 
                              "                                                                   \n"
                            + "    # entering '( PLUS | MINUS | MUL_OP | REL_OP ) node node'               \n"
                            + "      .sym pmc " + reg + "                                         \n"
                            + "      " + reg + " = new 'PAST::Op'                                 \n"
                          );
                        
                    infix=(CommonTree)input.LT(1);
                    if ( (input.LA(1)>=MINUS && input.LA(1)<=MUL_OP)||input.LA(1)==REL_OP ) {
                        input.consume();
                        errorRecovery=false;
                    }
                    else {
                        MismatchedSetException mse =
                            new MismatchedSetException(null,input);
                        recoverFromMismatchedSet(input,mse,FOLLOW_set_in_node184);    throw mse;
                    }


                    match(input, Token.DOWN, null); 
                    pushFollow(FOLLOW_node_in_node200);
                    node(reg);
                    _fsp--;

                    pushFollow(FOLLOW_node_in_node203);
                    node(reg);
                    _fsp--;


                    match(input, Token.UP, null); 

                          System.out.print( 
                              "      " + reg + ".'op'( 'infix:" + infix.getText() + "' )              \n"
                            + "    reg_temp = new 'PAST::Exp'                                     \n"
                            + "    reg_temp.'add_child'( " + reg + " )                            \n"
                            + "      null " + reg + "                                             \n"
                            + "  " + reg_mother + ".'add_child'( reg_temp )                 \n"
                            + "    null reg_temp                                                  \n"
                            + "    # leaving '( PLUS | MINUS | MUL | DIV ) node node'             \n"
                          );
                        

                    }
                    break;
                case 6 :
                    // src/antlr3/GenPastPir.g:231:5: ^( VAR LETTER )
                    {
                    match(input,VAR,FOLLOW_VAR_in_node220); 

                    match(input, Token.DOWN, null); 
                    LETTER3=(CommonTree)input.LT(1);
                    match(input,LETTER,FOLLOW_LETTER_in_node222); 

                    match(input, Token.UP, null); 

                          System.out.print( 
                              "                                                                   \n"
                            + " # entering '( VAR LETTER )                                        \n"
                            + "    reg_temp = new 'PAST::Var'                                     \n"
                            + "    reg_temp.'varname'( '" + LETTER3.getText() + "' )                   \n"
                            + "    reg_temp.'vartype'( 'scalar' )                                 \n"
                            + "    reg_temp.'scope'( 'global' )                                   \n"
                            + "  " + reg_mother + ".'add_child'( reg_temp )                 \n"
                            + "    null reg_temp                                                  \n"
                            + "  # leaving '(VAR LETTER)'                                         \n"
                          );
                        

                    }
                    break;
                case 7 :
                    // src/antlr3/GenPastPir.g:245:5: NEWLINE
                    {
                    match(input,NEWLINE,FOLLOW_NEWLINE_in_node236); 
                     
                          System.out.print(     
                              "                                                                   \n"
                            + "# entering 'NEWLINE'                                               \n"
                            + "            reg_temp = new 'PAST::Val'                             \n"
                            + "            reg_temp.value( '\\n' )                                \n"
                            + "            reg_temp.valtype( 'strqq' )                            \n"
                            + "          " + reg_mother + ".'add_child'( reg_temp )         \n"
                            + "          null reg_temp                                            \n"
                            + "# leaving 'NEWLINE'                                                \n"
                          );
                        

                    }
                    break;
                case 8 :
                    // src/antlr3/GenPastPir.g:258:5: STRING
                    {
                    STRING4=(CommonTree)input.LT(1);
                    match(input,STRING,FOLLOW_STRING_in_node248); 

                          // In bc backslash has on special meaning, so s!/!//!
                          // Write newlines as '\n', in to not break PIR. s!\n!\\n!
                          String escaped = STRING4.getText().replaceAll( "\\\\", "\\\\\\\\\\\\\\\\" ).replaceAll( "\\n", "\\\\\\\\n" );
                          System.out.print(     
                              "                                                                   \n"
                            + "# entering 'STRING'                                                \n"
                            + "            reg_temp = new 'PAST::Val'                             \n"
                            + "            reg_temp.value( " + escaped + " )                      \n"
                            + "            reg_temp.valtype( 'strqq' )                            \n"
                            + "          " + reg_mother + ".'add_child'( reg_temp )         \n"
                            + "          null reg_temp                                            \n"
                            + "# leaving 'STRING'                                                 \n"
                          );
                        

                    }
                    break;
                case 9 :
                    // src/antlr3/GenPastPir.g:274:5: ^( If node[\"reg_if_op\"] node[\"reg_if_op\"] )
                    {

                          reg_num++;
                          String reg_exp   = "reg_expression_" + reg_num;
                          System.out.print( 
                              "  # entering 'If node node                                         \n"
                            + "      reg_if_op = new 'PAST::Op'                                   \n"
                            + "      reg_if_op.'op'( 'if' )                                       \n"
                            + "        .sym pmc " + reg_exp + "                                   \n"
                            + "        " + reg_exp + " = new 'PAST::Exp'                          \n"
                            + "                                                                   \n"
                          );
                        
                    match(input,If,FOLLOW_If_in_node268); 

                    match(input, Token.DOWN, null); 
                    pushFollow(FOLLOW_node_in_node270);
                    node("reg_if_op");
                    _fsp--;

                    pushFollow(FOLLOW_node_in_node273);
                    node("reg_if_op");
                    _fsp--;


                    match(input, Token.UP, null); 

                           // Create a node for If
                          System.out.print( 
                              "  # entering 'STMTS node*'                                         \n"
                            + "  " + reg_mother + ".'add_child'( reg_if_op )                \n"
                            + "  # leaving 'If node node                                          \n"
                          );
                        

                    }
                    break;
                case 10 :
                    // src/antlr3/GenPastPir.g:295:5: ^( STMTS ( node[reg_stmts] )* )
                    {

                          reg_num++;
                          String reg_stmts = "reg_stmts_" + reg_num;
                          System.out.print( 
                              "        .sym pmc " + reg_stmts + "                                 \n"
                            + "        " + reg_stmts + " = new 'PAST::Stmts'                      \n"
                          );
                        
                    match(input,STMTS,FOLLOW_STMTS_in_node296); 

                    if ( input.LA(1)==Token.DOWN ) {
                        match(input, Token.DOWN, null); 
                        // src/antlr3/GenPastPir.g:303:14: ( node[reg_stmts] )*
                        loop1:
                        do {
                            int alt1=2;
                            int LA1_0 = input.LA(1);
                            if ( ((LA1_0>=FUNCTION && LA1_0<=PRINT)||(LA1_0>=STMTS && LA1_0<=STRING)||(LA1_0>=NUMBER && LA1_0<=REL_OP)||LA1_0==If) ) {
                                alt1=1;
                            }


                            switch (alt1) {
                        	case 1 :
                        	    // src/antlr3/GenPastPir.g:303:14: node[reg_stmts]
                        	    {
                        	    pushFollow(FOLLOW_node_in_node298);
                        	    node(reg_stmts);
                        	    _fsp--;


                        	    }
                        	    break;

                        	default :
                        	    break loop1;
                            }
                        } while (true);


                        match(input, Token.UP, null); 
                    }

                           // Create a node for If
                          System.out.print( 
                              "  " + reg_mother + ".'add_child'( " + reg_stmts + " )        \n"
                            + "  # leaving 'STMTS node*'                                          \n"
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


 

    public static final BitSet FOLLOW_START_PHP_in_gen_pir_past72 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_PRINT_in_node94 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_node_in_node96 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_FUNCTION_in_node113 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_LETTER_in_node115 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_ASSIGN_OP_in_node137 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_VAR_in_node140 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_LETTER_in_node142 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_node_in_node145 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_NUMBER_in_node160 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_node184 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_node_in_node200 = new BitSet(new long[]{0x00000000403F3D80L});
    public static final BitSet FOLLOW_node_in_node203 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_VAR_in_node220 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_LETTER_in_node222 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_NEWLINE_in_node236 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_STRING_in_node248 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_If_in_node268 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_node_in_node270 = new BitSet(new long[]{0x00000000403F3D80L});
    public static final BitSet FOLLOW_node_in_node273 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_STMTS_in_node296 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_node_in_node298 = new BitSet(new long[]{0x00000000403F3D88L});

}