#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# gen_config_h-01.t

use strict;
use warnings;
use Test::More tests =>  7;
use Carp;
use lib qw( lib );
use_ok('config::gen::config_h');
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Test qw(
    test_step_thru_runstep
    test_step_constructor_and_description
);

my $args = process_options(
    {
        argv => [ ],
        mode => q{configure},
    }
);

my $conf = Parrot::Configure->new;
my $pkg = q{gen::config_h};
$conf->add_steps($pkg);
$conf->options->set( %{$args} );
my $step = test_step_constructor_and_description($conf);
ok(-f 'config/gen/config_h/config_h.in',
    "Prequisite file config_h.in located");
ok(-f 'config/gen/config_h/feature_h.in',
    "Prequisite file feathre_h.in located");

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

gen_config_h-01.t - test config::gen::config_h

=head1 SYNOPSIS

    % prove t/steps/gen_config_h-01.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test configuration step gen::config_h.  Since this step
is primarily concerned with printing to files based on reading certain source
files and reading data stored in the Parrot::Configure object over the course
of configuration, no complete simulation by a test file is feasible.  We
therefore content ourselves with seeing whether the source files needed by the
step can be located.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

config::gen::config_h, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
