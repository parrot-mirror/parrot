# Copyright (C) 2001-2003, The Perl Foundation.
# $Id$

=head1 NAME

config/auto/memalign.pm - Memory Alignment

=head1 DESCRIPTION

Determines if the C library supports C<memalign()>.

=cut

package auto::memalign;

use strict;
use warnings;

use base qw(Parrot::Configure::Step);

use Parrot::Configure::Utils ':auto';


sub _init {
    my $self = shift;
    my %data;
    $data{description} = q{Determining if your C library supports memalign};
    $data{args}        = [ qw( miniparrot verbose ) ];
    $data{result}      = q{};
    return \%data;
}

sub runstep {
    my ( $self, $conf ) = @_;

    if ( $conf->options->get('miniparrot') ) {
        $conf->data->set( memalign => '' );
        $self->set_result('skipped');
        return 1;
    }

    if ( defined $conf->data->get('memalign') ) {

        # already set; leave it alone
        $self->set_result('already set');
        return 1;
    }
    my $test = 0;

    _set_malloc_header($conf);

    _set_ptrcast($conf);

    $conf->cc_gen('config/auto/memalign/test_c.in');
    eval { $conf->cc_build(); };
    unless ( $@ || $conf->cc_run_capture() !~ /ok/ ) {
        $test = 1;
    }
    $conf->cc_clean();

    my $test2 = 0;

    $conf->cc_gen('config/auto/memalign/test_c2.in');
    eval { $conf->cc_build(); };
    unless ( $@ || $conf->cc_run_capture() !~ /ok/ ) {
        $test2 = 1;
    }
    $conf->cc_clean();

    $self->_set_memalign($conf, $test, $test2);

    return 1;
}

sub _set_malloc_header {
    my $conf = shift;
    if ( $conf->data->get('i_malloc') ) {
        $conf->data->set( malloc_header => 'malloc.h' );
    }
    else {
        $conf->data->set( malloc_header => 'stdlib.h' );
    }
}

sub _set_ptrcast {
    my $conf = shift;
    if ( $conf->data->get('ptrsize') == $conf->data->get('intsize') ) {
        $conf->data->set( ptrcast => 'int' );
    }
    else {
        $conf->data->set( ptrcast => 'long' );
    }
}

sub _set_memalign {
    my $self = shift;
    my ($conf, $test, $test2) = @_;
    $conf->data->set( malloc_header => undef );

    my $f =
          $test2 ? 'posix_memalign'
        : $test  ? 'memalign'
        :          '';
    $conf->data->set( memalign => $f );
    print( $test ? " (Yep:$f) " : " (no) " ) if $conf->options->get('verbose');
    $self->set_result( $test ? 'yes' : 'no' );
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
