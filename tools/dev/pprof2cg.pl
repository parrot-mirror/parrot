#!/usr/bin/perl

# Copyright (C) 2009, Parrot Foundation.
# $Id$

use strict;
use warnings;

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
parrot.pprof.XXXX, where XXXX is the PID of the parrot process.

To generate a Callgrind-compatible profile, run this script with the pprof
filename as the first argument.  The output file will be in parrot.out.XXXX,
where XXXX again is the PID of the original parrot process.

XXX: document $stats format

=cut



main(\@ARGV);

sub main {
    my $argv      = shift;
    my $stats     = {};
    my $ctx_stack = [];
    my $filename  = $argv->[0];

    open(my $in_fh, '<', $filename) or die "couldn't open $filename for reading: $!";

    while (<$in_fh>) {
        my $line = $_;
        process_line($line, $stats, $ctx_stack);
    }
    close($in_fh) or die "couldn't close $filename: $!";

    #print_stats($stats);

    unless ($filename =~ s/\.pprof\./.out./) {
        $filename = "$filename.out";
    }

    open(my $out_fh, '>', $filename) or die "couldn't open $filename for writing: $!";
    my $cg_profile = get_cg_profile($stats);
    print $out_fh $cg_profile;
    close($out_fh) or die "couldn't close $filename: $!";
}


sub process_line {

    my $line      = shift;
    my $stats     = shift;
    my $ctx_stack = shift;

    for ($line) {
        if (/^#/) {
            #comments are always ignored
        }
        elsif (/^VERSION:(\d+)$/) {
            my $version = $1;
            if ($version != 1) {
                die "profile was generated by an incompatible version of the profiling runcore.";
            }
        }
        elsif (/^CLI:(.*)$/) {
            $stats->{'global_stats'}{'cli'} = $1;
        }
        #context switch
        elsif (/^CS:(.*)$/) {

            my $cs_hash      = split_vars($1);
            my $is_first     = scalar(@$ctx_stack) == 0;
            my $is_redundant = !$is_first && ($ctx_stack->[0]{'ctx'} eq $cs_hash->{'ctx'});
            my $reused_ctx   = $is_redundant && ($ctx_stack->[0]{'sub'} ne $cs_hash->{'sub'});
            my $is_call      = scalar(grep {$_->{'ctx'} eq $cs_hash->{'ctx'}} @$ctx_stack) == 0;

            if ($is_first) {
                $ctx_stack->[0] = $cs_hash;
            }
            elsif ($reused_ctx) {
                $ctx_stack->[0]{'sub'} = $cs_hash->{'sub'};
                $ctx_stack->[0]{'ns'}  = $cs_hash->{'ns'};
            }
            elsif ($is_redundant) {
                #don't do anything
            }
            elsif ($is_call) {
                $ctx_stack->[0]{'op_num'}++;
                my $extra = {
                    op_name => "CALL",
                    target  => $cs_hash->{'ns'}
                };
                store_stats($stats, $ctx_stack->[0], 0, $extra );
                unshift @$ctx_stack, $cs_hash;
            }
            else {
                #shift contexts off the stack until one matches the current ctx
                while ($ctx_stack->[0]->{'ctx'} ne $cs_hash->{'ctx'}) {
                    my $ctx = shift @$ctx_stack;
                }
            }
            #print Dumper($ctx_stack);
        }
        elsif (/^END_OF_RUNLOOP$/) {
            #end of loop
            @$ctx_stack = ();
        }
        elsif (/^OP:(.*)$/) {
            my $op_hash = split_vars($1);

            die "input file did not specify an initial context" if (@$ctx_stack == 0);

            if (exists $ctx_stack->[0]{'line'} && $op_hash->{'line'} == $ctx_stack->[0]{'line'}) {
                $ctx_stack->[0]{'op_num'}++;
            }
            else {
                $ctx_stack->[0]{'op_num'} = 0;
            }

            $ctx_stack->[0]{'line'} = $op_hash->{'line'};
            my $extra = { op_name => $op_hash->{'op'} };
            store_stats($stats, $ctx_stack->[0], $op_hash->{'time'}, $extra);

            $extra->{'no_hits'} = 1;
            for my $frame (@$ctx_stack[1 .. scalar(@$ctx_stack)-1 ]) {
                store_stats($stats, $frame, $op_hash->{'time'}, $extra);
            }
        }
        else {
            die "Unrecognized line format: \"$line\"";
        }
    }
}

