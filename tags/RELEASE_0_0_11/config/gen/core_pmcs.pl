package Configure::Step;

use strict;
use vars qw($description @args);
use Parrot::Configure::Step ':gen';

$description="Generating core pmc list...";

@args=();

sub runstep {
    generate_h();
    generate_c();
    generate_pm();
}

sub generate_h {
    my $file = "include/parrot/core_pmcs.h";
    open(OUT, ">$file.tmp");

    print OUT <<"END";
/*
 * DO NOT EDIT THIS FILE
 *
 * Automatically generated by config/gen/core_pmcs.pl
 */

/* &gen_from_enum(pmctypes.pasm) subst(s/enum_class_(\\w+)/\$1/e) */
enum {
END

    my @pmcs = split(/ /, Configure::Data->get('pmc_names'));
    print OUT "    enum_class_default,\n";
    print OUT "    enum_class_$_,\n" foreach (@pmcs);
    print OUT <<"END";
    enum_class_core_max
};

/* &end_gen */
END

    close OUT;

    move_if_diff("$file.tmp", $file);
}

sub generate_c {
    my $file = "core_pmcs.c";
    my @pmcs = split(/ /, Configure::Data->get('pmc_names'));

    open(OUT, ">$file.tmp");

    print OUT <<"END";
/*
 * DO NOT EDIT THIS FILE
 *
 * Automatically generated by config/gen/core_pmcs.pl
 */

#include "parrot/parrot.h"

END

    print OUT "extern void Parrot_${_}_class_init(Interp *, int);\n"
      foreach (@pmcs);

    print OUT <<"END";

extern void Parrot_initialize_core_pmcs(Interp *interp);
void Parrot_initialize_core_pmcs(Interp *interp)
{
END

    print OUT "    Parrot_${_}_class_init(interp, enum_class_${_});\n"
      foreach (@pmcs);
    print OUT <<"END";
}

static void register_pmc(Interp *interp, PMC* registry, int pmc_id)
{
    PMC* key;
    key = key_new_string(interp, Parrot_base_vtables[pmc_id].whoami);
    VTABLE_set_integer_keyed(interp, registry, key, pmc_id);
}

extern void Parrot_register_core_pmcs(Interp *interp, PMC* registry);
void Parrot_register_core_pmcs(Interp *interp, PMC* registry)
{
END

    print OUT "    register_pmc(interp, registry, enum_class_$_);\n"
      foreach (@pmcs);
    print OUT <<"END";
}
END

    close OUT;

    move_if_diff("$file.tmp", $file);
}

sub generate_pm {
    my $file = "lib/Parrot/PMC.pm";
    my @pmcs = split(/ /, Configure::Data->get('pmc_names'));

    open(OUT, ">$file.tmp");

    print OUT <<'END';
# DO NOT EDIT THIS FILE
#
# Automatically generated by config/gen/core_pmcs.pl

package Parrot::PMC;
use vars qw(@ISA %pmc_types @EXPORT_OK);

@ISA = qw( Exporter );
@EXPORT_OK = qw( %pmc_types);

%pmc_types = (
END

    for my $num (0..$#pmcs) {
	my $id = $num+1;
        print OUT "\t$pmcs[$num] => $id,\n";
    }

    print OUT <<"END";
);

1;
END

    close OUT;

    move_if_diff("$file.tmp", $file);
}

1;
