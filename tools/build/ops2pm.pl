#! perl
# Copyright (C) 2001-2004, The Perl Foundation.
# $Id$
use warnings;
use strict;
use Data::Dumper;
$Data::Dumper::Useqq = 1;
use Getopt::Long;
use lib 'lib';
#use Parrot::Ops2pm::Utils qw(
#    process_ARGV
#    prepare_ops
#    renum_op_map_file
#    load_op_map_files
#    sort_ops
#    prepare_real_ops
#    print_module
#    print_h
#);
use Parrot::Ops2pm::Utils;
use Parrot::Ops2pm::Auxiliary qw( Usage );

my ( $nolines_flag, $help_flag, $renum_flag );
GetOptions(
    "no-lines" => \$nolines_flag,
    "help"     => \$help_flag,
    "renum"    => \$renum_flag,
);

if ($help_flag or ! @ARGV) {
    Usage();
    exit;
}

#my ($file, $argvref) = process_ARGV(@ARGV);
#my $ops = prepare_ops($file, $nolines_flag, $argvref);
#    
#if ($renum_flag) {
#    renum_op_map_file($ops);
#    exit 0;
#}
#load_op_map_files();
#$ops = sort_ops($ops);
#
#my $real_ops = prepare_real_ops( {
#    ops             => $ops,
#    nolines_flag    => $nolines_flag,
#} );
#
#my $moddir  = "lib/Parrot/OpLib";
#my $module  = "core.pm";
#
#print_module( {
#    moddir      => $moddir,
#    ops_file    => $file,
#    real_ops    => $real_ops,
#    script      => $0,
#    module      => $module,
#    package     => 'core',
#} );
#
#my $inc_dir = "include/parrot/oplib";
#my $inc_f   = "ops.h";
#print_h( {
#    inc_dir     => $inc_dir,
#    inc_f       => $inc_f,
#    ops_file    => $file,
#    script      => $0,
#    real_ops    => $real_ops,
#} );

my $self = Parrot::Ops2pm::Utils->new( {
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

################### DOCUMENTATION ####################

=head1 NAME

tools/build/ops2pm.pl - Generate Perl module from operation definitions

=head1 SYNOPSIS

 $ perl tools/build/ops2pm.pl [--help] [--no-lines] input.ops [input2.ops ...]
 $ perl tools/build/ops2pm.pl [--renum]  input.ops [input2.ops ...]

=head1 DESCRIPTION

Reads the ops files listed on the command line and outputs a
C<Parrot::OpLib::core> module containing information about the ops.

=head2 Options

=over 4

=item C<--help>

Print synopsis.

=item C<--no-lines>

Do not generate C<#line> directives in the generated C code.

=item C<--renum>

Renumber opcodes according to existing ops in ops/num and natural
order in the given ops files. See also F<tools/dev/ops_renum.mak>.

=back

=head2 WARNING

Generating a C<Parrot::OpLib::core> module for a set of ops files that
you do not later turn into C code (see F<tools/build/ops2c.pl>) with the
same op content and order is a recipe for disaster. But as long as you
just run these tools in the standard build process via C<make> there
shouldn't be a problem.

=head1 TODO

The original design of the ops processing code was intended to be
a read-only representation of what was in a particular ops file. It was
not originally intended that it was a mechanism for building a bigger
virtual ops file from multiple physical ops files.

This code does half of that job (the other half is getting them to
compile together instead of separately in a F<*_ops.c> file).

You can see evidence of this by the way this code reaches in to the
internal C<OPS> hash key to do its concatenation, and the way it
twiddles each op's C<CODE> hash key after that.

If the op and oplib Perl modules are going to be used for modifying
information read from ops files in addition to reading it, they should
be changed to make the above operations explicitly supported.

Otherwise, the Parrot build and interpreter start-up logic should be
modified so that it doesn't need to concatenate separate ops files.

=head1 SEE ALSO

=over 4

=item F<tools/build/ops2c.pl>.

=back

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

