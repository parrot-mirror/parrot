# Copyright (C) 2001-2009, The Perl Foundation.
# $Id$

=head1 NAME

config/gen/config_pm.pm - Record configuration data

=head1 DESCRIPTION

Writes the C<Parrot::Config::Generated> Perl module, the
F<runtime/parrot/library/config.fpmc> generator program, and the F<myconfig>
file.

=cut

package gen::config_pm;

use strict;
use warnings;

use base qw(Parrot::Configure::Step);
use Parrot::Configure::Utils ':gen';

use Cwd qw(cwd);
use File::Spec::Functions qw(catdir);

sub _init {
    my $self = shift;
    my %data;
    $data{description} = q{Record configuration data for later retrieval};
    $data{result}      = q{};
    $data{templates}    = {
        myconfig        => 'config/gen/config_pm/myconfig.in',
        Config_pm       => 'config/gen/config_pm/Config_pm.in',
        config_lib      => 'config/gen/config_pm/config_lib_pasm.in',
    };
    return \%data;
}

sub runstep {
    my ( $self, $conf ) = @_;

    $conf->data->clean;

    my $template = $self->{templates}->{myconfig};
    $conf->genfile($template, 'myconfig' );

    $template = $self->{templates}->{Config_pm};
    open( my $IN, "<", $template )
        or die "Can't open $template: $!";

    my $configdir = catdir(qw/lib Parrot Config/);
    unless ( -d $configdir ) {
        mkdir $configdir
            or die "Can't create dir $configdir: $!";
    }
    my $gen_pm = q{lib/Parrot/Config/Generated.pm};
    $conf->append_configure_log($gen_pm);
    open( my $OUT, ">", $gen_pm )
        or die "Can't open $gen_pm: $!";

    my $pkg = __PACKAGE__;
    print {$OUT} <<"END";
# ex: set ro:
# DO NOT EDIT THIS FILE
# Generated by $pkg from $template

END

    while (<$IN>) {
        s/\@PCONFIG\@/$conf->data->dump(q{c}, q{*PConfig})/e;
        s/\@PCONFIGTEMP\@/$conf->data->dump(q{c_temp}, q{*PConfig_Temp})/e;
        print {$OUT} $_;
    }

    close $IN  or die "Can't close $template: $!";
    close $OUT or die "Can't close $gen_pm: $!";

    $template = $self->{templates}->{config_lib};
    open( $IN,  "<", $template ) or die "Can't open '$template': $!";
    my $c_l_pasm = q{config_lib.pasm};
    $conf->append_configure_log($c_l_pasm);
    open( $OUT, ">", $c_l_pasm ) or die "Can't open $c_l_pasm: $!";

    print {$OUT} <<"END";
# ex: set ro:
# DO NOT EDIT THIS FILE
# Generated by $pkg from $template and \%PConfig
# This file should be the last thing run during
# the make process, after Parrot is built.

END

    while (<$IN>) {
        if (/\@PCONFIG\@/) {
            for my $k ( sort { lc $a cmp lc $b || $a cmp $b } $conf->data->keys ) {
                my $v = $conf->data->get($k);
                if ( defined $v ) {
                    my $type = ref $v;
                    if ( $type ) {
                        die "type of '$k' is not supported : $type\n";
                    }
                    # Scalar
                    $v =~ s/(["\\])/\\$1/g;
                    $v =~ s/\n/\\n/g;
                    print {$OUT} qq(    set P0["$k"], "$v"\n);
                }
                else {
                    # Undef
                    print {$OUT} qq(    set P0["$k"], P1\n);
                }
            }
        }
        elsif (s/\@PWD\@/cwd/e) {
            print {$OUT} $_;
        }
        else {
            print {$OUT} $_;
        }
    }

    close $IN  or die "Can't close $template: $!";
    close $OUT or die "Can't close $c_l_pasm: $!";

    return 1;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
