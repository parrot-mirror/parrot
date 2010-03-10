#! nqp
# Copyright (C) 2010, Parrot Foundation.
# $Id$

=begin

=head1 NAME

Ops::Op - Parrot Operation

=head1 SYNOPSIS

  use Ops::Op;

=head1 DESCRIPTION

C<Ops::Op> represents a Parrot operation (op, for short), as read
from an ops file via C<Ops::OpsFile>, or perhaps even generated by
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

=end

class Ops::Op is PAST::Block;

INIT {
    pir::load_bytecode("dumper.pbc");
}

=begin

=item C<new(:$code, :$type, :$name, :@args, :%flags)>

Allocates a new bodyless op. A body must be provided eventually for the
op to be usable.

C<$code> is the integer identifier for the op.

C<$type> is the type of op (see the note on op types above).

C<$name> is the name of the op.

C<@args> is a reference to an array of argument type descriptors.

C<$flags> is a hash reference containing zero or more I<hints> or
I<directives>.


=back

=head2 Instance Methods

=over 4

=item C<code()>

Returns the op code.

=item C<type()>

The type of the op, either 'inline' or 'function'.

=item C<name()>

The (short or root) name of the op.

=item C<full_name()>

For argumentless ops, it's the same as C<name()>. For ops with
arguments, an underscore followed by underscore-separated argument types
are appended to the name.

=item C<func_name()>

The same as C<full_name()>, but with 'C<Parrot_>' prefixed.

=end

method code($code?) { self.attr('code', $code, defined($code)) }

method type($type?) { self.attr('type', $type, defined($type)) }

method name($name?) { self.attr('name', $name, defined($name)) }

method args($args?) { self.attr('args', $args, defined($args)) }

method arg_types($args?)  {
    my $res := self.attr('arg_types', $args, defined($args));

    return list() if !defined($res);
    pir::does__IPS($res, 'array') ?? $res !! list($res);
}

method arg_dirs($args?)   { self.attr('arg_dirs', $args, defined($args)) }

method arg_type($arg_num) {
    my @arg_types := self.arg_types;
    @arg_types[$arg_num];
}

method full_name() {
    my $name      := self.name;
    my @arg_types := self.arg_types;

    #say("# $name arg_types " ~ @arg_types);
    join('_', $name, |@arg_types);
}

method func_name($trans) {
    return $trans.prefix ~ self.full_name;
}


=begin

=item C<flags()>

Sets the op's flags.  This returns a hash reference, whose keys are any
flags (passed as ":flag") specified for the op.

=end

method flags(%flags?) { self.attr('flags', %flags, defined(%flags)) }

=begin

=item C<body($body)>

=item C<body()>

Sets/gets the op's code body.

=end

method body() {
    my $res := '';
    for @(self) -> $part {
        $res := $res ~ $part<inline>;
    }
    $res;
}

=begin

=item C<jump($jump)>

=item C<jump()>

Sets/gets a string containing one or more C<op_jump_t> values joined with
C<|> (see F<include/parrot/op.h>). This indicates if and how an op
may jump.

=end

method jump($jump?)   { self.attr('jump', $jump, defined($jump)) }

=begin

=item C<add_jump($jump)>

=item C<add_jump($jump)>

Add a jump flag to this op if it's not there already.

=end

method add_jump($jump) {
    my $found_jump := 0;

    unless self.jump { self.jump(list()) }

    for self.jump {
        if $_ eq $jump { $found_jump := 1 }
    }

    unless $found_jump { 
        self.jump.push($jump);
    }
}

=begin

=item C<get_jump()>

=item C<get_jump()>

Get the jump flags that apply to this op.

=end

method get_jump() {

    if self.jump {
        return join( '|', |self.jump );
    }
    else {
        return '0';
    }
}

=begin

=item C<source($trans, $op)>

Returns the L<C<body()>> of the op with substitutions made by
C<$trans> (a subclass of C<Ops::Trans>).

=end

method source( $trans, $op ) {

    my $prelude := $trans.body_prelude;
    return self.get_body( $prelude, $trans, $op );
}


