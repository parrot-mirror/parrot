#! perl

use lib 'lib';
use Text::Balanced qw(extract_delimited);
use Math::BigInt;
use Getopt::Long;
use strict;

my $outfile = 'all_cstring.str';
my $string_private_h = 'include/parrot/string_private_cstring.h';

my ($result, $do_all, $do_init, $file);
$result = GetOptions(
    "all" => \$do_all,
    "init" => \$do_init,
);

$do_all and do {
    &read_all;
    &create_c_include;
    exit;
};
$do_init and do {
    unlink $outfile;
    exit;
};

$file = shift @ARGV;
$file =~ s/\.c$//;
my $infile = $file . '.c';
die "$0: $infile: $!" unless -e $infile;

my %known_strings = ();
my @all_strings;

&read_all;
open ALL, ">>$outfile" or die "Can't write '$outfile': $!";
&process_cfile;
close ALL;

sub hash_val {
	my $h = Math::BigInt->new('+0');
	my $s = shift;
	for (my $i = 0; $i < length($s); ++$i) {
		$h += $h << 5;
		$h &= 0xffffffff;
		$h += ord substr($s, $i, 1);
		$h &= 0xffffffff;
	}
	return sprintf("0x%x", $h);
}

sub read_all {
    if (-e $outfile) {
	open IN, "<$outfile";
	while (<IN>) {
	    # len hashval "string"
	    if (/(\d+)\s+(0x[\da-hA-H]+)\s+"(.*)"/) {
		push @all_strings, [$1, $2, $3];
		$known_strings{$3} = scalar @all_strings;
	    }
	}
	close(IN);
    }
}

sub process_cfile {
    open IN, $infile or die "Can't read '$infile': $!";

    my $line = 0;
    print <<"HEADER";
/*
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically from '$infile'
 * by $0.
 *
 * Any changes made here will be lost!
 *
 */

#define CONCAT(a,b) a##b
#define _CONST_STRING(i, l) (i)->const_cstring_table[CONCAT(_CONST_STRING_, l)]
#define CONST_STRING(i, s) _CONST_STRING(i, __LINE__)

HEADER
    print ALL "# $infile\n";
    my %this_file_seen;
    while (<IN>) {
	$line++;
	next if m/^\s*#/; # ignore preprocessor
	next unless s/.*\bCONST_STRING\s*\(\w+\s*,//;

	my $str = extract_delimited; # $_, '"';
	$str = substr $str, 1, -1;
	# print STDERR "** '$str' $line\n";
	my $n;
	if ($n = $known_strings{$str}) {
	    if (!$this_file_seen{$str}) {
		print "#define _CONST_STRING_$line $n\n";
	    }
	    else {
		print "#define _CONST_STRING_$line _CONST_STRING_",
		    $this_file_seen{$str}, "\n";
	    }
	    $this_file_seen{$str} = $line;
	    next;
	}
	my $len = length $str;
	my $hashval = hash_val($str);
	push @all_strings, [$len, $hashval, $str];
	$n = scalar @all_strings;
	$known_strings{$str} = $n;
	$this_file_seen{$str} = $line;
	print "#define _CONST_STRING_$line $n\n";
	print ALL qq!$len\t$hashval\t"$str"\n!;
    }
    close(IN);
}

sub create_c_include {
    open OUT, ">$string_private_h" or die "Can't write '$string_private_h': $!";
    print OUT <<HEADER;
/*
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically from '$outfile'
 * by $0.
 *
 * Any changes made here will be lost!
 *
 */
static const struct _cstrings {
    UINTVAL len;
    Parrot_UInt4 hash_val;
    const char *string;
} parrot_cstrings[] = {
	{ 0, 0, "" },
HEADER
    my @all;
    for my $s (@all_strings) {
	push @all, qq!\t{$s->[0], $s->[1], "$s->[2]"}!;
    }
    print OUT join(",\n", @all);
    print OUT <<HEADER;

};

HEADER
    close OUT;
}

=pod
print <<"HEADER";
/*
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically from '$infile'
 * by $0.
 *
 * Any changes made here will be lost!
 *
 */

#define CONCAT(a,b) a##b
#define _S(name) (__PARROT_STATIC_STR(__LINE__))
#define __PARROT_STATIC_STR(line) CONCAT(&static_string_, line)

#if ! DISABLE_GC_DEBUG
#  define GC_DEBUG_VERSION ,0
#else
#  define GC_DEBUG_VERSION
#endif

HEADER

# currently unused true const strings
sub output_string {
  my ($text, $line) = @_;

  if (exists $known_strings{$text}) {
    <<"DATA";
#define static_string_${line} static_string_$known_strings{$text}

DATA
  }
  else {
    $known_strings{$text} = $line;
    my $h = hash_val($text);
    <<"DATA";
static /*const*/ char static_string_${line}_data\[\] = $text;
static /*const*/ struct parrot_string_t static_string_${line} = {
  { /* pobj_t */
    {{
      static_string_${line}_data,
      sizeof(static_string_${line}_data)
    }},
    (PObj_constant_FLAG|PObj_external_FLAG)
    GC_DEBUG_VERSION
  },
  sizeof(static_string_${line}_data),
  static_string_${line}_data,
  sizeof(static_string_${line}_data) - 1,
  1,
  $h
};

DATA
  }
}

open IN, $infile;

my $line = 0;
while (<IN>) {
  $line++;
  next if m/^\s*#/; # ignore preprocessor
  next unless s/.*\b_S\b//;

  my $str = extract_bracketed $_, '(")';

  print output_string (substr($str,1,-1), $line);
}
=cut
