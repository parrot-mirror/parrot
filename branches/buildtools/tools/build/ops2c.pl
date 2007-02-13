#! perl
# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$
use warnings;
use strict;
use Data::Dumper;
use lib 'lib';
#use Parrot::OpsFile;
#use Parrot::OpLib::core;
use Parrot::Config;
use Parrot::Ops2c::Auxiliary qw( Usage getoptions );
use Parrot::Ops2c::Utils;

my $flagref = getoptions();
if (
        (not defined $flagref) or 
        $flagref->{help} or
        (not @ARGV)
    ) {
        Usage();
        exit 1;
}

my $self = Parrot::Ops2c::Utils->new( {
    argv    => [ @ARGV ],
    flag    => $flagref,
    script  => $0,
} );
if (not defined $self) {
    Usage();
    exit 1;
}
#########################
local @ARGV = @{$self->{argv}};
my $trans = $self->{trans};
my $suffix = $self->{suffix};

my $file    = $self->{file};
my $base    = $self->{base};
my $incdir    = $self->{incdir};
my $include    = $self->{include};
my $header    = $self->{header};
my $source    = $self->{source};
my $sym_export    = $self->{sym_export};

my $ops = $self->{ops};
my %versions = %{$self->{versions}};
my $num_ops = $self->{num_ops};
my $num_entries  = $self->{num_entries};

my $preamble = $self->{preamble};
my $init_func = $self->{init_func};

##### BEGIN printing to $HEADER #####
$self->print_c_header_file();
##### END printing to $HEADER #####

my $defines         = $trans->defines();    # Invoked as:  ${defines}
my $bs = "${base}${suffix}_";   # Also invoked as ${bs}
my $opsarraytype    = $trans->opsarraytype();

##### BEGIN printing to $SOURCE #####
open my $SOURCE, '>', $source
    or die "ops2c.pl: Cannot open source file '$source' for writing: $!!\n";

_print_preamble_source( {
    fh          => $SOURCE,
    preamble    => $preamble,
    include     => $include,
    defines     => $defines,
    bs          => $bs,
    ops         => $ops,
    trans       => $trans,
} );

_print_ops_addr_decl( {
    trans   => $trans,
    fh      => $SOURCE,
    bs      => $bs,
} );

_print_run_core_func_decl_source( {
    trans   => $trans,
    fh      => $SOURCE,
    base    => $base,
} );

# Iterate over the ops, appending HEADER and SOURCE fragments:
my $op_funcs_ref;
my $op_func_table_ref;
my $cg_jump_table_ref;
my $index;

($index, $op_funcs_ref, $op_func_table_ref, $cg_jump_table_ref) = 
    _iterate_over_ops( {
        ops             => $ops,
        trans           => $trans,
        opsarraytype    => $opsarraytype,
        suffix          => $suffix,
        bs              => $bs,
    } );

my @op_funcs        = @{$op_funcs_ref};
my @op_func_table   = @{$op_func_table_ref};
my @cg_jump_table   = @{$cg_jump_table_ref};

_print_cg_jump_table( {
    fh              => $SOURCE,
    cg_jump_table   => \@cg_jump_table,
    suffix          => $suffix,
    trans           => $trans,
    bs              => $bs,
} );

_print_goto_opcode( {
    fh      => $SOURCE,
    suffix  => $suffix,
    bs      => $bs,
} );

_print_op_function_definitions( {
    fh          => $SOURCE,
    op_funcs    => \@op_funcs,
    trans       => $trans,
    base        => $base,
} );
#######

# reset #line in the SOURCE file.
$SOURCE = _reset_line_number( {
    flag        => $flagref,
    fh          => $SOURCE,
    sourcefile  => $source,
} );

my ($op_info, $op_func, $getop) = _op_func_table( {
    suffix          => $suffix,
    bs              => $bs,
    num_ops         => $num_ops,
    num_entries     => $num_entries,
    op_func_table   => \@op_func_table,
    fh              => $SOURCE,
} );

my $namesref = {};
($namesref, $op_info, $index) = _op_info_table( {
    suffix      => $suffix,
    bs          => $bs,
    fh          => $SOURCE,
    op_info     => $op_info,
    num_entries => $num_entries,
    index       => $index,
    ops         => $ops,
    names       => $namesref,
} );

$getop = _op_lookup( {
    getop   => $getop,
    suffix  => $suffix,
    flag    => $flagref,
    index   => $index,
    names   => $namesref,
    fh      => $SOURCE,
    num_ops => $num_ops,
    bs      => $bs,
} );

