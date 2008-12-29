# Copyright (C) 2007-2008, The Perl Foundation.
# $Id$

class Perl6::Grammar::Actions ;

method TOP($/) {
    my $past := $( $<statement_block> );
    $past.blocktype('declaration');
    declare_implicit_routine_vars($past);
    $past.lexical(0);

    #  Make sure we have the interpinfo constants.
    $past.unshift( PAST::Op.new( :inline('.include "interpinfo.pasm"') ) );

    # Set package for unit mainline
    $past.unshift(set_package_magical());

    # Create the unit's startup block.
    my $main := PAST::Block.new( :pirflags(':main') );
    $main.loadinit().push(
        PAST::Op.new( :inline('$P0 = compreg "Perl6"',
                              'unless null $P0 goto have_perl6',
                              'load_bytecode "perl6.pbc"',
                              'have_perl6:')
        )
    );

   # call the unit mainline, passing any arguments, and return
   # the result.  We force a tailcall here because we need a
   # :load sub (below) to occur last in the generated output, but don't
   # want it to be treated as the module's return value.
   $main.push(
       PAST::Op.new( :pirop('tailcall'),
           PAST::Op.new( :pirop('find_name'), '!UNIT_START' ),
           $past,
           PAST::Var.new( :scope('parameter'), :name('@_'), :slurpy(1) )
       )
    );

    # generate a :load sub that invokes this one, but does so _last_
    # (e.g., at the end of a load_bytecode operation)
    $main.push(
        PAST::Block.new( :pirflags(':load'), :blocktype('declaration'),
            PAST::Op.new(
                :inline( '.include "interpinfo.pasm"',
                         '$P0 = interpinfo .INTERPINFO_CURRENT_SUB',
                         '$P0 = $P0."get_outer"()',
                         '$P0()'
                )
            )
        )
    );
    $main.push( PAST::Stmts.new() );

    make $main;
}


method statement_block($/, $key) {
    our $?BLOCK;
    our @?BLOCK;
    our $?SIGNATURE_BLOCK;
    ##  when entering a block, use any $?SIGNATURE_BLOCK if it exists,
    ##  otherwise create an empty block with an empty first child to
    ##  hold any parameters we might encounter inside the block.
    if $key eq 'open' {
        if $?SIGNATURE_BLOCK {
            $?BLOCK := $?SIGNATURE_BLOCK;
            $?SIGNATURE_BLOCK := 0;
        }
        else {
            $?BLOCK := PAST::Block.new( PAST::Stmts.new(), :node($/));
        }
        @?BLOCK.unshift($?BLOCK);
    }
    if $key eq 'close' {
        my $past := @?BLOCK.shift();
        $?BLOCK := @?BLOCK[0];
        $past.push($($<statementlist>));
        make $past;
    }
}


method block($/) {
    make $( $<statement_block> );
}


method statementlist($/) {
    my $past := PAST::Stmts.new( :node($/) );
    for $<statement> {
        $past.push( $($_) );
    }
    make $past;
}


method statement($/, $key) {
    my $past;
    if $key eq 'control' {
        $past := $( $<statement_control> );
    }
    elsif $key eq 'null' {
        $past := PAST::Stmts.new();
    }
    else {
        my $sml;
        $past := $( $<expr> );
        if $past.isa(PAST::Block) && !$past.blocktype() {
            $past.blocktype('immediate');
        }
        if $key eq 'mod_cond' {
            my $body := $past;
            $past := $( $<statement_mod_cond> );
            $past.push( $body );
            $sml := $<statement_mod_loop>[0];
        }
        if $key eq 'mod_loop' { $sml := $<statement_mod_loop>; }
        if $sml {
            my $body := $past;
            if $sml<sym> eq 'for' {
                if !$body.isa(PAST::Block) {
                    $body := PAST::Block.new( PAST::Stmts.new(), $body );
                    $body.blocktype('immediate');
                }
                declare_implicit_function_vars( $body );
            }
            $past := $( $sml );
            $past.push( $body );
        }
    }
    make $past;
}


method statement_control($/, $key) {
    make $( $/{$key} );
}


method if_statement($/) {
    my $count := +$<xblock> - 1;
    my $past  := $( $<xblock>[$count] );
    declare_implicit_block_vars($past[1], 0);
    ## add any 'else' clause
    if $<pblock> {
        my $else := $( $<pblock>[0] );
        $else.blocktype('immediate');
        declare_implicit_block_vars($else, 0);
        $past.push( $else );
    }
    ## build if/then/elsif structure
    while $count != 0 {
        $count--;
        my $else := $past;
        $past := $( $<xblock>[$count] );
        declare_implicit_block_vars($past[1], 0);
        $past.push($else);
    }
    make $past;
}

method unless_statement($/) {
    my $past := $( $<xblock> );
    $past.pasttype('unless');
    declare_implicit_block_vars($past[1], 0);
    make $past;
}

method while_statement($/) {
    my $past := $( $<xblock> );
    $past.pasttype(~$<sym>);
    declare_implicit_block_vars($past[1], 0);
    make $past;
}

method repeat_statement($/) {
    my $cond  := $( $<EXPR> );
    my $block := $( $<block> );
    $block.blocktype('immediate');
    # pasttype is 'repeat_while' or 'repeat_until'
    my $pasttype := 'repeat_' ~ ~$<loop>;
    make PAST::Op.new( $cond, $block, :pasttype($pasttype), :node($/) );
}

method given_statement($/) {
    my $past := $( $<xblock> );
    $past.push( $past.shift() );              # swap <EXPR> and <pblock>
    $past[0].blocktype('declaration');
    declare_implicit_function_vars($past[0]);
    $past.pasttype('call');
    make $past;
}

method when_statement($/) {
    my $block := $( $<block> );
    $block.blocktype('immediate');

    # Push a handler onto the innermost block so that we can exit if we
    # successfully match
    when_handler_helper($block);

    # Invoke smartmatch of the expression.
    my $match_past := PAST::Op.new(
        PAST::Var.new( :name('$_') ),
        $( $<EXPR> ),
        :name('infix:~~'),
        :pasttype('call'),
        :node($/)
    );

    # Use the smartmatch result as the condition.
    my $past := PAST::Op.new(
        $match_past, $block,
        :pasttype('if'),
        :node( $/ )
    );
    make $past;
}

method default_statement($/) {
    # Always executed if reached, so just produce the block.
    my $block := $( $<block> );
    $block.blocktype('immediate');

    # Push a handler onto the innermost block so that we can exit if we
    # successfully match
    when_handler_helper($block);

    make $block;
}

sub when_handler_helper($block) {
    our $?BLOCK;
    # XXX TODO: This isn't quite the right way to check this...
    unless $?BLOCK.handlers() {
        my @handlers;
        @handlers.push(
            PAST::Control.new(
                PAST::Op.new(
                    :pasttype('pirop'),
                    :pirop('return'),
                    PAST::Var.new(
                        :scope('keyed'),
                        PAST::Var.new( :name('exception'), :scope('register') ),
                        'payload',
                    ),
                ),
                :handle_types('BREAK')
            )
        );
        $?BLOCK.handlers(@handlers);
    }

    # push a control exception throw onto the end of the block so we
    # exit the innermost block in which $_ was set.
    my $last := $block.pop();
    $block.push(
        PAST::Op.new(
            :pasttype('call'),
            :name('break'),
            $last
        )
    );

    # Push a handler onto the block to handle CONTINUE exceptions so we can
    # skip throwing the BREAK exception
    my @handlers;
    if $block.handlers() {
        @handlers := $block.handlers();
    }
    @handlers.push(
        PAST::Control.new(
            PAST::Op.new(
                :pasttype('pirop'),
                :pirop('return'),
            ),
            :handle_types('CONTINUE')
        )
    );
    $block.handlers(@handlers);
}

method loop_statement($/) {
    my $block := $( $<block> );
    $block.blocktype('immediate');
    my $cond  := $<e2> ?? $( $<e2>[0] ) !! 1;
    my $loop := PAST::Op.new( $cond, $block, :pasttype('while'), :node($/) );
    if $<e3> {
        $loop.push( $( $<e3>[0] ) );
    }
    if $<e1> {
        $loop := PAST::Stmts.new( $( $<e1>[0] ), $loop, :node($/) );
    }
    make $loop;
}

method for_statement($/) {
    my $past := $( $<xblock> );
    $past.pasttype('for');
    $past[0] := PAST::Op.new(:name('list'), $past[0]);
    declare_implicit_function_vars($past[1]);
    make $past;
}

method pblock($/) {
    my $block := $( $<block> );
    make $block;
}

method xblock($/) {
    my $pblock := $( $<pblock> );
    $pblock.blocktype('immediate');
    my $past := PAST::Op.new(
        $( $<EXPR> ), $pblock,
        :pasttype('if'),
        :node( $/ )
    );
    make $past;
}

method use_statement($/) {
    my $name := ~$<name>;
    my $past;
    if $name ne 'v6' && $name ne 'lib' {
        ##  Create a loadinit node so the use module is loaded
        ##  when this module is loaded...
        our $?BLOCK;
        $?BLOCK.loadinit().push(
            PAST::Op.new(
                PAST::Val.new( :value($name) ),
                :name('use'),
                :pasttype('call'),
                :node( $/ )
            )
        );
        ##  ...and load it immediately to get its BEGIN semantics
        ##  and symbols for the current compilation.
        use($name);
    }
    $past := PAST::Stmts.new( :node($/) );
    make $past;
}

