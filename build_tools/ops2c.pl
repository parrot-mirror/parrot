#! /usr/bin/perl -w
#
# ops2c.pl
#
# Generate a C header and source file from the operation definitions in
# an .ops file, using a supplied transform.
#
# $Id$
#

use strict;
use lib 'lib';
use Parrot::OpsFile;

my %arg_dir_mapping = (
	''   => 'PARROT_ARGDIR_IGNORED',
	'i'  => 'PARROT_ARGDIR_IN',
	'o'  => 'PARROT_ARGDIR_OUT',
	'io' => 'PARROT_ARGDIR_INOUT'
);

sub Usage {
    print STDERR <<_EOF_;
usage: $0 trans input.ops [input2.ops ...]
_EOF_
    exit 1;
}

#
# Process command-line argument:
#

Usage() unless @ARGV >= 2;

my $trans_class = "Parrot::OpTrans::" . shift @ARGV;

eval "require $trans_class";

my $trans = $trans_class->new;

my $prefix  = $trans->prefix;
my $suffix  = $trans->suffix;
my $defines = $trans->defines;
my $opsarraytype = $trans->opsarraytype;

my $file = shift @ARGV;

my $base = $file;
$base =~ s/\.ops$//;

my $incdir  = "include/parrot/oplib";
my $include = "parrot/oplib/${base}_ops${suffix}.h";
my $header  = "include/$include";
my $source  = "${base}_ops${suffix}.c";

my %hashed_ops;

#
# Read the input files:
#

my %opsfiles;
my @opsfiles;

foreach my $opsfile ($file, @ARGV) {
  if ($opsfiles{$opsfile}) {
    print STDERR "$0: Ops file '$opsfile' mentioned more than once!\n";
    next;
  }

  $opsfiles{$opsfile} = 1;
  push @opsfiles, $opsfile;

  die "$0: Could not read ops file '$opsfile'!\n" unless -r $opsfile;
}

my $ops = new Parrot::OpsFile @opsfiles;

my $version       = $ops->version;
my $major_version = $ops->major_version;
my $minor_version = $ops->minor_version;
my $patch_version = $ops->patch_version;

my $cur_code = 0;
for(@{$ops->{OPS}}) {
   $_->{CODE}=$cur_code++;

   hash_op($_->full_name(), $_->{CODE});
}

my $num_ops     = scalar $ops->ops;
my $num_entries = $num_ops + 1; # For trailing NULL


#
# Open the output files:
#

if (! -d $incdir) {
    mkdir($incdir, 0755) or die "ops2c.pl: Could not mkdir $incdir $!!\n";
}

open HEADER, ">$header"
  or die "ops2c.pl: Could not open header file '$header' for writing: $!!\n";

open SOURCE, ">$source"
  or die "ops2c.pl: Could not open source file '$source' for writing: $!!\n";


#
# Print the preamble for the HEADER and SOURCE files:
#

my $preamble = <<END_C;
/*
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically from '$file' (and possibly other
 * .ops files). by $0.
 *
 * Any changes made here will be lost!  
 *
 */

END_C

print HEADER $preamble;
print HEADER <<END_C;
#include "parrot/parrot.h"
#include "parrot/oplib.h"

extern op_lib_t * Parrot_DynOp_${base}${suffix}_${major_version}_${minor_version}_${patch_version}(void);

END_C

print SOURCE $preamble;
print SOURCE <<END_C;
#include "$include"

${defines}

END_C

print SOURCE $ops->preamble($trans);


#
# Iterate over the ops, appending HEADER and SOURCE fragments:
#

my @op_funcs;
my @op_func_table;

my $index = 0;

foreach my $op ($ops->ops) {
    my $func_name  = $op->func_name;
    my $arg_types  = "$opsarraytype *, struct Parrot_Interp *";
    my $prototype  = "$opsarraytype * $func_name ($arg_types)";
    my $args       = "$opsarraytype *cur_opcode, struct Parrot_Interp * interpreter";
    my $definition = "static $opsarraytype *\n$func_name ($args)";
    my $source     = $op->source($trans);

#    print HEADER "$prototype;\n";

    push @op_func_table, sprintf("  %-50s /* %6ld */\n", "$func_name,", $index++);
    push @op_funcs,      "$definition {\n$source}\n\n";
}

print SOURCE <<END_C;

/*
** Op Function Definitions:
*/

END_C

print SOURCE @op_funcs;

#
# reset #line in the SOURCE file.
#

close(SOURCE);
open(SOURCE, "<$source") || die "Error re-reading $source: $!\n";
my $line = 0; while (<SOURCE>) { $line++; } $line+=2;
close(SOURCE);
open(SOURCE, ">>$source") || die "Error appending to $source: $!\n";
print SOURCE "#line $line \"$source\"\n" unless $ENV{PARROT_NO_LINE};


#
# Finish the SOURCE file's array initializer:
#

print SOURCE <<END_C;

INTVAL ${base}_numops${suffix} = $num_ops;

/*
** Op Function Table:
*/

static op_func${suffix}_t op_func_table\[$num_entries] = {
END_C

print SOURCE @op_func_table;

print SOURCE <<END_C;
  (op_func${suffix}_t)0  /* NULL function pointer */
};


END_C


#
# Op Info Table:
#

print SOURCE <<END_C;

/*
** Op Info Table:
*/

static op_info_t op_info_table\[$num_entries] = {
END_C

$index = 0;

foreach my $op ($ops->ops) {
    my $type       = sprintf("PARROT_%s_OP", uc $op->type);
    my $name       = $op->name;
    my $full_name  = $op->full_name;
    my $func_name  = $op->func_name;
    my $body       = $op->body;
    my $jump       = $op->jump || 0;
    my $arg_count  = $op->size;
    my $arg_types  = "{ " . join(", ", map { sprintf("PARROT_ARG_%s", uc $_) } $op->arg_types) . " }";
    my $arg_dirs   = "{ " . join(", ", map { $arg_dir_mapping{$_} } $op->arg_dirs) . " }";

    print SOURCE <<END_C;
  { /* $index */
    $type,
    "$name",
    "$full_name",
    "$func_name",
    "", /* TODO: Put the body here */
    $jump, /* 1 = relative 2 = absolute 4 = pop 8 = next 16 = unpredictable */ 
    $arg_count,
    $arg_types,
    $arg_dirs
  },
END_C

  $index++;
}

print SOURCE <<END_C;
};

/*
** Op lookup function:
*/

END_C

#print STDERR "Top level op chars: ", keys %$remembered_ops, "\n";

generate_hash(\%hashed_ops);

print SOURCE <<END_C;

/*
** op lib descriptor:
*/

static op_lib_t op_lib = {
  "$base",
  $major_version,
  $minor_version,
  $patch_version,
  $num_ops,
  op_info_table,
  op_func_table,
  find_op
};

op_lib_t * Parrot_DynOp_${base}${suffix}_${major_version}_${minor_version}_${patch_version}(void) {
  return &op_lib;
}

END_C

exit 0;

#
# Hash op to its code for the find_op() generation
#
sub hash_op {
    my ($name, $code) = @_;
    $hashed_ops{$name} = $code;    
}

#
# Generate the find_op() function
#
sub generate_hash {
    my $hash = shift;
    my @opnames = sort keys %$hash;

print SOURCE<<END_C;
struct op_hash_node {
    char name[32];
    int opcode;
};

static struct op_hash_node op_hash[] = {
END_C

    my $count = 0;
    my %first;
    my $bottom = 0xff;
    my $top = 0;
    my $bottom_ch;
    my $bottom_sec = 0xff;
    my $top_sec = 0;
    my $bottom_sec_ch;
    my ($f, $c1, $c2);
    foreach my $opname (@opnames) {
        $f = substr($opname, 0, 2);
        $c1 = ord(substr($opname, 0, 1));
        $c2 = ord(substr($opname, 1, 2));
        if($c1 < $bottom) {
        	$bottom = $c1;
        }
        if($c2 < $bottom_sec) {
        	$bottom_sec = $c2;
        }
        if($top < $c1) {
        	$top = $c1;
        }
        if($top_sec < $c2) {
        	$top_sec = $c2;
        }
        if($first{$f}) {
        	print SOURCE "{ \"$opname\", ", $hash->{$opname}, "},\n";
        }
        else {
        	print SOURCE "{\"\", 0},\n";
        	$count++;
        	$first{$f} = $count;
        	print SOURCE "{ \"$opname\", ", $hash->{$opname}, "},\n";
        }	
        $count++;
    }

    $bottom_ch = "'" . chr($bottom) . "'";
    $bottom_sec_ch = "'" . chr($bottom_sec) . "'";

print SOURCE<<END_C;
    {"", 0}
};

static int op_hash_jump[] = {
END_C
    for(my $c1 = $bottom; $c1 <= $top; $c1++) {
    	for(my $c2 = $bottom_sec; $c2 <= $top_sec; $c2++) {
    		if($first{chr($c1) . chr($c2)}) {
    			print SOURCE $first{chr($c1) . chr($c2)} . ", /* " . chr($c1) . chr($c2) . " */ \n";
    		}
    		else {
    			print SOURCE "0,\n";
    		}
    	}
    }
    print SOURCE "0};\n";

    my $range1 = $top - $bottom + 1;
    my $range2 = $top_sec - $bottom_sec + 1;

print SOURCE<<END_C;

/*
 * If this hasher stinks blame it on Melvin.
 * It achieves 40% of the Big Switch(tm) for the old find_op() which
 * itself was approaching the 'mops' benchmark, but takes way less
 * resources to compile and is 500k of generated source smaller.
 * We generate a jump table for the 1st and 2nd characters of
 * the opcode. Then, the hash is sorted so we just move cursor
 * right and down through the sorted array until we either match
 * the whole op or hit a null entry.
 * When we write out the ops we compute the min and max char codes so we
 * can compress the jump table. I expect this is still tunable.
 */
static int find_op(const char * name) {
	/* Table compressed to first char */
	int bucket = (name[0] - $bottom_ch) * $range2 + 
			(name[1] - $bottom_sec_ch);
	int op;
	int i = 2;
	if((op = op_hash_jump[bucket]) == 0) {
		printf("Invalid bucket for %s\n", name);
		exit(0);
	}
	for(;;) {
		if(name[i] != op_hash[op].name[i]) {
			op++;
			if(op_hash[op].name[0] == 0)
				return -1;
			continue;
		}
		if(name[i] == 0)
			return op_hash[op].opcode;
		i++;
	}
}
END_C
    
}
