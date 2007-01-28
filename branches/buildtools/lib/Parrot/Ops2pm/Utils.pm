# Copyright (C) 2004-2006, The Perl Foundation.
# $Id$
package Parrot::Ops2pm::Utils;
use strict;
use warnings;
use Cwd;
use Data::Dumper;
use File::Path ();
use File::Spec;
use lib ("lib/");
use Parrot::OpsFile;

=head1 NAME

Parrot::Ops2pm::Utils - Methods holding functionality for F<tools/build/ops2pm.pl>.

=head1 SYNOPSIS

    use Parrot::Ops2pm::Utils;
    
    $self = Parrot::Ops2pm::Utils->new( {
        argv            => [ @ARGV ],
        nolines         => $nolines_flag,
        renum           => $renum_flag,
        moddir          => "lib/Parrot/OpLib",
        module          => "core.pm",
        inc_dir         => "include/parrot/oplib",
        inc_f           => "ops.h",
        script          => "tools/build/ops2pm.pl",
    } );
    
    $self->prepare_ops();
        
    if ($renum_flag) {
        $self->renum_op_map_file();
        exit 0;
    }
    
    $self->load_op_map_files();
    $self->sort_ops();
    $self->prepare_real_ops();
    $self->print_module();
    $self->print_h();
    exit 0;

=cut

=head1 DESCRIPTION

Parrot::Ops2pm::Utils provides methods called by F<tools/build/ops2pm.pl>, a
program which is called at the very beginning of the Parrot F<make> process.
The program's function is to build two files:

The functionality originally found in F<tools/build/ops2pm.pl> has been
extracted into this package's methods in order to support component-focused
testing and future refactoring.

=cut

############### Package-scoped Lexical Variables ###############

my $NUM_FILE   = "src/ops/ops.num";
my $SKIP_FILE  = "src/ops/ops.skip";

############### Subroutines ###############

=head1 METHODS

=head2 C<new()>

B<Purpose:>  Process files provided as command-line arguments to
F<tools/build/ops2pm.pl> and construct a Parrot::Ops2pm::Utils object.

B<Arguments:>  Hash reference with the following elements:

    argv        :   reference to @ARGV
    nolines     :   set to true value to eliminate #line
                    directives in output
    renum       :   set to true value if
    moddir      :   directory where output module is created
                    (generally, lib/Parrot/OpLib)
    module      :   name of output module
                    (generally, core.pm)
    inc_dir     :   directory where C-header file is created
                    (generally, include/parrot/oplib)
    inc_f       :   name of output C-header file
                    (generally, ops.h)
    script      :   name of the script to be executed by 'make'
                    (generally, tools/build/ops2pm.pl)

B<Return Value:>  Parrot::Ops2pm::Utils object.

B<Comment:>  Arguments for the constructor have been selected so as to provide
subsequent methods with all information needed to execute properly and to be
testable.  A Parrot::Ops2pm::Utils object I<can> be constructed lacking some
of these arguments and still suffice for the execution of particular methods
-- this is done during the test suite -- but such an object would not suffice
for F<make>'s call to F<tools/build/ops2pm.pl>.

=cut

sub new {
    my ($class, $argsref) = @_;
    my @argv = @{$argsref->{argv}};
    my $file = shift @argv;
    die "$argsref->{script}: Could not find ops file '$file'!\n"
        unless -e $file;
    $argsref->{file} = $file;
    $argsref->{argv} = \@argv;
    return bless $argsref, $class;
}

=head2 C<prepare_ops()>

B<Purpose:>  Call C<Parrot::OpsFile->new()>, then populate the resulting
C<$opts> hash reference with information from  each of the F<.ops> files
provided as command-line arguments to F<tools/build/ops2pm.pl>.

B<Arguments:>  None.  (Implicitly requires that at least the C<argv> and
C<script> elements were provided to the constructor.)

B<Return Value:>  None.  Internally, sets the C<ops> key in the object's data
structure.

B<Comment:>

=cut

sub prepare_ops {
    my $self = shift;
    my $ops = Parrot::OpsFile->new( [$self->{file}], $self->{nolines} );
    die "$self->{script}: Could not read ops file '$self->{file}'!\n"
        unless defined $ops;

    # Copy the ops from the remaining .ops files to the object just created.
    my %seen;

    while ( defined (my $f = shift( @{$self->{argv}} ) ) ) {
        if ( $seen{$f} ) {
            print STDERR "$self->{script}: Ops file '$f' mentioned more than once!\n";
            next;
        }
        $seen{$f} = 1;

        die "$self->{script}: Could not find ops file '$f'!\n"
            unless -e $f;
        my $temp_ops = Parrot::OpsFile->new( [$f], $self->{nolines} );
        die "$self->{script}: Could not read ops file '$f'!\n"
            unless defined $temp_ops;
        die "OPS invalid for $f" unless ref $temp_ops->{OPS};

        my $experimental = $f =~ /experimental/;
        # mark experimental ops
        if ($experimental) {
            for my $el ( @{ $temp_ops->{OPS} } ) {
                $el->{experimental} = 1;
            }
        }

        push @{ $ops->{OPS} }, @{ $temp_ops->{OPS} };
        $ops->{PREAMBLE} .= "\n" . $temp_ops->{PREAMBLE};
    }
    $self->{ops} = $ops;
}

