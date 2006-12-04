# Copyright (C) 2001-2003, The Perl Foundation.
# $Id$

=head1 NAME

config/gen/config_pm.pm - Record configuration data

=head1 DESCRIPTION

Writes the C<Parrot::Config> Perl module, the
F<runtime/parrot/library/config.fpmc> generator program, and the F<myconfig>
file.

=cut

package gen::config_pm;

use strict;
use warnings;
use vars qw($description @args);

use base qw(Parrot::Configure::Step::Base);

use Parrot::Configure::Step qw(genfile);
use Data::Dumper;
use Cwd qw(cwd);
use File::Spec::Functions qw(catdir);

$description = "Recording configuration data for later retrieval";

@args = ();

sub runstep
{
    my ($self, $conf) = @_;

    $conf->data->clean;

    genfile('config/gen/config_pm/myconfig.in', 'myconfig');

    open(IN, "<", "config/gen/config_pm/Config_pm.in")
        or die "Can't open Config_pm.in: $!";

    unless ( -d catdir( qw/lib Parrot Config/ ) ) {
        mkdir catdir( qw/lib Parrot Config/ )
            or die "Can't create dir ".catdir( qw/lib Parrot Config/ ).": $!";
    }
    open(OUT, ">", "lib/Parrot/Config/Generated.pm")
        or die "Can't open lib/Parrot/Config/Generated.pm: $!";

    print OUT "# Generated by config/gen/config_pm.pm\n";

    while (<IN>) {
        s/<<HERE>>/$conf->data->dump()/e;
        print OUT;
    }

    close IN  or die "Can't close Config_pm.in: $!";
    close OUT or die "Can't close Config.pm: $!";

    my $template = "config/gen/config_pm/config_lib.in";
    open(IN, "<", $template)          or die "Can't open '$template': $!";
    open(OUT, ">", "config_lib.pasm") or die "Can't open config_lib.pasm: $!";

    print OUT <<"END";
# Generated by config/gen/config_pm.pm from the template
# '$template' and \%PConfig
# This file should be the last thing run during
# the make process, after Parrot is built.
END

    while (<IN>) {
        if (/<<HERE>>/) {
            my $k;
            for $k (sort { lc $a cmp lc $b || $a cmp $b } $conf->data->keys) {
                my $v = $conf->data->get($k);
                if (defined $v) {
                    $v =~ s/(["\\])/\\$1/g;
                    $v =~ s/\n/\\n/g;
                    print OUT qq(\tset P0["$k"], "$v"\n);
                } else {
                    print OUT qq(\tset P0["$k"], P1\n);
                }
            }
        } elsif (s/<<PWD>>/cwd/e) {
            print OUT;
        } else {
            print OUT;
        }
    }

    close IN  or die "Can't close config_lib.in: $!";
    close OUT or die "Can't close config_lib.pasm: $!";

    return $self;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
