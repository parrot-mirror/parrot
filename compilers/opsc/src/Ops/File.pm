#! nqp
# Copyright (C) 2001-2009, Parrot Foundation.
# $Id$

# XXX Better to put this into docs/ somewhere.

=begin

=head1 NAME

Ops::File - Ops To C Code Generation

=head1 SYNOPSIS

  use Ops::File;

=head1 DESCRIPTION

C<Ops::File> takes one or more files of op functions and
creates real C code for them.

This class is used by F<tools/build/ops2c.pl>,
F<tools/build/ops2pm.pl> and F<tools/build/pbc2c.pl>.

=head2 Op Functions

For ops that have trivial bodies (such as just a call to some other
function and a C<return> statement), opcode functions are in the format:

    inline op opname (args) :flags {
        ... body of function ...
    }

Note that currently the C<inline> op type is ignored.

Alternately, for opcode functions that have more internal complexity the
format is:

    op opname (args) :flags {
        ... body of function ...
    }

There may be more than one C<return>.

In both cases the closing brace B<must> be on its own line.

When specifying multiple flags, each flag gets its own prefixing colon.

=head2 Op Arguments

Op arguments are a comma-separated list of direction and type pairs.

Argument direction is one of:

    in            the argument passes a value into the op
    out           the argument passes a value out of the op
    inout         the argument passes a value into and out of the op
    inconst       the argument passes a constant value into the op
    invar         the argument passes a variable value into the op

Argument direction is used to determine the life times of symbols and
their related register allocations. When an argument is passed into an
op a register is read from, when it's passed out of an op a register is
written to.

Argument type is one of:

    INT       the argument is an integer
    NUM       the argument is an numeric
    STR       the argument is an string
    PMC       the argument is an PMC
    KEY       the argument is an aggregate PMC key
    INTKEY    the argument is an aggregate PMC integer key
    LABEL     the argument is an integer branch offset or address

The size of the return offset is determined from the op function's
signature.

=head2 Op Flags

The flags are of two types:

=over 4

=item 1 class

The classification of ops is intended to facilitate the selection of
suitable ops for a Parrot safe mode.

=item 2 behavior

The presence (or absence) of certain flags will change how the op behaves. For
example, the lack of the C<flow> flag will cause the op to be implicitly
terminated with C<goto NEXT()>. (See next section).

The :deprecated flag will generate a diagnostic to standard error at
runtime when a deprecated opcode is invoked and
C<PARROT_WARNINGS_DEPRECATED_FLAG> has been set.

=back

=head2 Op Body (Macro Substitutions)

In the following macro descriptions, C<PC> and C<PC'> are the current
and next position within the Parrot code.

=over 4

=item C<goto OFFSET(X)>

Transforms to C<PC' = PC + X>. This is used for branches.

=item C<goto NEXT()>

Transforms to C<PC' = PC + S>, where C<S> is the size of an op.

=item C<goto ADDRESS(X)>

Transforms to C<PC' = X>. This is used for absolute jumps.

=item C<expr OFFSET(X)>

Transforms to C<PC + X>. This is used to give a relative address.

=item C<expr NEXT()>

Transforms to C<PC + S>, the position of the next op.

=item C<expr ADDRESS(X)>

Transforms to C<X>, an absolute address.

=item C<OP_SIZE>

Transforms to C<S>, the size of an op.

=item C<HALT()>

Transforms to C<PC' = 0>. Halts run loop, and resets the current
position to the start of the Parrot code, without resuming.

=item C<restart OFFSET(X)>

Transforms to C<PC' = 0> and restarts at C<PC + X>.

=item C<restart NEXT()>

Transforms to C<PC' = 0> and restarts at C<PC + S>.

=item C<$n>

Transforms to the op function's nth argument. C<$0> is the opcode itself.

=back

Note that, for ease of parsing, if the argument to one of the above
notations in a ops file contains parentheses, then double the enclosing
parentheses and add a space around the argument, like so:

    goto OFFSET(( (void*)interp->happy_place ))

=head2 Class Methods

=over 4

=end

class Ops::File is Hash;

pir::load_bytecode('config.pbc');

=begin

=item C<new(@files)>

Returns a new instance initialized by calling C<read_ops()> on each of
the specified op files.

=item C<new_str($str)>

Returns a new instance initialized by compiling C<$str> as the contents of an
ops file.

=end

method new(*@files, :$oplib!, :$nolines, :$core) {
    self<files>   := @files;
    self<oplib>   := $oplib;
    self<core>    := $core;
    self<ops>     := list(); # Ops
    self<preamble>:= '';

    if !self<core> {
        self<file> := @files[0];
    }

    self<compiler>:= pir::compreg__Ps('Ops');
    self<compiler>.set_oplib($oplib);

    self._set_version();

    for @files { self.read_ops( $_, $nolines ) }

    self;
}

method new_str($str, :$oplib) {
    self<ops>      := list(); # Ops
    self<preamble> := '';

    self<compiler> := pir::compreg__Ps('Ops');
    self<oplib>    := $oplib;
    self<compiler>.set_oplib($oplib);

    self._set_version();

    self._set_version();

    self.compile_ops($str);

    self;
}


=begin

=back

=head2 Instance Methods

=over 4

=item C<read_ops($file,$nolines)>

Reads in the specified .ops file, gathering information about the ops.

=end

method read_ops($file, $nolines) {
    $Ops::Compiler::Actions::OPLIB := self<oplib>;

    say("# Parsing $file");
    my $start_time := pir::time__N();
    my $buffer     := slurp($file);
    self.compile_ops($buffer);
    say('# ... in ' ~ pir::time__N() - $start_time ~ ' seconds');
}

method compile_ops($str) {
    my $compiler := self<compiler>;
    my $past     := $compiler.compile($str, :target('past'));

    for @($past<ops>) {
        if $_<experimental> && self<core> {
            say("# Experimental op " ~ $_.full_name ~ " is not in ops.num.");
        }
        self<ops>.push($_);
    }

    for @( $past<preamble> ) {
        self<preamble> := self<preamble> ~ $_;
    }
    $past;
}

method get_parse_tree($str) {
    my $compiler := pir::compreg__Ps('Ops');
    $compiler.compile($str, :target('parse'));
}

method preamble() { self<preamble> };
method ops() { self<ops> };

method version() {
    self<version>;
}

method version_major() { self<version_major> }
method version_minor() { self<version_minor> }
method version_patch() { self<version_patch> }

method _set_version() {
    my $config := _config();
    my $version := $config<VERSION>;
    #say("# $version");
    my @bits := split('.', $version);
    self<version_major> := @bits[0];
    self<version_minor> := @bits[1];
    self<version_patch> := @bits[2];
    self<version>       := @bits;
}

=begin

=back

=head1 SEE ALSO

=over 4

=item C<Parrot::Op>

=item C<Parrot::OpTrans>

=item F<tools/build/ops2c.pl>

=item F<tools/build/ops2pm.pl>

=item F<tools/build/pbc2c.pl>

=back

=end

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: ft=perl6 expandtab shiftwidth=4: