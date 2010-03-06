
class Ops::Trans::C is Ops::Trans;

method new() {
    # Storage for generated ops functions.
    self<op_funcs>  := list();
    # Storage for generated ops functions prototypes.
    self<op_protos> := list();

    self;
}

method suffix() { '' };

method prepare_ops($emitter, $ops_file) {

    my $index := 0;
    my @op_protos;
    my @op_funcs;
    my @op_func_table;

    for $ops_file.ops -> $op {
        #say("# preparing " ~ $op);
        my $func_name := self.suffix ~ $op.full_name;
        my $definition := "opcode_t *\n$func_name (opcode_t *cur_opcode, PARROT_INTERP)";
        my $prototype := ~$emitter<sym_export>
                ~ "opcode_t * $func_name (opcode_t *cur_opcode, PARROT_INTERP);\n";

        my $src := $op.source( self );

        @op_func_table.push(sprintf( "  %-50s /* %6ld */\n", "$func_name,", $index ));

        my $body := join(' ', $definition, '{', "\n", $src, '}', "\n\n");
        @op_funcs.push($body);
        @op_protos.push($prototype);
        $index++;
    }

    self<op_funcs>      := @op_funcs;
    self<op_protos>     := @op_protos;
    self<op_func_table> := @op_func_table;
}

method emit_c_header_part($fh) {
    for self<op_protos> -> $proto {
        $fh.print($proto);
    }
}

# vim: expandtab shiftwidth=4 ft=perl6: