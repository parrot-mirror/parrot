# Copyright (C) 2004-2008, The Perl Foundation.
# $Id: PCCMETHOD.pm 29952 2008-08-02 22:45:13Z allison $

package Parrot::Pmc2c::MULTI;
#use base 'Parrot::Pmc2c::PCCMETHOD';
use strict;
use warnings;
use Carp qw(longmess croak);

=head1 NAME

Parrot::Pmc2c::MULTI - Parses and preps MULTI dispatch subs

=head1 SYNOPSIS

    use Parrot::Pmc2c::MULTI;

=head1 DESCRIPTION

Parrot::Pmc2c::MULTI - Parses and preps MULTI multiple dispatch declarations
called from F<Parrot:Pmc2c::Pmc2cMain>

=cut

=head1 FUNCTIONS

=head2 Publicly Available Methods

=head3 C<rewrite_multi_sub($method, $pmc)>

B<Purpose:>  Parse and Build PMC multiple dispatch subs.

B<Arguments:>

=over 4

=item * C<self>

=item * C<method>

Current Method Object

=item * C<body>

Current Method Body

=back

=cut

sub rewrite_parameters {
    my ($parameters) = @_;
    my @param_types = ();
    my @new_params = ();
    my $new_param_string = "";

    for my $param ( split /,/, $parameters ) {
        my ( $type, $name, $rest ) = split /\s+/, &Parrot::Pmc2c::PCCMETHOD::trim($param), 3;

        die "Invalid MULTI parameter '$param': missing type or name\n"
             unless defined $name;

        die "Invalid MULTI parameter '$param': attributes not allowed on multis\n"
             if defined $rest;

        if ($name =~ /[\**]?(\"?\w+\"?)/) {
            $name = $1;
        }

        # Capture the actual type for the sub name
        push @param_types, $type;

        # Pass standard parameter types unmodified.
        # All other param types are rewritten as PMCs.
        if ($type eq 'STRING' or $type eq 'PMC' or $type eq 'INTVAL' or $type eq 'FLOATVAL') {
            push @new_params, $param;
        } else {
            push @new_params, "PMC *$name";
        }
    }
    $new_param_string = join (",", @new_params);

    return ($new_param_string, @param_types);
}

=head3 C<rewrite_multi_sub()>

    rewrite_multi_sub($method, $pmc);

=cut

sub rewrite_multi_sub {
    my ( $self, $pmc ) = @_;

    # Fixup the parameters, standardizing PMC types and extracting type names
    # for the multi name.
    my ($paramstring, @paramlist) = rewrite_parameters( $self->parameters );
    $self->parameters($paramstring);

    my $sub_name = "multi_" . $self->name . "_" . join ('_', @paramlist);

    $self->name($sub_name);

    $self->{MULTI} = 1;

    return 1;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
