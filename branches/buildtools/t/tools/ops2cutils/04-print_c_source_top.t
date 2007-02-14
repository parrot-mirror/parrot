#! perl
# Copyright (C) 2006, The Perl Foundation.
# $Id: 04-print_c_source_top.t 16962 2007-02-13 03:38:24Z jkeenan $
# 04-print_c_source_top.t

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
use Test::More qw(no_plan); # tests =>  26;
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
        local @ARGV = qw( C CGoto CGP CSwitch CPrederef );
        my $self = Parrot::Ops2c::Utils->new( {
            argv            => [ @ARGV ],
            flag            => { core => 1 },
        } );
        ok(defined $self, 
            "Constructor correctly returned when provided >= 1 arguments");

        my $c_header_file = $self->print_c_header_file();
        ok(-e $c_header_file, "$c_header_file created");
        ok(-s $c_header_file, "$c_header_file has non-zero size");

        my ($SOURCE, $op_func_table_ref, $bs, $index) =
            $self->print_c_source_top();
        is(ref($SOURCE), q{GLOB}, "Argument type is filehandle (typeglob)");
        is(ref($op_func_table_ref), q{ARRAY}, "Array reference noted");
        is($bs, q{core_}, "'core_' identified");
        like($index, qr/^\d+$/, "\$index is numeric");
    }

    ok(chdir($cwd), "returned to starting directory");
}


pass("Completed all tests in $0");

sub test_single_trans_and_header {
    my $trans = shift;
    my %available = map {$_, 1} qw( C CGoto CGP CSwitch CPrederef );
    croak "Bad argument $trans to test_single_trans()"
        unless $available{$trans};

    my $self = Parrot::Ops2c::Utils->new( {
            argv            => [ $trans ],
            flag            => { core => 1 },
        } );
    ok(defined $self, 
        "Constructor correct when provided with single argument $trans");
    my $c_header_file = $self->print_c_header_file();
    ok(-e $c_header_file, "$c_header_file created");
    ok(-s $c_header_file, "$c_header_file has non-zero size");
}

################### DOCUMENTATION ###################

=head1 NAME

04-print_c_source_top.t - test C<Parrot::Ops2c::Utils::new()>

=head1 SYNOPSIS

    % prove t/tools/ops2cutils/04-print_c_source_top.t

=head1 DESCRIPTION

The files in this directory test the publicly callable subroutines of 
F<lib/Parrot/Ops2c/Utils.pm> and F<lib/Parrot/Ops2c/Auxiliary.pm>.   
By doing so, they test the functionality of the F<ops2c.pl> utility.  
That functionality has largely been extracted 
into the methods of F<Utils.pm>.

F<04-print_c_source_top.t> tests whether 
C<Parrot::Ops2c::Utils::print_c_source_top()> work properly.

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
