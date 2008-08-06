# Copyright (C) 2007-2008, The Perl Foundation.
# $Id$
package Parrot::Configure::Options::Conf::CLI;

use strict;
use warnings;
use base qw( Exporter );
our @EXPORT_OK = qw(
    @valid_options
    $script
    %options_components
    $parrot_version
    $svnid
);
use lib qw( lib );
use Parrot::Configure::Options::Conf qw(
    $script
    $parrot_version
    $svnid
    print_help
    print_version
);
use Parrot::Configure::Options::Conf::Shared qw(
    @shared_valid_options
);
use Parrot::Configure::Step::List qw( get_steps_list );

our @valid_options = ( 'ask', @shared_valid_options );

my %short_circuits = (
    help    => \&print_help,
    version => \&print_version,
);

our %options_components = (
    'valid_options'  => \@valid_options,
    'script'         => $script,
    'short_circuits' => \%short_circuits,
    'conditionals'   => \&conditional_assignments,
);

sub conditional_assignments {
    my $argsref = shift;
    $argsref->{debugging} = 1
        unless ( ( exists $argsref->{debugging} ) && !$argsref->{debugging} );
    $argsref->{maintainer} = 1
        if defined $argsref->{lex}
            or defined $argsref->{yacc};
    my @steps_list = get_steps_list();
    return ( $argsref, [ @steps_list ] );
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
