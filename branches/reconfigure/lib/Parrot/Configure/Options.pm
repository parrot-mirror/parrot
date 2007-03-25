# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$
package Parrot::Configure::Options;
use strict;
use warnings;
use base qw( Exporter );
our @EXPORT_OK = qw( process_options );

my @valid_opts = qw(ask bindir cage cc ccflags ccwarn cgoto cxx datadir
    debugging define exec-prefix execcapable floatval gc help icu-config
    icudatadir icuheaders icushared includedir infodir inline intval
    jitcapable ld ldflags lex libdir libexecdir libs link linkflags
    localstatedir m maintainer mandir miniparrot nomanicheck oldincludedir
    opcode ops optimize parrot_is_shared pmc prefix profile sbindir
    sharedstatedir step sysconfdir verbose verbose-step=N version without-gdbm
    without-gmp without-icu yacc);

sub process_options {
    my $argsref = shift;
    my %args;
    for (@{$argsref->{argv}}) {
        my ( $key, $value ) = m/--([-\w]+)(?:=(.*))?/;
        $key   = 'help' unless defined $key;
        $value = 1      unless defined $value;
    
        unless ( grep $key eq $_, @valid_opts ) {
            die qq/Invalid option $key. See "perl Configure.pl --help" for valid options\n/;
        }
    
        for ($key) {
            if ($key =~ m/version/) {
#                print_version_info($argsref->{parrot_version});
                print_version_info($argsref);
                exit;
            }
    
            if ($key =~ m/help/) {
#                print_help($argsref->{script});
                print_help($argsref);
                exit;
            }
            $args{$key} = $value;
        }
    }
    
    $args{debugging} = 1
        unless ( ( exists $args{debugging} ) && !$args{debugging} );
    $args{maintainer} = 1 if defined $args{lex} or defined $args{yacc};
    return \%args;
}

################### SUBROUTINES ###################

sub print_version_info {
#    my $parrot_version = shift;
#    my $svnid = '$Id$';
#    print "Parrot Version $parrot_version Configure 2.0\n";
#    print "$svnid\n";
    my $argsref = shift;
    print "Parrot Version $argsref->{parrot_version} Configure 2.0\n";
    print "$argsref->{svnid}\n";
}

sub print_help {
    my $argsref = shift;
    print <<"EOT";
$argsref->{script} - Parrot Configure 2.0

General Options:

   --help               Show this text
   --version            Show version information
   --verbose            Output extra information
   --verbose=2          Output every setting change
   --verbose-step=N     Set verbose for step N only
   --verbose-step=regex Set verbose for step matching description
   --nomanicheck        Don't check the MANIFEST
   --step=(gen::languages)
                        Execute a single configure step

   --ask                Have Configure ask for commonly-changed info

Compile Options:

   --debugging=0        Disable debugging, default = 1
   --inline             Compiler supports inline
   --optimize           Optimized compile
   --optimize=flags     Add given optimizer flags
   --parrot_is_shared   Link parrot dynamically
   --m=32               Build 32bit executable on 64-bit architecture.
   --profile            Turn on profiled compile (gcc only for now)
   --cage               [CAGE] compile includes many additional warnings

   --cc=(compiler)      Use the given compiler
   --ccflags=(flags)    Use the given compiler flags
   --ccwarn=(flags)     Use the given compiler warning flags
   --cxx=(compiler)     Use the given C++ compiler
   --libs=(libs)        Use the given libraries
   --link=(linker)      Use the given linker
   --linkflags=(flags)  Use the given linker flags
   --ld=(linker)        Use the given loader for shared libraries
   --ldflags=(flags)    Use the given loader flags for shared libraries
   --lex=(lexer)        Use the given lexical analyzer generator
   --yacc=(parser)      Use the given parser generator

   --define=inet_aton   Quick hack to use inet_aton instead of inet_pton

Parrot Options:

   --intval=(type)      Use the given type for INTVAL
   --floatval=(type)    Use the given type for FLOATVAL
   --opcode=(type)      Use the given type for opcodes
   --ops=(files)        Use the given ops files
   --pmc=(files)        Use the given PMC files

   --cgoto=0            Don't build cgoto core - recommended when short of mem
   --jitcapable         Use JIT
   --execcapable        Use JIT to emit a native executable
   --gc=(type)          Determine the type of garbage collection
                        type=(gc|libc|malloc|malloc-trace) default is gc

External Library Options:

   --without-gmp        Build parrot without GMP support
   --without-gdbm       Build parrot without GDBM support

ICU Options:

   For using a system ICU, these options can be used:

   --icu-config=/path/to/icu-config
                        Location of the script used for ICU autodetection.
                        You just need to specify this option if icu-config
                        is not in you PATH.

   --icu-config=none    can be used to disable the autodetection feature.
                        It will also be disabled if you specify any other
                        of the following ICU options.

   If you do not have a full ICU installation:

   --without-icu        Build parrot without ICU support
   --icuheaders=(path)  Location of ICU headers without /unicode
   --icushared=(flags)  Full linker command to create shared libraries
   --icudatadir=(path)  Directory to locate ICU's data file(s)

Other Options (may not be implemented):

   --maintainer         Create imcc's parser and lexer files. Needs a working
                        parser and lexer.
   --miniparrot         Build parrot assuming only pure ANSI C is available

Install Options:

    --prefix=PREFIX         install architecture-independent files in PREFIX
                            [/usr/local]
    --exec-prefix=EPREFIX   install architecture-dependent files in EPREFIX
                            [PREFIX]

    By default, `make install' will install all the files in
    `/usr/local/bin', `/usr/local/lib' etc.  You can specify
    an installation prefix other than `/usr/local' using `--prefix',
    for instance `--prefix=\$HOME'.

    For better control, use the options below.

    Fine tuning of the installation directories:
    --bindir=DIR            user executables [EPREFIX/bin]
    --sbindir=DIR           system admin executables [EPREFIX/sbin]
    --libexecdir=DIR        program executables [EPREFIX/libexec]
    --datadir=DIR         read-only architecture-independent data [PREFIX/share]
    --sysconfdir=DIR        read-only single-machine data [PREFIX/etc]
    --sharedstatedir=DIR   modifiable architecture-independent data [PREFIX/com]
    --localstatedir=DIR     modifiable single-machine data [PREFIX/var]
    --libdir=DIR            object code libraries [EPREFIX/lib]
    --includedir=DIR        C header files [PREFIX/include]
    --oldincludedir=DIR     C header files for non-gcc [/usr/include]
    --infodir=DIR           info documentation [PREFIX/info]
    --mandir=DIR            man documentation [PREFIX/man]

EOT
};

1;

#################### DOCUMENTATION ####################

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

=head1 SEE ALSO

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
