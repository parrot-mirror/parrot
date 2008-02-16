#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# init_install-01.t

use strict;
use warnings;
use Test::More qw(no_plan); # tests => 19;
use Carp;
use Cwd;
use Data::Dumper;
use File::Temp qw(tempdir);
use lib qw( lib t/configure/testlib );
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use_ok('config::init::install');
use Parrot::Configure::Parallel::Trace;

my $trace = Parrot::Configure::Parallel::Trace->new($0);
ok(defined $trace, "Parallel::Trace constructor succeeded");
is($trace->store_this_step(), 1, "Step stored");

my $cwd = cwd();
my $pkg  = q{init::install};
{
    my $tdir  = tempdir( CLEANUP => 1 );
    my $tdir1 = tempdir( CLEANUP => 1 );
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
    $conf->refresh($trace->get_previous_state());
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

    is( $conf->data->get('prefix'),         $tdir,  "--prefix option confirmed" );
    is( $conf->data->get('exec_prefix'),    $tdir,  "--exec-prefix option confirmed" );
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

init_install-01.t - test config::init::install

=head1 SYNOPSIS

    % prove t/steps/init_install-01.t

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
