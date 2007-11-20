# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$
package Parrot::Configure::Initialize::Install;
use strict;
use warnings;
use lib ( "./lib" );

################### SUBROUTINES ###################

sub init_install {
    my $self = shift;
    my $prefix = $self->{options}->{prefix} || "/usr/local";
    $prefix =~ s{/\z}{};
    my $ep = $self->{options}->{'exec-prefix'};
    $ep =~ s{/\z}{} if defined $ep;
    my $eprefix = $ep ? $ep : $prefix;

    $self->{prefix} = $prefix;
    $self->{exec_prefix} = $eprefix;

    #  --bindir=DIR           user executables [EPREFIX/bin]
    $self->{bindir} = $self->_assign_dir( 'bindir', $eprefix, '/bin' );

    #  --sbindir=DIR          system admin executables [EPREFIX/sbin]
    $self->{sbindir} = $self->_assign_dir( 'sbindir', $eprefix, '/sbin' );

    #  --libexecdir=DIR       program executables [EPREFIX/libexec]
    $self->{libexecdir} = $self->_assign_dir( 'libexecdir', $eprefix, '/libexec' );

    #  --datadir=DIR          read-only architecture-independent data 
    #                         [PREFIX/share]
    $self->{datadir} = $self->_assign_dir( 'datadir', $prefix, '/share' );
    # parrot internal use only
    $self->{doc_dir} = $self->{datadir} . "/doc/parrot";

    #  --sysconfdir=DIR       read-only single-machine data [PREFIX/etc]
    $self->{sysconfdir} = $self->_assign_dir( 'sysconfdir', $prefix, '/etc' );

    #  --sharedstatedir=DIR   modifiable architecture-independent data
    #                         [PREFIX/com]
    $self->{sharedstatedir} = $self->_assign_dir( 'sharedstatedir', $prefix, '/com' );

    #  --localstatedir=DIR    modifiable single-machine data [PREFIX/var]
    $self->{localstatedir} = $self->_assign_dir( 'localstatedir', $prefix, '/var' );

    #  --libdir=DIR           object code libraries [EPREFIX/lib]
    $self->{libdir} = $self->_assign_dir( 'libdir', $eprefix, '/lib' );

    #  --includedir=DIR       C header files [PREFIX/include]
    $self->{includedir} = $self->_assign_dir( 'includedir', $prefix, '/include' );

    #  --oldincludedir=DIR    C header files f|| non-gcc [/usr/include]
    $self->{oldincludedir} = $self->_assign_dir( 'oldincludedir', q{}, '/usr/include' );

    #  --infodir=DIR          info documentation [PREFIX/info]
    $self->{infodir} = $self->_assign_dir( 'infodir', $prefix, '/info' );

    #  --mandir=DIR           man documentation [PREFIX/man]
    $self->{mandir} = $self->_assign_dir( 'mandir', $prefix, '/man' );

    # deprecated
    $self->{bin_dir} = $self->{bindir};
    $self->{lib_dir} = $self->{libdir};
    $self->{include_dir} = $self->{includedir};
}

sub _assign_dir {
    my $self = shift;
    my ( $dir_str, $fix, $ext ) = @_;
    my $d = $self->{options}->{$dir_str};
    return $d ? $d : $fix . $ext;
}

1;

#################### DOCUMENTATION ####################

=head1 NAME

Parrot::Configure::Initialize::Install - Gather initial configuration data from command-line options, Perl 5 configuration and other system data

=head1 SYNOPSIS

    use Parrot::Configure::Initialize::Install;

=head1 DESCRIPTION

Parrot::Configure::Initialize:Install gathers initial configuration
data from command-line options, Perl 5 c<%Config> and other readily
available sources.  Its methods are inherited and invoked by
Parrot::Configure::Initialize.

=head1 SUBROUTINES

=head1 NOTES

The functionality in this package was transferred from the former
C<init::defaults> configuration steps by Jim Keenan.

=head1 SEE ALSO

F<Configure.pl>.  Parrot::Configure.  Parrot::Configure::Initialize.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
