# $Id$
package Parrot::Manifest;
use strict;
use warnings;
use Carp;

sub new {
    my $class = shift;
    my $script = shift;

    my $self = bless( {}, $class );

    my %data = (
        id          => '$' . 'Id$',
        time        => scalar gmtime,
        cmd         => -d '.svn' ? 'svn' : 'svk',
        script      => $script,
    );

    my @status_output = qx($data{cmd} status -v);
    
    # grab the versioned resources:
    my @versioned_files = ();
    my @dirs = ();
    my @versioned_output = grep !/^\?/, @status_output;
    for my $line (@versioned_output) {
        my @line_info = split( /\s+/, $line );
    
        # the file is the last item in the @line_info array
        my $filename = $line_info[-1];
        $filename =~ s/\\/\//g;
        # ignore the debian directory
        next if $filename =~ m[/\.svn|blib|debian];
        if ( -d $filename ) {
            push @dirs, $filename;
        } else {
            push @versioned_files, $filename;
        }
    }
    $data{dirs} = \@dirs;
    $data{versioned_files} = \@versioned_files;

    # initialize the object from the prepared values (Damian, p. 98)
    %$self = %data;
    return $self;
}

1;

##### DOCUMENTATION #####

=head1 NAME

Parrot::Manifest - Base class for creating MANIFEST and MANIFEST.SKIP

=head1 SEE ALSO

Parrot::Manifest::Files, Parrot::Manifest::Skip,
F<tools/dev/mk_manifest_and_skip.pl>.

=head1 AUTHOR

James E. Keenan (jkeenan@cpan.org) refactored code from earlier versions of
F<tools/dev/mk_manifest_and_skip.pl>.

=head1 LICENSE

This is free software which you may distribute under the same terms as Perl
itself.

=cut
