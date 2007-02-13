# Copyright (C) 2004-2006, The Perl Foundation.
# $Id$
package Parrot::Ops2c::Utils;
use strict;
use lib ("lib/");
use Parrot::OpLib::core;
use Parrot::OpsFile;

sub new {
    my ($class, $argsref) = @_;
    unless (defined $argsref->{flag}) {
        print STDERR "Parrot::Ops2c::Utils::new() requires reference to hash of command-line options: $!";
        return;
    }
    my $flagref = $argsref->{flag};
    my @argv = @{$argsref->{argv}};
    $argsref->{script} ||= "tools/build/ops2c.pl";
    unless (@argv) {
        print STDERR "Parrot::Ops2c::Utils::new() requires 'trans' options: $!";
        return;
    };
    my $class_name = shift @argv;
    my %is_allowed = map { $_ => 1 } qw(C CGoto CGP CSwitch CPrederef);
    unless ($is_allowed{$class_name}) {
        print STDERR "Parrot::Ops2c::Utils::new() requires C, CGoto, CGP, CSwitch and/or  CPrederef: $!";
        return;
    };

    my $trans_class = "Parrot::OpTrans::" . $class_name;
    eval "require $trans_class";
    my $trans   = $trans_class->new();
    # Don't yet know how to test the following.
    unless (defined $trans) {
        print STDERR "Unable to construct $trans object: $!";
        return;
    };

    my $suffix  = $trans->suffix();     # Invoked (sometimes) as ${suffix}

    my $file = $flagref->{core} ? 'core.ops' : shift @argv;
    my $base = $file;   # Invoked (sometimes) as ${base}
    $base =~ s/\.ops$//;
    my $base_ops_stub = $base . q{_ops} . $suffix;
    my $base_ops_h    = $base_ops_stub . q{.h};

    my $incdir  = "include/parrot/oplib";
    my $include = "parrot/oplib/$base_ops_h";
    my $header  = "include/$include";

    # SOURCE is closed and reread, which confuses make -j
    # create a temp file and rename it
    my $source = "src/ops/$base_ops_stub.c.temp";

    if ( $base =~ m!^src/dynoplibs/! || $flagref->{dynamic} ) {
        $source             =~ s!src/ops/!!;
        $header             = $base_ops_h;
        $base               =~ s!^.*[/\\]!!;
        $include            = $base_ops_h;
        $flagref->{dynamic} = 1;
    }

    my $sym_export = $flagref->{dynamic} 
        ? 'PARROT_DYNEXT_EXPORT'
        : 'PARROT_API';

    my $ops;
    if ($flagref->{core}) {
        $ops = _prepare_core( {
            file        => $file,
            flag        => $flagref,
        } );
    }
    else {
        $ops = _prepare_non_core( {
            file        => $file,
            argv        => [ @argv ],
            flag        => $flagref,
        } );
    }

    my %versions = (
        major => $ops->major_version,
        minor => $ops->minor_version,
        patch => $ops->patch_version,
    );
    my $num_ops       = scalar $ops->ops;
    my $num_entries   = $num_ops + 1;          # For trailing NULL

    if ( ! $flagref->{dynamic} && ! -d $incdir ) {
        mkdir( $incdir, 0755 )
            or die "ops2c.pl: Could not mkdir $incdir $!!\n";
    }

    my $preamble = _compose_preamble($file, $argsref->{script});

    my $init_func = join q{_}, (
        q{Parrot},
        q{DynOp},
        $base . $suffix,
        @versions{ qw(major minor patch) },
    );

###############################
    $argsref->{argv} = \@argv;
    $argsref->{trans} = $trans;
    $argsref->{suffix} = $suffix;

    $argsref->{file} = $file;
    $argsref->{base} = $base;
    $argsref->{incdir} = $incdir;
    $argsref->{include} = $include;
    $argsref->{header} = $header;
    $argsref->{source} = $source;
    $argsref->{sym_export} = $sym_export;

    $argsref->{ops} = $ops;
    $argsref->{versions} = \%versions;
    $argsref->{num_ops} = $num_ops;
    $argsref->{num_entries} = $num_entries;

    $argsref->{preamble} = $preamble;
    $argsref->{init_func} = $init_func;

    $argsref->{flag} = $flagref;
    return bless $argsref, $class;
}

sub _prepare_core {
    my $argsref = shift;
    my $ops = Parrot::OpsFile->new(
        [ qq|src/ops/$argsref->{file}| ],
        $argsref->{flag}->{nolines},
    );
    $ops->{OPS}      = $Parrot::OpLib::core::ops;
    $ops->{PREAMBLE} = $Parrot::OpLib::core::preamble;
    return $ops;
}

sub _prepare_non_core {
    my $argsref = shift;
    my %opsfiles;
    my @opsfiles;

    foreach my $f ( $argsref->{file}, @{$argsref->{argv}} ) {
        if ( $opsfiles{$f} ) {
            print STDERR "$argsref->{script}: Ops file '$f' mentioned more than once!\n";
            next;
        }

        $opsfiles{$f} = 1;
        push @opsfiles, $f;

        die "$argsref->{script}: Could not read ops file '$f'!\n" unless -r $f;
    }

    my $ops = Parrot::OpsFile->new( \@opsfiles, $argsref->{flag}->{nolines} );

    my $cur_code = 0;
    for my $el ( @{ $ops->{OPS} } ) {
        $el->{CODE} = $cur_code++;
    }
    return $ops;
}

sub _compose_preamble {
    my ($file, $script) = @_;
    my $preamble = <<END_C;
/* ex: set ro:
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically from '$file' (and possibly other
 * .ops files). by $script.
 *
 * Any changes made here will be lost!
 *
 */

END_C
    return $preamble;
}

sub print_c_header_file {
    my $self = shift;

    open my $HEADER, '>', $self->{header}
        or die "ops2c.pl: Cannot open header file '$self->{header}' for writing: $!!\n";

    _print_preamble_header( {
        fh          => $HEADER,
        preamble    => $self->{preamble},
        flag        => $self->{flag},
        sym_export  => $self->{sym_export},
        init_func   => $self->{init_func},
    } );

    _print_run_core_func_decl_header( {
        trans   => $self->{trans},
        fh      => $HEADER,
        base    => $self->{base},
    } );

    _print_coda($HEADER);

    close $HEADER or die "Unable to close handle to $self->{header}: $!";
    (-e $self->{header}) or die "$self->{header} not created: $!";
    (-s $self->{header}) or die "$self->{header} has 0 size: $!";
    return $self->{header};
}

sub _print_preamble_header {
    my $argsref = shift;
    my $fh = $argsref->{fh};

    print $fh $argsref->{preamble};
    if ($argsref->{flag}->{dynamic}) {
        print $fh "#define PARROT_IN_EXTENSION\n";
    }
    print $fh <<END_C;
#include "parrot/parrot.h"
#include "parrot/oplib.h"

$argsref->{sym_export} extern op_lib_t *$argsref->{init_func}(long init);

END_C
}

sub _print_run_core_func_decl_header {
    my $argsref = shift;
    if ( $argsref->{trans}->can("run_core_func_decl") ) {
        my $run_core_func = 
            $argsref->{trans}->run_core_func_decl($argsref->{base});
        my $fh = $argsref->{fh};
        print $fh "$run_core_func;\n";
    } else {
        return;
    }
}

sub _print_coda {
    my $fh = shift;
    print $fh <<END_C;

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
END_C
}

1;
