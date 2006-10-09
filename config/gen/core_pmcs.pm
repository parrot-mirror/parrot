# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$

=head1 NAME

config/gen/core_pmcs.pm - Core PMC List

=head1 DESCRIPTION

Generates the core PMC list F<include/parrot/core_pmcs.h>.

=cut

package gen::core_pmcs;

use strict;
use warnings;

use base qw(Parrot::Configure::Step::Base);

use Parrot::Configure::Step ':gen';

our $description = 'Generating core pmc list';
our @args = ();

sub runstep
{
    my ($self, $conf) = @_;

    $self->generate_h($conf);
    $self->generate_c($conf);
    $self->generate_pm($conf);

    return $self;
}

sub generate_h
{
    my ($self, $conf) = @_;

    my $file = "include/parrot/core_pmcs.h";
    open(OUT, ">$file.tmp");

    print OUT <<"END_H";
/*
 * DO NOT EDIT THIS FILE
 *
 * Automatically generated by config/gen/core_pmcs.pm
 */

/* &gen_from_enum(pmctypes.pasm) subst(s/enum_class_(\\w+)/\$1/e) */
enum {
END_H

    my @pmcs = split(/ /, $conf->data->get('pmc_names'));
    print OUT "    enum_class_default,\n";
    my $i = 1;
    foreach (@pmcs) {
        print OUT "    enum_class_$_,\t/*  $i */ \n";
        $i++;
    }
    print OUT <<"END_H";
    enum_class_core_max
};

/* &end_gen */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
END_H

    close OUT;

    move_if_diff("$file.tmp", $file);

    return;
}

sub generate_c
{
    my ($self, $conf) = @_;

    my $file = "src/core_pmcs.c";
    my @pmcs = split(/ /, $conf->data->get('pmc_names'));

    open(OUT, ">$file.tmp");

    print OUT <<"END_C";
/*
 * DO NOT EDIT THIS FILE
 *
 * Automatically generated by config/gen/core_pmcs.pm
 */

#include "parrot/parrot.h"

END_C

    print OUT "extern void Parrot_${_}_class_init(Interp *, int, int);\n" foreach (@pmcs);

    print OUT <<"END_C";

void Parrot_register_core_pmcs(Interp *interp, PMC* registry);
extern void Parrot_initialize_core_pmcs(Interp *interp);
void Parrot_initialize_core_pmcs(Interp *interp)
{
    int pass;
    for (pass = 0; pass <= 1; ++pass) {
        /* first the PMC with the highest enum
         * this reduces MMD table resize action
         */
END_C

    print OUT "        Parrot_${_}_class_init(interp, enum_class_${_}, pass);\n" foreach (@pmcs[-1 .. -1]);
    print OUT "        Parrot_${_}_class_init(interp, enum_class_${_}, pass);\n"
        foreach (@pmcs[0 .. $#pmcs - 1]);
    print OUT <<"END_C";
        if (!pass) {
	    parrot_global_setup_2(interp);
        }
    }
}

static void register_pmc(Interp *interp, PMC* registry, int pmc_id)
{
    STRING* key = interp->vtables[pmc_id]->whoami;
    VTABLE_set_integer_keyed_str(interp, registry, key, pmc_id);
}

void
Parrot_register_core_pmcs(Interp *interp, PMC* registry)
{
END_C

    print OUT "    register_pmc(interp, registry, enum_class_$_);\n" foreach (@pmcs);
    print OUT <<'END_C';
}

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
END_C

    close OUT;

    move_if_diff("$file.tmp", $file);

    return;
}

sub generate_pm
{
    my ($self, $conf) = @_;

    my $file = "lib/Parrot/PMC.pm";
    my @pmcs = split(/ /, $conf->data->get('pmc_names'));

    open(OUT, ">$file.tmp");

    print OUT <<'END_PM';
# DO NOT EDIT THIS FILE
#
# Automatically generated by config/gen/core_pmcs.pm

package Parrot::PMC;

use strict;
use warnings;

use vars qw(@ISA %pmc_types @EXPORT_OK);

@ISA = qw( Exporter );
@EXPORT_OK = qw( %pmc_types);

%pmc_types = (
END_PM

    for my $num (0 .. $#pmcs) {
        my $id = $num + 1;
        print OUT "\t$pmcs[$num] => $id,\n";
    }

    print OUT <<'END_PM';
);

1;
END_PM

    close OUT;

    move_if_diff("$file.tmp", $file);

    return;
}

1;
