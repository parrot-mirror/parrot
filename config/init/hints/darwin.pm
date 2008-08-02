# Copyright (C) 2005, The Perl Foundation.
# $Id$

package init::hints::darwin;

use strict;
use warnings;

our %defaults = (
    uname   => `uname -r`,
    sw_vers => `sw_vers -productVersion`,
);

sub runstep {
    my ( $self, $conf ) = @_;

    my $verbose = $conf->options->get('verbose');

    # @flags is the list of options that have -arch flags added to them
    # implicitly through config/init/defaults.pm when using Apple's Perl
    # 5.8 build to run Configure.pl (it's a multi-architecture build).
    # This doesn't play nice with getting parrot to build on PPC systems
    # and causes all sorts of fun issues with lipo and friends.  So, it's
    # time to remove all -arch flags set in $conf->data that haven't been
    # requested by command-line options and force a single, native
    # architecture to being the default build.
    my @flags = qw(ccflags linkflags ldflags ld_share_flags ld_load_flags);
    my @arches = qw(i386 ppc64 ppc x86_64);

    print "\nChecking for -arch flags not explicitly added:\n" if $verbose;
    for my $flag (@flags) {
        my $set_flags =  _get_adjusted_user_options($conf, $flag);

        my $stored = $conf->data->get($flag) || '';

#        if ($verbose) {
#            print "Checking $flag...\n";
#            print "User-specified: " . ($set_flags || '(nil)') . "\n";
#            print "Pre-check: " . ($stored || '(nil)') . "\n";
#        }
        _precheck($flag, $set_flags, $stored, $verbose);

        for my $arch (@arches) {
            if (!$set_flags || $set_flags !~ /(?:^|\W)-arch\s+$arch(?:\W|$)/) {
                $stored =~ s/-arch\s+$arch//g;
                $conf->data->set($flag => $stored);
            }
        }
        _postcheck($conf, $flag, $verbose);
    }
    # And now, after possibly losing a few undesired compiler and linker
    # flags, on to the main Darwin config.

    my ( $ccflags, $ldflags, $libs ) =
        $conf->data->get(qw(ccflags ldflags libs));

    $libs = _strip_ldl_as_needed($libs);

    _set_deployment_environment();

    my $lib_dir = $conf->data->get('build_dir') . "/blib/lib";
    $ldflags .= " -L$lib_dir";
    $ccflags .= " -pipe -fno-common -Wno-long-double ";

    $conf->data->set(
        darwin              => 1,
        osx_version         => $ENV{'MACOSX_DEPLOYMENT_TARGET'},
        ccflags             => $ccflags,
        ldflags             => $ldflags,
        ccwarn              => "-Wno-shadow",
        libs                => $libs,
        share_ext           => '.dylib',
        load_ext            => '.bundle',
        link                => 'c++',
        linkflags           => '-undefined dynamic_lookup',
        ld                  => 'c++',
        ld_share_flags      => '-dynamiclib -undefined dynamic_lookup',
        ld_load_flags       => '-undefined dynamic_lookup -bundle',
        memalign            => 'some_memalign',
        has_dynamic_linking => 1,

        # RT 43147:  When built against a dynamic libparrot,
        # installable_parrot records the path to the blib version 
        # of the library.
        
        parrot_is_shared       => 1,
        libparrot_shared       => 'libparrot.$(SOVERSION)$(SHARE_EXT)',
        libparrot_shared_alias => 'libparrot$(SHARE_EXT)',
        rpath                  => "-L",
        libparrot_soname       => "-install_name "
            . $lib_dir
            . $conf->data->get('slash')
            . "libparrot"
            . $conf->data->get('share_ext')
    );
}

sub _get_adjusted_user_options {
    my ($conf, $flag) = @_;
    my $set_flags = q{};
    if ($flag =~ /^ld/) {
        $set_flags = $conf->options->get('ldflags') || '';
    }
    else {
        $set_flags = $conf->options->get($flag) || '';
    }
    return $set_flags;
}

sub _precheck {
    my ($flag, $set_flags, $stored, $verbose) = @_;
    if ($verbose) {
        print "Checking $flag...\n";
        print "User-specified: " . ($set_flags || '(nil)') . "\n";
        print "Pre-check: " . ($stored || '(nil)') . "\n";
    }
}

sub _postcheck {
    my ($conf, $flag, $verbose) = @_;
    if ($verbose) {
        print "Post-check: ", ( $conf->data->get($flag) or '(nil)' ), "\n";
    }
}

sub _strip_ldl_as_needed {
    my $libs = shift;
    my $OSVers = $defaults{uname};
    chomp $OSVers;
    {
        local $^W;
        $OSVers =~ /(\d+)/;
        if ( $1 >= 7 ) {
            $libs =~ s/-ldl//;
        }
    }
    return $libs;
}

sub _set_deployment_environment {
    unless (defined $ENV{'MACOSX_DEPLOYMENT_TARGET'}) {
        my $OSX_vers = $defaults{sw_vers};
        chomp $OSX_vers;
        # remove minor version
        $OSX_vers =join '.', (split /[.]/, $OSX_vers)[0,1];
        $ENV{'MACOSX_DEPLOYMENT_TARGET'} = $OSX_vers;
    }
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
