# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$
package Parrot::Configure::Initialize::Defaults;
use strict;
use warnings;
use Carp;
use Config;
use Cwd qw(abs_path);
use File::Spec;
use FindBin;    # see build_dir
use lib ( "./lib" );
use Parrot::BuildUtil;

################### SUBROUTINES ###################

sub _init_from_options {
    my $self = shift;
    $self->{debugging} = $self->{options}->{debugging} ? 1 : 0;
    $self->{verbose}   = $self->{options}->{verbose};
}

sub _init_from_Config {
    my $self = shift;
    # Compiler -- used to turn .c files into object files.
    # (Usually cc or cl, or something like that.)
    $self->{cc} = $Config{cc};
    $self->{ccflags} = $Config{ccflags};
    $self->{ccwarn} = exists( $Config{ccwarn} ) ? $Config{ccwarn} : '';

    # Flags used to indicate this object file is to be compiled
    # with position-independent code suitable for dynamic loading.
    # e.g. -fpic for GNU cc.
    $self->{cc_shared} = $Config{cccdlflags};

    # C++ compiler -- used to compile parts of ICU.  ICU's configure
    # will try to find a suitable compiler, but it prefers GNU c++ over
    # a system c++, which might not be appropriate.  This setting
    # allows you to override ICU's guess, but is otherwise currently
    # unset.  Ultimately, it should be set to whatever ICU figures
    # out, or parrot should look for it and always tell ICU what to
    # use.
    $self->{cxx} = 'c++';

    # Linker, used to link object files (plus libraries) into
    # an executable.  It is usually $cc on Unix-ish systems.
    # VMS and Win32 might use "Link".
    # Perl5's Configure doesn't distinguish linking from loading, so
    # make a reasonable guess at defaults.
    $self->{link} = $Config{cc};
    $self->{linkflags} = $Config{ldflags};

    # Linker Flags to have this binary work with the 
    # shared and dynamically loadable libraries we're building.
    # On HP-UX, for example, we need to
    # allow dynamic libraries to access the binary's symbols
    # e.g. -Wl,-E on HP-UX
    $self->{link_dynamic} = $Config{ccdlflags};

    # ld: Tool used to build shared libraries and dynamically loadable
    # modules. Often $cc on Unix-ish systems, but apparently sometimes
    # it's ld.
    $self->{ld} = $Config{ld};
    $self->{ldflags} = $Config{ldflags};

    # Some operating systems (e.g. Darwin) distinguish between shared
    # libraries and modules that can be dynamically loaded.
    # Flags to tell ld to build a shared library, 
    # e.g., -shared for GNU ld.
    $self->{ld_share_flags} = $Config{lddlflags};

    # Flags to tell ld to build a dynamically loadable module,
    # e.g., -shared for GNU ld.
    $self->{ld_load_flags} = $Config{lddlflags};

    $self->{libs} = $Config{libs};

    $self->{cc_inc} = "-I./include";
    $self->{cc_debug} = '-g';
    $self->{link_debug} = '';

    $self->{o} = $Config{_o};       # object files extension
    $self->{share_ext} = ".$Config{so}";    # shared library extension

    # dynamically loadable module extension
    $self->{load_ext} = ".$Config{so}";
    $self->{a} = $Config{_a};        # library or archive extension
    $self->{exe} = $Config{_exe};      # executable files extension
    $self->{cc_o_out} = '-o ';              # cc object output file

    # cc executable output file (different on Win32)
    $self->{cc_exe_out} = '-o ';

    # prefix for ldflags (necessary for Win32)
    $self->{cc_ldflags} = '';

    # ld output file.  Keep the trailing space.
    $self->{ld_out} = '-o ';

    # include debug info in executable
    $self->{ld_debug} = '';

    # Way to decorate a function to mark it as an exportable or
    # importable symbol.
    $self->{sym_export} = '';
    $self->{sym_import} = '';

    # Library build directory
    $self->{blib_dir} = 'blib/lib';

    # libparrot library names
    $self->{libparrot_static} = 'libparrot' . $Config{_a};
    $self->{libparrot_shared} = 'libparrot.' . $Config{so};

    # does the system know about static/dynamic linking?
    $self->{has_static_linking} = 1;
    $self->{has_dynamic_linking} = 0;

    # default behaviour for linking parrot to a 
    # static or shared libparrot
    $self->{parrot_is_shared} = 0;

    #  avoid a warning during Configure.pl
    $self->{libparrot_soname} = '';

    $self->{perl} = $^X;
    $self->{perl_inc} = _find_perl_headers();
    $self->{test_prog} = 'parrot';
    $self->{rm_f} = '$(PERL) -MExtUtils::Command -e rm_f';
    $self->{rm_rf} = '$(PERL) -MExtUtils::Command -e rm_rf';
    $self->{mkpath} = '$(PERL) -MExtUtils::Command -e mkpath';
    $self->{touch} = '$(PERL) -MExtUtils::Command -e touch';
    $self->{chmod} =
        '$(PERL) -MExtUtils::Command -e ExtUtils::Command::chmod';
    $self->{ar} = $Config{ar};
    $self->{ar_flags} = 'cr';

    # for Win32
    $self->{ar_out} = '';

    # for Borland C
    $self->{ar_extra} = '';
    $self->{ranlib} = $Config{ranlib};
    $self->{rpath} = '';
    $self->{make} = $Config{make};
    $self->{make_set_make} = $Config{make_set_make};
    $self->{make_and} = '&&';

    # make_c: Command to emulate GNU make's C<-C directory> option:
    # chdir to C<directory> before executing $(MAKE)
    $self->{make_c} = '$(PERL) -e \'chdir shift @ARGV; system q{$(MAKE)}, @ARGV; exit $$? >> 8;\'';

    # if platform has a .s file that needs to be assembled
    $self->{platform_asm} = 0;
    $self->{as} = 'as';    # assembler

    $self->{cp} = '$(PERL) -MExtUtils::Command -e cp';
    $self->{lns} = $Config{lns};                          # soft link
    $self->{slash} = '/';
}

