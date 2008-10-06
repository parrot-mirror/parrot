#!perl
# Copyright (C) 2001-2007, The Perl Foundation.
# $Id$

use strict;
use warnings;
use lib qw( t . lib ../lib ../../lib ../../../lib );
use Test::More;
use Parrot::Test tests => 20;
use Parrot::Test::PGE;

=head1 NAME

t/compilers/pge/pge_text.t - PGE::Text tests

=head1 DESCRIPTION

These tests examine the ability of PGE to match text with brackets in it.

=head1 SYNOPSIS

        % prove t/compilers/pge/text_brk.t

=cut

## First, test direct calls to PGE::Text::bracketed
##
pir_output_is( <<'CODE', <<'OUT', "bracketed" );
.sub main :main
    .local pmc bracketed

    load_bytecode 'PGE.pbc'
    load_bytecode 'PGE/Text.pir'

    bracketed = get_global ['PGE';'Text'], "bracketed"

    $S0 = "{ nested { and } okay, () and <>,  escaped \\}'s } okay"
    $P0 = bracketed($S0)
    bsr result
    $S0 = "{ nested \n{ and } okay, \n() and <>, escaped \\}'s } okay"
    $P0 = bracketed($S0)
    bsr result
    $S0 = "{ nested { and } okay,  unbalanced ( and < , escaped \\}'s } okay"
    $P0 = bracketed($S0, "{}")
    bsr result
    $S0 = "{ unmatched nested { not okay, nor ( and < } not okay"
    $P0 = bracketed($S0, "{}")
    bsr result
    $S0 = "{ unbalanced nested [ even with } and ] to match not okay"
    $P0 = bracketed($S0, "{}[]")
    bsr result
    $S0 = "<a quoted \">\" unbalanced right bracket> okay"
    $P0 = bracketed($S0, "<\">")
    bsr result
    $S0 = "<quoted \">\" unbalanced of two quotes (`>>>\"\"\">>>>`)> okay"
    $P0 = bracketed($S0, "<\"`>")
    bsr result
    $S0 = "<a misquoted '>' bracket ends string>"
    $P0 = bracketed($S0, "<\"`>")
    bsr result
    .return ()

  result:
    if $P0 goto succeed
    print "failed\n"
    ret
  succeed:
    $I0 = $P0."to"()
    $S1 = substr $S0, $I0
    print $S1
    print "\n"
    ret
.end
CODE
 okay
 okay
 okay
failed
failed
 okay
 okay
' bracket ends string>
OUT

## Now, test calls as subrules
##
my $PTB = "^<PGE::Text::bracketed>\$";
p6rule_is( "{ nested { and } okay, () and <> pairs okay }",      $PTB );
p6rule_is( "{ nested { and } okay, () <>, escaped \\}'s okay }", $PTB );
p6rule_isnt( "{ unmatched nested { not okay }", $PTB );
p6rule_isnt( "{ unmatched nested ( not okay }", $PTB );

## parameterized with {}
$PTB = "^<PGE::Text::bracketed: {}>";
p6rule_is( "{ nested { } okay, unbalanced (, <, escaped \\} okay}", $PTB );
p6rule_isnt( "{ unmatched nested { not okay }",              $PTB );
p6rule_isnt( "{ unmatched nested { not okay, nor ( and < }", $PTB );

## parameterized with {}[]" (nested and quoted)
$PTB = '^<PGE::Text::bracketed: {}[]"`>';
p6rule_isnt( '{ unbalanced nested [ with } and ] not okay', $PTB );
p6rule_is( '{ balanced nested [ with ] and ( is } okay',          $PTB );
p6rule_is( '{ a quoted "}" unbalanced right bracket} okay',       $PTB );
p6rule_is( '{ quoted "}" unbalanced quotes (`}}}"""}}}}`)} okay', $PTB );

## escaped bracket characters in regex, nesting not checked
## There might be a better suited file for these tests
p6rule_is( '{ opening at start of string', '^\{' );
p6rule_is( 'opening { at end of string {', '\{$' );
p6rule_is( '} closing at start of string', '^\}' );
p6rule_is( 'closing } at end of string }', '\}$' );
p6rule_is( '[ opening at start of string', '^\[' );
p6rule_is( 'opening [ at end of string [', '\[$' );
p6rule_is( '] closing at start of string', '^\]' );
p6rule_is( 'closing ] at end of string ]', '\]$' );

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
