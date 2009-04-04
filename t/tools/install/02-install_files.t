#! perl
# Copyright (C) 2007, Parrot Foundation.
# $Id$
# 02-install_files.t

use strict;
use warnings;

use Test::More tests => 11;
use Carp;
use File::Path qw( mkpath );
use File::Temp qw( tempdir );
use lib qw( lib );
use Parrot::Install qw(
    install_files
    create_directories
);
use IO::CaptureOutput qw( capture );

{
    my $tdir = tempdir( CLEANUP => 1 );
    $tdir .= '/';

    my @dirs = qw(foo/bar foo/bar/baz);
    create_directories($tdir, { map { $_ => 1 } @dirs });
    my($fullname);

    my @files = ( ['README', "$dirs[0]/README"] );

    {
        my ( $stdout, $stderr, $rv );
        capture(
            sub { $rv = install_files($tdir, 1, @files); },
            \$stdout,
            \$stderr,
        );
        ok( $rv, 'install_files() completed successfully in dry-run case' );
    
        my $files_created = 0;
        foreach my $el (@files) {
            $files_created++ if -f "$tdir$el->[1]";
        }
        is( $files_created, 0, 'dry-run, so no files created' );

        like( $stdout, qr/Installing.*README.*README/s,
            'got expected installation message' );
    }

    {
        my ( $stdout, $stderr, $rv );
        capture(
            sub { $rv = install_files($tdir, 0, @files); },
            \$stdout,
            \$stderr,
        );
        ok( $rv, 'install_files() completed successfully in production case' );
    
        my $files_created = 0;
        foreach my $el (@files) {
            $files_created++ if -f "$tdir$el->[1]";
        }
        is( $files_created, 1, 'production, so 1 file created' );

        like( $stdout, qr/Installing.*README/s,
            'got expected installation message' );
    }
}

{
    my $tdir = tempdir( CLEANUP => 1 );
    $tdir .= '/';

    my @dirs = qw(foo/bar foo/bar/baz);
    create_directories($tdir, { map { $_ => 1 } @dirs });
    my($fullname);

    # Case where element in @files is not an array ref
    my @files = ( q{} );

    {
        my ( $stdout, $stderr, $rv );
        capture(
            sub { $rv = install_files($tdir, 0, @files); },
            \$stdout,
            \$stderr,
        );
        ok( $rv, 'install_files() handled invalid argument as expected' );
    
        like( $stdout, qr/Installing \.\.\./, 
            'got expected installation message' );
    }
}

{
    my $tdir = tempdir( CLEANUP => 1 );
    $tdir .= '/';

    my @dirs = qw(foo/bar foo/bar/baz);
    create_directories($tdir, { map { $_ => 1 } @dirs });
    my($fullname);

    # Case where element in @files does not hold existent file
    my $nonexistent = q{ajdpfadksjfjvjkvds} . $$;
    my @files = ( [ $nonexistent, "$dirs[0]/$nonexistent"] );

    {
        my ( $stdout, $stderr, $rv );
        capture(
            sub { $rv = install_files($tdir, 0, @files); },
            \$stdout,
            \$stderr,
        );
        ok( $rv, 'install_files() handled non-existent file as expected' );
    
        like( $stdout, qr/Installing \.\.\./, 
            'got expected installation message' );
    }
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

02-install_files.t - test subroutines exported by C<Parrot::Install>

=head1 SYNOPSIS

    % prove t/tools/install/02-install_files.t

=head1 DESCRIPTION

The files in this directory test functionality used by
F<tools/dev/install_files.pl> and F<tools/dev/install_dev_files.pl> and
exported by F<lib/Parrot/Install.pm>.

=head1 AUTHOR

James E Keenan and Timothy S Nelson

=head1 SEE ALSO

Parrot::Install, F<tools/dev/install_files.pl>, F<tools/dev/install_dev_files.pl>

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
