#! perl
# Copyright (C) 2007-2008, The Perl Foundation.
# $Id$
# 05-renum_op_map_file.t

use strict;
use warnings;

#        my $tdir = tempdir( CLEANUP => 1 );

use Test::More qw( no_plan );
use Carp;
use Cwd;
use File::Temp (qw| tempdir |);
#use Data::Dumper;$Data::Dumper::Indent=1;
use File::Basename;
use File::Copy;
use Tie::File;
use lib '/home/jimk/work/opsrenum/lib';
use Parrot::OpsRenumber;

my ($self, @opsfiles);
my ($lastcode, $lastnumber);
my $numoutput = q{src/ops/ops.num};

##### Stage 1:  Generate ops.num de novo #####

my @stage1 = qw(
    src/ops/core.ops.orig
    src/ops/bit.ops.orig
    src/ops/ops.num.orig
);

copy_into_position(\@stage1, q{orig});
($lastcode, $lastnumber) = run_test_stage(
    [ qw(
        src/ops/core.ops
        src/ops/bit.ops
    ) ],
    $numoutput,
);
is($lastcode, q{bxors_s_sc_sc},
    "Stage 1:  Got expected last opcode");
is($lastnumber, 190,
    "Stage 1:  Got expected last opcode number");

##### Stage 2:  Delete some opcodes and regenerate ops.num #####

my @stage2 = qw( src/ops/bit.ops.second );
copy_into_position(\@stage2, q{second});
($lastcode, $lastnumber) = run_test_stage(
    [ qw(
        src/ops/core.ops
        src/ops/bit.ops
    ) ],
    $numoutput,
);

($lastcode, $lastnumber) = get_last_opcode($numoutput);
is($lastcode, q{bxor_i_ic_ic},
    "Stage 2:  Got expected last opcode");
is($lastnumber, 184,
    "Stage 2:  Got expected last opcode number");

##### Stage 3:  Add some opcodes and regenerate ops.num #####

my @stage3 = qw( src/ops/pic.ops.orig );
copy_into_position(\@stage3, q{orig});
($lastcode, $lastnumber) = run_test_stage(
    [ qw(
        src/ops/core.ops
        src/ops/bit.ops
        src/ops/pic.ops
    ) ],
    $numoutput,
);

($lastcode, $lastnumber) = get_last_opcode($numoutput);
is($lastcode, q{pic_callr___pc},
    "Stage 3:  Got expected last opcode");
is($lastnumber, 189,
    "Stage 3:  Got expected last opcode number");

pass("Completed all tests in $0");

#################### SUBROUTINES ####################

sub run_test_stage {
    my ($opsfilesref, $numoutput) = @_;
    my $self = Parrot::OpsRenumber->new(
        {
            argv    => $opsfilesref,
            moddir  => "lib/Parrot/OpLib",
            module  => "core.pm",
            inc_dir => "include/parrot/oplib",
            inc_f   => "ops.h",
            script  => "tools/dev/opsrenumber.pl",
        }
    );
    
    $self->prepare_ops();
    $self->renum_op_map_file();
    my ($lastcode, $lastnumber) = get_last_opcode($numoutput);
    return ($lastcode, $lastnumber);
}

sub copy_into_position {
    my ($stageref, $ext) = @_;
    foreach my $or ( @{ $stageref } ) {
        my $base = basename($or);
        my $real;
        ($real = $base) =~ s/\.$ext$//;
        my $fullreal = qq{src/ops/$real};
        copy $or, $fullreal or croak "Unable to copy $base";
    }
}

sub get_last_opcode {
    my $file = shift;
    croak "$file not found: $!" unless -f $file;
    my (@lines, $lastline);
    tie @lines, 'Tie::File', $file or croak "Unable to tie to $file: $!";
    $lastline = $lines[-1];
    untie @lines or croak "Unable to untie from $file: $!";
    my ($lastcode, $lastnumber) = split /\s+/, $lastline, 2;
    croak "Couldn't parse last line of $file: $!"
        unless (defined $lastcode and defined $lastnumber);
    return ($lastcode, $lastnumber);
}