method begin_statement($/) {
    my $past := $( $<block> );
    $past.blocktype('declaration');
    declare_implicit_routine_vars($past);                  # FIXME
    my $sub := PAST::Compiler.compile( $past );
    $sub();
    # XXX - should emit BEGIN side-effects, and do a proper return()
    make PAST::Block.new();
}

method end_statement($/) {
    my $past := $( $<block> );
    $past.blocktype('declaration');
    declare_implicit_routine_vars($past);                  # FIXME
    my $sub := PAST::Compiler.compile( $past );
    PIR q<  $P0 = get_hll_global ['Perl6'], '@?END_BLOCKS' >;
    PIR q<  $P1 = find_lex '$sub' >;
    PIR q<  push $P0, $P1 >;
    make $past;
}

method catch_statement($/) {
    my $past := $( $<block> );
    $past.blocktype('immediate');
    $past := PAST::Stmts.new(
        PAST::Op.new(
            :pasttype('bind'),
            PAST::Var.new( :name('$_'), :scope('lexical') ),
            PAST::Var.new( :name('exception'), :scope('register') )
        ),
        PAST::Op.new(
            :pasttype('bind'),
            PAST::Var.new( :name('$!'), :scope('lexical') ),
            PAST::Var.new( :name('exception'), :scope('register') )
        ),
        $past
    );
    our $?BLOCK;
    my $eh := PAST::Control.new( $past );
    my @handlers;
    if $?BLOCK.handlers() {
        @handlers := $?BLOCK.handlers();
    }
    @handlers.unshift($eh);
    $?BLOCK.handlers(@handlers);
    make PAST::Stmts.new();
}

method control_statement($/) {
    my $past := $( $<block> );
    $past.blocktype('immediate');
    $past := PAST::Stmts.new(
        PAST::Op.new(
            :pasttype('bind'),
            PAST::Var.new( :name('$_'), :scope('lexical') ),
            PAST::Var.new( :name('exception'), :scope('register') )
        ),
        PAST::Op.new(
            :pasttype('bind'),
            PAST::Var.new( :name('$!'), :scope('lexical') ),
            PAST::Var.new( :name('exception'), :scope('register') )
        ),
        $past
    );
    our $?BLOCK;
    my $eh := PAST::Control.new(
        $past,
        :handle_types('CONTROL')
    );
    my @handlers;
    if $?BLOCK.handlers() {
        @handlers := $?BLOCK.handlers();
    }
    @handlers.unshift($eh);
    $?BLOCK.handlers(@handlers);
    make PAST::Stmts.new();
}

method statement_mod_loop($/) {
    my $expr := $( $<EXPR> );
    my $sym := ~$<sym>;

    if $sym eq 'given' {
        my $assign := PAST::Op.new(
            :name('infix::='),
            :pasttype('bind'),
            :node($/)
        );
        $assign.push(
            PAST::Var.new( :node($/), :name('$_'), :scope('lexical') )
        );
        $assign.push( $expr );

        my $past := PAST::Stmts.new( $assign, :node($/) );
        make $past;
    }
    elsif $sym eq 'for' {
        my $past := PAST::Op.new(
            PAST::Op.new($expr, :name('list')),
            :pasttype($sym),
            :node( $/ )
        );
        make $past;
    }
    else {
        make PAST::Op.new(
            $expr,
            :pasttype( $sym ),
            :node( $/ )
        );
    }
}


method statement_mod_cond($/) {
    my $sym := ~$<sym>;
    my $expr := $( $<EXPR> );
    if $sym eq 'when' {
        $expr := PAST::Op.new(
                     PAST::Var.new( :name('$_'), :scope('lexical') ),
                     $expr,
                     :name('infix:~~'),
                     :pasttype('call'),
                     :node($/)
                 );
        $sym := 'if';
    }
    make PAST::Op.new( $expr, :pasttype($sym), :node($/) );
}


method statement_prefix($/) {
    my $past := $($<statement>);
    my $sym := ~$<sym>;

    if $sym eq 'do' {
        # fall through, just use the statement itself
    }
    ##  after the code in the try block is executed, bind $! to Failure,
    ##  and set up the code to catch an exception, in case one is thrown
    elsif $sym eq 'try' {
        $past := PAST::Op.new( $past, :pasttype('try') );

        ##  Add a catch node to the try op that captures the
        ##  exception object into $!.
        my $catchpir := "    .get_results (%r)\n    store_lex '$!', %r";
        $past.push( PAST::Op.new( :inline( $catchpir ) ) );

        ##  Add an 'else' node to the try op that clears $! if
        ##  no exception occurred.
        my $elsepir  := "    new %r, 'Failure'\n    store_lex '$!', %r";
        $past.push( PAST::Op.new( :inline( $elsepir ) ) );
    }
    elsif $sym eq 'gather' {
        if !$past.isa(PAST::Block) {
            $past := PAST::Block.new($past)
        }
        $past.blocktype('declaration');
        $past := PAST::Op.new( $past, :pasttype('call'),
                               :name('gather'), :node($/) );
    }
    else {
        $/.panic( $sym ~ ' not implemented');
    }
    make $past;
}


method multi_declarator($/) {
    my $sym  := ~$<sym>;
    my $past :=  $<declarator> ?? $( $<declarator> ) !! $( $<routine_def> );

    if $past.isa(PAST::Block) {
        # If we're declaring a multi or a proto, flag the sub as :multi,
        # and transform the sub's container to a Perl6MultiSub.
        if $sym eq 'multi' || $sym eq 'proto' {
            my $pirflags := ~$past.pirflags();
            $past.pirflags( $pirflags ~ ' :multi()' );
            $past.loadinit().push( 
                PAST::Op.new( :name('!TOPERL6MULTISUB'), :pasttype('call'),
                    PAST::Var.new( :name('block'), :scope('register') )
                )
            );
        }
    }

    make $past;
}


method enum_declarator($/, $key) {
    my $values := $( $/{$key} );

    my $name := ~$<name>[0];
    if $name {
        # It's a named enumeration. First, we will get a mapping of all the names
        # we will introduce with this enumeration to their values. We'll compute
        # these at compile time, so then we can build as much of the enum as possible
        # as PAST at compile time too. Note that means that, like a BEGIN block, we
        # will compile, run and get the return value now.
        my $block := PAST::Block.new(
            :blocktype('declaration'),
            PAST::Stmts.new(
                PAST::Op.new(
                    :pasttype('call'),
                    :name('!anon_enum'),
                    $values
                )
            )
        );
        my $getvals_sub := PAST::Compiler.compile( $block );
        my %values := $getvals_sub();

        # Now we need to emit a role of the name of the enum containing:
        #  * One attribute with the same name as the enum
        #  * A method of the same name as the enum
        #  * Methods for each name introduced by the enum that compare the
        #    attribute with the value of that name.
        my $role_past := PAST::Stmts.new(
            PAST::Op.new(
                :pasttype('bind'),
                PAST::Var.new(
                    :name('def'),
                    :scope('register'),
                    :isdecl(1)
                ),
                PAST::Op.new(
                    :pasttype('call'),
                    :name('!keyword_role'),
                    PAST::Val.new( :value($name) )
                )
            ),
            PAST::Op.new(
                :pasttype('call'),
                :name('!keyword_has'),
                PAST::Var.new(
                    :name('def'),
                    :scope('register')
                ),
                PAST::Val.new( :value("$!" ~ $name) ),
                # XXX Set declared type here, when we parse that.
                PAST::Var.new(
                    :name('Object'),
                    :scope('package')
                )
            ),
            PAST::Op.new(
                :pasttype('callmethod'),
                :name('add_method'),
                PAST::Var.new(
                    :name('def'),
                    :scope('register')
                ),
                PAST::Val.new( :value($name) ),
                make_accessor($/, undef, "$!" ~ $name, 1, 'attribute')
            )
        );
        for %values.keys() {
            # Method for this value.
            $role_past.push(PAST::Op.new(
                :pasttype('callmethod'),
                :name('add_method'),
                PAST::Var.new(
                    :name('def'),
                    :scope('register')
                ),
                PAST::Val.new( :value($_) ),
                PAST::Block.new(
                    :blocktype('declaration'),
                    :pirflags(':method'),
                    PAST::Stmts.new(
                        PAST::Op.new(
                            :pasttype('call'),
                            :name('infix:eq'), # XXX not generic enough
                            PAST::Var.new(
                                :name("$!" ~ $name),
                                :scope('attribute')
                            ),
                            PAST::Val.new( :value(%values{$_}) )
                        )
                    )
                )
            ));
        }

        # Now we emit code to create a class for the enum that does the role
        # that we just defined. Note $def in the init code refers to this
        # class from now on. Mark the class as an enum.
        my $class_past := PAST::Stmts.new(
            PAST::Op.new(
                :pasttype('bind'),
                PAST::Var.new(
                    :name('def'),
                    :scope('register'),
                    :isdecl(1)
                ),
                PAST::Op.new(
                    :pasttype('call'),
                    :name('!keyword_enum'),
                    PAST::Var.new(
                        :name('def'),
                        :scope('register')
                    )
                )
            ),
            PAST::Op.new(
                :inline('    setprop %0, "enum", %1'),
                PAST::Var.new(
                    :name('def'),
                    :scope('register')
                ),
                PAST::Val.new(
                    :value(1),
                    :returns('Int')
                )
            )
        );

        # Want to give the class an invoke method that returns the enum value,
        # and get_string, get_number and get_integer v-table overrides to we
        # can get data from it..
        $class_past.push(PAST::Op.new(
            :pasttype('callmethod'),
            :name('add_vtable_override'),
            PAST::Var.new(
                :scope('register'),
                :name('def')
            ),
            'invoke',
            PAST::Block.new(
                :blocktype('declaration'),
                :pirflags(":method"),
                PAST::Var.new(
                    :name("$!" ~ $name),
                    :scope('attribute')
                )
            )
        ));
        $class_past.push(PAST::Op.new(
            :pasttype('callmethod'),
            :name('add_vtable_override'),
            PAST::Var.new(
                :scope('register'),
                :name('def')
            ),
            'get_string',
            PAST::Block.new(
                :blocktype('declaration'),
                :pirflags(":method"),
                PAST::Op.new(
                    :pasttype('call'),
                    :name('prefix:~'),
                    PAST::Var.new(
                        :name("$!" ~ $name),
                        :scope('attribute')
                    )
                )
            )
        ));
        $class_past.push(PAST::Op.new(
            :pasttype('callmethod'),
            :name('add_vtable_override'),
            PAST::Var.new(
                :scope('register'),
                :name('def')
            ),
            'get_integer',
            PAST::Block.new(
                :blocktype('declaration'),
                :pirflags(":method"),
                PAST::Op.new(
                    :pasttype('call'),
                    :name('prefix:+'),
                    PAST::Var.new(
                        :name("$!" ~ $name),
                        :scope('attribute')
                    )
                )
            )
        ));
        $class_past.push(PAST::Op.new(
            :pasttype('callmethod'),
            :name('add_vtable_override'),
            PAST::Var.new(
                :scope('register'),
                :name('def')
            ),
            'get_number',
            PAST::Block.new(
                :blocktype('declaration'),
                :pirflags(":method"),
                PAST::Op.new(
                    :pasttype('call'),
                    :name('prefix:+'),
                    PAST::Var.new(
                        :name("$!" ~ $name),
                        :scope('attribute')
                    )
                )
            )
        ));

        # Now we need to create instances of each of these and install them
        # in a package starting with the enum's name, plus an alias to them
        # in the current package.
        for %values.keys() {
            # Instantiate with value.
            $class_past.push(PAST::Op.new(
                :pasttype('bind'),
                PAST::Var.new(
                    :name($_),
                    :namespace($name),
                    :scope('package')
                ),
                PAST::Op.new(
                    :pasttype('callmethod'),
                    :name('new'),
                    PAST::Var.new(
                        :name('def'),
                        :scope('register')
                    ),
                    PAST::Val.new(
                        :value(%values{$_}),
                        :named( PAST::Val.new( :value("$!" ~ $name) ) )
                    )
                )
            ));

            # Add alias in current package.
            # XXX Need to do collision detection, once we've a registry.
            $class_past.push(PAST::Op.new(
                :pasttype('bind'),
                PAST::Var.new(
                    :name($_),
                    :scope('package')
                ),
                PAST::Var.new(
                    :name($_),
                    :namespace($name),
                    :scope('package')
                )
            ));
        }

        # Assemble all that we build into a statement list and then place it
        # into the init code.
        our $?BLOCK;
        my $loadinit := $?BLOCK.loadinit();
        $loadinit.push($role_past);
        $loadinit.push($class_past);

        # Finally, since it's a decl, we don't have anything to emit at this
        # point; just hand back empty statements block.
        make PAST::Stmts.new();
    }
    else {
        # Emit runtime call anonymous enum constructor.
        make PAST::Op.new(
            :pasttype('call'),
            :name('!anon_enum'),
            $values
        );
    }
}


