# perl
use strict;
use warnings;
use Carp;
use Text::Wrap;
use lib qw( ./lib );
use Parrot::Configure::Utils qw( _slurp );

my $wrap_width = 70;
$Text::Wrap::columns = $wrap_width;

croak "You may search for only 1 ops code at a time: $!"
    if @ARGV > 1;
my $pattern = $ARGV[0] ||= q{};

my $opsdir = q{src/ops};
my @opsfiles = glob("$opsdir/*.ops");

my $total_identified = 0;
foreach my $f (@opsfiles) {
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
        print_name(\@paras, $wrap_width, $seen);
        my @sorted_idx = sort {$a <=> $b} @keys;
        my %remain_paras = map {$_, 1} @keys;
        foreach my $idx (@sorted_idx) {
            if ($remain_paras{$idx}) {
                my $k = handle_indices(
                    \%iden_paras,
                    $idx,
                    \%remain_paras,
                );
                print fill('', '', ($paras[$k])), "\n\n";
            }
        }
    }
}

print "No matches were found\n" unless $total_identified;

##### SUBROUTINES #####

sub print_name {
    my $parasref = shift;
    my $wrap_width = shift;
    my $count = shift;
    NAME: for (my $i=0; $i<=$#$parasref; $i++) {
        my $j = $i+1;
        if ($parasref->[$i] =~ /^=head1\s+NAME/o and $parasref->[$j]) {
            my $str = qq{\n};
            $str .= q{-} x $wrap_width, qq{\n};
            $str .= $parasref->[$j],
                q<  (>,
                $count,
                q< >,
                ($count > 1 ?  q<matches> : q<match>),
                qq<)\n>;
            $str .= q{-} x $wrap_width,  qq{\n};
            $str .= qq{\n};
            print $str;
            last NAME;
        }
    }
}

sub handle_indices {
    my ($identified_ref, $idx, $remaining_ref) = @_;
    my $j = $idx + 1;
    my $k = $j;
    print qq{$identified_ref->{$idx}{op}($identified_ref->{$idx}{args})\n};
    delete $remaining_ref->{$idx};
    if (defined %{$identified_ref->{$j}} ) {
        $k = handle_indices(
            $identified_ref,
            $j,
            $remaining_ref,
        );
    }
    return $k;
}

