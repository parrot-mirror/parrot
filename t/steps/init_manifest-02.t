#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# init_manifest-02.t

use strict;
use warnings;
use Test::More tests =>  8;
use Carp;
use Cwd;
use File::Copy;
use File::Temp qw(tempdir);
use lib qw( lib t/steps/testlib );
use_ok('config::init::manifest');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use IO::CaptureOutput qw| capture |;
use Auxiliary qw(
    get_step_name
    store_this_step_pure
    get_previous_state
);

my $pkg = get_step_name($0);
ok($pkg, "Step name has true value");

ok(store_this_step_pure($pkg), "State stored");

my $args = process_options(
    {
        argv => [],
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

# Lets see if we can trick ExtUtils::Manifest into thinking there are missing
# files.
my $cwd = cwd();
{
    my $tdir = tempdir();
    chdir $tdir or croak "Unable to change to tempdir";
    copy( qq{$cwd/MANIFEST}, qq{$tdir/MANIFEST} )
        or croak "Unable to copy MANIFEST";
    {
        my ($ret, $stdout, $stderr);
        capture(
            sub { $ret = $step->runstep($conf); },
            \$stdout,
            \$stderr,
        );
        is( $ret, undef, "$step_name runstep returned undef" );
    }
    chdir $cwd or croak "Unable to change back";
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

init_manifest-02.t - test config::init::manifest

=head1 SYNOPSIS

    % prove t/steps/init_manifest-02.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::init::manifest.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::init::manifest, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
