# Copyright (C) 2007, The Perl Foundation.
# $Id$

package Auxiliary;
use strict;
use warnings;
our (@ISA, @EXPORT_OK);
@ISA       = qw( Exporter );
@EXPORT_OK = qw(
    get_step_name
    get_step_position
    retrieve_state
    dump_state
    get_previous_state
    store_this_step_pure
    update_state
);
use Carp;
use Data::Dumper;
$Data::Dumper::Indent = 1;
use File::Basename;
use Storable qw( nstore retrieve );
use lib qw( lib );
use Parrot::Configure::Step::List qw( get_steps_list );
use Parrot::Configure::Parallel;
use Parrot::Configure::Options qw( process_options );

our $sto = q{.configure_parallel.sto};

our %steps_position;
my @steps_list = get_steps_list();
for (my $i=0; $i<=$#steps_list; $i++) {
    $steps_position{$steps_list[$i]} = $i+1;
}

sub get_step_name {
    my $script = shift;
    my $base = basename($script);
    my ($type, $class);
    if ($base =~ m/^(init|inter|auto|gen)_(.*?)\-/o) {
        ($type, $class) = ($1, $2);
    } else {
        croak "Cannot parse test file name $base to get step: $!";
    }
    return $type . q{::} . $class;
}

sub get_step_position {
    my $step = shift;
    return $steps_position{$step};
}

sub retrieve_state {
    my $state = [];
    local $Storable::Eval = 1;
    $state = retrieve($sto) if -e $sto;
    return $state;
}

sub dump_state {
    my $state = retrieve_state();
    print Dumper $state;
}

sub get_previous_state {
    my $pkg = shift;
    my $state = shift || retrieve_state();
    my $step_position = get_step_position($pkg);
    if ( (defined($state->[$step_position - 1]))
            and
         (ref($state->[$step_position - 1]) =~ /Parrot::Configure/)
     ) {
         return $state->[$step_position - 1];
     } else {
         return;
     }
}

sub store_this_step_pure {
    my $pkg = shift;
    my $state = retrieve_state();
    my $step_position = get_step_position($pkg);
    return 2 if $state->[$step_position];
    my $args = process_options( {
        argv => [q{--silent}],
        mode => q{configure},
    } );

    my $conf = Parrot::Configure::Parallel->new;
#    my $pv = get_previous_state($pkg,$state);
    $conf->refresh(get_previous_state($pkg,$state));
    $conf->add_steps($pkg);
    $conf->options->set( %{$args} );
    
    my $task        = $conf->steps->[-1];
    my $step_name   = $task->step;
    my $step = $step_name->new();
    my $ret = $step->runstep($conf);
    if (defined $ret) {
        update_state(
            {
                state       => $state,
#                step_name   => $step_name,
                conf        => $conf,
                sto         => $sto,
            }
        );
    } else {
        croak "Unable to run pure version of current step: $!";
    }
    $conf = undef;
    return 1;
}

sub update_state {
    my $argsref = shift;
#    if (! defined $argsref->{state}->[0]) {
#        $argsref->{state}->[0] = [];
#    }
#    push @{ $argsref->{state}->[0] }, $argsref->{step_name};
    push @{ $argsref->{state} }, $argsref->{conf};
    {
        local $Storable::Deparse = 1;
        nstore( $argsref->{state}, $argsref->{sto} );
    }
    return 1;
}

1;

=head1 NAME

t/steps/testlib/Auxiliary.pm - Subroutines used in F<t/steps/*.t>.

=head1 SYNOPSIS

Use only in test scripts.

=head1 AUTHOR

James E Keenan

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
