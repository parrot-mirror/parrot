# Copyright: 2005 The Perl Foundation.  All Rights Reserved.
# $Id$

package init::hints::mswin32;

use strict;

sub runstep
{
    my ($self, $conf) = @_;

    my ($cc, $ccflags, $libs) = $conf->data->get(qw(cc ccflags libs));

    # Later in the Parrot::Configure::RunSteps->runsteps process,
    # inter/progs.pl will merge the command-line overrides with the defaults.
    # We do one bit of its work early here, because we need the result now.
    $cc = $conf->options->get('cc') if defined $conf->options->get('cc');

    my $is_msvc  = grep { $cc eq $_ } (qw(cl cl.exe));
    my $is_intel = grep { $cc eq $_ } (qw(icl icl.exe));
    my $is_mingw = grep { $cc eq $_ } (qw(gcc gcc.exe));
    my $is_bcc   = grep { $cc eq $_ } (qw(bcc32 bcc32.exe));

    $conf->data->set(
        win32             => 1,
        PQ                => '"',
        make_c            => '$(PERL) -e "chdir shift @ARGV; system \'$(MAKE)\', @ARGV; exit $$? >> 8;"',
        ncilib_link_extra => '-def:src/libnci_test.def',
    );

    if ($is_msvc) {

        # Check the output of cl.exe to see if it contains the
        # string 'Standard' and remove the -O1 option if it does.
        # This will prevent the 'optimization is not available in the
        # standard edition compiler' warning each time we compile.
        # The logo gets printed to STDERR; hence the redirection.
        my $cc_output = `$cc /? 2>&1`;
        $ccflags =~ s/-O1 // if $cc_output =~ m/Standard/ || $cc_output =~ m{/ZI};
        $ccflags =~ s/-Gf/-GF/ if $cc_output =~ m/Version (\d+)/ && $1 >= 13;

        $conf->data->set(
            share_ext  => '.dll',
            load_ext   => '.dll',
            a          => '.lib',
            o          => '.obj',
            cc_o_out   => '-Fo',
            cc_exe_out => '-out:',
            cc_ldflags => '/link',

            # ZI messes with __LINE__
            cc_debug             => '-Zi',
            ld_debug             => '-debug',
            ld_share_flags       => '-dll -def:libparrot.def',
            ld_load_flags        => '-dll -def:libparrot.def',
            ld_out               => '-out:',
            ldflags              => '-nologo -nodefaultlib',
            libparrot_static     => 'libparrot_s'.$conf->data->get('a'),
            libparrot_shared     => 'libparrot_s$(SHARE_EXT)',
            ar_flags             => '',
            ar_out               => '-out:',
            slash                => '\\',
            blib_dir             => 'blib\\lib',
            ccflags              => $ccflags,
            ccwarn               => '',
            has_dynamic_linking  => 1
        );
        
        # We'll build shared by default.
        $conf->data->set('parrot_is_shared') = 1
            unless defined($conf->data->get('parrot_is_shared'));

        # 'link' needs to be link.exe, not cl.exe.
        # This makes 'link' and 'ld' the same.
        $conf->data->set(link => $conf->data->get('ld'));

        # We can't use -opt: and -debug together.
        if ($conf->data->get('ld_debug') =~ /-debug/) {
            my $linkflags = $conf->data->get('linkflags');
            $linkflags =~ s/-opt:\S+//;
            $conf->data->set(linkflags => $linkflags);
        }

        # We need to build a .def file to export parrot.exe symbols in a
        # static build and similarly to the shared lib otherwise.
        if ($conf->data->get('parrot_is_shared')) {
            $conf->data->set(
                ld_parrot_dll_def => '-def:parrot.def',
                parrot_dll_def    => 'parrot.def'
            );
        } else {
            $conf->data->set(
                ld_parrot_exe_def => '-def:parrot.def',
                parrot_exe_def    => 'parrot.def'
            );
        }

        # When building dynclasses we need to flag up the need to
        # mark shared variables with __declspec(dllimport).
        $conf->data->set(cc_building_dynclass_flag => '-DPARROT_BUILDING_WIN32_DLL');
    } elsif ($is_intel) {
        $conf->data->set(
            share_ext  => '.dll',
            load_ext   => '.dll',
            a          => '.lib',
            o          => '.obj',
            cc_o_out   => '-Fo',
            cc_exe_out => '-out:',
            cc_ldflags => '/link',

            # ZI messes with __LINE__
            cc_debug             => '-Zi',
            libs                 => "$libs libircmt.lib",
            ld                   => 'xilink',
            ld_debug             => '-debug',
            ld_share_flags       => '-dll -def:libparrot.def',
            ld_load_flags        => '-dll -def:libparrot.def',
            ld_out               => '-out:',
            ldflags              => '-nologo -nodefaultlib',
            ar                   => 'xilib',
            ar_flags             => '',
            ar_out               => '-out:',
            slash                => '\\',
            blib_dir             => 'blib\\lib',
            ccflags              => $ccflags,
            ccwarn               => '',
            has_dynamic_linking  => 1,
        );

        # 'link' needs to be xilink.exe, not icl.exe.
        # This makes 'link' and 'ld' the same.
        $conf->data->set(link => $conf->data->get('ld'));

        # We can't use -opt: and -debug together.
        if ($conf->data->get('ld_debug') =~ /-debug/) {
            my $linkflags = $conf->data->get('linkflags');
            $linkflags =~ s/-opt:\S+//;
            $conf->data->set(linkflags => $linkflags);
        }
    } elsif ($is_bcc) {
        $conf->data->set(
            o          => '.obj',
            a          => '.lib',
            share_ext  => '.dll',
            load_ext   => '.dll',
            cc         => ${cc},
            ccflags    => '-O2 -w-8066 -DWIN32 -DNO_STRICT -DNDEBUG -D_CONSOLE',
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

            ar       => 'tlib',
            ar_flags => '',
            ar_out   => '',
            ar_extra => '/au',
            slash    => '\\',
            blib_dir => 'blib\\lib',
            make_and => "\n\t",
        );
    } elsif ($is_mingw) {
        my $make = $conf->data->get(qw(make));
        if ($make =~ /nmake/i) {

            # ActiveState Perl or PXPerl
            $conf->data->set(
                a              => '.a',
                ar             => 'ar',
                cc             => 'gcc',
                ccflags        => '-DWIN32 ',
                ld             => 'g++',
                ld_load_flags  => '-shared ',
                ld_share_flags => '-shared ',
                ldflags        => '',
                libs           =>
                    '-lmsvcrt -lmoldname -lkernel32 -luser32 -lgdi32 -lwinspool -lcomdlg32 -ladvapi32 -lshell32 -lole32 -loleaut32 -lnetapi32 -luuid -lws2_32 -lmpr -lwinmm -lversion -lodbc32 ',
                link              => 'gcc',
                linkflags         => '',
                ncilib_link_extra => 'src/libnci_test.def',
                o                 => '.o',
                slash             => '\\',
                blib_dir          => 'blib\\lib',
            );
            if ($conf->data->get(qw(optimize)) eq "1") {
                $conf->data->set(optimize => '-O2');
            }
        } elsif ($make =~ /dmake/i) {

            # mingw Perl
            $conf->data->set(
                ld_load_flags     => '-shared ',
                ld_share_flags    => '-shared ',
                ncilib_link_extra => 'src/libnci_test.def',
            );
        } else {
            warn "unknown configuration";
        }

        # We need to build a .def file to export parrot.exe symbols.
        $conf->data->set(
            ld_parrot_exe_def => 'parrot.def',
            parrot_exe_def    => 'parrot.def',
            link_dynamic      => '-Wl,--out-implib,parrot.a',
        );

        # When building dynclasses we need to flag up the need to
        # mark shared variables with __declspec(dllimport).
        $conf->data->set(cc_building_dynclass_flag => '-DPARROT_BUILDING_WIN32_DLL');
    }
}

1;
