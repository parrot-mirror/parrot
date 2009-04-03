#! perl
# Copyright (C) 2007, Parrot Foundation.
# $Id$
# 01-install_files.t

use strict;
use warnings;

use Test::More qw(no_plan); # tests =>  5;
use Carp;
use File::Temp qw( tempdir );
use lib qw( lib );
use File::Temp qw/ tempdir /;
use Parrot::Install qw(
    install_files
    create_directories
    lines_to_files
);
use IO::CaptureOutput qw( capture );

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

01-install_files.t - test subroutines exported by C<Parrot::Install>

=head1 SYNOPSIS

    % prove t/tools/install/01-install_files.t

=head1 DESCRIPTION

The files in this directory test functionality used by
F<tools/dev/install_files.pl> and F<tools/dev/install_dev_files.pl> and
exported by F<lib/Parrot/Install.pm>.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Install, F<tools/dev/install_files.pl>, F<tools/dev/install_dev_files.pl>

=cut

{
    my $dir = tempdir( CLEANUP => 1 );
    $dir .= '/';

    my @dirs = qw(foo/bar foo/bar/baz);
    create_directories($dir, { map { $_ => 1 } @dirs });
    my($fullname);
    my $dirs_created = 0;
    foreach my $d (@dirs) {
        $dirs_created++ if -d "$dir$d";
    }
    is($dirs_created, 2, 'got expected number of directories created');
}

{
    my($dir) = tempdir( CLEANUP => 1 );
    $dir .= '/';

    my(@dirs) = qw(foo/bar foo/bar/baz);
    create_directories($dir, { map { $_ => 1 } @dirs });
    my($fullname);
    foreach(@dirs) {
        $fullname = $dir . $_;
        -d $fullname or croak "create_directories didn't create directory '$fullname'";
    }
    ok(1, 'create_directories passed all tests');

    my($testdir) = $dirs[0];
    my(@files) = ['README', "$testdir/README"];

    install_files($dir, 1, @files);
    foreach(@files) {
        $fullname = $dir . $_->[1];
        -f "$fullname" and croak "install_files installed file '$fullname' in a dry run";
    }
    ok(1, 'install_files passed dry-run test');
    
    install_files($dir, 0, @files);
    foreach(@files) {
        $fullname = $dir . $_->[1];
        -f "$fullname" or croak "install_files didn't install file '$fullname'";
    }
    ok(1, 'install_files passed all tests');
}

## Can't safely run lines_to_files() more than once in a program until it's been fixed, 
## and we can't fix it until its tested, so I've commented most of these out until we've
## fixed lines_to_files() not to use @ARGV
{
    my($metatransforms, $othertransforms, $manifests, $options, $parrotdir,
        $files, $installable_exe, $directories);

    # First lines_to_files test
#    eval { lines_to_files(); };
#    $@ or die "lines_to_files didn't die with no parameters\n";
#    ok($@ =~ /^.manifests must be an array reference$/, 'lines_to_files dies with bad parameters');

    # Second lines_to_files test
#    eval { lines_to_files(
#        $metatransforms, $othertransforms, 
#        [qw(MANIFEST MANIFEST.generated)], 
#        $options, $parrotdir
#    ); };
#    ok($@ =~ /^Unknown install location in MANIFEST for file/, 'fails for install locations not specified in transforms');

    # Third lines_to_files test
    $metatransforms = {
        doc => {
            optiondir => 'doc',
            transform => sub {
                my($dest) = @_;
                $dest =~ s/^docs\/resources/resources/; # resources go in the top level of docs
                $dest =~ s/^docs/pod/; # other docs are actually raw Pod
                $parrotdir, $dest;
            },
        },
    };
    $othertransforms = {
        '.*' => {
            optiondir => 'foo',
            transform => sub {
                return(@_);
            }
        }
    };

    ($files, $installable_exe, $directories) = lines_to_files(
        $metatransforms, $othertransforms, 
        [qw(MANIFEST MANIFEST.generated)], 
        { packages => 'main' }, $parrotdir
    );
    ok((ref($files) and ref($installable_exe) and ref($directories)), 'lines_to_files returns something vaguely sensible');
    ok(1, 'lines_to_files passed all tests');
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
