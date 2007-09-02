# Copyright (C) 2005-2007, The Perl Foundation.
# $Id$

package init::hints::linux;

use strict;
use warnings;

use Config;

sub runstep {
    my ( $self, $conf ) = @_;

    my $libs        = $conf->option_or_data('libs');
    my $cc_flags    = $conf->option_or_data('ccflags');
    my $cc          = $conf->option_or_data('cc');
    my $linkflags   = $conf->option_or_data('linkflags');

    # should find g++ in most cases
    my $link = $conf->data->get('link') || 'c++';

    if ( $libs !~ /-lpthread/ ) {
        $libs .= ' -lpthread';
    }
    my $ld_share_flags = $conf->data->get('ld_share_flags');
    my $cc_shared      = $conf->data->get('cc_shared');

    if ( $cc =~ /icc/ ) {
        # Intel C++ compiler has the same name as its C compiler
        $link = $cc;

        # don't allow icc to pretend it's gcc
        $cc_flags .= ' -no-gcc';

        # suppress sprintf warnings that don't apply
        $cc_flags .= ' -wd269';

        $cc_flags .= ' -Wall -Wcheck -w2';

        $ld_share_flags = ' -shared -g -pipe -fexceptions -fPIC';
        $cc_shared .= ' -fPIC';
    }
    elsif ( $cc =~ /suncc/ ) {
        $link = 'sunCC';
        if ( $ld_share_flags !~ /-KPIC/ ) {
            $ld_share_flags = '-KPIC';
        }
        if ( $cc_shared !~ /-KPIC/ ) {
            $cc_shared = '-KPIC';
        }
    }
    else {
        if ( $ld_share_flags !~ /-fPIC/ ) {
            $ld_share_flags .= ' -fPIC';
        }
        if ( $cc_shared !~ /-fPIC/ ) {
            $cc_shared .= ' -fPIC';
        }

        # --export-dynamic, s. info gcc, ld
        $linkflags .= ' -Wl,-E';
    }

    if ( $cc_flags !~ /-D_GNU_SOURCE/ ) {

        # Request visibility of all POSIX symbols
        # _XOPEN_SOURCE=600 doesn't work with glibc 2.1.3
        # _XOPEN_SOURCE=500 gives 2 undefined warns (setenv, unsetenv) on 2.1.3
        $cc_flags .= ' -D_GNU_SOURCE';
    }

    ### XXX This is a dummy callback to test callbacks.
    ### This is for debugging purposes only and is not expected to work.
    ### Suggested by Andy Dougherty.
    ### Cf: http://rt.perl.org/rt3/Ticket/Display.html?id=45025
    # Run the gcc version test to see if $cc is really gcc.
    my $linux_link_cb = sub {
        use Parrot::Configure::Step qw(cc_gen cc_run);
        use Carp;
        my ( $key, $cc ) = @_;
        my %gnuc;
        my $link = $conf->data->get('link');
        cc_gen("config/auto/gcc/test_c.in");

        # Can't call cc_build since we haven't set all the flags yet.
        # This should suffice for this test.
        my $cc_inc = $conf->data->get('cc_inc');
        Parrot::Configure::Step::_run_command( "$cc -o test test.c $cc_inc", 'test.cco', 'test.cco' )
            and confess "C compiler failed (see test.cco)";
        %gnuc = eval cc_run() or die "Can't run the test program: $!";
        if ( defined $gnuc{__GNUC__} ) {
            # $link = 'g++';  # don't actually set it in this test function.
       $conf->data->set( link => $link );
        }
        else {
            # Don't know what compiler we have, so don't touch $link.
        }
        $conf->data->deltrigger( "cc", "linux_link" );
    };
    $conf->data->settrigger( "cc", "linux_link", $linux_link_cb );
    ### XXX End of dummy callback to test callbacks

    $conf->data->set(
        ccflags        => $cc_flags,
        libs           => $libs,
        ld_share_flags => $ld_share_flags,
        ld_load_flags  => $ld_share_flags,
        i_lib_pthread  => 1,                 # RT#43149 fake a header entry
        linkflags      => $linkflags,
        link           => $link,
        cc_shared      => $cc_shared,
        rpath          => '-Wl,-rpath=',

        has_dynamic_linking    => 1,
        parrot_is_shared       => 1,
        libparrot_shared       => 'libparrot$(SHARE_EXT).$(SOVERSION)',
        libparrot_shared_alias => 'libparrot$(SHARE_EXT)',
        libparrot_soname       => '-Wl,-soname=libparrot$(SHARE_EXT).$(SOVERSION)',
    );

    if ( ( split( '-', $Config{archname} ) )[0] eq 'ia64' ) {
        $conf->data->set( platform_asm => 1 );
    }
    return;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
