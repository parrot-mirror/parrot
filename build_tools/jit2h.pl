#! /usr/bin/perl -w
#
# jit2h.pl
#
# $Id$
#

use strict;
use lib 'lib';
use Parrot::OpLib::core;
use Parrot::Op;
use Parrot::OpTrans::C;

my %type_to_arg = (
    INT_CONST => 'ic',
    NUM_CONST => 'nc',
    STRING_CONST => 'sc',
    INT_REG => 'i',
    NUM_REG => 'n',
    PMC_REG => 'p',
    STRING_REG => 's',
);

my $core_numops = scalar(@$Parrot::OpLib::core::ops);
my @core_opfunc = map { $_->func_name } @$Parrot::OpLib::core::ops;
my %opcodes;

for(@$Parrot::OpLib::core::ops) {
    my $name = $_->{NAME} . '_' .join '_',@{$_->{ARGS}}[1..$#{$_->{ARGS}}];
    $opcodes{$name} = $_->{CODE};
}

my $cpuarch = shift @ARGV;

my ($i,$j,$k,$n);

my ($function, $body, $line, $extern, $header);

my ($asm, $precompiled);

my %core_ops;
my %templates;

sub readjit($) {
    my $file = shift;

    my %ops;
    my $template;

    open (IN,$file) or die "Can't open file $file: $!";
    while ($line = <IN>) {
        if ($line =~ m/^#define/) {
            $line =~ s/PREV_OP\s(..?)\s(\w+)/(jit_info->prev_op) && (*jit_info->prev_op $1 $opcodes{$2})/g;
            $header .= $line;
            next;
        }
	# ignore comment and empty lines
        next if (($line =~ m/^;/) || ($line =~ m/^\s*$/));
        if (!defined($function) && !defined($template)) {
	    if ($line =~ m/TEMPLATE\s+(\w+)\s*{/) { #}
		$template = $1;
		$asm = "";
		next;
	    }
	    else {
               $line =~ m/(extern\s*)?(\w+)\s*{/; #}
		$extern = (defined($1))? 1 : 0;
		$function = $2;
		$asm = "";
		next;
	    }
        }
        if ($line =~ m/^}/) { #{
	    # end of template definition?
	    if (defined($template)) {
		$templates{$template} = $asm;
		$template = undef;
		next;
	    }
	    # no, end of function
	    # 1. check templates
	    while (my($t, $body) = each(%templates)) {
		if ($asm =~ /$t\s+/){
		    my $tbody = $body;
		    while ($asm =~ s/\b(s(.).+?\2.*?\2)(?:\s+)?//) {
			eval "\$tbody =~ ${1}g";
			if ($@) {
			    die "error in template subst: $@\n";
			}
		    }
		    $asm = $tbody;
		    # reset iterator for next run
		    keys(%templates);
		    last;
		}
	    }

	    # then do other substitutions
            $asm =~ s/([\&\*])([a-zA-Z_]+)\[(\d+)\]/make_subs($1,$2,$3)/ge;
            $asm =~ s/NEW_FIXUP/Parrot_jit_newfixup(jit_info)/g;
            $asm =~ s/CUR_FIXUP/jit_info->arena.fixups/g;
            $asm =~ s/NATIVECODE/jit_info->native_ptr/g;
            $asm =~ s/CUR_OPCODE/jit_info->cur_op/g;
            $asm =~ s/cur_opcode/jit_info->cur_op/g;
            $asm =~ s/MAP\[(\d)\]/MAP($1)/g;
            $asm =~ s/PUSH_MAPPED_REG\((\d)\)/Parrot_jit_push_registers(jit_info,$1)/g;
            $ops{$function} = [ $asm , $extern ];
            $function = undef;
        }
        $asm .= $line;
    }
    return %ops;
}

use Parrot::Vtable;
my $vtable;
my $vjit = 0;
sub vtable_num($) {
    my $meth = shift;
    unless ($vtable) {
	$vtable = parse_vtable();
    }
    my $i = 0;
    $vjit++;
    for my $entry (@{$vtable}) {
	return $i if ($entry->[1] eq $meth);
	$i++;
    }
    die("vtable not found for $meth\n");
}

open JITCPU, ">$ARGV[0]" or die;

print JITCPU<<END_C;
/*
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically from 'jit/$cpuarch/core.jit'
 * by $0.
 *
 * Any changes made here will be lost!
 *
 */

#include<parrot/parrot.h>
#include"parrot/jit.h"
#define JIT_EMIT 1

/*
 *define default jit_funcs, if architecture doesn't have these optimizations
 */
#define Parrot_jit_vtable1_op Parrot_jit_normal_op
#define Parrot_jit_vtable1r_op Parrot_jit_normal_op
#define Parrot_jit_vtable2rk_op Parrot_jit_normal_op
#define Parrot_jit_vtable3k_op Parrot_jit_normal_op
/*
 * the numbers corresspond to the registers
 */
#define Parrot_jit_vtable_112_op Parrot_jit_normal_op
#define Parrot_jit_vtable_221_op Parrot_jit_normal_op
#define Parrot_jit_vtable_1121_op Parrot_jit_normal_op
#define Parrot_jit_vtable_1123_op Parrot_jit_normal_op
#define Parrot_jit_vtable_2231_op Parrot_jit_normal_op
#define Parrot_jit_vtable_1r223_op Parrot_jit_normal_op
#define Parrot_jit_vtable_1r332_op Parrot_jit_normal_op

#define Parrot_jit_vtable_ifp_op Parrot_jit_cpcf_op
#define Parrot_jit_vtable_unlessp_op Parrot_jit_cpcf_op
#define Parrot_jit_vtable_newp_ic_op Parrot_jit_normal_op

#define Parrot_jit_restart_op Parrot_jit_cpcf_op

#include"parrot/jit_emit.h"

#undef CONST
#define IREG(i) interpreter->int_reg.registers[jit_info->cur_op[i]]
#define NREG(i) interpreter->num_reg.registers[jit_info->cur_op[i]]
#define PREG(i) interpreter->pmc_reg.registers[jit_info->cur_op[i]]
#define SREG(i) interpreter->string_reg.registers[jit_info->cur_op[i]]
#define CONST(i) interpreter->code->const_table->constants[jit_info->cur_op[i]]
#ifndef MAP
# define MAP(i) jit_info->optimizer->map_branch[jit_info->op_i + (i)]
#endif
END_C


%core_ops = readjit("jit/$cpuarch/core.jit");

print JITCPU $header if ($header);

my @jit_funcs;
push @jit_funcs, "Parrot_jit_fn_info_t op_jit[$core_numops] = {\n";

my $njit = scalar keys(%core_ops);

my $jit_fn_retn = "void";
my $jit_fn_params = "(Parrot_jit_info_t *jit_info, struct Parrot_Interp * interpreter)";

for ($i = 0; $i < $core_numops; $i++) {
    $body = $core_ops{$core_opfunc[$i]}[0];
    $extern = $core_ops{$core_opfunc[$i]}[1];

    my $jit_func;
    my $op = $Parrot::OpLib::core::ops->[$i];

    $precompiled = 0;
    if (!defined $body) {
	$precompiled = 1;
	$extern = 1;
	my $opbody = $op->body;
	if ($op->full_name eq 'new_p_ic') {
	    $jit_func = "Parrot_jit_vtable_newp_ic_op";
	    $opbody =~ /vtable->(\w+)/;
	    $extern = vtable_num($1);
	    #print "$jit_func $extern\n";
	}
	# jitable vtable funcs:
	# *) $1->vtable->{vtable}(interp, $1)
	elsif ($opbody =~ /
	^(?:.*\.ops")?\s+
	{{\@1}}->vtable->
	(\w+)
	\(interpreter,
	\s*
	{{\@1}}
	\);
	\s+{{\+=\d}}/xm) {
	    $jit_func = "Parrot_jit_vtable1_op";
	    $extern = vtable_num($1);
	    #print $op->full_name .": $jit_func $extern\n";
	}
	# *) $1 = $2->vtable->{vtable}(interp, $2)
	elsif ($opbody =~ /
	^(?:.*\.ops")?\s+
	{{\@1}}\s*=\s*
	{{\@2}}->vtable->
	(\w+)
	\(interpreter,
	\s*
	{{\@2}}
	\);
	\s+{{\+=\d}}/xm) {
	    $jit_func = "Parrot_jit_vtable1r_op";
	    $extern = vtable_num($1);
	    #print $op->full_name .": $jit_func $extern\n";
	}
	# *) $1 = $2->vtable->{vtable}(interp, $2, &key)
	elsif ($opbody =~ /
	^(?:.*\.ops")?\s+
	(?:INTVAL\s+key\s+=\s+{{\@3}};\s+)
	{{\@1}}\s*=\s*
	{{\@2}}->vtable->
	(\w+)
	\(interpreter,
	\s*
	{{\@2}},\s*&key
	\);
	\s+{{\+=\d}}/xm) {
	    $jit_func = "Parrot_jit_vtable2rk_op";
	    $extern = vtable_num($1);
	    #print $op->full_name .": $jit_func $extern\n";
	}
	# *) $X->vtable->{vtable}(interp, $Y, $Z)
	elsif ($opbody =~ /
	^(?:.*\.ops")?\s+
	{{\@(\d)}}->vtable->
	(\w+)
	\(interpreter,
	\s*
	{{\@(\d)}},\s*{{\@(\d)}}
	\);
	\s+{{\+=\d}}/xm) {
	    $jit_func = "Parrot_jit_vtable_$1$3$4_op";
	    $extern = vtable_num($2);
	    #print $op->full_name .": $jit_func $extern\n";
	}
	# *) $R = $X->vtable->{vtable}(interp, $Y, $Z)
	elsif ($opbody =~ /
	^(?:.*\.ops")?\s+
	{{\@(\d)}}\s*=\s*
	{{\@(\d)}}->vtable->
	(\w+)
	\(interpreter,
	\s*
	{{\@(\d)}},\s*{{\@(\d)}}
	\);
	\s+{{\+=\d}}/xm) {
	    $jit_func = "Parrot_jit_vtable_$1r$2$4$5_op";
	    $extern = vtable_num($3);
	    #print $op->full_name .": $jit_func $extern\n";
	}
	# *) $X->vtable->{vtable}(interp, $Y, $Z, $A)
	elsif ($opbody =~ /
	^(?:.*\.ops")?\s+
	{{\@(\d)}}->vtable->
	(\w+)
	\(interpreter,
	\s*
	{{\@(\d)}},\s*{{\@(\d)}},\s*{{\@(\d)}}
	\);
	\s+{{\+=\d}}/xm) {
	    $jit_func = "Parrot_jit_vtable_$1$3$4$5_op";
	    $extern = vtable_num($2);
	    #print $op->full_name .": $jit_func $extern\n";
	}
	# *) $1->vtable->{vtable}(interp, $1, &key, $3)
	elsif ($opbody =~ /
	^(?:.*\.ops")?\s+
	(?:INTVAL\s+key\s+=\s+{{\@2}};\s+)
	{{\@1}}->vtable->
	(\w+)
	\(interpreter,
	\s*
	{{\@1}},\s*&key,\s*{{\@3}}
	\);
	\s+{{\+=\d}}/xm) {
	    $jit_func = "Parrot_jit_vtable3k_op";
	    $extern = vtable_num($1);
	    #print $op->full_name .": $jit_func $extern\n";
	}
	# some specials
	elsif ($op->full_name eq 'if_p_ic') {
	    $jit_func = "Parrot_jit_vtable_ifp_op";
	    $opbody =~ /vtable->(\w+)/;
	    $extern = vtable_num($1);
	    #print "$jit_func $extern\n";
	}
	elsif ($op->full_name eq 'unless_p_ic') {
	    $jit_func = "Parrot_jit_vtable_unlessp_op";
	    $opbody =~ /vtable->(\w+)/;
	    $extern = vtable_num($1);
	    #print "$jit_func $extern\n";
	}

	elsif ($op->jump =~ /JUMP_RESTART/ ) {
	    $jit_func = "Parrot_jit_restart_op";
        }
	elsif ($op->jump) {
	    $jit_func = "Parrot_jit_cpcf_op";
	} else {
	    $jit_func = "Parrot_jit_normal_op";
	}
    }
    else
    {
        $jit_func = "$core_opfunc[$i]_jit";
    }

    unless($precompiled){
    print JITCPU "\nstatic $jit_fn_retn " . $core_opfunc[$i] . "_jit" . $jit_fn_params . "{\n$body}\n";
    }
    push @jit_funcs, "{ $jit_func, $extern }, \t" .
	    "/* op $i: $core_opfunc[$i] */\n";
}

print JITCPU @jit_funcs, "};\n";

print("jit2h: $njit (+ $vjit vtable) of $core_numops ops are JITed.\n");
sub make_subs {
    my ($ptr, $type, $index) = @_;
    return(($ptr eq '&' ? '&' : '') . sprintf($Parrot::OpTrans::C::arg_maps{$type_to_arg{$type}}, $index));
}