# Called from rewrite_body() to perform the actual substitutions.
method substitute($str, $trans) {


    #also needed:
    #s/OP_SIZE/ self.size /g;
    $str := subst($str, /'OP_SIZE'/, self.size);

    #my $rewrote_access = s/{{\@([^{]*?)}}/   $trans->access_arg($self->arg_type($1 - 1), $1, $self); /me;

    $str := subst($str,
        /'{{@' $<op_num>=[<digit>+] '}}'/,
        -> $m { $trans.access_arg( self.arg_type(+$m<op_num> - 1), +$m<op_num>) }
    );

    #s/{{=0,=([^{]*?)}}/   $trans->restart_address($1) . "; {{=0}}"; /me;
    $str := subst($str,
        /'{{=0,=' $<addr>=[<-[{]>*?] '}}'/,
        -> $m { $trans.restart_address($m<addr>) ~ '; {{=0}}' }
    );

    #s/{{=0,\+=([^{]*?)}}/ $trans->restart_offset($1)  . "; {{=0}}"; /me;
    $str := subst($str,
        /'{{=0,+=' $<offset>=[<-[{]>*?] '}}'/,
        -> $m { $trans.restart_offset($m<offset>) ~ '; {{=0}}' }
    );

    #s/{{=([^*][^{]*?)}}/  $trans->goto_address($1); /me;
    $str := subst($str,
        /'{{=' $<addr>=[<-[{]>*?] '}}'/,
        -> $m { $trans.goto_address($m<addr>) }
    );

    #s/{{\+=([^{]*?)}}/    $trans->goto_offset($1);  /me;
    $str := subst($str,
        /'{{+=' $<offset>=[<-[{]>*?] '}}'/,
        -> $m { $trans.goto_offset($m<offset>) }
    );

    #s/{{\^(-?\d+)}}/      $1                        /me;
    $str := subst($str,
        /'{{^' $<addr>=[ <digit>+] '}}'/,
        -> $m { $m<addr> }
    );

    #s/{{\^\+([^{]*?)}}/   $trans->expr_offset($1);  /me;
    $str := subst($str,
        /'{{^+' $<offset>=[<-[{]>*?] '}}'/,
        -> $m { $trans.expr_offset($m<offset>) }
    );

    #s/{{\^([^{]*?)}}/     $trans->expr_address($1); /me;
    $str := subst($str,
        /'{{^' $<addr>=[<-[{]>*?] '}}'/,
        -> $m { $trans.expr_address($m<addr>) }
    );

=begin COMMENT

    #XXX: die "Argument access not allowed in preamble\n"
    #XXX: if $preamble_only && $rewrote_access;

=end COMMENT

    $str;
}

=begin

=item C<get_body($prelude, $trans, $op)>

Performs the various macro substitutions using the specified transform,
correctly handling nested substitions, and repeating over the whole string
until no more substitutions can be made.

C<VTABLE_> macros are enforced by converting C<<< I<< x >>->vtable->I<<
method >> >>> to C<VTABLE_I<method>>.

=end

method get_body( $prelude, $trans, $op ) {

    my $body := $prelude;

    #work through the op_body tree
    for $op<op_body> {

        pir::say("found an op body thing");
    }

    return self.substitute( $body, $trans );
}

=begin

=item C<size()>

Returns the op's number of arguments. Note that this also includes
the op itself as one argument.

=end

method size() {
    return pir::does__IPs(self.arg_types, 'array') ?? +self.arg_types + 1 !! 2;
}

=begin

=back

=head1 SEE ALSO

=over 4

=item C<Ops::OpsFile>

=item C<Ops::OpTrans>

=item F<tools/build/ops2c.pl>

=item F<tools/build/ops2pm.pl>

=item F<tools/build/pbc2c.pl>

=back

=head1 HISTORY

Author: Gregor N. Purdy E<lt>gregor@focusresearch.comE<gt>

Migrate to NQP: Vasily Chekalkin E<lt>bacek@bacek.comE<gt>

=end

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: ft=perl6 expandtab shiftwidth=4:

