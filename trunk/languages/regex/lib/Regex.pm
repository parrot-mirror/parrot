# -*- perl -*-

package Regex;

use base 'Exporter';
BEGIN {
    @Regex::EXPORT_OK = qw(expr_to_tree tree_to_list list_to_pasm compile);
};

use Regex::Parse;
use Regex::PreOptimize;
use Regex::Optimize;
use Regex::Generate;

use Regex::Rewrite::Stackless;
#use Regex::CodeGen::Rx;
use Regex::CodeGen::Pasm;
use Regex::CodeGen::IMCC;

use strict;

sub expr_to_tree {
    my ($expr, %options) = @_;

    my $parser = Regex::Parse->new(%options);
    my $tree = $parser->compile($expr);
    return $tree if $options{'no-tree-optimize'};

    my $opt1 = Regex::PreOptimize->new();
    return $opt1->optimize_tree($tree);
}

sub tree_to_list {
    my ($tree, %options) = @_;

    my $rewrite = Regex::Rewrite::Stackless->new(%options);
    my @code = $rewrite->run($tree);
    return @code if $options{'no-list-optimize'};

    my $opt2 = Regex::Optimize->new();
    return $opt2->optimize(@code);
}

sub list_to_pasm {
    my ($code, %options) = @_;
    my $cgen;

    if (($options{output} || '') eq 'IMCC') {
        $cgen = Regex::CodeGen::IMCC->new(%options);
    } else {
        $cgen = Regex::CodeGen::Pasm->new(%options);
    }
    return $cgen->output(@$code);
}

sub compile {
    my ($expr, %options) = @_;
    my $tree = expr_to_tree($expr, %options);
    my @code = tree_to_list($tree, %options);
    return list_to_pasm(\@code, %options);
}

1;
