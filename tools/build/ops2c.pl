#! perl
# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$
use warnings;
use strict;
use lib 'lib';
# use Parrot::Config;
use Parrot::Ops2c::Auxiliary qw( Usage getoptions );
use Parrot::Ops2c::Utils;

my $flagref = getoptions();
if (
        (not defined $flagref) or 
        $flagref->{help} or
        (not @ARGV)
    ) {
        Usage();
        exit 1;
}

my $self = Parrot::Ops2c::Utils->new( {
    argv    => [ @ARGV ],
    flag    => $flagref,
    script  => $0,
} );
if (not defined $self) {
    Usage();
    exit 1;
}

$self->print_c_header_file();

my $SOURCE = $self->print_c_source_top();

my $c_source_final = $self->print_c_source_bottom($SOURCE);

exit 0;

#################### DOCUMENTATION ####################

=head1 NAME

tools/build/ops2c.pl - Parser for .ops files

=head1 SYNOPSIS

    % perl tools/build/ops2c.pl trans [--help] [--no-lines] [--dynamic]
                                      [--core | input.ops [input2.ops ...]]
       trans := C | CGoto | CGP | CSwitch | CPrederef

For example:

    % perl tools/build/ops2c.pl C --core

    % perl tools/build/ops2c.pl C --dynamic myops.ops

=head1 DESCRIPTION

This script uses a supplied transform to create a pair of C header and
implementation files from the operation definitions found in one or more
F<*.ops> files.

=head2 Transforms

The first command-line argument is the last package name component of a
subclass of C<Parrot::OpTrans>. These subclasses all have full names of
the form C<Parrot::OpTrans::*>. An instance of the class is created and
later consulted for various bits of information needed to generate the C
code. Each creates a different type of run loop.

=over

=item C<C>

Create the function-based (slow or fast core) run loop.

=item C<CGoto>

Create the C<goto> run loop.

=item C<CGP>

Create the C<goto> and predereferenced run loop.

=item C<CSwitch>

Create the C<switch>ed and predereferenced run loop.

=item C<CPrederef>

Create the predereferenced run loop.

=back

=head2 Options

=over 4

=item C<--help>

Print synopsis.

=item C<--dynamic>

Indicate that the opcode library is dynamic.

=item C<--core>

Build the Parrot core opcode library.

=item C<--no-lines>

Do not generate C<#line> directives in the generated C code.

=back

=head1 SEE ALSO

=over 4

=item F<tools/build/ops2pm.pl>

=item C<Parrot::OpsFile>

=item C<Parrot::Op>

=item C<Parrot::OpTrans>

=item C<Parrot::OpTrans::C>

=item C<Parrot::OpTrans::CGoto>

=item C<Parrot::OpTrans::Compiled>

=item C<Parrot::OpTrans::CGP>

=item C<Parrot::OpTrans::CSwitch>

=item C<Parrot::OpTrans::CPrederef>

=item C<Parrot::Ops2c::Utils>

=item C<Parrot::Ops2c::Auxiliary>

=back

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

