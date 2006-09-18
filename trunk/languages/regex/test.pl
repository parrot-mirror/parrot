#! perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Regex;
use Regex::Driver;
# use lib "$FindBin::Bin/../../lib";
# use Parrot::Config;

# Running this with perl5.005 produces:
# Can't locate object method "new" via package "Regex::CodeGen::IMCC"
use 5.006;

use File::Spec::Functions;	# In perl core only for >= 5.6.

# FIXME: This is still probably unix-only, because the parrot binary
# will have different names
my $PARROT_EXE = catfile(catdir($FindBin::Bin, updir(), updir()), "parrot");

sub usage {
    my ($msg, $status) = @_;
    $status = 1 if ! defined $status;

    print $msg . "\n" if $msg;

    print <<"END";
Usage: $0 [-c|--compile] [--language=LANGUAGE] [--optimize=PASSES|--nooptimize] <filename>

  Test files are Perl5 source files which must contain a __END__ section.
  Right after the __END__ there must be a single regular expression.
  Next there should be any number of pairs of INPUT and OUTPUT
  sections, where an INPUT: section begins with the string 'INPUT:' on
  a line by itself, followed by some data and a newline. (The newline
  is not regarded as part of the data, so add an extra one if you want
  the input to end with a newline.) The OUTPUT: section is similar.

  Example:

__END__
(a*a|(aaa))a
INPUT:
xxxxxxxxaaabb
OUTPUT:
Match found
0: 8..10
1: 8..9
INPUT:
aaaaaaaaaaaa
OUTPUT:
Match found
0: 0..11
INPUT:
xyz
OUTPUT:
Match failed
END
  exit $status;
}

my $DEBUG = 0;
my $compile = 0;
my $tree_opt = 1;
my $list_opt = 1;
my $language;
my $testfile;
my $pattern;

# Hm. What versions of perl provide Getopt::Long as a builtin?
foreach (@ARGV) {
    if (/^(-h|--help)$/) {
        usage(0);
    } elsif (/^(-c|--compile)$/) {
        $compile = 1; # Compile only
    } elsif (/--no(-?)optimize/) {
        $tree_opt = 0;
        $list_opt = 0;
    } elsif (/--language=(.*)/) {
        $language = $1;
    } elsif (/--expr=(.*)/) {
        $pattern = $1;
    } elsif (/--optimize=(.*)/) {
        my $opts = $1;
        $tree_opt = ($opts =~ /t/i);
        $list_opt = ($opts =~ /l/i);
    } elsif (/^(-d|--debug)$/) {
        $DEBUG = 1;
    } elsif (! defined $testfile) {
        $testfile = $_;
    } else {
        usage "too many args!";
    }
}

usage "not enough args: testfile required"
  if ! defined $testfile && ! defined $pattern;

if (defined $testfile) {
    open(SPEC, $testfile) or die "open $testfile: $!";
    $pattern = <SPEC>;
    chomp($pattern);
}

generate_regular($pattern);
exit(0) if $compile;

my $status = 1;

my $testCount = 1;
$_ = <SPEC>;
while (1) {
    my ($input, $output);

    last if ! defined $_;
    die "INPUT: expected" if ! /^INPUT:/;

    # Gather input, look for OUTPUT:
    $input = '';
    undef $output;
    while (<SPEC>) {
        $output = '', last if /^OUTPUT:/;
        $input .= $_;
    }
    chomp($input);
    die "EOF during INPUT section" if ! defined($output);

    # Gather output
    while (<SPEC>) {
        last if /^INPUT:/;
        $output .= $_;
    }

    $status &&= process($input, $output, $testCount++);
}

exit ($status ? 0 : 1);

sub generate_regular_pir {
    my ($filename, $pattern) = @_;
    open(PIR, ">$filename") or die "create $filename: $!";

    my $ctx = { };
    my $trees = Regex::expr_to_tree($pattern, $ctx, DEBUG => $DEBUG);

    my $driver = Regex::Driver->new('pir', emit_main => 1);

    print PIR <<"END";
# Regular expression test
# Generated by $0
# Pattern >>$pattern<<

END

    $driver->output_header(*PIR);

    for my $tree (@$trees) {
        $driver->output_rule(*PIR, '_regex', $tree, $ctx, DEBUG => $DEBUG);
    }

    close PIR;
}

sub generate_pbc {
    my ($pir, $pbc) = @_;
    my $status = system("$PARROT_EXE", "-o", $pbc, $pir);
    if (! defined($status) || $status) {
        die "assemble failed with status " . ($? >> 8);
    }
}

sub generate_regular {
    my $pattern = shift;
    generate_regular_pir("test_regex.pir", $pattern);
    generate_pbc("test_regex.pir", "test.pbc");
}

sub process {
    my ($input, $output, $testnum) = @_;
    open(TEST, "$PARROT_EXE test.pbc '$input' |");

    local $/;
    my $actual_output = <TEST>;
    if ($actual_output eq $output) {
        print "ok $testnum\n";
        return 1;
    } else {
        print "not ok $testnum\n";
        print " == Received ==\n$actual_output\n";
        print " == Expected ==\n$output\n";
        return 0;
    }
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
