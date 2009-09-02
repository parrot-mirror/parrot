#!/usr/bin/perl

# Copyright (C) 2009, Parrot Foundation.
# $Id$


no warnings;
use v5.10.0;
use warnings;
use strict;

use Data::Dumper;

=head1 NAME

tools/dev/pprof2cg.pl

=head1 DESCRIPTION

Convert the output of Parrot's profiling runcore to a Callgrind-compatible
format.

=head1 USAGE

Generate a profile by passing C<-Rprofiling> to parrot, for example C<./parrot
-Rprofiling perl6.pbc hello.p6>.  Once execution completes, parrot will print a
message specifying the location of profile.  The profile will usually be named
parrot.XXXX.pprof, where XXXX is the PID of the parrot process.

=cut


my @ctx_stack = ();
my %stats;

my $total_time = 0;
my $prev_line = 0;


sub split_vars{
    my $href;
    my $str = shift;
    while ($str =~ /\G { ([^:]+) : (.*?) } /cxg) {
        $href->{$1} = $2;
    }
    return $href;
}

sub store_stats {
    my $stats_ref = shift;
    my $locator   = shift;
    my $time      = shift;
    my $extra     = shift;

    my $file   = $locator->{'file'};
    my $ns     = $locator->{'ns'};
    my $line   = $locator->{'line'};
    my $op_num = $locator->{'op_num'};

    if (exists $stats_ref->{$file}{$ns}{$line}[$op_num]) {
        $stats_ref->{$file}{$ns}{$line}[$op_num]{'hits'}++
            unless exists $extra->{no_hits};
        $stats_ref->{$file}{$ns}{$line}[$op_num]{'time'} += $time;
    }
    else {
        $stats_ref->{$file}{$ns}{$line}[$op_num]{'hits'}    = 1;
        $stats_ref->{$file}{$ns}{$line}[$op_num]{'time'}    = $time;
        for my $key (keys %{$extra}) {
            $stats_ref->{$file}{$ns}{$line}[$op_num]{$key} = $extra->{$key};
        }
    }
}


while (<>) {

    if (/^#/) {
        #comments are always ignored
    }
    elsif (/^VERSION:(\d+)$/) {
        my $version = $1;
        if ($version != 1) {
            die "profile was generated by an incompatible version of the profiling runcore.";
        }
    }
    #context switch
    elsif (/^CS:(.*)$/) {

        my $cs_hash      = split_vars($1);
        my $is_first     = $#ctx_stack == -1;
        my $is_redundant = !$is_first && ($ctx_stack[0]{'ctx'} eq $cs_hash->{'ctx'});
        my $is_call      = !scalar(grep {$_->{'ctx'} eq $cs_hash->{'ctx'}} @ctx_stack);

        if ($is_first) {
            $ctx_stack[0] = $cs_hash;
        } 
        elsif ($is_redundant) {
            #don't do anything
        } 
        elsif ($is_call) {
            
            $ctx_stack[0]{'op_num'}++;
            my $extra = {
                op_name => "CALL", 
                target  => $cs_hash->{'ns'}
            };
            store_stats(\%stats, $ctx_stack[0], 0, $extra );
            unshift @ctx_stack, $cs_hash;
        }
        else {
            shift @ctx_stack while ($ctx_stack[0]->{'ctx'} ne $cs_hash->{'ctx'});
        }
        print Dumper(\@ctx_stack);
    }
    elsif (/^OP:(.*)$/) {
        my $op_hash = split_vars($1);

        if (exists $ctx_stack[0]{'line'} && $op_hash->{'line'} == $ctx_stack[0]{'line'}) {
            $ctx_stack[0]{'op_num'}++;
        }
        else {
            $ctx_stack[0]{'op_num'} = 0;
        }

        $ctx_stack[0]{'line'} = $op_hash->{'line'};
        my $extra = { op_name => $op_hash->{'op'} };
        store_stats(\%stats, $ctx_stack[0], $op_hash->{'time'}, $extra);

        $extra->{'no_hits'} = 1;
        for my $frame (@ctx_stack[1 .. $#ctx_stack]) {
            store_stats(\%stats, $frame, $op_hash->{'time'}, $extra);
        }
    }
}


if (1) {
    for my $file (sort keys %stats) {
        for my $ns (sort keys %{ $stats{$file} }) {
            for my $line_num (sort {$a<=>$b} keys %{ $stats{$file}{$ns} }) {
                for my $op_numbr (0 .. $#{$stats{$file}{$ns}{$line_num}}) {

                    print "$file  $ns  line:$line_num  op:$op_numbr ";

                    for my $attr (sort keys %{ $stats{$file}{$ns}{$line_num}[$op_numbr] }) {
                        print "{ $attr => $stats{$file}{$ns}{$line_num}[$op_numbr]{$attr} } ";
                    }
                    say "";
                }
            }
            say "";
        }
    }
}


=head1

open(OUT_FH, ">parrot.out") or die "couldn't open parrot.out for writing";

say OUT_FH <<"HEADER";
version: 1
creator: 3.4.1-Debian
pid: 5751
cmd:  ./callgrind_test

part: 1
desc: I1 cache:
desc: D1 cache:
desc: L2 cache:
desc: Timerange: Basic block 0 - $total_time
desc: Trigger: Program termination
positions: line
events: Ir
summary: $total_time

HEADER

for $file (keys %stats) {

    say OUT_FH "fl=$file"; 

    for $func (keys %{ $stats{$file} }) {
        say OUT_FH "\nfn=$func";

        for $line (sort keys %{ $stats{$file}{$func} }) {

            if ($stats{$file}{$func}{$line}{line_calls_func}) {

                my $line_time = 0;
                my $func_op_num = 0;

                for $op_num (sort grep {$_ ne 'line_calls_func'} keys %{ $stats{$file}{$func}{$line} }) {

                    if ($stats{$file}{$func}{$line}{$op_num}{op} eq "FUNCTION_CALL") {
                        $func_op_num = $op_num;
                    }
                    else {
                        $line_time += $stats{$file}{$func}{$line}{$op_num}{time}
                            unless $stats{$file}{$func}{$line}{$op_num}{op} ~~ @call_ops;
                    }
                }
                say OUT_FH "$line $line_time";

                my $func_name = $stats{$file}{$func}{$line}{$func_op_num}{func_name};
                my $hits      = $stats{$file}{$func}{$line}{$func_op_num}{hits};
                $line_time = $stats{$file}{$func}{$line}{$func_op_num-1}{time};
                say OUT_FH "cfn=$func_name";
                say OUT_FH "calls=$hits $line_time";

                my $func_time = $stats{$file}{$func}{$line}{$func_op_num}{time};

                say OUT_FH "$line $func_time";
            }
            else {
                #aggregate all lines
                my $line_time = 0;
                for $op_num (sort grep {$_ ne 'line_calls_func'} keys %{ $stats{$file}{$func}{$line} }) {
                    $line_time += $stats{$file}{$func}{$line}{$op_num}{time};
                }
                say OUT_FH "$line $line_time";
            }
        }
    }
}

say OUT_FH "totals: $total_time";
