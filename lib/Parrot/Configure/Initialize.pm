# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$
package Parrot::Configure::Initialize;
use strict;
use warnings;
use base qw( Exporter );
our @EXPORT_OK = qw(
    get_data_from_prompts
);
use Carp;
use Config;
use FindBin;    # see build_dir
use lib ( "./lib" );
use Parrot::Configure::Step;
use Parrot::BuildUtil;
use Cwd qw(abs_path);
use File::Spec;

################### SUBROUTINES ###################

sub get_data_from_prompts {
    my $options_ref = shift;
    croak "Argument to get_data_from_prompts() must be hash ref"
        unless ref($options_ref) eq 'HASH';
    print <<'END';


    Okay, I'm going to start by asking you a couple questions about your
    compiler and linker.  Default values are in square brackets; you can
    hit ENTER to accept them.  If you don't understand a question, the
    default will usually work--they've been intuited from your Perl 5
    configuration.

END
# To provide the user with proper selections for the prompts, we have to
# do much of the initialization we would normally do in steps like
# init::defaults.  Examples:  reading in values from the Perl 5 Config.
# We'll eventually abstract this into a module, but for now we'll do an
# _init routine.


}

sub _init_from_options {
    my $options_ref = shift;
}

#sub _init {
#    my $options_ref = shift;
#    my %init = (
#        debugging => $options_ref->{debugging} ? 1 : 0,
#        optimize  => '',
#        verbose   => $options_ref->{verbose},
#        build_dir => abs_path($FindBin::Bin),
#
#        # Compiler -- used to turn .c files into object files.
#        # (Usually cc or cl, or something like that.)
#        cc      => $Config{cc},
#        ccflags => $Config{ccflags},
#        ccwarn  => exists( $Config{ccwarn} ) ? $Config{ccwarn} : '',
#
#        # Flags used to indicate this object file is to be compiled
#        # with position-independent code suitable for dynamic loading.
#        cc_shared => $Config{cccdlflags},    # e.g. -fpic for GNU cc.
#
#        # C++ compiler -- used to compile parts of ICU.  ICU's configure
#        # will try to find a suitable compiler, but it prefers GNU c++ over
#        # a system c++, which might not be appropriate.  This setting
#        # allows you to override ICU's guess, but is otherwise currently
#        # unset.  Ultimately, it should be set to whatever ICU figures
#        # out, or parrot should look for it and always tell ICU what to
#        # use.
#        cxx => 'c++',
#
#        # Linker, used to link object files (plus libraries) into
#        # an executable.  It is usually $cc on Unix-ish systems.
#        # VMS and Win32 might use "Link".
#        # Perl5's Configure doesn't distinguish linking from loading, so
#        # make a reasonable guess at defaults.
#        link      => $Config{cc},
#        linkflags => $Config{ldflags},
#
#        # Linker Flags to have this binary work with the shared and dynamically
#        # loadable libraries we're building.  On HP-UX, for example, we need to
#        # allow dynamic libraries to access the binary's symbols
#        link_dynamic => $Config{ccdlflags},    # e.g. -Wl,-E on HP-UX
#
#        # ld: Tool used to build shared libraries and dynamically loadable
#        # modules. Often $cc on Unix-ish systems, but apparently sometimes
#        # it's ld.
#        ld      => $Config{ld},
#        ldflags => $Config{ldflags},
#
#        # Some operating systems (e.g. Darwin) distinguish between shared
#        # libraries and modules that can be dynamically loaded.  Flags to tell
#        # ld to build a shared library, e.g.  -shared for GNU ld.
#        ld_share_flags => $Config{lddlflags},
#
#        # Flags to tell ld to build a dynamically loadable module, e.g.
#        # -shared for GNU ld.
#        ld_load_flags => $Config{lddlflags},
#
#        libs => $Config{libs},
#
#        cc_inc     => "-I./include",
#        cc_debug   => '-g',
#        link_debug => '',
#
#        o         => $Config{_o},       # object files extension
#        share_ext => ".$Config{so}",    # shared library extension
#
#        # dynamically loadable module extension
#        load_ext => ".$Config{so}",
#        a        => $Config{_a},        # library or archive extension
#        exe      => $Config{_exe},      # executable files extension
#        cc_o_out => '-o ',              # cc object output file
#
#        # cc executable output file (different on Win32)
#        cc_exe_out => '-o ',
#
#        # prefix for ldflags (necessary for Win32)
#        cc_ldflags => '',
#
#        # ld output file.  Keep the trailing space.
#        ld_out => '-o ',
#
#        # include debug info in executable
#        ld_debug => '',
#
#        # Way to decorate a function to mark it as an exportable or
#        # importable symbol.
#        sym_export => '',
#        sym_import => '',
#
#        # Library build directory
#        blib_dir => 'blib/lib',
#
#        # libparrot library names
#        libparrot_static => 'libparrot' . $Config{_a},
#        libparrot_shared => 'libparrot.' . $Config{so},
#
#        # does the system know about static/dynamic linking?
#        has_static_linking  => 1,
#        has_dynamic_linking => 0,
#
#        # default behaviour for linking parrot to a static or shared libparrot
#        parrot_is_shared => 0,
#
#        #avoid a warning during Configure.pl
#        libparrot_soname => '',
#
#        perl      => $^X,
#        perl_inc  => $self->find_perl_headers(),
#        test_prog => 'parrot',
#        rm_f      => '$(PERL) -MExtUtils::Command -e rm_f',
#        rm_rf     => '$(PERL) -MExtUtils::Command -e rm_rf',
#        mkpath    => '$(PERL) -MExtUtils::Command -e mkpath',
#        touch     => '$(PERL) -MExtUtils::Command -e touch',
#        chmod     => '$(PERL) -MExtUtils::Command -e ExtUtils::Command::chmod',
#        ar        => $Config{ar},
#        ar_flags  => 'cr',
#
#        # for Win32
#        ar_out => '',
#
#        # for Borland C
#        ar_extra      => '',
#        ranlib        => $Config{ranlib},
#        rpath         => '',
#        make          => $Config{make},
#        make_set_make => $Config{make_set_make},
#        make_and      => '&&',
#
#        # make_c: Command to emulate GNU make's C<-C directory> option:  chdir
#        # to C<directory> before executing $(MAKE)
#        make_c => '$(PERL) -e \'chdir shift @ARGV; system q{$(MAKE)}, @ARGV; exit $$? >> 8;\'',
#
#        # if platform has a .s file that needs to be assembled
#        platform_asm => 0,
#        as           => 'as',    # assembler
#
#        cp    => '$(PERL) -MExtUtils::Command -e cp',
#        lns   => $Config{lns},                          # soft link
#        slash => '/',
#
#        VERSION => $parrot_version,
#        MAJOR   => $parrot_version[0],
#        MINOR   => $parrot_version[1],
#        PATCH   => $parrot_version[2],
#        DEVEL   => ( -e 'DEVELOPING' ? '-devel' : '' ),
#
#        configdate => scalar gmtime() . " GMT",
#        PQ         => "'",
#        dquote     => "\\\"",
#
#        # yacc = Automatic parser generator
#        # lex  = Automatic lexer  generator
#        # Some systems may lack these
#        yacc => 'bison -v -y',
#        lex  => 'flex',
#
#        # Extra flags needed for libnci_test.so
#        ncilib_link_extra => '',
#
#    );
#    # add profiling if needed
#    # RT#41497 gcc syntax
#    # we should have this in the hints files e.g. cc_profile
#    # RT#41496 move profiling to it's own step
#    if ( $conf->options->get('profile') ) {
#        $conf->data->set(
#            cc_debug => " -pg ",
#            ld_debug => " -pg ",
#        );
#    }
#
#    # adjust archname, cc and libs for e.g. --m=32
#    # RT#41499 this is maybe gcc only
#    my $m        = $conf->options->get('m');
#    my $archname = $Config{archname};
#    if ($m) {
#        if ( $archname =~ /x86_64/ && $m eq '32' ) {
#            $archname =~ s/x86_64/i386/;
#
#            # adjust gcc?
#            for my $cc qw(cc cxx link ld) {
#                $conf->data->add( ' ', $cc, '-m32' );
#            }
#
#            # and lib flags
#            for my $lib qw(ld_load_flags ld_share_flags ldflags linkflags) {
#                my $item = $conf->data->get($lib);
#                ( my $ni = $item ) =~ s/lib64/lib/g;
#                $conf->data->set( $lib, $ni );
#            }
#        }
#    }
#
#    # RT#41500 adjust lib install-path /lib64 vs. lib
#    # remember corrected archname - jit.pm was using $Config('archname')
#    $conf->data->set( 'archname', $archname );
#
#    return 1;
#}

sub find_perl_headers {
    my $self = shift;
    return File::Spec->catdir( $Config::Config{archlib}, 'CORE' );
}

1;

#################### DOCUMENTATION ####################

=head1 NAME

Parrot::Configure::Initialize - Gather initial configuration data from
command-line options, Perl 5 configuration and other system data

=head1 SYNOPSIS

    use Parrot::Configure::Initialize;

    my $init = Parrot::Configure::Initialize->new($args);

=head1 DESCRIPTION

Parrot::Configure::Initialize gathers initial configuration data from
command-line options, Perl 5 c<%Config> and other readily available
sources.  It makes this data available to other packages such as
Parrot::Configure::Interactive (so that correct prompts can be offered
to the user) and to config::init::defaults.

=head1 SUBROUTINES

=head2 C<new()>

=over 4

=item * Purpose

Parrot::Configure::Initialize constructor.

=item * Arguments

One argument:  The hash reference which is the output of
C<Parrot::Configure::Options::process_options>.  This is a list of
key-value pairs reflecting the results of processing of command-line
options.

=item * Return Value

Hash reference holding list of key-value pairs suitable for insertion
into Parrot::Configure object via C<$conf->data->set()>.

=item * Comment

=back

=head1 NOTES

The functionality in this package was transferred from the former
C<init::defaults> configuration steps by Jim Keenan.

=head1 SEE ALSO

F<Configure.pl>.  Parrot::Configure.  Parrot::Configure::Interactive.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
