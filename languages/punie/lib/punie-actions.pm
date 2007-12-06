class Punie::Grammar::Actions;

##  The ast of the entire program is the ast of the
##  top-level <lineseq>.
method TOP($/) {
    make $($<lineseq>);
}



