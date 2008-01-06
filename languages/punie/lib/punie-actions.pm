# Copyright (C) 2007, The Perl Foundation.
# $Id $

class Punie::Grammar::Actions;

##  The ast of the entire program is the ast of the
##  top-level <lineseq>.
method TOP($/) {
    my $?GLOBAL;
    my $init := PAST::Stmts.new();
    $init.push( PAST::Var.new(:name('$_'), :isdecl(1)) );
    $init.push( PAST::Var.new(:name('$#'), :isdecl(1)) );
    $init.push( PAST::Var.new(:name('$ '), :isdecl(1)) );
    $?GLOBAL := PAST::Block.new(
            PAST::Stmts.new( $init ),
            :blocktype('immediate'),
            :node($/)
    );
    $?GLOBAL.symbol( '$_', :scope('package') );
    $?GLOBAL.symbol( '$#', :scope('package') );
    $?GLOBAL.symbol( '$ ', :scope('package') );
    my $past := PAST::Block.new( :node($/), :name('anon') );
    $past.push( $($<lineseq>) );
    make $past;
}

method block ($/) {
    my $init := PAST::Stmts.new();
    $init.push(
        PAST::Var.new(:name('@_'), :scope('parameter'), :slurpy(1))
    );
    my $past := PAST::Block.new( :node($/), :blocktype('immediate') );
    $past.symbol( '@_', :scope('lexical') );
    $past.push( $init );
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
    my $past := PAST::Op.new( :node($/) );
    my $expr := $($<expr>);
    if ~$expr.name() eq 'infix:,' {
        for @($expr) {
            $past.push( $_ );
        }
    }
    else {
        $past.push( $expr );
    }
    $past.name('print');
    $past.pasttype('call');
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

method loop($/, $key) {
    # TODO: handle $<label>
    my $past := $( $/{$key} );
    make $past
}

method while_loop($/) {
    my $past := PAST::Op.new( :pasttype( 'while' ), :node($/) );
    my $cond;

    if $<expr> {
        $cond := $( $<expr>[0] );
    }
    else {
        # no condition means true; make the condition true.
        $cond := PAST::Val.new( :value('1'), :returns('Integer'), :node($/) );
    }

    my $block := $( $<block> );
    $past.push($cond);
    $past.push($block);

    make $past;
}

method until_loop($/) {
    my $past := PAST::Op.new( :pasttype( 'until' ), :node($/) );
    my $cond := $( $<expr> );
    my $block := $( $<block> );
    $past.push($cond);
    $past.push($block);
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

method stringbacktick($/) {
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
    $past.name( ~$<sym> );
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
    my $sigil := ~$<sigil>[0];
    if    ~$sigil eq '@' { $viviself := 'ResizablePMCArray'; }
    elsif ~$sigil eq '%' { $viviself := 'Hash'; }
    if    ~$<key>[0]<KEY> eq '[' { $viviself := 'ResizablePMCArray'; $sigil := '@'; }
    elsif ~$<key>[0]<KEY> eq '{' { $viviself := 'Hash';  $sigil := '%'; }
    if $<key> {
        my $scope := 'package';
        if ~$sigil ~ ~$<word> eq '@_' { $scope := 'lexical' }
        my $base := PAST::Var.new(
            :name( $sigil ~ $<word> ),
            :scope($scope),
            :viviself($viviself)
        );
        make PAST::Var.new(
            $base,
            $( $<key>[0]<expr> ),
            :scope('keyed'),
            :viviself('Undef')
        );
    }
    else {
        if ~$<sigil> eq '$#' { # XXX not yet implemented
        }
        make PAST::Var.new(
            :node($/),
            :name( $sigil ~ $<word> ),
            :viviself($viviself),
            :scope('package')
        );
    }

}


method special_variable($/) {
    make PAST::Var.new( :node($/), :name(~$/), :scope('package') );
}
