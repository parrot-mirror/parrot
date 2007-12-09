#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# init_install-02.t

use strict;
use warnings;
use Test::More tests => 21;
use Carp;
use Cwd;
use Data::Dumper;
use File::Temp qw(tempdir);
use lib qw( lib t/configure/testlib t/steps/testlib );
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use_ok('config::init::install');
use Auxiliary qw(
    get_step_name
    store_this_step_pure
    get_previous_state
);

my $cwd = cwd();
{
    my $pkg = get_step_name($0);
    ok($pkg, "Step name has true value");
    ok(store_this_step_pure($pkg), "State stored");

    my $tdir      = tempdir();
    my $tdir_orig = $tdir;
    $tdir .= q{/};
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

    my $conf = Parrot::Configure->new;
    $conf->refresh(get_previous_state($pkg));
    $conf->add_steps($pkg);
    $conf->options->set( %{$args} );

    my $task        = $conf->steps->[-1];
    my $step_name   = $task->step;

    my $step = $step_name->new();
    ok( defined $step, "$step_name constructor returned defined value" );
    isa_ok( $step, $step_name );
    ok( $step->description(), "$step_name has description" );

    my $ret = $step->runstep($conf);
    ok( defined $ret, "$step_name runstep() returned defined value" );

    is( $conf->data->get('prefix'),
        $tdir_orig, "--prefix option confirmed; trailing slash stripped" );
    is( $conf->data->get('exec_prefix'),
        $tdir_orig, "--exec-prefix option confirmed; trailing slash stripped" );
    is( $conf->data->get('bindir'),         $tdir1, "--bindir option confirmed" );
    is( $conf->data->get('sbindir'),        $tdir1, "--sbindir option confirmed" );
    is( $conf->data->get('libexecdir'),     $tdir1, "--libexecdir option confirmed" );
    is( $conf->data->get('datadir'),        $tdir1, "--datadir option confirmed" );
    is( $conf->data->get('sharedstatedir'), $tdir1, "--sharedstatedir option confirmed" );
    is( $conf->data->get('localstatedir'),  $tdir1, "--localstatedir option confirmed" );
    is( $conf->data->get('libdir'),         $tdir1, "--libdir option confirmed" );
    is( $conf->data->get('includedir'),     $tdir1, "--includedir option confirmed" );
    is( $conf->data->get('oldincludedir'),  $tdir1, "--oldincludedir option confirmed" );
    is( $conf->data->get('infodir'),        $tdir1, "--infodir option confirmed" );
    is( $conf->data->get('mandir'),         $tdir1, "--mandir option confirmed" );
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

init_install-02.t - test config::init::install

=head1 SYNOPSIS

    % prove t/steps/init_install-02.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::init::install.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::init::install, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
