// $ANTLR 3.0b6 src/antlr3/Plumhead.g 2007-02-28 22:06:45

import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;


import org.antlr.runtime.tree.*;

public class PlumheadParser extends Parser {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "PROGRAM", "NOQUOTE_STRING", "STMTS", "ARRAY", "PREFIX", "SEA", "CODE_START", "CODE_END", "WS", "DOUBLEQUOTE_STRING", "SINGLEQUOTE_STRING", "ECHO", "IDENT", "SCALAR", "DIGITS", "INTEGER", "NUMBER", "MINUS", "PLUS", "MUL_OP", "BITWISE_OP", "ASSIGN_OP", "REL_OP", "IF", "ELSE", "';'", "'('", "')'", "'{'", "'}'", "'['", "']'"
    };
    public static final int CODE_START=10;
    public static final int MINUS=21;
    public static final int ARRAY=7;
    public static final int IDENT=16;
    public static final int DIGITS=18;
    public static final int BITWISE_OP=24;
    public static final int NUMBER=20;
    public static final int WS=12;
    public static final int SINGLEQUOTE_STRING=14;
    public static final int MUL_OP=23;
    public static final int SEA=9;
    public static final int CODE_END=11;
    public static final int STMTS=6;
    public static final int PROGRAM=4;
    public static final int PREFIX=8;
    public static final int ASSIGN_OP=25;
    public static final int INTEGER=19;
    public static final int DOUBLEQUOTE_STRING=13;
    public static final int ECHO=15;
    public static final int ELSE=28;
    public static final int IF=27;
    public static final int EOF=-1;
    public static final int REL_OP=26;
    public static final int PLUS=22;
    public static final int NOQUOTE_STRING=5;
    public static final int SCALAR=17;

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
    // src/antlr3/Plumhead.g:71:1: program : sea_or_code -> ^( PROGRAM sea_or_code ) ;
    public program_return program() throws RecognitionException {
        program_return retval = new program_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        sea_or_code_return sea_or_code1 = null;

        List list_sea_or_code=new ArrayList();

        try {
            // src/antlr3/Plumhead.g:72:5: ( sea_or_code -> ^( PROGRAM sea_or_code ) )
            // src/antlr3/Plumhead.g:72:5: sea_or_code
            {
            pushFollow(FOLLOW_sea_or_code_in_program690);
            sea_or_code1=sea_or_code();
            _fsp--;

            list_sea_or_code.add(sea_or_code1.getTree());

            // AST REWRITE
            int i_0 = 0;
            retval.tree = root_0;
            root_0 = (CommonTree)adaptor.nil();
            // 72:17: -> ^( PROGRAM sea_or_code )
            {
                // src/antlr3/Plumhead.g:72:20: ^( PROGRAM sea_or_code )
                {
                CommonTree root_1 = (CommonTree)adaptor.nil();
                root_1 = (CommonTree)adaptor.becomeRoot(adaptor.create(PROGRAM, "PROGRAM"), root_1);

                adaptor.addChild(root_1, list_sea_or_code.get(i_0));

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

    public static class sea_or_code_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start sea_or_code
    // src/antlr3/Plumhead.g:75:1: sea_or_code : ( sea | code )+ ;
    public sea_or_code_return sea_or_code() throws RecognitionException {
        sea_or_code_return retval = new sea_or_code_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        sea_return sea2 = null;

        code_return code3 = null;



        try {
            // src/antlr3/Plumhead.g:76:5: ( ( sea | code )+ )
            // src/antlr3/Plumhead.g:76:5: ( sea | code )+
            {
            root_0 = (CommonTree)adaptor.nil();

            // src/antlr3/Plumhead.g:76:5: ( sea | code )+
            int cnt1=0;
            loop1:
            do {
                int alt1=3;
                int LA1_0 = input.LA(1);
                if ( (LA1_0==SEA) ) {
                    alt1=1;
                }
                else if ( (LA1_0==CODE_START) ) {
                    alt1=2;
                }


                switch (alt1) {
            	case 1 :
            	    // src/antlr3/Plumhead.g:76:7: sea
            	    {
            	    pushFollow(FOLLOW_sea_in_sea_or_code715);
            	    sea2=sea();
            	    _fsp--;

            	    adaptor.addChild(root_0, sea2.getTree());

            	    }
            	    break;
            	case 2 :
            	    // src/antlr3/Plumhead.g:76:13: code
            	    {
            	    pushFollow(FOLLOW_code_in_sea_or_code719);
            	    code3=code();
            	    _fsp--;

            	    adaptor.addChild(root_0, code3.getTree());

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
    // $ANTLR end sea_or_code

    public static class sea_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start sea
    // src/antlr3/Plumhead.g:79:1: sea : SEA -> ^( ECHO NOQUOTE_STRING[$SEA] ) ;
    public sea_return sea() throws RecognitionException {
        sea_return retval = new sea_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token SEA4=null;
        List list_SEA=new ArrayList();
        CommonTree SEA4_tree=null;

        try {
            // src/antlr3/Plumhead.g:80:5: ( SEA -> ^( ECHO NOQUOTE_STRING[$SEA] ) )
            // src/antlr3/Plumhead.g:80:5: SEA
            {
            SEA4=(Token)input.LT(1);
            match(input,SEA,FOLLOW_SEA_in_sea736); 
            list_SEA.add(SEA4);


            // AST REWRITE
            int i_0 = 0;
            retval.tree = root_0;
            root_0 = (CommonTree)adaptor.nil();
            // 80:9: -> ^( ECHO NOQUOTE_STRING[$SEA] )
            {
                // src/antlr3/Plumhead.g:80:12: ^( ECHO NOQUOTE_STRING[$SEA] )
                {
                CommonTree root_1 = (CommonTree)adaptor.nil();
                root_1 = (CommonTree)adaptor.becomeRoot(adaptor.create(ECHO, "ECHO"), root_1);

                adaptor.addChild(root_1, adaptor.create(NOQUOTE_STRING, SEA4));

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
    // src/antlr3/Plumhead.g:83:1: code : CODE_START statements CODE_END -> statements ;
    public code_return code() throws RecognitionException {
        code_return retval = new code_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token CODE_START5=null;
        Token CODE_END7=null;
        statements_return statements6 = null;

        List list_statements=new ArrayList();
        List list_CODE_START=new ArrayList();
        List list_CODE_END=new ArrayList();
        CommonTree CODE_START5_tree=null;
        CommonTree CODE_END7_tree=null;

        try {
            // src/antlr3/Plumhead.g:84:5: ( CODE_START statements CODE_END -> statements )
            // src/antlr3/Plumhead.g:84:5: CODE_START statements CODE_END
            {
            CODE_START5=(Token)input.LT(1);
            match(input,CODE_START,FOLLOW_CODE_START_in_code760); 
            list_CODE_START.add(CODE_START5);

            pushFollow(FOLLOW_statements_in_code762);
            statements6=statements();
            _fsp--;

            list_statements.add(statements6.getTree());
            CODE_END7=(Token)input.LT(1);
            match(input,CODE_END,FOLLOW_CODE_END_in_code764); 
            list_CODE_END.add(CODE_END7);


            // AST REWRITE
            int i_0 = 0;
            retval.tree = root_0;
            root_0 = (CommonTree)adaptor.nil();
            // 84:36: -> statements
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

    public static class relational_expression_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start relational_expression
    // src/antlr3/Plumhead.g:87:1: relational_expression : expression ( REL_OP^ expression )? ;
    public relational_expression_return relational_expression() throws RecognitionException {
        relational_expression_return retval = new relational_expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token REL_OP9=null;
        expression_return expression8 = null;

        expression_return expression10 = null;


        CommonTree REL_OP9_tree=null;

        try {
            // src/antlr3/Plumhead.g:88:5: ( expression ( REL_OP^ expression )? )
            // src/antlr3/Plumhead.g:88:5: expression ( REL_OP^ expression )?
            {
            root_0 = (CommonTree)adaptor.nil();

            pushFollow(FOLLOW_expression_in_relational_expression782);
            expression8=expression();
            _fsp--;

            adaptor.addChild(root_0, expression8.getTree());
            // src/antlr3/Plumhead.g:88:16: ( REL_OP^ expression )?
            int alt2=2;
            int LA2_0 = input.LA(1);
            if ( (LA2_0==REL_OP) ) {
                alt2=1;
            }
            switch (alt2) {
                case 1 :
                    // src/antlr3/Plumhead.g:88:18: REL_OP^ expression
                    {
                    REL_OP9=(Token)input.LT(1);
                    match(input,REL_OP,FOLLOW_REL_OP_in_relational_expression786); 
                    REL_OP9_tree = (CommonTree)adaptor.create(REL_OP9);
                    root_0 = (CommonTree)adaptor.becomeRoot(REL_OP9_tree, root_0);

                    pushFollow(FOLLOW_expression_in_relational_expression789);
                    expression10=expression();
                    _fsp--;

                    adaptor.addChild(root_0, expression10.getTree());

                    }
                    break;

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
    // $ANTLR end relational_expression

    public static class statements_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start statements
    // src/antlr3/Plumhead.g:91:1: statements : ( statement )* ;
    public statements_return statements() throws RecognitionException {
        statements_return retval = new statements_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        statement_return statement11 = null;



        try {
            // src/antlr3/Plumhead.g:92:5: ( ( statement )* )
            // src/antlr3/Plumhead.g:92:5: ( statement )*
            {
            root_0 = (CommonTree)adaptor.nil();

            // src/antlr3/Plumhead.g:92:5: ( statement )*
            loop3:
            do {
                int alt3=2;
                int LA3_0 = input.LA(1);
                if ( (LA3_0==CODE_END) ) {
                    int LA3_1 = input.LA(2);
                    if ( (LA3_1==SEA) ) {
                        int LA3_4 = input.LA(3);
                        if ( (LA3_4==CODE_START) ) {
                            alt3=1;
                        }


                    }


                }
                else if ( (LA3_0==ECHO||LA3_0==SCALAR||LA3_0==IF) ) {
                    alt3=1;
                }


                switch (alt3) {
            	case 1 :
            	    // src/antlr3/Plumhead.g:92:7: statement
            	    {
            	    pushFollow(FOLLOW_statement_in_statements807);
            	    statement11=statement();
            	    _fsp--;

            	    adaptor.addChild(root_0, statement11.getTree());

            	    }
            	    break;

            	default :
            	    break loop3;
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
    // $ANTLR end statements

    public static class statement_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start statement
    // src/antlr3/Plumhead.g:95:1: statement : ( ECHO^ expression ';'! | IF '(' relational_expression ')' '{' s1= statements '}' ( ELSE '{' s2= statements '}' -> ^( IF relational_expression ^( STMTS $s1) ^( STMTS $s2) ) | -> ^( IF relational_expression ^( STMTS $s1) ) ) | CODE_END SEA CODE_START -> ^( ECHO NOQUOTE_STRING[$SEA] ) | SCALAR ASSIGN_OP^ expression ';'! | s= SCALAR '[' key= expression ']' ASSIGN_OP val= expression ';' -> ^( ASSIGN_OP ^( ARRAY[$s] $key) $val) );
    public statement_return statement() throws RecognitionException {
        statement_return retval = new statement_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token s=null;
        Token ECHO12=null;
        Token char_literal14=null;
        Token IF15=null;
        Token char_literal16=null;
        Token char_literal18=null;
        Token char_literal19=null;
        Token char_literal20=null;
        Token ELSE21=null;
        Token char_literal22=null;
        Token char_literal23=null;
        Token CODE_END24=null;
        Token SEA25=null;
        Token CODE_START26=null;
        Token SCALAR27=null;
        Token ASSIGN_OP28=null;
        Token char_literal30=null;
        Token char_literal31=null;
        Token char_literal32=null;
        Token ASSIGN_OP33=null;
        Token char_literal34=null;
        statements_return s1 = null;

        statements_return s2 = null;

        expression_return key = null;

        expression_return val = null;

        expression_return expression13 = null;

        relational_expression_return relational_expression17 = null;

        expression_return expression29 = null;

        List list_statements=new ArrayList();
        List list_expression=new ArrayList();
        List list_relational_expression=new ArrayList();
        List list_CODE_START=new ArrayList();
        List list_ASSIGN_OP=new ArrayList();
        List list_29=new ArrayList();
        List list_30=new ArrayList();
        List list_ELSE=new ArrayList();
        List list_IF=new ArrayList();
        List list_31=new ArrayList();
        List list_32=new ArrayList();
        List list_35=new ArrayList();
        List list_SEA=new ArrayList();
        List list_33=new ArrayList();
        List list_SCALAR=new ArrayList();
        List list_CODE_END=new ArrayList();
        List list_34=new ArrayList();
        CommonTree s_tree=null;
        CommonTree ECHO12_tree=null;
        CommonTree char_literal14_tree=null;
        CommonTree IF15_tree=null;
        CommonTree char_literal16_tree=null;
        CommonTree char_literal18_tree=null;
        CommonTree char_literal19_tree=null;
        CommonTree char_literal20_tree=null;
        CommonTree ELSE21_tree=null;
        CommonTree char_literal22_tree=null;
        CommonTree char_literal23_tree=null;
        CommonTree CODE_END24_tree=null;
        CommonTree SEA25_tree=null;
        CommonTree CODE_START26_tree=null;
        CommonTree SCALAR27_tree=null;
        CommonTree ASSIGN_OP28_tree=null;
        CommonTree char_literal30_tree=null;
        CommonTree char_literal31_tree=null;
        CommonTree char_literal32_tree=null;
        CommonTree ASSIGN_OP33_tree=null;
        CommonTree char_literal34_tree=null;

        try {
            // src/antlr3/Plumhead.g:96:5: ( ECHO^ expression ';'! | IF '(' relational_expression ')' '{' s1= statements '}' ( ELSE '{' s2= statements '}' -> ^( IF relational_expression ^( STMTS $s1) ^( STMTS $s2) ) | -> ^( IF relational_expression ^( STMTS $s1) ) ) | CODE_END SEA CODE_START -> ^( ECHO NOQUOTE_STRING[$SEA] ) | SCALAR ASSIGN_OP^ expression ';'! | s= SCALAR '[' key= expression ']' ASSIGN_OP val= expression ';' -> ^( ASSIGN_OP ^( ARRAY[$s] $key) $val) )
            int alt5=5;
            switch ( input.LA(1) ) {
            case ECHO:
                alt5=1;
                break;
            case IF:
                alt5=2;
                break;
            case CODE_END:
                alt5=3;
                break;
            case SCALAR:
                int LA5_4 = input.LA(2);
                if ( (LA5_4==34) ) {
                    alt5=5;
                }
                else if ( (LA5_4==ASSIGN_OP) ) {
                    alt5=4;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("95:1: statement : ( ECHO^ expression ';'! | IF '(' relational_expression ')' '{' s1= statements '}' ( ELSE '{' s2= statements '}' -> ^( IF relational_expression ^( STMTS $s1) ^( STMTS $s2) ) | -> ^( IF relational_expression ^( STMTS $s1) ) ) | CODE_END SEA CODE_START -> ^( ECHO NOQUOTE_STRING[$SEA] ) | SCALAR ASSIGN_OP^ expression ';'! | s= SCALAR '[' key= expression ']' ASSIGN_OP val= expression ';' -> ^( ASSIGN_OP ^( ARRAY[$s] $key) $val) );", 5, 4, input);

                    throw nvae;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("95:1: statement : ( ECHO^ expression ';'! | IF '(' relational_expression ')' '{' s1= statements '}' ( ELSE '{' s2= statements '}' -> ^( IF relational_expression ^( STMTS $s1) ^( STMTS $s2) ) | -> ^( IF relational_expression ^( STMTS $s1) ) ) | CODE_END SEA CODE_START -> ^( ECHO NOQUOTE_STRING[$SEA] ) | SCALAR ASSIGN_OP^ expression ';'! | s= SCALAR '[' key= expression ']' ASSIGN_OP val= expression ';' -> ^( ASSIGN_OP ^( ARRAY[$s] $key) $val) );", 5, 0, input);

                throw nvae;
            }

            switch (alt5) {
                case 1 :
                    // src/antlr3/Plumhead.g:96:5: ECHO^ expression ';'!
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    ECHO12=(Token)input.LT(1);
                    match(input,ECHO,FOLLOW_ECHO_in_statement823); 
                    ECHO12_tree = (CommonTree)adaptor.create(ECHO12);
                    root_0 = (CommonTree)adaptor.becomeRoot(ECHO12_tree, root_0);

                    pushFollow(FOLLOW_expression_in_statement826);
                    expression13=expression();
                    _fsp--;

                    adaptor.addChild(root_0, expression13.getTree());
                    char_literal14=(Token)input.LT(1);
                    match(input,29,FOLLOW_29_in_statement828); 

                    }
                    break;
                case 2 :
                    // src/antlr3/Plumhead.g:97:5: IF '(' relational_expression ')' '{' s1= statements '}' ( ELSE '{' s2= statements '}' -> ^( IF relational_expression ^( STMTS $s1) ^( STMTS $s2) ) | -> ^( IF relational_expression ^( STMTS $s1) ) )
                    {
                    IF15=(Token)input.LT(1);
                    match(input,IF,FOLLOW_IF_in_statement836); 
                    list_IF.add(IF15);

                    char_literal16=(Token)input.LT(1);
                    match(input,30,FOLLOW_30_in_statement838); 
                    list_30.add(char_literal16);

                    pushFollow(FOLLOW_relational_expression_in_statement840);
                    relational_expression17=relational_expression();
                    _fsp--;

                    list_relational_expression.add(relational_expression17.getTree());
                    char_literal18=(Token)input.LT(1);
                    match(input,31,FOLLOW_31_in_statement842); 
                    list_31.add(char_literal18);

                    char_literal19=(Token)input.LT(1);
                    match(input,32,FOLLOW_32_in_statement844); 
                    list_32.add(char_literal19);

                    pushFollow(FOLLOW_statements_in_statement848);
                    s1=statements();
                    _fsp--;

                    list_statements.add(s1.getTree());
                    char_literal20=(Token)input.LT(1);
                    match(input,33,FOLLOW_33_in_statement850); 
                    list_33.add(char_literal20);

                    // src/antlr3/Plumhead.g:98:5: ( ELSE '{' s2= statements '}' -> ^( IF relational_expression ^( STMTS $s1) ^( STMTS $s2) ) | -> ^( IF relational_expression ^( STMTS $s1) ) )
                    int alt4=2;
                    int LA4_0 = input.LA(1);
                    if ( (LA4_0==ELSE) ) {
                        alt4=1;
                    }
                    else if ( (LA4_0==CODE_END||LA4_0==ECHO||LA4_0==SCALAR||LA4_0==IF||LA4_0==33) ) {
                        alt4=2;
                    }
                    else {
                        NoViableAltException nvae =
                            new NoViableAltException("98:5: ( ELSE '{' s2= statements '}' -> ^( IF relational_expression ^( STMTS $s1) ^( STMTS $s2) ) | -> ^( IF relational_expression ^( STMTS $s1) ) )", 4, 0, input);

                        throw nvae;
                    }
                    switch (alt4) {
                        case 1 :
                            // src/antlr3/Plumhead.g:98:7: ELSE '{' s2= statements '}'
                            {
                            ELSE21=(Token)input.LT(1);
                            match(input,ELSE,FOLLOW_ELSE_in_statement858); 
                            list_ELSE.add(ELSE21);

                            char_literal22=(Token)input.LT(1);
                            match(input,32,FOLLOW_32_in_statement860); 
                            list_32.add(char_literal22);

                            pushFollow(FOLLOW_statements_in_statement864);
                            s2=statements();
                            _fsp--;

                            list_statements.add(s2.getTree());
                            char_literal23=(Token)input.LT(1);
                            match(input,33,FOLLOW_33_in_statement866); 
                            list_33.add(char_literal23);


                            // AST REWRITE
                            int i_0 = 0;
                            retval.tree = root_0;
                            root_0 = (CommonTree)adaptor.nil();
                            // 98:34: -> ^( IF relational_expression ^( STMTS $s1) ^( STMTS $s2) )
                            {
                                // src/antlr3/Plumhead.g:98:37: ^( IF relational_expression ^( STMTS $s1) ^( STMTS $s2) )
                                {
                                CommonTree root_1 = (CommonTree)adaptor.nil();
                                root_1 = (CommonTree)adaptor.becomeRoot((Token)list_IF.get(i_0), root_1);

                                adaptor.addChild(root_1, list_relational_expression.get(i_0));
                                // src/antlr3/Plumhead.g:98:65: ^( STMTS $s1)
                                {
                                CommonTree root_2 = (CommonTree)adaptor.nil();
                                root_2 = (CommonTree)adaptor.becomeRoot(adaptor.create(STMTS, "STMTS"), root_2);

                                adaptor.addChild(root_2, s1.tree);

                                adaptor.addChild(root_1, root_2);
                                }
                                // src/antlr3/Plumhead.g:98:80: ^( STMTS $s2)
                                {
                                CommonTree root_2 = (CommonTree)adaptor.nil();
                                root_2 = (CommonTree)adaptor.becomeRoot(adaptor.create(STMTS, "STMTS"), root_2);

                                adaptor.addChild(root_2, s2.tree);

                                adaptor.addChild(root_1, root_2);
                                }

                                adaptor.addChild(root_0, root_1);
                                }

                            }



                            }
                            break;
                        case 2 :
                            // src/antlr3/Plumhead.g:99:34: 
                            {

                            // AST REWRITE
                            int i_0 = 0;
                            retval.tree = root_0;
                            root_0 = (CommonTree)adaptor.nil();
                            // 99:34: -> ^( IF relational_expression ^( STMTS $s1) )
                            {
                                // src/antlr3/Plumhead.g:99:37: ^( IF relational_expression ^( STMTS $s1) )
                                {
                                CommonTree root_1 = (CommonTree)adaptor.nil();
                                root_1 = (CommonTree)adaptor.becomeRoot((Token)list_IF.get(i_0), root_1);

                                adaptor.addChild(root_1, list_relational_expression.get(i_0));
                                // src/antlr3/Plumhead.g:99:65: ^( STMTS $s1)
                                {
                                CommonTree root_2 = (CommonTree)adaptor.nil();
                                root_2 = (CommonTree)adaptor.becomeRoot(adaptor.create(STMTS, "STMTS"), root_2);

                                adaptor.addChild(root_2, s1.tree);

                                adaptor.addChild(root_1, root_2);
                                }

                                adaptor.addChild(root_0, root_1);
                                }

                            }



                            }
                            break;

                    }


                    }
                    break;
                case 3 :
                    // src/antlr3/Plumhead.g:101:5: CODE_END SEA CODE_START
                    {
                    CODE_END24=(Token)input.LT(1);
                    match(input,CODE_END,FOLLOW_CODE_END_in_statement959); 
                    list_CODE_END.add(CODE_END24);

                    SEA25=(Token)input.LT(1);
                    match(input,SEA,FOLLOW_SEA_in_statement961); 
                    list_SEA.add(SEA25);

                    CODE_START26=(Token)input.LT(1);
                    match(input,CODE_START,FOLLOW_CODE_START_in_statement963); 
                    list_CODE_START.add(CODE_START26);


                    // AST REWRITE
                    int i_0 = 0;
                    retval.tree = root_0;
                    root_0 = (CommonTree)adaptor.nil();
                    // 101:29: -> ^( ECHO NOQUOTE_STRING[$SEA] )
                    {
                        // src/antlr3/Plumhead.g:101:32: ^( ECHO NOQUOTE_STRING[$SEA] )
                        {
                        CommonTree root_1 = (CommonTree)adaptor.nil();
                        root_1 = (CommonTree)adaptor.becomeRoot(adaptor.create(ECHO, "ECHO"), root_1);

                        adaptor.addChild(root_1, adaptor.create(NOQUOTE_STRING, SEA25));

                        adaptor.addChild(root_0, root_1);
                        }

                    }



                    }
                    break;
                case 4 :
                    // src/antlr3/Plumhead.g:102:5: SCALAR ASSIGN_OP^ expression ';'!
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    SCALAR27=(Token)input.LT(1);
                    match(input,SCALAR,FOLLOW_SCALAR_in_statement980); 
                    SCALAR27_tree = (CommonTree)adaptor.create(SCALAR27);
                    adaptor.addChild(root_0, SCALAR27_tree);

                    ASSIGN_OP28=(Token)input.LT(1);
                    match(input,ASSIGN_OP,FOLLOW_ASSIGN_OP_in_statement982); 
                    ASSIGN_OP28_tree = (CommonTree)adaptor.create(ASSIGN_OP28);
                    root_0 = (CommonTree)adaptor.becomeRoot(ASSIGN_OP28_tree, root_0);

                    pushFollow(FOLLOW_expression_in_statement985);
                    expression29=expression();
                    _fsp--;

                    adaptor.addChild(root_0, expression29.getTree());
                    char_literal30=(Token)input.LT(1);
                    match(input,29,FOLLOW_29_in_statement987); 

                    }
                    break;
                case 5 :
                    // src/antlr3/Plumhead.g:103:5: s= SCALAR '[' key= expression ']' ASSIGN_OP val= expression ';'
                    {
                    s=(Token)input.LT(1);
                    match(input,SCALAR,FOLLOW_SCALAR_in_statement996); 
                    list_SCALAR.add(s);

                    char_literal31=(Token)input.LT(1);
                    match(input,34,FOLLOW_34_in_statement998); 
                    list_34.add(char_literal31);

                    pushFollow(FOLLOW_expression_in_statement1002);
                    key=expression();
                    _fsp--;

                    list_expression.add(key.getTree());
                    char_literal32=(Token)input.LT(1);
                    match(input,35,FOLLOW_35_in_statement1004); 
                    list_35.add(char_literal32);

                    ASSIGN_OP33=(Token)input.LT(1);
                    match(input,ASSIGN_OP,FOLLOW_ASSIGN_OP_in_statement1006); 
                    list_ASSIGN_OP.add(ASSIGN_OP33);

                    pushFollow(FOLLOW_expression_in_statement1010);
                    val=expression();
                    _fsp--;

                    list_expression.add(val.getTree());
                    char_literal34=(Token)input.LT(1);
                    match(input,29,FOLLOW_29_in_statement1012); 
                    list_29.add(char_literal34);


                    // AST REWRITE
                    int i_0 = 0;
                    retval.tree = root_0;
                    root_0 = (CommonTree)adaptor.nil();
                    // 103:66: -> ^( ASSIGN_OP ^( ARRAY[$s] $key) $val)
                    {
                        // src/antlr3/Plumhead.g:103:69: ^( ASSIGN_OP ^( ARRAY[$s] $key) $val)
                        {
                        CommonTree root_1 = (CommonTree)adaptor.nil();
                        root_1 = (CommonTree)adaptor.becomeRoot((Token)list_ASSIGN_OP.get(i_0), root_1);

                        // src/antlr3/Plumhead.g:103:82: ^( ARRAY[$s] $key)
                        {
                        CommonTree root_2 = (CommonTree)adaptor.nil();
                        root_2 = (CommonTree)adaptor.becomeRoot(adaptor.create(ARRAY, s), root_2);

                        adaptor.addChild(root_2, key.tree);

                        adaptor.addChild(root_1, root_2);
                        }
                        adaptor.addChild(root_1, val.tree);

                        adaptor.addChild(root_0, root_1);
                        }

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
    // $ANTLR end statement

    public static class expression_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start expression
    // src/antlr3/Plumhead.g:106:1: expression : ( DOUBLEQUOTE_STRING | SINGLEQUOTE_STRING | bitwise_expression | s= SCALAR ( '[' key= expression ']' -> ^( ARRAY[$s] $key) )? );
    public expression_return expression() throws RecognitionException {
        expression_return retval = new expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token s=null;
        Token DOUBLEQUOTE_STRING35=null;
        Token SINGLEQUOTE_STRING36=null;
        Token char_literal38=null;
        Token char_literal39=null;
        expression_return key = null;

        bitwise_expression_return bitwise_expression37 = null;

        List list_expression=new ArrayList();
        List list_35=new ArrayList();
        List list_SCALAR=new ArrayList();
        List list_34=new ArrayList();
        CommonTree s_tree=null;
        CommonTree DOUBLEQUOTE_STRING35_tree=null;
        CommonTree SINGLEQUOTE_STRING36_tree=null;
        CommonTree char_literal38_tree=null;
        CommonTree char_literal39_tree=null;

        try {
            // src/antlr3/Plumhead.g:107:5: ( DOUBLEQUOTE_STRING | SINGLEQUOTE_STRING | bitwise_expression | s= SCALAR ( '[' key= expression ']' -> ^( ARRAY[$s] $key) )? )
            int alt7=4;
            switch ( input.LA(1) ) {
            case DOUBLEQUOTE_STRING:
                alt7=1;
                break;
            case SINGLEQUOTE_STRING:
                alt7=2;
                break;
            case INTEGER:
            case NUMBER:
            case MINUS:
            case 30:
                alt7=3;
                break;
            case SCALAR:
                alt7=4;
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("106:1: expression : ( DOUBLEQUOTE_STRING | SINGLEQUOTE_STRING | bitwise_expression | s= SCALAR ( '[' key= expression ']' -> ^( ARRAY[$s] $key) )? );", 7, 0, input);

                throw nvae;
            }

            switch (alt7) {
                case 1 :
                    // src/antlr3/Plumhead.g:107:5: DOUBLEQUOTE_STRING
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    DOUBLEQUOTE_STRING35=(Token)input.LT(1);
                    match(input,DOUBLEQUOTE_STRING,FOLLOW_DOUBLEQUOTE_STRING_in_expression1046); 
                    DOUBLEQUOTE_STRING35_tree = (CommonTree)adaptor.create(DOUBLEQUOTE_STRING35);
                    adaptor.addChild(root_0, DOUBLEQUOTE_STRING35_tree);


                    }
                    break;
                case 2 :
                    // src/antlr3/Plumhead.g:108:5: SINGLEQUOTE_STRING
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    SINGLEQUOTE_STRING36=(Token)input.LT(1);
                    match(input,SINGLEQUOTE_STRING,FOLLOW_SINGLEQUOTE_STRING_in_expression1052); 
                    SINGLEQUOTE_STRING36_tree = (CommonTree)adaptor.create(SINGLEQUOTE_STRING36);
                    adaptor.addChild(root_0, SINGLEQUOTE_STRING36_tree);


                    }
                    break;
                case 3 :
                    // src/antlr3/Plumhead.g:109:5: bitwise_expression
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    pushFollow(FOLLOW_bitwise_expression_in_expression1058);
                    bitwise_expression37=bitwise_expression();
                    _fsp--;

                    adaptor.addChild(root_0, bitwise_expression37.getTree());

                    }
                    break;
                case 4 :
                    // src/antlr3/Plumhead.g:110:5: s= SCALAR ( '[' key= expression ']' -> ^( ARRAY[$s] $key) )?
                    {
                    s=(Token)input.LT(1);
                    match(input,SCALAR,FOLLOW_SCALAR_in_expression1066); 
                    list_SCALAR.add(s);

                    // src/antlr3/Plumhead.g:110:14: ( '[' key= expression ']' -> ^( ARRAY[$s] $key) )?
                    int alt6=2;
                    int LA6_0 = input.LA(1);
                    if ( (LA6_0==34) ) {
                        alt6=1;
                    }
                    switch (alt6) {
                        case 1 :
                            // src/antlr3/Plumhead.g:110:16: '[' key= expression ']'
                            {
                            char_literal38=(Token)input.LT(1);
                            match(input,34,FOLLOW_34_in_expression1070); 
                            list_34.add(char_literal38);

                            pushFollow(FOLLOW_expression_in_expression1074);
                            key=expression();
                            _fsp--;

                            list_expression.add(key.getTree());
                            char_literal39=(Token)input.LT(1);
                            match(input,35,FOLLOW_35_in_expression1076); 
                            list_35.add(char_literal39);


                            // AST REWRITE
                            int i_0 = 0;
                            retval.tree = root_0;
                            root_0 = (CommonTree)adaptor.nil();
                            // 110:39: -> ^( ARRAY[$s] $key)
                            {
                                // src/antlr3/Plumhead.g:110:42: ^( ARRAY[$s] $key)
                                {
                                CommonTree root_1 = (CommonTree)adaptor.nil();
                                root_1 = (CommonTree)adaptor.becomeRoot(adaptor.create(ARRAY, s), root_1);

                                adaptor.addChild(root_1, key.tree);

                                adaptor.addChild(root_0, root_1);
                                }

                            }



                            }
                            break;

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
    // $ANTLR end expression

    public static class bitwise_expression_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start bitwise_expression
    // src/antlr3/Plumhead.g:113:1: bitwise_expression : adding_expression ( BITWISE_OP^ adding_expression )* ;
    public bitwise_expression_return bitwise_expression() throws RecognitionException {
        bitwise_expression_return retval = new bitwise_expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token BITWISE_OP41=null;
        adding_expression_return adding_expression40 = null;

        adding_expression_return adding_expression42 = null;


        CommonTree BITWISE_OP41_tree=null;

        try {
            // src/antlr3/Plumhead.g:114:5: ( adding_expression ( BITWISE_OP^ adding_expression )* )
            // src/antlr3/Plumhead.g:114:5: adding_expression ( BITWISE_OP^ adding_expression )*
            {
            root_0 = (CommonTree)adaptor.nil();

            pushFollow(FOLLOW_adding_expression_in_bitwise_expression1104);
            adding_expression40=adding_expression();
            _fsp--;

            adaptor.addChild(root_0, adding_expression40.getTree());
            // src/antlr3/Plumhead.g:114:23: ( BITWISE_OP^ adding_expression )*
            loop8:
            do {
                int alt8=2;
                int LA8_0 = input.LA(1);
                if ( (LA8_0==BITWISE_OP) ) {
                    alt8=1;
                }


                switch (alt8) {
            	case 1 :
            	    // src/antlr3/Plumhead.g:114:25: BITWISE_OP^ adding_expression
            	    {
            	    BITWISE_OP41=(Token)input.LT(1);
            	    match(input,BITWISE_OP,FOLLOW_BITWISE_OP_in_bitwise_expression1108); 
            	    BITWISE_OP41_tree = (CommonTree)adaptor.create(BITWISE_OP41);
            	    root_0 = (CommonTree)adaptor.becomeRoot(BITWISE_OP41_tree, root_0);

            	    pushFollow(FOLLOW_adding_expression_in_bitwise_expression1111);
            	    adding_expression42=adding_expression();
            	    _fsp--;

            	    adaptor.addChild(root_0, adding_expression42.getTree());

            	    }
            	    break;

            	default :
            	    break loop8;
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
    // $ANTLR end bitwise_expression

    public static class adding_expression_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start adding_expression
    // src/antlr3/Plumhead.g:117:1: adding_expression : multiplying_expression ( ( PLUS^ | MINUS^ ) multiplying_expression )* ;
    public adding_expression_return adding_expression() throws RecognitionException {
        adding_expression_return retval = new adding_expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token PLUS44=null;
        Token MINUS45=null;
        multiplying_expression_return multiplying_expression43 = null;

        multiplying_expression_return multiplying_expression46 = null;


        CommonTree PLUS44_tree=null;
        CommonTree MINUS45_tree=null;

        try {
            // src/antlr3/Plumhead.g:118:5: ( multiplying_expression ( ( PLUS^ | MINUS^ ) multiplying_expression )* )
            // src/antlr3/Plumhead.g:118:5: multiplying_expression ( ( PLUS^ | MINUS^ ) multiplying_expression )*
            {
            root_0 = (CommonTree)adaptor.nil();

            pushFollow(FOLLOW_multiplying_expression_in_adding_expression1127);
            multiplying_expression43=multiplying_expression();
            _fsp--;

            adaptor.addChild(root_0, multiplying_expression43.getTree());
            // src/antlr3/Plumhead.g:118:28: ( ( PLUS^ | MINUS^ ) multiplying_expression )*
            loop10:
            do {
                int alt10=2;
                int LA10_0 = input.LA(1);
                if ( ((LA10_0>=MINUS && LA10_0<=PLUS)) ) {
                    alt10=1;
                }


                switch (alt10) {
            	case 1 :
            	    // src/antlr3/Plumhead.g:118:30: ( PLUS^ | MINUS^ ) multiplying_expression
            	    {
            	    // src/antlr3/Plumhead.g:118:30: ( PLUS^ | MINUS^ )
            	    int alt9=2;
            	    int LA9_0 = input.LA(1);
            	    if ( (LA9_0==PLUS) ) {
            	        alt9=1;
            	    }
            	    else if ( (LA9_0==MINUS) ) {
            	        alt9=2;
            	    }
            	    else {
            	        NoViableAltException nvae =
            	            new NoViableAltException("118:30: ( PLUS^ | MINUS^ )", 9, 0, input);

            	        throw nvae;
            	    }
            	    switch (alt9) {
            	        case 1 :
            	            // src/antlr3/Plumhead.g:118:32: PLUS^
            	            {
            	            PLUS44=(Token)input.LT(1);
            	            match(input,PLUS,FOLLOW_PLUS_in_adding_expression1133); 
            	            PLUS44_tree = (CommonTree)adaptor.create(PLUS44);
            	            root_0 = (CommonTree)adaptor.becomeRoot(PLUS44_tree, root_0);


            	            }
            	            break;
            	        case 2 :
            	            // src/antlr3/Plumhead.g:118:40: MINUS^
            	            {
            	            MINUS45=(Token)input.LT(1);
            	            match(input,MINUS,FOLLOW_MINUS_in_adding_expression1138); 
            	            MINUS45_tree = (CommonTree)adaptor.create(MINUS45);
            	            root_0 = (CommonTree)adaptor.becomeRoot(MINUS45_tree, root_0);


            	            }
            	            break;

            	    }

            	    pushFollow(FOLLOW_multiplying_expression_in_adding_expression1143);
            	    multiplying_expression46=multiplying_expression();
            	    _fsp--;

            	    adaptor.addChild(root_0, multiplying_expression46.getTree());

            	    }
            	    break;

            	default :
            	    break loop10;
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
    // src/antlr3/Plumhead.g:121:1: multiplying_expression : unary_expression ( MUL_OP^ unary_expression )* ;
    public multiplying_expression_return multiplying_expression() throws RecognitionException {
        multiplying_expression_return retval = new multiplying_expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token MUL_OP48=null;
        unary_expression_return unary_expression47 = null;

        unary_expression_return unary_expression49 = null;


        CommonTree MUL_OP48_tree=null;

        try {
            // src/antlr3/Plumhead.g:122:5: ( unary_expression ( MUL_OP^ unary_expression )* )
            // src/antlr3/Plumhead.g:122:5: unary_expression ( MUL_OP^ unary_expression )*
            {
            root_0 = (CommonTree)adaptor.nil();

            pushFollow(FOLLOW_unary_expression_in_multiplying_expression1160);
            unary_expression47=unary_expression();
            _fsp--;

            adaptor.addChild(root_0, unary_expression47.getTree());
            // src/antlr3/Plumhead.g:122:22: ( MUL_OP^ unary_expression )*
            loop11:
            do {
                int alt11=2;
                int LA11_0 = input.LA(1);
                if ( (LA11_0==MUL_OP) ) {
                    alt11=1;
                }


                switch (alt11) {
            	case 1 :
            	    // src/antlr3/Plumhead.g:122:24: MUL_OP^ unary_expression
            	    {
            	    MUL_OP48=(Token)input.LT(1);
            	    match(input,MUL_OP,FOLLOW_MUL_OP_in_multiplying_expression1164); 
            	    MUL_OP48_tree = (CommonTree)adaptor.create(MUL_OP48);
            	    root_0 = (CommonTree)adaptor.becomeRoot(MUL_OP48_tree, root_0);

            	    pushFollow(FOLLOW_unary_expression_in_multiplying_expression1167);
            	    unary_expression49=unary_expression();
            	    _fsp--;

            	    adaptor.addChild(root_0, unary_expression49.getTree());

            	    }
            	    break;

            	default :
            	    break loop11;
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
    // src/antlr3/Plumhead.g:125:1: unary_expression : ( postfix_expression | MINUS postfix_expression -> ^( PREFIX[\"-\"] postfix_expression ) );
    public unary_expression_return unary_expression() throws RecognitionException {
        unary_expression_return retval = new unary_expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token MINUS51=null;
        postfix_expression_return postfix_expression50 = null;

        postfix_expression_return postfix_expression52 = null;

        List list_postfix_expression=new ArrayList();
        List list_MINUS=new ArrayList();
        CommonTree MINUS51_tree=null;

        try {
            // src/antlr3/Plumhead.g:126:5: ( postfix_expression | MINUS postfix_expression -> ^( PREFIX[\"-\"] postfix_expression ) )
            int alt12=2;
            int LA12_0 = input.LA(1);
            if ( ((LA12_0>=INTEGER && LA12_0<=NUMBER)||LA12_0==30) ) {
                alt12=1;
            }
            else if ( (LA12_0==MINUS) ) {
                alt12=2;
            }
            else {
                NoViableAltException nvae =
                    new NoViableAltException("125:1: unary_expression : ( postfix_expression | MINUS postfix_expression -> ^( PREFIX[\"-\"] postfix_expression ) );", 12, 0, input);

                throw nvae;
            }
            switch (alt12) {
                case 1 :
                    // src/antlr3/Plumhead.g:126:5: postfix_expression
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    pushFollow(FOLLOW_postfix_expression_in_unary_expression1183);
                    postfix_expression50=postfix_expression();
                    _fsp--;

                    adaptor.addChild(root_0, postfix_expression50.getTree());

                    }
                    break;
                case 2 :
                    // src/antlr3/Plumhead.g:127:5: MINUS postfix_expression
                    {
                    MINUS51=(Token)input.LT(1);
                    match(input,MINUS,FOLLOW_MINUS_in_unary_expression1189); 
                    list_MINUS.add(MINUS51);

                    pushFollow(FOLLOW_postfix_expression_in_unary_expression1191);
                    postfix_expression52=postfix_expression();
                    _fsp--;

                    list_postfix_expression.add(postfix_expression52.getTree());

                    // AST REWRITE
                    int i_0 = 0;
                    retval.tree = root_0;
                    root_0 = (CommonTree)adaptor.nil();
                    // 127:30: -> ^( PREFIX[\"-\"] postfix_expression )
                    {
                        // src/antlr3/Plumhead.g:127:33: ^( PREFIX[\"-\"] postfix_expression )
                        {
                        CommonTree root_1 = (CommonTree)adaptor.nil();
                        root_1 = (CommonTree)adaptor.becomeRoot(adaptor.create(PREFIX, "-"), root_1);

                        adaptor.addChild(root_1, list_postfix_expression.get(i_0));

                        adaptor.addChild(root_0, root_1);
                        }

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
    // $ANTLR end unary_expression

    public static class postfix_expression_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start postfix_expression
    // src/antlr3/Plumhead.g:130:1: postfix_expression : ( NUMBER | INTEGER | '(' expression ')' -> expression );
    public postfix_expression_return postfix_expression() throws RecognitionException {
        postfix_expression_return retval = new postfix_expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token NUMBER53=null;
        Token INTEGER54=null;
        Token char_literal55=null;
        Token char_literal57=null;
        expression_return expression56 = null;

        List list_expression=new ArrayList();
        List list_30=new ArrayList();
        List list_31=new ArrayList();
        CommonTree NUMBER53_tree=null;
        CommonTree INTEGER54_tree=null;
        CommonTree char_literal55_tree=null;
        CommonTree char_literal57_tree=null;

        try {
            // src/antlr3/Plumhead.g:131:5: ( NUMBER | INTEGER | '(' expression ')' -> expression )
            int alt13=3;
            switch ( input.LA(1) ) {
            case NUMBER:
                alt13=1;
                break;
            case INTEGER:
                alt13=2;
                break;
            case 30:
                alt13=3;
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("130:1: postfix_expression : ( NUMBER | INTEGER | '(' expression ')' -> expression );", 13, 0, input);

                throw nvae;
            }

            switch (alt13) {
                case 1 :
                    // src/antlr3/Plumhead.g:131:5: NUMBER
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    NUMBER53=(Token)input.LT(1);
                    match(input,NUMBER,FOLLOW_NUMBER_in_postfix_expression1215); 
                    NUMBER53_tree = (CommonTree)adaptor.create(NUMBER53);
                    adaptor.addChild(root_0, NUMBER53_tree);


                    }
                    break;
                case 2 :
                    // src/antlr3/Plumhead.g:132:5: INTEGER
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    INTEGER54=(Token)input.LT(1);
                    match(input,INTEGER,FOLLOW_INTEGER_in_postfix_expression1221); 
                    INTEGER54_tree = (CommonTree)adaptor.create(INTEGER54);
                    adaptor.addChild(root_0, INTEGER54_tree);


                    }
                    break;
                case 3 :
                    // src/antlr3/Plumhead.g:133:5: '(' expression ')'
                    {
                    char_literal55=(Token)input.LT(1);
                    match(input,30,FOLLOW_30_in_postfix_expression1227); 
                    list_30.add(char_literal55);

                    pushFollow(FOLLOW_expression_in_postfix_expression1229);
                    expression56=expression();
                    _fsp--;

                    list_expression.add(expression56.getTree());
                    char_literal57=(Token)input.LT(1);
                    match(input,31,FOLLOW_31_in_postfix_expression1231); 
                    list_31.add(char_literal57);


                    // AST REWRITE
                    int i_0 = 0;
                    retval.tree = root_0;
                    root_0 = (CommonTree)adaptor.nil();
                    // 133:24: -> expression
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


 

    public static final BitSet FOLLOW_sea_or_code_in_program690 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_sea_in_sea_or_code715 = new BitSet(new long[]{0x0000000000000602L});
    public static final BitSet FOLLOW_code_in_sea_or_code719 = new BitSet(new long[]{0x0000000000000602L});
    public static final BitSet FOLLOW_SEA_in_sea736 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_CODE_START_in_code760 = new BitSet(new long[]{0x0000000008028800L});
    public static final BitSet FOLLOW_statements_in_code762 = new BitSet(new long[]{0x0000000000000800L});
    public static final BitSet FOLLOW_CODE_END_in_code764 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_expression_in_relational_expression782 = new BitSet(new long[]{0x0000000004000002L});
    public static final BitSet FOLLOW_REL_OP_in_relational_expression786 = new BitSet(new long[]{0x00000000403A6000L});
    public static final BitSet FOLLOW_expression_in_relational_expression789 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_statement_in_statements807 = new BitSet(new long[]{0x0000000008028802L});
    public static final BitSet FOLLOW_ECHO_in_statement823 = new BitSet(new long[]{0x00000000403A6000L});
    public static final BitSet FOLLOW_expression_in_statement826 = new BitSet(new long[]{0x0000000020000000L});
    public static final BitSet FOLLOW_29_in_statement828 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_IF_in_statement836 = new BitSet(new long[]{0x0000000040000000L});
    public static final BitSet FOLLOW_30_in_statement838 = new BitSet(new long[]{0x00000000403A6000L});
    public static final BitSet FOLLOW_relational_expression_in_statement840 = new BitSet(new long[]{0x0000000080000000L});
    public static final BitSet FOLLOW_31_in_statement842 = new BitSet(new long[]{0x0000000100000000L});
    public static final BitSet FOLLOW_32_in_statement844 = new BitSet(new long[]{0x0000000208028800L});
    public static final BitSet FOLLOW_statements_in_statement848 = new BitSet(new long[]{0x0000000200000000L});
    public static final BitSet FOLLOW_33_in_statement850 = new BitSet(new long[]{0x0000000010000002L});
    public static final BitSet FOLLOW_ELSE_in_statement858 = new BitSet(new long[]{0x0000000100000000L});
    public static final BitSet FOLLOW_32_in_statement860 = new BitSet(new long[]{0x0000000208028800L});
    public static final BitSet FOLLOW_statements_in_statement864 = new BitSet(new long[]{0x0000000200000000L});
    public static final BitSet FOLLOW_33_in_statement866 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_CODE_END_in_statement959 = new BitSet(new long[]{0x0000000000000200L});
    public static final BitSet FOLLOW_SEA_in_statement961 = new BitSet(new long[]{0x0000000000000400L});
    public static final BitSet FOLLOW_CODE_START_in_statement963 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SCALAR_in_statement980 = new BitSet(new long[]{0x0000000002000000L});
    public static final BitSet FOLLOW_ASSIGN_OP_in_statement982 = new BitSet(new long[]{0x00000000403A6000L});
    public static final BitSet FOLLOW_expression_in_statement985 = new BitSet(new long[]{0x0000000020000000L});
    public static final BitSet FOLLOW_29_in_statement987 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SCALAR_in_statement996 = new BitSet(new long[]{0x0000000400000000L});
    public static final BitSet FOLLOW_34_in_statement998 = new BitSet(new long[]{0x00000000403A6000L});
    public static final BitSet FOLLOW_expression_in_statement1002 = new BitSet(new long[]{0x0000000800000000L});
    public static final BitSet FOLLOW_35_in_statement1004 = new BitSet(new long[]{0x0000000002000000L});
    public static final BitSet FOLLOW_ASSIGN_OP_in_statement1006 = new BitSet(new long[]{0x00000000403A6000L});
    public static final BitSet FOLLOW_expression_in_statement1010 = new BitSet(new long[]{0x0000000020000000L});
    public static final BitSet FOLLOW_29_in_statement1012 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_DOUBLEQUOTE_STRING_in_expression1046 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SINGLEQUOTE_STRING_in_expression1052 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_bitwise_expression_in_expression1058 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SCALAR_in_expression1066 = new BitSet(new long[]{0x0000000400000002L});
    public static final BitSet FOLLOW_34_in_expression1070 = new BitSet(new long[]{0x00000000403A6000L});
    public static final BitSet FOLLOW_expression_in_expression1074 = new BitSet(new long[]{0x0000000800000000L});
    public static final BitSet FOLLOW_35_in_expression1076 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_adding_expression_in_bitwise_expression1104 = new BitSet(new long[]{0x0000000001000002L});
    public static final BitSet FOLLOW_BITWISE_OP_in_bitwise_expression1108 = new BitSet(new long[]{0x0000000040380000L});
    public static final BitSet FOLLOW_adding_expression_in_bitwise_expression1111 = new BitSet(new long[]{0x0000000001000002L});
    public static final BitSet FOLLOW_multiplying_expression_in_adding_expression1127 = new BitSet(new long[]{0x0000000000600002L});
    public static final BitSet FOLLOW_PLUS_in_adding_expression1133 = new BitSet(new long[]{0x0000000040380000L});
    public static final BitSet FOLLOW_MINUS_in_adding_expression1138 = new BitSet(new long[]{0x0000000040380000L});
    public static final BitSet FOLLOW_multiplying_expression_in_adding_expression1143 = new BitSet(new long[]{0x0000000000600002L});
    public static final BitSet FOLLOW_unary_expression_in_multiplying_expression1160 = new BitSet(new long[]{0x0000000000800002L});
    public static final BitSet FOLLOW_MUL_OP_in_multiplying_expression1164 = new BitSet(new long[]{0x0000000040380000L});
    public static final BitSet FOLLOW_unary_expression_in_multiplying_expression1167 = new BitSet(new long[]{0x0000000000800002L});
    public static final BitSet FOLLOW_postfix_expression_in_unary_expression1183 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_MINUS_in_unary_expression1189 = new BitSet(new long[]{0x0000000040180000L});
    public static final BitSet FOLLOW_postfix_expression_in_unary_expression1191 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_NUMBER_in_postfix_expression1215 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_INTEGER_in_postfix_expression1221 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_30_in_postfix_expression1227 = new BitSet(new long[]{0x00000000403A6000L});
    public static final BitSet FOLLOW_expression_in_postfix_expression1229 = new BitSet(new long[]{0x0000000080000000L});
    public static final BitSet FOLLOW_31_in_postfix_expression1231 = new BitSet(new long[]{0x0000000000000002L});

}