sub _init_version {
    my $self = shift;
    my $parrot_version = Parrot::BuildUtil::parrot_version();
    my @parrot_version = Parrot::BuildUtil::parrot_version();
    $self->{VERSION} = $parrot_version;
    $self->{MAJOR} = $parrot_version[0];
    $self->{MINOR} = $parrot_version[1];
    $self->{PATCH} = $parrot_version[2];
    $self->{DEVEL} = ( -e 'DEVELOPING' ? '-devel' : '' );
}

sub _init_misc {
    my $self = shift;
    $self->{optimize}   = '';
    $self->{build_dir}  = abs_path($FindBin::Bin);
    $self->{configdate} = scalar gmtime() . " GMT";
    $self->{PQ} = "'";
    $self->{dquote} = "\\\"";

    # yacc = Automatic parser generator
    # lex  = Automatic lexer  generator
    # Some systems may lack these
    $self->{yacc} = 'bison -v -y';
    $self->{lex} = 'flex';

    # Extra flags needed for libnci_test.so
    $self->{ncilib_link_extra} = '';
}

sub _init_profile {
    my $self = shift;
    # add profiling if needed
    # RT#41497 gcc syntax
    # we should have this in the hints files e.g. cc_profile
    # RT#41496 move profiling to it's own step
    if ( $self->{options}->{profile} ) {
        $self->{cc_debug} = " -pg ";
        $self->{ld_debug} = " -pg ";
    }
}

sub _init_archname {
    my $self = shift;
    # adjust archname, cc and libs for e.g. --m=32
    # RT#41499 this is maybe gcc only
    my $m        = $self->{options}->{'m'};
    my $archname = $Config{archname};
    if ($m) {
        if ( $archname =~ /x86_64/ && $m eq '32' ) {
            $archname =~ s/x86_64/i386/;

            # adjust gcc?
            for my $cc qw(cc cxx link ld) {
                $self->{$cc} .= '-m32';
            }

            # and lib flags
            for my $lib qw(
                ld_load_flags
                ld_share_flags
                ldflags
                linkflags
            ) {
                my $item = $self->{$lib};
                ( my $ni = $item ) =~ s/lib64/lib/g;
                $self->{$lib} = $ni;
            }
        }
    }
    # RT#41500 adjust lib install-path /lib64 vs. lib
    # remember corrected archname - jit.pm was using $Config('archname')
    $self->{archname} = $archname;
}

sub _find_perl_headers {
    my $self = shift;
    return File::Spec->catdir( $Config::Config{archlib}, 'CORE' );
}

1;

#################### DOCUMENTATION ####################

=head1 NAME

Parrot::Configure::Initialize::Defaults - Gather initial configuration data from command-line options, Perl 5 configuration and other system data

=head1 SYNOPSIS

    use Parrot::Configure::Initialize::Defaults;

=head1 DESCRIPTION

Parrot::Configure::Initialize:Defaults gathers initial configuration
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
