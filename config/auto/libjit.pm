# Copyright (C) 2009, Parrot Foundation.
# $Id$

=head1 NAME

config/auto/libjit - Check whether LibJIT is installed

=head1 DESCRIPTION

Determines whether libjit is present is installed and functional on the system.
It is OK when it doesn't exist.

The libjit library implements just-in-time compilation functionality. Unlike
other JITs, this one is designed to be independent of any particular virtual
machine bytecode format or language. 

libjit can be obtained from L<http://freshmeat.net/projects/libjit/> or through
your distribution's package manager. Developer documentation is available from
L<http://www.gnu.org/software/dotgnu/libjit-doc/libjit.html>

=cut

package auto::libjit;

use strict;
use warnings;

use base 'Parrot::Configure::Step';

use Parrot::Configure::Utils ':auto';

sub _init {
    my $self = shift;
    my %data = (
        description => 'Is LibJIT installed',
        result        => '',
    );
    return \%data;
}

sub runstep {
    my ($self, $conf) = @_;

    my ($verbose, $without) = $conf->options->get( qw{
                                    verbose
                                    without-libjit
    });

    my ($has_libjit, $extra_libs);
    if ($without) {
        $has_libjit = 0;
    }
    else {
        $extra_libs = $self->_select_lib( {
            conf         => $conf,
            osname       => $conf->data->get_p5('OSNAME'),
            cc           => $conf->data->get('cc'),
            win32_nongcc => 'libjit.lib',
            default      => '-ljit',
        } );

        $conf->cc_gen('config/auto/libjit/libjit_c.in');
        eval { $conf->cc_build('', $extra_libs) };
        if ($@) {
            print "cc_build() failed: $@\n" if $verbose;
            $has_libjit = 0;
        }
        else {
            my $test;
            eval { $test = $conf->cc_run(); };
            if ($@) {
                print "cc_run() failed: $@\n" if $verbose;
                $has_libjit = 0;
            }
            else {
                $has_libjit =
                    $self->_evaluate_cc_run($test, $has_libjit, $verbose);
            }
        }
        $conf->cc_clean();
    }

    $conf->data->set( HAS_LIBJIT => $has_libjit );
    _handle_has_libjit($conf, $has_libjit, $extra_libs);
    $self->set_result( $has_libjit ? 'yes' : 'no' );

    return 1;
}

sub _evaluate_cc_run {
    my ($self, $test, $has_libjit, $verbose) = @_;
    if ($test =~ m/^USES INTERPRETER: \d+/ ) {
        $has_libjit = 1;
        print " (yes) " if $verbose;
        $self->set_result("yes");
    }
    return $has_libjit;
}

sub _handle_has_libjit {
    my ($conf, $has_libjit, $extra_libs) = @_;
    if ($has_libjit) {
        $conf->data->set(
            libjit_has_alloca    => ($conf->data->get('cpuarch') eq 'i386' ? '1' : '0'),
        );
        $conf->data->add( ' ', libs => $extra_libs );
    }
    else {
        $conf->data->set( libjit_has_alloca => 0 );
    }
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
