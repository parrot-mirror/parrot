#! perl -w

use strict;
use FindBin;
use File::Spec::Functions;

# FIXME: This is still probably unix-only, because the parrot binary
# will have different names
my $PARROT_EXE = catfile(catdir($FindBin::Bin, updir(), updir()), "parrot");

sub usage {
    my ($msg, $status) = @_;
    $status = 1 if ! defined $status;

    print $msg . "\n" if $msg;

    print <<"END";
Usage: $0 [-c|--compile] [--optimize=PASSES|--nooptimize] <filename>

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

my $DEBUG = 0;
my $compile = 0;
my $tree_opt = 1;
my $list_opt = 1;
my $testfile;
foreach (@ARGV) {
    if (/^(-h|--help)$/) {
        usage(0);
    } elsif (/^(-c|--compile)$/) {
        $compile = 1; # Compile only
    } elsif (/--no(-?)optimize/) {
        $tree_opt = 0;
        $list_opt = 0;
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
  if ! defined $testfile;

open(SPEC, $testfile);
my $pattern = <SPEC>;
chomp($pattern);

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

sub generate_regular_imc {
    my ($filename, $pattern) = @_;
    open(PIR, ">$filename") or die "create $filename: $!";
    use FindBin;
    use lib "$FindBin::Bin/lib";
    use Regex;

    print PIR <<"END";
.sub _main

# Regular expression test
# Generated by $0
# Pattern >>$pattern<<
    set S0, P5[1] # argv[1] (or perl5's \$ARGV[0])
    newsub \$P0, .Sub, _regex
    .pcc_begin prototyped
    .arg S0
    .pcc_call \$P0
ret_addr:
    .pcc_end
    end

DUMPSTRING:
        # Print the current position in the string
#	trace 0
        print "<"
        substr S1, S0, 0, I1
        print S1
        print "><"
        sub I21, I2, I1
        substr S1, S0, I1, I21
        print S1
        print ">\\n"
        ret

DUMPSTACK:
        # Dump the stack
        print "STACK["
        depth I10
        mul I11, I10, -1
	print I10
        print "]: "

DUMPLOOP:
        eq I10, 0, RETURN
	rotate_up I11
        entrytype I13, 0
	eq I13, 1, STACKINT
        restore S12
	print "'"
        print S12
	print "'"
        save S12
        branch AFTERELT
STACKINT:
	restore I12
        print I12
        save I12
AFTERELT:
        print " "
        sub I10, I10, 1
        branch DUMPLOOP

RETURN:
        print "\\n"
#	trace 1
        ret
.end

.pcc_sub _regex prototyped
 .param string rx_input
 .local int rx_len
 .local int rx_pos
 .local int rx_tmp
 .local IntList rx_stack
 .local PerlArray rx_starts
 .local PerlArray rx_ends

 rx_stack = new IntList
 rx_starts = new PerlArray
 rx_ends = new PerlArray

END

    my @asm = Regex::compile($pattern, { },
                             'printResults', 'printMatchFailed',
                             DEBUG => $DEBUG);

    print PIR "$_\n" foreach (@asm);

    print PIR <<'END';
printMatchFailed:
    print "Match failed\n"
    goto done
printResults:
    print "Match found\n"
    .local int match_num
    .local int ii
    .local int valid_flag
    set match_num, 0
printLoop:
    set ii, match_num
    bsr printGroup
    add match_num, ii, 1
    if valid_flag goto printLoop
done:
    .pcc_begin_return
    .pcc_end_return

printGroup:
    .local int num_groups
    set num_groups, rx_starts
    lt match_num, num_groups, groupDefined
    set valid_flag, 0
    ret
groupDefined:
    .local int match_start
    .local int match_end
    set match_start, rx_starts[match_num]
    set match_end, rx_ends[match_num]
    eq match_end, -2, skipPrint
    print match_num
    print ": "
    print match_start
    print ".."
    add match_end, match_end, -1 # Off by one
    print match_end
    print "\n"
skipPrint:
    set valid_flag, 1
    ret
.end
END

    close PIR;
}

sub generate_pbc {
    my ($imc, $pbc) = @_;
    my $status = system("$PARROT_EXE", "-o", $pbc, $imc);
    if (! defined($status) || $status) {
        die "assemble failed: $!";
    }
}

sub generate_regular {
    my $pattern = shift;
    generate_regular_imc("test.imc", $pattern);
    generate_pbc("test.imc", "test.pbc");
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
