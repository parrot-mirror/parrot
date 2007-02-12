# Copyright (C) 2006, The Perl Foundation.
# $Id: GenerateCore.pm 16816 2007-01-27 06:16:23Z jkeenan $
package GenerateCore;
use strict;
our (@ISA, @EXPORT_OK);
@ISA = qw(Exporter);
@EXPORT_OK = qw(
    generate_core
);
use Carp;
use File::Copy;
use lib ( "./lib" );
use Parrot::Ops2pm::Utils;

my @srcopsfiles = qw( src/ops/core.ops src/ops/bit.ops src/ops/cmp.ops
src/ops/debug.ops src/ops/experimental.ops src/ops/io.ops src/ops/math.ops
src/ops/object.ops src/ops/pic.ops src/ops/pmc.ops src/ops/set.ops
src/ops/stack.ops src/ops/stm.ops src/ops/string.ops src/ops/sys.ops
src/ops/var.ops );
my $num = "src/ops/ops.num";
my $skip = "src/ops/ops.skip";

sub generate_core {
    my ($cwd, $tdir, $srcopsref, $num_file, $skip_file) = @_;
    my @srcopsfiles = @$srcopsref;
    mkdir qq{$tdir/src};
    mkdir qq{$tdir/src/ops};
    mkdir qq{$tdir/src/dynoplibs};

    foreach my $f (@srcopsfiles) {
        copy(qq{$cwd/$f}, qq{$tdir/$f});
    }
    copy(qq{$cwd/$num}, qq{$tdir/$num});
    copy(qq{$cwd/$skip}, qq{$tdir/$skip});
    my @opsfiles = glob("./src/ops/*.ops");
    
    mkdir qq{$tdir/lib};
    mkdir qq{$tdir/lib/Parrot};
    mkdir qq{$tdir/lib/Parrot/Ops2c};
    mkdir qq{$tdir/include};
    mkdir qq{$tdir/include/parrot};
    mkdir qq{$tdir/include/parrot/oplib};
    
    my $o2p = Parrot::Ops2pm::Utils->new( {
        argv            => [ @opsfiles ],
        script          => "tools/build/ops2pm.pl",
        moddir          => "lib/Parrot/OpLib",
        module          => "core.pm",
    } );
    
    $o2p->prepare_ops();
    $o2p->load_op_map_files();
    $o2p->sort_ops();
    $o2p->prepare_real_ops();
    $o2p->print_module();

    croak "Temporary core.pm file not written"
        unless (-f qq|$tdir/$o2p->{moddir}/$o2p->{module}|);
    return qq{$tdir/lib};
}

1;
