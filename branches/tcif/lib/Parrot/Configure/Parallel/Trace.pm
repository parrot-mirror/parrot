# Copyright (C) 2007, The Perl Foundation.
# $Id$
package Parrot::Configure::Parallel::Trace;

=head1 NAME

Parrot::Configure::Parallel::Trace - Manipulate a Parrot::Configure::Parallel object during testing of configuration step classes.

=head1 SYNOPSIS

    use Parrot::Configure::Parallel::Trace;

    $trace =
        Parrot::Configure::Parallel::Trace->new('current_test_script');

    $step_name = $trace->get_step_name();

    $step_position = $trace->get_step_position();

    $stepsref = $trace->get_all_step_positions();

    $sto = $trace->get_storable_file();

    $state = $trace->retrieve_state();

    $trace->dump_state();

    $trace->get_previous_state();

    $trace->update_state( {
        state       => $state,
        conf        => $conf,
    } );

    $trace->store_this_step();

Used only in configuration step tests found in F<t/steps/>.

=cut

use strict;
use warnings;
use Carp;
use Data::Dumper;
local $Data::Dumper::Indent = 1;
use File::Basename;
use Storable qw( nstore retrieve );
use lib qw( lib config );
use Parrot::Configure::Step::List ();
use Parrot::Configure::Parallel;
use Parrot::Configure::Options qw( process_options );

our $sto = q{.configure_parallel.sto};

=head1 METHODS

=head2 C<new()>

B<Purpose:>  Constructor.

B<Arguments:>  Single argument, which is a string representing a
filename.  In actual use, the filename is that of the calling test
script, I<i.e.>, Perl's C<$0>.

    $trace = Parrot::Configure::Parallel::Trace->new($0);

B<Return Value:>  Hash reference blessed into class
Parrot::Configure::Parallel::Trace.  Hash starts off with these
elements:

=over 4

=item * C<sto>

The name of the Storable file on disk holding the results of parallel
configuration.  Value is a string.

=item * C<position>

Table mapping the sequence positions of the configuration steps to their
names.  Value is a hash reference with elements such as:

    init_manifest   => 1,

=item * C<step>

The short name of the configuration step class being tested by the test
file constructing this object.  Value is a string.

Example:  test file F<t/steps/init_manifest-01.t> will have a value of
C<init::manifest> in this element.

=back

B<Comment:>

Will C<croak> if a configuration step class cannot be parsed from the
argument.

=cut

sub new {
    my $class = shift;
    croak "Need to provide name of test script as argument to Parrot::Configure::Parallel::Trace::new()"
        unless $_[0];
    my $script = shift;
    my %args;
    $args{sto} = $sto;

    my @steps_list = Parrot::Configure::Step::List::get_steps_list();
    my %steps_position;
    for (my $i=0; $i<=$#steps_list; $i++) {
        $steps_position{$steps_list[$i]} = $i+1;
    }
    $args{position} = \%steps_position;

    my $base = basename($script);
    my ($type, $stepclass);
    if ($base =~ m/^(init|inter|auto|gen)_(.*?)\-/o) {
        ($type, $stepclass) = ($1, $2);
    } else {
        croak "Cannot parse test file name $base to get step: $!";
    }
    $args{step} = $type . q{::} . $stepclass;

    return bless \%args, $class;
}

=head2 C<get_step_name()>

B<Purpose:>  Accesses short name of configuration step class derived
from argument to constructor.

B<Arguments:>

    $step_name = $trace->get_step_name();

B<Return Value:>  String holding short name of configuration step.
Example:

    init::manifest

B<Comment:>

=cut

sub get_step_name {
    my $self = shift;
    return $self->{step};
}

=head2 C<get_step_position()>

B<Purpose:>  Accesses the sequence number of the configuration step
class calculated from the argument to the constructor.

B<Arguments:>  None.

    $step_position = $trace->get_step_position();

B<Return Value:>  Non-negative integer.  Example, if class is
C<init::defaults>, C<$step_position> is C<2>.

B<Comment:>

=cut

sub get_step_position {
    my $self = shift;
    return $self->{position}->{$self->{step}};
}

=head2 C<get_all_step_positions()>

B<Purpose:>  Provides a look-up table for the sequence numbers of all
configuration step classes.

B<Arguments:>  None.

    $stepsref = $trace->get_all_step_positions()

B<Return Value:> Hash reference, where each element's key is a
configuration step class (I<e.g.>, C<init::manifest>) and each element's
value is the corresponding sequence number (C<1>).

B<Comment:>

=cut

sub get_all_step_positions {
    my $self = shift;
    return $self->{position};
}

=head2 C<get_storable_file()>

B<Purpose:>  Provide the name of the Storable file on disk used to
record the results of parallel configuration.

B<Arguments:>  None.

    $sto = $trace->get_storable_file();

B<Return Value:> String, which is a filename.

B<Comment:>  The Storable file is not guaranteed to actually exist.  For
instance, it should not exist prior to beginning configuration.  All
that this method does is return the name designated for this file.

=cut

sub get_storable_file {
    my $self = shift;
    return $self->{sto};
}

=head2 C<retrieve_state()>

B<Purpose:>  Retrieves from the Storable file on disk a list of the
states of configuration at the conclusion of all steps executed so far.

B<Arguments:>  None.

    $state = $trace->retrieve_state();

B<Return Value:>

Array reference.  Each element in the array represents the state of the
Parrot::Configure::Parallel object at the conclusion of a given
configuration step.

B<Comment:>

If no Storable file is found, will return an empty array reference.

=cut

sub retrieve_state {
    my $self = shift;
    my $state = [];
    local $Storable::Eval = 1;
    $state = retrieve($self->{sto}) if -e $self->{sto};
    return $state;
}

=head2 C<dump_state()>

B<Purpose:>  Dumps the list of configuration states retrieved by
C<retrieve_state()>.

B<Arguments:>  None.

    $trace->dump_state();

B<Return Value:>  Implicitly returns a true value upon success.

B<Comment:>  Uses F<Data::Dumper> with C<$Data::Dumper::Indent> set to
C<1> to reduce unnecessary whitespace and disk storage requirements.

=cut

sub dump_state {
    my $self = shift;
    my $state = $self->retrieve_state();
    print Dumper $state;
}

=head2 C<get_previous_state()>

B<Purpose:>  Determine what was the state of configuration at the
conclusion of the last step successfully completed.

B<Arguments:>  In normal use, no arguments are needed, as this method
will internally call C<retrieve_state()>.  For testing purposes you may
provide an array reference to preempt use of the array reference
returned by C<retrieve_state()>.

B<Return Value:>  Hash reference representing the internal state of the
Parrot::Configure::Parallel object.  Returns C<undef> if this is not
successful.

B<Comment:>

=cut

sub get_previous_state {
    my $self = shift;
    my $step_position = $self->get_step_position($self->{step});
    my $state = shift || $self->retrieve_state();
    if ( (defined($state->[$step_position - 1]))
            and
         (ref($state->[$step_position - 1]) =~ /Parrot::Configure/)
     ) {
         return $state->[$step_position - 1];
     } else {
         return;
     }
}

=head2 C<update_state()>

B<Purpose:>  Updates the Storable object on disk with the results of
running the current configuration step.

B<Arguments:>  Hash reference with two keys:  C<state> and C<conf>.

    $trace->update_state( {
        state       => $state,
        conf        => $conf,
    } );

B<Return Value:>  Returns true value upon success.

B<Comment:>

=cut

sub update_state {
    my $self = shift;
    my $argsref = shift;
    if (! defined $argsref->{state}->[0]) {
        $argsref->{state}->[0] = [];
    }
    push @{ $argsref->{state}->[0] }, $self->get_step_name();

    push @{ $argsref->{state} }, $argsref->{conf};
    {
        local $Storable::Deparse = 1;
        nstore( $argsref->{state}, $self->{sto} );
    }
    return 1;
}

=head2 C<store_this_step()>

B<Purpose:>  As needed:  Retrieves the configuration state from the
Storable file on disk.  Constructs a Parrot::Configure::Parallel object,
then replaces the content of that object with the configuration state so
retrieved.  Executes the particular configuration step's C<runstep()>
method and stores the updated state on disk.

B<Arguments:>  None.

B<Return Value:>  If the current configuration step is being encountered
for the first time (I<e.g.>, F<t/steps/init_defaults-01.t>), then method
executes completely and returns C<1> upon success.

If, however, the current configuration step has been previously
encountered (I<e.g.>, F<t/steps/init_defaults-02.t>), then the method
short-circuits and returns C<2> upon success.

So, you get a true value on success either way, but the indicator of
success may vary.

B<Comment:>

=cut

sub store_this_step {
    my $self = shift;
    my $pkg = $self->{step};
    my $step_position = $self->get_step_position($pkg);
    my $state = $self->retrieve_state();
    return 2 if $state->[ $step_position ];

    my $args = process_options( {
        argv => [q{--silent}, @ARGV],
        mode => q{configure},
    } );

    my $conf = Parrot::Configure::Parallel->new();
    $conf->refresh($self->get_previous_state($state));
    $conf->add_steps($pkg);
    $conf->options->set( %{$args} );

    my $task        = $conf->steps->[-1];
    my $step_name   = $task->step;
    my $step = $step_name->new();
    my $ret = $step->runstep($conf);
    if (defined $ret) {
        $self->update_state(
            {
                state       => $state,
                conf        => $conf,
            }
        );
    } else {
        croak "Unable to run pure version of current step: $!";
    }
    $conf = undef;
    return 1;
}

1;

#################### DOCUMENTATION ####################

=head1 PREREQUISITES

=head2 Perl 5 Core Modules

=over 4

=item * Carp

=item * Data::Dumper

C<$Data::Dumper::Indent> is set to C<1>.

=item * File::Basename

=item * Storable C<qw( nstore retrieve )>

=back

=head2 Perl 5 Modules in Parrot Distribution

=over 4

=item * Parrot::Configure::Step::List C<qw( get_steps_list )>

=item * Parrot::Configure::Parallel

=item * Parrot::Configure::Options C<qw( process_options )>

=back

=head1 AUTHOR

James E Keenan

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
