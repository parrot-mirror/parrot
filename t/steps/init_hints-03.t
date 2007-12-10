#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# init_hints-03.t

use strict;
use warnings;
use Test::More tests =>  9;
use Carp;
use Cwd;
use File::Path ();
use File::Temp qw(tempdir);
use lib qw( lib t/configure/testlib t/steps/testlib );
use_ok('config::init::hints');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Test qw( test_step_thru_runstep);
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
        argv => [q{--verbose}],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;
$conf->refresh(get_previous_state($pkg));

my ( $task, $step_name, $step, $ret );

$conf->add_steps($pkg);
$conf->options->set( %{$args} );

$task        = $conf->steps->[-1];
$step_name   = $task->step;

$step = $step_name->new();
ok( defined $step, "$step_name constructor returned defined value" );
isa_ok( $step, $step_name );
ok( $step->description(), "$step_name has description" );
my $cwd = cwd();
{
    my $tdir = tempdir( CLEANUP => 1 );
    File::Path::mkpath(qq{$tdir/init/hints})
        or croak "Unable to create directory for local hints";
    my $localhints = qq{$tdir/init/hints/local.pm};
    open my $FH, '>', $localhints
        or croak "Unable to open temp file for writing";
    print $FH <<END;
package init::hints::local;
use strict;
1;
END
    close $FH or croak "Unable to close temp file after writing";
    unshift( @INC, $tdir );

    # need to capture the --verbose output,
    # because the fact that it does not end
    # in a newline confuses Test::Harness
    {
        my ($ret, $stdout);
        capture(
            sub { $ret = $step->runstep($conf); },
            \$stdout,
        );
        ok( $stdout, "verbose output:  hints were captured" );
        ok( defined $ret, "$step_name runstep() returned defined value" );
    }
    unlink $localhints or croak "Unable to delete $localhints";
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

init_hints-03.t - test config::init::hints

=head1 SYNOPSIS

    % prove t/steps/init_hints-03.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::init::hints.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::init::hints, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
