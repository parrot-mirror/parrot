#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# inter_make-02.t

use strict;
use warnings;
use Test::More tests =>  9;
use Carp;
use lib qw( lib t/configure/testlib );
use_ok('config::inter::make');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
is($trace->store_this_step(), 2,
    "Step stored; has previously been tested");

my $args = process_options(
    {
        argv => [q{--ask}],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new();
$conf->refresh($trace->get_previous_state());

my ( $task, $step_name, $step, $ret );
my $pkg = q{inter::make};

$conf->add_steps($pkg);
$conf->options->set( %{$args} );

$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );

$conf->data->set('gmake_version' => '4.1');
my $prog = 'gmake';
inter::make::_set_make_c($conf, $prog);
is($conf->data->get('make_c'), 'gmake -C',
    "make_c correctly set when gmake");

$conf->data->set('gmake_version' => undef);
my $str = q|$(PERL) -e 'chdir shift @ARGV; system q{$(MAKE)}, @ARGV; exit $$?  >> 8;'|;
$conf->data->set(make_c => $str);
$prog = 'make';
inter::make::_set_make_c($conf, $prog);
is($conf->data->get('make_c'),
    q|$(PERL) -e 'chdir shift @ARGV; system q{make}, @ARGV; exit $$?  >> 8;'|,
    "make_c correctly set when gmake");

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

inter_make-02.t - test config::inter::make

=head1 SYNOPSIS

    % prove t/steps/inter_make-02.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::inter::make.

B<Note:>  Since F<inter::make> probes for the F<make> program
found on a particular OS, it will probably be difficult to achieve high
branch or condition coverage.  The module is likely to discover a
F<make> program long before it reaches the point where it must prompt
the user for a response.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::inter::make, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
