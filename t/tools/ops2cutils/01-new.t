#! perl
# Copyright (C) 2006, The Perl Foundation.
# $Id: 01-new.t 16894 2007-02-04 22:54:29Z jkeenan $
# 01-new.t

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
use Test::More qw(no_plan); # tests =>  30;
use Carp;
use Cwd;
use_ok( 'Parrot::Ops2c::Utils' );
use lib ("$main::topdir/t/tools/ops2cutils/testlib");
use_ok( "Capture" );


ok(chdir $main::topdir, "Positioned at top-level Parrot directory");
my $cwd = cwd();
my ($msg, $tie);

{
    local @ARGV = qw();
    $tie = tie *STDERR, "Capture" or croak "Unable to tie";
    my $self = Parrot::Ops2c::Utils->new( {
        argv            => [ @ARGV ],
        flag            => {},
    } );
    $msg = $tie->READLINE;
    untie *STDERR or croak "Unable to untie";
    ok(! defined $self, 
        "Constructor correctly returned undef due to lack of command-line arguments");
    like($msg,
        qr/^Parrot::Ops2c::Utils::new\(\) requires 'trans' options/,
        "Error message is correct");
}

{
    local @ARGV = qw( gobbledygook );
    $tie = tie *STDERR, "Capture" or croak "Unable to tie";
    my $self = Parrot::Ops2c::Utils->new( {
        argv            => [ @ARGV ],
        flag            => {},
    } );
    $msg = $tie->READLINE;
    untie *STDERR or croak "Unable to untie";
    ok(! defined $self, 
        "Constructor correctly returned undef due to bad class name command-line argument");
    like($msg,
        qr/Parrot::Ops2c::Utils::new\(\) requires C, CGoto, CGP, CSwitch and\/or  CPrederef/,
        "Got correct error message");
}

{
    local @ARGV = qw( C );
    my $self = Parrot::Ops2c::Utils->new( {
        argv            => [ @ARGV ],
        flag            => {},
    } );
    ok(defined $self, 
        "Constructor correctly returned when provided 1 argument");
}

{
    local @ARGV = qw( C );
    $tie = tie *STDERR, "Capture" or croak "Unable to tie";
    my $self = Parrot::Ops2c::Utils->new( {
        argv            => [ @ARGV ],
    } );
    $msg = $tie->READLINE;
    untie *STDERR or croak "Unable to untie";
    ok(! defined $self, 
        "Constructor correctly returned undef when lacking reference to options");
    like($msg,
        qr/^Parrot::Ops2c::Utils::new\(\) requires reference to hash of command-line options/,
        "Error message correctly returned");
}

{
    local @ARGV = qw( C CGoto CGP CSwitch CPrederef);
    my $self = Parrot::Ops2c::Utils->new( {
        argv            => [ @ARGV ],
        flag            => {},
    } );
    ok(defined $self, 
        "Constructor correctly returned when provided >= 1 arguments");
}

#$VAR1 = [];
#$VAR2 = bless( {
#                 'split_count' => 0
#               }, 'Parrot::OpTrans::CSwitch' );
#$VAR3 = '_switch';
#/usr/local/bin/perl tools/build/vtable_extend.pl
#/usr/local/bin/perl tools/build/ops2c.pl CGoto --core
#$VAR1 = [];
#$VAR2 = bless( {}, 'Parrot::OpTrans::CGoto' );
#$VAR3 = '_cg';
#/usr/local/bin/perl tools/build/ops2c.pl CGP --core
#$VAR1 = [];
#$VAR2 = bless( {}, 'Parrot::OpTrans::CGP' );
#$VAR3 = '_cgp';

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

01-new.t - test C<Parrot::Ops2c::Utils::new()>

=head1 SYNOPSIS

    % prove t/tools/ops2cutils/01-new.t

=head1 DESCRIPTION

The files in this directory test the publicly callable subroutines of 
F<lib/Parrot/Ops2c/Utils.pm> and F<lib/Parrot/Ops2c/Auxiliary.pm>.   
By doing so, they test the functionality of the F<ops2c.pl> utility.  
That functionality has largely been extracted 
into the methods of F<Utils.pm>.

F<01-new.t> tests whether C<Parrot::Ops2c::Auxiliary::Usage()> 
and F<getoptions()> work properly.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Ops2c::Auxiliary, F<ops2c.pl>.

=cut

