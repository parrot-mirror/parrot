class Perl6::Grammar::Actions ;

method TOP($/) {
    make $( $<statementlist> );
}


method statementlist($/) {
    my $past := PAST::Stmts.new( :node($/) );
    for $<statement> {
        $past.push( $($_) );
    }
    make $past;
}


method statement($/, $key) {
    make $( $/{$key} );
}


method statement_control($/, $key) {
    make $( $/{$key} );
}


method use_statement($/) {
    make PAST::Stmts.new( :node($/) );
}


method term($/, $key) {
    make $( $/{$key} );
}


method noun($/, $key) {
    make $( $/{$key} );
}


method circumfix($/, $key) {
    my $past;
    if ($key eq '( )') {
        $past := $( $<statementlist> );
    }
    make $past;
}


method value($/, $key) {
    make $( $/{$key} );
}


method number($/) {
    make PAST::Val.new( :value( ~$/ ), :node( $/ ) );
}


method quote($/) {
    make PAST::Val.new( :value( $($<string_literal>) ),
                        :node( $/ )
                      );
}


method listop($/) {
    make PAST::Op.new( $( $<arglist> ),
                       :name( ~$<sym> ),
                       :pasttype('call'),
                       :node( $/ )
                     );
}

method arglist($/) {
    make $( $<EXPR> );
}


method EXPR($/, $key) {
    if ($key eq 'end') {
        make $($<expr>);
    }
    else {
        my $past := PAST::Op.new( :name($<type>),
                                  :pasttype($<top><pasttype>),
                                  :pirop($<top><pirop>),
                                  :lvalue($<top><lvalue>),
                                  :node($/)
                                );
        for @($/) {
            $past.push( $($_) );
        }
        make $past;
    }
}



