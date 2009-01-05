#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# gen_makefiles-01.t

use strict;
use warnings;
my @cond_tests;
my @conf_args = ( true => 1, false => 0, value => 'xx' );
BEGIN {
    @cond_tests =
      (
       # perl-syntax       true or false
       ["IF(true)", 		1],
       ["IF(false)", 		0],
       ["UNLESS(true)",	        0],
       ["UNLESS(false)",	1],
       ["IF(true | false)",	1],
       ["IF(true & false)",     0],
       ["IF(true or true)",     1],
       ["IF(true or false)",    1],
       ["IF(false or true)",    1],
       ["IF(false or false)",   0],
       ["IF(true and true)",    1],
       ["IF(true and false)",   0],
       ["IF(false and true)",   0],
       ["IF(false and false)",  0],
       ["UNLESS(true|false)",   0],
       ["UNLESS(true&false)",   1],
       ["IF(!false)", 		1],
       ["IF(true)", 		1],
       ["ELSIF(value)", 	0],
       ["ELSE", 	        0],
       ["IF(false)", 		0],
       ["ELSIF(value)", 	1],
       ["ELSE", 	        0],
       ["IF(false)", 		0],
       ["ELSIF(false)", 	0],
       ["ELSE", 	        1],
       # Exercise the parser
       ["IF(true and (!false and value))",  1],
       ["IF(true and (!false) and value)",  1],
       ["IF(true and !false and value)",    1, 'no parens'],
       ["IF(true and not false and value)", 1, 'no parens'],
       ["IF(true&!false&value)",            1],
       ["IF(false or (!false and value))",  1, 'not parser problem'],
       ["UNLESS(!(true&!false&value))",     1, 'no ws, but nested parens'],
       ["IF(true&(!false&false))",          0, 'not precedence'],
       ["IF(true&(!false&value))",          1],
       ["IF(not true and value)",           0, 'not precedence over and'],
       ["IF(not false and value)",          1],
       ["IF((not false) and value)",        1],
       ["IF(not (false and value))",        1],
       ["IF(not (false or value))",         0],
       ["IF(true and not false)",           1],
       # platform
       ["IF(someplatform)",		    1],
       ["IF(not someplatform)",		    0],
       ["UNLESS(someplatform)",		    0],
       ["UNLESS(not someplatform)",	    1],
       # key==value
       ["IF(value==xx)",                    1],
       ["IF(value==xxy)",                   0],
       ["UNLESS(value==xx)",                0],
       ["UNLESS(value==xxy)",               1],
       ["IF(true & (value==xx & (!false)))",1],
       # These are invalid:
       #["IF(value == xx)",                  0], # invalid op error
       #["IF(value = xx)",                   0], # invalid op error
       ["IF(value=xx)",                     0], # also invalid, no warning. checks for key value=xx

       # Legacy syntax                 true or false
       ["CONDITIONED_LINE(true)", 	    1],
       ["INVERSE_CONDITIONED_LINE(true)",   0],
       ["CONDITIONED_LINE(false)", 	    0],
       ["INVERSE_CONDITIONED_LINE(false)",  1],
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

my ($args, $step_list_ref) = process_options(
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

my $index = undef;
sub result {
    my $c = shift;
    my $s = $c->[0];
    $s =~ s/^\+/plus_/;
    $s =~ s/^\-/minus_/;
    $s =~ s/\|/OR/g;
    $s =~ s/\&/AND/g;
    $s =~ s/\!/NOT/g;
    $s =~ s/[\()]//g;
    $s =~ s/ /_/g;
    $s .= ("_".++$index) if $s =~ /^(ELSE|ELSIF)/;
    return $s."=".($c->[1]?"true":"false");
}
# test #IF(keys):line
$conf->data->set( @conf_args, ('osname' => 'someplatform' ) );
open IN, ">", "Makefile_$$.in";
print IN "# There should only be =true results in .out\n";
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
$index = undef;
for my $c (@cond_tests) {
    my $result = result($c);
    if ($c->[2] and $c->[2] =~ /^TODO(.*)$/) {
        local $TODO = $1;
        ok(($c->[1] ? $f =~ /^$result$/m : $f !~ /^$result$/m), "$result");
    }
    else {
        ok(($c->[1] ? $f =~ /^$result$/m : $f !~ /^$result$/m), "$result".($c->[2]?" $c->[2]":''));
    }
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

=head1 SEE ALSO

config::gen::makefiles, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
