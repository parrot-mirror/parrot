#! perl
# Copyright (C) 2009, Parrot Foundation.
# $Id$
# gen/libjit-01.t

use strict;
use warnings;

use constant NUM_GENERATED_FILES => 2;
# use Test::More tests => 8 + 2*NUM_GENERATED_FILES;
use Test::More qw( no_plan );

use File::Copy 'move';
use File::Temp 'tempfile';

use lib 'lib';
use Parrot::Configure;
use Parrot::Configure::Options 'process_options';
use Parrot::Configure::Test qw(
    test_step_thru_runstep
    rerun_defaults_for_testing
    test_step_constructor_and_description
);

use_ok('config::gen::libjit');

my ($args, $step_list_ref) = process_options(
    {
	argv => [],
	mode => 'configure',
    }
);

my $conf = Parrot::Configure->new;

my $serialized = $conf->pcfreeze();

my $pkg = 'gen::libjit';
$conf->add_steps($pkg);
$conf->options->set( %$args );
my $step = test_step_constructor_and_description($conf);

is( scalar keys %{$step->{targets}}, NUM_GENERATED_FILES,
    "Expected number of generated files");
is_deeply([keys %{$step->{targets}}], [keys %{$step->{templates}}],
    "Templates match targets");

foreach (keys %{$step->{templates}}) {
    ok(-f $step->{templates}{$_}, "Able to locate $_ template")
}

my %orig_files;
foreach (keys %{$step->{targets}}) {
    if (-f (my $targ_name = $step->{targets}{$_})) {
        $orig_files{$_} = tempfile();
        move($targ_name, $orig_files{$_});
    }
}

my %orig_conf = map { $_ => $conf->data->get($_) } qw[ iv nv ];
$conf->data->set( iv => 'int', nv => 'float' );
# Set a value for 'libjit_has_alloca' to avoid uninitialized value warning.
$conf->data->set( 'libjit_has_alloca' => 1 );
my $ret = $step->runstep($conf);
ok( $ret, "runstep() returned true value" );
foreach (keys %{$step->{targets}}) {
    ok(-f $step->{targets}{$_}, "$_ target generated");
}

# re-set for next test
$conf->data->set(%orig_conf);
$step->set_result( '' );
foreach (keys %{$step->{targets}}) {
    if (exists $orig_files{$_}) {
        move( $orig_files{$_}, $step->{targets}{$_} );
    } else {
        unlink $_;
    }
}

$conf->replenish($serialized);

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

  gen/libjit-01.t - test gen::libjit

=head1 SYNOPSIS

    % prove t/steps/gen/libjit-01.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test gen::libjit.

=head1 SEE ALSO

config::gen::libjit, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
#! perl
# Copyright (C) 2009, Parrot Foundation.
# $Id$
# auto/libjit-01.t

use strict;
use warnings;

use Test::More tests => 34;
use lib qw( lib t/configure/testlib );
use Parrot::Configure;
use Parrot::Configure::Options 'process_options';
use Parrot::Configure::Test qw(
    test_step_thru_runstep
    rerun_defaults_for_testing
    test_step_constructor_and_description
);
use IO::CaptureOutput qw( capture );

use_ok('config::init::defaults');
use_ok('config::auto::libjit');

my ($args, $step_list_ref) = process_options( {
        argv => [ q{--without-libjit} ],
        mode => 'configure',
} );

my $conf = Parrot::Configure->new;

my $serialized = $conf->pcfreeze();

test_step_thru_runstep( $conf, 'init::defaults', $args );

my $pkg = 'auto::libjit';
my ( $step, $ret );

$conf->add_steps($pkg);
$conf->options->set(%$args);
$step = test_step_constructor_and_description($conf);
$ret = $step->runstep($conf);
ok( $ret, "runstep() returned true value" );
is( $step->result(), 'no', "Result is 'no', as expected" );
is( $conf->data->get( 'HAS_LIBJIT' ), 0,
   "Got expected result with --without-libjit option" );
