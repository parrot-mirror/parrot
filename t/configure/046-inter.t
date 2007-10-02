#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 046-inter.t

use strict;
use warnings;
use Test::More tests => 11;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('inter::theta');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::IO::Capture::Mini;
use Tie::Filehandle::Preempt::Stdin;

$| = 1;
is( $|, 1, "output autoflush is set" );

my $args = process_options(
    {
        argv => [],
        mode => q{configure},
    }
);
ok( defined $args, "process_options returned successfully" );
my %args = %$args;

my $conf = Parrot::Configure->new;
ok( defined $conf, "Parrot::Configure->new() returned okay" );

my ( $task, $step_name, @step_params, $step, $ret );
my $pkg = q{inter::theta};

$conf->add_steps($pkg);
$conf->options->set( %{$args} );

$task        = $conf->steps->[0];
$step_name   = $task->step;
@step_params = @{ $task->params };

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );
my ( @prompts, $object );
@prompts = (q{n});
$object = tie *STDIN, 'Tie::Filehandle::Preempt::Stdin', @prompts;
can_ok( 'Tie::Filehandle::Preempt::Stdin', ('READLINE') );
isa_ok( $object, 'Tie::Filehandle::Preempt::Stdin' );

$ret = $step->runstep($conf);
ok( defined $ret, "$step_name runstep() returned defined value" );

$object = undef;
untie *STDIN;

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

046-inter.t - test Parrot::Configure::_run_this_step() with regard to configuration steps that prompt for user input

=head1 SYNOPSIS

    % prove t/configure/046-inter.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

