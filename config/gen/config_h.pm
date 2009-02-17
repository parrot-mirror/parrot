# Copyright (C) 2001-2007, Parrot Foundation.
# $Id$

=head1 NAME

config/gen/config_h.pm - Configuration Header

=head1 DESCRIPTION

Generates F<include/parrot/config.h> with platform-specific configuration
values, F<include/parrot/has_header.h> with platform-specific header
information, and F<include/parrot/feature.h> with information on optional
features.

=cut

package gen::config_h;

use strict;
use warnings;

use base qw(Parrot::Configure::Step);

use Parrot::Configure::Utils ':gen';


sub _init {
    my $self = shift;
    my %data;
    $data{description} = q{Generate C headers};
    $data{result}      = q{};
    $data{templates}    = {
        config_h    => 'config/gen/config_h/config_h.in',
        feature_h   => 'config/gen/config_h/feature_h.in',
    };
    return \%data;
}

sub runstep {
    my ( $self, $conf ) = @_;

    $conf->genfile($self->{templates}->{config_h}, 'include/parrot/config.h',
        ignore_pattern    => 'PARROT_CONFIG_DATE',
        conditioned_lines => 1
    );

    $conf->genfile($self->{templates}->{feature_h}, 'include/parrot/feature.h',
        ignore_pattern => 'PARROT_CONFIG_DATE',
        feature_file   => 1
    );

    my $hh = "include/parrot/has_header.h";
    $conf->append_configure_log($hh);
    open( my $HH, ">", "$hh.tmp" )
        or die "Can't open has_header.h: $!";

    print {$HH} <<EOF;
/*
** !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
**
** This file is generated automatically by Configure.pl
*/

#ifndef PARROT_HAS_HEADER_H_GUARD
#define PARROT_HAS_HEADER_H_GUARD

/*
 * i_(\\w+) header includes
 */

EOF

    for ( sort( $conf->data->keys() ) ) {
        next unless /i_(\w+)/;
        if ( $conf->data->get($_) ) {
            print {$HH} "#define PARROT_HAS_HEADER_\U$1 1\n";
        }
        else {
            print {$HH} "#undef  PARROT_HAS_HEADER_\U$1\n";
        }
    }

    my $osname = $conf->data->get_p5('OSNAME');
    print {$HH} "\n#define BUILD_OS_NAME \"$osname\"\n";

    _handle_define_option($conf, $HH);

    print {$HH} <<EOF;

/*
 * HAS_(\\w+) config entries
 */

EOF
    for ( sort( $conf->data->keys() ) ) {
        next unless /HAS_(\w+)/;
        if ( $conf->data->get($_) ) {
            print {$HH} "#define PARROT_HAS_\U$1 1\n";
        }
    }
    print {$HH} <<EOF;

/*
 * D_(\\w+) config entries
 */

EOF
    for ( sort( $conf->data->keys() ) ) {
        next unless /D_(\w+)/;
        my $val;
        if ( $val = $conf->data->get($_) ) {
            print {$HH} "#define PARROT_\U$1 $val\n";
        }
    }

    # append the guard endif and C code coda
    print {$HH} <<EOF;

#endif /* PARROT_HAS_HEADER_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
EOF

    close $HH;

    move_if_diff( "$hh.tmp", $hh );

    return 1;
}

sub _handle_define_option {
    my ($conf, $HH) = @_;
    my $define = $conf->options->get('define');

    if ($define) {
        my @vals = split /,/, $define;
        print {$HH} <<EOF;

/*
 * defines from commandline
 */

EOF
        for my $v (@vals) {
            print {$HH} "#define PARROT_DEF_" . uc($v), " 1\n";
        }
    }
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
