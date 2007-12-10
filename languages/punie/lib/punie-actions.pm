class Punie::Grammar::Actions;

##  The ast of the entire program is the ast of the
##  top-level <lineseq>.
method TOP($/) {
    my $past := PAST::Block.new( :node($/), :name('anon') );
    $past.push( $($<lineseq>) );
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

method gprint ($/) {
    my $past := PAST::Op.new();
    $past.name('print');
    $past.pasttype('call');
    $past.node($/);
    make $past;
}

method integer($/) {
    make PAST::Val.new( :value( ~$/ ), :returns('Integer'), :node( $/ ) );
}

method stringdouble($/) {
    make PAST::Val.new( :value( ~$<string_literal> ), :node($/) );
}

method stringsingle($/) {
    make PAST::Val.new( :value( ~$<string_literal> ), :node($/) );
}