method routine_declarator($/, $key) {
    my $past;
    if $key eq 'sub' {
        $past := $($<routine_def>);
    }
    elsif $key eq 'submethod' {
        $/.panic('submethod declarations not yet implemented');
    }
    $past.node($/);
    if (+@($past[1])) {
        declare_implicit_routine_vars($past);
    }
    else {
        $past[1].push( PAST::Op.new( :name('list') ) );
    }
    ##  Add a call to !SIGNATURE_BIND to fixup params and do typechecks.
    $past[0].push(
        PAST::Op.new( :pasttype('call'), :name('!SIGNATURE_BIND') )
    );
    make $past;
}


method routine_def($/) {
    my $past := $( $<block> );
    $past.blocktype('declaration');
    if $<deflongname> {
        my $name := ~$<deflongname>[0];
        $past.name( $name );
        our $?BLOCK;
        $?BLOCK.symbol( $name, :scope('package') );
    }
    $past.control('return_pir');
    make $past;
}


method method_def($/) {
    my $past := $( $<block> );
    my $identifier := $<identifier>;
    if $identifier {
        $past.name( ~$identifier[0] );
    }
    $past.control('return_pir');

    # Emit code to apply any traits.
    if $<trait> {
        for $<trait> {
            my $trait := $_;
            if $trait<trait_auxiliary> {
                my $aux  := $trait<trait_auxiliary>;
                my $sym  := $aux<sym>;

                if $sym eq 'is' {
                    my $name := $aux<name>;

                    # Emit call to trait_auxiliary:is apply trait.
                    my @ns := Perl6::Compiler.parse_name( $name );
                    $past.loadinit().push(
                        PAST::Op.new(
                            :pasttype('call'),
                            :name('trait_auxiliary:is'),
                            PAST::Var.new(
                                :name(@ns.pop()),
                                :namespace(@ns),
                                :scope('package')
                            ),
                            PAST::Var.new(
                                :name('block'), :scope('register')
                            )
                        )
                    );
                }
            }
        }
    }

    make $past;
}


method trait($/) {
    my $past;
    if $<trait_auxiliary> {
        $past := $( $<trait_auxiliary> );
    }
    elsif $<trait_verb> {
        $past := $( $<trait_verb> );
    }
    make $past;
}

method trait_auxiliary($/) {
    my $sym := ~$<sym>;
    my $trait;
    if $sym eq 'is' {
        $trait := ~$<name>;
    }
    make PAST::Op.new( :name('list'), 'trait_auxiliary:' ~ $sym, $trait );
}
    

method signature($/, $key) {
    our $?SIGNATURE;
    our $?SIGNATURE_BLOCK;
    our $?BLOCK;
    our @?BLOCK;
    if $key eq 'open' {
        $?SIGNATURE := PAST::Op.new( :pasttype('stmts'), :node($/) );
        $?SIGNATURE_BLOCK := PAST::Block.new( $?SIGNATURE,
                                              :blocktype('declaration') );
        $?SIGNATURE_BLOCK.symbol( '!signature', :defined(1) );
        @?BLOCK.unshift($?SIGNATURE_BLOCK);
    }
    else {
        my $loadinit := $?SIGNATURE_BLOCK.loadinit();
        my $sigobj   := PAST::Var.new( :scope('register') );

        ##  create a Signature object and attach to the block
        $loadinit.push(
            PAST::Op.new( :inline('    %0 = new "Signature"',
                                  '    setprop block, "$!signature", %0'), 
                           $sigobj)
        );

        ##  loop through parameters of signature
        my $arity := $<parameter> ?? +@($<parameter>) !! 0;
        $?SIGNATURE_BLOCK.arity($arity);
        my $i     := 0;
        while $i < $arity {
            my $param_past := $( $<parameter>[$i] );
            my $name       := $param_past.name();
            my $symbol     := $?SIGNATURE_BLOCK.symbol($name);

            ##  set the default value of the param and add var node to block
            $param_past.viviself( $symbol<viviself> );
            $?SIGNATURE.push( $param_past );

            if $symbol<type_binding> {
                $?SIGNATURE.push( $symbol<type_binding> );
            }

            ##  add parameter to the signature object
            my $sigparam := PAST::Op.new( :pasttype('callmethod'), 
                                :name('!add_param'), $sigobj, $name );

            ##  add any typechecks
            my $type := $symbol<type>;
            if +@($type) > 0 {
                ##  don't need the 'and' junction for only one type
                if +@($type) == 1 { $type := $type[0] }
                $type.named('type');
                $sigparam.push($type);
            }

            ##  add traits (we're not using this yet.)
            my $trait := $symbol<trait>;
            if $trait {
                $trait.named('trait');
                $sigparam.push($trait);
            }

            my $readtype := $symbol<readtype>;
            $readtype.named('readtype');
            $sigparam.push($readtype);

            $loadinit.push($sigparam);
            $i++;
        }

        ##  restore block stack and return signature ast
        @?BLOCK.shift();
        make $?SIGNATURE;
    }

    $?BLOCK := @?BLOCK[0];
}


method type_constraint($/) {
    my $past;
    if $<fulltypename> {
        $past := $( $<fulltypename> );
    }
    make $past;
}