sub print_stats {
    my $stats = shift;

    for my $file (grep {$_ ne 'global_stats'} sort keys %$stats) {
        for my $ns (sort keys %{ $stats->{$file} }) {
            for my $line_num (sort {$a<=>$b} keys %{ $stats->{$file}{$ns} }) {
                for my $op_num (0 .. $#{$stats->{$file}{$ns}{$line_num}}) {

                    print "$file  $ns  line/op:$line_num/$op_num ";

                    for my $attr (sort keys %{ $stats->{$file}{$ns}{$line_num}[$op_num] }) {
                        print "{ $attr => $stats->{$file}{$ns}{$line_num}[$op_num]{$attr} } ";
                    }
                    print "\n";
                }
            }
            print "\n";
        }
    }
}

sub split_vars {
    my $href;
    my $str = shift;
    while ($str =~ /\G { ([^:]+) : (.*?) } /cxg) {
        $href->{$1} = $2;
    }
    return $href;
}

sub store_stats {
    my $stats   = shift;
    my $locator = shift;
    my $time    = shift;
    my $extra   = shift;

    my $file   = $locator->{'file'};
    my $ns     = $locator->{'ns'};
    my $line   = $locator->{'line'};
    my $op_num = $locator->{'op_num'};

    if (exists $stats->{'global_stats'}{'total_time'}) {
        $stats->{'global_stats'}{'total_time'} += $time;
    }
    else {
        $stats->{'global_stats'}{'total_time'} = $time;
    }

    if (exists $stats->{$file}{$ns}{$line}[$op_num]) {
        $stats->{$file}{$ns}{$line}[$op_num]{'hits'}++
            unless exists $extra->{no_hits};
        $stats->{$file}{$ns}{$line}[$op_num]{'time'} += $time;
    }
    else {
        $stats->{$file}{$ns}{$line}[$op_num]{'hits'} = 1;
        $stats->{$file}{$ns}{$line}[$op_num]{'time'} = $time;
        for my $key (keys %{$extra}) {
            $stats->{$file}{$ns}{$line}[$op_num]{$key} = $extra->{$key};
        }
    }
}


sub get_cg_profile {

    my $stats = shift;
    my @output = ();

    push @output, <<"HEADER";
version: 1
creator: 3.4.1-Debian
pid: 5751
cmd: $stats->{'global_stats'}{'cli'}

part: 1
desc: I1 cache:
desc: D1 cache:
desc: L2 cache:
desc: Timerange: Basic block 0 - $stats->{'global_stats'}{'total_time'}
desc: Trigger: Program termination
positions: line
events: Ir
summary: $stats->{'global_stats'}{'total_time'}

HEADER

    for my $file (grep {$_ ne 'global_stats'} keys %$stats) {

        push @output, "fl=$file";

        for my $ns (keys %{ $stats->{$file} }) {
            push @output, "\nfn=$ns";

            for my $line (sort keys %{ $stats->{$file}{$ns} }) {

                my $curr_op  = 0;
                my $op_count = scalar(@{$stats->{$file}{$ns}{$line}});
                my $op_time  = 0;

                #XXX: "cache" $stats->{$file}{$ns}{$line}[$curr_op]
                while ($curr_op < $op_count && $stats->{$file}{$ns}{$line}[$curr_op]{'op_name'} ne 'CALL') {
                    $op_time += $stats->{$file}{$ns}{$line}[$curr_op]{'time'};
                    $curr_op++;
                }
                push @output, "$line $op_time";

                if ($curr_op < $op_count && $stats->{$file}{$ns}{$line}[$curr_op]{'op_name'} eq 'CALL') {
                    my $call_target = $stats->{$file}{$ns}{$line}[$curr_op]{'target'};
                    my $call_count  = $stats->{$file}{$ns}{$line}[$curr_op]{'hits'};
                    my $call_cost   = $stats->{$file}{$ns}{$line}[$curr_op]{'time'};

                    push @output, "cfn=$call_target";
                    push @output, "calls=$call_count $call_cost";
                }

                if ($curr_op < $op_count) {
                    $op_time = 0;
                    while ($curr_op < $op_count) {
                        $op_time += $stats->{$file}{$ns}{$line}[$curr_op]{'time'};
                        $curr_op++;
                    }
                    push @output, "$line $op_time";
                }
            }
        }
    }

    push @output, "totals: $stats->{'global_stats'}{'total_time'}";
    return join("\n", @output);
}
