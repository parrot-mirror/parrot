# Copyright (C) 2001-2004, Parrot Foundation.
# $Id$

=head1 NAME

Parrot::OpTrans::Compiled - Transform Parrot Bytecode To C

=head1 DESCRIPTION

C<Parrot::OpTrans::Compiled> inherits from C<Parrot::OpTrans> and is
used by F<tools/build/pbc2c.pl> to transform Parrot bytecode to a C code
run loop.

=head2 Instance Methods

=over 4

=cut

package Parrot::OpTrans::Compiled;

use strict;
use warnings;

use base qw( Parrot::OpTrans );

=item C<defines()>

Returns the C C<#define> macros required by the ops.

=cut

sub defines {
    return <<END;
#define REL_PC (cur_opcode - start_code)
#define IREG(i) REG_INT(interp, i)
#define NREG(i) REG_NUM(interp, i)
#define PREG(i) REG_PMC(interp, i)
#define SREG(i) REG_STR(interp, i)
#define CONST(i) interp->code->const_table->constants[i]
END
}

=item C<pc($pc)>

=item C<pc()>

Sets/gets the current position in Parrot code.

=cut

sub pc {
    my $self = shift;

    if (@_) {
        $self->{PC} = shift;
    }
    else {
        return $self->{PC};
    }
}

=item C<args(@args)>

=item C<args()>

Sets/gets the transform's arguments.

=cut

sub args {
    my $self = shift;

    if (@_) {
        $self->{ARGS} = [@_];
    }
    else {
        return $self->{ARGS};
    }
}

=item C<arg($index)>

Returns the argument at index C<$index>.

=cut

sub arg {
    my $self = shift;

    return $self->{ARGS}[shift];
}

=item C<goto_address($address)>

Transforms the C<goto ADDRESS($address)> macro in an ops file into the
relevant C code.

=cut

sub goto_address {
    my ( $self, $addr ) = @_;

    #print STDERR "pbcc: map_ret_abs($addr)\n";

    return "cur_opcode = $addr;\ngoto switch_label";
}

=item C<expr_offset($offset)>

An offset expression is always an offset from C<start_code>, because
the C<ret> instruction may be in a different runops core. C<ret> will
always treat saved addresses as relative to C<start_code>, because that
interpretation is global across all runops cores.

=cut

sub expr_offset {
    my ( $self, $offset ) = @_;

    return sprintf( "start_code + %d + %s", $self->pc, $offset );
}

=item C<goto_offset($offset)>

Transforms the C<goto OFFSET($offset)> macro in an ops file into the
relevant C code.

=cut

sub goto_offset {
    my ( $self, $offset ) = @_;

    if ( $offset =~ /^-?\d+$/ ) {
        return sprintf( "goto PC_%d", $self->pc + $offset );
    }
    else {
        return sprintf( "cur_opcode = &&PC_%d; cur_opcode += %s; goto switch_label",
            $self->pc, $offset );
    }

    #print STDERR "pbcc: map_ret_rel($offset)\n";
}

=item C<goto_pop()>

Transforms the C<goto POP()> macro in an ops file into the relevant C
code.

=cut

sub goto_pop {
    my ($self) = @_;

    return "cur_opcode = pop_dest(interp);\ngoto switch_label";
}

my %arg_maps = (
    'i'  => "IREG(%ld)",
    'n'  => "NREG(%ld)",
    'p'  => "PREG(%ld)",
    's'  => "SREG(%ld)",
    'k'  => "PREG(%ld)",
    'ki' => "IREG(%ld)",

    'ic'  => "%ld",
    'nc'  => "CONST(%ld)->u.number",
    'pc'  => "CONST(%ld)->u.key",
    'sc'  => "CONST(%ld)->u.string",
    'kc'  => "CONST(%ld)->u.key",
    'kic' => "%ld",
);

=item C<access_arg($type, $value, $op)>

Returns the C code for the specified op argument type (see
C<Parrot::OpTrans>) and value. C<$op> is an instance of C<Parrot::Op>.

=cut

sub access_arg {
    my ( $self, $type, $num, $op ) = @_;

    #print STDERR "pbcc: map_arg($type, $num)\n";

    return sprintf( $arg_maps{$type}, $self->arg( $num - 1 ) );
}

=item C<restart_address($address)>

Returns the C code for C<restart ADDRESS($address)>.

=cut

sub restart_address {
    my ( $self, $addr ) = @_;

    die "pbc2c.pl: Cannot handle RESUME ops!";
}

=item C<restart_offset($offset)>

Returns the C code for C<restart OFFSET($offset)>.

=cut

sub restart_offset {
    my ( $self, $offset ) = @_;

    die "pbc2c.pl: Cannot handle RESUME ops!";
}

=back

=head1 SEE ALSO

=over 4

=item C<Parrot::OpTrans>

=item C<Parrot::OpTrans::C>

=item C<Parrot::OpTrans::CGP>

=item C<Parrot::OpTrans::CGoto>

=item C<Parrot::OpTrans::CPrederef>

=item C<Parrot::OpTrans::CSwitch>

=back

=cut

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
