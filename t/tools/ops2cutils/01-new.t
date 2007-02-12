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
use File::Copy;
use File::Temp (qw| tempdir |);
use_ok( 'Parrot::Ops2pm::Utils' );
use lib ("$main::topdir/t/tools/ops2cutils/testlib");
use_ok( "Capture" );
use_ok( "GenerateCore", qw| generate_core | );

my @srcopsfiles = qw( src/ops/core.ops src/ops/bit.ops src/ops/cmp.ops
src/ops/debug.ops src/ops/experimental.ops src/ops/io.ops src/ops/math.ops
src/ops/object.ops src/ops/pic.ops src/ops/pmc.ops src/ops/set.ops
src/ops/stack.ops src/ops/stm.ops src/ops/string.ops src/ops/sys.ops
src/ops/var.ops );
my $num = "src/ops/ops.num";
my $skip = "src/ops/ops.skip";

ok(chdir $main::topdir, "Positioned at top-level Parrot directory");
my $cwd = cwd();
my ($msg, $tie);

{
    my $tdir = tempdir( CLEANUP => 1 );
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $tlib = generate_core(
        $cwd, $tdir, \@srcopsfiles, $num, $skip);

    ok(-d $tlib, "lib directory created under tempdir");
    unshift @INC, $tlib;
    require Parrot::Ops2c::Utils;

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
            flag            => { core => 1 },
        } );
        ok(defined $self, 
            "Constructor correctly returned when provided 1 argument");
    }
    
    {
        local @ARGV = qw( C CGoto CGP CSwitch CPrederef);
        my $self = Parrot::Ops2c::Utils->new( {
            argv            => [ @ARGV ],
            flag            => { core => 1 },
        } );
        ok(defined $self, 
            "Constructor correctly returned when provided >= 1 arguments");
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
    
    ok(chdir($cwd), "returned to starting directory");
}


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

__END__

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
