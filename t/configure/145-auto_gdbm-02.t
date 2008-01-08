#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 145-auto_gdbm-02.t

use strict;
use warnings;
use Test::More tests => 25;
use Carp;
use Cwd;
use File::Temp qw( tempdir );
use lib qw( lib t/configure/testlib );
use_ok('config::init::defaults');
use_ok('config::auto::gdbm');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Test qw( test_step_thru_runstep);

my $args = process_options(
    {
        argv => [ q{--without-gdbm} ],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;

test_step_thru_runstep( $conf, q{init::defaults}, $args );

my $pkg = q{auto::gdbm};

$conf->add_steps($pkg);
$conf->options->set( %{$args} );

my ( $task, $step_name, $step);
$task        = $conf->steps->[1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );

my $osname;
my ($flagsbefore, $flagsafter);

$osname = 'foobar';
$flagsbefore = $conf->data->get( 'linkflags' );
ok($step->_handle_darwin_for_fink($conf, $osname, 'gdbm.h'),
    "handle_darwin_for_fink() returned true value");
$flagsafter = $conf->data->get( 'linkflags' );
is($flagsbefore, $flagsafter, "No change in linkflags, as expected");

my $cwd = cwd();
{
    my $tdir = tempdir( CLEANUP => 1 );
    ok(chdir $tdir, "Able to change to temporary directory");
    ok( (mkdir 'lib'), "Able to make lib directory");
    ok( (mkdir 'include'), "Able to make include directory");
    $conf->data->set('fink_lib_dir' => qq{$tdir/lib});
    $conf->data->set('fink_include_dir' => qq{$tdir/include});
    $osname = 'darwin';
    $flagsbefore = $conf->data->get( 'linkflags' );
    ok($step->_handle_darwin_for_fink($conf, $osname, 'gdbm.h'),
        "handle_darwin_for_fink() returned true value");
    $flagsafter = $conf->data->get( 'linkflags' );
    is($flagsbefore, $flagsafter, "No change in linkflags, as expected");

    ok(chdir $cwd, "Able to change back to original directory after testing");
}

{
    my $tdir2 = tempdir( CLEANUP => 1 );
    ok(chdir $tdir2, "Able to change to temporary directory");
    ok( (mkdir 'lib'), "Able to make lib directory");
    ok( (mkdir 'include'), "Able to make include directory");
    my $libdir = qq{$tdir2/lib};
    my $includedir = qq{$tdir2/include};
    $conf->data->set('fink_lib_dir' => $libdir);
    $conf->data->set('fink_include_dir' => $includedir);
    my $foo = qq{$includedir/gdbm.h};
    open my $FH, ">", $foo or croak "Could not open for writing";
    print $FH "Hello world\n";
    close $FH or croak "Could not close after writing";
    
    $osname = 'darwin';
    $flagsbefore = $conf->data->get( 'linkflags' );
    ok($step->_handle_darwin_for_fink($conf, $osname, 'gdbm.h'),
        "handle_darwin_for_fink() returned true value");
    $flagsafter = $conf->data->get( 'linkflags' );
    isnt($flagsbefore, $flagsafter, "Change in linkflags, as expected");
    like($conf->data->get( 'linkflags' ), qr/-L$libdir/,
        "'linkflags' modified as expected");

    ok(chdir $cwd, "Able to change back to original directory after testing");
}
pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

145-auto_gdbm-02.t - test config::auto::gdbm

=head1 SYNOPSIS

    % prove t/configure/145-auto_gdbm-02.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test config::auto::gdbm in the case where the
C<--without-gdbm> option is set.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::auto::gdbm, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
