#!./parrot-nqp
# Copyright (C) 2010, Parrot Foundation.
# $Id$

pir::load_bytecode('PCT.pbc');
pir::load_bytecode('PAST/Pattern.pbc');

plan(501);

test_type_matching();
test_attribute_exact_matching();

sub test_type_matching() {
    my $blockPat := PAST::Pattern::Block.new();
    my $opPat := PAST::Pattern::Op.new();
    my $stmtsPat := PAST::Pattern::Stmts.new();
    my $valPat := PAST::Pattern::Val.new();
    my $varPat := PAST::Pattern::Var.new();
    my $varListPat := PAST::Pattern::VarList.new();

    my $block := PAST::Block.new();
    my $op := PAST::Op.new();
    my $stmts := PAST::Stmts.new();
    my $val := PAST::Val.new();
    my $var := PAST::Var.new();
    my $varList := PAST::VarList.new();

    my @objs := [ $block, $op, $stmts, $val, $var, $varList ];

    for @objs {
        if $_ ~~ PAST::Block {
            ok($_ ~~ $blockPat, "PAST::Block ~~ PAST::Pattern::Block.");
        }
        else {
            ok(!($_ ~~ $blockPat), 
               ~pir::class__p_p($_) ~ " !~~ PAST::Pattern::Block.");
        }

        if $_ ~~ PAST::Op {
            ok($_ ~~ $opPat, "PAST::Op ~~ PAST::Pattern::Op.");
        }
        else {
            ok(!($_ ~~ $opPat),
               ~pir::class__p_p($_) ~ " !~~ PAST::Pattern::Op.");
        }

        if $_ ~~ PAST::Stmts {
            ok($_ ~~ $stmtsPat, "PAST::Stmts ~~ PAST::Pattern::Stmts.");
        } 
        else {
            ok(!($_ ~~ $stmtsPat),
               ~pir::class__p_p($_) ~ " !~~ PAST::Pattern::Stmts.");
        }

        if $_ ~~ PAST::Val {
            ok($_ ~~ $valPat, "PAST::Val ~~ PAST::Pattern::Val.");
        }
        else {
            ok(!($_ ~~ $valPat),
               ~pir::class__p_p($_) ~ " !~~ PAST::Pattern::Val.");
        }

        if $_ ~~ PAST::Var {
            ok($_ ~~ $varPat, "PAST::Var ~~ PAST::Pattern::Var.");
        }
        else {
            ok(!($_ ~~ $varPat),
               ~pir::class__p_p($_) ~ " !~~ PAST::Pattern::Var.");
        }

        if $_ ~~ PAST::VarList {
            ok($_ ~~ $varListPat,
               "PAST::VarList ~~ PAST::Pattern::VarList.");
        }
        else {
            ok(!($_ ~~ $varListPat),
               ~pir::class__p_p($_) ~ " !~~ PAST::Pattern::VarList.");
	}
    }
}

sub test_attribute_exact_matching () {
    test_attribute_exact_matching_on_node_attr("name");
    test_attribute_exact_matching_on_node_attr("source");
    test_attribute_exact_matching_on_node_attr("pos");
    test_attribute_exact_matching_on_node_attr("returns");
    test_attribute_exact_matching_on_node_attr("arity");
    test_attribute_exact_matching_on_node_attr("named");
    test_attribute_exact_matching_on_node_attr("flat");
    test_attribute_exact_matching_on_node_attr("lvalue");
}

sub node_with_attr_set ($class, $attr, $val) {
    my $node := $class.new();
    if ($attr eq "source" || $attr eq "pos") {
        $node{$attr} := $val;
    }
    else {
        $node.attr($attr, $val, 1);
    }
    $node;
}

sub test_attribute_exact_matching_on_node_attr($attr) {
    my @classes :=
      $attr eq "lvalue" ??
        [ [PAST::Pattern::Block, PAST::Block],
          [PAST::Pattern::Op, PAST::Op],
          [PAST::Pattern::Stmts, PAST::Stmts],
          [PAST::Pattern::Var, PAST::Var],
          [PAST::Pattern::VarList, PAST::VarList] ]
        !!
          [ [PAST::Pattern::Block, PAST::Block],
            [PAST::Pattern::Op, PAST::Op],
            [PAST::Pattern::Stmts, PAST::Stmts],
            [PAST::Pattern::Val, PAST::Val],
            [PAST::Pattern::Var, PAST::Var],
            [PAST::Pattern::VarList, PAST::VarList] ];

    for @classes {
        my $class := $_[1];
        my $patClass := $_[0];
        my $pattern := node_with_attr_set($patClass, $attr, "foo");

        my $right := node_with_attr_set($class, $attr, "foo");
        ok($right ~~ $pattern, "Matching $class.$attr.");

        my @wrong := [ node_with_attr_set($class, $attr, "bar"),
                       node_with_attr_set($class,
                                          ($attr eq "name" ??
                                           "returns" !! "name"),
                                          "foo"),
                       $class.new("foo"),
                       $class.new()
                     ];

        for @classes {
            my $otherClass := $_[1];
            unless (pir::issame__i_p_p($class, $otherClass)) {
                pir::push_p_p(@wrong, node_with_attr_set($otherClass,
                                                         $attr,
                                                         "foo"));
            }
        }

        my $iota := 0;
        for @wrong {
            ok(!($_ ~~ $pattern),
               "Non-matching $class.$attr " ~ ($iota++) );
        }
    }
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
