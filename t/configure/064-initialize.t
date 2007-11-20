#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 064-initialize.t

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
my $args  = process_options(
    {
        argv =>[],
        mode => q{configure},
    }
);
my $init = Parrot::Configure::Initialize->new($args);
ok(defined $init,
    "Parrot::Configure::Initialize returned defined value");
isa_ok($init, "Parrot::Configure::Initialize");
ok($init->init_install(), 'init_install() completed okay');

is( $init->{prefix},         qq{/usr/local},
    "--prefix option confirmed" );
is( $init->{exec_prefix},    qq{/usr/local},
    "--exec-prefix option confirmed" );
is( $init->{bindir},         qq{/usr/local/bin},
    "--bindir option confirmed" );
is( $init->{sbindir},        qq{/usr/local/sbin},
    "--sbindir option confirmed" );
is( $init->{libexecdir},     qq{/usr/local/libexec},
    "--libexecdir option confirmed" );
is( $init->{datadir},        qq{/usr/local/share},
    "--datadir option confirmed" );
is( $init->{doc_dir},        qq{/usr/local/share/doc/parrot},
    "--doc_dir option confirmed" );
is( $init->{sysconfdir},     qq{/usr/local/etc},
    "--sysconfdir option confirmed" );
is( $init->{sharedstatedir}, qq{/usr/local/com},
    "--sharedstatedir option confirmed" );
is( $init->{localstatedir},  qq{/usr/local/var},
    "--localstatedir option confirmed" );
is( $init->{libdir},         qq{/usr/local/lib},
    "--libdir option confirmed" );
is( $init->{includedir},     qq{/usr/local/include},
    "--includedir option confirmed" );
is( $init->{oldincludedir},  qq{/usr/include},
    "--oldincludedir option confirmed" );
is( $init->{infodir},        qq{/usr/local/info},
    "--infodir option confirmed" );
is( $init->{mandir},         qq{/usr/local/man},
    "--mandir option confirmed" );

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

064-initialize.t - Test Parrot::Configure::Initialize

=head1 SYNOPSIS

    % prove t/configure/064-initialize.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test Parrot::Configure::Initialize::Install in the
case where no command-line options have been provided.

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


