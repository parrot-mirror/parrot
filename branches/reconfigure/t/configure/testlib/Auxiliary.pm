# Copyright (C) 2007, The Perl Foundation.
# $Id$
package Auxiliary;
use strict;
use warnings;
our ( @ISA, @EXPORT_OK );
@ISA       = qw(Exporter);
@EXPORT_OK = qw(
    test_step_thru_runstep
);
use Carp;
*ok = *Test::More::ok;
*isa_ok = *Test::More::isa_ok;
use lib qw( . lib ../lib ../../lib );
use Parrot::Configure;

sub test_step_thru_runstep {
    my ($conf, $pkg, $args, $stepnum) = @_;
    my ($task, $step_name, @step_params, $step, $ret);
    
    $conf->add_steps($pkg);
    $conf->options->set(%{$args});

    $task = $conf->steps->[$stepnum];
    $step_name   = $task->step;
    @step_params = @{ $task->params };

    $step = $step_name->new();
    ok(defined $step, "$step_name constructor returned defined value");
    isa_ok($step, $step_name);
    ok($step->description(), "$step_name has description");
    $ret = $step->runstep($conf);
    ok(defined $ret, "$step_name runstep() returned defined value");
}

1;

################### DOCUMENTATION ###################

=head1 NAME

Auxiliary - subroutines used in F<t/configure/*> tests

=head1 SYNOPSIS

    use lib qw( . lib ../lib ../../lib t/configure/testlib );
    use Auxiliary qw( test_step_thru_runstep );

    $parrot_version = Parrot::BuildUtil::parrot_version();
    $args = process_options( {
    argv            => [ ],
    script          => $0,
    parrot_version  => $parrot_version,
    svnid           => '$Id$',
} );

    $conf = Parrot::Configure->new;
    test_step_thru_runstep($conf, q{init::defaults}, $args, 0);

=head1 DESCRIPTION

The subroutines in this package are used to simplify tests found in
F<t/configure/>.

So far, only one subroutine is available for export on demand:
C<test_step_thru_runstep()>.  This subroutine takes as arguments the
Parrot::Configure object, a string holding the name of the step to be run,
hashref C<$args> which is the output of C<process_options()> and an integer
which, so far, must be manually incremented between invocations of the
subroutine.

Each invocation of C<test_step_thru_runstep()> runs 4 tests.

=head1 AUTHOR

David H Adler and James E Keenan

=head1 SEE ALSO

F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
