#! perl -w
# Copyright: 2001-2006 The Perl Foundation.  All Rights Reserved.
# $Id: pmc2c.pl 12524 2006-05-05 21:50:26Z petdance $

=head1 NAME

tools/build/headerizer.pl - Generates the function header parts of .h files from .c files

=head1 SYNOPSIS

Update the headers in F<include/parrot> with the function declarations
in F<src/*.c>.

    % perl tools/build/headerizer.pl --cdir=src --hdir=include/parrot

=head1 DESCRIPTION

=head1 COMMAND-LINE OPTIONS

=over 4

=item C<--cdir=dir>

Specify the directory to find the source files.  Defaults to F<src>
if not specified.

=item C<--hdir=dir>

Specify the directory to find the header files.  Defaults to
F<include/parrot> if not specified.

=item C<--verbose>

Verbose status along the way.

=back

=cut

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../..";
use lib "$FindBin::Bin/../../lib";
use Getopt::Long;

my %opt;

main();

=head1 FUNCTIONS

=cut

sub open_file {
    my $direction = shift;
    my $filename = shift;

    my $action =
        ($direction eq "<") ? "Reading" :
        ($direction eq ">>") ? "Appending" : "Writing";

    print "$action $filename\n" if $opt{verbose};
    open my $fh, $direction, $filename or die "$action $filename: $!\n";
    return $fh;
}

sub main {
    $opt{hdir} = "include/parrot";
    $opt{cdir} = "src";
    GetOptions(
        "hdir=s"    => \$opt{hdir},
        "cdir=s"    => \$opt{cdir},
        "verbose"   => \$opt{verbose},
    ) or exit(1);
    unshift @include, ".", "$FindBin::Bin/../..", "$FindBin::Bin/../../src/pmc/";
}

# vim: expandtab shiftwidth=4:
