# Copyright (C) 2001-2003, The Perl Foundation.
# $Id$

=head1 NAME

config/auto/env.pm - System Environment

=head1 DESCRIPTION

Determining if the C library has C<setenv()> and C<unsetenv()>.

More information about these functions can be found at
L<http://www.gnu.org/software/libc/manual/html_node/Environment-Access.html>,
among other locations.

=cut

package auto::env;

use strict;
use warnings;

use base qw(Parrot::Configure::Step::Base);

use Parrot::Configure::Step ':auto';

sub _init {
    my $self = shift;
    my %data;
    $data{description} = q{Determining if your C library has setenv / unsetenv};
    $data{args}        = [ qw( verbose ) ];
    $data{result}      = q{};
    return \%data;
}

sub runstep {
    my ( $self, $conf ) = ( shift, shift );

    my ( $setenv, $unsetenv ) = ( 0, 0 );

    cc_gen('config/auto/env/test_setenv.in');
    eval { cc_build(); };
    unless ( $@ || cc_run() !~ /ok/ ) {
        $setenv = 1;
    }
    cc_clean();
    cc_gen('config/auto/env/test_unsetenv.in');
    eval { cc_build(); };
    unless ( $@ || cc_run() !~ /ok/ ) {
        $unsetenv = 1;
    }
    cc_clean();

    $self->_evaluate_env($conf, $setenv, $unsetenv);

    return 1;
}

sub _evaluate_env {
    my ($self, $conf, $setenv, $unsetenv) = @_;
    my $verbose = $conf->options->get('verbose');
    $conf->data->set(
        setenv   => $setenv,
        unsetenv => $unsetenv
    );

    if ( $setenv && $unsetenv ) {
        print " (both) " if $verbose;
        $self->set_result('both');
    }
    elsif ($setenv) {
        print " (setenv) " if $verbose;
        $self->set_result('setenv');
    }
    elsif ($unsetenv) {
        print " (unsetenv) " if $verbose;
        $self->set_result('unsetenv');
    }
    else {
        print " (no) " if $verbose;
        $self->set_result('no');
    }
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
