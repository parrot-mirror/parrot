# Copyright (C) 2005-2007, The Perl Foundation.
# $Id$

package init::hints::mswin32;

use strict;
use warnings;
use Win32;

sub runstep {
    my ( $self, $conf ) = @_;

    my $libs      = $conf->option_or_data('libs');
    my $ccflags   = $conf->option_or_data('ccflags');
    my $cc        = $conf->option_or_data('cc');

    # Later in the Parrot::Configure::RunSteps->runsteps process,
    # inter/progs.pl will merge the command-line overrides with the defaults.
    # We do one bit of its work early here, because we need the result now.
    $cc = $conf->options->get('cc') if defined $conf->options->get('cc');

    my $is_msvc  = grep { $cc eq $_ } (qw(cl cl.exe));
    my $is_intel = grep { $cc eq $_ } (qw(icl icl.exe));
    my $is_mingw = grep { $cc eq $_ } (qw(gcc gcc.exe));
    my $is_bcc   = grep { $cc eq $_ } (qw(bcc32 bcc32.exe));

    $conf->data->set(
        win32  => 1,
        PQ     => '"',
        make_c => '$(PERL) -e "chdir shift @ARGV; system \'$(MAKE)\', @ARGV; exit $$? >> 8;"',
        ncilib_link_extra => '-def:src/libnci_test.def',
    );

    my $build_dir = $conf->data->get('build_dir');

    if ( $build_dir =~ /\s/ ) {
        $conf->data->set( build_dir => Win32::GetShortPathName($build_dir) );
    }

    if ($is_msvc) {

        # Check the output of cl.exe to see if it contains the
        # string 'Standard' and remove the -O1 option if it does.
        # This will prevent the 'optimization is not available in the
        # standard edition compiler' warning each time we compile.
        # The logo gets printed to STDERR; hence the redirection.
        my $cc_output = `$cc /? 2>&1` || '';
        $ccflags =~ s/-O1 // if $cc_output =~ m/Standard/ || $cc_output =~ m{/ZI};
        $ccflags =~ s/-Gf/-GF/ if $cc_output =~ m/Version (\d+)/ && $1 >= 13;

        # override perl's warnings level
        $ccflags =~ s/-W\d/-W4/;
        $ccflags .= " -Wp64 ";

        my $ccwarn = '';

        # disable certain very noisy warnings
        $ccwarn .= "-wd4127 ";    # conditional expression is constant
        $ccwarn .= "-wd4054 ";    # type cast from function ptr to data ptr
        $ccwarn .= "-wd4310 ";    # cast truncates constant value

        $conf->data->set(
            share_ext  => '.dll',
            load_ext   => '.dll',
            a          => '.lib',
            o          => '.obj',
            cc_o_out   => '-Fo',
            cc_exe_out => '-out:',
            cc_ldflags => '/link',

            make_c => q{$(PERL) -e "chdir shift @ARGV;}
                . q{system '$(MAKE)', '-nologo', @ARGV; exit $$? >> 8;"},
            make => 'nmake',

            # ZI messes with __LINE__
            cc_debug            => '-Zi',
            ld_debug            => '-debug',
            ld_share_flags      => '-dll',
            ld_load_flags       => '-dll',
            ld_out              => '-out:',
            ldflags             => '-nologo -nodefaultlib',
            libs                => 'kernel32.lib ws2_32.lib msvcrt.lib oldnames.lib ',
            libparrot_static    => 'libparrot' . $conf->data->get('a'),
            libparrot_shared    => 'libparrot$(SHARE_EXT)',
            ar_flags            => '',
            ar_out              => '-out:',
            slash               => '\\',
            blib_dir            => 'blib\\lib',
            ccflags             => $ccflags,
            ccwarn              => $ccwarn,
            has_dynamic_linking => 1,
            parrot_is_shared    => 1,

            sym_export => '__declspec(dllexport)',
            sym_import => '__declspec(dllimport)'
        );

        # If we are building shared, need to include dynamic libparrot.lib, otherwise
        # the static libparrot.lib.
        if ( $conf->data->get('parrot_is_shared') ) {
            $conf->data->set( libparrot_ldflags => 'libparrot.lib' );
        }

        # 'link' needs to be link.exe, not cl.exe.
        # This makes 'link' and 'ld' the same.
        $conf->data->set( link => $conf->data->get('ld') );

        # We can't use -opt: and -debug together.
        if ( $conf->data->get('ld_debug') =~ /-debug/ ) {
            my $linkflags = $conf->option_or_data('linkflags');
            $linkflags =~ s/-opt:\S+//;
            $conf->data->set( linkflags => $linkflags );
        }
    }
    elsif ($is_intel) {
        $conf->data->set(
            share_ext  => '.dll',
            load_ext   => '.dll',
            a          => '.lib',
            o          => '.obj',
            cc_o_out   => '-Fo',
            cc_exe_out => '-out:',
            cc_ldflags => '/link',

            # ZI messes with __LINE__
            cc_debug            => '-Zi',
            libs                => "$libs libircmt.lib",
            ld                  => 'xilink',
            ld_debug            => '-debug',
            ld_share_flags      => '-dll',
            ld_load_flags       => '-dll',
            ld_out              => '-out:',
            ldflags             => '-nologo -nodefaultlib',
            ar                  => 'xilib',
            ar_flags            => '',
            ar_out              => '-out:',
            slash               => '\\',
            blib_dir            => 'blib\\lib',
            ccflags             => $ccflags,
            ccwarn              => '',
            has_dynamic_linking => 1
        );

        # 'link' needs to be xilink.exe, not icl.exe.
        # This makes 'link' and 'ld' the same.
        $conf->data->set( link => $conf->data->get('ld') );

        # We can't use -opt: and -debug together.
        if ( $conf->data->get('ld_debug') =~ /-debug/ ) {
            my $linkflags = $conf->option_or_data('linkflags');
            $linkflags =~ s/-opt:\S+//;
            $conf->data->set( linkflags => $linkflags );
        }
    }
    elsif ($is_bcc) {
        $conf->data->set(
            o         => '.obj',
            a         => '.lib',
            share_ext => '.dll',
            load_ext  => '.dll',
            cc        => ${cc},
            ccflags =>
                '-O2 -w-8066 -DWIN32 -DNO_STRICT -DNDEBUG -D_CONSOLE -w-par -w-aus -w-ccc -w-rch',
            cc_o_out   => '-o',
            cc_exe_out => '-e',
            cc_debug   => '-v',

            ld             => ${cc},
            ldflags        => '',
            ld_out         => '-e',
            cc_ldflags     => '',
            ld_debug       => '-v',
            ld_share_flags => '-WD',
            ld_load_flags  => '-WD',
            libs           => 'import32.lib cw32.lib',

            link      => ${cc},
            linkflags => '',

            ar       => 'tlib /a /P128',
            ar_flags => '',
            ar_out   => '',
            ar_extra => '',
            slash    => '\\',
            blib_dir => 'blib\\lib',
            make_and => "\n\t",
        );
    }
    elsif ($is_mingw) {
        my $make = $conf->data->get(qw(make));
        if ( $make =~ /nmake/i ) {

            # ActiveState Perl or PXPerl
            $conf->data->set(
                a       => '.a',
                ar      => 'ar',
                cc      => 'gcc',
                ccflags => '-DWIN32 ',
                ld      => 'g++',
                ldflags => '',
                libs =>
'-lmsvcrt -lmoldname -lkernel32 -luser32 -lgdi32 -lwinspool -lcomdlg32 -ladvapi32 -lshell32 -lole32 -loleaut32 -lnetapi32 -luuid -lws2_32 -lmpr -lwinmm -lversion ',
                link      => 'gcc',
                linkflags => '',
                o         => '.o',
                blib_dir  => 'blib\\lib',
            );
            if ( $conf->data->get(qw(optimize)) eq "1" ) {
                $conf->data->set( optimize => '-O2' );
            }
        }
        elsif ( $make =~ /dmake/i ) {

            # mingw Perl
        }
        else {
            warn "unknown configuration";
        }

        $conf->data->set(
            parrot_is_shared    => 1,
            has_dynamic_linking => 1,
            ld_load_flags       => '-shared ',
            ld_share_flags      => '-shared ',
            libparrot_ldflags   => $conf->data->get('build_dir') . '/libparrot.dll',
            ncilib_link_extra   => 'src/libnci_test.def',
            sym_export          => '__declspec(dllexport)',
            sym_import          => '__declspec(dllimport)',
            make                => 'mingw32-make',
            make_c              => 'mingw32-make -C',
            slash               => '\\',
        );
    }
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
