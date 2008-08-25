#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# gen_makefiles-01.t

use strict;
use warnings;
my @cond_tests;
my @conf_args = ( dummy1 => 1, dummy2 => 0, dummy3 => 'xx' );
BEGIN {
    @cond_tests =
      (# test                true or false
       ["+(dummy1)", 		1],
       ["+(dummy2)", 		0],
       ["+(dummy1 dummy2)",	1],
       ["+(and dummy1 dummy2)", 0],
       ["-(dummy1)",		0],
       ["-(dummy2)",		1],
       ["-(dummy1 dummy2)",	0],
       ["-(and dummy1 dummy2)",	1],
       ["+(dummy3=xx)",		1],
       ["+(dummy3=xxy)",	0],
       ["-(dummy3=xx)",		0],
       ["-(dummy3=xxy)",	1],
       ["+(dummy1=1)",		1],
       ["+(dummy2=0)",		1],
       ["+($^O)",		1],
       ["+(not$^O)",		0],
       ["-($^O)",		0],
       ["-(not$^O)",		1],
       ["+(or dummy1 dummy2)",	1],
       ["-(or dummy1 dummy2)",	0],
       ["+(or dummy1 (not dummy2))",	1],
       ["+(and dummy1 (not dummy2))",	1],
       ["+(and (not dummy2) dummy1)",	1],
       # break it with whitespace
       ["+( or dummy1(not dummy2))",	1],
       ["+(or dummy1(not dummy2))",	1],
      );
}
use Test::More tests => (7 + scalar(@cond_tests));
use Carp;
use lib qw( . lib );
use_ok('config::gen::makefiles');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Test qw(
    test_step_thru_runstep
    test_step_constructor_and_description
);

########## regular ##########

my $args = process_options(
    {
        argv => [ ],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;
my $pkg = q{gen::makefiles};
$conf->add_steps($pkg);
$conf->options->set( %{$args} );
my $step = test_step_constructor_and_description($conf);
my $missing_SOURCE = 0;
my %makefiles = %{ $step->{makefiles} };
foreach my $k ( keys %makefiles ) {
    $missing_SOURCE++ unless (-f $makefiles{$k}{SOURCE});
}
is($missing_SOURCE, 0, "No Makefile source file missing");
ok(-f $step->{CFLAGS_source}, "CFLAGS source file located");

sub result {
    my $c = shift;
    my $s = $c->[0];
    $s =~ s/^\+/plus_/;
    $s =~ s/^\-/minus_/;
    $s =~ s/[\()]//g;
    $s =~ s/ /_/g;
    return $s."=".($c->[1]?"true":"false");
}
# test #+(keys):line RT #57548
$conf->data->set( @conf_args );
open IN, ">", "Makefile_$$.in";
print IN "# There should only be true results in .out\n";
for my $c (@cond_tests) {
    my $result = result($c);
    print IN "#$c->[0]:$result\n";
}
close IN;
$conf->genfile("Makefile_$$.in", "Makefile_$$.out",
	       (makefile => 1, conditioned_lines => 1));
open OUT, "<", "Makefile_$$.out";
my $f;
{
    local $/;
    $f = <OUT>;
}
END {
    unlink "Makefile_$$.in", "Makefile_$$.out";
}
for my $c (@cond_tests) {
    my $result = result($c);
    ok(($c->[1] ? $f =~ /^$result$/m : $f !~ /^$result$/m), "$result");
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

gen_makefiles-01.t - test gen::makefiles

=head1 SYNOPSIS

    % prove t/steps/gen_makefiles-01.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test gen::makefiles.

=head1 AUTHOR

James E Keenan

Reini Urban (#+, #-)

=head1 SEE ALSO

config::gen::makefiles, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
