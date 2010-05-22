#! nqp
# Copyright (C) 2010, Parrot Foundation.
# $Id$

INIT {
    pir::load_bytecode("dumper.pbc");
};

class Ops::Renumberer is Hash;

=begin NAME

C<Ops::Renumberer> - renumber ops.num.

=end NAME

=begin DESCRIPTION

This class is responsible for renumbering src/ops/ops.num when the number or
order of ops there needs to be changed.

=end DESCRIPTION

=begin SYNOPSIS

    my $renum := Ops::Renumberer.new( :ops_file($f) );

=end SYNOPSIS

=begin ATTRIBUTES

=over 4

=item * C<$.max_op_num>

Scalar holding number of highest non-experimental op.  Example:

    'max_op_num' => 1246,

=back

=end ATTRIBUTES

=begin METHODS

=over 4

=item C<new>

Build an Ope::Renumberer.

(It's NQP. In Perl 6 it should be submethod and invoked automatically)

=end METHODS

method new(:$ops_file!) {
    self<ops_file> := $ops_file;

    self;
}

=begin METHODS

=item C<needs_renumbering>

Check if ops.num needs to be renumbered.

=end METHODS

method needs_renumbering() {
    #find out if the order in ops.num reflects the order in Ops::File
    my $op_num_table := self<ops_file>.oplib.op_num_table;
    my $opsfile_ops  := self<ops_file>.ops;
    my $opsfile_num  := 0;
    my $needs_renumbering := 0;

    for $opsfile_ops -> $opsfile_op {
        my $op_name := $opsfile_op.full_name;
        my $op_num_table_num := +$op_num_table{ $op_name };
        #say("op_num_table says $op_name has number $op_num_table_num, opsfile says $opsfile_num");
        if (!$opsfile_op<experimental> && $opsfile_num != $op_num_table_num) {
            say("Opsfile and optable disagree about $op_name: $opsfile_num vs $op_num_table_num");
            $needs_renumbering := 1;
        }
        $opsfile_num++;
    }

    $needs_renumbering;
}

method renumber_ops() {
    #grab all ops in ops.num
    my %fixed_ops     := hash();
    my %numbered_ops  := hash();
    my $found_dynamic := 0;
    my $max_op_num    := 0;
    my $ops_num_fh    := pir::open__PSs(self<ops_file>.oplib.num_file, 'w')
        || die("Can't open "~ self<ops_file>.oplib.num_file);

    #record which ones have fixed numbers and which just need to be somewhere in ops.num
    for self<ops_file>.oplib.num_file_lines -> $line {

        #copy all lines through ###DYNAMIC### into the new ops.num verbatim
        unless $found_dynamic {
            $ops_num_fh.print(~$line);
        }

        if $line<op> {
            if $found_dynamic {
                %numbered_ops{ $line<op><name> } := 1;
            }
            else {
                %fixed_ops{ $line<op><name> } := +$line<op><number>;
                $max_op_num := +$line<op><number>;
            }
        }
        elsif $line<dynamic> {
            $found_dynamic := 1;
        }
    }

    #XXX: print header to include/parrot/opsenum.h (ignore fixed ops)

    for self<ops_file>.ops -> $op {
        if %numbered_ops.exists( $op.full_name ) {
            $max_op_num++;
            $ops_num_fh.print($op.full_name ~ "    " ~ $max_op_num ~ "\n");
        }
    }
}

# Local Variables:
#   mode: perl6
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=perl6:
