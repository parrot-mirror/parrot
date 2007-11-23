#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 064-init_miniparrot.t

use strict;
use warnings;

use Test::More tests => 16;
use Carp;
use Cwd;
use File::Temp qw(tempdir);
use lib qw( lib t/configure/testlib );
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Initialize;

my $cwd = cwd();
my $args  = process_options(
    {
        argv => [q{--miniparrot}],
        mode => q{configure},
    }
);
my $init = Parrot::Configure::Initialize->new($args);
ok(defined $init,
    "Parrot::Configure::Initialize returned defined value");
isa_ok($init, "Parrot::Configure::Initialize");
ok($init->init_defaults(), 'init_defaults() completed okay');

is( $init->get('miniparrot'),  undef, "miniparrot is not yet enabled" );
is( $init->get('jitarchname'), undef, "jitarchname undef as expected" );
is( $init->get('jitcpuarch'),  undef, "jitcpuarch undef as expected" );
is( $init->get('jitcpu'),      undef, "jitcpu undef as expected" );
is( $init->get('jitosname'),   undef, "jitosname undef as expected" );

ok($init->init_miniparrot(), 'init_miniparrot() completed okay');

ok( $init->get('miniparrot'),  "miniparrot is enabled" );
is( $init->get('jitarchname'), 'nojit', "jitarchname as expected" );
is( $init->get('jitcpuarch'),  'i386',  "jitcpuarch as expected" );
is( $init->get('jitcpu'),      'I386',  "jitcpu as expected" );
is( $init->get('jitosname'),   'nojit', "jitosname as expected" );
ok( !$init->get('jitcapable'), "not jitcapable as expected" );

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

064-init_miniparrot.t - Test Parrot::Configure::Initialize

=head1 SYNOPSIS

    % prove t/configure/064-init_miniparrot.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test whether the C<--miniparrot> option overrides the
default settings.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure, Parrot::Configure::Initialize,
Parrot::Configure::Initialize::Defaults,
Parrot::Configure::Initialize::Miniparrot, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:


