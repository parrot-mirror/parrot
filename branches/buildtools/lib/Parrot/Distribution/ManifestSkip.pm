# Copyright (C) 2007, The Perl Foundation.
# $Id: Distribution.pm 17319 2007-03-04 01:35:40Z jkeenan $

=head1 NAME

Parrot::Distribution::ManifestSkip - Functionality to generate MANIFEST.SKIP

=head1 SYNOPSIS

    use Parrot::Distribution::ManifestSkip qw( gen_manifest_skip );

    $manifest_skip_lines_ref = gen_manifest_skip();

=head1 DESCRIPTION

Parrot::Distribution::ManifestSkip exports on request a single subroutine,
F<gen_manifest_skip>().  This subroutine's principal use is in
F<tools/dev/gen_manifest_skip.pl>.

=head2 C<gen_manifest_skip()>

=over 4

B<Purpose:>  Gather the names of files needed to populate MANIFEST.SKIP.

B<Arguments:>  None.

B<Return Value:>  Reference to an array holding the names of files needed to
populate MANIFEST.SKIP. 

B<Comment:>

This subroutine queries the svn:ignore property and generates the lines 
for MANIFEST.SKIP.

=back

=head2 Note

This is B<not> a subclass of Parrot::Distribution.  The subroutine the package
exports formerly resided in that package but has been refactored into this
package because it was not a true Parrot::Distribution method and because its
purpose was quite distinct from the other Parrot::Distribution methods.

=head1 PREREQUISITES

=over 4

=item * Perl 5

=over 4

=item * ExtUtils::Manifest

=item * File::Spec

=back

=item * Parrot

=over 4

=item * Parrot::Configure::Step

=item * Parrot::Revision

=back

=back

=head1 AUTHOR

=head1 SEE ALSO

Parrot::Distribution.  F<tools/dev/gen_manifest_skip.pl>.

=cut

package Parrot::Distribution::ManifestSkip;
use strict;
use ExtUtils::Manifest;
use File::Spec;
use lib qw( lib );
use Parrot::Configure::Step qw(capture_output);
use Parrot::Revision;
our (@ISA, @EXPORT_OK);
@ISA = qw( Exporter );
@EXPORT_OK = qw( gen_manifest_skip );


sub gen_manifest_skip {

    # manicheck.pl is probably only useful for checked out revisions
    # Checkout is done either with svn or svk
    my $svn_cmd;
    if ( defined $Parrot::Revision::svn_entries
        && $Parrot::Revision::svn_entries =~ m/\.svn/ )
    {
        $svn_cmd = 'svn';
    }
    else {
        $svn_cmd = 'svk';
    }

    # Find all directories in the Parrot distribution
    my %dir_list = map {
        my $dir = ( File::Spec->splitpath($_) )[1];
        $dir =~ s!\.svn/$!!;
        $dir => 1
    } keys %{ ExtUtils::Manifest::manifind() };
    my @skip;    # regular expressions for files to skip
    foreach my $dir ( sort keys %dir_list ) {
        next if $dir =~ m/\.svn/;
        next if ( $dir && !-d $dir );

        my $patterns = capture_output("$svn_cmd propget svn:ignore $dir");

        # TODO: escape chars that are special in regular expressions
        push @skip, qq{# generated from svn:ignore of '$dir'}, map {
            my $end = $dir_list{ $dir . $_ } ? '$' : '/';
                                        # ignore file or dir
            s/\./\\./g;                 # . is simply a dot
            s/\*/.*/g;                  # * is any amount of chars
            "^${dir}${_}\$",            # SVN globs are specific to a dir
            "^${dir}${_}/",             # SVN globs are specific to a dir
        } split( /\n/, $patterns );
    }

    return \@skip;
}

1;
