#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 066-init_headers.t

use strict;
use warnings;

use Test::More tests =>  8;
use Carp;
use Cwd;
use File::Copy;
use File::Temp qw(tempdir);
use Tie::File;
use lib qw( lib t/configure/testlib );
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Initialize;
use Parrot::IO::Capture::Mini;

my $args  = process_options(
    {
        argv => [],
        mode => q{configure},
    }
);
my $init = Parrot::Configure::Initialize->new($args);
ok(defined $init,
    "Parrot::Configure::Initialize returned defined value");
isa_ok($init, "Parrot::Configure::Initialize");
ok($init->init_defaults(), 'init_defaults() completed okay');
ok($init->init_install(), 'init_install() completed okay');
ok($init->init_hints(), 'init_hints() completed okay');

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
    my $ret = $init->init_headers();
    ok( $ret, "init_headers() returned true value" );
    like(
        $init->get(q{TEMP_nongen_headers}),
        qr{\$\(INC_DIR\)/phony\.h\\},
        qq{Header added to MANIFEST for testing purposes correctly detected in Parrot::Configure object data structure}
    );

    chdir $cwd
        or croak "Unable to change back to starting directory after testing";
}
pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

066-init_headers.t - Test Parrot::Configure::Initialize

=head1 SYNOPSIS

    % prove t/configure/066-init_headers.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test configuration initialization conducted by
Parrot::Configure::Initialize::Headers.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure, Parrot::Configure::Initialize,
Parrot::Configure::Initialize::Headers,
F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:


