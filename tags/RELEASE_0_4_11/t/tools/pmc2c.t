#! perl
# Copyright (C) 2005, The Perl Foundation.
# $Id$

=head1 NAME

t/tools/pmc2c.t - test the PMC to C generator

=head1 SYNOPSIS

    % prove t/tools/pmc2c.t

=head1 DESCRIPTION

Tests the C<pmc2c> utility by providing it with a number of source
pmc files, having it generate the resulting C file and verifying
the output.

We never actually check the *full* output of the conversion.
We simply check several smaller components to avoid a test file
that is far too unwieldy.

=cut

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );

use Fatal qw{open close};
use Test::More;
use Parrot::Test tests => 11;
use Parrot::Config;

my $pmc2c = join $PConfig{slash}, qw(. tools build pmc2c.pl);

sub pmc2c_output_like {
    my ($pmc)  = shift;
    my ($c)    = shift;
    my ($name) = shift;

    my $c_file = pmc_to_c($pmc);

    open my $c_fh, '<', $c_file;
    my $c_output = do { local $/ = undef; <$c_fh> };
    close $c_fh;

    unless ( ref $c ) {
        chomp $c;
        $c = qr{\Q$c\E};
    }

    like( $c_output, $c, $name );
}

{
    my $counter = 0;

    sub pmc_to_c {
        my $pmc = shift;

        $counter++;

        my $pmc_file = "$0_$counter.pmc";
        open my $fh, '>', $pmc_file;
        print {$fh} $pmc;
        close $fh;

        system("$^X $pmc2c --dump $pmc_file");
        system("$^X $pmc2c -c $pmc_file");

        my $c_file = $pmc_file;
        $c_file =~ s/\.pmc$/\.c/;

        return $c_file;
    }

}

pmc2c_output_like( <<'END_PMC', qr{DO NOT EDIT THIS FILE}, 'no edit warning' );
pmclass a { }
END_PMC

pmc2c_output_like( <<'END_PMC', qr{#line 1 ".*\.pmc"\n}, 'initial line numbering' );
pmclass a { }
END_PMC

pmc2c_output_like( <<'END_PMC', <<'END_C', 'includes' );
pmclass a { }
END_PMC
#include "parrot/parrot.h"
#include "parrot/extend.h"
#include "parrot/dynext.h"
#include "pmc_a.h"
#include "pmc_default.h"
#include "a.str"
END_C

pmc2c_output_like( <<'END_PMC', <<'END_C', 'class initialization' );
pmclass a { }
END_PMC
void
Parrot_a_class_init(Parrot_Interp interp, int entry, int pass)
{
    const VTABLE temp_base_vtable = {
END_C

pmc2c_output_like( <<'END_PMC', <<'END_C', 'comment passthrough' );
pmclass a { }
/* passthrough */
END_PMC
/* passthrough */
END_C

pmc2c_output_like( <<'END_PMC', <<'END_C', 'pod passthrough' );
pmclass a { }

=for naught

Documentation

=cut
END_PMC
=for naught

Documentation

=cut
END_C

pmc2c_output_like( <<'END_PMC', <<'END_C', 'does' );
pmclass a does nothing { }
END_PMC
vt_clone->does_str = CONST_STRING(interp, "nothing");
END_C

pmc2c_output_like( <<'END_PMC', <<'END_C', 'need_ext' );
pmclass a need_ext { }
END_PMC
    const VTABLE temp_base_vtable = {
        NULL, /* namespace */
        enum_class_a, /* base_type */
        NULL, /* whoami */
        0|VTABLE_PMC_NEEDS_EXT|VTABLE_HAS_READONLY_FLAG, /* flags */
END_C

pmc2c_output_like( <<'END_PMC', <<'END_C', 'const_too 1' );
pmclass a const_too { }
END_PMC
void
Parrot_a_class_init(Parrot_Interp interp, int entry, int pass)
{
    const VTABLE temp_base_vtable = {
        NULL, /* namespace */
        enum_class_a, /* base_type */
        NULL, /* whoami */
        VTABLE_HAS_CONST_TOO, /* flags */
END_C

pmc2c_output_like( <<'END_PMC', <<'END_C', 'const_too 2' );
pmclass a const_too { }
END_PMC
void
Parrot_Consta_class_init(Parrot_Interp interp, int entry, int pass)
{
    const VTABLE temp_base_vtable = {
        NULL, /* namespace */
        enum_class_Consta, /* base_type */
        NULL, /* whoami */
        VTABLE_IS_CONST_FLAG, /* flags */
END_C

pmc2c_output_like( <<'END_PMC', <<'END_C', 'maps' );
pmclass a hll dale maps Integer { }
END_PMC
            INTVAL pmc_id = Parrot_get_HLL_id(
                interp, const_string(interp, "dale")
            );
            if (pmc_id > 0)
                Parrot_register_HLL_type(
                    interp, pmc_id, enum_class_Integer, entry
                );
END_C

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
