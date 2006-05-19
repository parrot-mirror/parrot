# Copyright 2005, The Perl Foundation.

=head1 NAME

TGE::Parser - parser for the grammar syntax of TGE

=head1 DESCRIPTION

=cut

.namespace [ 'TGE::Parser' ]

.include "compilers/tge/TGE/Parser_gen.pir"

=head2 agparse

Take the source string for a tree grammar, and return a sensible data
structure.

=cut

.sub agparse
    .param string source

    # Parse the source string and build a match tree
    .local pmc match
    .local pmc start_rule
    start_rule = find_global "TGE::Parser", "start"
    match = start_rule(source)
    # Verify the parse
    $I0 = match.__get_bool()
    unless $I0 goto err_parse    # if parse fails, stop
#        print "parse succeeded\n"
#        print "Match tree dump:\n"
#        load_bytecode "dumper.pbc"
#        load_bytecode "PGE/Dumper.pbc"
#        '_dumper'(match, "match")

    .local pmc grammar
    grammar = _load_grammar()

    # Transform the parse tree and return the result
    .local pmc tree_match
    tree_match = grammar.apply(match)
    $P5 = tree_match.get('result')
    .return($P5)

  err_parse:
    print "Unable to parse the tree grammar.\n"
    end
.end

.sub _load_grammar
    # Construct a tree grammar for manipulating the parse tree
    .local pmc grammar
    grammar = new "TGE"
    $P3 = find_global "TGE::Parser", "ROOT_result"
    grammar.agrule("ROOT", "result", ".", $P3)
    $P3 = find_global "TGE::Parser", "statements_result"
    grammar.agrule("statements", "result", ".", $P3)
    $P3 = find_global "TGE::Parser", "transrule_result"
    grammar.agrule("transrule", "result", ".", $P3)
    $P3 = find_global "TGE::Parser", "type_value"
    grammar.agrule("type", "value", ".", $P3)
    $P3 = find_global "TGE::Parser", "attrdef_name"
    grammar.agrule("attrdef", "name", ".", $P3)
    $P3 = find_global "TGE::Parser", "attrdef_parent"
    grammar.agrule("attrdef", "parent", ".", $P3)
    $P3 = find_global "TGE::Parser", "attrdef_action"
    grammar.agrule("attrdef", "action", ".", $P3)

    .return (grammar)
.end

.sub ROOT_result
    .param pmc tree
    .param pmc node
    $I0 = exists node["TGE::Parser::statements"]
    unless $I0 goto err_no_tree
    $P0 = node["TGE::Parser::statements"]
    $P2 = tree.get('result', $P0, 'statements')
    .return ($P2)

err_no_tree:
   print "Top-level rule did not match.\n"
   .return ()
.end

.sub statements_result
    .param pmc tree
    .param pmc node
    .local pmc rules
    rules = new .ResizablePMCArray
    $I0 = defined node["TGE::Parser::transrule"]
    unless $I0 goto err_no_tree
    $P0 = node["TGE::Parser::transrule"]

    # Iterate over the list of rules, and generate a processed tree for
    # each rule.  Return an array of all the processed rules.
    .local pmc iter
    iter = new .Iterator, $P0 # loop over the array
    iter = 0 # start at the beginning
loop_start:
    unless iter goto loop_end
    $P1 = shift iter
    $P2 = tree.get('result', $P1, 'transrule')
    push rules, $P2
    goto loop_start
loop_end:
    .return (rules)

err_no_tree:
    print "This grammar contained no rules.\n"
    .return (rules)
.end

.sub transrule_result
    .param pmc tree
    .param pmc node
    .local pmc rule
    rule = new .Hash

    # Get the type name
    $I0 = exists node["TGE::Parser::type"]
    unless $I0 goto err_no_rule
    $P1 = node["TGE::Parser::type"]
    $P2 = tree.get('value', $P1, 'type')
    rule["type"] = $P2

    $I0 = exists node["TGE::Parser::attrdef"]
    unless $I0 goto err_no_rule
    $P3 = node["TGE::Parser::attrdef"]
    $P4  = tree.get('name', $P3, 'attrdef')
    rule["name"] = $P4
    $P4 = tree.get('parent', $P3, 'attrdef')
    rule["parent"] = $P4
    $P4 = tree.get('action', $P3, 'attrdef')
    rule["action"] = $P4
    $S0 = typeof $P1
    .return (rule)
   
err_no_rule:
    print "Unable to find all the components of a rule definition\n"
    return ()
.end

# The attribute 'value' on nodes of type 'type'.
.sub type_value
    .param pmc tree
    .param pmc node
    .local pmc value
    value = new .String
    $S2 = node
    value = $S2
    .return (value)
.end

# The attribute 'name' on nodes of type 'attrdef'.
.sub attrdef_name
    .param pmc tree
    .param pmc node
    .local pmc name
    name = new .String
    $P2 = node["TGE::Parser::name"]
    $P3 = $P2[0]
    $S1 = $P3
    name = $S1
    .return (name)
.end

# The attribute 'parent' on nodes of type 'attrdef'.
.sub attrdef_parent
    .param pmc tree
    .param pmc node
    .local pmc name
    name = new .String
    $P2 = node["TGE::Parser::parenlist"]
    $P3 = $P2[0]
    $S1 = $P3
    name = $S1
    .return (name)
.end

# The attribute 'action' on nodes of type 'attrdef'.
.sub attrdef_action
    .param pmc tree
    .param pmc node
    .local pmc name
    name = new .String
    $P2 = node["TGE::Parser::codeblock"]
    $P3 = $P2[0]
    $S1 = $P3
    name = $S1
    .return (name)
.end

=head1 AUTHOR

Allison Randal <allison@perl.org>

=cut
