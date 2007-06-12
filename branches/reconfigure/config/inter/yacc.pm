# Copyright (C) 2001-2007, The Perl Foundation.
# $Id$

=head1 NAME

config/auto/yacc.pm - parser generator

=head1 DESCRIPTION

Determines whether C<yacc> is installed and if it's actually C<bison> of at
least the user-specified minimum version, defaulting to 2.1.

=cut

package inter::yacc;

use strict;
use warnings;

use vars qw( $description @args $prompt $util );

use base qw(Parrot::Configure::Step::Base);

use Parrot::Configure::Step qw( :inter capture_output check_progs );

$util        = 'yacc';
$description = "Determining whether $util is installed";
$prompt      = "Do you have a parser generator, like bison or yacc?";
@args        = qw( yacc ask maintainer );

my $default_required = '2.1';

sub runstep {
    my ( $self, $conf ) = @_;

    my $verbose = $conf->options->get('verbose');

    # undef means we don't have bison... default to not having bison
    $conf->data->set( bison_version => undef );

    unless ( $conf->options->get('maintainer') ) {
        $conf->data->set( $util => 'echo' );
        $self->set_result('skipped');
        return $self;
    }

    my $prog;

    # precedence of sources for the program:
    # default -> probe -> environment -> option -> ask
    $prog ||= $conf->options->get($util);
    $prog ||= $ENV{ uc($util) };

    # never override the user.  If a non-existent program is specified then
    # the user is responsible for the consequences.
    if ( defined $prog ) {
        $conf->data->set( $util => $prog );
        $self->set_result('user defined');
        return $self;
    }

    $prog = check_progs( [ 'bison -v -y', 'yacc', 'byacc' ], $verbose );

    unless ($prog) {
        $self->set_result('no yacc program was found');
        return;
    }

    # RT#43170 should --ask be handled like the other user defines or 
    # checked for version requirements?
    if ( $conf->options->get('ask') ) {
        $prog = prompt( $prompt, $prog ? $prog : $conf->data->get($util) );
    }

    my ( $stdout, $stderr, $ret ) = capture_output( $prog, '--version' );

    # don't override the user even if the program they provided appears to be
    # broken
    if ( $ret == -1 and !$conf->options->get('ask') ) {

        # fall back to default
        $self->set_result('yacc program does not exist or does not understand --version');
        return;
    }

    # if '--version' returns a string assume that this is bison.
    # if this is bison pretending to be yacc '--version' doesn't work
    if ( $stdout =~ /Bison .*? (\d+) \. (\d+) (\w)?/x ) {

        # someday we might need to check $3 also.
        my ( $prog_major, $prog_minor, $prog_patch ) = ( $1, $2, $3 );
        my $prog_version = "$1.$2";
        $prog_version .= $3 if $3;

        # is there a version requirement?
        my $req = $conf->options->get('bison_required');
        unless ( defined $req ) {
            $req = $default_required;
        }
        if ($req) {
            my ( $rmajor, $rminor ) = ( $req =~ / ^ (\d+) \. (\d+) (\w)? $ /x );
            unless ( defined $rmajor ) {
                $self->set_result("could not understand bison version requirement");
                return;
            }

            unless (
                $prog_major >= $rmajor

                or (    $prog_major == $rmajor
                    and $prog_minor >= $rminor )
                )
            {
                $self->set_result( "found bison version $prog_version"
                        . " but at least $rmajor.$rminor is required" );
                return;
            }
        }

        $conf->data->set( bison_version => $prog_version );
        $self->set_result("bison $prog_version");
        $conf->data->set( $util => $prog );
    }
    else {
        $self->set_result('yacc program does not exist or does not understand --version');
        return;
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
