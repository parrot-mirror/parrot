# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$
package Parrot::Configure::Interactive;
use strict;
use warnings;
use base qw( Exporter );
our @EXPORT_OK = qw(
    get_data_from_prompts
);

################### SUBROUTINES ###################

sub get_data_from_prompts {
    # nothing yet, 'cause I gotta go to the movies!
}

1;

#################### DOCUMENTATION ####################

=head1 NAME

Parrot::Configure::Interactive - Specify configuration settings via prompts to user

=head1 SYNOPSIS

    use Parrot::Configure::Interactive qw(
        get_data_from_prompts
    );

    $args = get_data_from_prompts($args);
    
=head1 DESCRIPTION

Parrot::Configure::Interactive exports on demand one subroutine which
prompts the user to enter configuration data selections.

=head1 SUBROUTINES

=head2 C<get_data_from_prompts()>

=over 4

=item * Purpose

During C<Configure.pl> (or its test equivalents), prompt the user to
enter customized configuration settings.

=item * Arguments

One argument:  The hash reference which is the output of
C<Parrot::Configure::Options::process_options>.

=item * Return Value

Hash reference which is an augmented version of the hash ref supplied to
the function as an argument.

=item * Comment

=back

=head1 NOTES

The functionality in this package was transferred from the former
C<inter::*> configuration steps by Jim Keenan.

=head1 SEE ALSO

F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
