# $Id$
# Copyright (C) 2009, Parrot Foundation.

=head1 Generic PMC emitter

=cut

.namespace ['PMC';'Emitter';'PMC']

.sub '' :load :init
    .local pmc p6meta

    p6meta = new 'P6metaclass'

    p6meta.'new_class'('PMC::Emitter::PMC')

.end

=item C<generate_h_file>

Generate part of header file.

=cut

# "Template Method". Just override generate_h_file_functions in derived
# classes.

.sub 'generate_h_file' :method
    .param pmc past
    .local string res

    .local string guard
    .local string name

    name = past.'name'()
    $S0 = 'uc'(name)

    guard = 'PARROT_PMC_'
    concat guard, $S0
    concat guard, '_H_GUARD'

    res = '#ifndef '
    concat res, guard
    concat res, "\n"
    concat res, '#define '
    concat res, guard
    concat res, "\n"

    $S0 = self.'generate_h_file_functions'(past)
    concat res, $S0
    
    concat res, '#endif /* '
    concat res, guard
    concat res, " */ \n"

    .return (res)
.end

=item C<generate_h_file_functions>

Generate C declarations for vtable functions

=cut

.sub 'generate_h_file_functions' :method
    .param pmc past
    .local string res
    .local pmc vtable_info, vtable_hash
    .local pmc vtables, it, entry, class_init
    .local string pmc_name, vtable_name

    .local pmc res_builder

    pmc_name = past.'name'()

    $P0 = get_hll_global ['PMC'; 'VTableInfo'], 'vtable_hash'
    vtable_hash = $P0()
    
    concat res, "void Parrot_"
    concat res, pmc_name
    concat res, "_class_init(PARROT_INTERP, int, int);\n" 

    vtables = self.'!vtables'(past)

    it = iter vtables
  loop:
    unless it goto done
    res_builder = new 'ResizableStringArray'
    vtable_name = shift it
    entry = vtables[vtable_name]
    vtable_info = vtable_hash[vtable_name]

    # Generate 2 methods. One for read, one for write.
    $S0 = self.'!generate_signature'(pmc_name, entry, 0 :named('ro'))
    push res_builder, $S0
    push res_builder, ";\n"

    $S0 = join '', res_builder
    concat res, $S0

    goto loop

  done:
    .return (res)
.end

=item C<generate_c_file>

Generate C file for PMC.

=cut

.sub 'generate_c_file' :method
    .param pmc past
    .local string res

    .local string guard
    .local string name

    $S0 = self.'generate_c_file_functions'(past)
    concat res, $S0
    
    $S0 = self.'!generate_class_init'(past)
    concat res, $S0
    
    .return (res)
.end

=item C<generate_c_file_functions>

Generate C declarations for vtable functions

=cut

.sub 'generate_c_file_functions' :method
    .param pmc past
    .local string res
    .local pmc vtable_info, vtable_hash
    .local pmc vtables, it, entry, class_init
    .local string pmc_name, vtable_name

    .local pmc res_builder

    pmc_name = past.'name'()

    $P0 = get_hll_global ['PMC'; 'VTableInfo'], 'vtable_hash'
    vtable_hash = $P0()
    
    vtables = self.'!vtables'(past)

    it = iter vtables
  loop:
    unless it goto done
    res_builder = new 'ResizableStringArray'
    vtable_name = shift it
    entry = vtables[vtable_name]
    vtable_info = vtable_hash[vtable_name]

    # Generate 2 methods. One for read, one for write.
    $S0 = self.'!generate_signature'(pmc_name, entry, 0 :named('ro'))
    push res_builder, $S0
    $P0 = new ['PMC';'Emitter';'C']
    $S0 = $P0.'emit'(entry)
    push res_builder, $S0

    $S0 = join '', res_builder
    concat res, $S0

    goto loop

  done:
    .return (res)
.end


=item C<!generate_signature>

Generate full signature of vtable.

=cut

.sub '!generate_signature' :method
    .param string pmc_name
    .param pmc    entry
    .param int    ro       :named('ro')
    
    .local pmc res
    .local string vtable_name
    vtable_name = entry.'name'()

    res = new 'ResizableStringArray'
    push res, 'PARROT_EXPORT '
    $S0 = entry.'returns'()
    push res, $S0
    push res, ' Parrot_'
    push res, pmc_name
    push res, '_'
    push res, vtable_name
    push res, '(PARROT_INTERP'

    .local pmc it
    $P1 = entry['parameters']
    it = $P1.'iterator'()
  param_loop:
    unless it goto param_done
    $P2 = shift it

    push res, ', '
    $S0 = $P2.'returns'()
    push res, $S0
    $S0 = $P2.'name'()
    push res, $S0

    goto param_loop
  param_done:

    push res, ")"
    $S0 = join '', res
    .return ($S0)
.end


=item C<!generate_class_init>

Generating class_init function

=cut

.sub '!generate_class_init' :method
    .param pmc past
    
    .local string pmc_name
    pmc_name = past.'name'()

    .local pmc res

    res = new 'ResizableStringArray'
    push res, 'PARROT_EXPORT void '
    push res, ' Parrot_'
    push res, pmc_name
    push res, '_class_init'
    push res, '(PARROT_INTERP, int entry, int pass) '

    push res, "\n{\n"

    # Put generating of vtables here.

    $P0 = past['class_init']
    $I0 = defined $P0
    unless $I0 goto no_init

    push res, "/* class_init */\n"
    $P1 = new ['PMC';'Emitter';'C']
    $S0 = $P1.'emit'($P0)
    push res, $S0
  no_init:

    push res, "\n}\n"
    

    $S0 = join '', res
    .return ($S0)
.end


.sub '!class_init' :method
    .param pmc past
    .tailcall past.'class_init'()
.end

.sub '!vtables' :method
    .param pmc past
    .tailcall past.'vtables'()
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
