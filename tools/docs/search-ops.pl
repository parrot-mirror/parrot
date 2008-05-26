# perl
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
croak "You must supply 1 ops code as a command-line argument: $!"
    unless $all or $ARGV[0];

my $pattern = $all ? q{} : $ARGV[0];
my $wrap_width = 70;
my $opsdir = q{src/ops};

my $total_identified = search_all_ops_files(
    $pattern, $wrap_width, $opsdir
);

#print $total_identified, "\n";
print "No matches were found\n" unless $total_identified;
exit 0;

