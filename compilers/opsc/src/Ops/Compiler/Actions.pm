# Copyright (C) 2009, Parrot Foundation.
# $Id$

class Ops::Compiler::Actions is HLL::Actions;

method TOP($/) {
    make $<body>.ast;
}

method body($/) {
    my $past := PAST::Stmts.new(
        :node($/)
    );

    $past<preamble> := PAST::Stmts.new(
        :node($/)
    );
    $past<ops> := PAST::Stmts.new(
        :node($/)
    );

    for $<preamble> {
        $past<preamble>.push($_.ast);
    }

    for $<op> {
        $past<ops>.push($_.ast);
    }

    make $past;
}

method preamble($/) {
    make PAST::Op.new(
        :node($/),
        :pasttype('preamble'),
        ~$<preamble_guts>
    );
}

method op($/) {

    # Handling flags.
    my %flags := pir::new__Ps('Hash');
    for $<op_flag> {
        %flags{~$_<identifier>} := 1;
    }

    my @args := list();
    if ($<op_params>) {
        @args := @($<op_params>[0].ast);
    }

    my $past := Ops::Op.new(
        :code(-1),
        :name(~$<op_name>),
        :type(~$<op_type>),

        :flags(%flags),
        :args(@args),
        :normalized_args(normalize_args(@args)),

        $<op_body>.ast
    );

    make $past;
}

# Normalize args
# For each arg produce LoL of all available variants
# E.g. "in" will produce "i" and "ic" variants
#
# type one of <i p s n>
# direction one of <i o io>
# is_label one of <0 1>

sub normalize_args(@args) {
    my @result;
    for @args -> $arg {
        my $res := PAST::Var.new(
            :isdecl(1)
        );

        if $arg<type> eq 'LABEL' {
            $res<type>     := 'i';
            $res<is_label> := 1;
        }
        else {
            $res<is_label> := 0;
        }

        if $arg<type> eq 'INTKEY' {
            $res<type> := 'ki';
        }
        else {
            $res<type> := lc(substr($arg<type>, 0, 1));
        }

        my $use := $arg<direction>;

        if $use eq 'in' {
            $res<variant>   := $res<type> ~ "c";
            $res<direction> := 'i';
        }
        elsif $use eq 'invar' {
            $res<direction> := 'i';
        }
        elsif $use eq 'inconst' {
            $res<type>      := $res<type> ~ "c";
            $res<direction> := 'i';
        }
        elsif $use eq 'inout' {
            $res<direction> := 'io';
        }
        else {
            $res<direction> := 'o';
        }

        @result.push($res);
    }
    @result;
}

# Expand normalized arguments. Create list of all possible variants of arguments.
sub expand_arguments(*@args) {
    return unless +@args;
}



method op_params($/) {
    my $past := PAST::Stmts.new(
        :node($/)
    );

    for $<op_param> {
        $past.push($_.ast);
    }

    make $past;
}

method op_param($/) {
    my $past := PAST::Var.new(
        :node($/),
        :isdecl(1)
    );

    # We have to store 2 "types". Just set 2 properties on Var for now
    $past<direction> := ~$<op_param_direction>;
    $past<type>      := ~$<op_param_type>;

    make $past;
}

method op_body($/) {
    # Single big chunk
    make PAST::Op.new(
        :node($/),
        :pasttype('inline'),
        :inline(~$/)
    );
}

# Local Variables:
#   mode: perl6
#   fill-column: 100
# End:
# vim: expandtab ft=perl6 shiftwidth=4:
