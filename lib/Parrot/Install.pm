package Parrot::Install;
# $Id$
use strict;
use warnings;
use File::Basename qw(dirname);
use File::Copy;
use base qw( Exporter );
our @EXPORT_OK = qw(
    install_files
    create_directories
    lines_to_files
);

# Install the mentioned files into the appropriate locations
sub install_files {
    my($destdir, $dryrun, @files) = @_;
    my($src, $dest, $mode);

    print("Installing ...\n");
    foreach ( @files ) {
        next unless $_;
        ( $src, $dest ) = @$_;
        $dest = $destdir . $dest;
        if ( $dryrun ) {
            print "$src -> $dest\n";
            next;
        }
        else {
            next unless -e $src;
            next if $^O eq 'cygwin' and -e "$src.exe"; # stat works, copy not
            copy( $src, $dest ) or die "copy $src to $dest: $!\n";
            print "$dest\n";
        }
        $mode = ( stat($src) )[2];
        chmod $mode, $dest;
    }
}

# Created the directories passed in
sub create_directories {
    my($destdir, $directories) = @_;
    my($dir, @dirs);

    for $dir ( map { $destdir . $_ } keys %$directories ) {
        unless ( -d $dir ) {

            # Make full path to the directory $dir
            while ( !-d $dir ) {    # Scan up to nearest existing ancestor
                unshift @dirs, $dir;
                $dir = dirname($dir);
            }
            foreach (@dirs) {
                -d or mkdir( $_, 0777 ) or die "mkdir $_: $!\n";
            }
        }
    }
}

# Suck in the lines from the mentioned manifests,
# and turn them into file locations.
sub lines_to_files {
    my($metatransforms, $othertransforms, $manifests, $options, $parrotdir) = @_;
    my @files;
    my @installable_exe;
    my %directories;
    my $tkey;

    # We'll report multiple occurrences of the same file
    my(%seen);

    @ARGV = @$manifests;
    LINE: while (<>) {
        chomp;

        s/\#.*//;    # Ignore comments
        next if /^\s*$/;    # Skip blank lines

        my ( $src, $meta, $dest ) = split( /\s+/, $_ );
        $dest ||= $src;

        if ( $seen{$src}++ ) {
            print STDERR "$ARGV:$.: Duplicate entry $src\n";
        }

        # Parse out metadata
        die "Malformed line in MANIFEST: $_" if not defined $meta;
        my $generated = $meta =~ s/^\*//;
        my ($package) = $meta =~ /^\[(.*?)\]/;
        $meta =~ s/^\[(.*?)\]//;
        next unless $package;    # Skip if this file belongs to no package

        my($plist) = $options->{packages};
        next unless $package =~ /$plist/;

        my %meta;
        @meta{ split( /,/, $meta ) } = ();
        $meta{$_} = 1 for ( keys %meta );          # Laziness

        FIXFILE: {
            # Have to catch this case early for some unknown reason
            if ( /^runtime/ ) {
                $dest =~ s/^runtime\/parrot\///;
                $dest = File::Spec->catdir(
                    $options->{libdir}, $parrotdir, $dest
                );
                last FIXFILE;
            }

            my($copy);
            foreach $tkey (keys %$metatransforms) {
                if ( $meta{$tkey} ) {
                    $copy = $dest; # only needed for installable
                    $dest = File::Spec->catdir(
                        $options->{$metatransforms->{$tkey}->{optiondir} . 'dir'},
                        &{ $metatransforms->{$tkey}->{transform} }($dest)
                    );
                    if ( $metatransforms->{$tkey}->{isbin}
                            and
                        $copy =~ /^installable/
                    ) {
                        push @installable_exe, [ $src, $dest ];
                        next LINE;
                    }
                    last FIXFILE;
                }
            }

            foreach $tkey (keys %$othertransforms) {
                if ( /$tkey/ ) {
                    $dest = File::Spec->catdir(
                        $options->{$othertransforms->{$tkey}->{optiondir} . 'dir'},
                        &{ $othertransforms->{$tkey}->{transform} }($dest)
                    );
                    last FIXFILE;
                }
            }
            die "Unknown install location in MANIFEST: $_";
        }

        $dest = File::Spec->catdir( $options->{buildprefix}, $dest )
            if $options->{buildprefix};

        $directories{ dirname($dest) } = 1;
        push( @files, [ $src => $dest ] );
    }
    continue {
        close ARGV if eof;    # Reset line numbering for each input file
    }

    return(\@files, \@installable_exe, \%directories);
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