=head2 C<renum_op_map_file()>

B<Purpose:>  Triggered when F<tools/build/ops2pm.pl> is called with the
C<--renum> flag, this method ...

B<Arguments:>  String holding name of an F<.ops> file; defaults to
F<src/ops/ops.num>.

B<Return Value:>  Returns true value upon success. 

B<Comment:>  After being called by F<tools/build/ops2pm.pl>, that script
exits, making this the only Parrot::Ops2pm::Utils method which is I<not> a
stepping stone on the path to building F<lib/Parrot/OpLib/core.pm>.

=cut

sub renum_op_map_file {
    my $self = shift;

    my $file = scalar(@_) ? shift : $NUM_FILE;
    my ( $name, $number, @lines, %seen, %fixed, $fix );
    $fix = 1;
    open my $OP, '<', $file
        or die "Can't open $file, error $!";
    while (<$OP>) {
        push @lines, $_ if $fix;
        chomp;
        $fix = 0 if /^###DYNAMIC###/;
        s/#.*$//;
        s/\s*$//;
        s/^\s*//;
        next unless $_;
        ( $name, $number ) = split( /\s+/, $_ );
        $seen{$name} = $number;
        $fixed{$name} = $number if ($fix);
    }
    close $OP;
    open $OP, '>', $file
        or die "Can't open $file, error $!";
    print $OP @lines;
    my ($n);

    #
    # we can't use all autogenerated ops from oplib/core
    # there are unwanted permutations like 'add_i_ic_ic
    # which aren't opcodes but calced at compile-time
    #

    for ( @{ $self->{ops}->{OPS} } ) {
        if ( defined $fixed{ $_->full_name } ) {
            $n = $fixed{ $_->full_name };
        }
        elsif ( $seen{ $_->full_name } ) {
            printf $OP "%-31s%4d\n", $_->full_name, ++$n;
        }
    }
    close $OP;
    return 1;
}

=head2 C<load_op_map_files()>

B<Purpose:>  

B<Arguments:>  None.

B<Return Value:>   Returns true value upon success.  Internally, sets these
keys in the object's data structure:  C<max_op_num>, C<skiptable> and
C<optable>.

B<Comment:>

=cut

sub load_op_map_files {
    my $self = shift;
    my $num_file  = $NUM_FILE;
    my $skip_file = $SKIP_FILE;

    my ( $op, $name, $number, $prev );

    $self->{max_op_num} ||= 0;

    open $op, '<', $num_file
        or die "Can't open $num_file: $!";
    $prev = -1;
    while (<$op>) {
        chomp;
        s/#.*$//;
        s/\s*$//;
        s/^\s*//;
        next unless $_;
        ( $name, $number ) = split( /\s+/, $_ );
        if ( $prev + 1 != $number ) {
            die "hole in ops.num before #$number";
        }
        if ( exists $self->{optable}->{$name} ) {
            die "duplicate opcode $name and $number";
        }
        $prev = $number;
        $self->{optable}->{$name} = $number;
        if ( $number > $self->{max_op_num} ) {
            $self->{max_op_num} = $number;
        }
    }
    undef $op;

    open $op, '<', $skip_file
        or die "Can't open $skip_file: $!";
    while (<$op>) {
        chomp;
        s/#.*$//;
        s/\s*$//;
        s/^\s*//;
        next unless $_;
        ($name) = split( /\s+/, $_ );
        if ( exists $self->{optable}->{$name} ) {
            die "skipped opcode is also in $num_file";
        }
        $self->{skiptable}->{$name} = 1;
    }
    undef $op;
    return 1;
}

=head2 C<sort_ops()>

B<Purpose:>  

B<Arguments:>  None.

B<Return Value:>  None.  Internally, sets the C<ops> key of the object's data
structure.

B<Comment:>

=cut

sub sort_ops {
    my $self = shift;
    for my $el ( @{ $self->{ops}->{OPS} } ) {
        if ( exists $self->{optable}->{$el->full_name} ) {
            $el->{CODE} = $self->{optable}->{$el->full_name};
        }
        elsif ( exists $self->{skiptable}->{$el->full_name} ) {
            $el->{CODE} = -1;
        }
        elsif ($el->{experimental}) {
            my $n = $self->{optable}->{$el->full_name} = ++$self->{max_op_num};
            warn sprintf(
                "%-25s %-10s experimental, not in ops.num\n", 
                $el->full_name, $n
            ) if -e "DEVELOPING";
            $el->{CODE} = $n;
        }
        else {
            warn sprintf(
                "%-25s %-10s SKIPPED: not in ops.num nor ops.skip\n",
                $el->full_name, ""
            ) if -e "DEVELOPING";
            $el->{CODE} = -1;
        }
    }
    @{ $self->{ops}->{OPS} } = sort { $a->{CODE} <=> $b->{CODE} } ( @{ $self->{ops}->{OPS} } );
}

