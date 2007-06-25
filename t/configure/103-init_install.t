#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 103-init_install.t

use strict;
use warnings;
use Test::More qw(no_plan); # tests =>  2;
use Carp;
use Cwd;
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
#    chdir $tdir or croak "Unable to change to tempdir";
    my $pkg = q{init::install};
    my $parrot_version = Parrot::BuildUtil::parrot_version();
    my $args = process_options( {
        argv            => [ q{--prefix=$tdir} ],
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
