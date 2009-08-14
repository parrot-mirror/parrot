#! perl
# Copyright (C) 2001-2008, Parrot Foundation.
# $Id$

=head1 NAME

Parrot::Op - Parrot Operation

=head1 SYNOPSIS

  use Parrot::Op;

=head1 DESCRIPTION

C<Parrot::Op> represents a Parrot operation (op, for short), as read
from an ops file via C<Parrot::OpsFile>, or perhaps even generated by
some other means. It is the Perl equivalent of the C<op_info_t> C
C<struct> defined in F<include/parrot/op.h>.

=head2 Op Type

Ops are either I<auto> or I<manual>. Manual ops are responsible for
having explicit next-op C<RETURN()> statements, while auto ops can count
on an automatically generated next-op to be appended to the op body.

Note that F<tools/build/ops2c.pl> supplies either 'inline' or 'function'
as the op's type, depending on whether the C<inline> keyword is present
in the op definition. This has the effect of causing all ops to be
considered manual.

=head2 Op Arguments

Note that argument 0 is considered to be the op itself, with arguments
1..9 being the arguments passed to the op.

Op argument direction and type are represented by short one or two letter
descriptors.

Op Direction:

    i   The argument is incoming
    o   The argument is outgoing
    io  The argument is both incoming and outgoing

Op Type:

    i   The argument is an integer register index.
    n   The argument is a number register index.
    p   The argument is a PMC register index.
    s   The argument is a string register index.
    ic  The argument is an integer constant (in-line).
    nc  The argument is a number constant index.
    pc  The argument is a PMC constant index.
    sc  The argument is a string constant index.
    kc  The argument is a key constant index.
    ki  The argument is a key integer register index.
    kic  The argument is a key integer constant (in-line).

=head2 Class Methods

=over 4

=cut

package Parrot::Op;

use strict;
use warnings;

=item C<new($code, $type, $name, $args, $argdirs, $labels, $flags)>

Allocates a new bodyless op. A body must be provided eventually for the
op to be usable.

C<$code> is the integer identifier for the op.

C<$type> is the type of op (see the note on op types above).

C<$name> is the name of the op.

C<$args> is a reference to an array of argument type descriptors.

C<$argdirs> is a reference to an array of argument direction
descriptors. Element I<x> is the direction of argument C<< $args->[I<x>]
>>.

C<$labels> is a reference to an array of boolean values indicating
whether each argument direction was prefixed by 'C<label>'.

C<$flags> is a hash reference containing zero or more I<hints> or
I<directives>.

=cut

sub new {
    my $class = shift;
    my ( $code, $type, $name, $args, $argdirs, $labels, $flags ) = @_;

    my $self = {
        CODE    => $code,
        TYPE    => $type,
        NAME    => $name,
        ARGS    => [@$args],
        ARGDIRS => [@$argdirs],
        LABELS  => [@$labels],
        FLAGS   => $flags,
        BODY    => '',
        JUMP    => 0,
    };

    return bless $self, $class;
}

=back

=head2 Instance Methods

=over 4

=item C<code()>

Returns the op code.

=cut

sub code {
    my $self = shift;

    return $self->{CODE};
}

=item C<type()>

The type of the op, either 'inline' or 'function'.

=cut

sub type {
    my $self = shift;

    return $self->{TYPE};
}

=item C<name()>

The (short or root) name of the op.

=cut

sub name {
    my $self = shift;

    return $self->{NAME};
}

=item C<full_name()>

For argumentless ops, it's the same as C<name()>. For ops with
arguments, an underscore followed by underscore-separated argument types
are appended to the name.

=cut

sub full_name {
    my $self      = shift;
    my $name      = $self->name;
    my @arg_types = $self->arg_types;

    $name .= "_" . join( "_", @arg_types ) if @arg_types;

    return $name;
}

=item C<func_name()>

The same as C<full_name()>, but with 'C<Parrot_>' prefixed.

=cut

sub func_name {
    my ( $self, $trans ) = @_;

    return $trans->prefix . $self->full_name;
}

=item C<arg_types()>

Returns the types of the op's arguments.

=cut

sub arg_types {
    my $self = shift;

    return @{ $self->{ARGS} };
}

=item C<arg_type($index)>

Returns the type of the op's argument at C<$index>.

=cut

sub arg_type {
    my $self = shift;

    return $self->{ARGS}[shift];
}

=item C<arg_dirs()>

Returns the directions of the op's arguments.

=cut

sub arg_dirs {
    my $self = shift;

    return @{ $self->{ARGDIRS} };
}

=item C<labels()>

Returns the labels.

=cut

sub labels {
    my $self = shift;

    return @{ $self->{LABELS} };
}

=item C<flags(@flags)>

