# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$
package Parrot::Configure::Initialize::Miniparrot;
use strict;
use warnings;
use lib ( "./lib" );

################### SUBROUTINES ###################

sub init_miniparrot {
    my $self = shift;
    unless ( $self->{options}->{miniparrot} ) {
        return 1;
    }

    $self->{miniparrot}         = 1;
    $self->{DEVEL}              = $self->{DEVEL} . '-miniparrot';
    $self->{TEMP_cg_h}          = '';
    $self->{TEMP_cg_c}          = '';
    $self->{TEMP_cg_o}          = '';
    $self->{TEMP_cg_r}          = '';
    $self->{cg_flag}            = '';
    $self->{archname}           = 'miniparrot';
    $self->{cpuarch}            = 'unknown';
    $self->{osname}             = 'ANSI';
    $self->{jitarchname}        = 'nojit';
    $self->{jitcpuarch}         = 'i386';
    $self->{jitcpu}             = 'I386';
    $self->{jitosname}          = 'nojit';
    $self->{jitcapable}         = 0;
    $self->{execcapable}        = 0;
    $self->{cc_hasjit}          = '';
    $self->{TEMP_jit_o}         = '';
    $self->{TEMP_exec_h}        = '';
    $self->{TEMP_exec_o}        = '';
    $self->{TEMP_atomic_o}      = '';
    $self->{asmfun_o}           = '';
    $self->{has___sighandler_t} = undef;
    $self->{has_sigatomic_t}    = undef;
    $self->{has_sigaction}      = undef;
    $self->{has_setitimer}      = undef;

    # we can't guarantee anything about pointer alignment under ANSI C89.
    # so we will have to check every byte.
    $self->{ptr_alignment}      = 1;
    #Allow ANSI headers only
    foreach ( qw|
        assert
        complex
        ctype
        errno
        locale
        math
        setjmp
        signal
        stdarg
        stdio
        stdlib
        string
        time
    | )
    {
        $self->{"i_$_"} = 1;
    }
}

1;

#################### DOCUMENTATION ####################

=head1 NAME

Parrot::Configure::Initialize::Miniparrot - Miniparrot configuration

=head1 SYNOPSIS

    use Parrot::Configure::Initialize::Miniparrot;

=head1 DESCRIPTION

Modifies settings to match miniparrot (ANSI C Parrot)'s needs.  This step
primarily overwrites a lot of settings in the Configure database to disable
JIT and match ANSI characteristics.

Centralizing these settings will (hopefully) allow for an eventual move away
from using Configure at all for miniparrot builds.

=head1 SUBROUTINES

=head1 NOTES

The functionality in this package was transferred from the former
C<init::miniparrot> configuration steps by Jim Keenan.

=head1 SEE ALSO

F<Configure.pl>.  Parrot::Configure.  Parrot::Configure::Initialize.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
