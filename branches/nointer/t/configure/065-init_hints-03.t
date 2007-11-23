#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 065-init_hints-03.t

use strict;
use warnings;

use Test::More tests =>  7;
use Carp;
use Cwd;
use File::Path ();
use File::Temp qw(tempdir);
use lib qw( lib t/configure/testlib );
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Initialize;
use Parrot::IO::Capture::Mini;

my $cwd = cwd();
my $args  = process_options(
    {
        argv => [q{--verbose}],
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
    my $tdir = tempdir( CLEANUP => 1 );
    File::Path::mkpath(qq{$tdir/Parrot/Configure/Initialize/Hints})
        or croak "Unable to create directory for local hints";
    my $localhints = qq{$tdir/Parrot/Configure/Initialize/Hints/local.pm};
    open my $FH, '>', $localhints
        or croak "Unable to open temp file for writing";
    print $FH <<END;
package Parrot::Configure::Initialize::Hints::local;
use strict;
1;
END
    close $FH or croak "Unable to close temp file after writing";
    unshift( @INC, $tdir );

    # need to capture the --verbose output,
    # because the fact that it does not end
    # in a newline confuses Test::Harness
    {
        my $tie_out = tie *STDOUT, "Parrot::IO::Capture::Mini"
            or croak "Unable to tie";
        my $ret = $init->init_hints();
        my @lines = $tie_out->READLINE;
        ok( @lines, "verbose output:  hints were captured" );
        ok( $ret, "init_hints() returned true value" );
    }
    unlink $localhints or croak "Unable to delete $localhints";
}
untie *STDOUT;
pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

065-init_hints-03.t - Test Parrot::Configure::Initialize

=head1 SYNOPSIS

    % prove t/configure/065-init_hints-03.t

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


