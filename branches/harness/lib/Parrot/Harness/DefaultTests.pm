# Copyright (C) 2006-2007, The Perl Foundation.
# $Id$

=head1 NAME

Parrot::Harness::DefaultTests - Tests run by default by F<t/harness>

=head1 DESCRIPTION

This file exports a single subroutine, C<get_default_tests()>, which is the
list of tests run by F<t/harness> by default.

C<get_default_tests()> in list context returns the list of default tests.  In
scalar context it returns a reference to that list.

=cut

package Parrot::Harness::DefaultTests;
use strict;
use lib qw( . lib ../lib ../../lib );
use FindBin qw/$Bin/;
use base qw( Exporter );
our @EXPORT = qw( get_default_tests );

sub get_default_tests {
    my ($core_tests_only, $runcore_tests_only) = @_;

    # runcore tests are always run.
    my @runcore_tests = qw(
        t/compilers/imcc/*/*.t
        t/op/*.t
        t/pmc/*.t
        t/oo/*.t
        t/native_pbc/*.t
        t/dynpmc/*.t
        t/dynoplibs/*.t
        t/compilers/pge/*.t
        t/compilers/pge/p5regex/*.t
        t/compilers/pge/perl6regex/*.t
        t/compilers/tge/*.t
        t/library/*.t
    );
    
    # core tests are run unless --runcore-tests is present.  Typically
    # this list and the list above are run in response to --core-tests
    my @core_tests = qw(
        t/run/*.t
        t/src/*.t
        t/tools/*.t
        t/perl/*.t
        t/stm/*.t
    );
    
    # configure tests are tests to be run at the beginning of 'make test';
    # standard tests are other tests run by default with no core options
    # present
    my @configure_tests = qw( t/configure/*.t t/steps/*.t t/postconfigure/*.t );
    my @standard_tests = qw(
        t/compilers/json/*.t
        t/examples/*.t
        t/doc/*.t
        t/distro/manifest.t
    );
    
    # add metadata.t and coding standards tests only if we're DEVELOPING
    if ( -e "$Bin/../DEVELOPING" ) {
        push @standard_tests, 't/distro/file_metadata.t';
        push @standard_tests, map { "t/codingstd/$_" } qw(
            c_code_coda.t
            c_header_guards.t
            c_indent.t
            c_struct.t
            check_toxxx.t
            copyright.t
            cppcomments.t
            cuddled_else.t
            filenames.t
            gmt_utc.t
            linelength.t
            pccmethod_deps.t
            pir_code_coda.t
            svn_id.t
            tabs.t
            trailing_space.t
        );
        # XXX: This takes WAY too long to run: perlcritic.t
    }

    # build the list of default tests
    my @default_tests = @runcore_tests;
    unless ($runcore_tests_only) {
       push @default_tests, @core_tests;
       unless ($core_tests_only) {
           unshift @default_tests, @configure_tests;
           push @default_tests, @standard_tests;
       }
    }
    wantarray
        ? return @default_tests
        : return [ @default_tests ];
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

