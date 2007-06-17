# Copyright (C) 2001-2007, The Perl Foundation.
# $Id$

=head1 NAME

config/auto/readline.pm - Test for readline lib

=head1 DESCRIPTION

Determines whether the platform supports readline.

=cut

package auto::readline;

use strict;
use warnings;
use vars qw($description @args);

use base qw(Parrot::Configure::Step::Base);

use Config;
use Parrot::Configure::Step ':auto';

$description = 'Determining if your platform supports readline';

@args = qw(verbose);

sub runstep {
    my ( $self, $conf ) = @_;

    my $verbose = $conf->options->get('verbose');

    my $cc        = $conf->data->get('cc');
    my $libs      = $conf->data->get('libs');
    my $linkflags = $conf->data->get('linkflags');
    my $ccflags   = $conf->data->get('ccflags');
    if ( $^O =~ /mswin32/i ) {
        if ( $cc =~ /^gcc/i ) {
            $conf->data->add( ' ',
                libs => '-lreadline -lgw32c -lole32 -luuid -lwsock32 -lmsvcp60' );
        }
        else {
            $conf->data->add( ' ', libs => 'readline.lib' );
        }
    }
    elsif ( $^O =~ /linux/i ) {
        $conf->data->add( ' ', libs => '-lreadline -lncurses' );
    }
    else {
        $conf->data->add( ' ', libs => '-lreadline' );
    }

    my $osname = $Config{osname};

    # On OS X check the presence of the readline header in the standard
    # Fink/macports location.
    # RT#43134: Need a more generalized way for finding
    # where Fink lives.
    if ( $osname =~ /darwin/ ) {
        if ( -f "/sw/include/readline/readline.h" ) {
            $conf->data->add( ' ', linkflags => '-L/sw/lib' );
            $conf->data->add( ' ', ldflags   => '-L/sw/lib' );
            $conf->data->add( ' ', ccflags   => '-I/sw/include' );
        }
        if ( -f "/opt/local/include/readline/readline.h" ) {
            $conf->data->add( ' ', linkflags => '-L/opt/local/lib' );
            $conf->data->add( ' ', ldflags   => '-L/opt/local/lib' );
            $conf->data->add( ' ', ccflags   => '-I/opt/local/include' );
        }
    }

    cc_gen('config/auto/readline/readline.in');
    my $has_readline = 0;
    eval { cc_build() };
    if ( !$@ ) {
        if ( cc_run() ) {
            $has_readline = 1;
            print " (yes) " if $verbose;
            $self->set_result('yes');
        }
        $conf->data->set(
            readline     => 'define',
            HAS_READLINE => $has_readline,
        );
    }
    unless ($has_readline) {

        # The Config::Data settings might have changed for the test
        $conf->data->set( 'libs',      $libs );
        $conf->data->set( 'ccflags',   $ccflags );
        $conf->data->set( 'linkflags', $linkflags );
        print " (no) " if $verbose;
        $self->set_result('no');
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
