# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$
package Parrot::Configure::Initialize::Miniparrot;
use strict;
use warnings;
use lib ( "./lib" );

################### SUBROUTINES ###################

sub init_miniparrot {
    my $self = shift;
    unless ( $self->get_options('miniparrot') ) {
        return 1;
    }

    $self->set(
        miniparrot          => 1,
        DEVEL               => $self->get('DEVEL') . '-miniparrot',
        TEMP_cg_h           => '',
        TEMP_cg_c           => '',
        TEMP_cg_o           => '',
        TEMP_cg_r           => '',
        cg_flag             => '',
        archname            => 'miniparrot',
        cpuarch             => 'unknown',
        osname              => 'ANSI',
        jitarchname         => 'nojit',
        jitcpuarch          => 'i386',
        jitcpu              => 'I386',
        jitosname           => 'nojit',
        jitcapable          => 0,
        execcapable         => 0,
        cc_hasjit           => '',
        TEMP_jit_o          => '',
        TEMP_exec_h         => '',
        TEMP_exec_o         => '',
        TEMP_atomic_o       => '',
        asmfun_o            => '',
        has___sighandler_t  => undef,
        has_sigatomic_t     => undef,
        has_sigaction       => undef,
        has_setitimer       => undef,

    # we can't guarantee anything about pointer alignment under ANSI C89.
    # so we will have to check every byte.
        ptr_alignment       => 1,
    );
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
        $self->set("i_$_" => 1);
    }
    return 1;
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
