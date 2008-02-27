#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# inter_shlibs-02.t

use strict;
use warnings;
use Test::More tests => 11;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::inter::shlibs');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Tie::Filehandle::Preempt::Stdin;
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
ok($trace->store_this_step(),
    "Step stored; has previously been tested");

my $args = process_options(
    {
        argv => [q{--ask}],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;
$conf->refresh($trace->get_previous_state());

my $pkg = q{inter::shlibs};

$conf->add_steps($pkg);
$conf->options->set( %{$args} );

my ( $task, $step_name, $step);
$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );

my ( @prompts, $prompt, $object );

$prompt = q{ };
push @prompts, $prompt;

$object = tie *STDIN, 'Tie::Filehandle::Preempt::Stdin', @prompts;
can_ok( 'Tie::Filehandle::Preempt::Stdin', ('READLINE') );
isa_ok( $object, 'Tie::Filehandle::Preempt::Stdin' );

{
    open STDOUT, '>', "/dev/null" or croak "Unable to open to myout";
    my $ret = $step->runstep($conf);
    close STDOUT or croak "Unable to close after myout";
    ok( $ret, "$step_name runstep() returned true value" );
    is( $step->result(), q{done}, "Expected result was set" );
}

undef $object;
untie *STDIN;

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

inter_shlibs-02.t - test config::inter::shlibs

=head1 SYNOPSIS

    % prove t/steps/inter_shlibs-02.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::inter::shlibs.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::inter::shlibs, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
