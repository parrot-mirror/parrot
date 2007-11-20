# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$
package Parrot::Configure::Initialize;
use strict;
use warnings;
use Carp;
use lib ( "./lib" );
use base qw|
    Parrot::Configure::Initialize::Defaults
    Parrot::Configure::Initialize::Install
|;

################### SUBROUTINES ###################

sub new {
    my $class = shift;
    my $options_ref = shift;
    croak "Argument to Parrot::Configure::Initialize->new() must be hash ref"
        unless ref($options_ref) eq 'HASH';
    my %init;
    my $self = bless \%init, $class;
    $self->{options} = $options_ref;
    return $self;
}

sub init_all {
    my $self = shift;
    $self->init_defaults();
    $self->init_install();
    $self->init_miniparrot();
}

1;

#################### DOCUMENTATION ####################

=head1 NAME

Parrot::Configure::Initialize - Gather initial configuration data from
command-line options, Perl 5 configuration and other system data

=head1 SYNOPSIS

    use Parrot::Configure::Initialize;

    my $init = Parrot::Configure::Initialize->new($args);

    $init->init_all();

=head1 DESCRIPTION

Parrot::Configure::Initialize gathers initial configuration data from
command-line options, Perl 5 c<%Config> and other readily available
sources.  It makes this data available to other packages such as
Parrot::Configure::Interactive (so that correct prompts can be offered
to the user) and to config::init::defaults.

=head1 SUBROUTINES

=head2 C<new()>

=over 4

=item * Purpose

Parrot::Configure::Initialize constructor.

=item * Arguments

One argument:  The hash reference which is the output of
C<Parrot::Configure::Options::process_options>.  This is a list of
key-value pairs reflecting the results of processing of command-line
options.

=item * Return Value

Hash reference holding list of key-value pairs suitable for insertion
into Parrot::Configure object via C<$conf->data->set()>.

=item * Comment

=back

=head1 NOTES

The functionality in this package was transferred from the former
C<init::defaults> configuration steps by Jim Keenan.

=head1 SEE ALSO

F<Configure.pl>.  Parrot::Configure.  Parrot::Configure::Interactive.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
