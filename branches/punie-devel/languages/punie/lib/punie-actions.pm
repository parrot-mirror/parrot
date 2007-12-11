class Punie::Grammar::Actions;

##  The ast of the entire program is the ast of the
##  top-level <lineseq>.
method TOP($/) {
    my $past := PAST::Block.new( :node($/), :name('anon') );
    $past.push( $($<lineseq>) );
    make $past;
}

method block ($/) {
    my $past := PAST::Block.new( :node($/), :blocktype('immediate') );
    $past.push( $( $<lineseq> ) );
    make $past;
}

method lineseq ($/) {
    my $past := PAST::Stmts.new( :node($/) );
    for $<line> {
        $past.push( $($_) );
    }
    make $past;
}

method line ($/, $key) {
    make $( $/{$key} );
}

method subroutine($/) {
    my $past := $($<block>);
    $past.name( ~$<word> );
    $past.blocktype('declaration');
    $past.node($/);
    make $past;
}

method gprint ($/) {
    my $past := PAST::Op.new( $($<expr>) );
    $past.name('print');
    $past.pasttype('call');
    $past.node($/);
    make $past;
}

method cond($/) {
    my $cond := +$<expr> - 1;
    my $past := PAST::Op.new( $( $<expr>[$cond] ),
                              $( $<block>[$cond] ),
                              :pasttype( 'if' ),
                              :node( $/ )
                            );
    if ( $<else> ) {
        $past.push( $( $<else>[0] ) );
    }
    while ($cond != 0) {
        $cond := $cond - 1;
        $past := PAST::Op.new( $( $<expr>[$cond] ),
                               $( $<block>[$cond] ),
                               $past,
                               :pasttype('if'),
                               :node( $/ )
                             );
    }
    $past.pasttype( ~$<sym> );
    make $past;
}

method integer($/) {
    make PAST::Val.new( :value( ~$/ ), :returns('Integer'), :node( $/ ) );
}

method number($/) {
    make PAST::Val.new( :value( ~$/ ), :returns('Float'), :node( $/ ) );
}

method stringdouble($/) {
    make PAST::Val.new( :value( ~$<string_literal> ), :node($/) );
}

method stringsingle($/) {
    make PAST::Val.new( :value( ~$<string_literal> ), :node($/) );
}

method subcall($/) {
    my $past := PAST::Op.new( :node($/) );
    if $<expr> {
        my $expr := $($<expr>[0]);
        if ~$expr.name() eq 'infix:,' {
            for @($expr) {
                $past.push( $_ );
            }
        }
        else {
            $past.push( $expr );
        }
    }
    $past.name( ~$<word> );
    $past.pasttype('call');
    $past.node($/);
    make $past;
}

method expr($/, $key) {
    make $( $/{$key} );
}

method oexpr($/, $key) {
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

method variable($/) {
    my $viviself := 'Undef';
    if ($<sigil> && ~$<sigil> eq '@') { $viviself := 'List'; }
    make PAST::Var.new(
        :node($/),
        :name( ~$/ ),
        :viviself($viviself),
        :scope('package')
    );
}
