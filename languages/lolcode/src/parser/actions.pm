# Copyright (C) 2008, The Perl Foundation.
# $Id$

=begin comments

lolcode::Grammar::Actions - ast transformations for lolcode

This file contains the methods that are used by the parse grammar
to build the PAST representation of an lolcode program.
Each method below corresponds to a rule in F<src/parser/grammar.pg>,
and is invoked at the point where C<{*}> appears in the rule,
with the current match object as the first argument.  If the
line containing C<{*}> also has a C<#= key> comment, then the
value of the comment is passed as the second argument to the method.

=end comments

class lolcode::Grammar::Actions;

method TOP($/) {
    my $block := $( $<block> );
    my $it := PAST::Var.new( :name( 'IT' ), :scope('lexical'), :viviself('Undef'), :isdecl(1));
    $block.unshift($it);
    make $block;
}


method statement ($/, $key) {
    if (($key eq 'expression')&&($<expression><tokens>[0]<identifier> ne 'VISIBLE')) {
        my $it := PAST::Var.new( :name( 'IT' ), :scope('lexical'), :viviself('Undef'));
        my $past := PAST::Op.new( :pasttype('bind'), :node( $/ ) );
        $past.push( $it );
        $past.push( $( $<expression> ) );
        make $past;
    }
    else {
        make $( $/{$key} ); # For now
    }
}


method declare($/) {
    our $?BLOCK;
    our @?BLOCK;

    my $name := ~$<variable><identifier>;

    my $var := PAST::Var.new( :name( $name ),
                        :viviself('Undef'),
                        :node( $/ )
                    );

    my $scope := 'lexical';
    if $<scope>[0] {
        if ~$<scope>[0] eq 'FARAWAY' {
            $scope := 'package';
        }
    }

    $var.scope(~$scope);
    unless $?BLOCK.symbol($name) {
        $?BLOCK.symbol($name, :scope($scope));
        $var.isdecl(1);
    }

    if ($<expression>) {
        $var.isdecl(1);
        # XXX Someone clever needs to refactor this into C<assign>
        my $past := PAST::Op.new( :pasttype('bind'), :node( $/ ) );
        $past.push( $var );
        $past.push( $( $<expression>[0] ) );
        make $past;
    }
    else {
        make $var;
    }
}

method assign($/) {
    my $past := PAST::Op.new( :pasttype('bind'), :node( $/ ) );
    $past.push( $( $<variable> ) );
    $past.push( $( $<expression> ) );
    make $past;
}

method function($/,$key) {
    our $?BLOCK;
    if $key eq 'params' {
        our $?BLOCK_SIGNATURE;
        my $arglist;
        $arglist := PAST::Stmts.new();
        # if there are any parameters, get the PAST for each of them and
        # adjust the scope to parameter.
        for $<parameters> {
            my $param := PAST::Var.new(:name(~$_<identifier>), :scope('parameter'), :node($($_)));
            $param.isdecl(1);
            $arglist.push($param);
        }
        $?BLOCK_SIGNATURE := $arglist;
    }
    elsif $key eq 'block' {
        my $block := $( $<block> );
        $block.blocktype('declaration');
        $?BLOCK.symbol(~$<variable><identifier>, :arity($block.arity()));


        my $it := PAST::Var.new( :name( 'IT' ), :scope('lexical'), :viviself('Undef'), :isdecl(1));
        $block[1].unshift($it);

        $it := PAST::Var.new( :name( 'IT' ), :scope('lexical'));
        $block[1].push($it);
        $block.name(~$<variable><identifier>);
        make $block;
        #my $past := PAST::Op.new( :pasttype('bind'), :node( $/ ) );
        #$($<variable>).isdecl(1);
        #$past.push( $( $<variable> ) );
        #$past.push( $block );
        #make $past;
    }



}

method ifthen($/) {
    my $count := +$<expression> - 1;
    my $expr  := $( $<expression>[$count] );
    my $then  := $( $<block>[$count] );
    $then.blocktype('immediate');
    my $past := PAST::Op.new( $expr, $then,
                              :pasttype('if'),
                              :node( $/ )
                            );
    if ( $<else> ) {
        my $else := $( $<else>[0] );
        $else.blocktype('immediate');
        $past.push( $else );
    }
    while ($count != 0) {
        $count := $count - 1;
        $expr  := $( $<expression>[$count] );
        $then  := $( $<block>[$count] );
        $then.blocktype('immediate');
        $past  := PAST::Op.new( $expr, $then, $past,
                               :pasttype('if'),
                               :node( $/ )
                             );
    }
    $expr := $past.shift();
    my $it := PAST::Var.new( :name( 'IT' ), :scope('lexical'), :viviself('Undef'));
    my $bind := PAST::Op.new( :pasttype('bind'), :node( $/ ) );
    $bind.push( $it );
    $bind.push( $expr );
    $past.unshift( $it );
    my $past := PAST::Stmts.new( $bind, $past, :node( $/ ) );
    make $past;
}