$conf->cc_clean();

$conf->replenish($serialized);

($args, $step_list_ref) = process_options( {
    argv => [ ],
    mode => q{configure},
} );
rerun_defaults_for_testing($conf, $args );
$conf->add_steps($pkg);
$conf->options->set( %{$args} );
$step = test_step_constructor_and_description($conf);
$ret = $step->runstep($conf);
ok( $ret, "runstep() returned true value" );
like( $step->result(), qr/yes|no/, "Result is either 'yes' or 'no'" );
ok( defined( $conf->data->get( 'HAS_LIBJIT' ) ),
   "'HAS_LIBJIT' has defined value" );
$conf->cc_clean();

########## _evaluate_cc_run ##########

my ($test, $has_libjit, $verbose);

$step->set_result( undef );

$test = q{USES INTERPRETER: 33};
$has_libjit = 0;
$verbose = 0;
$has_libjit = $step->_evaluate_cc_run($test, $has_libjit, $verbose);
ok( $has_libjit, "_evaluate_cc_run() returned true value, as expected" );
is( $step->result(), 'yes', "result is yes, as expected" );

$step->set_result( undef );

$test = q{foobar};
$has_libjit = 0;
$verbose = 0;
$has_libjit = $step->_evaluate_cc_run($test, $has_libjit, $verbose);
ok( ! $has_libjit, "_evaluate_cc_run() returned false value, as expected" );
ok( ! defined($step->result()), "result is undefined, as expected" );

$step->set_result( undef );

$test = q{USES INTERPRETER: 33};
$has_libjit = 0;
$verbose = 1;
{
    my ($stdout, $stderr);
    capture(
        sub { $has_libjit =
            $step->_evaluate_cc_run($test, $has_libjit, $verbose); },
        \$stdout,
        \$stderr,
    );
    ok( $has_libjit, "_evaluate_cc_run() returned true value, as expected" );
    is( $step->result(), 'yes', "result is yes, as expected" );
    like( $stdout, qr/\(yes\)/, "Got expected verbose output" );
}

########## _handle_has_libjit() ##########

my $extra_libs;

$conf->data->set( 'libjit_has_alloca' => undef );
$conf->data->set( 'libs' => '' );

$has_libjit = 1;
$extra_libs = 'mylibs';
$conf->data->set( 'cpuarch' => 'i386' );

auto::libjit::_handle_has_libjit($conf, $has_libjit, $extra_libs);
ok( $conf->data->get( 'libjit_has_alloca'),
    "on i386 with libJIT, 'libjit_has_alloca' has true value" );
is( $conf->data->get( 'libs' ), " $extra_libs",
    "Got expected value for libs" );

$conf->data->set( 'libjit_has_alloca' => undef );
$conf->data->set( 'libs' => '' );

$has_libjit = 1;
$extra_libs = 'mylibs';
$conf->data->set( 'cpuarch' => 'ppc' );

auto::libjit::_handle_has_libjit($conf, $has_libjit, $extra_libs);
ok( ! $conf->data->get( 'libjit_has_alloca'),
    "on non-i386 with libJIT, 'libjit_has_alloca' has false value" );
is( $conf->data->get( 'libs' ), " $extra_libs",
    "Got expected value for libs" );

$conf->data->set( 'libjit_has_alloca' => undef );
$conf->data->set( 'libs' => '' );

$has_libjit = 0;
$extra_libs = 'mylibs';

auto::libjit::_handle_has_libjit($conf, $has_libjit, $extra_libs);
ok( ! $conf->data->get( 'libjit_has_alloca'),
    "without libJIT, 'libjit_has_alloca' has false value" );
is( $conf->data->get( 'libs' ), "",
    "Got expected value for libs" );

################### DOCUMENTATION ###################

=head1 NAME

auto/libjit-01.t - test auto::libjit

=head1 SYNOPSIS

    % prove t/steps/auto/libjit-01.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test auto::libjit.

=head1 SEE ALSO

config::auto::libjit, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
