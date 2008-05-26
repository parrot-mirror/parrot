# perl
# Copyright (C) 2008, The Perl Foundation.
# $Id: SearchOps.pm 27813 2008-05-26 13:41:47Z jkeenan $
use strict;
use warnings;
use Carp;
use Getopt::Long ();
use lib qw( ./lib );
use Parrot::Docs::SearchOps qw(
    search_all_ops_files
    Usage
);

my ($help, $all);
Getopt::Long::GetOptions(
    "help|usage"    => \$help,
    "all"           => \$all,
) or exit 1;

if ($help) {
    Usage();
    exit 0;
}

croak "You may search for only 1 ops code at a time: $!"
    if @ARGV > 1;
croak "You must supply 1 ops code as a command-line argument.  Type '--help' for usage: $!"
    unless $all or $ARGV[0];

my $pattern = $all ? q{} : $ARGV[0];
my $wrap_width = 70;
my $opsdir = q{src/ops};

my $total_identified = search_all_ops_files(
    $pattern, $wrap_width, $opsdir
);

print "No matches were found\n" unless $total_identified;
exit 0;

=head1 NAME

tools/docs/search-ops.pl - Get descriptions of ops codes

=head1 USAGE

From the top-level Parrot directory,

    perl tools/docs/search-ops.pl some_ops_code

For help,

    perl tools/docs/search-ops.pl --help

... or

    perl tools/docs/search-ops.pl --usage

=head1 AUTHOR

James E Keenan, adapting Python program written by Bernhard Schmalhofer.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
