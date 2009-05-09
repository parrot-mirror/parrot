# Copyright (C) 2009, Parrot Foundation.
# $Id$

class PMC::Emitter::PMC;

# =item C<generate_h_file>
#
# Generate part of header file.
#
# =cut

# "Template Method". Just override generate_h_file_functions in derived
# classes.

method generate_h_file() {
    my $past := self.past;
    my $name := self.name;

    my $guard := 'PARROT_PMC_' ~ self.ucname ~ '_H_GUARD';

    # "join" is way too simple...
    my $res := join('', (
        '#ifndef ' ~ $guard ~ "\n",
        '#define ' ~ $guard ~ "\n\n",

        self.generate_h_file_functions(), "\n",

        self.generate_attr_struct(), "\n",

        self.generate_casting_macro(), "\n",

        self.generate_attr_accessors(), "\n",

        '#endif /* ', $guard, " */ \n"
    )
    );

    $res
}

# =item C<generate_h_file_functions>
#
# Generate C declarations for vtable functions
#
# =cut

method generate_h_file_functions() {
    my $past := self.past;
    my %vtables := PMC::VTableInfo::vtable_hash();

    my @res_builder;

    @res_builder.push("void Parrot_" ~ self.name ~ "_class_init(PARROT_INTERP, int, int);\n");

    my %vtables := self.vtables;

    for %vtables {
        my $entry := %vtables{$_};
        @res_builder.push(self.generate_signature($entry, "") ~ ";\n");
    };

    join('', @res_builder);
}

#=item C<generate_attr_struct>
#
#Generate a C declaration for the ATTR wrapper struct
#
#=cut

method generate_attr_struct() {

    my $struct_start;
    my $struct_body;
    my $struct_end;

    $struct_start :=
        "\n/* " ~ self.name ~ " PMC's underlying struct. */\n" ~
        "typedef struct Parrot_" ~ self.name ~ "_attributes {\n";

    my @attrs := self.attrs;
    my @struct_members;

    for @attrs {
        @struct_members.push("    " ~ $_<type> ~ " " ~ $_<name> ~ ";\n");
    }

    $struct_end := "} Parrot_" ~ self.name ~ "_attributes;\n";

    return $struct_start ~ join('', @struct_members) ~ $struct_end;
}

#=item C<generate_casting_macro>
#
#Generate a #define to simplify ATTR access
#
#=cut

method generate_casting_macro() {

    return
        "#define PARROT_" ~ self.ucname ~ "(o) ((Parrot_" ~ self.name ~ "_attributes *) PMC_data(o))\n";
}


#=item C<generate_attr_accessors>
#
#Generate a macros to manipulate ATTRs
#
#=cut

method generate_attr_accessors() {

    my @attrs := self.attrs;
    my @accessors;

    for @attrs {
        @accessors.push( self.generate_accessor_comment(self.name, $_<name>) );
        @accessors.push( self.generate_get_accessor($_<type>,$_<name>) );
        @accessors.push( self.generate_set_accessor($_<type>,$_<name>) );
    }

    return join("\n", @accessors);
}

method generate_accessor_comment( $pmcname, $attrname ) {
    return
        "\n/* Generated macro accessors for the '"~ $attrname ~
        "' attribute of the "~ $pmcname ~ " PMC. */\n";
}

method generate_get_accessor($type, $attr_name) {

    my $macro_start :=
"#define GETATTR_" ~ self.name ~ "_" ~ $attr_name ~ "(interp, pmc, dest) \\
do { \\
    if (PObj_is_object_TEST(pmc)) { \\\n";

    my $macro_body;

    if $type eq 'INTVAL' {
        $macro_body := self.intval_getter_body($attr_name);
    }
    elsif $type eq 'FLOATVAL' {
        $macro_body := self.floatval_getter_body($attr_name);
    }
    elsif $type eq 'STRING*' {
        $macro_body := self.strptr_getter_body($attr_name);
    }
    elsif $type eq 'PMC*' {
        $macro_body := self.pmcptr_getter_body($attr_name);
    }
    else {
        $macro_body := self.default_getter_body($type);
    }

    my $macro_end := "
    } \\
    else \\
        (dest) = ((Parrot_" ~ self.name ~ "_attributes *)PMC_data(pmc))->" ~ $attr_name ~ "; \\
} while (0);\n";

    return $macro_start ~ $macro_body ~ $macro_end;
}

method intval_getter_body($name) {
    return
'        PMC *attr_value = VTABLE_get_attr_str(interp, \\
            pmc, Parrot_str_new_constant(interp, "'~ $name ~'")); \\
        (dest) = (PMC_IS_NULL(attr_value) ? (INTVAL) 0: VTABLE_get_integer(interp, attr_value)); \\';
}

method floatval_getter_body($name) {
    return
'        PMC *attr_value = VTABLE_get_attr_str(interp, \\
            pmc, Parrot_str_new_constant(interp, "'~ $name ~'")); \\
        (dest) = (PMC_IS_NULL(attr_value) ? (FLOATVAL) 0.0: VTABLE_get_number(interp, attr_value)); \\';
}

method strptr_getter_body($name) {
    return
'        PMC *attr_value = VTABLE_get_attr_str(interp, \\
            pmc, Parrot_str_new_constant(interp, "'~ $name ~'")); \\
        (dest) = (PMC_IS_NULL(attr_value) ? (STRING *) NULL: VTABLE_get_string(interp, attr_value)); \\';
}

method pmcptr_getter_body($name) {
    return
'        (dest) = VTABLE_get_attr_str(interp, \\
             pmc, Parrot_str_new_constant(interp, "'~ $name ~'")); \\';
}

method default_getter_body($type) {
    return
"        Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION, \\
            \"Attributes of type '"~ $type ~ "' cannot be subclassed from a high-level PMC.\"); \\";
}

method generate_set_accessor($type, $attr_name) {

    my $macro_start :=
"#define SETATTR_"~ self.name ~"_"~ $attr_name ~"(interp, pmc, value) \\
do { \\
    if (PObj_is_object_TEST(pmc)) { \\\n";

    my $macro_body;

    if $type eq 'INTVAL' {
        $macro_body := self.intval_setter_body($attr_name);
    }
    elsif $type eq 'FLOATVAL' {
        $macro_body := self.floatval_setter_body($attr_name);
    }
    elsif $type eq 'STRING*' {
        $macro_body := self.strptr_setter_body($attr_name);
    }
    elsif $type eq 'PMC*' {
        $macro_body := self.pmcptr_setter_body($attr_name);
    }
    else {
        $macro_body := self.default_setter_body($type);
    }

    my $macro_end := "
    } \\
    else \\
        ((Parrot_"~ self.name ~"_attributes *)PMC_data(pmc))->"~ $attr_name ~" = (value); \\
} while (0);\n";

    return $macro_start ~ $macro_body ~ $macro_end;
}


method intval_setter_body($name) {
    return
"        PMC *attr_value = pmc_new(interp, enum_class_Integer); \\
        VTABLE_set_integer_native(interp, attr_value, value); \\
        VTABLE_set_attr_str(interp, pmc, \\
            Parrot_str_new_constant(interp, \""~ $name ~"\"), attr_value); \\";
}

method floatval_setter_body($name) {
    return
"        PMC *attr_value = pmc_new(interp, enum_class_Float); \\
        VTABLE_set_number_native(interp, attr_value, value); \\
        VTABLE_set_attr_str(interp, pmc, \\
            Parrot_str_new_constant(interp, \""~ $name ~"\"), attr_value); \\";
}

method strptr_setter_body($name) {
    return
"        PMC *attr_value = pmc_new(interp, enum_class_String); \\
        VTABLE_set_string_native(interp, attr_value, value); \\
        VTABLE_set_attr_str(interp, pmc, \\
            Parrot_str_new_constant(interp, \""~ $name ~"\"), attr_value); \\";
}

method pmcptr_setter_body($name) {
    return
"         VTABLE_set_attr_str(interp, pmc, \\
             Parrot_str_new_constant(interp, \""~ $name ~"\"), value); \\";
}

method default_setter_body($type) {
    return
"         Parrot_ex_throw_from_c_args(interp, NULL, EXCEPTION_INVALID_OPERATION, \\
              \"Attributes of type '"~ $type ~"' cannot be \" \\
              \"subclassed from a high-level PMC.\"); \\";
}


#=item C<generate_c_file>
#
#Generate C file for PMC.
#
#=cut
method generate_c_file() {
    my $res :=
          self.generate_c_file_functions()
        ~ self.generate_class_init();
}


#=item C<generate_c_file_functions>
#
#Generate C declarations for vtable functions
#
#=cut

method generate_c_file_functions() {
    my $past    := self.past;
    my %vtables := self.vtables;

    my @res;
    for %vtables {
        my $entry := %vtables{$_};
        @res.push(self.generate_signature($entry, ""));
        @res.push(PMC::Emitter::C::emit($entry));
    }

    join('', @res);
}


#=item C<!generate_class_init>
#
#Generating class_init function
#
#=cut

method generate_class_init() {
    my @res;
    @res.push(
          "PARROT_EXPORT void Parrot_"
        ~ self.name
        ~ "_class_init(PARROT_INTERP, int entry, int pass) {\n");

    # PUT VTABLE GENERTION HERE

    my $past := self.past;
    if ($past<class_init>) {
        @res.push("/* class_init */\n");
        @res.push(PMC::Emitter::C::emit($past<class_init>));
    }

    @res.push("\n}\n");
    join('', @res);
}

method dumper($x) {
    PIR q<
        load_bytecode "dumper.pbc"
    >;
    _dumper($x);
}

method attrs() {
    self.past.attrs;
}

method vtables() {
    self.past.vtables;
}

method generate_signature($entry, $prefix) {
    my @res;

    @res.push('PARROT_EXPORT ' ~ $entry.returns() ~ ' Parrot_' ~ self.name ~ '_' ~ $entry.name);

    @res.push('(PARROT_INTERP');
    for @($entry<parameters>) {
        @res.push(', ' ~ $_.returns() ~ $_.name);
    }
    @res.push(')');

    join('', @res);
}

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