=item C<flags()>

Sets/gets the op's flags.  This returns a hash reference, whose keys are any
flags (passed as ":flag") specified for the op.

=cut

sub flags {
    my $self = shift;

    if (@_) {
        $self->{FLAGS} = shift;
    }

    return $self->{FLAGS};
}

=item C<arg_dir($index)>

Returns the direction of the op's argument at C<$index>.

=cut

sub arg_dir {
    my $self = shift;

    return $self->{ARGDIRS}[shift];
}

=item C<body($body)>

=item C<body()>

Sets/gets the op's code body.

=cut

sub body {
    my $self = shift;

    if (@_) {
        $self->{BODY} = shift;
    }

    return $self->{BODY};
}

=item C<jump($jump)>

=item C<jump()>

Sets/gets a string containing one or more C<op_jump_t> values joined with
C<|> (see F<include/parrot/op.h>). This indicates if and how an op
may jump.

=cut

sub jump {
    my $self = shift;

    if (@_) {
        $self->{JUMP} = shift;
    }

    return $self->{JUMP};
}

=item C<full_body()>

For manual ops, C<full_body()> is the same as C<body()>. For auto ops
this method adds a final C<goto NEXT()> line to the code to represent
the auto-computed return value. See the note on op types above.

=cut

sub full_body {
    my $self = shift;
    my $body = $self->body;

    $body .= sprintf( "  {{+=%d}};\n", $self->size ) if $self->type eq 'auto';

    return $body;
}

# Called from rewrite_body() to perform the actual substitutions.
sub _substitute {
    my $self = shift;
    local $_ = shift;
    my $trans = shift;

    s/{{\@([^{]*?)}}/   $trans->access_arg($self->arg_type($1 - 1), $1, $self); /me;

    s/{{=0,=([^{]*?)}}/   $trans->restart_address($1) . "; {{=0}}"; /me;
    s/{{=0,\+=([^{]*?)}}/ $trans->restart_offset($1)  . "; {{=0}}"; /me;
    s/{{=0,-=([^{]*?)}}/  $trans->restart_offset(-$1) . "; {{=0}}"; /me;

    s/{{\+=([^{]*?)}}/    $trans->goto_offset($1);  /me;
    s/{{-=([^{]*?)}}/     $trans->goto_offset(-$1); /me;
    s/{{=([^*][^{]*?)}}/  $trans->goto_address($1); /me;

    s/{{\^(-?\d+)}}/      $1                        /me;
    s/{{\^\+([^{]*?)}}/   $trans->expr_offset($1);  /me;
    s/{{\^-([^{]*?)}}/    $trans->expr_offset(-$1); /me;
    s/{{\^([^{]*?)}}/     $trans->expr_address($1); /me;

    return $_;
}

=item C<rewrite_body($body, $trans)>

Performs the various macro substitutions using the specified transform,
correctly handling nested substitions, and repeating over the whole string
until no more substitutions can be made.

C<VTABLE_> macros are enforced by converting C<<< I<< x >>->vtable->I<<
method >> >>> to C<VTABLE_I<method>>.

=cut

sub rewrite_body {
    my ( $self, $body, $trans ) = @_;

    # use vtable macros
    $body =~ s!
        (?:
            {{\@\d+\}}
            |
            \b\w+(?:->\w+)*
        )->vtable->\s*(\w+)\(
        !VTABLE_$1(!sgx;

    while (1) {
        my $new_body = $self->_substitute( $body, $trans );

        last if $body eq $new_body;

        $body = $new_body;
    }

    return $body;
}

=item C<source($trans)>

Returns the L<C<full_body()>> of the op with substitutions made by
C<$trans> (a subclass of C<Parrot::OpTrans>).

=cut

sub source {
    my ( $self, $trans ) = @_;

    my $flags = $self->flags;

    if (exists($$flags{pic})
        && !( ref($trans) eq 'Parrot::OpTrans::CGP' || ref($trans) eq 'Parrot::OpTrans::CSwitch' ) )
    {
        return qq{PANIC(interp, "How did you do that");\n};
    }

    return $self->rewrite_body( $self->full_body, $trans );
}

=item C<size()>

Returns the op's number of arguments. Note that this also includes
the op itself as one argument.

=cut

sub size {
    my $self = shift;

    return scalar( $self->arg_types + 1 );
}

=back

=head1 SEE ALSO

=over 4

=item C<Parrot::OpsFile>

=item C<Parrot::OpTrans>

=item F<tools/build/ops2c.pl>

=item F<tools/build/ops2pm.pl>

=item F<tools/build/pbc2c.pl>

=back

=head1 HISTORY

Author: Gregor N. Purdy E<lt>gregor@focusresearch.comE<gt>

=cut

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
