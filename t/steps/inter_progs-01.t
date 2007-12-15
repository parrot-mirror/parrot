#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# inter_progs-01.t

use strict;
use warnings;

# Please leave as 'no_plan'; see 'BUG' in POD.
use Test::More qw(no_plan);    # tests => 24;
use Carp;
use Data::Dumper;
use lib qw( lib t/configure/testlib t/steps/testlib );
use_ok('config::inter::progs');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Tie::Filehandle::Preempt::Stdin;
use IO::CaptureOutput qw| capture |;
use Auxiliary qw(
    get_step_name
    store_this_step_pure
    get_previous_state
);

my $pkg = get_step_name($0);
ok($pkg, "Step name has true value");
ok(store_this_step_pure($pkg), "State stored");

=for hints_for_testing Testing and refactoring of inter::progs should
entail understanding of issues discussed in the following RT tickets:
http://rt.perl.org/rt3/Ticket/Display.html?id=43174;
http://rt.perl.org/rt3/Ticket/Display.html?id=43173; and
http://rt.perl.org/rt3/Ticket/Display.html?id=41168.  You will have to
determine a way to test a user response to a prompt.

=cut

my $args = process_options(
    {
        argv => [q{--ask}],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;
$conf->refresh(get_previous_state($pkg));

my ( $task, $step_name, $step, $ret );

$conf->add_steps($pkg);
$conf->options->set( %{$args} );

$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );

my ( @prompts, $object );
foreach my $p (
    qw|
    cc
    link
    ld
    ccflags
    linkflags
    ldflags
    libs
    cxx
    |
    )
{
    push @prompts, $conf->data->get($p);
}
push @prompts, q{y};

$object = tie *STDIN, 'Tie::Filehandle::Preempt::Stdin', @prompts;
can_ok( 'Tie::Filehandle::Preempt::Stdin', ('READLINE') );
isa_ok( $object, 'Tie::Filehandle::Preempt::Stdin' );

{
    my ($ret, $stdout);
    capture(
        sub { $ret = $step->runstep($conf); },
        \$stdout,
    );
    ok( defined $ret, "$step_name runstep() returned defined value" );
}

$object = undef;
untie *STDIN;

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

inter_progs-01.t - test config::inter::progs

=head1 SYNOPSIS

    % prove t/steps/inter_progs-01.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::inter::progs.

=head1 BUG

This file tests the case where the C<--ask> option is specified and,
hence, the user must respond to a prompt.  The response to the prompt is
supplied automatically via Tie::Filehandle::Preempt::Stdin.  But that
response is made via C<STDOUT>.  A user generally would not like to see
that output when running this test, say, via C<prove -v>.  So the data
written to C<STDOUT> must be captured rather than displayed.

In other test files we can do that with Parrot::IO::Capture::Mini.  We
cannot do that here because there is extensive manipulation of C<STDOUT>
deep inside the code being tested.  The solution employed in this test
successfully disposes of information printed to C<STDOUT>, but it
confuses Test::Harness's count of tests run.  This would cause the file
as a whole to be reported as having failed, when in fact every single
test passed.  As a compromise, we run the file with C<no_plan>.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::inter::progs, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
