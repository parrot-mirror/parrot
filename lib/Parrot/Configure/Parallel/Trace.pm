# Copyright (C) 2007, The Perl Foundation.
# $Id$
package Parrot::Configure::Parallel::Trace;
use strict;
use warnings;
use Carp;
use Data::Dumper;
local $Data::Dumper::Indent = 1;
use File::Basename;
use Storable qw( nstore retrieve );
use lib qw( lib );
use Parrot::Configure::Step::List qw( get_steps_list );
use Parrot::Configure::Parallel;
use Parrot::Configure::Options qw( process_options );

our $sto = q{.configure_parallel.sto};

sub new {
    my $class = shift;
    croak "Need to provide name of test script as argument to Parrot::Configure::Parallel::Trace::new()"
        unless $_[0];
    my $script = shift;
    my %args;
    $args{sto} = $sto;

    my @steps_list = get_steps_list();
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

sub get_step_name {
    my $self = shift;
    return $self->{step};
}

sub get_step_position {
    my $self = shift;
    return $self->{position}->{$self->{step}};
}

sub retrieve_state {
    my $self = shift;
    my $state = [];
    local $Storable::Eval = 1;
    $state = retrieve($self->{sto}) if -e $self->{sto};
    return $state;
}

sub dump_state {
    my $self = shift;
    my $state = $self->retrieve_state();
    print Dumper $state;
}

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

sub update_state {
    my $self = shift;
    my $argsref = shift;
    push @{ $argsref->{state} }, $argsref->{conf};
    {
        local $Storable::Deparse = 1;
        nstore( $argsref->{state}, $self->{sto} );
    }
    return 1;
}

sub store_this_step_pure {
    my $self = shift;
    my $pkg = $self->{step};
    my $step_position = $self->get_step_position($pkg);
    my $state = $self->retrieve_state();
    return 2 if $state->[ $step_position ];

    my $args = process_options( {
        argv => [q{--silent}],
        mode => q{configure},
    } );

    my $conf = Parrot::Configure::Parallel->new;
    $conf->refresh($self->get_previous_state($pkg,$state));
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

=head1 NAME

Parrot::Configure::Parallel::Trace - Manipulate a Parrot::Configure::Parallel object during testing of configuration step classes.

=head1 SYNOPSIS

    $trace =
        Parrot::Configure::Parallel::Trace->new('current_test_script');

    $step_name = $trace->get_step_name();

    $step_position = $trace->get_step_position($step_name);

    $state = $self->retrieve_state();
    
    $self->dump_state();
    
    $self->get_previous_state($step_name);
    
    $self->update_state( {
        state       => $state,
        conf        => $conf,
    } );

    $self->store_this_step_pure($step_name);

Used only in configuration step tests found in F<t/steps/>.

=head1 AUTHOR

James E Keenan

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
