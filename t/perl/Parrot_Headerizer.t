#! perl
# Copyright (C) 2001-2009, Parrot Foundation.
# $Id$

use strict;
use warnings;
use lib qw( lib );

use Cwd;
use Parrot::Distribution;
use Test::More qw(no_plan); # tests => 26;

=head1 NAME

t/perl/Parrot_Headerizer.t - Parrot::Headerizer unit tests

=head1 SYNOPSIS

    % prove t/perl/Parrot_Headerizer.t

=head1 DESCRIPTION

Test individual Parrot::Headerizer methods.

=cut

BEGIN { use_ok('Parrot::Headerizer') }

my $headerizer = Parrot::Headerizer->new();
isa_ok( $headerizer, 'Parrot::Headerizer' );
ok( $headerizer->valid_macro( 'PARROT_CAN_RETURN_NULL' ),
    'valid macro reported' );
ok( ! $headerizer->valid_macro( 'IMAGINARY_MACRO_FOO_BAR_BAZ' ),
    'invalid macro reported' );
my @valid_macros = $headerizer->valid_macros();
ok( @valid_macros, 'sanity check: at least one valid macro exists' );

my $DIST = Parrot::Distribution->new;
my $cwd = cwd();
my $path = qq|$cwd/t/perl/testlib/dummy_imcc.y|;
my $buf = $DIST->slurp($path);
#print STDERR $buf;
my @function_decls = $headerizer->extract_function_declarations($buf);

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
