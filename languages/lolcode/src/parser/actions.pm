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
    my $past := PAST::Block.new( :blocktype('declaration'), :node( $/ ) );
    for $<statement> {
        $past.push( $( $_ ) );
    }
    make $past;
}


method statement ($/, $key) {
    make $( $/{$key} ); # For now
}


method visible($/) {
    my $past := PAST::Op.new( :name('VISIBLE'), :pasttype('call'), :node( $/ ) );
    if ( $<no_newline> ) {
        $past.push( PAST::Val.new( :value( 1 ), :named( PAST::Val.new( :value('no_newline') ) ) ) );
    }
    for $<value> {
        $past.push( $( $_ ) );
    }
    make $past;
}

method declare($/) {
    $($<variable>).isdecl(1);
    if ($<value>) { 
        # XXX Someone clever needs to refactor this into C<assign>
        my $past := PAST::Op.new( :pasttype('bind'), :node( $/ ) );
        $past.push( $( $<variable> ) );
        $past.push( $( $<value>[0] ) );
        make $past;
    } else {
        make $( $<variable> );
    }
}

method assign($/) {
        my $past := PAST::Op.new( :pasttype('bind'), :node( $/ ) );
        $past.push( $( $<variable> ) );
        $past.push( $( $<value> ) );
        make $past;
}

method value($/, $key) {
    make $( $/{$key} );
}


method integer($/) {
    make PAST::Val.new( :value( ~$/ ), :returns('Integer'), :node($/) );
}


method quote($/) {
    make PAST::Val.new( :value( $($<string_literal>) ), :node($/) );
}


method variable($/) {
    make PAST::Var.new( :name( ~$<name> ),
                        :scope('lexical'),
                        :viviself('Undef'),
                        :node( $/ )
                      );
}


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

