#!/usr/bin/perl -w

sub usage {
    my $status = shift || 1;
    print <<"END";
Usage: $0 <filename>

  Test files must contain a single regular expression on the first
  line. Next there should be any number of pairs of INPUT and OUTPUT
  sections, where an INPUT: section begins with the string 'INPUT:' on
  a line by itself, followed by some data and a newline. (The newline
  is not regarded as part of the data, so add an extra one if you want
  the input to end with a newline.) The OUTPUT: section is similar.

  Example:

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

if ($ARGV[0] && $ARGV[0] =~ /^(-h|--help)$/) {
    usage(0);
}

my $pattern = <>;
chomp($pattern);

generate_rx($pattern);

my $status = 1;

my $testCount = 1;
$_ = <>;
while (1) {
    my ($input, $output);

    last if eof();
    die "INPUT: expected" if ! /^INPUT:/;

    # Gather input, look for OUTPUT:
    $input = '';
    undef $output;
    while (<>) {
        $output = '', last if /^OUTPUT:/;
        $input .= $_;
    }
    chomp($input);
    die "EOF during INPUT: section" if ! defined($output);

    # Gather output
    while (<>) {
        last if /^INPUT:/;
        $output .= $_;
    }

    $status &&= process($input, $output, $testCount++);
}

exit ($status ? 0 : 1);

sub generate_rx_pasm {
    my ($filename, $pattern) = @_;
    open(PASM, ">$filename") or die "create $filename: $!";
    use FindBin;
    use lib "$FindBin::Bin/lib";
    use Regex;

    print PASM <<"END";
# Regular expression test
# Generated by $0
# Pattern >>$pattern<<
    set S0, "aabc" # Command-line input
    bsr REGEX
    rx_info_successful P0, I0
    if I0, \$matched
    print "Match failed\\n"
    end
\$matched:
    rx_info_getstartindex P0, I0
    rx_info_getindex P0, I1
    length I2, S0
    print "0: "
    print I0
    print ".."
    print I1
    print "\\n"
    rx_freeinfo P0
    end
END

    print PASM "REGEX:\n";
    my $parser = Regex::Parse->new();
    my $opt1 = Regex::PreOptimize->new();
    my $rewrite = Regex::Rewrite::Rx->new();
    my $opt2 = Regex::Optimize->new();
    my $cgen = Regex::CodeGen::Rx->new();

    my $tree = $parser->compile($pattern);
    my @code = $rewrite->run($tree);
    my @asm = $cgen->output(@code);
    my @optcode = $opt2->optimize(@code);
    my @optasm = $cgen->output(@optcode);
    print PASM "$_\n" foreach (@optasm);

    close PASM;
}

sub generate_pbc {
    my ($pasm, $pbc) = @_;
    my $status = system("$FindBin::Bin/../../assemble.pl $pasm > $pbc");
    if (! defined($status) || $status) {
        die "assemble.pl failed: $!";
    }
}

sub generate_rx {
    my $pattern = shift;
    generate_rx_pasm("test.pasm", $pattern);
    generate_pbc("test.pasm", "test.pbc");
}

sub process {
    my ($input, $output, $testnum) = @_;
    if (open(TEST, "-|") == 0) {
        exec("$FindBin::Bin/../../test_parrot", "test.pbc", $input)
          or die "Unable to exec";
    }

    local $/;
    my $actual_output = <TEST>;
    if ($actual_output eq $output) {
        print "ok $testnum\n";
        return 1;
    } else {
        print "not ok $testnum\n";
        return 0;
    }
}
