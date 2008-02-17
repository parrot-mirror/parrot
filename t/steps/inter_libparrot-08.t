#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# inter_libparrot-08.t

use strict;
use warnings;
use Test::More tests => 11;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::inter::libparrot');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Tie::Filehandle::Preempt::Stdin;
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
is($trace->store_this_step(), 2,
    "Step stored; has previously been tested");

my $args = process_options(
    {
        argv => [ q{--ask} ],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;
$conf->refresh($trace->get_previous_state());

my $pkg = q{inter::libparrot};
$conf->add_steps($pkg);
$conf->options->set( %{$args} );

my ( $task, $step_name, $step);
$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );

$conf->data->set('has_dynamic_linking' => 1);

my ( @prompts, $prompt, $object );

$prompt = q{n};
push @prompts, $prompt;

$object = tie *STDIN, 'Tie::Filehandle::Preempt::Stdin', @prompts;
can_ok( 'Tie::Filehandle::Preempt::Stdin', ('READLINE') );
isa_ok( $object, 'Tie::Filehandle::Preempt::Stdin' );

{
    open STDOUT, '>', "/dev/null" or croak "Unable to open to myout";
    my $ret = $step->runstep($conf);
    close STDOUT or croak "Unable to close after myout";
    ok( $ret, "$step_name runstep() returned true value" );
}

undef $object;
untie *STDIN;
is($step->result(), 'no', "Expected result was set");


pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

inter_libparrot-08.t - test config::inter::libparrot

=head1 SYNOPSIS

    % prove t/steps/inter_libparrot-08.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::inter::libparrot.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::inter::libparrot, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
