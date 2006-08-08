// $ANTLR 3.0b3 grammar/antlr_3/antlr_past2pir_past.g 2006-08-08 23:54:43

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;import java.util.Stack;
import java.util.List;
import java.util.ArrayList;

public class AntlrPast2PirPast extends TreeParser {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "PROGRAM", "VAR", "STRING", "LETTER", "PLUS", "MINUS", "MUL", "DIV", "MOD", "INCR", "DECR", "NUMBER", "INTEGER", "ML_COMMENT", "WS", "NEWLINE", "';'", "'('", "')'", "'quit'"
    };
    public static final int MINUS=9;
    public static final int LETTER=7;
    public static final int INCR=13;
    public static final int DECR=14;
    public static final int NUMBER=15;
    public static final int WS=18;
    public static final int STRING=6;
    public static final int MOD=12;
    public static final int PROGRAM=4;
    public static final int NEWLINE=19;
    public static final int VAR=5;
    public static final int MUL=10;
    public static final int INTEGER=16;
    public static final int EOF=-1;
    public static final int DIV=11;
    public static final int PLUS=8;
    public static final int ML_COMMENT=17;

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
                if ( ((LA1_0>=VAR && LA1_0<=STRING)||(LA1_0>=PLUS && LA1_0<=MOD)||LA1_0==NUMBER) ) {
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
    // grammar/antlr_3/antlr_past2pir_past.g:124:1: expression[String reg_mother] : ( ( adding_expression["reg_expression_exp"] | named_expression["reg_expression_exp"] ) | string[ mother_for_string ] );
    public void expression(String reg_mother) throws RecognitionException {   
        try {
            // grammar/antlr_3/antlr_past2pir_past.g:125:5: ( ( adding_expression[\"reg_expression_exp\"] | named_expression[\"reg_expression_exp\"] ) | string[ mother_for_string ] )
            int alt3=2;
            int LA3_0 = input.LA(1);
            if ( (LA3_0==VAR||(LA3_0>=PLUS && LA3_0<=MOD)||LA3_0==NUMBER) ) {
                alt3=1;
            }
            else if ( (LA3_0==STRING) ) {
                alt3=2;
            }
            else {
                NoViableAltException nvae =
                    new NoViableAltException("124:1: expression[String reg_mother] : ( ( adding_expression[\"reg_expression_exp\"] | named_expression[\"reg_expression_exp\"] ) | string[ mother_for_string ] );", 3, 0, input);

                throw nvae;
            }
            switch (alt3) {
                case 1 :
                    // grammar/antlr_3/antlr_past2pir_past.g:125:5: ( adding_expression[\"reg_expression_exp\"] | named_expression[\"reg_expression_exp\"] )
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
                        
                    // grammar/antlr_3/antlr_past2pir_past.g:136:5: ( adding_expression[\"reg_expression_exp\"] | named_expression[\"reg_expression_exp\"] )
                    int alt2=2;
                    int LA2_0 = input.LA(1);
                    if ( ((LA2_0>=PLUS && LA2_0<=MOD)||LA2_0==NUMBER) ) {
                        alt2=1;
                    }
                    else if ( (LA2_0==VAR) ) {
                        alt2=2;
                    }
                    else {
                        NoViableAltException nvae =
                            new NoViableAltException("136:5: ( adding_expression[\"reg_expression_exp\"] | named_expression[\"reg_expression_exp\"] )", 2, 0, input);

                        throw nvae;
                    }
                    switch (alt2) {
                        case 1 :
                            // grammar/antlr_3/antlr_past2pir_past.g:137:7: adding_expression[\"reg_expression_exp\"]
                            {
                            pushFollow(FOLLOW_adding_expression_in_expression105);
                            adding_expression("reg_expression_exp");
                            _fsp--;


                            }
                            break;
                        case 2 :
                            // grammar/antlr_3/antlr_past2pir_past.g:139:7: named_expression[\"reg_expression_exp\"]
                            {
                            pushFollow(FOLLOW_named_expression_in_expression122);
                            named_expression("reg_expression_exp");
                            _fsp--;


                            }
                            break;

                    }


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
                    break;
                case 2 :
                    // grammar/antlr_3/antlr_past2pir_past.g:167:5: string[ mother_for_string ]
                    {

                          String mother_for_string = reg_mother;
                        
                    pushFollow(FOLLOW_string_in_expression153);
                    string( mother_for_string );
                    _fsp--;


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
    // $ANTLR end expression


    // $ANTLR start string
    // grammar/antlr_3/antlr_past2pir_past.g:173:1: string[ String reg_mother ] : STRING ;
    public void string(String reg_mother) throws RecognitionException {   
        CommonTree STRING1=null;

        try {
            // grammar/antlr_3/antlr_past2pir_past.g:174:5: ( STRING )
            // grammar/antlr_3/antlr_past2pir_past.g:174:5: STRING
            {
            STRING1=(CommonTree)input.LT(1);
            match(input,STRING,FOLLOW_STRING_in_string169); 

                  // TODO: strip String
                  System.out.print(     
                      "                                                                \n"
                    + "# entering 'string'                                             \n"
                    + "# " + STRING1.getText() + "                                          \n"
                    + "    reg_expression_stmt = new 'PAST::Stmt'                      \n"
                    + "      reg_expression_topexp = new 'PAST::Exp'                   \n"
                    + "        reg_expression_op = new 'PAST::Op'                      \n"
                    + "        reg_expression_op.'op'( 'print' )                       \n"
                    + "          reg_expression_exp = new 'PAST::Exp'                  \n"
                    + "            reg_temp = new 'PAST::Val'                          \n"
                    + "            reg_temp.value( " + STRING1.getText() + " )              \n"
                    + "            reg_temp.valtype( 'strqq' )                           \n"
                    + "          reg_expression_exp.'add_child'( reg_temp )            \n"
                    + "          null reg_temp                                         \n"
                    + "        reg_expression_op.'add_child'( reg_expression_exp )     \n"
                    + "      reg_expression_topexp.'add_child'( reg_expression_op )    \n"
                    + "    reg_expression_stmt.'add_child'( reg_expression_topexp )    \n"
                    + "  " + reg_mother + ".'add_child'( reg_expression_stmt ) \n"
                    + "# leaving 'string'                                              \n"
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
    // $ANTLR end string


    // $ANTLR start integer
    // grammar/antlr_3/antlr_past2pir_past.g:202:1: integer[ String reg_mother ] : NUMBER ;
    public void integer(String reg_mother) throws RecognitionException {   
        CommonTree NUMBER2=null;

        try {
            // grammar/antlr_3/antlr_past2pir_past.g:203:5: ( NUMBER )
            // grammar/antlr_3/antlr_past2pir_past.g:203:5: NUMBER
            {
            NUMBER2=(CommonTree)input.LT(1);
            match(input,NUMBER,FOLLOW_NUMBER_in_integer193); 

                  System.out.print(     
                      "                                                                \n"
                    + "# entering 'integer'                                            \n"
                    + "reg_temp = new 'PAST::Val'                                      \n"
                    + "reg_temp.value( " + NUMBER2.getText() + " )                             \n"
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
    // grammar/antlr_3/antlr_past2pir_past.g:218:1: adding_expression[String reg_mother] : ( integer[ mother_for_int ] | ^(infix= (PLUS|MINUS|MUL|DIV|MOD) adding_expression[reg] adding_expression[reg] ) ) ;
    public void adding_expression(String reg_mother) throws RecognitionException {   
        CommonTree infix=null;

        try {
            // grammar/antlr_3/antlr_past2pir_past.g:219:5: ( ( integer[ mother_for_int ] | ^(infix= (PLUS|MINUS|MUL|DIV|MOD) adding_expression[reg] adding_expression[reg] ) ) )
            // grammar/antlr_3/antlr_past2pir_past.g:219:5: ( integer[ mother_for_int ] | ^(infix= (PLUS|MINUS|MUL|DIV|MOD) adding_expression[reg] adding_expression[reg] ) )
            {

                  System.out.print( 
                      "                                                                  \n"
                    + "  # entering 'adding_expression'                                  \n"
                  );
                  // Why can't I say:   integer[ reg_mother ] ???
                  String mother_for_int = reg_mother;
                
            // grammar/antlr_3/antlr_past2pir_past.g:227:5: ( integer[ mother_for_int ] | ^(infix= (PLUS|MINUS|MUL|DIV|MOD) adding_expression[reg] adding_expression[reg] ) )
            int alt4=2;
            int LA4_0 = input.LA(1);
            if ( (LA4_0==NUMBER) ) {
                alt4=1;
            }
            else if ( ((LA4_0>=PLUS && LA4_0<=MOD)) ) {
                alt4=2;
            }
            else {
                NoViableAltException nvae =
                    new NoViableAltException("227:5: ( integer[ mother_for_int ] | ^(infix= (PLUS|MINUS|MUL|DIV|MOD) adding_expression[reg] adding_expression[reg] ) )", 4, 0, input);

                throw nvae;
            }
            switch (alt4) {
                case 1 :
                    // grammar/antlr_3/antlr_past2pir_past.g:227:7: integer[ mother_for_int ]
                    {
                    pushFollow(FOLLOW_integer_in_adding_expression221);
                    integer( mother_for_int );
                    _fsp--;


                    }
                    break;
                case 2 :
                    // grammar/antlr_3/antlr_past2pir_past.g:229:7: ^(infix= (PLUS|MINUS|MUL|DIV|MOD) adding_expression[reg] adding_expression[reg] )
                    {

                            reg_num++;
                            String reg = "reg_" + reg_num;
                            System.out.print( 
                                "                                                                \n"
                              + "    # entering '( PLUS | MINUS | MUL | DIV ) adding_expression adding_expression'       \n"
                              + "      .sym pmc " + reg + "                                      \n"
                              + "      " + reg + " = new 'PAST::Op'                              \n"
                            );
                          
                    infix=(CommonTree)input.LT(1);
                    if ( (input.LA(1)>=PLUS && input.LA(1)<=MOD) ) {
                        input.consume();
                        errorRecovery=false;
                    }
                    else {
                        MismatchedSetException mse =
                            new MismatchedSetException(null,input);
                        recoverFromMismatchedSet(input,mse,FOLLOW_set_in_adding_expression252);    throw mse;
                    }


                    match(input, Token.DOWN, null); 
                    pushFollow(FOLLOW_adding_expression_in_adding_expression272);
                    adding_expression(reg);
                    _fsp--;

                    pushFollow(FOLLOW_adding_expression_in_adding_expression275);
                    adding_expression(reg);
                    _fsp--;


                    match(input, Token.UP, null); 

                            System.out.print( 
                                "      " + reg + ".'op'( 'infix:" + infix.getText() + "' )   \n"
                              + "    reg_temp = new 'PAST::Exp'                                  \n"
                              + "    reg_temp.'add_child'( " + reg + " )                         \n"
                              + "      null " + reg + "                                          \n"
                              + "  " + reg_mother + ".'add_child'( reg_temp ) \n"
                              + "    null reg_temp                                               \n"
                              + "    # leaving '( PLUS | MINUS | MUL | DIV ) adding_expression adding_expression'        \n"
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


    // $ANTLR start named_expression
    // grammar/antlr_3/antlr_past2pir_past.g:259:1: named_expression[String reg_mother] : ^( VAR LETTER ) ;
    public void named_expression(String reg_mother) throws RecognitionException {   
        CommonTree LETTER3=null;

        try {
            // grammar/antlr_3/antlr_past2pir_past.g:260:5: ( ^( VAR LETTER ) )
            // grammar/antlr_3/antlr_past2pir_past.g:260:5: ^( VAR LETTER )
            {

                  System.out.print( 
                      "                                                                  \n"
                    + "  # entering 'named_expression'                                  \n"
                  );
                
            match(input,VAR,FOLLOW_VAR_in_named_expression320); 

            match(input, Token.DOWN, null); 
            LETTER3=(CommonTree)input.LT(1);
            match(input,LETTER,FOLLOW_LETTER_in_named_expression322); 

            match(input, Token.UP, null); 

                  reg_num++;
                  System.out.print( 
                      "                                                                     \n"
                    + "    # entering '( VAR LETTER )                                       \n"
                    + "    .sym pmc reg_exp_" + reg_num + "                                 \n"
                    + "    reg_exp_" + reg_num + " = new 'PAST::Exp'                        \n"
                    + "      .sym pmc reg_op_" + reg_num + "                                \n"
                    + "      reg_op_" + reg_num + " = new 'PAST::Op'                        \n"
                    + "      reg_op_" + reg_num + ".'op'( 'infix:=' )                       \n"
                    + "        .sym pmc reg_var_" + reg_num + "                             \n"
                    + "        reg_var_" + reg_num + " = new 'PAST::Var'                    \n"
                    + "        reg_var_" + reg_num + ".'varname'( '" + LETTER3.getText() + "' )   \n"
                    + "        reg_var_" + reg_num + ".'vartype'( 'scalar' )                \n"
                    + "        reg_var_" + reg_num + ".'scope'( 'global' )                  \n"
                    + "      reg_op_" + reg_num + ".'add_child'( reg_var_" + reg_num + " )  \n"
                    + "        .sym pmc reg_val_" + reg_num + "                             \n"
                    + "        reg_val_" + reg_num + " = new 'PAST::Val'                    \n"
                    + "        reg_val_" + reg_num + ".'value'( 0 )                         \n"
                    + "        reg_val_" + reg_num + ".'valtype'( 'int' )                   \n"
                    + "      reg_op_" + reg_num + ".'add_child'( reg_val_" + reg_num + " )  \n"
                    + "    reg_exp_" + reg_num + ".'add_child'( reg_op_" + reg_num + " )    \n"
                    + "# a quick hack to initialize 'a'                                     \n"
                    + "stmts.'add_child'( reg_exp_" + reg_num + " )                         \n"
                    + "  " + reg_mother + ".'add_child'( reg_var_" + reg_num + " ) \n"
                    + "    # leaving '(VAR LETTER)'                                         \n"
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
    // $ANTLR end named_expression


 

    public static final BitSet FOLLOW_PROGRAM_in_gen_pir_past65 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_expression_in_gen_pir_past67 = new BitSet(new long[]{0x0000000000009F68L});
    public static final BitSet FOLLOW_adding_expression_in_expression105 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_named_expression_in_expression122 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_string_in_expression153 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_STRING_in_string169 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_NUMBER_in_integer193 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_integer_in_adding_expression221 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_adding_expression252 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_adding_expression_in_adding_expression272 = new BitSet(new long[]{0x0000000000009F00L});
    public static final BitSet FOLLOW_adding_expression_in_adding_expression275 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_VAR_in_named_expression320 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_LETTER_in_named_expression322 = new BitSet(new long[]{0x0000000000000008L});

}