method parameter($/) {
    our $?SIGNATURE_BLOCK;
    my $past   := $( $<param_var> );
    my $symbol := $?SIGNATURE_BLOCK.symbol( $past.name() );
    my $sigil  := $<param_var><sigil>;
    my $quant  := $<quant>;

    ##  handle slurpy and optional flags
    if $quant eq '*' {
        $past.slurpy( $sigil eq '@' || $sigil eq '%' );
        $past.named( $sigil eq '%' );
    }
    elsif $<named> eq ':' {          # named
        $past.named(~$<param_var><identifier>);
        if $quant ne '!' {      #  required (optional is default)
            $symbol<viviself> := 'Nil';
        }
    }
    elsif $quant eq '?' {           # positional optional
        $symbol<viviself> := 'Nil';
    }

    ##  handle any default value
    if $<default_value> {
        if $quant eq '!' {
            $/.panic("Can't put a default on a required parameter");
        }
        if $quant eq '*' {
            $/.panic("Can't put a default on a slurpy parameter");
        }
        $symbol<viviself> := $( $<default_value>[0]<EXPR> );
    }

    ##  keep track of any type constraints
    my $typelist := PAST::Op.new( :name('and'), :pasttype('call') );
    $symbol<type> := $typelist;
    if $<type_constraint> {
        for @($<type_constraint>) { 
            my $type_past := $( $_ );
            if substr( $_.text() , 0, 2 ) eq '::' {
                # it's a type binding
                $type_past.scope('lexical');
                $type_past.isdecl(1);
                $type_past.viviself( 
                    PAST::Op.new( :pasttype('callmethod'), :name('WHAT'),
                        PAST::Var.new( :name($past.name()) )
                    )
                );
                $symbol<type_binding> := $type_past;
                $?SIGNATURE_BLOCK.symbol( $type_past.name(), :scope('lexical') );
            }
            else {
                $typelist.push( $type_past );
            }
        }
    }

    my $readtype := '';
    if $<trait> {
        for @($<trait>) {
            my $traitpast := $( $_ );
            my $name := $traitpast[1];
            if $name eq 'readonly' || $name eq 'rw' || $name eq 'copy' {
                $readtype && 
                    $/.panic("Can only use one of readonly, rw, and copy");
                $readtype := $name;
            }
            # else $traitlist.push( $traitpast );  ## when we do other traits
        }
    }
    $symbol<readtype> := PAST::Val.new( :value($readtype || 'readonly') );

    make $past;
}


method param_var($/) {
    our $?SIGNATURE_BLOCK;
    my $name := ~$/;
    my $twigil := ~$<twigil>[0];
    if $twigil && $twigil ne '.' && $twigil ne '!' {
        $/.panic('Invalid twigil used in signature parameter.');
    }
    make PAST::Var.new(
        :name($name),
        :scope('parameter'),
        :node($/)
    );
    ##  Declare symbol as lexical in current (signature) block.
    ##  This is needed in case any post_constraints try to reference
    ##  this new param_var.
    $?SIGNATURE_BLOCK.symbol( $name , :scope('lexical') );
}


method expect_term($/, $key) {
    my $past;
    if $key eq '*' {
        # Whatever.
        $past := PAST::Op.new(
            :pasttype('callmethod'),
            :name('new'),
            :node($/),
            :lvalue(1),
            PAST::Var.new(
                :name('Whatever'),
                :scope('package'),
                :node($/)
            )
        );
    }
    else {
        $past := $( $/{$key} );
    }

    if $<post> {
        for $<post> {
            my $term := $past;
            $past := $($_);
            if $past.name() eq 'infix:,' { $past.name(''); }

            if  $past.isa(PAST::Op)
                && $past.pasttype() eq 'callmethod'
                && !$past.name() {
                    # indirect call, invocant needs to be second arg
                    my $meth := $past[0];
                    $past[0] := $term;
                    $past.unshift($meth);
            }
            else {
                $past.unshift($term);
            }
        }
    }
    make $past;
}


method post($/, $key) {
    make $( $/{$key} );
}


method dotty($/, $key) {
    my $past;

    if $key eq '.' {
        # Just a normal method call.
        $past := $( $<dottyop> );
    }
    elsif $key eq '!' {
        # Private method call. Need to put ! on the start of the name
        # (unless it was call to a code object, in which case we don't do
        # anything more).
        $past := $( $<methodop> );
        my $methodop := $<methodop>;
        if $methodop<name> {
            $past.name('!' ~ $past.name());
        }
        elsif $methodop<quote> {
            $past.name(
                PAST::Op.new(
                    :pasttype('call'),
                    :name('infix:~'),
                    '!',
                    $past.name()
                )
            );
        }
    }
    elsif $key eq '.*' {
        $past := $( $<dottyop> );
        if $/[0] eq '.?' || $/[0] eq '.+' || $/[0] eq '.*' || $/[0] eq '.^' {
            my $name := $past.name();
            unless $name {
                $/.panic("Cannot use " ~ $/[0] ~ " when method is a code ref");
            }
            unless $name.isa(PAST::Node) {
                $name := PAST::Val.new( :value($name) );
            }
            $past.unshift($name);
            $past.name('!' ~ $/[0]);
        }
        else {
            $/.panic($/[0] ~ ' method calls not yet implemented');
        }
    }
    elsif $key eq 'VAR' {
        $past := PAST::Op.new(
            :pasttype('call'),
            :name('!VAR'),
            :node($/)
        );
    }

    make $past;
}


method dottyop($/, $key) {
    make $( $/{$key} );
}


method methodop($/, $key) {
    my $past;

    if $key eq 'null' {
        $past := PAST::Op.new();
    }
    else {
        $past := build_call( $( $/{$key} ) );
    }
    $past.pasttype('callmethod');
    $past.node($/);

    if $<name> {
        $past.name(~$<name>);
    }
    elsif $<variable> {
        $past.unshift( $( $<variable> ) );
    }
    else {
        $past.name( $( $<quote> ) );
    }

    make $past;
}

method postcircumfix($/, $key) {
    my $past;
    if $key eq '[ ]' {
        $past := PAST::Block.new( $( $<semilist> ), :blocktype('declaration') );
        $past := PAST::Op.new( $past, :name('postcircumfix:[ ]'), :node($/) );
    }
    elsif $key eq '( )' {
        $past := build_call( $( $<semilist> ) );
        $past.node($/);
    }
    elsif $key eq '{ }' {
        $past := build_call( $( $<semilist> ) );
        $past.node($/);
        $past.name('postcircumfix:{ }');
    }
    elsif $key eq '< >' {
        $past := build_call( $( $<quote_expression> ) );
        $past.node($/);
        $past.name('postcircumfix:{ }');
    }
    else {
        $/.panic("postcircumfix " ~ $key ~ " not yet implemented");
    }
    make $past;
}


method noun($/, $key) {
    my $past;
    if $key eq 'self' {
        $past := PAST::Var.new(
            :name('self'),
            :scope('lexical'),
            :node($/)
        );
    }
    elsif $key eq 'dotty' {
        # Call on $_.
        $past := $( $/{$key} );
        $past.unshift(PAST::Var.new(
            :name('$_'),
            :scope('lexical'),
            :viviself('Failure'),
            :node($/)
        ));
    }
    else {
        $past := $( $/{$key} );
    }
    make $past;
}


sub apply_package_traits($package, $traits) {
    for $traits {
        my $aux := $_<trait_auxiliary>;
        # Apply any "is" traits through MMD.
        if $aux<sym> eq 'is' {
            # Check it's not a compiler-handled one.
            if $aux<name> ne 'also' {
                # Emit the call.
                my @identifier := Perl6::Compiler.parse_name(~$aux<name>);
                my $name := @identifier.pop();
                my $superclass := PAST::Var.new(
                                      :name($name),
                                      :scope('package'),
                                      :viviself('Undef')
                                  );
                if +@identifier != 0 {
                    $superclass.namespace(@identifier);
                }
                $package.push(
                    PAST::Op.new(
                        :pasttype('call'),
                        :name('trait_auxiliary:is'),
                        $superclass,
                        PAST::Var.new(
                            :name('def'),
                            :scope('register')
                        )
                    )
                );
            }
        }
        elsif $aux<sym> eq 'does' {
            # Role.
            my @identifier := Perl6::Compiler.parse_name(~$aux<name>);
            my $name := @identifier.pop();
            my $role_name := PAST::Var.new(
                                 :name($name),
                                 :namespace(@identifier),
                                 :scope('package'),
                             );
            $package.push(
                PAST::Op.new(
                    :pasttype('call'),
                    :name('!keyword_does'),
                    PAST::Var.new(
                        :name('def'),
                        :scope('register')
                    ),
                    $role_name
                )
            );
        }
        else {
            $traits.panic("Currently only is and does traits are supported on packages.");
        }
    }
}


method package_declarator($/, $key) {
    our $?CLASS;
    our @?CLASS;
    our $?GRAMMAR;
    our @?GRAMMAR;
    our $?MODULE;
    our @?MODULE;
    our $?PACKAGE;
    our @?PACKAGE;
    our $?ROLE;
    our @?ROLE;

    my $sym := $<sym>;

    if $key eq 'open' {
        # Start of a new package. We create an empty PAST::Stmts node for the
        # package definition to be stored in and put it onto the current stack
        # of packages and the stack of its package type.
        my $decl_past := PAST::Stmts.new();

        if    $sym eq 'package' {
            @?PACKAGE.unshift($decl_past);
        }
        ##  module isa package
        elsif $sym eq 'module' {
            @?MODULE.unshift($decl_past);
            @?PACKAGE.unshift($decl_past);
        }
        ##  role isa module isa package
        elsif $sym eq 'role' {
            @?ROLE.unshift($decl_past);
            @?MODULE.unshift($decl_past);
            @?PACKAGE.unshift($decl_past);
        }
        ##  class isa module isa package
        elsif $sym eq 'class' {
            @?CLASS.unshift($decl_past);
            @?MODULE.unshift($decl_past);
            @?PACKAGE.unshift($decl_past);
        }
        ##  grammar isa class isa module isa package
        elsif $sym eq 'grammar' {
            @?GRAMMAR.unshift($decl_past);
            @?CLASS.unshift($decl_past);
            @?MODULE.unshift($decl_past);
            @?PACKAGE.unshift($decl_past);
        }
    }
    else {
        # End of declaration. Our PAST will be that made by the package_def or
        # role_def.
        my $past := $( $/{$key} );

        # Set $?PACKAGE at the start of it.
        $past.unshift(set_package_magical());

        # Restore outer values in @?<magical> arrays
        if    $sym eq 'package' {
            @?PACKAGE.shift();
        }
        ##  module isa package
        elsif $sym eq 'module' {
            @?MODULE.shift();
            @?PACKAGE.shift();
        }
        ##  role isa module isa package
        elsif $sym eq 'role' {
            @?ROLE.shift();
            @?MODULE.shift();
            @?PACKAGE.shift();
        }
        ##  class isa module isa package
        elsif $sym eq 'class' {
            @?CLASS.shift();
            @?MODULE.shift();
            @?PACKAGE.shift();
        }
        ##  grammar isa class isa module isa package
        elsif $sym eq 'grammar' {
            @?GRAMMAR.shift();
            @?CLASS.shift();
            @?MODULE.shift();
            @?PACKAGE.shift();
        }
        make $past;
    }

    # make sure @?<magical>[0] is always the same as $?<magical>
    $?CLASS   := @?CLASS[0];
    $?GRAMMAR := @?GRAMMAR[0];
    $?MODULE  := @?MODULE[0];
    $?PACKAGE := @?PACKAGE[0];
    $?ROLE    := @?ROLE[0];
}


