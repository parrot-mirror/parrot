# Copyright (C) 2001-2007, The Perl Foundation.
# $Id$

package Parrot::Configure;

use strict;
use warnings;

use lib qw(lib config);
use Carp qw(carp);
use Storable qw(nstore retrieve);
use Parrot::Configure::Data;
use base qw( Parrot::Configure::Base );
use base qw(Parrot::Configure::Compiler);

my $singleton;

BEGIN {
    $singleton = {
        steps   => [],
        data    => Parrot::Configure::Data->new,
        options => Parrot::Configure::Data->new,
    };
    bless $singleton, "Parrot::Configure";
}

sub new {
    my $class = shift;
    return $singleton;
}

=head1 NAME

Parrot::Configure - Conducts the execution of Configuration Steps

=head1 SYNOPSIS

    use Parrot::Configure;

    my $conf = Parrot::Configure->new;
    my $data = $conf->data;
    my $options = $conf->options;
    my @steps = $conf->steps;
    $conf->add_steps(@steps);
    $conf->runsteps;

=head1 DESCRIPTION

This module provides provides a means for registering, executing, and
coordinating one or more configuration steps.  Please see
F<docs/configuration.pod> for further details about the configuration
framework.

=head1 USAGE

=head2 Import Parameters

This module accepts no arguments to its C<import> method and exports no
I<symbols>.

=cut

=head2 Methods

=head3 Constructor

=over 4

=item * C<new()>

Basic constructor.

Accepts no arguments and returns a Parrot::Configure object.

=cut

=back

=head1 CREDITS

The L</runsteps()> method is largely based on code written by Brent
Royal-Gordon C<brent@brentdax.com>.

=head1 AUTHOR

Joshua Hoblitt C<jhoblitt@cpan.org>

=head1 SEE ALSO

F<docs/configuration.pod>, L<Parrot::Configure::Data>,
L<Parrot::Configure::Utils>, L<Parrot::Configure::Step>

=cut

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
