package Parrot::Docs::SearchOps;
# Copyright (C) 2004, The Perl Foundation.
# $Id$

use strict;
use warnings;

use Exporter;
use Text::Wrap;
use lib qw( ./lib );
use Parrot::Configure::Utils qw( _slurp );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw(
    search_all_ops_files
    Usage
);

sub search_all_ops_files {
    my ($pattern, $wrap_width, $opsdir) = @_;
    $Text::Wrap::columns = $wrap_width;
    my @opsfiles = glob("$opsdir/*.ops");

    my $total_identified = 0;
    foreach my $f (@opsfiles) {
        $total_identified = _search_one_ops_file(
            $pattern, $wrap_width, $total_identified, $f,
        );
    }
    return $total_identified;
}

sub _search_one_ops_file {
    my ($pattern, $wrap_width, $total_identified, $f) = @_;
    my @paras = split /\n{2,}/, _slurp($f);
    my %iden_paras = ();
    for (my $i=0; $i<=$#paras; $i++) {
        my $j = $i+1;
        if (
            $paras[$i] =~ /^=item\sB<(\w*$pattern\w*)>\(([^)]+)\)/o
                and
            $paras[$j]
        ) {
            $iden_paras{$i}{op} = $1;
            $iden_paras{$i}{args} = $2;
        }
    }
    if (keys %iden_paras) {
        my @keys = keys %iden_paras;
        my $seen = scalar @keys;
        $total_identified += $seen;
        _print_name(\@paras, $wrap_width, $seen);
        my @sorted_idx = sort {$a <=> $b} @keys;
        my %remain_paras = map {$_, 1} @keys;
        foreach my $idx (@sorted_idx) {
            if ($remain_paras{$idx}) {
                my $k = _handle_indices(
                    \%iden_paras,
                    $idx,
                    \%remain_paras,
                );
                print fill('', '', ($paras[$k])), "\n\n";
            }
        }
    }
    return $total_identified;
}

sub _print_name {
    my $parasref = shift;
    my $wrap_width = shift;
    my $count = shift;
    NAME: for (my $i=0; $i<=$#$parasref; $i++) {
        my $j = $i+1;
        if ($parasref->[$i] =~ /^=head1\s+NAME/o and $parasref->[$j]) {
            my $str = qq{\n};
            $str .= q{-} x $wrap_width . qq{\n};
            $str .= $parasref->[$j] .
                q<  (> .
                $count .
                q< > .
                ($count > 1 ?  q<matches> : q<match>) .
                qq<)\n>;
            $str .= q{-} x $wrap_width .  qq{\n};
            $str .= qq{\n};
            print $str;
            last NAME;
        }
    }
}

sub _handle_indices {
    my ($identified_ref, $idx, $remaining_ref) = @_;
    my $j = $idx + 1;
    my $k = $j;
    print qq{$identified_ref->{$idx}{op}($identified_ref->{$idx}{args})\n};
    delete $remaining_ref->{$idx};
    if (defined %{$identified_ref->{$j}} ) {
        $k = _handle_indices(
            $identified_ref,
            $j,
            $remaining_ref,
        );
    }
    return $k;
}

sub Usage {
    print <<USAGE;
    tools/docs/search-ops.pl some_ops_pattern

Given a valid Perl 5 regex as an argument, the script will search inside
any *.ops file located in 'path' for an opcode name that matches, dumping both
its arguments and its description.

The program must be called from the top-level Parrot directory.

To dump every op, call '--all' on the command line.

Example:
> tools/docs/search-ops.pl load

----------------------------------------------------------------------
File: core.ops - Parrot Core Ops (2 matches)
----------------------------------------------------------------------

load_bytecode(in STR)
Load Parrot bytecode from file \$1, and (TODO) search the library path,
to locate the file.

loadlib(out PMC, in STR)
Load a dynamic link library named \$2 and store it in \$1.

----------------------------------------------------------------------
File: debug.ops (1 match)
----------------------------------------------------------------------

debug_load(inconst STR)
Load a Parrot source file for the current program.
USAGE
}

1;

=head1 NAME

Parrot::Docs::SearchOps - functions used in tools/docs/search-ops.pl

=head1 SYNOPSIS

    use Parrot::Docs::SearchOps qw(
        search_all_ops_files
        Usage
    );

=head1 DESCRIPTION

=cut



