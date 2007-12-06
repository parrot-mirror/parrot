class Punie::Grammar::Actions;

##  The ast of the entire program is the ast of the
##  top-level <lineseq>.
method TOP($/) {
    make $($<lineseq>);
}

method lineseq ($/) {
    my $past := PAST::Stmts.new( :node($/) );
    for $<line> {
        $past.push( $($_) );
    }
    make $past;
}


