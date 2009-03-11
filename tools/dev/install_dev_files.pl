#! perl -Ilib
################################################################################
# Copyright (C) 2001-2009, Parrot Foundation.
# $Id$
################################################################################

=head1 TITLE

tools/dev/install_dev_files.pl - Copy development files to their correct locations

=head1 SYNOPSIS

    % perl tools/dev/install_dev_files.pl [options]

=head1 DESCRIPTION

Use a detailed MANIFEST to install a set of development files.

=head2 Options

=over 4

=item C<buildprefix>

The build prefix. Defaults to ''.

=item C<prefix>

The install prefix. Defaults to '/usr'.

=item C<exec_prefix>

The exec prefix. Defaults to '/usr'.

=item C<bindir>

The executables directory. Defaults to '/usr/bin'.

=item C<libdir>

The library directory. Defaults to '/usr/lib'.

=item C<includedir>

The header directory. Defaults to '/usr/include'.

=back

=head2 See Also

See F<tools/dev/install_files.pl> for a detailed description of the MANIFEST
format.

=cut

################################################################################

use strict;
use warnings;
use File::Basename qw(basename);
use Parrot::Install;

# When run from the makefile, which is probably the only time this
# script will ever be used, all of these defaults will get overridden.
my %options = (
    buildprefix => '',
    prefix      => '/usr',
    destdir     => '',
    exec_prefix => '/usr',
    bindir      => '/usr/bin',
    libdir      => '/usr/lib',       # parrot/ subdir added below
    includedir  => '/usr/include',   # parrot/ subdir added below
    docdir      => '/usr/share/doc', # parrot/ subdir added below
    datadir     => '/usr/share/',    # parrot/ subdir added below
    srcdir      => '/usr/src/',      # parrot/ subdir added below
    'dry-run'   => 0,
    packages    => 'devel|pct|tge|nqp',
);

my @manifests;
foreach (@ARGV) {
    if (/^--([^=]+)=(.*)/) {
        $options{$1} = $2;
    }
    else {
        push @manifests, $_;
    }
}

my $parrotdir = $options{versiondir};

# Set up transforms on filenames
my(%metatransforms) = (
    lib => {
        optiondir => 'lib',
        transform => sub {
            my($dest) = @_;
            $parrotdir, "tools", $dest;
        },
    },
    share => {
        optiondir => 'data',
        transform => sub {
            my($dest) = @_;
            $parrotdir, basename($dest);
        },
    },
    include => {
        optiondir => 'include',
        transform => sub {
            my($dest) = @_;
            $dest =~ s/^src//; # strip off leading src/ dir
            $dest =~ s/^include//;
            $parrotdir, $dest;
        },
    },
    src => {
        optiondir => 'src',
        transform => sub {
            my($dest) = @_;
            $dest =~ s/^src//; # strip off leading src/ dir
            $parrotdir, $dest;
        },
    },
    doc => {
        optiondir => 'doc',
        transform => sub {
            my($dest) = @_;
            $dest =~ s/^docs/pod/; # other docs are actually raw Pod
            $parrotdir, $dest;
        },
    },
);

my(%othertransforms) = (
    '^(tools|VERSION)' => {
        optiondir => 'lib',
        transform => sub {
            my($dest) = @_;
            $parrotdir, $dest;
        },
    },
    '^compilers' => {
        optiondir => 'lib',
        transform => sub {
            my($dest) = @_;
            $dest =~ s/^compilers/languages/;
            $parrotdir, $dest;
        },
    },
);

my($files, $installable_exe, $directories) = Parrot::Install::lines_to_files(
    \%metatransforms, \%othertransforms, \@manifests, \%options, $parrotdir
);

unless ( $options{'dry-run'} ) {
    Parrot::Install::create_directories($options{destdir}, $directories);
}
Parrot::Install::install_files($options{destdir}, $options{'dry-run'}, @$files, @$installable_exe);

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
