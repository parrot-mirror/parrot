#! perl
# Copyright (C) 2008, The Perl Foundation
# $Id$

=head1 NAME

progress-graph.pl - generate a chart that displays rakudo's progress with
passing tests.

=head1 SYNOPSIS

perl tools/progress-graph.pl [input_file [output_file]]

=head1 DESCRIPTION

Create a chart that displays the number of passed, skipped and TODO tests.

If C<input_file> is given at the command line, it is read and parsed as a CSV
file. if absent F<docs/spectest-progress.csv> is used.

If C<output_file> is given, the image is written to that file. If not, the
file name C<rakudo-tests-%s.png> is used, where C<%s> stands for the last
processed date.

=cut


use strict;
use warnings;
use GD::Graph::bars;
use Text::CSV_XS;
use List::Util qw(max sum);
use POSIX qw(log10);

# column names
use constant DATE       => 0;
use constant REVISION   => 1;
use constant FILES      => 2;
use constant TESTS      => 3;
use constant PASS       => 4;
use constant FAIL       => 5;
use constant TODO       => 6;
use constant SKIP       => 7;

use constant MAX_COL    => 7;

my $fn = $ARGV[0] || 'docs/spectest-progress.csv';
open my $f, '<', $fn or die "Can't open file '$fn' for reading: $!";
my @data = map [], 0 .. MAX_COL;

my $csv = Text::CSV_XS->new({
        quote_char  => q{"},
        sep_char    => q{,},
    });

my $max = 0;
my @columns_to_plot = (PASS, FAIL, TODO, SKIP);

while (<$f>) {
    next if m/^"[a-z]+"/i; # skip header line
    next unless m/\d/;     # empty lines and such
    $csv->parse($_);
    my @cols = $csv->fields();
    push @{$data[0]}, substr $cols[0], 0, 10;
    for (1..MAX_COL){
        push @{$data[$_]}, $cols[$_];
    }
    $max = max $max, sum @cols[@columns_to_plot];
}

my $last_date = $data[DATE][-1];

my $p = GD::Graph::bars->new(600, 400);
no warnings 'qw';
$p->set(
        x_label             => 'Date',
        y_label             => 'Tests',
        title               => 'Passing Rakudo Spectests',
        x_label_skip        => 2,
        x_labels_vertical   => 1,
        cumulate            => 1,
        borderclrs          => [undef],
        dclrs               => [qw(#00FF00 #FF0000 #0000FF #FFFF00)]
    ) or die $p->error;

$p->set_legend('Pass', 'Fail', 'Todo', 'Skip');

# determine a better y_max_value - GD::Graph wastes much space by default
my $round_to = 10 ** int(log10 $max) / 5;
$max = $round_to * (1 + int($max / $round_to));
$p->set(y_max_value => $max );

my $g = $p->plot([@data[DATE, @columns_to_plot]]) or die $p->error;
my $out_file = $ARGV[1] || "rakudo-tests-$last_date.png";
open my $o, '>', $out_file
    or die "Can't open file graph.png for writing: $!";
binmode $o;
print $o $g->png;
close $o;
print "Image written to file '$out_file'\n";

