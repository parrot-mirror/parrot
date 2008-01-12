# Copyright (C) 2001-2007, The Perl Foundation.
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

use Cwd qw(cwd);
use File::Spec::Functions qw(catdir);

sub _init {
    my $self = shift;
    my %data;
    $data{description} = q{Recording configuration data for later retrieval};
    $data{result}      = q{};
    return \%data;
}

sub runstep {
    my ( $self, $conf ) = @_;

    $conf->data->clean;

    $conf->genfile('config/gen/config_pm/myconfig.in', 'myconfig' );

    open( my $IN, "<", "config/gen/config_pm/Config_pm.in" )
        or die "Can't open Config_pm.in: $!";

    my $configdir = catdir(qw/lib Parrot Config/);
    if ( !-d $configdir ) {
        mkdir $configdir
            or die "Can't create dir $configdir: $!";
    }
    open( my $OUT, ">", "lib/Parrot/Config/Generated.pm" )
        or die "Can't open lib/Parrot/Config/Generated.pm: $!";

    print {$OUT} "# Generated by config/gen/config_pm.pm\n";

    while (<$IN>) {
        s/<<PCONFIG>>/$conf->data->dump(q{c}, q{*PConfig})/e;
        s/<<PCONFIGTEMP>>/$conf->data->dump(q{c_temp}, q{*PConfig_Temp})/e;
        print {$OUT} $_;
    }

    close $IN  or die "Can't close Config_pm.in: $!";
    close $OUT or die "Can't close Config.pm: $!";

    my $template = "config/gen/config_pm/config_lib.in";
    open( $IN,  "<", $template )         or die "Can't open '$template': $!";
    open( $OUT, ">", "config_lib.pasm" ) or die "Can't open config_lib.pasm: $!";

    print {$OUT} <<"END";
# Generated by config/gen/config_pm.pm from the template
# '$template' and \%PConfig
# This file should be the last thing run during
# the make process, after Parrot is built.
END

    while (<$IN>) {
        if (/<<PCONFIG>>/) {
            my $k;
            for $k ( sort { lc $a cmp lc $b || $a cmp $b } $conf->data->keys ) {
                my $v = $conf->data->get($k);
                if ( defined $v ) {
                    $v =~ s/(["\\])/\\$1/g;
                    $v =~ s/\n/\\n/g;
                    print {$OUT} qq(\tset P0["$k"], "$v"\n);
                }
                else {
                    print {$OUT} qq(\tset P0["$k"], P1\n);
                }
            }
        }
        elsif (s/<<PWD>>/cwd/e) {
            print {$OUT} $_;
        }
        else {
            print {$OUT} $_;
        }
    }

    close $IN  or die "Can't close config_lib.in: $!";
    close $OUT or die "Can't close config_lib.pasm: $!";

    return 1;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
