# Copyright (C) 2001-2004, The Perl Foundation.
# $Id$

=head1 NAME

config/gen/PodText.pm - generate plain text docs from Pod files

=head1 SYNOPSIS

    use gen::PodText;

    gen::PodText->runstep($conf,
        "source1.pod" => "dest1.pod"
        "source2.pod" => "dest2.pod"
    );

=head1 DESCRIPTION

Uses L<Pod::Text> to convert Pod documents into their plain text equivalents.

=head1 USAGE

=head2 Methods

=head3 Class Methods

=over

=item * C<runstep()>

Converts Pod documents into plain text.  Documents to be converted as specified
as a hash with the keys being the source Pod document and the values being the
destination plain text file.

Accepts a L<Parrot::Configure> object followed by a flattened hash.

=back

=cut

package gen::PodText;

use strict;
use warnings;
use vars qw($description $result @args);

use base qw(Parrot::Configure::Step::Base);

use Pod::Text;

$description = 'Generating plain text docs from Pod';

@args = qw(verbose);

sub runstep {
    my ( $self, $conf, %docs ) = @_;

    my $verbose = $conf->options->get('verbose');

    my $parser = Pod::Text->new( width => 79 );

    my $count = 0;    # number of processed files
    foreach my $pod ( keys %docs ) {
        $count++;

        my $plain = $docs{$pod};
        $parser->parse_from_file( $pod, $plain );

        # append a header to the generated plain text
        open( my $fh, '+<', $plain )
            or die "can not open file $plain: $!";
        my $text = do { local $/; <$fh> };
        $text =
              "# DO NOT EDIT THIS FILE\n"
            . "# Generated by "
            . __PACKAGE__
            . " from $pod\n" . "\n"
            . $text;

        # the filehandle was opened for update so the files 'position' has to
        # be reset to the begining of the file so we don't end up just
        # appending to the end of the file.
        seek $fh, 0, 0;
        print $fh $text;
        close($fh) or die "can not close file $plain: $!";
    }

    $self->set_result( $count ? 'done' : 'no files to process' );

    return $self;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
