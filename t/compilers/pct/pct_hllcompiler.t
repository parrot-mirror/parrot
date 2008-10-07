#!perl

# Copyright (C) 2005-2006, The Perl Foundation.
# $Id$

use strict;
use warnings;
use lib qw(t . lib ../lib ../../lib ../../../lib);
use Test::More;
use Parrot::Test tests => 4;

pir_output_is( <<'CODE', <<'OUT', 'some of the auxiliary methods' );

.namespace ['None';'Module']
.sub 'q' :anon
.end
.namespace ['None';'Parser']
.sub 'q' :anon
.end
.namespace ['None';'Grammar']
.sub 'q' :anon
.end
.sub _main :main
    load_bytecode 'PCT/HLLCompiler.pbc'
    $P0 = new ['PCT';'HLLCompiler']

    # parse_name method
    $P1 = $P0.'parse_name'('None::Module')
    $S1 = $P1[0]
    say $S1
    $S1 = $P1[1]
    say $S1

    $P0.'parsegrammar'('None::Parser')
    $P1 = $P0.'parsegrammar'()
    $P1 = $P1.get_name()
    $S1 = join '::', $P1
    say $S1

    $P0.'astgrammar'('None::Grammar')
    $P1 = $P0.'astgrammar'()
    $P1 = $P1.get_name()
    $S1 = join '::', $P1
    say $S1

    end
.end
CODE
None
Module
parrot::None::Parser
parrot::None::Grammar
OUT

pir_output_is( <<'CODE', <<'OUT', 'one complete start-to-end compiler' );

.namespace [ 'NoneParser' ]

.sub 'TOP'
    .param string source
    .return (source)
.end

.namespace [ 'NoneBuilder' ]

.sub 'init' :anon :load :init
    load_bytecode 'Protoobject.pbc'
    $P0 = get_hll_global 'Protomaker'
    $P1 = $P0.'new_subclass'('Protoobject', 'NoneBuilder', 'text')
.end

.sub 'get' :method
    .param string stage

    $P0 = new ['PAST';'Op']
    $P0.'pasttype'('inline')
    $P0.'inline'("print %0\nprint \"\\n\"")

    $P2 = getattribute self, "text"
    $P1 = new ['PAST';'Val']
    $P1.'value'($P2)

    $P0.'push'($P1)

    .return ($P0)
.end

.sub 'text' :method
    .param pmc word
    setattribute self, 'text', word
.end

.namespace [ 'NoneGrammar' ]

.sub 'init' :anon :load :init
    load_bytecode 'Protoobject.pbc'
    $P0 = get_hll_global 'Protomaker'
    $P1 = $P0.'new_subclass'('Protoobject', 'NoneGrammar')
.end

.sub 'apply' :method
    .param pmc source

    $P0 = new 'NoneBuilder'
    $P0.'text'(source)

    .return ($P0)
.end

.namespace [ 'None';'Compiler' ]

.sub _main :main
    load_bytecode 'PCT.pbc'

    $P0 = new ['PCT';'HLLCompiler']
    $P0.'language'('None')
    $P0.'parsegrammar'('NoneParser')
    $P0.'astgrammar'('NoneGrammar')

    .local pmc args
    args = new 'ResizableStringArray'
    push args, "command"
    push args, "-e"
    push args, "thingy"
    $P1 = $P0.'command_line'(args)

    .return()
.end


CODE
thingy
OUT

pir_output_is( <<'CODE', <<'OUT', 'default stages' );
.sub _main :main
    load_bytecode 'PCT/HLLCompiler.pbc'

    .local pmc hllcompiler
    hllcompiler = new ['PCT';'HLLCompiler']

    $P0 = getattribute hllcompiler, "@stages"
    $S0 = join " ", $P0
    say $S0
    .return()
.end

CODE
parse past post pir evalpmc
OUT

pir_output_is( <<'CODE', <<'OUT', 'inserting and removing stages' );
.sub _main :main
    load_bytecode 'PCT/HLLCompiler.pbc'

    .local pmc hllcompiler
    hllcompiler = new ['PCT';'HLLCompiler']

    hllcompiler.removestage('parse')
    hllcompiler.addstage('foo')
    hllcompiler.addstage('bar', 'before' => 'evalpmc')
    hllcompiler.addstage('optimize', 'after' => 'past')
    hllcompiler.addstage('optimize', 'after' => 'post')
    hllcompiler.addstage('peel', 'after' => 'optimize')
    $P0 = getattribute hllcompiler, "@stages"
    $S0 = join " ", $P0
    say $S0
    .return()
.end

CODE
past optimize peel post optimize peel pir bar evalpmc foo
OUT

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
