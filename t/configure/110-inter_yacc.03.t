#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id: 110-inter_yacc.03.t 19598 2007-07-05 00:07:53Z jkeenan $
# 110-inter_yacc.03.t

use strict;
use warnings;
use Test::More qw(no_plan); # tests => 12;
use Carp;
use lib qw( . lib ../lib ../../lib t/configure/testlib );
use_ok('config::init::defaults');
$ENV{TEST_YACC} = 'foobar';
use_ok('config::inter::yacc');
use Parrot::BuildUtil;
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Auxiliary qw( test_step_thru_runstep);

my $parrot_version = Parrot::BuildUtil::parrot_version();
my $args = process_options( {
    argv            => [ q{--ask}, q{--maintainer} ],
    script          => $0,
    parrot_version  => $parrot_version,
    svnid           => '$Id: 109-inter_yacc.03.t 19525 2007-07-01 16:31:02Z jkeenan $',
} );

my $conf = Parrot::Configure->new();

test_step_thru_runstep($conf, q{init::defaults}, $args, 0);

my ($task, $step_name, @step_params, $step, $ret);
my $pkg = q{inter::yacc};

$conf->add_steps($pkg);
$conf->options->set(%{$args});

$task = $conf->steps->[1];
$step_name   = $task->step;
@step_params = @{ $task->params };

$step = $step_name->new();
ok(defined $step, "$step_name constructor returned defined value");
isa_ok($step, $step_name);
ok($step->description(), "$step_name has description");
$ret = $step->runstep($conf);
is($ret, undef, "$step_name runstep() returned undefined value");
my $result_expected = q{no yacc program was found}; 
is($step->result(), $result_expected,
    "Result was $result_expected");

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

110-inter_yacc.03.t - test config::inter::yacc

=head1 SYNOPSIS

    % prove t/configure/110-inter_yacc.03.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::inter::yacc. In
this case, only the C<--ask> option is provided.  Because the C<--maintainer>
option is not provided, the step is skipped and no prompt is ever reached.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::inter::yacc, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
