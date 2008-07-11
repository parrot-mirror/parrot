package Parrot::Configure;
# Copyright (C) 2001-2007, The Perl Foundation.
# $Id$

use strict;
use warnings;

use Class::Struct;
use lib qw( config lib );
use Parrot::Configure::Data;
use base qw(
    Parrot::Configure::Base
    Parrot::Configure::Compiler
);

struct(
    'Parrot::Configure::Task' => {
        step   => '$',
        object => 'Parrot::Configure::Step',
    },
);

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

1;

=head1 NAME

Parrot::Configure - Execute configuration steps

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

=head3 C<new()>

Basic constructor.  Accepts no arguments and returns a Parrot::Configure object.

The Parrot::Configure object is a singleton.  Over the course of the
configuration steps, data about the environment in which Parrot is being built
is stored in the Parrot::Configure object's data structure, then used to
generate Makefiles and other files needed during Parrot's build process.

=head3 Other Methods

Other Parrot::Configure methods are documented in Parrot::Configure::Base and
Parrot::Configure::Compiler.

=head1 CREDITS

The C<runsteps()> method is largely based on code written by Brent
Royal-Gordon C<brent@brentdax.com>.

=head1 AUTHOR

Joshua Hoblitt C<jhoblitt@cpan.org>

=head1 SEE ALSO

F<docs/configuration.pod>, L<Parrot::Configure::Data>,
L<Parrot::Configure::Utils>, L<Parrot::Configure::Step>

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