method package_def($/, $key) {
    our $?CLASS;
    our $?GRAMMAR;
    our $?MODULE;
    our $?NS;
    our $?PACKAGE;
    my $name := $<name>;

    if $key eq 'open' {
        # Start of package definition. Handle class and grammar specially.
        if $?PACKAGE =:= $?GRAMMAR {
            # Anonymous grammars not supported.
            unless $name {
                $/.panic('Anonymous grammars not supported');
            }

            # Start of grammar definition. Create grammar class object.
            $?GRAMMAR.push(
                PAST::Op.new(
                    :pasttype('bind'),
                    PAST::Var.new(
                        :name('def'),
                        :scope('register'),
                        :isdecl(1)
                    ),
                    PAST::Op.new(
                        :pasttype('call'),
                        :name('!keyword_grammar'),
                        PAST::Val.new( :value(~$name[0]) )
                    )
                )
            );
        }
        elsif $?PACKAGE =:= $?CLASS {
            my $class_def;

            if !have_trait('also', 'is', $<trait>) {
                # Start of class definition; make PAST to create class object if
                # we're creating a new class.
                $class_def := PAST::Op.new(
                    :pasttype('bind'),
                    PAST::Var.new(
                        :name('def'),
                        :scope('register'),
                        :isdecl(1)
                    ),
                    PAST::Op.new(
                        :pasttype('call'),
                        :name('!keyword_class')
                    )
                );

                # Add a name, if we have one.
                if $name {
                    $class_def[1].push( PAST::Val.new( :value(~$name[0]) ) );
                }
            }
            else {
                # We're adding to an existing class. Look up class by name and put
                # it in $def.
                unless $<name> {
                    $/.panic("Can only use is also trait on a named class.");
                }
                my @namespace := Perl6::Compiler.parse_name($<name>[0]);
                my $short_name := @namespace.pop();
                $class_def := PAST::Op.new(
                    :node($/),
                    :pasttype('bind'),
                    PAST::Var.new(
                        :name('def'),
                        :scope('register'),
                        :isdecl(1)
                    ),
                    PAST::Op.new(
                        :pasttype('callmethod'),
                        :name('get_parrotclass'),
                        PAST::Var.new(
                            :scope('package'),
                            :name('$!P6META'),
                            :namespace('Perl6Object')
                        ),
                        PAST::Var.new(
                            :name($short_name),
                            :namespace(@namespace),
                            :scope('package')
                        )
                    )
                );
            }

            $?CLASS.push($class_def);
        }
        else {
            # Anonymous modules not supported.
            unless $name {
                $/.panic('Anonymous modules not supported');
            }
        }

        # Also store the current namespace, if we're not anonymous.
        if $name {
            $?NS := ~$name[0];
        }
    }
    else {
        # XXX For now, to work around the :load :init not being allowed to be
        # an outer bug, we will enclose the actual package block inside an
        # immediate block of its own.
        my $inner_block := $( $<package_block> );
        $inner_block.blocktype('immediate');
        my $past := PAST::Block.new(
            $inner_block
        );

        # Declare the namespace and that the result block holds things that we
        # do "on load".
        if $name {
            $past.namespace(Perl6::Compiler.parse_name($<name>[0]));
        }
        $past.blocktype('declaration');
        $past.pirflags(':init :load');

        if $?PACKAGE =:= $?GRAMMAR {
            # Apply traits.
            apply_package_traits($?GRAMMAR, $<trait>);

            # Make proto-object for grammar.
            $?GRAMMAR.push(
                PAST::Op.new(
                    :pasttype('call'),
                    :name('!PROTOINIT'),
                    PAST::Op.new(
                        :pasttype('callmethod'),
                        :name('register'),
                        PAST::Var.new(
                            :scope('package'),
                            :name('$!P6META'),
                            :namespace('Perl6Object')
                        ),
                        PAST::Var.new(
                            :scope('register'),
                            :name('def')
                        ),
                        PAST::Val.new(
                            :value('Grammar'),
                            :named( PAST::Val.new( :value('parent') ) )
                        )
                    )
                )
            );

            # Attatch grammar declaration to the init code.
            our $?BLOCK;
            $?BLOCK.loadinit().push( $?GRAMMAR );

            # Clear namespace.
            $?NS := '';
        }
        elsif $?PACKAGE =:= $?CLASS {
            # Apply traits.
            apply_package_traits($?CLASS, $<trait>);

            # Check if we have the is also trait - don't re-create
            # proto-object if so.
            if !have_trait('also', 'is', $<trait>) {
                # It's a new class definition. Make proto-object.
                $?CLASS.push(
                    PAST::Op.new(
                        :pasttype('call'),
                        :name('!PROTOINIT'),
                        PAST::Op.new(
                            :pasttype('callmethod'),
                            :name('register'),
                            PAST::Var.new(
                                :scope('package'),
                                :name('$!P6META'),
                                :namespace('Perl6Object')
                            ),
                            PAST::Var.new(
                                :scope('register'),
                                :name('def')
                            ),
                            PAST::Val.new(
                                :value('Any'),
                                :named( PAST::Val.new( :value('parent') ) )
                            )
                        )
                    )
                );

                # If this is an anonymous class, the block doesn't want to be a
                # :init :load, and it's going to contain the class definition, so
                # we need to declare the lexical $def.
                unless $name {
                    $past.pirflags('');
                    $past.blocktype('immediate');
                    $past[0].push(PAST::Var.new(
                        :name('def'),
                        :scope('register'),
                        :isdecl(1)
                    ));
                }
            }

            # Attatch any class initialization code to the init code;
            # note that we skip blocks, which are method accessors that
            # we want to put under this block so they get the correct
            # namespace. If it's an anonymous class, everything goes into
            # this block.
            for @( $?CLASS ) {
                if $_.isa(PAST::Block) || !$name {
                    $past[0].push( $_ );
                }
                else {
                    our $?BLOCK;
                    $?BLOCK.loadinit().push( $_ );
                }
            }
        }

        make $past;
    }
}


method role_def($/, $key) {
    our $?ROLE;
    our $?NS;
    my $name := ~$<name>;

    if $key eq 'open' {
        # Start of role definition. Push on code to create a role object.
        $?ROLE.push(
            PAST::Op.new(
                :pasttype('bind'),
                PAST::Var.new(
                    :name('def'),
                    :scope('register'),
                    :isdecl(1)
                ),
                PAST::Op.new(
                    :pasttype('call'),
                    :name('!keyword_role'),
                    PAST::Val.new( :value($name) )
                )
            )
        );

        # Also store the current namespace.
        $?NS := $name;
    }
    else {
        # Declare the namespace and that the result block holds things that we
        # do "on load".
        my $past := $( $<package_block> );
        $past.namespace( PAST::Compiler.parse_name($name) );
        $past.blocktype('declaration');
        $past.pirflags(':init :load');

        # Apply traits.
        apply_package_traits($?ROLE, $<trait>);

        # Attatch role declaration to the init code, skipping blocks since
        # those are accessors.
        for @( $?ROLE ) {
            if $_.isa(PAST::Block) {
                $past.push( $_ );
            }
            else {
                our $?BLOCK;
                $?BLOCK.loadinit().push( $_ );
            }
        }

        # Clear namespace.
        $?NS := '';

        make $past;
    }
}


method package_block($/, $key) {
    my $past := $( $/{$key} );
    make $past;
}



method scope_declarator($/) {
    my $sym  := ~$<sym>;
    my $past := $( $<scoped> );
    if $past.isa(PAST::Var) {
        my $scope := $sym eq 'my' ?? 'lexical' !! 'package';
        our $?BLOCK;
        my $symbol := $?BLOCK.symbol( $past.name() );
        $symbol<scope> := $scope;
        $past.viviself( $symbol<viviself> );
        if $symbol<type> {
            $past := PAST::Op.new( :pirop('setprop'), 
                                   $past, 'type', $symbol<type>[0] );
        }
    }
    make $past;
}


method scoped($/) {
    my $past;
    if $<declarator> {
        $past := $( $<declarator> );
    }
    elsif $<multi_declarator> {
        $past := $( $<multi_declarator> );
        if $past.isa(PAST::Var) {
            our $?BLOCK;
            my $symbol := $?BLOCK.symbol( $past.name() );
            my $type := $symbol<type>;
            for @($<fulltypename>) {
                $type.push( $( $_ ) );
            }
            $symbol<viviself> := PAST::Op.new( :pirop('new PsP'), 
                                     'ObjectRef', 
                                     $( $<fulltypename>[0] ) );
        }
    }
    make $past;
}


