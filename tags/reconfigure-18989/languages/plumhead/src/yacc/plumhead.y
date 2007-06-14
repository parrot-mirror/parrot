%{
#include <stdio.h>
#include <string.h>


int main (void)
{
  return yyparse();
}

void yyerror(const char *str)
{
        fprintf(stderr,"error: %s\n",str);
}

int yywrap(void)
{
  return 1;
}

%}

%start program

%token HELLO

%%

program : HELLO
   {
        printf( "#!/usr/bin/env parrot                                             \n" );
        printf( "                                                                  \n" );
        printf( "# Do not edit this file.                                          \n" );
        printf( "# This file has been generated by GenPastPir.xsl                  \n" );
        printf( "                                                                  \n" );
        printf( ".sub 'php_init' :load :init                                       \n" );
        printf( "                                                                  \n" );
        printf( "  load_bytecode 'languages/plumhead/src/common/plumheadlib.pbc'   \n" );
        printf( "  load_bytecode 'PAST-pm.pbc'                                     \n" );
        printf( "  load_bytecode 'Parrot/HLLCompiler.pbc'                          \n" );
        printf( "  load_bytecode 'MIME/Base64.pbc'                                 \n" );
        printf( "  load_bytecode 'dumper.pbc'                                      \n" );
        printf( "  load_bytecode 'PGE.pbc'                                         \n" );
        printf( "  load_bytecode 'CGI/QueryHash.pbc'                               \n" );
        printf( "                                                                  \n" );
        printf( ".end                                                              \n" );
        printf( "                                                                  \n" );
        printf( ".sub plumhead :main                                               \n" );
        printf( "                                                                  \n" );
        printf( "    # look for subs in other namespaces                           \n" );
        printf( "    .local pmc parse_get_sub, parse_post_sub   \n" );
        printf( "    parse_get_sub  = get_global [ 'CGI'; 'QueryHash' ], 'parse_get'         \n" );
        printf( "    parse_post_sub = get_global [ 'CGI'; 'QueryHash' ], 'parse_post'        \n" );
        printf( "                                                                  \n" );
        printf( "    # the superglobals                                            \n" );
        printf( "    .local pmc superglobal_GET                                    \n" );
        printf( "    ( superglobal_GET ) = parse_get_sub()                         \n" );
        printf( "    set_global '$_GET', superglobal_GET                            \n" );
        printf( "                                                                  \n" );
        printf( "    .local pmc superglobal_POST                                   \n" );
        printf( "    ( superglobal_POST ) = parse_post_sub()                       \n" );
        printf( "    set_global '$_POST', superglobal_POST                          \n" );
        printf( "                                                                  \n" );
        printf( "    # The root node of PAST.                                      \n" );
        printf( "    .local pmc past_root                                          \n" );
        printf( "    past_root  = new 'PAST::Block'                                \n" );
        printf( "    past_root.init('name' => 'plumhead_main')                     \n" );
        printf( "                                                                  \n" );
        printf( "    .local pmc past_stmts                                         \n" );
        printf( "    past_stmts = new 'PAST::Stmts'                                \n" );
        printf( "                                                                  \n" );
        printf( "    .sym pmc past_temp                                            \n" );
        printf( "    .sym pmc past_name                                            \n" );
        printf( "    .sym pmc past_if_op                                           \n" );
        printf( "                                                                  \n" );
        printf( "\n" );
        printf( "                                                                  \n" );
        printf( "  # start of ECHO node                                            \n" );
        printf( "  .local pmc past_echo                                            \n" );
        printf( "  past_echo = new 'PAST::Op'                                      \n" );
        printf( "\n" );
        printf( "                                                                  \n" );
        printf( "  # start of NOQUOTE_STRING                                       \n" );
        printf( "  .local string val                                               \n" );
        printf( "  val = \"Hello, World!\"                                       \n" );
        printf( "  past_temp = new 'PAST::Val'                                     \n" );
        printf( "  .local pmc code_string                                          \n" );
        printf( "  code_string = new 'PGE::CodeString'                             \n" );
        printf( "  ( val ) = code_string.'escape'( val )                           \n" );
        printf( "      past_temp.'init'( 'name' => val, 'vtype' => '.Undef' )      \n" );
        printf( "  past_echo.'push'( past_temp )                    \n" );
        printf( "  # end of NOQUOTE_STRING                                         \n" );
        printf( "                                                                  \n" );
        printf( "\n" );
        printf( "                                                                  \n" );
        printf( "  past_echo.'attr'( 'name', 'echo', 1 )                           \n" );
        printf( "  past_stmts.'push'( past_echo )                    \n" );
        printf( "  # end of ECHO node                                              \n" );
        printf( "\n" );
        printf( "                                                                  \n" );
        printf( "                                                                  \n" );
        printf( "  past_root.'push'( past_stmts )                                  \n" );
        printf( "                                                                  \n" );
        printf( "    #'_dumper'(past_root, 'past')                                \n" );
        printf( "    # '_dumper'(superglobal_POST , 'superglobal_POST')            \n" );
        printf( "    # '_dumper'(superglobal_GET , 'superglobal_GET')              \n" );
        printf( "                                                                  \n" );
        printf( "    # .local pmc post                                             \n" );
        printf( "    # post = past_root.'compile'( 'target' => 'post' )            \n" );
        printf( "    # '_dumper'(post, 'post')                                     \n" );
        printf( "                                                                  \n" );
        printf( "    # .local pmc pir                                              \n" );
        printf( "    # pir = past_root.'compile'( 'target' => 'pir' )              \n" );
        printf( "    # print pir                                                   \n" );
        printf( "                                                                  \n" );
        printf( "    .local pmc pastcompiler, eval_past                            \n" );
        printf( "    pastcompiler = new 'HLLCompiler'                              \n" );
        printf( "    pastcompiler.'removestage'('parse')                           \n" );
        printf( "    pastcompiler.'removestage'('past')                            \n" );
        printf( "    eval_past = pastcompiler.'compile'(past_root)                 \n" );
        printf( "    eval_past()                                                   \n" );
        printf( "                                                                  \n" );
        printf( ".end                                                              \n" );
   }
   ;

%%

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
