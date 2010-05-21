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
    #record which ones are fixed and which just need to be somewhere
    #iterate through ops::file's ops
        #if this op is fixed
            #give it the fixed number
            #record the fixed number
        #else
            #give this op ++fixed
}

=begin ACCESSORS

Various methods for accessing internals.

=over 4

=item * C<skiptable>

=end ACCESSORS

method skiptable()  { self<skiptable>; }


# Local Variables:
#   mode: perl6
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=perl6:
