# Copyright (C) 2007, The Perl Foundation.
# $Id$
package Parrot::Configure::Test;
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

my $stepnum = 0;

sub test_step_thru_runstep {
    my ($conf, $pkg, $args) = @_;
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
    $stepnum++;
}

1;

################### DOCUMENTATION ###################

=head1 NAME

Parrot::Configure::Test - subroutines used in F<t/configure/*> tests

=head1 SYNOPSIS

    use lib qw( lib );
    use Parrot::Configure::Test qw( test_step_thru_runstep );

Set-up for C<test_step_thru_runstep()>:

    $parrot_version = Parrot::BuildUtil::parrot_version();
    $args = process_options( {
    argv            => [ ],
    script          => $0,
    parrot_version  => $parrot_version,
    svnid           => '$Id$',
} );

    $conf = Parrot::Configure->new;
    test_step_thru_runstep($conf, q{init::defaults}, $args);

=head1 DESCRIPTION

The subroutines in this package are used to simplify tests found in
F<t/configure/>.  Any subroutine in this package should be functional
(C<i.e.>, not object-oriented), be exported only on demand and have all its
arguments explicitly passed as arguments.

=head1 FUNCTIONS

=head2 C<test_step_thru_runstep()>

=over 4

=item * Purpose

Reduce code repeated in many test files in the F<t/configure/101+> series.
Execution of certain configuration steps depends upon successful
execution of some (though not necessarily all) of the preceding configuration
steps.  Hence, unit tests of the packages generating certain steps may require
execution of preceding steps in the test file.  Once you determine that you
need to execute one step as a prerequisite to another, you can provide that
step as an argument to C<test_step_thru_runstep()> and not worry about it
further.

=item * Arguments

List of three arguments:

=over 4

=item *

Parrot::Configure object

=item *

string holding the name of the step to be run

=item *

hash reference which is the output of
C<Parrot::Configure::Options::process_options()>.

=back

=item * Return Value

No explicit return value.

=item * Comment

Each invocation of C<test_step_thru_runstep()> runs 4 Test::More tests.

=back

=head1 AUTHORS

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