method declarator($/) {
    my $past;
    if $<variable_declarator> {
        $past := $( $<variable_declarator> );
    }
    elsif $<routine_declarator> {
        $past := $( $<routine_declarator> );
    }
    make $past;
}


method variable_declarator($/) {
    our $?BLOCK;
    my $past   := $( $<variable> );
    my $name   := $past.name();
    my $symbol := $?BLOCK.symbol( $name );
    if $symbol<scope> eq 'lexical' {
        $/.panic("Redeclaration of variable " ~ $name);
    }
    
    $past.isdecl(1);
    my $type     := List.new();
    my $viviself := container_type($<variable><sigil>);
    $?BLOCK.symbol($name, :type($type), :viviself($viviself) );
    make $past;
}

method variable($/, $key) {
    my $past;
    our $?BLOCK;
    if $key eq 'desigilname' {
        my $sigil      := ~$<sigil>;
        my $twigil     := ~$<twigil>[0];
        my @identifier := Perl6::Compiler.parse_name( $<desigilname> );
        my $name       := ~@identifier.pop();
        my $varname    := $sigil ~ $name;
        $past := PAST::Var.new( :name($varname), :node($/) );

        ##  if twigil is ^ or :, it's a placeholder var
        if $twigil eq '^' || $twigil eq ':' {
            if $?BLOCK.symbol('!signature') {
                $/.panic("Cannot use placeholder var in block with signature.");
            }
            unless $?BLOCK.symbol($varname) {
                $?BLOCK.symbol( $varname, :scope('lexical') );
                $?BLOCK.arity( +$?BLOCK.arity() + 1 );
                my $var := PAST::Var.new(:name($varname), :scope('parameter'));
                if $twigil eq ':' { $var.named( $name ); }
                my $block := $?BLOCK[0];
                my $i := +@($block);
                while $i > 0 && $block[$i-1]<name> gt $varname {
                    $block[$i] := $block[$i-1];
                    $i--;
                }
                $block[$i] := $var;
            }
        }

        ##  if namespace qualified or has a '*' twigil, it's a package var
        if @identifier || $twigil eq '*' {
            $past.namespace(@identifier);
            $past.scope('package');
            $past.viviself( container_type($sigil) );
        }
    }
    elsif $key eq 'special_variable' {
        $past := $( $<special_variable> );
    }
    make $past;
}


method special_variable($/) {
    make PAST::Var.new( :node($/), :name(~$/), :scope('lexical') );
}


method circumfix($/, $key) {
    my $past;
    if $key eq '( )' {
        $past := $<statementlist><statement>
                     ?? $( $<statementlist> )
                     !! PAST::Op.new(:name('list'));
    }
    if $key eq '[ ]' {
        $past := PAST::Op.new(:name('circumfix:[ ]'), :node($/) );
        if $<statementlist><statement> { $past.push( $( $<statementlist> ) ); }
    }
    elsif $key eq '{ }' {
        # If it is completely empty or consists of a single list, the first
        # element of which is either a hash or a pair, it's a hash constructor.
        $past := $( $<pblock> );
        my $is_hash := 0;
        if +@($past) == 2 && +@($past[0]) == 0 {
            if +@($past[1]) == 0 {
                # Empty block, so a hash.
                $is_hash := 1;
            }
            elsif +@($past[1]) == 1 && $past[1][0].isa(PAST::Op) {
                if $past[1][0].name() eq 'infix:=>' {
                    # Block with just one pair in it, so a hash.
                    $is_hash := 1;
                }
                elsif $past[1][0].name() eq 'infix:,' {
                    # List, but first elements must be...
                    if $past[1][0][0].isa(PAST::Op) &&
                            $past[1][0][0].name() eq 'infix:=>' {
                        # ...a Pair
                        $is_hash := 1;
                    }
                    elsif $past[1][0][0].isa(PAST::Var) &&
                            substr($past[1][0][0].name(), 0, 1) eq '%' {
                        # ...or a hash.
                        $is_hash := 1
                    }
                }
            }
        }
        if $is_hash {
            my @children := @($past[1]);
            $past := PAST::Op.new(
                :pasttype('call'),
                :name('circumfix:{ }'),
                :node($/)
            );
            for @children {
                $past.push($_);
            }
        }
        else {
            declare_implicit_function_vars($past);
        }
    }
    elsif $key eq '$( )' {
        my $method := contextualizer_name($/, $<sigil>);
        my $call_on := $( $<semilist> );
        if $call_on.name() eq 'infix:,' && +@($call_on) == 0 {
            $call_on := PAST::Var.new(
                :name('$/'),
                :scope('lexical')
            );
        }
        $past := PAST::Op.new(
            :pasttype('callmethod'),
            :name($method),
            :node($/),
            $call_on
        );
    }
    make $past;
}


method value($/, $key) {
    make $( $/{$key} );
}


method typename($/) {
    # Extract shortname part of identifier, if there is one.
    my $ns := Perl6::Compiler.parse_name($<name>);
    my $shortname := $ns.pop();

    # determine type's scope
    my $scope := '';
    our @?BLOCK;
    if +$ns == 0 && @?BLOCK {
        for @?BLOCK {
            if defined($_) && !$scope {
                my $sym := $_.symbol($shortname);
                if defined($sym) && $sym<scope> { $scope := $sym<scope>; }
            }
        }
    }

    # Create default PAST node for package lookup of type.
    my $past := PAST::Var.new(
        :name($shortname),
        :namespace($ns),
        :node($/),
        :scope($scope || 'package'),
    );

    make $past;
}


method fulltypename($/) {
    make $( $<typename> );
}


method number($/, $key) {
    make $( $/{$key} );
}


##  for a variety of reasons, this is easier in PIR than NQP for now.
##  NQP doesn't have assign yet, and Str is lighter-weight than Str.
method integer($/) {
    my $str;
    PIR q<  $P0 = find_lex '$/'   >;
    PIR q<  $S0 = $P0             >;
    PIR q<  $P1 = new 'Str'  >;
    PIR q<  assign $P1, $S0       >;
    PIR q<  store_lex '$str', $P1 >;
    make PAST::Val.new(
        :value( +$str ),
        :returns('Int'),
        :node( $/ )
    );
}


method dec_number($/) {
    my $str;
    PIR q<  $P0 = find_lex '$/'   >;
    PIR q<  $S0 = $P0             >;
    PIR q<  $P1 = new 'Str'  >;
    PIR q<  assign $P1, $S0       >;
    PIR q<  store_lex '$str', $P1 >;
    make PAST::Val.new(
        :value( +$str ),
        :returns('Num'),
        :node( $/ )
    );
}

method radint($/, $key) {
    make $( $/{$key} );
}

method rad_number($/) {
    my $radix    := ~$<radix>;
    my $intpart  := ~$<intpart>;
    my $fracpart := ~$<fracpart>;
    my $base;
    my $exp;
    if defined( $<base>[0] ) { $base := $<base>[0].text(); }
    if defined( $<exp>[0] ) { $exp := $<exp>[0].text(); }
    if ~$<postcircumfix> {
        my $radcalc := $( $<postcircumfix> );
        $radcalc.name('radcalc');
        $radcalc.pasttype('call');
        $radcalc.unshift( PAST::Val.new( :value( $radix ), :node( $/ ) ) );
        make $radcalc;
    }
    else{
        my $return_type := 'Int';
        if $fracpart { $return_type := 'Num'; }
        make PAST::Val.new(
            :value( radcalc( $radix, $intpart, $fracpart, ~$base, ~$exp ) ),
            :returns($return_type),
            :node( $/ )
        );
    }
}


method quote($/) {
    make $( $<quote_expression> );
}

method quote_expression($/, $key) {
    my $past;
    if $key eq 'quote_concat' {
        if +$<quote_concat> == 1 {
            $past := $( $<quote_concat>[0] );
        }
        else {
            $past := PAST::Op.new(
                :name('list'),
                :pasttype('call'),
                :node( $/ )
            );
            for $<quote_concat> {
                $past.push( $($_) );
            }
        }
    }
    elsif $key eq 'quote_regex' {
        our $?NS;
        $past := PAST::Block.new(
            $<quote_regex>,
            :compiler('PGE::Perl6Regex'),
            :namespace(Perl6::Compiler.parse_name( $?NS )),
            :blocktype('declaration'),
            :node( $/ )
        );
    }
    elsif $key eq 'quote_pir' {
        $past := PAST::Op.new( :inline( $<quote_pir> ), :node($/) );
    }
    make $past;
}


method quote_concat($/) {
    my $quote_term := $<quote_term>;
    my $terms := +$quote_term;
    my $count := 1;
    my $past := $( $quote_term[0] );
    while ($count != $terms) {
        $past := PAST::Op.new(
            $past,
            $( $quote_term[$count] ),
            :pirop('concat'),
            :pasttype('pirop')
        );
        $count := $count + 1;
    }
    make $past;
}


method quote_term($/, $key) {
    my $past;
    if ($key eq 'literal') {
        $past := PAST::Val.new(
            :value( ~$<quote_literal> ),
            :returns('Str'), :node($/)
        );
    }
    elsif ($key eq 'variable') {
        $past := PAST::Op.new( $( $<variable> ), :name('prefix:~'), :pasttype('call') );
    }
    elsif ($key eq 'circumfix') {
        $past := $( $<circumfix> );
        if $past.isa(PAST::Block) {
            $past.blocktype('immediate');
        }
        $past := PAST::Op.new( $past, :name('prefix:~'), :pasttype('call') );
    }
    make $past;
}


method term($/, $key) {
    my $past;
    if $key eq 'noarg' {
        $past := PAST::Op.new( :name( ~$<name> ), :pasttype('call') );
    }
    elsif $key eq 'args' {
        $past := $($<args>);
        $past.name( ~$<name> );
    }
    elsif $key eq 'func args' {
        $past := build_call( $( $<semilist> ) );
        $past.name( ~$<name> );
    }
    elsif $key eq 'VAR' {
        $past := PAST::Op.new(
            :name('!VAR'),
            :pasttype('call'),
            $( $<variable> )
        );
    }
    elsif $key eq 'sigil' {
        my $method := contextualizer_name($/, $<sigil>);

        $past := PAST::Op.new(
            :pasttype('callmethod'),
            :name($method),
            :node($/),
            $( $<arglist> )
        );
    }
    else { $past := $( $/{$key} ); }
    $past.node($/);
    make $past;
}


method args($/, $key) {
    my $past := build_call( $key eq 'func args'
        ?? $($<semilist>)
        !! $($<arglist>)
    );
    make $past;
}


method semilist($/) {
    my $past := $<EXPR>
        ?? $( $<EXPR>[0] )
        !! PAST::Op.new( :node($/), :name('infix:,') );
    make $past;
}


method arglist($/) {
    my $past := $<EXPR>
        ?? $( $<EXPR> )
        !! PAST::Op.new( :node($/), :name('infix:,') );
    make $past;
}


method EXPR($/, $key) {
    my $type := ~$<type>;

    if $key eq 'end' {
        make $($<expr>);
    }
    elsif ~$type eq 'infix:=' {
        my $lhs := $( $/[0] );
        my $rhs := $( $/[1] );
        my $past;

        # Is it an assignment to an attribute?
        if $lhs.isa(PAST::Var) && $lhs.scope() eq 'attribute' && $lhs.isdecl() {
            # Add this to the WHENCE clause.
            # XXX Need to make it a closure, but will need :subid to get
            # scoping right.
            our $?CLASS;
            $?CLASS.push(
                PAST::Op.new(
                    :pasttype('call'),
                    :name('!ADD_TO_WHENCE'),
                    PAST::Var.new(
                        :name('def'),
                        :scope('register')
                    ),
                    $lhs.name(),
                    $rhs
                )
            );

            # Nothing to emit at this point.
            $past := PAST::Stmts.new();
        }
        else {
            # Just a normal assignment.
            $past := PAST::Op.new(
                :pasttype('call'),
                :name('infix:='),
                :lvalue(1),
                $lhs,
                $rhs
            );
        }

        make $past;
    }
    elsif ~$type eq 'infix:.=' {
        my $invocant  := $( $/[0] );
        my $call      := $( $/[1] );

        # Check that we have a sub call.
        if !$call.isa(PAST::Op) || $call.pasttype() ne 'call' {
            $/[0].panic('.= must have a call on the right hand side');
        }

        # Change call node to a callmethod.
        $call.pasttype('callmethod');

        # We only want to evaluate invocant once; stash it in a register.
        $call.unshift(PAST::Op.new(
            :pasttype('bind'),
            PAST::Var.new(
                :name('detemp'),
                :scope('register'),
                :isdecl(1)
            ),
            $invocant
        ));

        # Do call, then assignment to target container.
        my $past := PAST::Op.new(
            :inline("    %r = 'infix:='(%1, %0)"),
            :node($/),
            $call,
            PAST::Var.new(
                :name('detemp'),
                :scope('register')
            )
        );

        make $past;
    }
    elsif ~$type eq 'infix:does' || ~$type eq 'infix:but' {
        my $past := PAST::Op.new(
            $( $/[0] ),
            :pasttype('call'),
            :name(~$type),
            :node($/)
        );
        my $rhs := $( $/[1] );
        if $rhs.isa(PAST::Op) && $rhs.pasttype() eq 'call' {
            # Make sure we only have one initialization value.
            if +@($rhs) > 2 {
                $/[0].panic("Role initialization can only supply a value for one attribute");
            }
            # Push role name and argument onto infix:does or infix:but.
            $past.push($rhs[0]);
            $past.push($rhs[1]);
        }
        else {
            $past.push($rhs);
        }
        make $past;
    }
    elsif ~$type eq 'prefix:|' {
        # Need to make it flatten the argument.
        my $past := $( $/[0] );
        $past.flat(1);
        make $past;
    }
    else {
        my $past := PAST::Op.new(
            :node($/),
            :name($type),
            :opattr($<top>)
        );
        if $<top><subname> { $past.name(~$<top><subname>); }
        for @($/) {
            unless +$_.from() == +$_.to() { $past.push( $($_) ) };
        }

        make $past;
    }
}


method regex_declarator($/, $key) {
    make $( $/{$key} );
}


method regex_declarator_regex($/) {
    my $past := $( $<quote_expression> );
    $past.name( ~$<identifier>[0] );
    make $past;
}


method regex_declarator_token($/) {
    my $past := $( $<quote_expression> );
    $past.compiler_args( :ratchet(1) );
    $past.name( ~$<identifier>[0] );
    make $past;
}


method regex_declarator_rule($/) {
    my $past := $( $<quote_expression> );
    $past.compiler_args( :s(1), :ratchet(1) );
    $past.name( ~$<identifier>[0] );
    make $past;
}


method type_declarator($/) {
    # We need a block containing the constraint condition.
    my $past := $( $<EXPR> );
    if (!$past.isa(PAST::Block) || $past.compiler() eq 'PGE::Perl6Regex') {
        # Make block with a smart match of the the expression as its contents.
        $past := PAST::Block.new(
            PAST::Stmts.new(
                PAST::Var.new(
                    :scope('parameter'),
                    :name('$_')
                )
            ),
            PAST::Stmts.new(
                PAST::Op.new(
                    :pasttype('callmethod'),
                    :name('ACCEPTS'),
                    $past,
                    PAST::Var.new(
                        :scope('lexical'),
                        :name('$_')
                    )
                )
            )
        );
    }

    # Make sure it has a parameter and keep hold of it if found.
    my $param;
    my $dollar_underscore;
    for @($past[0]) {
        if $_.isa(PAST::Var) {
            if $_.scope() eq 'parameter' {
                $param := $_;
            }
            elsif $_.name() eq '$_' {
                $dollar_underscore := $_;
            }
        }
    }
    unless $param {
        if $dollar_underscore {
            $dollar_underscore.scope('parameter');
            $param := $dollar_underscore;
        }
        else {
            $param := PAST::Var.new(
                :name('$_'),
                :scope('parameter')
            );
            $past[0].push($param);
        }
    }

    # Create subset type.
    my @name := Perl6::Compiler.parse_name($<name>);
    $past := PAST::Op.new(
        :node($/),
        :pasttype('bind'),
        PAST::Var.new(
            :name(@name.pop()),
            :namespace(@name),
            :scope('package')
        ),
        PAST::Op.new(
            :pasttype('call'),
            :name('!CREATE_SUBSET_TYPE'),
            $<typename> ??
                $( $<typename>[0] )
                !!
                PAST::Var.new(
                    :name('Any'),
                    :scope('package')
                ),
            $past
        )
    );

    # Put this code in loadinit, so the type is created early enough,
    # then this node results in an empty statement node.
    our $?BLOCK;
    $?BLOCK.loadinit().push($past);

    make PAST::Stmts.new();
}


method fatarrow($/) {
    my $past := PAST::Op.new(
        :node($/),
        :pasttype('call'),
        :name('infix:=>'),
        :returns('Pair'),
        PAST::Val.new( :value(~$<key>) ),
        $( $<val> )
    );
    make $past;
}


method colonpair($/, $key) {
    my $pair_key;
    my $pair_val;

    if $key eq 'false' {
        $pair_key := PAST::Val.new( :value(~$<identifier>) );
        $pair_val := PAST::Val.new( :value(0), :returns('Int') );
    }
    elsif $key eq 'value' {
        $pair_key := PAST::Val.new( :value(~$<identifier>) );
        if $<postcircumfix> {
            $pair_val := $( $<postcircumfix>[0] );
            if $pair_val.name() ne 'infix:,' || +@($pair_val) == 1 {
                $pair_val := $pair_val[0];
            }
        }
        else {
            $pair_val := PAST::Val.new( :value(1), :returns('Int') );
        }
    }
    elsif $key eq 'varname' {
        if $<desigilname><name> {
            $pair_key := PAST::Val.new( :value( ~$<desigilname> ) );
            $pair_val := PAST::Var.new(
                :name( ~$<sigil> ~ ~$<twigil> ~ ~$<desigilname> )
            );
        }
        else {
            $/.panic('complex varname colonpair case not yet implemented');
        }
    }
    else {
        $/.panic($key ~ " pairs not yet implemented.");
    }

    my $past := PAST::Op.new(
        :node($/),
        :pasttype('call'),
        :name('infix:=>'),
        :returns('Pair'),
        $pair_key,
        $pair_val
    );
    make $past;
}


method capterm($/) {
    # We will create the capture object, passing the things supplied.
    my $past := build_call( $( $<capture> ) );
    $past.name('prefix:\\');
    make $past;
}


method capture($/) {
    make $( $<EXPR> );
}


method sigterm($/) {
    my $past := $( $/<signature> );
    make $past;
}


# Used by all calling code to process arguments into the correct form.
sub build_call($args) {
    if !$args.isa(PAST::Op) || $args.name() ne 'infix:,' {
        $args := PAST::Op.new( :node($args), :name('infix:,'), $args);
    }
    my $i := 0;
    my $elems := +@($args);
    while $i < $elems {
        my $x := $args[$i];
        if $x.returns() eq 'Pair' {
            $x[1].named($x[0]);
            $args[$i] := $x[1];
        }
        $i++;
    }
    $args.pasttype('call');
    $args;
}


sub declare_implicit_routine_vars($block) {
    for ('$_', '$/', '$!') {
        unless $block.symbol($_) {
            $block[0].push( PAST::Var.new( :name($_),
                                           :scope('lexical'),
                                           :isdecl(1),
                                           :viviself('Failure') ) );
            $block.symbol($_, :scope('lexical') );
        }
    }
}


sub declare_implicit_block_vars($block, $tparam) {
    $block[0].push( PAST::Op.new(
                        :inline('    .local pmc outerlex',
                                '    getinterp $P0',
                                '    set outerlex, $P0["outer";"lexpad";1]')));
    for ('$_', '$/', '$!') {
        unless $block.symbol($_) {
            my $lex := PAST::Op.new(:inline('    set %r, outerlex["'~$_~'"]'));
            my $scope := ($tparam && $_ eq '$_') ?? 'parameter' !! 'lexical';
            $block[0].push(
                PAST::Var.new( :name($_),
                               :scope($scope),
                               :isdecl(1),
                               :viviself($lex)
                )
            );
            $block.symbol($_, :scope('lexical') );
        }
    }
}

sub declare_implicit_function_vars($block) {
    declare_implicit_block_vars($block, !defined($block.arity()));
}

sub contextualizer_name($/, $sigil) {
    ##  Contextualizing is calling .item, .list, .hash, etc.
    ##  on the expression in the brackets
    my $method;
    if    $sigil eq '$' { $method := 'item'; }
    elsif $sigil eq '@' { $method := 'list'; }
    elsif $sigil eq '%' { $method := 'hash'; }
    else {
        $/.panic("Use of contextualizer " ~ $sigil ~ " not implemented.");
    }
    $method
}


sub container_type($sigil) {
    if    $sigil eq '@' { return 'Perl6Array'  }
    elsif $sigil eq '%' { return 'Perl6Hash'   }
    else                { return 'Perl6Scalar' }
}


# Processes a handles expression to produce the appropriate method(s).
sub process_handles($/, $expr, $attr_name) {
    my $past := PAST::Stmts.new();

    # What type of expression do we have?
    if $expr.isa(PAST::Val) && $expr.returns() eq 'Str' {
        # Just a single string mapping.
        my $name := ~$expr.value();
        my $method := make_handles_method($/, $name, $name, $attr_name);
        $past.push(add_method_to_class($method));
    }
    elsif $expr.isa(PAST::Op) && $expr.returns() eq 'Pair' {
        # Single pair.
        my $method := make_handles_method_from_pair($/, $expr, $attr_name);
        $past.push(add_method_to_class($method));
    }
    elsif $expr.isa(PAST::Op) && $expr.pasttype() eq 'call' &&
          $expr.name() eq 'list' {
        # List of something, but what is it?
        for @($expr) {
            if $_.isa(PAST::Val) && $_.returns() eq 'Str' {
                # String value.
                my $name := ~$_.value();
                my $method := make_handles_method($/, $name, $name, $attr_name);
                $past.push(add_method_to_class($method));
            }
            elsif $_.isa(PAST::Op) && $_.returns() eq 'Pair' {
                # Pair.
                my $method := make_handles_method_from_pair($/, $_, $attr_name);
                $past.push(add_method_to_class($method));
            }
            else {
                $/.panic(
                    'Only a list of constants or pairs can be used in handles'
                );
            }
        }
    }
    elsif $expr.isa(PAST::Stmts) && $expr[0].name() eq 'infix:,' {
        # Also a list, but constructed differently.
        for @($expr[0]) {
            if $_.isa(PAST::Val) && $_.returns() eq 'Str' {
                # String value.
                my $name := ~$_.value();
                my $method := make_handles_method($/, $name, $name, $attr_name);
                $past.push(add_method_to_class($method));
            }
            elsif $_.isa(PAST::Op) && $_.returns() eq 'Pair' {
                # Pair.
                my $method := make_handles_method_from_pair($/, $_, $attr_name);
                $past.push(add_method_to_class($method));
            }
            else {
                $/.panic(
                    'Only a list of constants or pairs can be used in handles'
                );
            }
        }
    }
    else {
        $/.panic('Illegal or unimplemented use of handles');
    }

    $past
}


# Produces a handles method.
sub make_handles_method($/, $from_name, $to_name, $attr_name) {
    PAST::Block.new(
        :name($from_name),
        :pirflags(':method'),
        :blocktype('declaration'),
        :node($/),
        PAST::Var.new(
            :name('@a'),
            :scope('parameter'),
            :slurpy(1)
        ),
        PAST::Var.new(
            :name('%h'),
            :scope('parameter'),
            :named(1),
            :slurpy(1)
        ),
        PAST::Op.new(
            :name($to_name),
            :pasttype('callmethod'),
            PAST::Var.new(
                :name($attr_name),
                :scope('attribute')
            ),
            PAST::Var.new(
                :name('@a'),
                :scope('lexical'),
                :flat(1)
            ),
            PAST::Var.new(
                :name('%h'),
                :scope('lexical'),
                :flat(1),
                :named(1)
            )
        )
    )
}


# Makes a handles method from a pair.
sub make_handles_method_from_pair($/, $pair, $attr_name) {
    my $meth;

    # Single pair mapping. Check we have string name and value.
    my $key := $pair[0];
    my $value := $pair[1];
    if $key.isa((PAST::Val) && $value.isa(PAST::Val)) {
        my $from_name := ~$key.value();
        my $to_name := ~$value.value();
        $meth := make_handles_method($/, $from_name, $to_name, $attr_name);
    }
    else {
        $/.panic('Only constants may be used in a handles pair argument.');
    }

    $meth
}


# Generates a setter/getter method for an attribute in a class or role.
sub make_accessor($/, $method_name, $attr_name, $rw, $scope) {
    my $getset;
    if $rw {
        $getset := PAST::Var.new( :name($attr_name), :scope($scope) );
    }
    else {
        $getset := PAST::Op.new(
            :inline(
                '    %r = new "Perl6Scalar", %0',
                '    $P0 = get_hll_global [ "Bool" ], "True"',
                '    setprop %r, "readonly", $P0'
            ),
            PAST::Var.new( :name($attr_name), :scope($scope) )
        );
    }
    my $accessor := PAST::Block.new(
        PAST::Stmts.new($getset),
        :blocktype('declaration'),
        :name($method_name),
        :pirflags(':method'),
        :node( $/ )
    );
    $accessor
}


# Adds the given method to the current class. This just returns the method that
# is passed to it if the current class is named and the original declaration; in
# the case that it is anonymous or we're adding to it we need instead to emit an
# add_method call and remove the methods name so it doesn't pollute the namespace.
sub add_method_to_class($method) {
    our $?CLASS;
    our $?PACKAGE;
    if !($?CLASS =:= $?PACKAGE) || $?CLASS[0][1].name() eq '!keyword_class' && +@($?CLASS[0][1]) == 1 {
        $method
    }
    else {
        # Create new PAST::Block - can't work out how to unset the name of an
        # existing one.
        my $new_method := PAST::Block.new(
            :blocktype($method.blocktype()),
            :pirflags($method.pirflags())
        );
        for @($method) {
            $new_method.push($_);
        }

        # Put call to add method into the class definition.
        $?CLASS.push(PAST::Op.new(
            :pasttype('callmethod'),
            :name('add_method'),
            PAST::Var.new(
                :name('def'),
                :scope('register')
            ),
            PAST::Val.new( :value($method.name()) ),
            $new_method
        ));

        $new_method
    }
}

# Creates an anonymous subset type.
sub make_anon_subset($past, $parameter) {
    # We need a block containing the constraint condition.
    if !$past.isa(PAST::Block) {
        # Make block with the expression as its contents.
        $past := PAST::Block.new(
            PAST::Stmts.new(),
            PAST::Stmts.new( $past )
        );
    }

    # Make sure it has a parameter.
    my $param;
    my $dollar_underscore;
    for @($past[0]) {
        if $_.isa(PAST::Var) {
            if $_.scope() eq 'parameter' {
                $param := $_;
            }
            elsif $_.name() eq '$_' {
                $dollar_underscore := $_;
            }
        }
    }
    unless $param {
        if $dollar_underscore {
            $dollar_underscore.scope('parameter');
            $param := $dollar_underscore;
        }
        else {
            $param := PAST::Var.new(
                :name('$_'),
                :scope('parameter')
            );
            $past[0].push($param);
        }
    }

    # Now we'll just pass this block to the type checker,
    # since smart-matching a block invokes it.
    return PAST::Op.new(
        :pasttype('call'),
        :name('!TYPECHECKPARAM'),
        PAST::Op.new(
            :pirop('newclosure'),
            $past
        ),
        PAST::Var.new(
            :name($parameter.name()),
            :scope('lexical')
        )
    );
}


# Takes a parse tree of traits and checks if we have the trait of the given
# name applied with the given verb. If it finds the trait, returns the
# syntax tree for that trait; otherwise, returns undef.
sub have_trait($name, $verb, $traits) {
    unless $traits { return 0; }
    for @($traits) {
        if $_ && $_<trait_auxiliary> {
            my $trait := $_<trait_auxiliary>;
            if $trait<sym> eq $verb && $trait<name> eq $name {
                return $trait;
            }
        }
    }
    return 0;
}


# Returns the code to set $?PACKAGE to the current package.
sub set_package_magical() {
    return PAST::Var.new(
            :name('$?PACKAGE'),
            :scope('lexical'),
            :isdecl(1),
            :viviself(PAST::Op.new(:pirop('get_namespace P')))
    );
}


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
