package Parrot::Pmc2c::PMC::Object;
use base 'Parrot::Pmc2c::PMC';
use strict;
use warnings;

=head1 C<body($method, $line, $out_name)>

Returns the C code for the method body.

Overrides the default implementation to direct all unknown methods to
first check if there is an implementation of the vtable method in the
vtable methods hash of this class of any others, and delegates up to
any PMCs in the MRO.

=cut

sub pre_method_gen {
    my ( $self ) = @_;
    
    # vtable methods
    foreach my $method ( @{ $self->vtable->methods } ) {
        my $vt_method_name = $method->name;
        next unless $self->normal_unimplemented_vtable($vt_method_name);
        my $new_default_method = $method->clone({ 
                parent_name => $self->name, 
                type        => Parrot::Pmc2c::Method::VTABLE,
          });

      my ( $func_ret, $ret_suffix, $args, $sig ) = $new_default_method->signature;

      # Do we have a return value?
      my $method_return_type = $method->return_type;
      my $return = $method_return_type =~ /void/ ? '' : 'return ';
      my $void_return = $method_return_type =~ /void/ ? 'return;' : '';

      # work out what the null return should be so that we can quieten the "no
      # return from non-void function" warnings.
      # unfortunately, the general case:
      #my $null_return = "($method->{type})NULL";
      # doesn't work with gcc (it builds and tests without even a warning with
      # icc), so we add a workaround for the null return from a FLOATVAL
      # function
      my $null_return;
      if ($method_return_type eq 'void') {
          $null_return = '';
      }
      elsif ($method_return_type =~ /PMC|INTVAL|STRING|opcode_t/) {
          $null_return = "return ($method_return_type)NULL;";
      }
      # workaround for gcc because the general case doesn't work there
      elsif ($method_return_type =~ /FLOATVAL/) {
          $null_return = 'return (FLOATVAL) 0;';
      }
      else {
          $null_return = '';
      }

        $new_default_method->body(Parrot::Pmc2c::Emitter->text(<<"EOC"));
    Parrot_Object * const obj = PARROT_OBJECT(pmc);
    Parrot_Class * const _class = PARROT_CLASS(obj->_class);

    /* Walk and search for the vtable method. */
    const int num_classes = VTABLE_elements(interp, _class->all_parents);
    const int all_in_universe = !PObj_HasAlienParents_TEST(obj->_class);
    const int alien_parents_pos = VTABLE_elements(interp, _class->attrib_metadata);
    int i;
    for (i = 0; i < num_classes; i++) {
        /* Get the class. */
        PMC * const cur_class = VTABLE_get_pmc_keyed_int(interp, _class->all_parents, i);

        /* If it's from this universe or the class doesn't inherit from
         * anything outside of it... */
        if (all_in_universe || VTABLE_isa(interp, cur_class, string_from_literal(interp, "Class"))) {
            const Parrot_Class * const class_info = PARROT_CLASS(cur_class);
            if (VTABLE_exists_keyed_str(interp, class_info->vtable_methods, string_from_literal(interp, "$vt_method_name"))) {
                /* Found it; call. */
                PMC * const meth = VTABLE_get_pmc_keyed_str(interp,
                    class_info->vtable_methods, string_from_literal(interp, "$vt_method_name"));
                ${return}Parrot_run_meth_fromc_args$ret_suffix(interp, meth, pmc, string_from_literal(interp, "$vt_method_name"), "$sig"$args);
                $void_return
            }
        }
        else {
            /* Get the PMC instance and call the vtable method on that. */
            PMC * const del_class = VTABLE_get_pmc_keyed_int(interp, obj->attrib_store, alien_parents_pos);
            ${return}VTABLE_$vt_method_name(interp, del_class$args);
        }
    }
    $null_return
EOC
        $self->add_method($new_default_method);
    }
    return 1;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
