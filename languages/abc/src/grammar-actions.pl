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
    make PAST::Op.new( $past,
                       :name('saynum'),
                       :pasttype('call')
                     );
}


method expression($/, $key) {
    if ($key eq 'end') {
        make $($<expr>);
    }
    else {
        my $past := PAST::Op.new( :name($<type>),
                                  :pasttype($<top><pasttype>),
                                  :pirop($<top><pirop>),
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


method integer($/) {
    make PAST::Val.new( :value( +$/ ), :node( $/ ) );
}

