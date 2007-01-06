// $ANTLR 3.0b5 src/antlr3/Plumhead.g 2007-01-06 19:05:09

import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;


import org.antlr.runtime.tree.*;

public class PlumheadParser extends Parser {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "PROGRAM", "SEA", "CODE_START", "CODE_END", "WS", "STRING", "ECHO", "';'"
    };
    public static final int CODE_START=6;
    public static final int ECHO=10;
    public static final int WS=8;
    public static final int EOF=-1;
    public static final int STRING=9;
    public static final int SEA=5;
    public static final int CODE_END=7;
    public static final int PROGRAM=4;

        public PlumheadParser(TokenStream input) {
            super(input);
        }
        
    protected TreeAdaptor adaptor = new CommonTreeAdaptor();

    public void setTreeAdaptor(TreeAdaptor adaptor) {
        this.adaptor = adaptor;
    }
    public TreeAdaptor getTreeAdaptor() {
        return adaptor;
    }

    public String[] getTokenNames() { return tokenNames; }
    public String getGrammarFileName() { return "src/antlr3/Plumhead.g"; }


    public static class program_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start program
    // src/antlr3/Plumhead.g:30:1: program : s1= sea code s2= sea ( WS )? -> ^( PROGRAM $s1 code $s2) ;
    public program_return program() throws RecognitionException {   
        program_return retval = new program_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token WS2=null;
        sea_return s1 = null;

        sea_return s2 = null;

        code_return code1 = null;

        List list_code=new ArrayList();
        List list_sea=new ArrayList();
        List list_WS=new ArrayList();
        CommonTree WS2_tree=null;

        try {
            // src/antlr3/Plumhead.g:31:5: (s1= sea code s2= sea ( WS )? -> ^( PROGRAM $s1 code $s2) )
            // src/antlr3/Plumhead.g:31:5: s1= sea code s2= sea ( WS )?
            {
            pushFollow(FOLLOW_sea_in_program190);
            s1=sea();
            _fsp--;

            list_sea.add(s1.tree);
            pushFollow(FOLLOW_code_in_program192);
            code1=code();
            _fsp--;

            list_code.add(code1.tree);
            pushFollow(FOLLOW_sea_in_program196);
            s2=sea();
            _fsp--;

            list_sea.add(s2.tree);
            // src/antlr3/Plumhead.g:31:24: ( WS )?
            int alt1=2;
            int LA1_0 = input.LA(1);
            if ( (LA1_0==WS) ) {
                alt1=1;
            }
            switch (alt1) {
                case 1 :
                    // src/antlr3/Plumhead.g:31:24: WS
                    {
                    WS2=(Token)input.LT(1);
                    match(input,WS,FOLLOW_WS_in_program198); 
                    list_WS.add(WS2);


                    }
                    break;

            }


            // AST REWRITE
            int i_0 = 0;
            retval.tree = root_0;
            root_0 = (CommonTree)adaptor.nil();
            // 31:28: -> ^( PROGRAM $s1 code $s2)
            {
                // src/antlr3/Plumhead.g:31:31: ^( PROGRAM $s1 code $s2)
                {
                CommonTree root_1 = (CommonTree)adaptor.nil();
                root_1 = (CommonTree)adaptor.becomeRoot(adaptor.create(PROGRAM, "PROGRAM"), root_1);

                adaptor.addChild(root_1, s1.tree);
                adaptor.addChild(root_1, list_code.get(i_0));
                adaptor.addChild(root_1, s2.tree);

                adaptor.addChild(root_0, root_1);
                }

            }



            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
            retval.stop = input.LT(-1);

                retval.tree = (CommonTree)adaptor.rulePostProcessing(root_0);
                adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

       }
        return retval;
    }
    // $ANTLR end program

    public static class sea_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start sea
    // src/antlr3/Plumhead.g:34:1: sea : SEA -> ^( ECHO STRING[$SEA] ) ;
    public sea_return sea() throws RecognitionException {   
        sea_return retval = new sea_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token SEA3=null;
        List list_SEA=new ArrayList();
        CommonTree SEA3_tree=null;

        try {
            // src/antlr3/Plumhead.g:35:5: ( SEA -> ^( ECHO STRING[$SEA] ) )
            // src/antlr3/Plumhead.g:35:5: SEA
            {
            SEA3=(Token)input.LT(1);
            match(input,SEA,FOLLOW_SEA_in_sea228); 
            list_SEA.add(SEA3);


            // AST REWRITE
            int i_0 = 0;
            retval.tree = root_0;
            root_0 = (CommonTree)adaptor.nil();
            // 35:9: -> ^( ECHO STRING[$SEA] )
            {
                // src/antlr3/Plumhead.g:35:12: ^( ECHO STRING[$SEA] )
                {
                CommonTree root_1 = (CommonTree)adaptor.nil();
                root_1 = (CommonTree)adaptor.becomeRoot(adaptor.create(ECHO, "ECHO"), root_1);

                adaptor.addChild(root_1, adaptor.create(STRING, SEA3));

                adaptor.addChild(root_0, root_1);
                }

            }



            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
            retval.stop = input.LT(-1);

                retval.tree = (CommonTree)adaptor.rulePostProcessing(root_0);
                adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

       }
        return retval;
    }
    // $ANTLR end sea

    public static class code_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start code
    // src/antlr3/Plumhead.g:38:1: code : CODE_START statements ( WS )? CODE_END ( WS )? -> statements ;
    public code_return code() throws RecognitionException {   
        code_return retval = new code_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token CODE_START4=null;
        Token WS6=null;
        Token CODE_END7=null;
        Token WS8=null;
        statements_return statements5 = null;

        List list_statements=new ArrayList();
        List list_CODE_START=new ArrayList();
        List list_WS=new ArrayList();
        List list_CODE_END=new ArrayList();
        CommonTree CODE_START4_tree=null;
        CommonTree WS6_tree=null;
        CommonTree CODE_END7_tree=null;
        CommonTree WS8_tree=null;

        try {
            // src/antlr3/Plumhead.g:39:5: ( CODE_START statements ( WS )? CODE_END ( WS )? -> statements )
            // src/antlr3/Plumhead.g:39:5: CODE_START statements ( WS )? CODE_END ( WS )?
            {
            CODE_START4=(Token)input.LT(1);
            match(input,CODE_START,FOLLOW_CODE_START_in_code252); 
            list_CODE_START.add(CODE_START4);

            pushFollow(FOLLOW_statements_in_code254);
            statements5=statements();
            _fsp--;

            list_statements.add(statements5.tree);
            // src/antlr3/Plumhead.g:39:27: ( WS )?
            int alt2=2;
            int LA2_0 = input.LA(1);
            if ( (LA2_0==WS) ) {
                alt2=1;
            }
            switch (alt2) {
                case 1 :
                    // src/antlr3/Plumhead.g:39:27: WS
                    {
                    WS6=(Token)input.LT(1);
                    match(input,WS,FOLLOW_WS_in_code256); 
                    list_WS.add(WS6);


                    }
                    break;

            }

            CODE_END7=(Token)input.LT(1);
            match(input,CODE_END,FOLLOW_CODE_END_in_code259); 
            list_CODE_END.add(CODE_END7);

            // src/antlr3/Plumhead.g:39:40: ( WS )?
            int alt3=2;
            int LA3_0 = input.LA(1);
            if ( (LA3_0==WS) ) {
                alt3=1;
            }
            switch (alt3) {
                case 1 :
                    // src/antlr3/Plumhead.g:39:40: WS
                    {
                    WS8=(Token)input.LT(1);
                    match(input,WS,FOLLOW_WS_in_code261); 
                    list_WS.add(WS8);


                    }
                    break;

            }


            // AST REWRITE
            int i_0 = 0;
            retval.tree = root_0;
            root_0 = (CommonTree)adaptor.nil();
            // 39:44: -> statements
            {
                adaptor.addChild(root_0, list_statements.get(i_0));

            }



            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
            retval.stop = input.LT(-1);

                retval.tree = (CommonTree)adaptor.rulePostProcessing(root_0);
                adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

       }
        return retval;
    }
    // $ANTLR end code

    public static class statements_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start statements
    // src/antlr3/Plumhead.g:42:1: statements : ( statement )+ ;
    public statements_return statements() throws RecognitionException {   
        statements_return retval = new statements_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        statement_return statement9 = null;



        try {
            // src/antlr3/Plumhead.g:43:5: ( ( statement )+ )
            // src/antlr3/Plumhead.g:43:5: ( statement )+
            {
            root_0 = (CommonTree)adaptor.nil();

            // src/antlr3/Plumhead.g:43:5: ( statement )+
            int cnt4=0;
            loop4:
            do {
                int alt4=2;
                int LA4_0 = input.LA(1);
                if ( (LA4_0==WS) ) {
                    int LA4_1 = input.LA(2);
                    if ( (LA4_1==ECHO) ) {
                        alt4=1;
                    }


                }
                else if ( (LA4_0==ECHO) ) {
                    alt4=1;
                }


                switch (alt4) {
            	case 1 :
            	    // src/antlr3/Plumhead.g:43:7: statement
            	    {
            	    CommonTree root_1 = (CommonTree)adaptor.nil();

            	    pushFollow(FOLLOW_statement_in_statements281);
            	    statement9=statement();
            	    _fsp--;

            	    adaptor.addChild(root_1, statement9.tree);

            	    adaptor.addChild(root_0, root_1);

            	    }
            	    break;

            	default :
            	    if ( cnt4 >= 1 ) break loop4;
                        EarlyExitException eee =
                            new EarlyExitException(4, input);
                        throw eee;
                }
                cnt4++;
            } while (true);


            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
            retval.stop = input.LT(-1);

                retval.tree = (CommonTree)adaptor.rulePostProcessing(root_0);
                adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

       }
        return retval;
    }
    // $ANTLR end statements

    public static class statement_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start statement
    // src/antlr3/Plumhead.g:46:1: statement : ( WS )? ECHO ( WS )? STRING ( WS )? ';' -> ^( ECHO STRING ) ;
    public statement_return statement() throws RecognitionException {   
        statement_return retval = new statement_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token WS10=null;
        Token ECHO11=null;
        Token WS12=null;
        Token STRING13=null;
        Token WS14=null;
        Token char_literal15=null;
        List list_ECHO=new ArrayList();
        List list_11=new ArrayList();
        List list_WS=new ArrayList();
        List list_STRING=new ArrayList();
        CommonTree WS10_tree=null;
        CommonTree ECHO11_tree=null;
        CommonTree WS12_tree=null;
        CommonTree STRING13_tree=null;
        CommonTree WS14_tree=null;
        CommonTree char_literal15_tree=null;

        try {
            // src/antlr3/Plumhead.g:47:5: ( ( WS )? ECHO ( WS )? STRING ( WS )? ';' -> ^( ECHO STRING ) )
            // src/antlr3/Plumhead.g:47:5: ( WS )? ECHO ( WS )? STRING ( WS )? ';'
            {
            // src/antlr3/Plumhead.g:47:5: ( WS )?
            int alt5=2;
            int LA5_0 = input.LA(1);
            if ( (LA5_0==WS) ) {
                alt5=1;
            }
            switch (alt5) {
                case 1 :
                    // src/antlr3/Plumhead.g:47:5: WS
                    {
                    WS10=(Token)input.LT(1);
                    match(input,WS,FOLLOW_WS_in_statement297); 
                    list_WS.add(WS10);


                    }
                    break;

            }

            ECHO11=(Token)input.LT(1);
            match(input,ECHO,FOLLOW_ECHO_in_statement300); 
            list_ECHO.add(ECHO11);

            // src/antlr3/Plumhead.g:47:14: ( WS )?
            int alt6=2;
            int LA6_0 = input.LA(1);
            if ( (LA6_0==WS) ) {
                alt6=1;
            }
            switch (alt6) {
                case 1 :
                    // src/antlr3/Plumhead.g:47:14: WS
                    {
                    WS12=(Token)input.LT(1);
                    match(input,WS,FOLLOW_WS_in_statement302); 
                    list_WS.add(WS12);


                    }
                    break;

            }

            STRING13=(Token)input.LT(1);
            match(input,STRING,FOLLOW_STRING_in_statement305); 
            list_STRING.add(STRING13);

            // src/antlr3/Plumhead.g:47:25: ( WS )?
            int alt7=2;
            int LA7_0 = input.LA(1);
            if ( (LA7_0==WS) ) {
                alt7=1;
            }
            switch (alt7) {
                case 1 :
                    // src/antlr3/Plumhead.g:47:25: WS
                    {
                    WS14=(Token)input.LT(1);
                    match(input,WS,FOLLOW_WS_in_statement307); 
                    list_WS.add(WS14);


                    }
                    break;

            }

            char_literal15=(Token)input.LT(1);
            match(input,11,FOLLOW_11_in_statement310); 
            list_11.add(char_literal15);


            // AST REWRITE
            int i_0 = 0;
            retval.tree = root_0;
            root_0 = (CommonTree)adaptor.nil();
            // 47:33: -> ^( ECHO STRING )
            {
                // src/antlr3/Plumhead.g:47:36: ^( ECHO STRING )
                {
                CommonTree root_1 = (CommonTree)adaptor.nil();
                root_1 = (CommonTree)adaptor.becomeRoot((Token)list_ECHO.get(i_0), root_1);

                adaptor.addChild(root_1, (Token)list_STRING.get(i_0));

                adaptor.addChild(root_0, root_1);
                }

            }



            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
            retval.stop = input.LT(-1);

                retval.tree = (CommonTree)adaptor.rulePostProcessing(root_0);
                adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

       }
        return retval;
    }
    // $ANTLR end statement


 

    public static final BitSet FOLLOW_sea_in_program190 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_code_in_program192 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_sea_in_program196 = new BitSet(new long[]{0x0000000000000102L});
    public static final BitSet FOLLOW_WS_in_program198 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEA_in_sea228 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_CODE_START_in_code252 = new BitSet(new long[]{0x0000000000000500L});
    public static final BitSet FOLLOW_statements_in_code254 = new BitSet(new long[]{0x0000000000000180L});
    public static final BitSet FOLLOW_WS_in_code256 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_CODE_END_in_code259 = new BitSet(new long[]{0x0000000000000102L});
    public static final BitSet FOLLOW_WS_in_code261 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_statement_in_statements281 = new BitSet(new long[]{0x0000000000000502L});
    public static final BitSet FOLLOW_WS_in_statement297 = new BitSet(new long[]{0x0000000000000400L});
    public static final BitSet FOLLOW_ECHO_in_statement300 = new BitSet(new long[]{0x0000000000000300L});
    public static final BitSet FOLLOW_WS_in_statement302 = new BitSet(new long[]{0x0000000000000200L});
    public static final BitSet FOLLOW_STRING_in_statement305 = new BitSet(new long[]{0x0000000000000900L});
    public static final BitSet FOLLOW_WS_in_statement307 = new BitSet(new long[]{0x0000000000000800L});
    public static final BitSet FOLLOW_11_in_statement310 = new BitSet(new long[]{0x0000000000000002L});

}