#! /usr/bin/perl -w
#
# ops2pm.pl
#
# Generate a Perl module from the operation definitions in .ops files.
#
# The first .ops file on the command line is read in and its name is used to
# determine the name of the Perl module that will contain the op info.
#
# Any remaining .ops files on the command line are read in, and their op
# info objects are appended, in order, to the op info array obtained from the
# first .ops file.
#
# WARNING: Generating a combined Perl module for a set of .ops files that
# you do not later turn into a combined opcode table with the same content
# and order is a recipe for disaster.
# 
# XXX: The original design of the .ops processing code was intended to be a
# read-only representation of what was in a particular .ops file. It was
# not originally intended that it was a mechanism for building a bigger
# virtual .ops file from multiple physical .ops files. This code does half of
# that job (the other half is getting them to compile together instead of
# separately in a *_ops.c file). You can see evidence of this by the way this
# code reaches in to the internal OPS hash key to do its concatenation, and
# the way it twiddles each op's CODE hash key after that. If the op and oplib
# Perl modules are going to be used for modifying information read from .ops
# files in addition to reading it, they should be changed to make the above
# operations explicitly supported. Otherwise, the Parrot build and interpreter
# start-up logic should be modified so that it doesn't need to concatenate 
# separate .ops files.
#

use strict;
use lib 'lib';
use Parrot::OpsFile;

use Data::Dumper;
$Data::Dumper::Useqq  = 1;
#$Data::Dumper::Terse  = 1;
#$Data::Dumper::Indent = 0;

my $moddir  = "lib/Parrot/OpLib";

sub Usage {
    print STDERR <<_EOF_;
usage: $0 input.ops [input2.ops ...]
_EOF_
    exit;
}

Usage() unless @ARGV;


#
# Use the first .ops file to determine the output file name, and read in its
# ops:
#

my $file = shift @ARGV;

my ($base)  = ($file =~ m{^(.*)\.ops$});
my $package = "${base}";
my $module  = "lib/Parrot/OpLib/${package}.pm";

die "$0: Could not find ops file '$file'!\n" unless -e $file;
my $ops = new Parrot::OpsFile $file;
die "$0: Could not read ops file '$file'!\n" unless defined $ops;


#
# Copy the ops from the remaining .ops files to the object just created.
#

my %seen;

for $file (@ARGV) {
    if ($seen{$file}) {
      print STDERR "$0: Ops file '$file' mentioned more than once!\n";
      next;
    }
    $seen{$file} = 1;

    die "$0: Could not find ops file '$file'!\n" unless -e $file;
    my $temp_ops = new Parrot::OpsFile $file;
    die "$0: Could not read ops file '$file'!\n" unless defined $temp_ops;

    push @{$ops->{OPS}}, @{$temp_ops->{OPS}};
}


#
# Renumber the ops based on their new absolute positions (they started out
# being numbered according to their relative position within their respective
# .ops files):
#

my $cur_code = 0;
for(@{$ops->{OPS}}) {
    $_->{CODE}=$cur_code++;
}


#
# Open the output file:
#

if (! -d $moddir) {
    mkdir($moddir, 0755) or die "$0: Could not mkdir $moddir: $!!\n";
}
open MODULE, ">$module"
  or die "$0: Could not open module file '$module' for writing: $!!\n";


#
# Print the preamble for the MODULE file:
#

my $version = $ops->version;

my $preamble = <<END_C;
#! perl -w
#
# !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
#
# This file is generated automatically from '$file'.
# Any changes made here will be lost!
#

use strict;

package Parrot::OpLib::$package;

use vars qw(\$VERSION \$ops);

\$VERSION = "$version";

END_C

print MODULE $preamble;
print MODULE Data::Dumper->Dump([[ $ops->ops ]], [ qw($ops) ]);

print MODULE <<END_C;

1;
END_C

exit 0;

