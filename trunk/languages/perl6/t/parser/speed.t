#!/usr/bin/perl -w

use strict;

use FindBin;
use lib $FindBin::Bin;

use P6CTest;

# Figure out how many tests we have.
my @tests = @ARGV ? @ARGV : glob "speed_*.pl";

plan(tests => scalar @tests);

check_parse {
    name => "Parse speed checks",
    pgm_files => \@tests,
};
