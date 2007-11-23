#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 065-init_hints-04.t

use strict;
use warnings;

use Test::More tests =>  6;
use Carp;
use lib qw( lib t/configure/testlib );
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Initialize;
use Parrot::IO::Capture::Mini;

my $cwd = cwd();
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

{
    local $^O = q{imaginaryOS};
    my $ret;
    eval { $ret = $init->init_hints(); };
    like(
        $@,
        qr{^Can't locate Parrot/Configure/Initialize/Hints/$^O}i, #'
        "Got expected error message upon bad value for \$^O"
    );
}
pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

065-init_hints-04.t - Test Parrot::Configure::Initialize

=head1 SYNOPSIS

    % prove t/configure/065-init_hints-04.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test configuration initialization as conducted by
Parrot::Configure::Initialize::Hints.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure, Parrot::Configure::Initialize,
Parrot::Configure::Initialize::Hints, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:


