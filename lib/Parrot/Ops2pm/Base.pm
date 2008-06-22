# Copyright (C) 2007, The Perl Foundation.
# $Id$
package Parrot::Ops2pm::Base;
use strict;
use warnings;

=head1 NAME

Parrot::Ops2pm::Base - Constructor for Parrot::Ops2pm and Parrot::OpsRenumber.

=head1 SYNOPSIS

    use base qw( Parrot::Ops2pm::Base );

    $self = Parrot::Ops2pm->new( {
        argv            => [ @ARGV ],
        nolines         => $nolines_flag,
        renum           => $renum_flag,
        moddir          => "lib/Parrot/OpLib",
        module          => "core.pm",
        inc_dir         => "include/parrot/oplib",
        inc_f           => "ops.h",
        script          => "tools/build/ops2pm.pl",
    } );

=cut

=head1 DESCRIPTION

Parrot::Ops2pm::Base provides a constructor to be inherited by Parrot::Ops2pm
and Parrot::OpsRenumber.  The former provides methods called by
F<tools/build/ops2pm.pl>, a program which is called at the very beginning of
the Parrot F<make> process.  The latter is called by
F<tools/dev/opsrenumber.pl>.

=head1 METHODS

=head2 C<new()>

=over 4

=item * Purpose

Process files provided as command-line arguments to
F<tools/build/ops2pm.pl> and construct a Parrot::Ops2pm object.

=item * Arguments

Hash reference with the following elements:

    argv        :   reference to @ARGV
    nolines     :   set to true value to eliminate #line
                    directives in output
    renum       :   set to true value if
    moddir      :   directory where output module is created
                    (generally, lib/Parrot/OpLib)
    module      :   name of output module
                    (generally, core.pm)
    inc_dir     :   directory where C-header file is created
                    (generally, include/parrot/oplib)
    inc_f       :   name of output C-header file
                    (generally, ops.h)
    script      :   name of the script to be executed by 'make'
                    (generally, tools/build/ops2pm.pl)

=item * Return Value

Object of the invoking class (Parrot::Ops2pm or Parrot::OpsRenumber, as the
case may be).

=item * Comment

Arguments for the constructor have been selected so as to provide
subsequent methods with all information needed to execute properly and to be
testable.  A Parrot::Ops2pm object I<can> be constructed lacking some
of these arguments and still suffice for the execution of particular methods
-- this is done during the test suite -- but such an object would not suffice
for F<make>'s call to F<tools/build/ops2pm.pl>.

=back

=cut

sub new {
    my ( $class, $argsref ) = @_;
    my @argv = @{ $argsref->{argv} };
    my $file = shift @argv;
    die "$argsref->{script}: Could not find ops file '$file'!\n"
        unless -e $file;
    $argsref->{file} = $file;
    $argsref->{argv} = \@argv;
    $argsref->{num_file}    = "src/ops/ops.num";
    $argsref->{skip_file}   = "src/ops/ops.skip";
    return bless $argsref, $class;
}

1;