=head2 C<prepare_real_ops()>

B<Purpose:>  

B<Arguments:>  None.

B<Return Value:>  None.  Internally, sets the C<real_ops> key of the object's data
structure.

B<Comment:>

=cut

sub prepare_real_ops {
    my $self = shift;

    my $real_ops = Parrot::OpsFile->new( [], $self->{nolines} );
    $real_ops->{PREAMBLE} = $self->{ops}->{PREAMBLE};
    $real_ops->version( $self->{ops}->version );
    
    # verify opcode numbers
    my $seq = 0;
    for my $el ( @{ $self->{ops}->{OPS} } ) {
        next if ( $el->{CODE} < 0 );    # skip
        my $opname = $el->full_name;
        my $n      = $self->{optable}->{$opname};  # former global
        if ( $n != $el->{CODE} ) {
            die "op $opname: number mismatch: ops.num $n vs. core.ops $el->{CODE}";
        }
        if ( $seq != $el->{CODE} ) {
            die "op $opname: sequence mismatch: ops.num $seq vs. core.ops $el->{CODE}";
        }
        push @{ $real_ops->{OPS} }, $el;
        ++$seq;
    }
    $self->{real_ops} = $real_ops;
}

=head2 C<print_module()>

B<Purpose:>  Uses information in the object's data structure to create 
F<lib/Parrot/OpLib/core.pm>.

B<Arguments:>  None.

B<Return Value:>  Returns true value upon success.

B<Comment:>

=cut

sub print_module {
    my $self = shift;
    my $cwd = cwd();
    my $fulldir = File::Spec->catdir( $cwd, $self->{moddir} );
    if ( !-d $fulldir ) {
        File::Path::mkpath( $fulldir, 0, 0755 )
            or die "$self->{script}: Could not mkdir $fulldir: $!!\n";
    }
    my $fullpath = File::Spec->catfile( ($fulldir), $self->{module});
    open my $MODULE, '>', $fullpath
        or die "$self->{script}: Could not open module file '$fullpath' for writing: $!!\n";

    my $version = $self->{real_ops}->version();
    ( my $pod = <<"END_POD") =~ s/^    //osmg;
=head1 NAME

Parrot::OpLib::core - Parrot Op Info

=head1 DESCRIPTION

This is an autogenerated file, created by F<$self->{script}>.

It contains Parrot version info, a preamble for inclusion in C code,
and an array of C<Parrot::Op> instances representing the Parrot ops.

=cut
END_POD

    my $preamble = <<END_C;
#! perl -w
#
# !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
#
# This file is generated automatically from '$self->{file}'.
# Any changes made here will be lost!
#

$pod

use strict;

package Parrot::OpLib::core;

use vars qw(\$VERSION \$ops \$preamble);

\$VERSION = "$version";

END_C

    print $MODULE $preamble;
    print $MODULE Data::Dumper->Dump( [ $self->{real_ops}->preamble, [ $self->{real_ops}->ops ] ],
        [qw($preamble $ops)] );

    print $MODULE <<END_C;

1;
END_C

    close $MODULE;
    return 1;
}

=head2 C<print_h()>

B<Purpose:>  Uses information in the object's data structure to create 
F<include/parrot/oplib/ops.h>.

B<Arguments:>  None.

B<Return Value:>  Returns true value upon success.

B<Comment:>

=cut

sub print_h {
    my $self = shift;
    my $cwd = cwd();
    my $fulldir = File::Spec->catdir( $cwd, $self->{inc_dir} );
    if ( !-d $fulldir ) {
        File::Path::mkpath( $fulldir, 0, 0755 )
            or die "$self->{script}: Could not mkdir $fulldir: $!!\n";
    }

    my $fullpath = File::Spec->catfile( ($fulldir), $self->{inc_f});
    open my $OUT, '>', $fullpath
        or die "$self->{script}: Could not open module file '$fullpath' for writing: $!!\n";

    print $OUT <<END_C;
/* ex: set ro:
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically from '$self->{file}'
 * by $self->{script}.
 *
 * Any changes made here will be lost!
 */

#ifndef PARROT_OPS_H_GUARD
#define PARROT_OPS_H_GUARD

typedef enum {
END_C

    my @OPS = @{ $self->{real_ops}->{OPS} };
    for my $el ( @OPS ) {
        my $opname = $el->full_name;
        my $n      = $el->{CODE};
        my $comma  = $n < @OPS - 1 ? "," : "";
        $opname = "PARROT_OP_$opname$comma";

        printf $OUT "    %-30s\t/* %4d */\n", $opname, $n;
    }

    print $OUT <<END_C;
} parrot_opcode_enums;

#endif

END_C

    # append the C code coda
    print $OUT <<END_C;
/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
END_C
    close $OUT;
    return 1;
}

1;

