#! perl
# Copyright (C) 2006, The Perl Foundation.
# $Id: 02-usage.t 16894 2007-02-04 22:54:29Z jkeenan $
# 02-usage.t

use strict;
use warnings;
BEGIN {
    use FindBin qw($Bin);
    use Cwd qw(cwd realpath);
    realpath($Bin) =~ m{^(.*\/parrot)\/[^/]*\/[^/]*\/[^/]*$};
    our $topdir = $1;
    if (defined $topdir) {
        print "\nOK:  Parrot top directory located\n";
    } else {
        $topdir = realpath($Bin) . "/../../..";
    }
    unshift @INC, qq{$topdir/lib};
}
use Test::More tests =>  30;
use Carp;
use Cwd;
use lib ("$main::topdir/t/tools/ops2cutils/testlib");
use_ok( "Capture" );

use_ok( 'Parrot::Ops2c::Auxiliary', qw| Usage getoptions | );

ok(chdir $main::topdir, "Positioned at top-level Parrot directory");
my $cwd = cwd();
my ($msg, $tie, @lines);
{
    $tie = tie *STDERR, "Capture" or croak "Unable to tie";
    my $rv = Usage();
    $msg = $tie->READLINE;
    untie *STDERR or croak "Unable to untie";
    is($rv, 1, "Usage() returned");
    like($msg,
        qr|^
            \s*%\sperl\stools\/build\/ops2c\.pl\strans.*
            trans\s:=.*
            For\sexample.*
            core.*
            dynamic.*
            |msx,
        "Got expected usage message");
}

{
    local @ARGV = qw( --no-lines );
    my $flagsref = getoptions();
    ok($flagsref->{nolines}, "no-lines option detected");
    ok(! defined $flagsref->{help}, "help option not defined");
    ok(! defined $flagsref->{dynamic}, "dynamic option not defined");
    ok(! defined $flagsref->{core}, "core option not defined");
}

{
    local @ARGV = ();
    my $flagsref = getoptions();
    ok(! defined $flagsref->{nolines}, "no-lines option not defined");
    ok(! defined $flagsref->{help}, "help option not defined");
    ok(! defined $flagsref->{dynamic}, "dynamic option not defined");
    ok(! defined $flagsref->{core}, "core option not defined");
}

{
    local @ARGV = qw( --no-lines --help --core );
    my $flagsref = getoptions();
    ok($flagsref->{nolines}, "no-lines option detected");
    ok($flagsref->{help}, "help option detected");
    ok(! defined $flagsref->{dynamic}, "dynamic option not defined");
    ok($flagsref->{core}, "core option detected");
}

{
    local @ARGV = qw( --dynamic );
    my $flagsref = getoptions();
    ok(! defined $flagsref->{nolines}, "no-lines option not defined");
    ok(! defined $flagsref->{help}, "help option not defined");
    ok(defined $flagsref->{dynamic}, "dynamic option defined");
    ok(! defined $flagsref->{core}, "core option not defined");
}

{
    local @ARGV = qw( --d );
    my $flagsref = getoptions();
    ok(! defined $flagsref->{nolines}, "no-lines option not defined");
    ok(! defined $flagsref->{help}, "help option not defined");
    ok(defined $flagsref->{dynamic}, "dynamic option defined");
    ok(! defined $flagsref->{core}, "core option not defined");
}

{
    local @ARGV = qw( --no-lines --help --core --d );
    my $flagsref = getoptions();
    ok($flagsref->{nolines}, "no-lines option detected");
    ok($flagsref->{help}, "help option detected");
    ok(defined $flagsref->{dynamic}, "dynamic option defined");
    ok($flagsref->{core}, "core option detected");
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

02-usage.t - test C<Parrot::Ops2c::Auxiliary::Usage()> and <getoptions()>

=head1 SYNOPSIS

    % prove t/tools/ops2cutils/02-usage.t

=head1 DESCRIPTION

The files in this directory test the publicly callable subroutines of 
F<lib/Parrot/Ops2c/Utils.pm> and F<lib/Parrot/Ops2c/Auxiliary.pm>.   
By doing so, they test the functionality of the F<ops2c.pl> utility.  
That functionality has largely been extracted 
into the methods of F<Utils.pm>.

F<02-usage.t> tests whether C<Parrot::Ops2c::Auxiliary::Usage()> 
and F<getoptions()> work properly.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Ops2c::Auxiliary, F<ops2c.pl>.

=cut
