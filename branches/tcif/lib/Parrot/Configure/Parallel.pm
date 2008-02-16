# Copyright (C) 2001-2007, The Perl Foundation.
# $Id$
package Parrot::Configure::Parallel;

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
    bless $singleton, "Parrot::Configure::Parallel";
}

sub new {
    my $class = shift;
    return $singleton;
}

1;

=head1 NAME

Parrot::Configure::Parallel - Create a parallel configuration object

=head1 SYNOPSIS

    use Parrot::Configure::Parallel;

    my $conf = Parrot::Configure::Parallel->new;
    my $data = $conf->data;
    my $options = $conf->options;
    my @steps = $conf->steps;
    $conf->add_steps(@steps);
    $conf->runsteps;

=head1 DESCRIPTION

=cut

=head2 Methods

=head3 Constructors

=over 4

=item * C<new()>

Basic constructor.

Accepts no arguments and returns a L<Parrot::Configure::Parallel> object.

=cut

=back

=head1 AUTHOR

Joshua Hoblitt C<jhoblitt@cpan.org>

=head1 SEE ALSO

F<docs/configuration.pod>, L<Parrot::Configure::Data>,
L<Parrot::Configure::Step>, L<Parrot::Configure::Step::Base>

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
