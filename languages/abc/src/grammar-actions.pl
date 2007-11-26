class ABC::Grammar::Actions;

# Copyright (C) 2007, The Perl Foundation.
# $Id$

method TOP($/) {
    make $($<statement_list>);
}


method statement_list($/) {
    my $past := PAST::Stmts.new( :node($/) );
    for $<statement> {
        $past.push( $($_) );
    }
    make $past;
}


method statement($/, $key) {
    my $past := $( $/{$key} );
    if ($key eq 'expression' && ~$past.name() ne 'infix:=') {
        my $last := PAST::Var.new( :name('last'),
                                   :scope('package'),
                                   :lvalue(1) );
        $past := PAST::Op.new( $last,
                               $past,
                               :pasttype('bind') );
        $past := PAST::Op.new( $past,
                               :name('saynum'),
                               :pasttype('call') );
    }
    make $past;
}


method expression($/, $key) {
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


method term($/, $key) {
    make $( $/{$key} );
}

method float($/) {
    make PAST::Val.new( :value( +$/ ), :node( $/ ) );
}

method integer($/) {
    make PAST::Val.new( :value( +$/ ), :node( $/ ) );
}

method variable($/) {
    make PAST::Var.new( :name( ~$/ ),
                        :scope('package'),
                        :viviself('Float'),
                        :node( $/ )
                      );
}
