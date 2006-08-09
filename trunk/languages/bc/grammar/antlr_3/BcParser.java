// $ANTLR 3.0b3 grammar/antlr_3/bc.g 2006-08-10 00:00:47

import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;


import org.antlr.runtime.tree.*;

public class BcParser extends Parser {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "PROGRAM", "VAR", "STRING", "ASSIGN_OP", "LETTER", "PLUS", "MINUS", "MUL_OP", "INCR_DECR", "NUMBER", "INTEGER", "ML_COMMENT", "WS", "NEWLINE", "';'", "'('", "')'", "'quit'"
    };
    public static final int INCR_DECR=12;
    public static final int VAR=5;
    public static final int INTEGER=14;
    public static final int ASSIGN_OP=7;
    public static final int MINUS=10;
    public static final int LETTER=8;
    public static final int WS=16;
    public static final int NUMBER=13;
    public static final int EOF=-1;
    public static final int STRING=6;
    public static final int MUL_OP=11;
    public static final int ML_COMMENT=15;
    public static final int PLUS=9;
    public static final int PROGRAM=4;
    public static final int NEWLINE=17;

        public BcParser(TokenStream input) {
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
    public String getGrammarFileName() { return "grammar/antlr_3/bc.g"; }


    public static class program_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start program
    // grammar/antlr_3/bc.g:27:1: program : ( input_item )+ quit -> ^( PROGRAM ( input_item )+ ) ;
    public program_return program() throws RecognitionException {   
        program_return retval = new program_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        input_item_return input_item1 = null;

        quit_return quit2 = null;

        List list_quit=new ArrayList();
        List list_input_item=new ArrayList();

        try {
            // grammar/antlr_3/bc.g:28:5: ( ( input_item )+ quit -> ^( PROGRAM ( input_item )+ ) )
            // grammar/antlr_3/bc.g:28:5: ( input_item )+ quit
            {
            // grammar/antlr_3/bc.g:28:5: ( input_item )+
            int cnt1=0;
            loop1:
            do {
                int alt1=2;
                int LA1_0 = input.LA(1);
                if ( (LA1_0==STRING||LA1_0==LETTER||(LA1_0>=INCR_DECR && LA1_0<=NUMBER)||LA1_0==19) ) {
                    alt1=1;
                }


                switch (alt1) {
            	case 1 :
            	    // grammar/antlr_3/bc.g:28:5: input_item
            	    {
            	    pushFollow(FOLLOW_input_item_in_program71);
            	    input_item1=input_item();
            	    _fsp--;

            	    list_input_item.add(input_item1.tree);

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

            pushFollow(FOLLOW_quit_in_program74);
            quit2=quit();
            _fsp--;

            list_quit.add(quit2.tree);

            // AST REWRITE
            int i_0 = 0;
            retval.tree = root_0;
            root_0 = (CommonTree)adaptor.nil();
            // 28:22: -> ^( PROGRAM ( input_item )+ )
            {
                // grammar/antlr_3/bc.g:28:25: ^( PROGRAM ( input_item )+ )
                {
                CommonTree root_1 = (CommonTree)adaptor.nil();
                root_1 = (CommonTree)adaptor.becomeRoot(adaptor.create(PROGRAM, "PROGRAM"), root_1);

                // grammar/antlr_3/bc.g:28:36: ( input_item )+
                {
                int n_1 = list_input_item == null ? 0 : list_input_item.size();
                 


                if ( n_1==0 ) throw new RuntimeException("Must have more than one element for (...)+ loops");
                for (int i_1=0; i_1<n_1; i_1++) {
                    adaptor.addChild(root_1, list_input_item.get(i_1));

                }
                }

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

    public static class input_item_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start input_item
    // grammar/antlr_3/bc.g:32:1: input_item : semicolon_list ;
    public input_item_return input_item() throws RecognitionException {   
        input_item_return retval = new input_item_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        semicolon_list_return semicolon_list3 = null;



        try {
            // grammar/antlr_3/bc.g:33:5: ( semicolon_list )
            // grammar/antlr_3/bc.g:33:5: semicolon_list
            {
            root_0 = (CommonTree)adaptor.nil();

            pushFollow(FOLLOW_semicolon_list_in_input_item99);
            semicolon_list3=semicolon_list();
            _fsp--;

            adaptor.addChild(root_0, semicolon_list3.tree);

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
    // $ANTLR end input_item

    public static class semicolon_list_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start semicolon_list
    // grammar/antlr_3/bc.g:36:1: semicolon_list : statement ( ';'! statement )* ;
    public semicolon_list_return semicolon_list() throws RecognitionException {   
        semicolon_list_return retval = new semicolon_list_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token char_literal5=null;
        statement_return statement4 = null;

        statement_return statement6 = null;


        CommonTree char_literal5_tree=null;

        try {
            // grammar/antlr_3/bc.g:37:5: ( statement ( ';'! statement )* )
            // grammar/antlr_3/bc.g:37:5: statement ( ';'! statement )*
            {
            root_0 = (CommonTree)adaptor.nil();

            pushFollow(FOLLOW_statement_in_semicolon_list113);
            statement4=statement();
            _fsp--;

            adaptor.addChild(root_0, statement4.tree);
            // grammar/antlr_3/bc.g:37:15: ( ';'! statement )*
            loop2:
            do {
                int alt2=2;
                int LA2_0 = input.LA(1);
                if ( (LA2_0==18) ) {
                    alt2=1;
                }


                switch (alt2) {
            	case 1 :
            	    // grammar/antlr_3/bc.g:37:17: ';'! statement
            	    {
            	    CommonTree root_1 = (CommonTree)adaptor.nil();

            	    char_literal5=(Token)input.LT(1);
            	    match(input,18,FOLLOW_18_in_semicolon_list117); 
            	    pushFollow(FOLLOW_statement_in_semicolon_list120);
            	    statement6=statement();
            	    _fsp--;

            	    adaptor.addChild(root_1, statement6.tree);

            	    adaptor.addChild(root_0, root_1);

            	    }
            	    break;

            	default :
            	    break loop2;
                }
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
    // $ANTLR end semicolon_list

    public static class statement_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start statement
    // grammar/antlr_3/bc.g:41:1: statement : ( expression | STRING );
    public statement_return statement() throws RecognitionException {   
        statement_return retval = new statement_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token STRING8=null;
        expression_return expression7 = null;


        CommonTree STRING8_tree=null;

        try {
            // grammar/antlr_3/bc.g:42:5: ( expression | STRING )
            int alt3=2;
            int LA3_0 = input.LA(1);
            if ( (LA3_0==LETTER||(LA3_0>=INCR_DECR && LA3_0<=NUMBER)||LA3_0==19) ) {
                alt3=1;
            }
            else if ( (LA3_0==STRING) ) {
                alt3=2;
            }
            else {
                NoViableAltException nvae =
                    new NoViableAltException("41:1: statement : ( expression | STRING );", 3, 0, input);

                throw nvae;
            }
            switch (alt3) {
                case 1 :
                    // grammar/antlr_3/bc.g:42:5: expression
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    pushFollow(FOLLOW_expression_in_statement137);
                    expression7=expression();
                    _fsp--;

                    adaptor.addChild(root_0, expression7.tree);

                    }
                    break;
                case 2 :
                    // grammar/antlr_3/bc.g:44:5: STRING
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    STRING8=(Token)input.LT(1);
                    match(input,STRING,FOLLOW_STRING_in_statement149); 
                    STRING8_tree = (CommonTree)adaptor.create(STRING8);
                    adaptor.addChild(root_0, STRING8_tree);


                    }
                    break;

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

    public static class expression_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start expression
    // grammar/antlr_3/bc.g:47:1: expression : ( named_expression ASSIGN_OP^^ expression | named_expression | adding_expression );
    public expression_return expression() throws RecognitionException {   
        expression_return retval = new expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token ASSIGN_OP10=null;
        named_expression_return named_expression9 = null;

        expression_return expression11 = null;

        named_expression_return named_expression12 = null;

        adding_expression_return adding_expression13 = null;


        CommonTree ASSIGN_OP10_tree=null;

        try {
            // grammar/antlr_3/bc.g:48:5: ( named_expression ASSIGN_OP^^ expression | named_expression | adding_expression )
            int alt4=3;
            int LA4_0 = input.LA(1);
            if ( (LA4_0==LETTER) ) {
                int LA4_1 = input.LA(2);
                if ( (LA4_1==ASSIGN_OP) ) {
                    alt4=1;
                }
                else if ( (LA4_1==STRING||LA4_1==LETTER||(LA4_1>=INCR_DECR && LA4_1<=NUMBER)||(LA4_1>=18 && LA4_1<=21)) ) {
                    alt4=2;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("47:1: expression : ( named_expression ASSIGN_OP^^ expression | named_expression | adding_expression );", 4, 1, input);

                    throw nvae;
                }
            }
            else if ( ((LA4_0>=INCR_DECR && LA4_0<=NUMBER)||LA4_0==19) ) {
                alt4=3;
            }
            else {
                NoViableAltException nvae =
                    new NoViableAltException("47:1: expression : ( named_expression ASSIGN_OP^^ expression | named_expression | adding_expression );", 4, 0, input);

                throw nvae;
            }
            switch (alt4) {
                case 1 :
                    // grammar/antlr_3/bc.g:48:5: named_expression ASSIGN_OP^^ expression
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    pushFollow(FOLLOW_named_expression_in_expression162);
                    named_expression9=named_expression();
                    _fsp--;

                    adaptor.addChild(root_0, named_expression9.tree);
                    ASSIGN_OP10=(Token)input.LT(1);
                    match(input,ASSIGN_OP,FOLLOW_ASSIGN_OP_in_expression164); 
                    ASSIGN_OP10_tree = (CommonTree)adaptor.create(ASSIGN_OP10);
                    root_0 = (CommonTree)adaptor.becomeRoot(ASSIGN_OP10_tree, root_0);

                    pushFollow(FOLLOW_expression_in_expression167);
                    expression11=expression();
                    _fsp--;

                    adaptor.addChild(root_0, expression11.tree);

                    }
                    break;
                case 2 :
                    // grammar/antlr_3/bc.g:50:5: named_expression
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    pushFollow(FOLLOW_named_expression_in_expression180);
                    named_expression12=named_expression();
                    _fsp--;

                    adaptor.addChild(root_0, named_expression12.tree);

                    }
                    break;
                case 3 :
                    // grammar/antlr_3/bc.g:52:5: adding_expression
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    pushFollow(FOLLOW_adding_expression_in_expression192);
                    adding_expression13=adding_expression();
                    _fsp--;

                    adaptor.addChild(root_0, adding_expression13.tree);

                    }
                    break;

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
    // $ANTLR end expression

    public static class named_expression_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start named_expression
    // grammar/antlr_3/bc.g:55:1: named_expression : LETTER -> ^( VAR LETTER ) ;
    public named_expression_return named_expression() throws RecognitionException {   
        named_expression_return retval = new named_expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token LETTER14=null;
        List list_LETTER=new ArrayList();
        CommonTree LETTER14_tree=null;

        try {
            // grammar/antlr_3/bc.g:56:5: ( LETTER -> ^( VAR LETTER ) )
            // grammar/antlr_3/bc.g:56:5: LETTER
            {
            LETTER14=(Token)input.LT(1);
            match(input,LETTER,FOLLOW_LETTER_in_named_expression205); 
            list_LETTER.add(LETTER14);


            // AST REWRITE
            int i_0 = 0;
            retval.tree = root_0;
            root_0 = (CommonTree)adaptor.nil();
            // 56:12: -> ^( VAR LETTER )
            {
                // grammar/antlr_3/bc.g:56:15: ^( VAR LETTER )
                {
                CommonTree root_1 = (CommonTree)adaptor.nil();
                root_1 = (CommonTree)adaptor.becomeRoot(adaptor.create(VAR, "VAR"), root_1);

                adaptor.addChild(root_1, (Token)list_LETTER.get(i_0));

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
    // $ANTLR end named_expression

    public static class adding_expression_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start adding_expression
    // grammar/antlr_3/bc.g:60:1: adding_expression : multiplying_expression ( ( PLUS^^ | MINUS^^ ) multiplying_expression )* ;
    public adding_expression_return adding_expression() throws RecognitionException {   
        adding_expression_return retval = new adding_expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token PLUS16=null;
        Token MINUS17=null;
        multiplying_expression_return multiplying_expression15 = null;

        multiplying_expression_return multiplying_expression18 = null;


        CommonTree PLUS16_tree=null;
        CommonTree MINUS17_tree=null;

        try {
            // grammar/antlr_3/bc.g:61:5: ( multiplying_expression ( ( PLUS^^ | MINUS^^ ) multiplying_expression )* )
            // grammar/antlr_3/bc.g:61:5: multiplying_expression ( ( PLUS^^ | MINUS^^ ) multiplying_expression )*
            {
            root_0 = (CommonTree)adaptor.nil();

            pushFollow(FOLLOW_multiplying_expression_in_adding_expression230);
            multiplying_expression15=multiplying_expression();
            _fsp--;

            adaptor.addChild(root_0, multiplying_expression15.tree);
            // grammar/antlr_3/bc.g:61:28: ( ( PLUS^^ | MINUS^^ ) multiplying_expression )*
            loop6:
            do {
                int alt6=2;
                int LA6_0 = input.LA(1);
                if ( ((LA6_0>=PLUS && LA6_0<=MINUS)) ) {
                    alt6=1;
                }


                switch (alt6) {
            	case 1 :
            	    // grammar/antlr_3/bc.g:61:30: ( PLUS^^ | MINUS^^ ) multiplying_expression
            	    {
            	    CommonTree root_1 = (CommonTree)adaptor.nil();

            	    // grammar/antlr_3/bc.g:61:30: ( PLUS^^ | MINUS^^ )
            	    int alt5=2;
            	    int LA5_0 = input.LA(1);
            	    if ( (LA5_0==PLUS) ) {
            	        alt5=1;
            	    }
            	    else if ( (LA5_0==MINUS) ) {
            	        alt5=2;
            	    }
            	    else {
            	        NoViableAltException nvae =
            	            new NoViableAltException("61:30: ( PLUS^^ | MINUS^^ )", 5, 0, input);

            	        throw nvae;
            	    }
            	    switch (alt5) {
            	        case 1 :
            	            // grammar/antlr_3/bc.g:61:32: PLUS^^
            	            {
            	            CommonTree root_2 = (CommonTree)adaptor.nil();

            	            PLUS16=(Token)input.LT(1);
            	            match(input,PLUS,FOLLOW_PLUS_in_adding_expression236); 
            	            PLUS16_tree = (CommonTree)adaptor.create(PLUS16);
            	            root_0 = (CommonTree)adaptor.becomeRoot(PLUS16_tree, root_0);


            	            adaptor.addChild(root_1, root_2);

            	            }
            	            break;
            	        case 2 :
            	            // grammar/antlr_3/bc.g:61:41: MINUS^^
            	            {
            	            CommonTree root_2 = (CommonTree)adaptor.nil();

            	            MINUS17=(Token)input.LT(1);
            	            match(input,MINUS,FOLLOW_MINUS_in_adding_expression241); 
            	            MINUS17_tree = (CommonTree)adaptor.create(MINUS17);
            	            root_0 = (CommonTree)adaptor.becomeRoot(MINUS17_tree, root_0);


            	            adaptor.addChild(root_1, root_2);

            	            }
            	            break;

            	    }

            	    pushFollow(FOLLOW_multiplying_expression_in_adding_expression246);
            	    multiplying_expression18=multiplying_expression();
            	    _fsp--;

            	    adaptor.addChild(root_1, multiplying_expression18.tree);

            	    adaptor.addChild(root_0, root_1);

            	    }
            	    break;

            	default :
            	    break loop6;
                }
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
    // $ANTLR end adding_expression

    public static class multiplying_expression_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start multiplying_expression
    // grammar/antlr_3/bc.g:65:1: multiplying_expression : unary_expression ( MUL_OP^^ unary_expression )* ;
    public multiplying_expression_return multiplying_expression() throws RecognitionException {   
        multiplying_expression_return retval = new multiplying_expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token MUL_OP20=null;
        unary_expression_return unary_expression19 = null;

        unary_expression_return unary_expression21 = null;


        CommonTree MUL_OP20_tree=null;

        try {
            // grammar/antlr_3/bc.g:66:5: ( unary_expression ( MUL_OP^^ unary_expression )* )
            // grammar/antlr_3/bc.g:66:5: unary_expression ( MUL_OP^^ unary_expression )*
            {
            root_0 = (CommonTree)adaptor.nil();

            pushFollow(FOLLOW_unary_expression_in_multiplying_expression263);
            unary_expression19=unary_expression();
            _fsp--;

            adaptor.addChild(root_0, unary_expression19.tree);
            // grammar/antlr_3/bc.g:66:22: ( MUL_OP^^ unary_expression )*
            loop7:
            do {
                int alt7=2;
                int LA7_0 = input.LA(1);
                if ( (LA7_0==MUL_OP) ) {
                    alt7=1;
                }


                switch (alt7) {
            	case 1 :
            	    // grammar/antlr_3/bc.g:66:24: MUL_OP^^ unary_expression
            	    {
            	    CommonTree root_1 = (CommonTree)adaptor.nil();

            	    MUL_OP20=(Token)input.LT(1);
            	    match(input,MUL_OP,FOLLOW_MUL_OP_in_multiplying_expression267); 
            	    MUL_OP20_tree = (CommonTree)adaptor.create(MUL_OP20);
            	    root_0 = (CommonTree)adaptor.becomeRoot(MUL_OP20_tree, root_0);

            	    pushFollow(FOLLOW_unary_expression_in_multiplying_expression270);
            	    unary_expression21=unary_expression();
            	    _fsp--;

            	    adaptor.addChild(root_1, unary_expression21.tree);

            	    adaptor.addChild(root_0, root_1);

            	    }
            	    break;

            	default :
            	    break loop7;
                }
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
    // $ANTLR end multiplying_expression

    public static class unary_expression_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start unary_expression
    // grammar/antlr_3/bc.g:70:1: unary_expression : ( postfix_expression | INCR_DECR^^ postfix_expression );
    public unary_expression_return unary_expression() throws RecognitionException {   
        unary_expression_return retval = new unary_expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token INCR_DECR23=null;
        postfix_expression_return postfix_expression22 = null;

        postfix_expression_return postfix_expression24 = null;


        CommonTree INCR_DECR23_tree=null;

        try {
            // grammar/antlr_3/bc.g:71:5: ( postfix_expression | INCR_DECR^^ postfix_expression )
            int alt8=2;
            int LA8_0 = input.LA(1);
            if ( (LA8_0==NUMBER||LA8_0==19) ) {
                alt8=1;
            }
            else if ( (LA8_0==INCR_DECR) ) {
                alt8=2;
            }
            else {
                NoViableAltException nvae =
                    new NoViableAltException("70:1: unary_expression : ( postfix_expression | INCR_DECR^^ postfix_expression );", 8, 0, input);

                throw nvae;
            }
            switch (alt8) {
                case 1 :
                    // grammar/antlr_3/bc.g:71:5: postfix_expression
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    pushFollow(FOLLOW_postfix_expression_in_unary_expression287);
                    postfix_expression22=postfix_expression();
                    _fsp--;

                    adaptor.addChild(root_0, postfix_expression22.tree);

                    }
                    break;
                case 2 :
                    // grammar/antlr_3/bc.g:73:5: INCR_DECR^^ postfix_expression
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    INCR_DECR23=(Token)input.LT(1);
                    match(input,INCR_DECR,FOLLOW_INCR_DECR_in_unary_expression299); 
                    INCR_DECR23_tree = (CommonTree)adaptor.create(INCR_DECR23);
                    root_0 = (CommonTree)adaptor.becomeRoot(INCR_DECR23_tree, root_0);

                    pushFollow(FOLLOW_postfix_expression_in_unary_expression302);
                    postfix_expression24=postfix_expression();
                    _fsp--;

                    adaptor.addChild(root_0, postfix_expression24.tree);

                    }
                    break;

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
    // $ANTLR end unary_expression

    public static class postfix_expression_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start postfix_expression
    // grammar/antlr_3/bc.g:76:1: postfix_expression : ( NUMBER | '(' expression ')' -> expression );
    public postfix_expression_return postfix_expression() throws RecognitionException {   
        postfix_expression_return retval = new postfix_expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token NUMBER25=null;
        Token char_literal26=null;
        Token char_literal28=null;
        expression_return expression27 = null;

        List list_expression=new ArrayList();
        List list_20=new ArrayList();
        List list_19=new ArrayList();
        CommonTree NUMBER25_tree=null;
        CommonTree char_literal26_tree=null;
        CommonTree char_literal28_tree=null;

        try {
            // grammar/antlr_3/bc.g:77:5: ( NUMBER | '(' expression ')' -> expression )
            int alt9=2;
            int LA9_0 = input.LA(1);
            if ( (LA9_0==NUMBER) ) {
                alt9=1;
            }
            else if ( (LA9_0==19) ) {
                alt9=2;
            }
            else {
                NoViableAltException nvae =
                    new NoViableAltException("76:1: postfix_expression : ( NUMBER | '(' expression ')' -> expression );", 9, 0, input);

                throw nvae;
            }
            switch (alt9) {
                case 1 :
                    // grammar/antlr_3/bc.g:77:5: NUMBER
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    NUMBER25=(Token)input.LT(1);
                    match(input,NUMBER,FOLLOW_NUMBER_in_postfix_expression315); 
                    NUMBER25_tree = (CommonTree)adaptor.create(NUMBER25);
                    adaptor.addChild(root_0, NUMBER25_tree);


                    }
                    break;
                case 2 :
                    // grammar/antlr_3/bc.g:79:5: '(' expression ')'
                    {
                    char_literal26=(Token)input.LT(1);
                    match(input,19,FOLLOW_19_in_postfix_expression327); 
                    list_19.add(char_literal26);

                    pushFollow(FOLLOW_expression_in_postfix_expression329);
                    expression27=expression();
                    _fsp--;

                    list_expression.add(expression27.tree);
                    char_literal28=(Token)input.LT(1);
                    match(input,20,FOLLOW_20_in_postfix_expression331); 
                    list_20.add(char_literal28);


                    // AST REWRITE
                    int i_0 = 0;
                    retval.tree = root_0;
                    root_0 = (CommonTree)adaptor.nil();
                    // 79:24: -> expression
                    {
                        adaptor.addChild(root_0, list_expression.get(i_0));

                    }



                    }
                    break;

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
    // $ANTLR end postfix_expression

    public static class quit_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start quit
    // grammar/antlr_3/bc.g:114:1: quit : 'quit' ;
    public quit_return quit() throws RecognitionException {   
        quit_return retval = new quit_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token string_literal29=null;

        CommonTree string_literal29_tree=null;

        try {
            // grammar/antlr_3/bc.g:115:5: ( 'quit' )
            // grammar/antlr_3/bc.g:115:5: 'quit'
            {
            root_0 = (CommonTree)adaptor.nil();

            string_literal29=(Token)input.LT(1);
            match(input,21,FOLLOW_21_in_quit514); 
            string_literal29_tree = (CommonTree)adaptor.create(string_literal29);
            adaptor.addChild(root_0, string_literal29_tree);


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
    // $ANTLR end quit


 

    public static final BitSet FOLLOW_input_item_in_program71 = new BitSet(new long[]{0x0000000000283140L});
    public static final BitSet FOLLOW_quit_in_program74 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_semicolon_list_in_input_item99 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_statement_in_semicolon_list113 = new BitSet(new long[]{0x0000000000040002L});
    public static final BitSet FOLLOW_18_in_semicolon_list117 = new BitSet(new long[]{0x0000000000083140L});
    public static final BitSet FOLLOW_statement_in_semicolon_list120 = new BitSet(new long[]{0x0000000000040002L});
    public static final BitSet FOLLOW_expression_in_statement137 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_STRING_in_statement149 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_named_expression_in_expression162 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_ASSIGN_OP_in_expression164 = new BitSet(new long[]{0x0000000000083100L});
    public static final BitSet FOLLOW_expression_in_expression167 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_named_expression_in_expression180 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_adding_expression_in_expression192 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_LETTER_in_named_expression205 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_multiplying_expression_in_adding_expression230 = new BitSet(new long[]{0x0000000000000602L});
    public static final BitSet FOLLOW_PLUS_in_adding_expression236 = new BitSet(new long[]{0x0000000000083000L});
    public static final BitSet FOLLOW_MINUS_in_adding_expression241 = new BitSet(new long[]{0x0000000000083000L});
    public static final BitSet FOLLOW_multiplying_expression_in_adding_expression246 = new BitSet(new long[]{0x0000000000000602L});
    public static final BitSet FOLLOW_unary_expression_in_multiplying_expression263 = new BitSet(new long[]{0x0000000000000802L});
    public static final BitSet FOLLOW_MUL_OP_in_multiplying_expression267 = new BitSet(new long[]{0x0000000000083000L});
    public static final BitSet FOLLOW_unary_expression_in_multiplying_expression270 = new BitSet(new long[]{0x0000000000000802L});
    public static final BitSet FOLLOW_postfix_expression_in_unary_expression287 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_INCR_DECR_in_unary_expression299 = new BitSet(new long[]{0x0000000000082000L});
    public static final BitSet FOLLOW_postfix_expression_in_unary_expression302 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_NUMBER_in_postfix_expression315 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_19_in_postfix_expression327 = new BitSet(new long[]{0x0000000000083100L});
    public static final BitSet FOLLOW_expression_in_postfix_expression329 = new BitSet(new long[]{0x0000000000100000L});
    public static final BitSet FOLLOW_20_in_postfix_expression331 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_21_in_quit514 = new BitSet(new long[]{0x0000000000000002L});

}