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
    $data{args}        = [ qw( inline verbose ) ];
    $data{result}      = q{};
    return \%data;
}

sub runstep {
    my ( $self, $conf ) = @_;

    my $test;
    my ( $inline, $verbose ) = $conf->options->get(qw(inline verbose));

    if ( defined $inline ) {
        $test = $inline;
    }
    else {
        cc_gen('config/auto/inline/test_1.in');
        eval { cc_build(); };
        if ( !$@ ) {
            $test = cc_run();
            chomp $test if $test;
        }
        cc_clean();
        if ( !$test ) {
            cc_gen('config/auto/inline/test_2.in');
            eval { cc_build(); };
            if ( !$@ ) {
                $test = cc_run();
                chomp $test if $test;
            }
            cc_clean();
        }
        if ($test) {
            print " ($test) " if $verbose;
            $self->set_result('yes');
        }
        else {
            print " no " if $verbose;
            $self->set_result('no');
            $test = '';
        }
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
