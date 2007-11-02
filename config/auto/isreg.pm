# Copyright (C) 2001-2003, The Perl Foundation.
# $Id$

=head1 NAME

config/auto/isreg - S_ISREG

=head1 DESCRIPTION

Determines if the C library has a working C<S_ISREG>.

=cut

package auto::isreg;

use strict;
use warnings;

use base qw(Parrot::Configure::Step::Base);

use Parrot::Configure::Step ':auto';


sub _init {
    my $self = shift;
    my %data;
    $data{description} = q{Determining if your C library has a working S_ISREG};
    $data{args}        = [ qw( verbose ) ];
    $data{result}      = q{};
    return \%data;
}

sub runstep {
    my ( $self, $conf ) = @_;

    my $errormsg = _first_probe_for_isreg();

    if (! $errormsg) {
        $errormsg = _second_probe_for_isreg();
    }
    cc_clean();
    $self->_evaluate_isreg($conf, $errormsg);
    return 1;
}

sub _first_probe_for_isreg {
    my $errormsg;
    cc_gen('config/auto/isreg/test_c.in');
    eval { cc_build(); };
    $errormsg = 1 if  $@;
    return $errormsg;
}

sub _second_probe_for_isreg {
    my $ccrunfailure;
    $ccrunfailure++ if ( cc_run() !~ /ok/ );
    return $ccrunfailure;
}

sub _evaluate_isreg {
    my ($self, $conf, $anyerror) = @_;
    my $test;
    $test = (! defined $anyerror) ? 1 : 0;
    $conf->data->set( isreg => $test );
    print( $test ? " (Yep) " : " (no) " ) if $conf->options->get('verbose');
    $self->set_result( $test ? 'yes' : 'no' );
    return 1;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
