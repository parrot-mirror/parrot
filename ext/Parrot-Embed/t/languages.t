#!perl

# Copyright (C) 2009, Parrot Foundation.
# $Id$

use strict;
use warnings;

use Test::More;
use File::Spec;

my $abc_pbc = File::Spec->catfile( '..', '..', 'examples', 'languages', 'abc', 'abc.pbc' );
plan skip_all => "Need to first run setup.pir in examples/languages/abc" unless -e $abc_pbc;

plan tests => 8;

use_ok('Parrot::Embed') or exit;

my $module = 'Parrot::Interpreter';
my $interp = $module->new();
ok( $interp, 'new() should return a valid interpreter' );
isa_ok( $interp, $module );

my $result = eval { $interp->load_file($abc_pbc) };
my $except = $@;
ok( $result,     '... returning true if it could load the file' );
is( $except, '', '... throwing no exception if so' );

my $abc = $interp->find_global( 'main', 'abc::Compiler' );
isa_ok( $abc, 'Parrot::PMC' );

my $pmc  = $abc->invoke('S->P', '2+3');
ok( $pmc, 'invoke() should return a PMC, given that signature' );
is( $pmc->get_string(), 1, 'value returned in the PMC' );

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
