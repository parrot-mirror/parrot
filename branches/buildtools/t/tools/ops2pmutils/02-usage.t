#! perl
# Copyright (C) 2006, The Perl Foundation.
# $Id$
# 02-usage.t

package Capture;
# Adapted from IO::Capture::Tie_STDx.
# Thanks as always to Mark Reynolds and Jon Morgan!

sub TIEHANDLE {
    my $class = shift;
    bless [], $class;
}

sub PRINT {
     my $self = shift;
     push @$self, join '',@_;
}

sub READLINE {
    my $self = shift;
    return wantarray ? @$self : shift @$self;
}

package main;

BEGIN {
    use FindBin qw($Bin);
    use Cwd qw(cwd realpath);
    realpath($Bin) =~ m{^(.*\/parrot)\/[^/]*\/[^/]*\/[^/]*$};
    $topdir = $1;
    if (defined $topdir) {
        print "\nOK:  Parrot top directory located\n";
    } else {
        $topdir = realpath($Bin) . "/../../..";
    }
    unshift @INC, qq{$topdir/lib};
}
use strict;
use warnings;
use Test::More tests =>  4;
use Carp;

use_ok( 'Parrot::Ops2pm::Auxiliary', qw| Usage | );

ok(chdir $main::topdir, "Positioned at top-level Parrot directory");
my $msg;
my $tie = tie *STDERR, "Capture" or croak "Unable to tie";
Usage();
$msg = $tie->READLINE;
untie *STDERR or croak "Unable to untie";
like($msg,
    qr|^usage: tools/build/ops2pm\.pl \[--help\] \[--no-lines\] input\.ops \[input2\.ops \.\.\.\]|,
    "Got expected usage message");

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

02-usage.t - test C<Parrot::Ops2pm::Utils::Usage()>

=head1 SYNOPSIS

    % prove t/tools/ops2pmutils/02-usage.t

=head1 DESCRIPTION

The files in this directory test the publicly callable subroutines of 
F<lib/Parrot/Ops2pm/Utils.pm>.  By doing so, they test the functionality 
of the F<ops2pm.pl> utility.  That functionality has largely been extracted 
into the methods of F<Utils.pm>.

F<02-usage.t> tests whether C<Parrot::Ops2pm::Utils::Usage()> works properly.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Ops2pm::Utils, F<ops2pm.pl>.

=cut

