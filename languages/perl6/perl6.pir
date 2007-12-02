=head1 TITLE

perl6.pir - A Perl 6 compiler.

=head2 Description

This is the base file for the Perl 6 compiler.

This file includes the parsing and grammar rules from
the src/ directory, loads the relevant PGE libraries,
and registers the compiler under the name 'Perl6'.

=head2 Functions

=over 4

=item __onload()

Creates the Perl6 compiler using a C<PCT::HLLCompiler>
object.

=cut

.namespace [ 'Perl6::Compiler' ]

.loadlib 'perl6_group'

.sub '__onload' :load :init
    load_bytecode 'PCT.pbc'

    $P0 = get_hll_global ['PCT'], 'HLLCompiler'
    $P1 = $P0.'new'()
    $P1.'language'('Perl6')
    $P1.'parsegrammar'('Perl6::Grammar')
    $P2 = split '::', 'Perl6::Grammar::Actions'
    $P1.'parseactions'($P2)
.end


=item main(args :slurpy)  :main

Start compilation by passing any command line C<args>
to the Perl6 compiler.

=cut

.sub 'main' :main
    .param pmc args

    $P0 = compreg 'Perl6'
    $P1 = $P0.'command_line'(args)
.end

.include 'src/gen_grammar.pir'

.include 'src/gen_actions.pir'

.include 'src/gen_builtins.pir'

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
