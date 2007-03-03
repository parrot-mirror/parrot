// $ANTLR 3.0b6 src/antlr3/Plumhead.g 2007-03-03 21:45:36

import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;


import org.antlr.runtime.tree.*;

public class PlumheadParser extends Parser {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "PROGRAM", "NOQUOTE_STRING", "STMTS", "SCALAR", "ARRAY", "FUNCTION", "PREFIX", "SEA", "CODE_START", "CODE_END", "WS", "DOUBLEQUOTE_STRING", "SINGLEQUOTE_STRING", "ECHO", "VAR_DUMP", "PAREN_OPEN", "PAREN_CLOSE", "IDENT", "VAR_NAME", "DIGITS", "INTEGER", "NUMBER", "MINUS", "PLUS", "MUL_OP", "BITWISE_OP", "ASSIGN_OP", "REL_OP", "IF", "ELSE", "';'", "'{'", "'}'", "'['", "']'"
    };
    public static final int CODE_START=12;
    public static final int MINUS=26;
    public static final int VAR_NAME=22;
    public static final int DIGITS=23;
    public static final int IDENT=21;
    public static final int ARRAY=8;
    public static final int BITWISE_OP=29;
    public static final int NUMBER=25;
    public static final int WS=14;
    public static final int SINGLEQUOTE_STRING=16;
    public static final int MUL_OP=28;
    public static final int SEA=11;
    public static final int CODE_END=13;
    public static final int STMTS=6;
    public static final int PROGRAM=4;
    public static final int PREFIX=10;
    public static final int PAREN_OPEN=19;
    public static final int ASSIGN_OP=30;
    public static final int INTEGER=24;
    public static final int DOUBLEQUOTE_STRING=15;
    public static final int PAREN_CLOSE=20;
    public static final int ECHO=17;
    public static final int ELSE=33;
    public static final int FUNCTION=9;
    public static final int IF=32;
    public static final int EOF=-1;
    public static final int VAR_DUMP=18;
    public static final int REL_OP=31;
    public static final int PLUS=27;
    public static final int NOQUOTE_STRING=5;
    public static final int SCALAR=7;

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
    // src/antlr3/Plumhead.g:65:1: program : sea_or_code -> ^( PROGRAM sea_or_code ) ;
    public program_return program() throws RecognitionException {
        program_return retval = new program_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        sea_or_code_return sea_or_code1 = null;

        List list_sea_or_code=new ArrayList();

        try {
            // src/antlr3/Plumhead.g:66:5: ( sea_or_code -> ^( PROGRAM sea_or_code ) )
            // src/antlr3/Plumhead.g:66:5: sea_or_code
            {
            pushFollow(FOLLOW_sea_or_code_in_program828);
            sea_or_code1=sea_or_code();
            _fsp--;

            list_sea_or_code.add(sea_or_code1.getTree());

            // AST REWRITE
            int i_0 = 0;
            retval.tree = root_0;
            root_0 = (CommonTree)adaptor.nil();
            // 66:17: -> ^( PROGRAM sea_or_code )
            {
                // src/antlr3/Plumhead.g:66:20: ^( PROGRAM sea_or_code )
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
    // src/antlr3/Plumhead.g:69:1: sea_or_code : ( sea | code )+ ;
    public sea_or_code_return sea_or_code() throws RecognitionException {
        sea_or_code_return retval = new sea_or_code_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        sea_return sea2 = null;

        code_return code3 = null;



        try {
            // src/antlr3/Plumhead.g:70:5: ( ( sea | code )+ )
            // src/antlr3/Plumhead.g:70:5: ( sea | code )+
            {
            root_0 = (CommonTree)adaptor.nil();

            // src/antlr3/Plumhead.g:70:5: ( sea | code )+
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
            	    // src/antlr3/Plumhead.g:70:7: sea
            	    {
            	    pushFollow(FOLLOW_sea_in_sea_or_code853);
            	    sea2=sea();
            	    _fsp--;

            	    adaptor.addChild(root_0, sea2.getTree());

            	    }
            	    break;
            	case 2 :
            	    // src/antlr3/Plumhead.g:70:13: code
            	    {
            	    pushFollow(FOLLOW_code_in_sea_or_code857);
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
    // src/antlr3/Plumhead.g:73:1: sea : SEA -> ^( ECHO NOQUOTE_STRING[$SEA] ) ;
    public sea_return sea() throws RecognitionException {
        sea_return retval = new sea_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token SEA4=null;
        List list_SEA=new ArrayList();
        CommonTree SEA4_tree=null;

        try {
            // src/antlr3/Plumhead.g:74:5: ( SEA -> ^( ECHO NOQUOTE_STRING[$SEA] ) )
            // src/antlr3/Plumhead.g:74:5: SEA
            {
            SEA4=(Token)input.LT(1);
            match(input,SEA,FOLLOW_SEA_in_sea874); 
            list_SEA.add(SEA4);


            // AST REWRITE
            int i_0 = 0;
            retval.tree = root_0;
            root_0 = (CommonTree)adaptor.nil();
            // 74:9: -> ^( ECHO NOQUOTE_STRING[$SEA] )
            {
                // src/antlr3/Plumhead.g:74:12: ^( ECHO NOQUOTE_STRING[$SEA] )
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
    // src/antlr3/Plumhead.g:77:1: code : CODE_START statements ( CODE_END )? -> statements ;
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
            // src/antlr3/Plumhead.g:78:5: ( CODE_START statements ( CODE_END )? -> statements )
            // src/antlr3/Plumhead.g:78:5: CODE_START statements ( CODE_END )?
            {
            CODE_START5=(Token)input.LT(1);
            match(input,CODE_START,FOLLOW_CODE_START_in_code898); 
            list_CODE_START.add(CODE_START5);

            pushFollow(FOLLOW_statements_in_code900);
            statements6=statements();
            _fsp--;

            list_statements.add(statements6.getTree());
            // src/antlr3/Plumhead.g:78:27: ( CODE_END )?
            int alt2=2;
            int LA2_0 = input.LA(1);
            if ( (LA2_0==CODE_END) ) {
                alt2=1;
            }
            switch (alt2) {
                case 1 :
                    // src/antlr3/Plumhead.g:78:27: CODE_END
                    {
                    CODE_END7=(Token)input.LT(1);
                    match(input,CODE_END,FOLLOW_CODE_END_in_code902); 
                    list_CODE_END.add(CODE_END7);


                    }
                    break;

            }


            // AST REWRITE
            int i_0 = 0;
            retval.tree = root_0;
            root_0 = (CommonTree)adaptor.nil();
            // 78:37: -> statements
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
    // src/antlr3/Plumhead.g:81:1: relational_expression : expression ( REL_OP^ expression )? ;
    public relational_expression_return relational_expression() throws RecognitionException {
        relational_expression_return retval = new relational_expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token REL_OP9=null;
        expression_return expression8 = null;

        expression_return expression10 = null;


        CommonTree REL_OP9_tree=null;

        try {
            // src/antlr3/Plumhead.g:82:5: ( expression ( REL_OP^ expression )? )
            // src/antlr3/Plumhead.g:82:5: expression ( REL_OP^ expression )?
            {
            root_0 = (CommonTree)adaptor.nil();

            pushFollow(FOLLOW_expression_in_relational_expression921);
            expression8=expression();
            _fsp--;

            adaptor.addChild(root_0, expression8.getTree());
            // src/antlr3/Plumhead.g:82:16: ( REL_OP^ expression )?
            int alt3=2;
            int LA3_0 = input.LA(1);
            if ( (LA3_0==REL_OP) ) {
                alt3=1;
            }
            switch (alt3) {
                case 1 :
                    // src/antlr3/Plumhead.g:82:18: REL_OP^ expression
                    {
                    REL_OP9=(Token)input.LT(1);
                    match(input,REL_OP,FOLLOW_REL_OP_in_relational_expression925); 
                    REL_OP9_tree = (CommonTree)adaptor.create(REL_OP9);
                    root_0 = (CommonTree)adaptor.becomeRoot(REL_OP9_tree, root_0);

                    pushFollow(FOLLOW_expression_in_relational_expression928);
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
    // src/antlr3/Plumhead.g:85:1: statements : ( statement )* ;
    public statements_return statements() throws RecognitionException {
        statements_return retval = new statements_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        statement_return statement11 = null;



        try {
            // src/antlr3/Plumhead.g:86:5: ( ( statement )* )
            // src/antlr3/Plumhead.g:86:5: ( statement )*
            {
            root_0 = (CommonTree)adaptor.nil();

            // src/antlr3/Plumhead.g:86:5: ( statement )*
            loop4:
            do {
                int alt4=2;
                int LA4_0 = input.LA(1);
                if ( (LA4_0==CODE_END) ) {
                    int LA4_1 = input.LA(2);
                    if ( (LA4_1==SEA) ) {
                        int LA4_4 = input.LA(3);
                        if ( (LA4_4==CODE_START) ) {
                            alt4=1;
                        }


                    }


                }
                else if ( ((LA4_0>=ECHO && LA4_0<=VAR_DUMP)||LA4_0==VAR_NAME||LA4_0==IF) ) {
                    alt4=1;
                }


                switch (alt4) {
            	case 1 :
            	    // src/antlr3/Plumhead.g:86:7: statement
            	    {
            	    pushFollow(FOLLOW_statement_in_statements946);
            	    statement11=statement();
            	    _fsp--;

            	    adaptor.addChild(root_0, statement11.getTree());

            	    }
            	    break;

            	default :
            	    break loop4;
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
    // src/antlr3/Plumhead.g:89:1: statement : ( ECHO expression ';' -> ^( ECHO expression ) | VAR_DUMP PAREN_OPEN expression PAREN_CLOSE ';' -> ^( VAR_DUMP expression ) | IF PAREN_OPEN relational_expression PAREN_CLOSE '{' s1= statements '}' ( ELSE '{' s2= statements '}' -> ^( IF relational_expression ^( STMTS $s1) ^( STMTS $s2) ) | -> ^( IF relational_expression ^( STMTS $s1) ) ) | CODE_END SEA CODE_START -> ^( ECHO NOQUOTE_STRING[$SEA] ) | VAR_NAME ASSIGN_OP val= expression ';' -> ^( ASSIGN_OP SCALAR[$VAR_NAME] $val) | VAR_NAME '[' key= expression ']' ASSIGN_OP val= expression ';' -> ^( ASSIGN_OP ^( ARRAY[$VAR_NAME] $key) $val) );
    public statement_return statement() throws RecognitionException {
        statement_return retval = new statement_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token ECHO12=null;
        Token char_literal14=null;
        Token VAR_DUMP15=null;
        Token PAREN_OPEN16=null;
        Token PAREN_CLOSE18=null;
        Token char_literal19=null;
        Token IF20=null;
        Token PAREN_OPEN21=null;
        Token PAREN_CLOSE23=null;
        Token char_literal24=null;
        Token char_literal25=null;
        Token ELSE26=null;
        Token char_literal27=null;
        Token char_literal28=null;
        Token CODE_END29=null;
        Token SEA30=null;
        Token CODE_START31=null;
        Token VAR_NAME32=null;
        Token ASSIGN_OP33=null;
        Token char_literal34=null;
        Token VAR_NAME35=null;
        Token char_literal36=null;
        Token char_literal37=null;
        Token ASSIGN_OP38=null;
        Token char_literal39=null;
        statements_return s1 = null;

        statements_return s2 = null;

        expression_return val = null;

        expression_return key = null;

        expression_return expression13 = null;

        expression_return expression17 = null;

        relational_expression_return relational_expression22 = null;

        List list_statements=new ArrayList();
        List list_relational_expression=new ArrayList();
        List list_expression=new ArrayList();
        List list_PAREN_OPEN=new ArrayList();
        List list_CODE_START=new ArrayList();
        List list_ASSIGN_OP=new ArrayList();
        List list_VAR_NAME=new ArrayList();
        List list_PAREN_CLOSE=new ArrayList();
        List list_ECHO=new ArrayList();
        List list_ELSE=new ArrayList();
        List list_38=new ArrayList();
        List list_IF=new ArrayList();
        List list_36=new ArrayList();
        List list_VAR_DUMP=new ArrayList();
        List list_35=new ArrayList();
        List list_37=new ArrayList();
        List list_SEA=new ArrayList();
        List list_CODE_END=new ArrayList();
        List list_34=new ArrayList();
        CommonTree ECHO12_tree=null;
        CommonTree char_literal14_tree=null;
        CommonTree VAR_DUMP15_tree=null;
        CommonTree PAREN_OPEN16_tree=null;
        CommonTree PAREN_CLOSE18_tree=null;
        CommonTree char_literal19_tree=null;
        CommonTree IF20_tree=null;
        CommonTree PAREN_OPEN21_tree=null;
        CommonTree PAREN_CLOSE23_tree=null;
        CommonTree char_literal24_tree=null;
        CommonTree char_literal25_tree=null;
        CommonTree ELSE26_tree=null;
        CommonTree char_literal27_tree=null;
        CommonTree char_literal28_tree=null;
        CommonTree CODE_END29_tree=null;
        CommonTree SEA30_tree=null;
        CommonTree CODE_START31_tree=null;
        CommonTree VAR_NAME32_tree=null;
        CommonTree ASSIGN_OP33_tree=null;
        CommonTree char_literal34_tree=null;
        CommonTree VAR_NAME35_tree=null;
        CommonTree char_literal36_tree=null;
        CommonTree char_literal37_tree=null;
        CommonTree ASSIGN_OP38_tree=null;
        CommonTree char_literal39_tree=null;

        try {
            // src/antlr3/Plumhead.g:90:5: ( ECHO expression ';' -> ^( ECHO expression ) | VAR_DUMP PAREN_OPEN expression PAREN_CLOSE ';' -> ^( VAR_DUMP expression ) | IF PAREN_OPEN relational_expression PAREN_CLOSE '{' s1= statements '}' ( ELSE '{' s2= statements '}' -> ^( IF relational_expression ^( STMTS $s1) ^( STMTS $s2) ) | -> ^( IF relational_expression ^( STMTS $s1) ) ) | CODE_END SEA CODE_START -> ^( ECHO NOQUOTE_STRING[$SEA] ) | VAR_NAME ASSIGN_OP val= expression ';' -> ^( ASSIGN_OP SCALAR[$VAR_NAME] $val) | VAR_NAME '[' key= expression ']' ASSIGN_OP val= expression ';' -> ^( ASSIGN_OP ^( ARRAY[$VAR_NAME] $key) $val) )
            int alt6=6;
            switch ( input.LA(1) ) {
            case ECHO:
                alt6=1;
                break;
            case VAR_DUMP:
                alt6=2;
                break;
            case IF:
                alt6=3;
                break;
            case CODE_END:
                alt6=4;
                break;
            case VAR_NAME:
                int LA6_5 = input.LA(2);
                if ( (LA6_5==ASSIGN_OP) ) {
                    alt6=5;
                }
                else if ( (LA6_5==37) ) {
                    alt6=6;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("89:1: statement : ( ECHO expression ';' -> ^( ECHO expression ) | VAR_DUMP PAREN_OPEN expression PAREN_CLOSE ';' -> ^( VAR_DUMP expression ) | IF PAREN_OPEN relational_expression PAREN_CLOSE '{' s1= statements '}' ( ELSE '{' s2= statements '}' -> ^( IF relational_expression ^( STMTS $s1) ^( STMTS $s2) ) | -> ^( IF relational_expression ^( STMTS $s1) ) ) | CODE_END SEA CODE_START -> ^( ECHO NOQUOTE_STRING[$SEA] ) | VAR_NAME ASSIGN_OP val= expression ';' -> ^( ASSIGN_OP SCALAR[$VAR_NAME] $val) | VAR_NAME '[' key= expression ']' ASSIGN_OP val= expression ';' -> ^( ASSIGN_OP ^( ARRAY[$VAR_NAME] $key) $val) );", 6, 5, input);

                    throw nvae;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("89:1: statement : ( ECHO expression ';' -> ^( ECHO expression ) | VAR_DUMP PAREN_OPEN expression PAREN_CLOSE ';' -> ^( VAR_DUMP expression ) | IF PAREN_OPEN relational_expression PAREN_CLOSE '{' s1= statements '}' ( ELSE '{' s2= statements '}' -> ^( IF relational_expression ^( STMTS $s1) ^( STMTS $s2) ) | -> ^( IF relational_expression ^( STMTS $s1) ) ) | CODE_END SEA CODE_START -> ^( ECHO NOQUOTE_STRING[$SEA] ) | VAR_NAME ASSIGN_OP val= expression ';' -> ^( ASSIGN_OP SCALAR[$VAR_NAME] $val) | VAR_NAME '[' key= expression ']' ASSIGN_OP val= expression ';' -> ^( ASSIGN_OP ^( ARRAY[$VAR_NAME] $key) $val) );", 6, 0, input);

                throw nvae;
            }

            switch (alt6) {
                case 1 :
                    // src/antlr3/Plumhead.g:90:5: ECHO expression ';'
                    {
                    ECHO12=(Token)input.LT(1);
                    match(input,ECHO,FOLLOW_ECHO_in_statement962); 
                    list_ECHO.add(ECHO12);

                    pushFollow(FOLLOW_expression_in_statement964);
                    expression13=expression();
                    _fsp--;

                    list_expression.add(expression13.getTree());
                    char_literal14=(Token)input.LT(1);
                    match(input,34,FOLLOW_34_in_statement966); 
                    list_34.add(char_literal14);


                    // AST REWRITE
                    int i_0 = 0;
                    retval.tree = root_0;
                    root_0 = (CommonTree)adaptor.nil();
                    // 90:69: -> ^( ECHO expression )
                    {
                        // src/antlr3/Plumhead.g:90:72: ^( ECHO expression )
                        {
                        CommonTree root_1 = (CommonTree)adaptor.nil();
                        root_1 = (CommonTree)adaptor.becomeRoot((Token)list_ECHO.get(i_0), root_1);

                        adaptor.addChild(root_1, list_expression.get(i_0));

                        adaptor.addChild(root_0, root_1);
                        }

                    }



                    }
                    break;
                case 2 :
                    // src/antlr3/Plumhead.g:91:5: VAR_DUMP PAREN_OPEN expression PAREN_CLOSE ';'
                    {
                    VAR_DUMP15=(Token)input.LT(1);
                    match(input,VAR_DUMP,FOLLOW_VAR_DUMP_in_statement1026); 
                    list_VAR_DUMP.add(VAR_DUMP15);

                    PAREN_OPEN16=(Token)input.LT(1);
                    match(input,PAREN_OPEN,FOLLOW_PAREN_OPEN_in_statement1028); 
                    list_PAREN_OPEN.add(PAREN_OPEN16);

                    pushFollow(FOLLOW_expression_in_statement1031);
                    expression17=expression();
                    _fsp--;

                    list_expression.add(expression17.getTree());
                    PAREN_CLOSE18=(Token)input.LT(1);
                    match(input,PAREN_CLOSE,FOLLOW_PAREN_CLOSE_in_statement1033); 
                    list_PAREN_CLOSE.add(PAREN_CLOSE18);

                    char_literal19=(Token)input.LT(1);
                    match(input,34,FOLLOW_34_in_statement1035); 
                    list_34.add(char_literal19);


                    // AST REWRITE
                    int i_0 = 0;
                    retval.tree = root_0;
                    root_0 = (CommonTree)adaptor.nil();
                    // 91:69: -> ^( VAR_DUMP expression )
                    {
                        // src/antlr3/Plumhead.g:91:72: ^( VAR_DUMP expression )
                        {
                        CommonTree root_1 = (CommonTree)adaptor.nil();
                        root_1 = (CommonTree)adaptor.becomeRoot((Token)list_VAR_DUMP.get(i_0), root_1);

                        adaptor.addChild(root_1, list_expression.get(i_0));

                        adaptor.addChild(root_0, root_1);
                        }

                    }



                    }
                    break;
                case 3 :
                    // src/antlr3/Plumhead.g:92:5: IF PAREN_OPEN relational_expression PAREN_CLOSE '{' s1= statements '}' ( ELSE '{' s2= statements '}' -> ^( IF relational_expression ^( STMTS $s1) ^( STMTS $s2) ) | -> ^( IF relational_expression ^( STMTS $s1) ) )
                    {
                    IF20=(Token)input.LT(1);
                    match(input,IF,FOLLOW_IF_in_statement1067); 
                    list_IF.add(IF20);

                    PAREN_OPEN21=(Token)input.LT(1);
                    match(input,PAREN_OPEN,FOLLOW_PAREN_OPEN_in_statement1069); 
                    list_PAREN_OPEN.add(PAREN_OPEN21);

                    pushFollow(FOLLOW_relational_expression_in_statement1071);
                    relational_expression22=relational_expression();
                    _fsp--;

                    list_relational_expression.add(relational_expression22.getTree());
                    PAREN_CLOSE23=(Token)input.LT(1);
                    match(input,PAREN_CLOSE,FOLLOW_PAREN_CLOSE_in_statement1073); 
                    list_PAREN_CLOSE.add(PAREN_CLOSE23);

                    char_literal24=(Token)input.LT(1);
                    match(input,35,FOLLOW_35_in_statement1075); 
                    list_35.add(char_literal24);

                    pushFollow(FOLLOW_statements_in_statement1079);
                    s1=statements();
                    _fsp--;

                    list_statements.add(s1.getTree());
                    char_literal25=(Token)input.LT(1);
                    match(input,36,FOLLOW_36_in_statement1081); 
                    list_36.add(char_literal25);

                    // src/antlr3/Plumhead.g:93:5: ( ELSE '{' s2= statements '}' -> ^( IF relational_expression ^( STMTS $s1) ^( STMTS $s2) ) | -> ^( IF relational_expression ^( STMTS $s1) ) )
                    int alt5=2;
                    int LA5_0 = input.LA(1);
                    if ( (LA5_0==ELSE) ) {
                        alt5=1;
                    }
                    else if ( (LA5_0==EOF||(LA5_0>=SEA && LA5_0<=CODE_END)||(LA5_0>=ECHO && LA5_0<=VAR_DUMP)||LA5_0==VAR_NAME||LA5_0==IF||LA5_0==36) ) {
                        alt5=2;
                    }
                    else {
                        NoViableAltException nvae =
                            new NoViableAltException("93:5: ( ELSE '{' s2= statements '}' -> ^( IF relational_expression ^( STMTS $s1) ^( STMTS $s2) ) | -> ^( IF relational_expression ^( STMTS $s1) ) )", 5, 0, input);

                        throw nvae;
                    }
                    switch (alt5) {
                        case 1 :
                            // src/antlr3/Plumhead.g:93:7: ELSE '{' s2= statements '}'
                            {
                            ELSE26=(Token)input.LT(1);
                            match(input,ELSE,FOLLOW_ELSE_in_statement1089); 
                            list_ELSE.add(ELSE26);

                            char_literal27=(Token)input.LT(1);
                            match(input,35,FOLLOW_35_in_statement1091); 
                            list_35.add(char_literal27);

                            pushFollow(FOLLOW_statements_in_statement1095);
                            s2=statements();
                            _fsp--;

                            list_statements.add(s2.getTree());
                            char_literal28=(Token)input.LT(1);
                            match(input,36,FOLLOW_36_in_statement1097); 
                            list_36.add(char_literal28);


                            // AST REWRITE
                            int i_0 = 0;
                            retval.tree = root_0;
                            root_0 = (CommonTree)adaptor.nil();
                            // 93:69: -> ^( IF relational_expression ^( STMTS $s1) ^( STMTS $s2) )
                            {
                                // src/antlr3/Plumhead.g:93:72: ^( IF relational_expression ^( STMTS $s1) ^( STMTS $s2) )
                                {
                                CommonTree root_1 = (CommonTree)adaptor.nil();
                                root_1 = (CommonTree)adaptor.becomeRoot((Token)list_IF.get(i_0), root_1);

                                adaptor.addChild(root_1, list_relational_expression.get(i_0));
                                // src/antlr3/Plumhead.g:93:100: ^( STMTS $s1)
                                {
                                CommonTree root_2 = (CommonTree)adaptor.nil();
                                root_2 = (CommonTree)adaptor.becomeRoot(adaptor.create(STMTS, "STMTS"), root_2);

                                adaptor.addChild(root_2, s1.tree);

                                adaptor.addChild(root_1, root_2);
                                }
                                // src/antlr3/Plumhead.g:93:115: ^( STMTS $s2)
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
                            // src/antlr3/Plumhead.g:94:69: 
                            {

                            // AST REWRITE
                            int i_0 = 0;
                            retval.tree = root_0;
                            root_0 = (CommonTree)adaptor.nil();
                            // 94:69: -> ^( IF relational_expression ^( STMTS $s1) )
                            {
                                // src/antlr3/Plumhead.g:94:72: ^( IF relational_expression ^( STMTS $s1) )
                                {
                                CommonTree root_1 = (CommonTree)adaptor.nil();
                                root_1 = (CommonTree)adaptor.becomeRoot((Token)list_IF.get(i_0), root_1);

                                adaptor.addChild(root_1, list_relational_expression.get(i_0));
                                // src/antlr3/Plumhead.g:94:100: ^( STMTS $s1)
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
                case 4 :
                    // src/antlr3/Plumhead.g:96:5: CODE_END SEA CODE_START
                    {
                    CODE_END29=(Token)input.LT(1);
                    match(input,CODE_END,FOLLOW_CODE_END_in_statement1260); 
                    list_CODE_END.add(CODE_END29);

                    SEA30=(Token)input.LT(1);
                    match(input,SEA,FOLLOW_SEA_in_statement1262); 
                    list_SEA.add(SEA30);

                    CODE_START31=(Token)input.LT(1);
                    match(input,CODE_START,FOLLOW_CODE_START_in_statement1264); 
                    list_CODE_START.add(CODE_START31);


                    // AST REWRITE
                    int i_0 = 0;
                    retval.tree = root_0;
                    root_0 = (CommonTree)adaptor.nil();
                    // 96:69: -> ^( ECHO NOQUOTE_STRING[$SEA] )
                    {
                        // src/antlr3/Plumhead.g:96:72: ^( ECHO NOQUOTE_STRING[$SEA] )
                        {
                        CommonTree root_1 = (CommonTree)adaptor.nil();
                        root_1 = (CommonTree)adaptor.becomeRoot(adaptor.create(ECHO, "ECHO"), root_1);

                        adaptor.addChild(root_1, adaptor.create(NOQUOTE_STRING, SEA30));

                        adaptor.addChild(root_0, root_1);
                        }

                    }



                    }
                    break;
                case 5 :
                    // src/antlr3/Plumhead.g:97:5: VAR_NAME ASSIGN_OP val= expression ';'
                    {
                    VAR_NAME32=(Token)input.LT(1);
                    match(input,VAR_NAME,FOLLOW_VAR_NAME_in_statement1321); 
                    list_VAR_NAME.add(VAR_NAME32);

                    ASSIGN_OP33=(Token)input.LT(1);
                    match(input,ASSIGN_OP,FOLLOW_ASSIGN_OP_in_statement1323); 
                    list_ASSIGN_OP.add(ASSIGN_OP33);

                    pushFollow(FOLLOW_expression_in_statement1327);
                    val=expression();
                    _fsp--;

                    list_expression.add(val.getTree());
                    char_literal34=(Token)input.LT(1);
                    match(input,34,FOLLOW_34_in_statement1329); 
                    list_34.add(char_literal34);


                    // AST REWRITE
                    int i_0 = 0;
                    retval.tree = root_0;
                    root_0 = (CommonTree)adaptor.nil();
                    // 97:69: -> ^( ASSIGN_OP SCALAR[$VAR_NAME] $val)
                    {
                        // src/antlr3/Plumhead.g:97:72: ^( ASSIGN_OP SCALAR[$VAR_NAME] $val)
                        {
                        CommonTree root_1 = (CommonTree)adaptor.nil();
                        root_1 = (CommonTree)adaptor.becomeRoot((Token)list_ASSIGN_OP.get(i_0), root_1);

                        adaptor.addChild(root_1, adaptor.create(SCALAR, VAR_NAME32));
                        adaptor.addChild(root_1, val.tree);

                        adaptor.addChild(root_0, root_1);
                        }

                    }



                    }
                    break;
                case 6 :
                    // src/antlr3/Plumhead.g:98:5: VAR_NAME '[' key= expression ']' ASSIGN_OP val= expression ';'
                    {
                    VAR_NAME35=(Token)input.LT(1);
                    match(input,VAR_NAME,FOLLOW_VAR_NAME_in_statement1376); 
                    list_VAR_NAME.add(VAR_NAME35);

                    char_literal36=(Token)input.LT(1);
                    match(input,37,FOLLOW_37_in_statement1378); 
                    list_37.add(char_literal36);

                    pushFollow(FOLLOW_expression_in_statement1382);
                    key=expression();
                    _fsp--;

                    list_expression.add(key.getTree());
                    char_literal37=(Token)input.LT(1);
                    match(input,38,FOLLOW_38_in_statement1384); 
                    list_38.add(char_literal37);

                    ASSIGN_OP38=(Token)input.LT(1);
                    match(input,ASSIGN_OP,FOLLOW_ASSIGN_OP_in_statement1386); 
                    list_ASSIGN_OP.add(ASSIGN_OP38);

                    pushFollow(FOLLOW_expression_in_statement1390);
                    val=expression();
                    _fsp--;

                    list_expression.add(val.getTree());
                    char_literal39=(Token)input.LT(1);
                    match(input,34,FOLLOW_34_in_statement1392); 
                    list_34.add(char_literal39);


                    // AST REWRITE
                    int i_0 = 0;
                    retval.tree = root_0;
                    root_0 = (CommonTree)adaptor.nil();
                    // 98:69: -> ^( ASSIGN_OP ^( ARRAY[$VAR_NAME] $key) $val)
                    {
                        // src/antlr3/Plumhead.g:98:72: ^( ASSIGN_OP ^( ARRAY[$VAR_NAME] $key) $val)
                        {
                        CommonTree root_1 = (CommonTree)adaptor.nil();
                        root_1 = (CommonTree)adaptor.becomeRoot((Token)list_ASSIGN_OP.get(i_0), root_1);

                        // src/antlr3/Plumhead.g:98:85: ^( ARRAY[$VAR_NAME] $key)
                        {
                        CommonTree root_2 = (CommonTree)adaptor.nil();
                        root_2 = (CommonTree)adaptor.becomeRoot(adaptor.create(ARRAY, VAR_NAME35), root_2);

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
    // src/antlr3/Plumhead.g:101:1: expression : ( DOUBLEQUOTE_STRING | SINGLEQUOTE_STRING | bitwise_expression | VAR_NAME '[' key= expression ']' -> ^( ARRAY[$VAR_NAME] $key) | VAR_NAME -> SCALAR[$VAR_NAME] );
    public expression_return expression() throws RecognitionException {
        expression_return retval = new expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token DOUBLEQUOTE_STRING40=null;
        Token SINGLEQUOTE_STRING41=null;
        Token VAR_NAME43=null;
        Token char_literal44=null;
        Token char_literal45=null;
        Token VAR_NAME46=null;
        expression_return key = null;

        bitwise_expression_return bitwise_expression42 = null;

        List list_expression=new ArrayList();
        List list_VAR_NAME=new ArrayList();
        List list_37=new ArrayList();
        List list_38=new ArrayList();
        CommonTree DOUBLEQUOTE_STRING40_tree=null;
        CommonTree SINGLEQUOTE_STRING41_tree=null;
        CommonTree VAR_NAME43_tree=null;
        CommonTree char_literal44_tree=null;
        CommonTree char_literal45_tree=null;
        CommonTree VAR_NAME46_tree=null;

        try {
            // src/antlr3/Plumhead.g:102:5: ( DOUBLEQUOTE_STRING | SINGLEQUOTE_STRING | bitwise_expression | VAR_NAME '[' key= expression ']' -> ^( ARRAY[$VAR_NAME] $key) | VAR_NAME -> SCALAR[$VAR_NAME] )
            int alt7=5;
            switch ( input.LA(1) ) {
            case DOUBLEQUOTE_STRING:
                alt7=1;
                break;
            case SINGLEQUOTE_STRING:
                alt7=2;
                break;
            case PAREN_OPEN:
            case INTEGER:
            case NUMBER:
            case MINUS:
                alt7=3;
                break;
            case VAR_NAME:
                int LA7_4 = input.LA(2);
                if ( (LA7_4==37) ) {
                    alt7=4;
                }
                else if ( (LA7_4==PAREN_CLOSE||LA7_4==REL_OP||LA7_4==34||LA7_4==38) ) {
                    alt7=5;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("101:1: expression : ( DOUBLEQUOTE_STRING | SINGLEQUOTE_STRING | bitwise_expression | VAR_NAME '[' key= expression ']' -> ^( ARRAY[$VAR_NAME] $key) | VAR_NAME -> SCALAR[$VAR_NAME] );", 7, 4, input);

                    throw nvae;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("101:1: expression : ( DOUBLEQUOTE_STRING | SINGLEQUOTE_STRING | bitwise_expression | VAR_NAME '[' key= expression ']' -> ^( ARRAY[$VAR_NAME] $key) | VAR_NAME -> SCALAR[$VAR_NAME] );", 7, 0, input);

                throw nvae;
            }

            switch (alt7) {
                case 1 :
                    // src/antlr3/Plumhead.g:102:5: DOUBLEQUOTE_STRING
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    DOUBLEQUOTE_STRING40=(Token)input.LT(1);
                    match(input,DOUBLEQUOTE_STRING,FOLLOW_DOUBLEQUOTE_STRING_in_expression1429); 
                    DOUBLEQUOTE_STRING40_tree = (CommonTree)adaptor.create(DOUBLEQUOTE_STRING40);
                    adaptor.addChild(root_0, DOUBLEQUOTE_STRING40_tree);


                    }
                    break;
                case 2 :
                    // src/antlr3/Plumhead.g:103:5: SINGLEQUOTE_STRING
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    SINGLEQUOTE_STRING41=(Token)input.LT(1);
                    match(input,SINGLEQUOTE_STRING,FOLLOW_SINGLEQUOTE_STRING_in_expression1435); 
                    SINGLEQUOTE_STRING41_tree = (CommonTree)adaptor.create(SINGLEQUOTE_STRING41);
                    adaptor.addChild(root_0, SINGLEQUOTE_STRING41_tree);


                    }
                    break;
                case 3 :
                    // src/antlr3/Plumhead.g:104:5: bitwise_expression
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    pushFollow(FOLLOW_bitwise_expression_in_expression1441);
                    bitwise_expression42=bitwise_expression();
                    _fsp--;

                    adaptor.addChild(root_0, bitwise_expression42.getTree());

                    }
                    break;
                case 4 :
                    // src/antlr3/Plumhead.g:105:5: VAR_NAME '[' key= expression ']'
                    {
                    VAR_NAME43=(Token)input.LT(1);
                    match(input,VAR_NAME,FOLLOW_VAR_NAME_in_expression1447); 
                    list_VAR_NAME.add(VAR_NAME43);

                    char_literal44=(Token)input.LT(1);
                    match(input,37,FOLLOW_37_in_expression1449); 
                    list_37.add(char_literal44);

                    pushFollow(FOLLOW_expression_in_expression1453);
                    key=expression();
                    _fsp--;

                    list_expression.add(key.getTree());
                    char_literal45=(Token)input.LT(1);
                    match(input,38,FOLLOW_38_in_expression1455); 
                    list_38.add(char_literal45);


                    // AST REWRITE
                    int i_0 = 0;
                    retval.tree = root_0;
                    root_0 = (CommonTree)adaptor.nil();
                    // 105:40: -> ^( ARRAY[$VAR_NAME] $key)
                    {
                        // src/antlr3/Plumhead.g:105:43: ^( ARRAY[$VAR_NAME] $key)
                        {
                        CommonTree root_1 = (CommonTree)adaptor.nil();
                        root_1 = (CommonTree)adaptor.becomeRoot(adaptor.create(ARRAY, VAR_NAME43), root_1);

                        adaptor.addChild(root_1, key.tree);

                        adaptor.addChild(root_0, root_1);
                        }

                    }



                    }
                    break;
                case 5 :
                    // src/antlr3/Plumhead.g:106:5: VAR_NAME
                    {
                    VAR_NAME46=(Token)input.LT(1);
                    match(input,VAR_NAME,FOLLOW_VAR_NAME_in_expression1476); 
                    list_VAR_NAME.add(VAR_NAME46);


                    // AST REWRITE
                    int i_0 = 0;
                    retval.tree = root_0;
                    root_0 = (CommonTree)adaptor.nil();
                    // 106:40: -> SCALAR[$VAR_NAME]
                    {
                        adaptor.addChild(root_0, adaptor.create(SCALAR, VAR_NAME46));

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
    // src/antlr3/Plumhead.g:109:1: bitwise_expression : adding_expression ( BITWISE_OP^ adding_expression )* ;
    public bitwise_expression_return bitwise_expression() throws RecognitionException {
        bitwise_expression_return retval = new bitwise_expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token BITWISE_OP48=null;
        adding_expression_return adding_expression47 = null;

        adding_expression_return adding_expression49 = null;


        CommonTree BITWISE_OP48_tree=null;

        try {
            // src/antlr3/Plumhead.g:110:5: ( adding_expression ( BITWISE_OP^ adding_expression )* )
            // src/antlr3/Plumhead.g:110:5: adding_expression ( BITWISE_OP^ adding_expression )*
            {
            root_0 = (CommonTree)adaptor.nil();

            pushFollow(FOLLOW_adding_expression_in_bitwise_expression1520);
            adding_expression47=adding_expression();
            _fsp--;

            adaptor.addChild(root_0, adding_expression47.getTree());
            // src/antlr3/Plumhead.g:110:23: ( BITWISE_OP^ adding_expression )*
            loop8:
            do {
                int alt8=2;
                int LA8_0 = input.LA(1);
                if ( (LA8_0==BITWISE_OP) ) {
                    alt8=1;
                }


                switch (alt8) {
            	case 1 :
            	    // src/antlr3/Plumhead.g:110:25: BITWISE_OP^ adding_expression
            	    {
            	    BITWISE_OP48=(Token)input.LT(1);
            	    match(input,BITWISE_OP,FOLLOW_BITWISE_OP_in_bitwise_expression1524); 
            	    BITWISE_OP48_tree = (CommonTree)adaptor.create(BITWISE_OP48);
            	    root_0 = (CommonTree)adaptor.becomeRoot(BITWISE_OP48_tree, root_0);

            	    pushFollow(FOLLOW_adding_expression_in_bitwise_expression1527);
            	    adding_expression49=adding_expression();
            	    _fsp--;

            	    adaptor.addChild(root_0, adding_expression49.getTree());

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
    // src/antlr3/Plumhead.g:113:1: adding_expression : multiplying_expression ( ( PLUS^ | MINUS^ ) multiplying_expression )* ;
    public adding_expression_return adding_expression() throws RecognitionException {
        adding_expression_return retval = new adding_expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token PLUS51=null;
        Token MINUS52=null;
        multiplying_expression_return multiplying_expression50 = null;

        multiplying_expression_return multiplying_expression53 = null;


        CommonTree PLUS51_tree=null;
        CommonTree MINUS52_tree=null;

        try {
            // src/antlr3/Plumhead.g:114:5: ( multiplying_expression ( ( PLUS^ | MINUS^ ) multiplying_expression )* )
            // src/antlr3/Plumhead.g:114:5: multiplying_expression ( ( PLUS^ | MINUS^ ) multiplying_expression )*
            {
            root_0 = (CommonTree)adaptor.nil();

            pushFollow(FOLLOW_multiplying_expression_in_adding_expression1543);
            multiplying_expression50=multiplying_expression();
            _fsp--;

            adaptor.addChild(root_0, multiplying_expression50.getTree());
            // src/antlr3/Plumhead.g:114:28: ( ( PLUS^ | MINUS^ ) multiplying_expression )*
            loop10:
            do {
                int alt10=2;
                int LA10_0 = input.LA(1);
                if ( ((LA10_0>=MINUS && LA10_0<=PLUS)) ) {
                    alt10=1;
                }


                switch (alt10) {
            	case 1 :
            	    // src/antlr3/Plumhead.g:114:30: ( PLUS^ | MINUS^ ) multiplying_expression
            	    {
            	    // src/antlr3/Plumhead.g:114:30: ( PLUS^ | MINUS^ )
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
            	            new NoViableAltException("114:30: ( PLUS^ | MINUS^ )", 9, 0, input);

            	        throw nvae;
            	    }
            	    switch (alt9) {
            	        case 1 :
            	            // src/antlr3/Plumhead.g:114:32: PLUS^
            	            {
            	            PLUS51=(Token)input.LT(1);
            	            match(input,PLUS,FOLLOW_PLUS_in_adding_expression1549); 
            	            PLUS51_tree = (CommonTree)adaptor.create(PLUS51);
            	            root_0 = (CommonTree)adaptor.becomeRoot(PLUS51_tree, root_0);


            	            }
            	            break;
            	        case 2 :
            	            // src/antlr3/Plumhead.g:114:40: MINUS^
            	            {
            	            MINUS52=(Token)input.LT(1);
            	            match(input,MINUS,FOLLOW_MINUS_in_adding_expression1554); 
            	            MINUS52_tree = (CommonTree)adaptor.create(MINUS52);
            	            root_0 = (CommonTree)adaptor.becomeRoot(MINUS52_tree, root_0);


            	            }
            	            break;

            	    }

            	    pushFollow(FOLLOW_multiplying_expression_in_adding_expression1559);
            	    multiplying_expression53=multiplying_expression();
            	    _fsp--;

            	    adaptor.addChild(root_0, multiplying_expression53.getTree());

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
    // src/antlr3/Plumhead.g:117:1: multiplying_expression : unary_expression ( MUL_OP^ unary_expression )* ;
    public multiplying_expression_return multiplying_expression() throws RecognitionException {
        multiplying_expression_return retval = new multiplying_expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token MUL_OP55=null;
        unary_expression_return unary_expression54 = null;

        unary_expression_return unary_expression56 = null;


        CommonTree MUL_OP55_tree=null;

        try {
            // src/antlr3/Plumhead.g:118:5: ( unary_expression ( MUL_OP^ unary_expression )* )
            // src/antlr3/Plumhead.g:118:5: unary_expression ( MUL_OP^ unary_expression )*
            {
            root_0 = (CommonTree)adaptor.nil();

            pushFollow(FOLLOW_unary_expression_in_multiplying_expression1576);
            unary_expression54=unary_expression();
            _fsp--;

            adaptor.addChild(root_0, unary_expression54.getTree());
            // src/antlr3/Plumhead.g:118:22: ( MUL_OP^ unary_expression )*
            loop11:
            do {
                int alt11=2;
                int LA11_0 = input.LA(1);
                if ( (LA11_0==MUL_OP) ) {
                    alt11=1;
                }


                switch (alt11) {
            	case 1 :
            	    // src/antlr3/Plumhead.g:118:24: MUL_OP^ unary_expression
            	    {
            	    MUL_OP55=(Token)input.LT(1);
            	    match(input,MUL_OP,FOLLOW_MUL_OP_in_multiplying_expression1580); 
            	    MUL_OP55_tree = (CommonTree)adaptor.create(MUL_OP55);
            	    root_0 = (CommonTree)adaptor.becomeRoot(MUL_OP55_tree, root_0);

            	    pushFollow(FOLLOW_unary_expression_in_multiplying_expression1583);
            	    unary_expression56=unary_expression();
            	    _fsp--;

            	    adaptor.addChild(root_0, unary_expression56.getTree());

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
    // src/antlr3/Plumhead.g:121:1: unary_expression : ( postfix_expression | MINUS postfix_expression -> ^( PREFIX[\"-\"] postfix_expression ) );
    public unary_expression_return unary_expression() throws RecognitionException {
        unary_expression_return retval = new unary_expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token MINUS58=null;
        postfix_expression_return postfix_expression57 = null;

        postfix_expression_return postfix_expression59 = null;

        List list_postfix_expression=new ArrayList();
        List list_MINUS=new ArrayList();
        CommonTree MINUS58_tree=null;

        try {
            // src/antlr3/Plumhead.g:122:5: ( postfix_expression | MINUS postfix_expression -> ^( PREFIX[\"-\"] postfix_expression ) )
            int alt12=2;
            int LA12_0 = input.LA(1);
            if ( (LA12_0==PAREN_OPEN||(LA12_0>=INTEGER && LA12_0<=NUMBER)) ) {
                alt12=1;
            }
            else if ( (LA12_0==MINUS) ) {
                alt12=2;
            }
            else {
                NoViableAltException nvae =
                    new NoViableAltException("121:1: unary_expression : ( postfix_expression | MINUS postfix_expression -> ^( PREFIX[\"-\"] postfix_expression ) );", 12, 0, input);

                throw nvae;
            }
            switch (alt12) {
                case 1 :
                    // src/antlr3/Plumhead.g:122:5: postfix_expression
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    pushFollow(FOLLOW_postfix_expression_in_unary_expression1599);
                    postfix_expression57=postfix_expression();
                    _fsp--;

                    adaptor.addChild(root_0, postfix_expression57.getTree());

                    }
                    break;
                case 2 :
                    // src/antlr3/Plumhead.g:123:5: MINUS postfix_expression
                    {
                    MINUS58=(Token)input.LT(1);
                    match(input,MINUS,FOLLOW_MINUS_in_unary_expression1605); 
                    list_MINUS.add(MINUS58);

                    pushFollow(FOLLOW_postfix_expression_in_unary_expression1607);
                    postfix_expression59=postfix_expression();
                    _fsp--;

                    list_postfix_expression.add(postfix_expression59.getTree());

                    // AST REWRITE
                    int i_0 = 0;
                    retval.tree = root_0;
                    root_0 = (CommonTree)adaptor.nil();
                    // 123:30: -> ^( PREFIX[\"-\"] postfix_expression )
                    {
                        // src/antlr3/Plumhead.g:123:33: ^( PREFIX[\"-\"] postfix_expression )
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
    // src/antlr3/Plumhead.g:126:1: postfix_expression : ( NUMBER | INTEGER | PAREN_OPEN expression PAREN_CLOSE -> expression );
    public postfix_expression_return postfix_expression() throws RecognitionException {
        postfix_expression_return retval = new postfix_expression_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token NUMBER60=null;
        Token INTEGER61=null;
        Token PAREN_OPEN62=null;
        Token PAREN_CLOSE64=null;
        expression_return expression63 = null;

        List list_expression=new ArrayList();
        List list_PAREN_OPEN=new ArrayList();
        List list_PAREN_CLOSE=new ArrayList();
        CommonTree NUMBER60_tree=null;
        CommonTree INTEGER61_tree=null;
        CommonTree PAREN_OPEN62_tree=null;
        CommonTree PAREN_CLOSE64_tree=null;

        try {
            // src/antlr3/Plumhead.g:127:5: ( NUMBER | INTEGER | PAREN_OPEN expression PAREN_CLOSE -> expression )
            int alt13=3;
            switch ( input.LA(1) ) {
            case NUMBER:
                alt13=1;
                break;
            case INTEGER:
                alt13=2;
                break;
            case PAREN_OPEN:
                alt13=3;
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("126:1: postfix_expression : ( NUMBER | INTEGER | PAREN_OPEN expression PAREN_CLOSE -> expression );", 13, 0, input);

                throw nvae;
            }

            switch (alt13) {
                case 1 :
                    // src/antlr3/Plumhead.g:127:5: NUMBER
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    NUMBER60=(Token)input.LT(1);
                    match(input,NUMBER,FOLLOW_NUMBER_in_postfix_expression1631); 
                    NUMBER60_tree = (CommonTree)adaptor.create(NUMBER60);
                    adaptor.addChild(root_0, NUMBER60_tree);


                    }
                    break;
                case 2 :
                    // src/antlr3/Plumhead.g:128:5: INTEGER
                    {
                    root_0 = (CommonTree)adaptor.nil();

                    INTEGER61=(Token)input.LT(1);
                    match(input,INTEGER,FOLLOW_INTEGER_in_postfix_expression1637); 
                    INTEGER61_tree = (CommonTree)adaptor.create(INTEGER61);
                    adaptor.addChild(root_0, INTEGER61_tree);


                    }
                    break;
                case 3 :
                    // src/antlr3/Plumhead.g:129:5: PAREN_OPEN expression PAREN_CLOSE
                    {
                    PAREN_OPEN62=(Token)input.LT(1);
                    match(input,PAREN_OPEN,FOLLOW_PAREN_OPEN_in_postfix_expression1643); 
                    list_PAREN_OPEN.add(PAREN_OPEN62);

                    pushFollow(FOLLOW_expression_in_postfix_expression1645);
                    expression63=expression();
                    _fsp--;

                    list_expression.add(expression63.getTree());
                    PAREN_CLOSE64=(Token)input.LT(1);
                    match(input,PAREN_CLOSE,FOLLOW_PAREN_CLOSE_in_postfix_expression1647); 
                    list_PAREN_CLOSE.add(PAREN_CLOSE64);


                    // AST REWRITE
                    int i_0 = 0;
                    retval.tree = root_0;
                    root_0 = (CommonTree)adaptor.nil();
                    // 129:39: -> expression
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


 

    public static final BitSet FOLLOW_sea_or_code_in_program828 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_sea_in_sea_or_code853 = new BitSet(new long[]{0x0000000000001802L});
    public static final BitSet FOLLOW_code_in_sea_or_code857 = new BitSet(new long[]{0x0000000000001802L});
    public static final BitSet FOLLOW_SEA_in_sea874 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_CODE_START_in_code898 = new BitSet(new long[]{0x0000000100462002L});
    public static final BitSet FOLLOW_statements_in_code900 = new BitSet(new long[]{0x0000000000002002L});
    public static final BitSet FOLLOW_CODE_END_in_code902 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_expression_in_relational_expression921 = new BitSet(new long[]{0x0000000080000002L});
    public static final BitSet FOLLOW_REL_OP_in_relational_expression925 = new BitSet(new long[]{0x0000000007498000L});
    public static final BitSet FOLLOW_expression_in_relational_expression928 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_statement_in_statements946 = new BitSet(new long[]{0x0000000100462002L});
    public static final BitSet FOLLOW_ECHO_in_statement962 = new BitSet(new long[]{0x0000000007498000L});
    public static final BitSet FOLLOW_expression_in_statement964 = new BitSet(new long[]{0x0000000400000000L});
    public static final BitSet FOLLOW_34_in_statement966 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_DUMP_in_statement1026 = new BitSet(new long[]{0x0000000000080000L});
    public static final BitSet FOLLOW_PAREN_OPEN_in_statement1028 = new BitSet(new long[]{0x0000000007498000L});
    public static final BitSet FOLLOW_expression_in_statement1031 = new BitSet(new long[]{0x0000000000100000L});
    public static final BitSet FOLLOW_PAREN_CLOSE_in_statement1033 = new BitSet(new long[]{0x0000000400000000L});
    public static final BitSet FOLLOW_34_in_statement1035 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_IF_in_statement1067 = new BitSet(new long[]{0x0000000000080000L});
    public static final BitSet FOLLOW_PAREN_OPEN_in_statement1069 = new BitSet(new long[]{0x0000000007498000L});
    public static final BitSet FOLLOW_relational_expression_in_statement1071 = new BitSet(new long[]{0x0000000000100000L});
    public static final BitSet FOLLOW_PAREN_CLOSE_in_statement1073 = new BitSet(new long[]{0x0000000800000000L});
    public static final BitSet FOLLOW_35_in_statement1075 = new BitSet(new long[]{0x0000001100462000L});
    public static final BitSet FOLLOW_statements_in_statement1079 = new BitSet(new long[]{0x0000001000000000L});
    public static final BitSet FOLLOW_36_in_statement1081 = new BitSet(new long[]{0x0000000200000002L});
    public static final BitSet FOLLOW_ELSE_in_statement1089 = new BitSet(new long[]{0x0000000800000000L});
    public static final BitSet FOLLOW_35_in_statement1091 = new BitSet(new long[]{0x0000001100462000L});
    public static final BitSet FOLLOW_statements_in_statement1095 = new BitSet(new long[]{0x0000001000000000L});
    public static final BitSet FOLLOW_36_in_statement1097 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_CODE_END_in_statement1260 = new BitSet(new long[]{0x0000000000000800L});
    public static final BitSet FOLLOW_SEA_in_statement1262 = new BitSet(new long[]{0x0000000000001000L});
    public static final BitSet FOLLOW_CODE_START_in_statement1264 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_NAME_in_statement1321 = new BitSet(new long[]{0x0000000040000000L});
    public static final BitSet FOLLOW_ASSIGN_OP_in_statement1323 = new BitSet(new long[]{0x0000000007498000L});
    public static final BitSet FOLLOW_expression_in_statement1327 = new BitSet(new long[]{0x0000000400000000L});
    public static final BitSet FOLLOW_34_in_statement1329 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_NAME_in_statement1376 = new BitSet(new long[]{0x0000002000000000L});
    public static final BitSet FOLLOW_37_in_statement1378 = new BitSet(new long[]{0x0000000007498000L});
    public static final BitSet FOLLOW_expression_in_statement1382 = new BitSet(new long[]{0x0000004000000000L});
    public static final BitSet FOLLOW_38_in_statement1384 = new BitSet(new long[]{0x0000000040000000L});
    public static final BitSet FOLLOW_ASSIGN_OP_in_statement1386 = new BitSet(new long[]{0x0000000007498000L});
    public static final BitSet FOLLOW_expression_in_statement1390 = new BitSet(new long[]{0x0000000400000000L});
    public static final BitSet FOLLOW_34_in_statement1392 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_DOUBLEQUOTE_STRING_in_expression1429 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SINGLEQUOTE_STRING_in_expression1435 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_bitwise_expression_in_expression1441 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_NAME_in_expression1447 = new BitSet(new long[]{0x0000002000000000L});
    public static final BitSet FOLLOW_37_in_expression1449 = new BitSet(new long[]{0x0000000007498000L});
    public static final BitSet FOLLOW_expression_in_expression1453 = new BitSet(new long[]{0x0000004000000000L});
    public static final BitSet FOLLOW_38_in_expression1455 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_NAME_in_expression1476 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_adding_expression_in_bitwise_expression1520 = new BitSet(new long[]{0x0000000020000002L});
    public static final BitSet FOLLOW_BITWISE_OP_in_bitwise_expression1524 = new BitSet(new long[]{0x0000000007080000L});
    public static final BitSet FOLLOW_adding_expression_in_bitwise_expression1527 = new BitSet(new long[]{0x0000000020000002L});
    public static final BitSet FOLLOW_multiplying_expression_in_adding_expression1543 = new BitSet(new long[]{0x000000000C000002L});
    public static final BitSet FOLLOW_PLUS_in_adding_expression1549 = new BitSet(new long[]{0x0000000007080000L});
    public static final BitSet FOLLOW_MINUS_in_adding_expression1554 = new BitSet(new long[]{0x0000000007080000L});
    public static final BitSet FOLLOW_multiplying_expression_in_adding_expression1559 = new BitSet(new long[]{0x000000000C000002L});
    public static final BitSet FOLLOW_unary_expression_in_multiplying_expression1576 = new BitSet(new long[]{0x0000000010000002L});
    public static final BitSet FOLLOW_MUL_OP_in_multiplying_expression1580 = new BitSet(new long[]{0x0000000007080000L});
    public static final BitSet FOLLOW_unary_expression_in_multiplying_expression1583 = new BitSet(new long[]{0x0000000010000002L});
    public static final BitSet FOLLOW_postfix_expression_in_unary_expression1599 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_MINUS_in_unary_expression1605 = new BitSet(new long[]{0x0000000003080000L});
    public static final BitSet FOLLOW_postfix_expression_in_unary_expression1607 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_NUMBER_in_postfix_expression1631 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_INTEGER_in_postfix_expression1637 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_PAREN_OPEN_in_postfix_expression1643 = new BitSet(new long[]{0x0000000007498000L});
    public static final BitSet FOLLOW_expression_in_postfix_expression1645 = new BitSet(new long[]{0x0000000000100000L});
    public static final BitSet FOLLOW_PAREN_CLOSE_in_postfix_expression1647 = new BitSet(new long[]{0x0000000000000002L});

}