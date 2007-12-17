# Copyright (C) 2001-2007, The Perl Foundation.
# $Id$

=head1 NAME

config/auto/cpu/i386/auto.pm

=head1 DESCRIPTION

Test

=cut

package auto::cpu::i386::auto;

use strict;
use warnings;

sub runstep {
    my ( $self, $conf ) = @_;

    my $verbose = $conf->options->get('verbose');

    my @files = qw( test_gcc_cmpxchg.in );
    for my $f (@files) {
        print " $f " if $verbose;
        my ($suffix) = $f =~ /test_(\w+)/;
        $f = "config/auto/cpu/i386/$f";
        $conf->cc_gen($f);
        eval { $conf->cc_build("-DPARROT_CONFIG_TEST") };
        if ($@) {
            print " $@ " if $verbose;
        }
        else {
            if ( $conf->cc_run() =~ /ok/ ) {
                $conf->data->set(
                    "i386_has_$suffix" => '1',
                    "HAS_i386_$suffix" => '1',
                );
                print " (\U$suffix) " if ($verbose);
                $conf->data->add( ' ', TEMP_generated => $f );
            }
        }
        $conf->cc_clean();
    }
    return;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
