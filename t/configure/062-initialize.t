#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 062-initialize.t

use strict;
use warnings;

use Test::More qw(no_plan); # tests => 12;
use Carp;
use Cwd;
use File::Temp qw(tempdir);
use lib qw( lib t/configure/testlib );
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Initialize;

my $cwd = cwd();
{
    my $tdir  = tempdir();
    my $tdir1 = tempdir();
    my $args  = process_options(
        {
            argv => [
                qq{--prefix=$tdir},         qq{--exec-prefix=$tdir},
                qq{--bindir=$tdir1},        qq{--sbindir=$tdir1},
                qq{--libexecdir=$tdir1},    qq{--datadir=$tdir1},
                qq{--sysconfdir=$tdir1},    qq{--sharedstatedir=$tdir1},
                qq{--localstatedir=$tdir1}, qq{--libdir=$tdir1},
                qq{--includedir=$tdir1},    qq{--oldincludedir=$tdir1},
                qq{--infodir=$tdir1},       qq{--mandir=$tdir1},
            ],
            mode => q{configure},
        }
    );
    my $init = Parrot::Configure::Initialize->new($args);
    ok(defined $init,
        "Parrot::Configure::Initialize returned defined value");
    isa_ok($init, "Parrot::Configure::Initialize");
}

#my $args = process_options(
#    {
#        argv => [q{--debugging=0}, q{--profile}, q{--m=32}],
#        mode => q{configure},
#    }
#);
#ok($init->init_defaults(), 'init_defaults() completed okay');
#
## Next 3 tests cheat by breaking encapsulation.
#is($init->{debugging}, 0, "Got expected value for 'debugging'");
#is($init->{cc_debug}, q{ -pg }, "Got expected value for 'cc_debug'");
#is($init->{options}->{m}, 32, "Got expected value for 'm'");
#
#    my $conf = Parrot::Configure->new;
#    test_step_thru_runstep( $conf, q{init::install}, $args );
#
#    is( $conf->data->get('prefix'),         $tdir,  "--prefix option confirmed" );
#    is( $conf->data->get('exec_prefix'),    $tdir,  "--exec-prefix option confirmed" );
#    is( $conf->data->get('bindir'),         $tdir1, "--bindir option confirmed" );
#    is( $conf->data->get('sbindir'),        $tdir1, "--sbindir option confirmed" );
#    is( $conf->data->get('libexecdir'),     $tdir1, "--libexecdir option confirmed" );
#    is( $conf->data->get('datadir'),        $tdir1, "--datadir option confirmed" );
#    is( $conf->data->get('sharedstatedir'), $tdir1, "--sharedstatedir option confirmed" );
#    is( $conf->data->get('localstatedir'),  $tdir1, "--localstatedir option confirmed" );
#    is( $conf->data->get('libdir'),         $tdir1, "--libdir option confirmed" );
#    is( $conf->data->get('includedir'),     $tdir1, "--includedir option confirmed" );
#    is( $conf->data->get('oldincludedir'),  $tdir1, "--oldincludedir option confirmed" );
#    is( $conf->data->get('infodir'),        $tdir1, "--infodir option confirmed" );
#    is( $conf->data->get('mandir'),         $tdir1, "--mandir option confirmed" );
#}
pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

062-initialize.t - Test Parrot::Configure::Initialize.

=head1 SYNOPSIS

    % prove t/configure/062-initialize.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test Parrot::Configure::Initialize::Defaults in the
case where command-line options have been provided.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure, Parrot::Configure::Initialize,
Parrot::Configure::Initialize::Defaults, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:


