#!perl
# Copyright (C) 2008, The Perl Foundation.
# $Id$

use strict;
use warnings;
use 5;
use lib qw(t . lib ../lib ../../lib ../../../lib);

use Data::Dumper;
use Test::More tests => 1;

use Parrot::Test::Util 'create_tempfile';
use Parrot::Config;

=head1 NAME

pct/complete_workflow.t - PCT tests

=head1 SYNOPSIS

    $ prove t/compilers/pct/complete_workflow.t

=head1 DESCRIPTION

This is a test script to try out constructing a grammar from a 
grammar syntax file. After that is attempted to add acctions
from a NQP class file. After that the generated compiler is tested.
Special cases in grammars and actions should also be tested.

=cut

# Do not assume that . is in $PATH
# places to look for things
my $BUILD_DIR     = $PConfig{build_dir};
my $TEST_DIR      = "$BUILD_DIR/t/compilers/pct";
my $PARROT        = "$BUILD_DIR/parrot$PConfig{exe}";
my $PERL5         = $PConfig{perl};
my $PARROT_DYNEXT = "$BUILD_DIR/runtime/parrot/dynext";
my $PGE_LIBRARY   = "$BUILD_DIR/runtime/parrot/library/PGE";
my $PERL6GRAMMAR  = "$PGE_LIBRARY/Perl6Grammar.pbc";
my $NQP           = "$BUILD_DIR/compilers/nqp/nqp.pbc";
my $PCT           = "$BUILD_DIR/runtime/parrot/library/PCT.pbc";

# set up a file with the grammar
#my ($PG, $pg_fn) = create_tempfile( SUFFIX => '.pg', DIR => $TEST_DIR );
my ($PG, $pg_fn) = create_tempfile( SUFFIX => '.pg', DIR => cwd(), UNLINK => 1 );
print $PG <<'END_PG';
# DO NOT EDIT.
# This file was generated by t/compilers/pct/complete_workflow.t

grammar TestGrammar;

token apply { ^<op>$ }
token op    { test <?ws> <val> <?ws> }
token val   { thingy }
END_PG

ok( 'dummy' );
#diag( Dumper( \%PConfig ) );





=head1 AUTHOR

Bernhard Schmalhofer <Bernhard.Schmalhofer@gmx.de>

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
