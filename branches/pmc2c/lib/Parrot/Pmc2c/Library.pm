# Copyright (C) 2004-2006, The Perl Foundation.
# $Id$

=head1 NAME

Parrot::Pmc2c::Library - PMC to C Code Generation

=head1 SYNOPSIS

    use Parrot::Pmc2c::Library;

=head1 DESCRIPTION

Parrot::Pmc2c::Library is a wrapper around a collection of PMCs linked in the
same dynamic library. A degenerate case is having an unnamed library with just
one PMC, which is the case used by the Parrot core. See L<Parrot::Pmc2c>

=head2 Instance Methods

=over 4

=cut

package Parrot::Pmc2c::Library;

use strict;
use warnings;
use Data::Dumper;
use Parrot::Pmc2c::PMCEmitter;
use Parrot::Pmc2c::UtilFunctions qw(dont_edit dynext_load_code c_code_coda spew);

=item C<new($opt, $vtable_dump, %pmcs)>

    $library = Parrot::Pmc2c::Library->new
        ( $options,     # hash refernce, the same passed to other constructors
          $vtable_dump, # vtable.dump
          pmc1        => $pmc1_dump,
          pmc2        => $pmc2_dump,
          ... );

Creates a new library object. If the C<$options> hash contains a
C<library> key its value will be used for the library name.

=cut

sub new {
    my ( $class, $opt, $vtable_dump, %pmcs ) = @_;
    my %emitters;

    foreach my $pmc ( values %pmcs ) {
        $emitters{$pmc->filename} = Parrot::Pmc2c::PMC->prep_for_emit($pmc, $vtable_dump);
    }

    return bless {
        opt  => $opt,
        pmcs => \%pmcs,
        emitters=> \%emitters,
    }, $class;
}

sub generate_library($$) {
    my ( $self, $library_name ) = @_;
    my $h_name  = "$library_name.h";
    my $c_name  = "$library_name.c";

    my $cout = $self->gen_c;
    spew($c_name, $cout);

    my $hout = $self->gen_h;
    spew($h_name, $hout);
}

=item C<write_all_files()>

Writes C and header files for all the PMCs in the library,
I<or> E<lt>libnameE<gt>.c and pmc_E<lt>libnameE<gt>.h if his object
represents a named library.

=cut

sub write_all_files {
    my $self    = shift;
    my $library_name = $self->{opt}{library};

    if ($library_name) {
        generate_library($self, $library_name);
    }
    else {
        for my $emitter ( values %{ $self->{emitters} } ) {
            $emitter->generate;
        }
    }
}

=item C<gen_h>

Writes the header file for the library.

=cut

sub gen_h {
    my ($self)     = @_;
    my $hout       = dont_edit('various files');
    my $lc_libname = lc $self->{opt}{library};

    $hout .= <<"EOH";
Parrot_PMC Parrot_lib_${lc_libname}_load(Parrot_Interp interp);
EOH
    $hout .= $self->c_code_coda;

    return $hout;
}

=item C<gen_c>

Writes the C file for the library.

=cut

sub gen_c {
    my ($self) = @_;
    my $cout = dont_edit('various files');

    $cout .= <<"EOC";
#define PARROT_IN_EXTENSION
#include "parrot/parrot.h"
#include "parrot/extend.h"
#include "parrot/dynext.h"
EOC
    
    foreach my $pmc ( values %{ $self->{pmcs} } ) {
        my $name = lc $pmc->{name};
        $cout .= <<"EOC";
#include "pmc_$name.h"
EOC
    }
    $cout .= "\n";
    $cout .= dynext_load_code( $self->{opt}{library},
        map { $_->{name} => $_ } values %{ $self->{pmcs} } );
    $cout .= $self->c_code_coda;

    return $cout;
}

=back

=head1 SEE ALSO

=over 4

=item F<tools/build/pmc2c.pl>

=back

=cut

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
