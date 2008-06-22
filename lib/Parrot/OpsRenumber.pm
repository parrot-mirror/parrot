# Copyright (C) 2007, The Perl Foundation.
# $Id$
package Parrot::OpsRenumber;
use strict;
use warnings;
use Cwd;
use Data::Dumper ();
use File::Path ();
use File::Spec;
use lib qw ( lib );
use base qw( Parrot::Ops2pm::Base );
use Parrot::OpsFile;

=head1 NAME

Parrot::OpsRenumber - Methods holding functionality for F<tools/build/ops2pm.pl>.

=head1 SYNOPSIS

    use Parrot::OpsRenumber;

    $self = Parrot::OpsRenumber->new( {
        argv            => [ @ARGV ],
        nolines         => $nolines_flag,
        renum           => $renum_flag,
        moddir          => "lib/Parrot/OpLib",
        module          => "core.pm",
        inc_dir         => "include/parrot/oplib",
        inc_f           => "ops.h",
        script          => "tools/build/ops2pm.pl",
    } );

    $self->prepare_ops();

    if ($renum_flag) {
        $self->renum_op_map_file();
        exit 0;
    }

    $self->load_op_map_files();
    $self->sort_ops();
    $self->prepare_real_ops();
    $self->print_module();
    $self->print_h();
    exit 0;

=cut

=head1 DESCRIPTION

Parrot::OpsRenumber provides methods called by F<tools/dev/opsrenumber.pl>.

The functionality originally found in F<tools/build/ops2pm.pl> has been
extracted into this package's methods in order to support component-focused
testing and future refactoring.

=head1 METHODS

=head2 C<new()>

Inherited from Parrot::Ops2pm::Base and documented in
F<lib/Parrot/Ops2pm/Base.pm>.

=head2 C<renum_op_map_file()>

=over 4

=item * Purpose

Triggered when F<tools/build/ops2pm.pl> is called with the
C<--renum> flag, this method renumbers F<src/ops/ops.num> based on the already
existing file of that name and additional F<.ops> files.

=item * Arguments

String holding name of an F<.ops> file; defaults to
F<src/ops/ops.num>.  (Implicitly requires that the C<argv>,
C<script> and C<renum> elements were provided to the constructor.)

=item * Return Value

Returns true value upon success.

=item * Comment

When F<tools/build/ops2pm.pl> is called with the C<--renum> option, this
method is triggered, after which F<ops2pm.pl> exits.  Consequently, this is
the only Parrot::Ops2pm method which is I<not> a
stepping stone on the path to building F<lib/Parrot/OpLib/core.pm>.

=back

=cut

sub renum_op_map_file {
    my $self = shift;

    my $file = scalar(@_) ? shift : $self->{num_file};
    my ( $name, $number, @lines, %seen, %fixed, $fix );
    $fix = 1;
    open my $OP, '<', $file
        or die "Can't open $file, error $!";
    while (<$OP>) {
        push @lines, $_ if $fix;
        chomp;
        $fix = 0 if /^###DYNAMIC###/;
        s/#.*$//;
        s/\s*$//;
        s/^\s*//;
        next unless $_;
        ( $name, $number ) = split( /\s+/, $_ );
        $seen{$name} = $number;
        $fixed{$name} = $number if ($fix);
    }
    close $OP;
    open $OP, '>', $file
        or die "Can't open $file, error $!";
    print $OP @lines;
    my ($n);

    #
    # we can't use all autogenerated ops from oplib/core
    # there are unwanted permutations like 'add_i_ic_ic
    # which aren't opcodes but calced at compile-time
    #

    for ( @{ $self->{ops}->{OPS} } ) {
        if ( defined $fixed{ $_->full_name } ) {
            $n = $fixed{ $_->full_name };
        }
        elsif ( $seen{ $_->full_name } ) {
            printf $OP "%-31s%4d\n", $_->full_name, ++$n;
        }
    }
    close $OP;
    return 1;
}

=head1 AUTHOR

See F<tools/build/ops2pm.pl> for a list of the Parrot hackers who, over a
period of several years, developed the functionality now found in the methods
of Parrot::Ops2pm and Parrot::OpsRenumber.  Jim Keenan extracted that
functionality and placed it in this package's methods.

=cut

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
