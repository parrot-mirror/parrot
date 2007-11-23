#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 062-initialize.t

use strict;
use warnings;

use Test::More tests => 19;
use Carp;
use Cwd;
use File::Temp qw(tempdir);
use lib qw( lib t/configure/testlib );
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Initialize;

my $cwd = cwd();
{
    my $tdir  = tempdir();
    my $tdir1 = tempdir();
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
    my $init = Parrot::Configure::Initialize->new($args);
    ok(defined $init,
        "Parrot::Configure::Initialize returned defined value");
    isa_ok($init, "Parrot::Configure::Initialize");
    ok($init->init_install(), 'init_install() completed okay');

    is( $init->get('prefix'),         $tdir,  "--prefix option confirmed" );
    is( $init->get('exec_prefix'),    $tdir,  "--exec-prefix option confirmed" );
    is( $init->get('bindir'),         $tdir1, "--bindir option confirmed" );
    is( $init->get('sbindir'),        $tdir1, "--sbindir option confirmed" );
    is( $init->get('libexecdir'),     $tdir1, "--libexecdir option confirmed" );
    is( $init->get('datadir'),        $tdir1, "--datadir option confirmed" );
    is( $init->get('doc_dir'),        qq{$tdir1/doc/parrot}, "--datadir option confirmed" );
    is( $init->get('sysconfdir'),     $tdir1, "--syscondir option confirmed" );
    is( $init->get('sharedstatedir'), $tdir1, "--sharedstatedir option confirmed" );
    is( $init->get('localstatedir'),  $tdir1, "--localstatedir option confirmed" );
    is( $init->get('libdir'),         $tdir1, "--libdir option confirmed" );
    is( $init->get('includedir'),     $tdir1, "--includedir option confirmed" );
    is( $init->get('oldincludedir'),  $tdir1, "--oldincludedir option confirmed" );
    is( $init->get('infodir'),        $tdir1, "--infodir option confirmed" );
    is( $init->get('mandir'),         $tdir1, "--mandir option confirmed" );
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

062-initialize.t - Test Parrot::Configure::Initialize

=head1 SYNOPSIS

    % prove t/configure/062-initialize.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test Parrot::Configure::Initialize::Install in the
case where command-line options have been provided.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure, Parrot::Configure::Initialize,
Parrot::Configure::Initialize::Defaults, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:


