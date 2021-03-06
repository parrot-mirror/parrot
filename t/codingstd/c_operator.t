#! perl
# Copyright (C) 2006-2009, Parrot Foundation.
# $Id$

use strict;
use warnings;

use lib qw( . lib ../lib ../../lib );
use Test::More tests => 1;
use Parrot::Distribution;
use Pod::Simple;

=head1 NAME

t/codingstd/c_operator.t - checks spacing around operators in C source

=head1 SYNOPSIS

    # test all files
    % prove t/codingstd/c_operator.t

    # test specific files
    % perl t/codingstd/c_operator.t src/foo.c include/parrot/bar.h

=head1 DESCRIPTION

Checks that all C language source files have the proper use of spacing
around operators.

=head1 AUTHOR

Paul Cochrane <paultcochrane at gmail dot com>

=head1 SEE ALSO

L<docs/pdds/pdd07_codingstd.pod>

=cut

my $DIST = Parrot::Distribution->new;
my @files = @ARGV ? <@ARGV> : $DIST->get_c_language_files();
check_operators(@files);

exit;

sub strip_pod {
    my $buf = shift;
    my $parser = Pod::Simple->new();
    my $non_pod_buf;
    $parser->output_string( \$non_pod_buf );
    # set up a code handler to get at the non-pod
    # thanks to Thomas Klausner's Pod::Strip for the inspiration
    $parser->code_handler(
        sub {
            print {$_[2]{output_fh}} $_[0], "\n";
        });
    $parser->parse_string_document( $buf );

    return $non_pod_buf;
}

sub check_operators {
    my %comma_space;

    foreach my $file (@_) {
        my $path = @ARGV ? $file : $file->path();

        # skip lex files
        next if $path =~ m/\.l$/;

        my $buf = $DIST->slurp($path);

        # only strip pod from .ops files
        if ( $path =~ m/\.ops$/ ) {
            $buf = strip_pod($buf);
        }

        # strip ', ", and C comments #'
        $buf =~ s{ (?:
                       (?: (') (?: \\\\ | \\' | [^'] )* (') ) # rm ' string #'
                     | (?: (") (?: \\\\ | \\" | [^"] )* (") ) # rm " string #"
                     | /(\*) .*? (\*)/                        # rm C comment
                   )
                }{defined $1 ? "$1$2" : defined $3 ? "$3$4" : "$5$6"}egsx;

        my @lines = split( /\n/, $buf );
        $comma_space{$path} = [];
        for (my $i=0; $i <= $#lines; $i++) {
            # after a comma there should be one space or a newline
            if ( $lines[$i] =~ m{ ( (?:,) (?! \s ) (?= .+) ) }gx ) {
                push @{ $comma_space{$path} }, $lines[$i];
            }
        }
    }

## L<PDD07/Code Formatting"there should be one space or a newline after a comma">/
    my @comma_space_files;
    for my $path ( sort keys %comma_space ) {
        if (my $cnt = scalar  @{ $comma_space{$path} }) {
            push @comma_space_files, <<"END_ERROR";
$path [$cnt line@{[ ($cnt >1) ? 's': '' ]}] at :
@{[ join("\n--\n", @{$comma_space{$path}}) ]}
END_ERROR
        }
    }
    is(join("\n",@comma_space_files),
       "",
       "there should be one space or a newline after a comma");
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
