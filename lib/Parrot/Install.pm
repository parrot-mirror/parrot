package Parrot::Install;
# $Id$
use strict;
use warnings;
use File::Basename qw(dirname);
use File::Copy;
use File::Spec;
use base qw( Exporter );
our @EXPORT_OK = qw(
    lines_to_files
    create_directories
    install_files
);

#################### DOCUMENTATION ####################

=head1 NAME

Parrot::Install - Functionality for installation programs

=head1 SYNOPSIS

    use Parrot::Install qw(
        install_files
        create_directories
        lines_to_files
    );

=head1 DESCRIPTION

This module exports on demand only three subroutines used in the Parrot
installation programs F<tools/dev/install_files.pl> and
F<tools/dev/install_dev_files.pl>.  The subroutines are tested by tests found
in F<t/tools/install/>.

=head1 SUBROUTINES

=head2 C<lines_to_files()>

B<Purpose:> Suck in the lines from the mentioned manifests, and turn them into
file locations.

B<Arguments:> List of five scalars.

    ($files, $installable_exe, $directories) =
        lines_to_files(
            \%metatransforms,
            \%othertransforms,
            \@manifests,
            \%options,
            $parrotdir,
        );

B<Return Value:> List of three scalars.

B<Comment:>

=cut

sub lines_to_files {
    my ($metatransforms, $othertransforms, $manifests_ref, 
        $options_ref, $parrotdir) = @_;
    my @files;
    my @installable_exe;
    my %directories;

    # We'll report multiple occurrences of the same file
    my(%seen);

    ref($manifests_ref) eq 'ARRAY'
        or die "Manifests must be listed in an array reference: $!";
    @{ $manifests_ref } > 0 or die "No manifests specified";
    @ARGV = @{ $manifests_ref };
    LINE: while ( my $entry = <> ) {
        chomp $entry;

        $entry =~ s/\#.*//;    # Ignore comments
        next if $entry =~ /^\s*$/;    # Skip blank lines

        my ( $src, $meta, $dest ) = split( /\s+/, $entry );
        $dest = $src unless $dest;

        if ( $seen{$src}++ ) {
            print STDERR "$ARGV:$.: Duplicate entry $src\n";
        }

        # Parse out metadata
        die "Malformed line in MANIFEST: $entry" if not defined $meta;
        my $generated = $meta =~ s/^\*//;
        my ($package) = $meta =~ /^\[(.*?)\]/;
        $meta =~ s/^\[(.*?)\]//;
        next unless $package;    # Skip if this file belongs to no package

        my $plist = defined ( $options_ref->{packages})
            ? $options_ref->{packages}
            : '.*';
        next unless $package =~ /$plist/;

        my %metadata;
        @metadata{ split( /,/, $meta ) } = ();
        $metadata{$entry} = 1 for ( keys %metadata );          # Laziness

        FIXFILE: {
            # Have to catch this case early for some unknown reason
            if ( $entry =~ /^runtime/ ) {
                $dest =~ s/^runtime\/parrot\///;
                $dest = File::Spec->catdir(
                    $options_ref->{libdir}, $parrotdir, $dest
                );
                last FIXFILE;
            }
            foreach my $tkey (keys %$metatransforms) {
                if ( $metadata{$tkey} ) {
                    my $copy = $dest; # only needed for installable
                    $dest = File::Spec->catdir(
                        $options_ref->{$metatransforms->{$tkey}->{optiondir} . 'dir'},
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

            foreach my $tkey (keys %$othertransforms) {
                if ( $entry =~ /$tkey/ ) {
                    $dest = File::Spec->catdir(
                        $options_ref->{$othertransforms->{$tkey}->{optiondir} . 'dir'},
                        &{ $othertransforms->{$tkey}->{transform} }($dest)
                    );
                    last FIXFILE;
                }
            }
            die "Unknown install location in MANIFEST for file '$entry': ";
        }

        $dest = File::Spec->catdir( $options_ref->{buildprefix}, $dest )
            if $options_ref->{buildprefix};

        $directories{ dirname($dest) } = 1;
        push( @files, [ $src => $dest ] );
    }
    continue {
        close ARGV if eof;    # Reset line numbering for each input file
    }

    return(\@files, \@installable_exe, \%directories);
}

=head2 C<create_directories()>

B<Purpose:> Creates the directories passed in.

B<Arguments:>  Two scalar arguments.

    create_directories(
        $destination_directory,
        $directories_hash_ref,
    );

B<Return Value:>  True value.

B<Comment:>

=cut

sub create_directories {
    my($destdir, $directories) = @_;

    for my $dir ( map { $destdir . $_ } keys %$directories ) {
        unless ( -d $dir ) {
            my @dirs_needed;

            # Make full path to the directory $dir
            while ( ! -d $dir ) {    # Scan up to nearest existing ancestor
                unshift @dirs_needed, $dir;
                $dir = dirname($dir);
            }
            foreach my $d ( @dirs_needed ) {
                mkdir( $d, 0777 ) or die "mkdir $d: $!";
            }
        }
    }
    return 1;
}

=head2 C<install_files()>

B<Purpose:> Install the mentioned files into the appropriate locations.

    install_files(
        $destination_directory,
        $dry_run_option,
        @list_of_files_and_executables,
    );

B<Arguments:>  Takes two scalar arguments, followed by a list consisting of
2-element, C<source => destination> array references.

B<Return Value:>  True value.

B<Comment:>

=cut

sub install_files {
    my($destdir, $dryrun, @files) = @_;
    my($src, $dest, $mode);

    print("Installing ...\n");
    foreach my $el ( @files ) {
        next unless ref($el) eq 'ARRAY';
        ( $src, $dest ) = @{ $el };
        $dest = $destdir . $dest;
        if ( $dryrun ) {
            print "$src -> $dest\n";
            next;
        }
        else {
            next unless -e $src;
            next if $^O eq 'cygwin' and -e "$src.exe"; # stat works, copy not
            copy( $src, $dest ) or die "copy $src to $dest: $!";
            print "$dest\n";
        }
        $mode = ( stat($src) )[2];
        chmod $mode, $dest;
    }
    return 1;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