method switch($/) {
    my $count := +$<value> - 1;
    my $val  := $( $<value>[$count] );
    my $then  := $( $<block>[$count] );
    my $it := PAST::Var.new( :name( 'IT' ), :scope('lexical'), :viviself('Undef'));
    my $expr := PAST::Op.new(:pasttype('call'), :name('BOTH SAEM'), $it, $val);
    $then.blocktype('immediate');
    my $past := PAST::Op.new( $expr, $then,
                              :pasttype('if'),
                              :node( $/ )
                            );
    if ( $<else> ) {
        my $else := $( $<else>[0] );
        $else.blocktype('immediate');
        $past.push( $else );
    }
    while ($count != 0) {
        $count := $count - 1;
        $val  := $( $<value>[$count] );
        $expr := PAST::Op.new(:pasttype('call'), :name('BOTH SAEM'), $it, $val);
        $then  := $( $<block>[$count] );
        $then.blocktype('immediate');
        $past  := PAST::Op.new( $expr, $then, $past,
                               :pasttype('if'),
                               :node( $/ )
                             );
    }
    #$expr := $past.shift();
    #my $it := PAST::Var.new( :name( 'IT' ), :scope('lexical'), :viviself('Undef'));
    #my $bind := PAST::Op.new( :pasttype('bind'), :node( $/ ) );
    #$bind.push( $it );
    #$bind.push( $expr );
    #$past.unshift( $it );
    my $past := PAST::Stmts.new( $past, :node( $/ ) );
    make $past;
}

method block($/,$key) {
    our $?BLOCK;
    our @?BLOCK;
    if $key eq 'open' {
        our $?BLOCK_SIGNATURE;
        $?BLOCK := PAST::Block.new( PAST::Stmts.new(), :node($/) );
        @?BLOCK.unshift($?BLOCK);
        my $iter := $?BLOCK_SIGNATURE.iterator();
        $?BLOCK.arity(0);
        for $iter {
            $?BLOCK.arity($?BLOCK.arity() + 1);
            $?BLOCK[0].push($_);
            $?BLOCK.symbol($_.name(), :scope('lexical'));
        }
    }
    elsif $key eq 'close' {
        #my $past := PAST::Block.new( :blocktype('declaration'), :node( $/ ) );
        my $past := @?BLOCK.shift();
        $?BLOCK := @?BLOCK[0];
        my $stmts := PAST::Stmts.new( :node( $/ ) );
        for $<statement> {
            $stmts.push( $( $_ ) );
        }
        $past.push($stmts);
        make $past;
    }
}

method value($/, $key) {
    make $( $/{$key} );
}

method bang($/) {
    make PAST::Val.new( :value( ~$/ ), :returns('String'), :node($/) );
}

method expression($/) {
    my $past := PAST::Op.new( :name('expr_parse'), :pasttype('call'), :node( $/ ) );
    for $<tokens> {
        my $name := ~$_<identifier>;
        if($_<identifier>) {
            my $foo := lookup($name);
            our $?BLOCK;
            our @?BLOCK;
            if $?BLOCK.symbol($name) && $?BLOCK.symbol($name)<scope> {
                $past.push(PAST::Var.new(:name($name), :scope($?BLOCK.symbol($name)<scope>)));
            }
            else {
                my $inline := '%r = find_name "' ~ $_<identifier> ~ '"';
                $past.push(PAST::Op.new( :inline($inline) ));
            }
        }
        elsif($_ eq "MKAY"){
            my $inline := '%r = find_name "MKAY"';
            $past.push(PAST::Op.new( :inline($inline) ));
        }
        else {
            $past.push( $( $_ ) );
        }
    }
    make $past;
}

method integer($/) {
    make PAST::Val.new( :value( ~$/ ), :returns('Integer'), :node($/) );
}

method float($/) {
    make PAST::Val.new( :value( ~$/ ), :returns('Float'), :node($/) );
}

method boolean($/) {
    if (~$/ eq 'FAIL' ) {
        make PAST::Val.new( :value( 0 ), :returns('Boolean'), :node($/) );
    }
    else {
        make PAST::Val.new( :value( 1 ), :returns('Boolean'), :node($/) );
    }
}

method quote($/) {
    make PAST::Val.new( :value( $($<yarn_literal>) ), :node($/) );
}


method variable ($/) {
    if ($<identifier> eq 'IT') {
        make PAST::Var.new( :name( 'IT' ), :scope('lexical'), :viviself('Undef'));
    }
    else {
        our $?BLOCK;
        our @?BLOCK;

        my $var := PAST::Var.new( :name( $<identifier> ),
                            :scope('lexical'),
                            :viviself('Undef'),
                            :node( $/ )
                        );
        if $?BLOCK.symbol($<identifier>) {
            my $scope := '' ~ $?BLOCK.symbol($<identifier>)<scope>;
            $var.scope(~$scope);
        }
        else {
            our @?BLOCK;
            my $exists := 0;
            my $scope;
            for @?BLOCK {
                if $_ {
                    my $sym_table := $_.symbol(~$<identifier>);
                    if $sym_table {
                        $exists := 1;
                        $scope := '' ~ $sym_table<scope>;
                    }
                }
            }
            if $exists == 0 {
                $var.scope('package');
            }
            else {
                $var.scope($scope);
            }
        }

        make $var;
    }
}


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

