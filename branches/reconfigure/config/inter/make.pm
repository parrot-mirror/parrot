# Copyright (C) 2001-2007, The Perl Foundation.
# $Id$

=head1 NAME

config/inter/make.pm - make utility

=head1 DESCRIPTION

Determines whether C<make> is installed and if it's actually GNU C<make>.

=cut

package inter::make;

use strict;
use warnings;

use vars qw( $description @args $prompt $util );

use base qw(Parrot::Configure::Step::Base);

use Parrot::Configure::Step qw( :inter capture_output check_progs );

$util        = 'make';
$description = "Determining whether $util is installed";
$prompt      = "Do you have a make utility like 'gmake' or 'make'?";
@args        = qw( make ask );

sub runstep {
    my ( $self, $conf ) = @_;

    my $verbose = $conf->options->get('verbose');

    # undef means we don't have GNU make... default to not having it
    $conf->data->set( gmake_version => undef );

    my $prog;

    # check the candidates for a 'make' program in this order:
    # environment ; option ; probe ; ask ; default
    # first pick wins.
    $prog ||= $ENV{ uc($util) };
    $prog ||= $conf->options->get($util);
    $prog ||= check_progs( ['gmake', 'mingw32-make', 'nmake', 'make'], $verbose );
    if ( !$prog ) {
        $prog = ( $conf->options->get('ask') )
            ? prompt( $prompt, $prog ? $prog : $conf->data->get($util) )
            : $conf->data->get($util);
    }

    # never override the user.  If a non-existent program is specified then
    # the user is responsible for the consequences.
    if ( defined $prog ) {
        $conf->data->set( $util => $prog );
        $self->set_result('yes');
    }
    else {
        # fall back to default
        $self->set_result('no');
        return $self;
    }

    my ( $stdout, $stderr, $ret ) = capture_output( $prog, '--version' );

    # don't override the user even if the program they provided appears to be
    # broken
    if ( $ret == -1 and !$conf->options->get('ask') ) {
        # fall back to default
        $self->set_result('no');
        return $self;
    }

    # if '--version' returns a string assume that this is gmake.
    if ( $stdout =~ /GNU \s+ Make \s+ (\d+) \. (\d+)/x ) {
        $conf->data->set( gmake_version => "$1.$2" );
    }

    $conf->data->set( $util => $prog );
    $self->set_result('yes');

    # setup make_C
    if ( $conf->data->get('gmake_version') ) {
        $conf->data->set( make_c => "$prog -C" );
    }
    else {

        # get the default value
        my $make_c = $conf->data->get('make_c');

        # RT#43171 this is an ugly hack
        # replace the value for $(MAKE) with the actual path or we'll end up
        # with a variable that recursively refers to itself
        $make_c =~ s/\$\(MAKE\)/$prog/;

        $conf->data->set( make_c => $make_c );
    }

    return $self;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
