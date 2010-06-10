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

method source( $trans ) {

    my $prelude := $trans.body_prelude;
    return $prelude ~ self.get_body( $trans );
}

=begin

=item C<get_body($trans)>

Performs the various macro substitutions using the specified transform,
correctly handling nested substitions, and repeating over the whole string
until no more substitutions can be made.

C<VTABLE_> macros are enforced by converting C<<< I<< x >>->vtable->I<<
method >> >>> to C<VTABLE_I<method>>.

=end

method get_body( $trans ) {

    my @body := list();

    #work through the op_body tree
    for @(self) {
        my $chunk := self.process_body_chunk($trans, $_);
        #pir::say('# chunk ' ~ $chunk);
        @body.push($chunk);
    }

    join('', |@body);
}

# Recursively process body chunks returning string.

our multi method process_body_chunk($trans, PAST::Var $chunk) {
    my $n := +$chunk.name;
    return $trans.access_arg( self.arg_type($n - 1), $n);
}

our multi method process_body_chunk($trans, PAST::Op $chunk) {
    my $type := $chunk.pasttype;
    #say('OP ' ~ $type);
    if $type eq 'inline' {
        #_dumper($chunk);
        #pir::say('RET ' ~ $chunk<inline>);
        return $chunk.inline;
    }
    elsif $type eq 'call' {
        my $name     := $chunk.name;
        #say('NAME '~$name ~ ' ' ~ $is_next);
        if $name eq 'OPSIZE' {
            #say('is_next');
            return ~self.size;
        }

        my @children := list();
        for @($chunk) {
            @children.push(self.process_body_chunk($trans, $_));
        }
        my $children := join('', |@children);

        #pir::say('children ' ~ $children);
        my $ret := Q:PIR<
            $P0 = find_lex '$trans'
            $P1 = find_lex '$name'
            $S0 = $P1
            $P1 = find_lex '$children'
            %r  = $P0.$S0($P1)
        >;
        #pir::say('RET ' ~ $ret);
        return $ret;
    }
}

our multi method process_body_chunk($trans, PAST::Stmts $chunk) {
    my @children := list();
    for @($chunk) {
        @children.push(self.process_body_chunk($trans, $_));
    }
    my $children := join('', |@children);
    return $children;
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

