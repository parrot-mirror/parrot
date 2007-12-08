# Copyright (C) 2001-2003, The Perl Foundation.
# $Id$

=head1 NAME

config/auto/inline.pm - Inline Compiler Support

=head1 DESCRIPTION

Determines whether the compiler supports C<inline>.

=cut

package auto::inline;

use strict;
use warnings;

use base qw(Parrot::Configure::Step::Base);

use Parrot::Configure::Step ':auto';


sub _init {
    my $self = shift;
    my %data;
    $data{description} = q{Determining if your compiler supports inline};
    $data{result}      = q{};
    return \%data;
}

sub runstep {
    my ( $self, $conf ) = @_;

    my $inline = $conf->options->get(qw(inline));
    if ( defined $inline ) {
        $conf->data->set( inline => $inline );
        return 1;
    }

    my $test = $self->_first_probe_for_inline();
    unless ($test) {
        $test = $self->_second_probe_for_inline($test);
    }

    $self->_evaluate_inline($conf, $test);
    return 1;
}

sub _first_probe_for_inline {
    my $self = shift;
    my $test;
    cc_gen('config/auto/inline/test_1.in');
    eval { cc_build(); };
    if ( !$@ ) {
        $test = cc_run();
        chomp $test if $test;
    }
    cc_clean();
    return $test;
}

sub _second_probe_for_inline {
    my $self = shift;
    my $test = shift;
    if ( !$test ) {
        cc_gen('config/auto/inline/test_2.in');
        eval { cc_build(); };
        if ( !$@ ) {
            $test = cc_run();
            chomp $test if $test;
        }
        cc_clean();
    }
    return $test;
}

sub _evaluate_inline {
    my ($self, $conf, $test) = @_;
    my $verbose = $conf->options->get(qw(verbose));
    if ($test) {
        print " ($test) " if $verbose;
        $self->set_result('yes');
    }
    else {
        print " no " if $verbose;
        $self->set_result('no');
        $test = '';
    }
    $conf->data->set( inline => $test );
    return 1;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
