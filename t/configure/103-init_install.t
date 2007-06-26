#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 103-init_install.t

use strict;
use warnings;
use Test::More tests => 19;
use Carp;
use Cwd;
use Data::Dumper;
use File::Temp qw(tempdir);
use lib qw( . lib ../lib ../../lib );
use Parrot::BuildUtil;
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use_ok('config::init::install');

=for hints_for_testing This file ought to test what happens when you provide a
non-default directory to each of the options in config/init/install.  For
testing purposes, these directories probably do not have to be real.  You
should probably test the Parrot::Configure object before and after calling
runsteps() in order to verify that the non-defaults made it into the object.

=cut

my $cwd = cwd();
{
    my $tdir = tempdir();
    my $tdir1 = tempdir();
#    chdir $tdir or croak "Unable to change to tempdir";
    my $pkg = q{init::install};
    my $parrot_version = Parrot::BuildUtil::parrot_version();
    my $args = process_options( {
        argv            => [ 
                            qq{--prefix=$tdir},
                            qq{--exec-prefix=$tdir},
                            qq{--bindir=$tdir1},
                            qq{--sbindir=$tdir1},
                            qq{--libexecdir=$tdir1},
                            qq{--datadir=$tdir1},
                            qq{--sysconfdir=$tdir1},
                            qq{--sharedstatedir=$tdir1},
                            qq{--localstatedir=$tdir1},
                            qq{--libdir=$tdir1},
                            qq{--includedir=$tdir1},
                            qq{--oldincludedir=$tdir1},
                            qq{--infodir=$tdir1},
                            qq{--mandir=$tdir1},
#                            qq{--doc_dir=$tdir1},
                            ],
        script          => $0,
        parrot_version  => $parrot_version,
        svnid           => '$Id$',
    } );
    
    my $conf = Parrot::Configure->new;
    $conf->add_steps($pkg);
    $conf->options->set(%{$args});
    
    my $task = $conf->steps->[0];
    my $step_name   = $task->step;
    my @step_params = @{ $task->params };
    
    my $step = $step_name->new();
    ok(defined $step, "$step_name constructor returned defined value");
    isa_ok($step, $step_name);
    ok($step->description(), "$step_name has description");
    my $ret = $step->runstep($conf);
    ok(defined $ret, "$step_name runstep() returned defined value");
    is($conf->data->get('prefix'), $tdir,
        "--prefix option confirmed");
    is($conf->data->get('exec_prefix'), $tdir,
        "--exec-prefix option confirmed");
    is($conf->data->get('bindir'), $tdir1,
        "--bindir option confirmed");
    is($conf->data->get('sbindir'), $tdir1,
        "--sbindir option confirmed");
    is($conf->data->get('libexecdir'), $tdir1,
        "--libexecdir option confirmed");
    is($conf->data->get('datadir'), $tdir1,
        "--datadir option confirmed");
    is($conf->data->get('sharedstatedir'), $tdir1,
        "--sharedstatedir option confirmed");
    is($conf->data->get('localstatedir'), $tdir1,
        "--localstatedir option confirmed");
    is($conf->data->get('libdir'), $tdir1,
        "--libdir option confirmed");
    is($conf->data->get('includedir'), $tdir1,
        "--includedir option confirmed");
    is($conf->data->get('oldincludedir'), $tdir1,
        "--oldincludedir option confirmed");
    is($conf->data->get('infodir'), $tdir1,
        "--infodir option confirmed");
    is($conf->data->get('mandir'), $tdir1,
        "--mandir option confirmed");
#    is($conf->data->get('doc_dir'), $tdir1,
#        "--doc_dir option confirmed");

#    chdir $cwd or croak "Unable to change back";
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

103-init_install.t - test config::init::install

=head1 SYNOPSIS

    % prove t/configure/103-init_install.t

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
