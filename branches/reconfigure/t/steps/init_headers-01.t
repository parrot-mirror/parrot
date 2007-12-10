#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# init_headers-00.t

use strict;
use warnings;
use Test::More tests =>  9;
use Carp;
use Cwd;
use File::Copy;
use File::Temp qw(tempdir);
use Tie::File;
use lib qw( lib t/configure/testlib t/steps/testlib );
use_ok('config::init::headers');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
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

my $cwd = cwd();
{
    my $tdir = tempdir( CLEANUP => 1 );
    chdir $tdir or croak "Unable to change to tempdir for testing";
    copy qq{$cwd/MANIFEST}, qq{$tdir/MANIFEST}
        or croak "Unable to copy MANIFEST for testing";
    my @lines;
    tie @lines, 'Tie::File', qq{$tdir/MANIFEST}
        or croak "Unable to tie to temporary MANIFEST";
    push @lines, q{include/parrot/phony.h    [main]include};
    untie @lines;
    my $ret = $step->runstep($conf);
    ok( defined $ret, "$step_name runstep() returned defined value" );
    like( $conf->data->get(q{TEMP_nongen_headers}), qr{\$\(INC_DIR\)/phony\.h\\},
qq{Header added to MANIFEST for testing purposes correctly detected in Parrot::Configure object data structure}
    );

    chdir $cwd
        or croak "Unable to change back to starting directory after testing";
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

init_headers-00.t - test config::init::headers

=head1 SYNOPSIS

    % prove t/steps/init_headers-00.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by config::init::headers.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::init::headers, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
