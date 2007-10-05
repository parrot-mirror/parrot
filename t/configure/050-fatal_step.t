#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 050-fatal_step.t

use strict;
use warnings;

use Test::More tests =>  6;
use Carp;
use lib qw( lib t/configure/testlib );
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Step::List qw( get_steps_list );
use Parrot::IO::Capture::Mini;

$| = 1;
is($|, 1, "output autoflush is set");

my $args = process_options( {
    argv    => [ q{--fatal-step} ],
    mode    => q{configure},
} );
ok(defined $args, "process_options returned successfully");
my %args = %$args;

my $conf = Parrot::Configure->new;
ok(defined $conf, "Parrot::Configure->new() returned okay");

my $first_step = q{init::zeta};
my $description = 'Determining if your computer does zeta';

$conf->add_steps( $first_step, get_steps_list() );

$conf->options->set(%args);
is($conf->options->{c}->{debugging}, 1,
    "command-line option '--debugging' has been stored in object");

my $rv;
my (@lines, @errlines);
{
    my ($tie, $errtie);
    $tie = tie *STDOUT, "Parrot::IO::Capture::Mini"
        or croak "Unable to tie";
    $errtie = tie *STDERR, "Parrot::IO::Capture::Mini"
        or croak "Unable to tie";
    $rv = $conf->runsteps;
    @lines = $tie->READLINE;
    @errlines = $errtie->READLINE;
}
untie *STDOUT;
untie *STDERR;

ok(! defined $rv, "runsteps returned undefined value as expected");

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

050-fatal_step.t - see what happens when C<--fatal-step> is set for all configuration steps

=head1 SYNOPSIS

    % prove t/configure/050-fatal_step.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file examine what happens when your configuration step
module returns something other than the object but has some other defined
result method.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
