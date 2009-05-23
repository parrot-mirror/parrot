#! perl
# Copyright (C) 2007-2008, Parrot Foundation.
# $Id$
# overall.t

use strict;
use warnings;
#use Data::Dumper;$Data::Dumper::Indent = 1;
use Test::More tests =>  4;
use Carp;
use Cwd;
use File::Basename;
use File::Copy;
use File::Path qw( mkpath );
use File::Spec ();
use File::Temp qw( tempdir );
use lib qw( lib );
use Parrot::Config qw( %PConfig );
use IO::CaptureOutput qw( capture );

my $DEBUG = 0;

my $cwd = cwd();
my $installer = File::Spec->catfile( 'tools', 'dev', 'install_files.pl' );
my $full_installer = File::Spec->catfile( $cwd, $installer );
ok(-f $full_installer, "Able to locate $installer");

my $testlibdir = File::Spec->catdir( qw| t tools install testlib | );
my $man_pseudo = File::Spec->catfile( $testlibdir, q|manifest_pseudo| );
my $full_man_pseudo = File::Spec->catfile( $cwd, $man_pseudo );
my $gen_pseudo = File::Spec->catfile( $testlibdir, q|generated_pseudo| );
my $full_gen_pseudo = File::Spec->catfile( $cwd, $gen_pseudo );

{
    my $builddir    = tempdir( CLEANUP => 1 );
    my $prefixdir   = tempdir( CLEANUP => 1 );
    if ($DEBUG) {
        print STDERR "$builddir\n$prefixdir\n";
    }

    my $includedir = File::Spec->catdir( $prefixdir, 'include' );
    my $libdir = File::Spec->catdir( $prefixdir, 'lib' );
    my $docdir = File::Spec->catdir( $prefixdir, 'share', 'doc' );
    my $versiondir = $PConfig{versiondir};

    my %testfiles = (
        'LICENSE'                 => {
            start   => File::Spec->catfile( qw| . LICENSE | ),
            end     => File::Spec->catfile(
                        $docdir, $versiondir, 'LICENSE' )
        },
        'docs/gettingstarted.pod' => {
            start   => File::Spec->catfile( qw| . docs gettingstarted.pod | ),
            end     => File::Spec->catfile(
                        $docdir,  $versiondir, 'pod', 'gettingstarted.pod' ),
        },
        'include/parrot/charset.h' => {
            start   => File::Spec->catfile( qw| . include parrot charset.h | ),
            end     => File::Spec->catfile(
                        $includedir, $versiondir, 'parrot', 'charset.h' ),
        },
        'runtime/parrot/include/sockets.pasm' => {
            start   => File::Spec->catfile( qw| . runtime parrot include sockets.pasm | ),
            end     => File::Spec->catfile(
                        $libdir, $versiondir, 'include', 'sockets.pasm' ),
        },
    );
    chdir $builddir or croak "Unable to change to tempdir for testing: $!";
    my $man_quasi = File::Spec->catfile( $builddir, 'MANIFEST' );
    my $gen_quasi = File::Spec->catfile( $builddir, 'MANIFEST.generated' );
    copy $full_man_pseudo => $man_quasi
        or croak "Unable to copy $man_pseudo for testing:  $!";
    copy $full_gen_pseudo => $gen_quasi
        or croak "Unable to copy $gen_pseudo for testing: $!";

    my @dirs_needed = qw(
        src
        docs
        include/parrot
        runtime/parrot/include
    );
    my @created =
        mkpath( map { File::Spec->catdir( $builddir, $_ ) } @dirs_needed );
    print STDERR "dirs created:  @created\n" if $DEBUG;
    foreach my $f ( keys %testfiles ) {
        my $src = File::Spec->catfile( $cwd, $testlibdir, $f );
        my $des = File::Spec->catfile( $builddir, $testfiles{$f}{start} );
        copy $src, $des or croak "Unable to copy $f for testing: $!";
    }
    my $cmd = qq{$^X $full_installer --prefix=$prefixdir};
    $cmd .= qq{ --includedir=$includedir};
    $cmd .= qq{ --libdir=$libdir};
    $cmd .= qq{ --versiondir=$versiondir};
    $cmd .= qq{ --docdir=$docdir};
    $cmd .= qq{ MANIFEST MANIFEST.generated};
    my ($stdout, $stderr);
    capture(
        sub {
            system( $cmd ) and croak "Unable to execute $installer: $!";
        },
        \$stdout,
        \$stderr,
    );
    like( $stdout, qr/^Installing/, "Got expected standard output" );
    my $seen = 0;
    foreach my $f ( keys %testfiles ) {
        my $des = $testfiles{$f}{end};
        print STDERR "wanted:  $des\n" if $DEBUG;
        $seen++ if -f $des;
    }
    is( $seen, scalar keys %testfiles,
        "Got all $seen expected files in installation" );

    chdir $cwd
        or croak "Unable to return to top-level directory after testing: $!";
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

overall.t - test tools/dev/install_files.pl

=head1 SYNOPSIS

    % prove t/tools/install/overall.t

=head1 DESCRIPTION

This file simulates the operation of F<tools/dev/install_files.pl> and
sanity-checks the results.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

F<tools/dev/install_files.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