_print_op_lib_descriptor( {
    fh              => $SOURCE,
    bs              => $bs,
    base            => $base,
    suffix          => $suffix,
    trans           => $trans,
    versions        => \%versions,
    num_ops         => $num_ops,
    op_info         => $op_info,
    op_func         => $op_func,
    getop           => $getop,
} );

_generate_init_func( {
    trans           => $trans,
    base            => $base,
    bs              => $bs,
    fh              => $SOURCE,
    init_func       => $init_func,
} );

_print_dynamic_lib_load( {
    flag            => $flagref,
    base            => $base,
    suffix          => $suffix,
    fh              => $SOURCE,
    sym_export      => $sym_export,
    init_func       => $init_func,
} );

_print_coda($SOURCE);

close $SOURCE or die "Unable to close handle to $source: $!";
##### END printing to $SOURCE #####

_rename_source($source);

exit 0;


#################### SUBROUTINES ####################

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

sub _print_preamble_source {
    my $argsref = shift;
    my $fh = $argsref->{fh};

    print $fh $argsref->{preamble};
    print $fh <<END_C;
#include "$argsref->{include}"

$argsref->{defines}
static op_lib_t $argsref->{bs}op_lib;

END_C

    my $text = $argsref->{ops}->preamble($argsref->{trans});
    $text =~ s/\bops_addr\b/${bs}ops_addr/g;
    print $fh $text;
}

sub _print_ops_addr_decl {
    my $argsref = shift;
    if ( $argsref->{trans}->can("ops_addr_decl") ) {
        my $fh = $argsref->{fh};
        print $fh $argsref->{trans}->ops_addr_decl($argsref->{bs});
    } else {
        return;
    }
}

sub _print_run_core_func_decl_source {
    my $argsref = shift;
    if ( $argsref->{trans}->can("run_core_func_decl") ) {
        my $fh = $argsref->{fh};
        print $fh $argsref->{trans}->run_core_func_decl($argsref->{base});
        print $fh "\n{\n";
        print $fh $argsref->{trans}->run_core_func_start;
    } else {
        return;
    }
}

sub _iterate_over_ops {
    my $argsref = shift;
    my @op_funcs;
    my @op_func_table;
    my @cg_jump_table;
    my $index = 0;
    my ( $prev_src, $prev_index );
    
    $prev_src = '';
    foreach my $op ( $argsref->{ops}->ops ) {
        my $func_name = $op->func_name($argsref->{trans});
        my $arg_types = "$argsref->{opsarraytype} *, Interp *";
        my $prototype = "$sym_export $argsref->{opsarraytype} * $func_name ($arg_types)";
        my $args      = "$argsref->{opsarraytype} *cur_opcode, Interp *interp";
        my $definition;
        my $comment = '';
        my $one_op  = "";
    
        if ( $argsref->{suffix} =~ /cg/ ) {
            $definition = "PC_$index:";
            $comment    = "/* " . $op->full_name() . " */";
        }
        elsif ( $argsref->{suffix} =~ /switch/ ) {
            $definition = "case $index:";
            $comment    = "/* " . $op->full_name() . " */";
        }
        else {
            $definition = "$prototype;\n$argsref->{opsarraytype} *\n$func_name ($args)";
        }
    
        my $src = $op->source($argsref->{trans});
        $src =~ s/\bop_lib\b/$argsref->{bs}op_lib/g;
        $src =~ s/\bops_addr\b/$argsref->{bs}ops_addr/g;
    
        if ( $argsref->{suffix} =~ /cg/ ) {
            if ( $prev_src eq $src ) {
                push @cg_jump_table, "        &&PC_$prev_index,\n";
            }
            else {
                push @cg_jump_table, "        &&PC_$index,\n";
            }
        }
        elsif ( $argsref->{suffix} eq '' ) {
            push @op_func_table, sprintf( "  %-50s /* %6ld */\n", "$func_name,", $index );
        }
        if ( $prev_src eq $src ) {
            push @op_funcs, "$comment\n";
        }
        else {
            $one_op .= "$definition $comment {\n$src}\n\n";
            push @op_funcs, $one_op;
            $prev_src = $src if ( $argsref->{suffix} eq '_cgp' || $argsref->{suffix} eq '_switch' );
            $prev_index = $index;
        }
        $index++;
    }
    return ($index, \@op_funcs, \@op_func_table, \@cg_jump_table);
}

sub _print_cg_jump_table {
    my $argsref = shift;
    my $fh = $argsref->{fh};
    my @cg_jump_table = @{$argsref->{cg_jump_table}};

    if ( $argsref->{suffix} =~ /cg/ ) {
        print $fh @cg_jump_table;
        print $fh <<END_C;
        NULL
    };
END_C
        print $fh $argsref->{trans}->run_core_after_addr_table($argsref->{bs});
    }
}

sub _print_goto_opcode {
    my $argsref = shift;
    my $fh = $argsref->{fh};

    if ( $argsref->{suffix} =~ /cgp/ ) {
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
    elsif ( $argsref->{suffix} =~ /cg/ ) {
        print $fh <<END_C;
goto *$argsref->{bs}ops_addr[*cur_opcode];

END_C
    }
    return 1;
}

sub _print_op_function_definitions {
    my $argsref = shift;
    my $fh = $argsref->{fh};
    my @op_funcs = @{$argsref->{op_funcs}};
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
            $argsref->{trans}->can("run_core_split") )
        {
            print $fh $argsref->{trans}->run_core_split($argsref->{base});
        }
        print $fh $op_funcs[$i];
    }
    
    if ( $trans->can("run_core_finish") ) {
        print $fh $trans->run_core_finish($base);
    }
    close($fh) || die "Unable to close after writing: $!";
}

sub _reset_line_number {
    my $argsref = shift;
    my $fh = $argsref->{fh};
    my $source = $argsref->{sourcefile};
    my $line = 0;
    open( $fh, '<', $source ) || die "Error re-reading $source: $!\n";
    while (<$fh>) { $line++; }
    $line += 2;
    close($fh) || die "Error closing $source:  $!";
    open( $fh, '>>', $source ) || die "Error appending to $source: $!\n";
    unless ($flagref->{nolines}) {
        my $source_escaped = $source;
        $source_escaped =~ s|\.temp||;
        $source_escaped =~ s|(\\)|$1$1|g;    # escape backslashes
        print $fh qq{#line $line "$source_escaped"\n};
    }
    return $fh;  # filehandle remains open
}

sub _op_func_table {
    my $argsref = shift;
    my $fh = $argsref->{fh};
    my ( $op_info, $op_func, $getop );
    $op_info = $op_func = 'NULL';
    $getop = '( int (*)(const char *, int) )NULL';
    
    if ( $argsref->{suffix} eq '' ) {
        $op_func = $argsref->{bs} . q{op_func_table};
        print $fh <<END_C;

INTVAL $argsref->{bs}numops$argsref->{suffix} = $argsref->{num_ops};

/*
** Op Function Table:
*/

static op_func$argsref->{suffix}_t ${op_func}\[$argsref->{num_entries}] = {
END_C

        print $fh @{$argsref->{op_func_table}};

        print $fh <<END_C;
  (op_func$argsref->{suffix}_t)0  /* NULL function pointer */
};


END_C
    }
    return ($op_info, $op_func, $getop);
}

sub _op_info_table {
    my $argsref = shift;
    my $fh = $argsref->{fh};
    my %names = %{$argsref->{names}};
    my %arg_dir_mapping = (
        ''   => 'PARROT_ARGDIR_IGNORED',
        'i'  => 'PARROT_ARGDIR_IN',
        'o'  => 'PARROT_ARGDIR_OUT',
        'io' => 'PARROT_ARGDIR_INOUT'
    );

    if ( $argsref->{suffix} eq '' ) {
        $argsref->{op_info} = "$argsref->{bs}op_info_table";
    
        #
        # Op Info Table:
        #
        print $fh <<END_C;

/*
** Op Info Table:
*/

static op_info_t $argsref->{op_info}\[$argsref->{num_entries}] = {
END_C

        $argsref->{index} = 0;
    
        foreach my $op ( $argsref->{ops}->ops ) {
            my $type = sprintf( "PARROT_%s_OP", uc $op->type );
            my $name = $op->name;
            $names{$name} = 1;
            my $full_name = $op->full_name;
            my $func_name = $op->func_name($trans);
            my $body      = $op->body;
            my $jump      = $op->jump || 0;
            my $arg_count = $op->size;
    
            ## 0 inserted if arrays are empty to prevent msvc compiler errors
            my $arg_types = "{ "
                . join( ", ",
                scalar $op->arg_types
                ? map { sprintf( "PARROT_ARG_%s", uc $_ ) } $op->arg_types
                : 0 )
                . " }";
            my $arg_dirs = "{ "
                . join(
                ", ", scalar $op->arg_dirs
                ? map { $arg_dir_mapping{$_} } $op->arg_dirs
                : 0
                ) . " }";
            my $labels = "{ "
                . join(
                ", ", scalar $op->labels
                ? $op->labels
                : 0
                ) . " }";
            my $flags = 0;
    
            print $fh <<END_C;
  { /* $argsref->{index} */
    /* type $type, */
    "$name",
    "$full_name",
    "$func_name",
    /* "",  body */
    $jump,
    $arg_count,
    $arg_types,
    $arg_dirs,
    $labels,
    $flags
  },
END_C

            $argsref->{index}++;
        }
        print $fh <<END_C;
};

END_C
    }
    return (\%names, $argsref->{op_info}, $argsref->{index});
}

sub _op_lookup {
    my $argsref = shift;
    my $fh = $argsref->{fh};

    if ( $argsref->{suffix} eq '' && !$argsref->{flag}->{dynamic} ) {
        $argsref->{getop} = 'get_op';
        my $hash_size = 3041;
        my $tot = $argsref->{index} + scalar keys(%{$argsref->{names}});
        if ( $hash_size < $tot * 1.2 ) {
            print STDERR "please increase hash_size ($hash_size) in tools/build/ops2c.pl "
                . "to a prime number > ", $tot * 1.2, "\n";
        }
        print $fh <<END_C;

/*
** Op lookup function:
*/

#define NUM_OPS $argsref->{num_ops}

#define OP_HASH_SIZE $hash_size

/* we could calculate a prime somewhat bigger than
 * n of fullnames + n of names
 * for now this should be ok
 *
 * look up an op_code: at first call to op_code() a hash
 * of short and full opcode names is created
 * hash functions are from imcc, thanks to Melvin.
 */


typedef struct hop {
    op_info_t * info;
    struct hop *next;
} HOP;
static HOP **hop;

static void hop_init(void);
static size_t hash_str(const char * str);
static void store_op(op_info_t *info, int full);

/* XXX on changing interpreters, this should be called,
   through a hook */

static void hop_deinit(void);

/*
 * find a short or full opcode
 * usage:
 *
 * interp->op_lib->op_code("set", 0)
 * interp->op_lib->op_code("set_i_i", 1)
 *
 * returns >= 0 (found idx into info_table), -1 if not
 */

static int get_op(const char * name, int full);

static size_t hash_str(const char * str) {
    size_t key = 0;
    const char * s;
    for(s=str; *s; s++)
        key = key * 65599 + *s;
    return key;
}

static void store_op(op_info_t *info, int full) {
    HOP * const p = mem_sys_allocate(sizeof(HOP));
    const size_t hidx =
        hash_str(full ? info->full_name : info->name) % OP_HASH_SIZE;
    p->info = info;
    p->next = hop[hidx];
    hop[hidx] = p;
}
static int get_op(const char * name, int full) {
    HOP * p;
    const size_t hidx = hash_str(name) % OP_HASH_SIZE;
    if (!hop) {
        hop = mem_sys_allocate_zeroed(OP_HASH_SIZE * sizeof(HOP*));
        hop_init();
    }
    for (p = hop[hidx]; p; p = p->next) {
        if(!strcmp(name, full ? p->info->full_name : p->info->name))
            return p->info - $argsref->{bs}op_lib.op_info_table;
    }
    return -1;
}
static void hop_init() {
    size_t i;
    op_info_t * info = $argsref->{bs}op_lib.op_info_table;
    /* store full names */
    for (i = 0; i < $argsref->{bs}op_lib.op_count; i++)
        store_op(info + i, 1);
    /* plus one short name */
    for (i = 0; i < $argsref->{bs}op_lib.op_count; i++)
        if (get_op(info[i].name, 0) == -1)
            store_op(info + i, 0);
}
static void hop_deinit(void)
{
    HOP *p, *next;
    if (hop) {
        size_t i;
        for (i = 0; i < OP_HASH_SIZE; i++)
            for (p = hop[i]; p; ) {
                next = p->next;
                free(p);
                p = next;
        }
        free(hop);
    }
    hop = 0;
}

END_C
        return $argsref->{getop};
    } else {
        print $fh <<END_C;
static void hop_deinit(void) {}
END_C
        return $argsref->{getop};
    }
}

sub _print_op_lib_descriptor {
    my $argsref = shift;
    my $fh = $argsref->{fh};
    my $trans = $argsref->{trans};
    my $core_type = $trans->core_type();
    print $fh <<END_C;

/*
** op lib descriptor:
*/

static op_lib_t $argsref->{bs}op_lib = {
  "$argsref->{base}",               /* name */
  "$argsref->{suffix}",             /* suffix */
  $core_type,                       /* core_type = PARROT_XX_CORE */
  0,                                /* flags */
  $argsref->{versions}->{major},    /* major_version */
  $argsref->{versions}->{minor},    /* minor_version */
  $argsref->{versions}->{patch},    /* patch_version */
  $argsref->{num_ops},              /* op_count */
  $argsref->{op_info},              /* op_info_table */
  $argsref->{op_func},              /* op_func_table */
  $argsref->{getop}                 /* op_code() */
};

END_C
}

sub _generate_init_func {
    my $argsref = shift;
    my $fh = $argsref->{fh};
    my $init1_code = "";
    if ( $argsref->{trans}->can("init_func_init1") ) {
        $init1_code = $argsref->{trans}->init_func_init1($argsref->{base});
    }
    
    my $init_set_dispatch = "";
    if ( $argsref->{trans}->can("init_set_dispatch") ) {
        $init_set_dispatch 
            = $argsref->{trans}->init_set_dispatch($argsref->{bs});
    }
    
    print $fh <<END_C;
op_lib_t *
$argsref->{init_func}(long init) {
    /* initialize and return op_lib ptr */
    if (init == 1) {
$init1_code
    return &$argsref->{bs}op_lib;
    }
    /* set op_lib to the passed ptr (in init) */
    else if (init) {
$init_set_dispatch
    }
    /* deinit - free resources */
    else {
    hop_deinit();
    }
    return NULL;
}

END_C
}

sub _print_dynamic_lib_load {
    my $argsref = shift;
    my $fh = $argsref->{fh};
    if ($argsref->{flag}->{dynamic}) {
        my $load_func = join q{_}, (
            q{Parrot},
            q{lib},
            $argsref->{base},
            (q{ops} . $argsref->{suffix}),
            q{load},
        );
        print $fh <<END_C;
/*
 * dynamic lib load function - called once
 */

$argsref->{sym_export} PMC*
$load_func(Parrot_Interp interp)
{
    PMC *lib = pmc_new(interp, enum_class_ParrotLibrary);
    PMC_struct_val(lib) = (void *) $argsref->{init_func};
    dynop_register(interp, lib);
    return lib;
}
END_C
    }
}

sub _rename_source {
    my $source = shift;
    my $final = $source;
    $final =~ s/\.temp//;
    rename $source, $final or die "Unable to rename $source to $final: $!";
}

#################### DOCUMENTATION ####################

=head1 NAME

tools/build/ops2c.pl - Parser for .ops files

=head1 SYNOPSIS

    % perl tools/build/ops2c.pl trans [--help] [--no-lines] [--dynamic]
                                      [--core | input.ops [input2.ops ...]]
       trans := C | CGoto | CGP | CSwitch | CPrederef

For example:

    % perl tools/build/ops2c.pl C --core

    % perl tools/build/ops2c.pl C --dynamic myops.ops

=head1 DESCRIPTION

This script uses a supplied transform to create a pair of C header and
implementation files from the operation definitions found in one or more
F<*.ops> files.

=head2 Transforms

The first command-line argument is the last package name component of a
subclass of C<Parrot::OpTrans>. These subclasses all have full names of
the form C<Parrot::OpTrans::*>. An instance of the class is created and
later consulted for various bits of information needed to generate the C
code. Each creates a different type of run loop.

=over

=item C<C>

Create the function-based (slow or fast core) run loop.

=item C<CGoto>

Create the C<goto> run loop.

=item C<CGP>

Create the C<goto> and predereferenced run loop.

=item C<CSwitch>

Create the C<switch>ed and predereferenced run loop.

=item C<CPrederef>

Create the predereferenced run loop.

=back

=head2 Options

=over 4

=item C<--help>

Print synopsis.

=item C<--dynamic>

Indicate that the opcode library is dynamic.

=item C<--core>

Build the Parrot core opcode library.

=item C<--no-lines>

Do not generate C<#line> directives in the generated C code.

=back

=head1 SEE ALSO

=over 4

=item F<tools/build/ops2pm.pl>

=item C<Parrot::OpsFile>

=item C<Parrot::Op>

=item C<Parrot::OpTrans>

=item C<Parrot::OpTrans::C>

=item C<Parrot::OpTrans::CGoto>

=item C<Parrot::OpTrans::Compiled>

=item C<Parrot::OpTrans::CGP>

=item C<Parrot::OpTrans::CSwitch>

=item C<Parrot::OpTrans::CPrederef>

=back

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:


__END__

#print STDERR Dumper (
#    \@ARGV,
#    $trans,
#    $suffix,
#    $file,
#    $base,
#    $incdir,
#    $include,
#    $header,
#    $source,
#    $sym_export,
#    $ops,
#    \%versions,
#    $num_ops,
#    $num_entries,
#);
