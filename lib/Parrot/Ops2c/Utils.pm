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

    $self->_print_preamble_header($HEADER);

    $self->_print_run_core_func_decl_header($HEADER);

    $self->_print_coda($HEADER);

    close $HEADER or die "Unable to close handle to $self->{header}: $!";
    (-e $self->{header}) or die "$self->{header} not created: $!";
    (-s $self->{header}) or die "$self->{header} has 0 size: $!";
    return $self->{header};
}

sub _print_preamble_header {
    my ($self, $fh) = @_;

    print $fh $self->{preamble};
    if ($self->{flag}->{dynamic}) {
        print $fh "#define PARROT_IN_EXTENSION\n";
    }
    print $fh <<END_C;
#include "parrot/parrot.h"
#include "parrot/oplib.h"

$self->{sym_export} extern op_lib_t *$self->{init_func}(long init);

END_C
}

sub _print_run_core_func_decl_header {
    my ($self, $fh) = @_;
    if ( $self->{trans}->can("run_core_func_decl") ) {
        my $run_core_func = 
            $self->{trans}->run_core_func_decl($self->{base});
        print $fh "$run_core_func;\n";
    } else {
        return;
    }
}

sub _print_coda {
    my ($self, $fh) = @_;
    print $fh <<END_C;

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
END_C
}

sub print_c_source_top {
    my $self = shift;
    $self->{defines} = $self->{trans}->defines();    # Invoked as:  ${defines}
    $self->{bs} = "$self->{base}$self->{suffix}_";   # Also invoked as ${bs}
    $self->{opsarraytype} = $self->{trans}->opsarraytype();

    ##### BEGIN printing to $SOURCE #####
    open my $SOURCE, '>', $self->{source}
        or die "ops2c.pl: Cannot open source file '$self->{source}' for writing: $!!\n";

    $self->_print_preamble_source($SOURCE);

    $self->_print_ops_addr_decl($SOURCE);

    $self->_print_run_core_func_decl_source($SOURCE);

    # Iterate over the ops, appending HEADER and SOURCE fragments:
    $self->_iterate_over_ops();

    $self->_print_cg_jump_table($SOURCE);

    $self->_print_goto_opcode($SOURCE);

    $self->_print_op_function_definitions($SOURCE);

    return $SOURCE;
}

###################

sub _print_preamble_source {
    my ($self, $fh) = @_;

    print $fh $self->{preamble};
    print $fh <<END_C;
#include "$self->{include}"

$self->{defines}
static op_lib_t $self->{bs}op_lib;

END_C

    my $text = $self->{ops}->preamble($self->{trans});
    $text =~ s/\bops_addr\b/$self->{bs}ops_addr/g;
    print $fh $text;
}

sub _print_ops_addr_decl {
    my ($self, $fh) = @_;
    if ( $self->{trans}->can("ops_addr_decl") ) {
        print $fh $self->{trans}->ops_addr_decl($self->{bs});
    } else {
        return;
    }
}

sub _print_run_core_func_decl_source {
    my ($self, $fh) = @_;
    if ( $self->{trans}->can("run_core_func_decl") ) {
        print $fh $self->{trans}->run_core_func_decl($self->{base});
        print $fh "\n{\n";
        print $fh $self->{trans}->run_core_func_start;
    } else {
        return;
    }
}

sub _iterate_over_ops {
    my $self = shift;
    my @op_funcs;
    my @op_func_table;
    my @cg_jump_table;
    my $index = 0;
    my ( $prev_src, $prev_index );

    $prev_src = '';
    foreach my $op ( $self->{ops}->ops ) {
        my $func_name = $op->func_name($self->{trans});
        my $arg_types = "$self->{opsarraytype} *, Interp *";
        my $prototype = "$self->{sym_export} $self->{opsarraytype} * $func_name ($arg_types)";
        my $args      = "$self->{opsarraytype} *cur_opcode, Interp *interp";
        my $definition;
        my $comment = '';
        my $one_op  = "";

        if ( $self->{suffix} =~ /cg/ ) {
            $definition = "PC_$index:";
            $comment    = "/* " . $op->full_name() . " */";
        }
        elsif ( $self->{suffix} =~ /switch/ ) {
            $definition = "case $index:";
            $comment    = "/* " . $op->full_name() . " */";
        }
        else {
            $definition = "$prototype;\n$self->{opsarraytype} *\n$func_name ($args)";
        }

        my $src = $op->source($self->{trans});
        $src =~ s/\bop_lib\b/$self->{bs}op_lib/g;
        $src =~ s/\bops_addr\b/$self->{bs}ops_addr/g;

        if ( $self->{suffix} =~ /cg/ ) {
            if ( $prev_src eq $src ) {
                push @cg_jump_table, "        &&PC_$prev_index,\n";
            }
            else {
                push @cg_jump_table, "        &&PC_$index,\n";
            }
        }
        elsif ( $self->{suffix} eq '' ) {
            push @op_func_table, sprintf( "  %-50s /* %6ld */\n", "$func_name,", $index );
        }
        if ( $prev_src eq $src ) {
            push @op_funcs, "$comment\n";
        }
        else {
            $one_op .= "$definition $comment {\n$src}\n\n";
            push @op_funcs, $one_op;
            $prev_src = $src if ( $self->{suffix} eq '_cgp' || $self->{suffix} eq '_switch' );
            $prev_index = $index;
        }
        $index++;
    }
    $self->{index} =  $index;
    $self->{op_funcs} = \@op_funcs;
    $self->{op_func_table} = \@op_func_table;
    $self->{cg_jump_table} = \@cg_jump_table;
}

sub _print_cg_jump_table {
    my ($self, $fh) = @_;
    my @cg_jump_table = @{$self->{cg_jump_table}};

    if ( $self->{suffix} =~ /cg/ ) {
        print $fh @cg_jump_table;
        print $fh <<END_C;
        NULL
    };
END_C
        print $fh $self->{trans}->run_core_after_addr_table($self->{bs});
    }
}

sub _print_goto_opcode {
    my ($self, $fh) = @_;

    if ( $self->{suffix} =~ /cgp/ ) {
        print $fh <<END_C;
#ifdef __GNUC__
# ifdef I386
    else if (cur_opcode == (void **) 1)
    asm ("jmp *4(%ebp)");  /* jump to ret addr, used by JIT */
# endif
#endif
    _reg_base = (char*)interp->ctx.bp.regs_i;
    goto **cur_opcode;

END_C
    }
    elsif ( $self->{suffix} =~ /cg/ ) {
        print $fh <<END_C;
goto *$self->{bs}ops_addr[*cur_opcode];

END_C
    }
    return 1;
}

sub _print_op_function_definitions {
    my ($self, $fh) = @_;
    my @op_funcs = @{$self->{op_funcs}};
    print $fh <<END_C;
/*
** Op Function Definitions:
*/

END_C

    # Finish the SOURCE file's array initializer:
    my $CORE_SPLIT = 300;
    for ( my $i = 0 ; $i < @op_funcs ; $i++ ) {
        if ( $i && 
            $i % $CORE_SPLIT == 0 && 
            $self->{trans}->can("run_core_split") )
        {
            print $fh $self->{trans}->run_core_split($self->{base});
        }
        print $fh $op_funcs[$i];
    }

    if ( $self->{trans}->can("run_core_finish") ) {
        print $fh $self->{trans}->run_core_finish($self->{base});
    }
    close($fh) || die "Unable to close after writing: $!";
}

1;
