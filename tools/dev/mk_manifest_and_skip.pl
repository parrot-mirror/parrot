#! perl
# $Id$

=head1 NAME

tools/dev/mk_manifest_and_skip.pl - Recreate MANIFEST and MANIFEST.SKIP

=head1 SYNOPSIS

    % perl tools/dev/mk_manifest_and_skip.pl

=head1 DESCRIPTION

Recreates MANIFEST and MANIFEST.SKIP from the svn directories.  So far tested
with svn 1.2.0.

=cut

package main;

use strict;
use warnings;

use File::Find;

my @dirs;  # will be filled in wanted

# XXX Most of these can probably be cleaned up
my %special = qw(
    NEWS                                            [devel]doc
    PBC_COMPAT                                      [devel]doc
    PLATFORMS                                       [devel]doc
    README                                          [devel]doc
    README.win32.pod                                [devel]doc
    README.win32.pod                                [devel]doc
    RESPONSIBLE_PARTIES                             [main]doc
    TODO                                            [main]doc
    parrot-config                                   [main]bin
    docs/BROKEN.pod                                 [devel]doc
    docs/ROADMAP.pod                                [devel]doc
    docs/compiler_faq.pod                           [devel]doc
    docs/configuration.pod                          [devel]doc
    docs/debug.pod                                  [devel]doc
    docs/dev/dod.pod                                [devel]doc
    docs/dev/events.pod                             [devel]doc
    docs/dev/fhs.pod                                [devel]doc
    docs/dev/infant.pod                             [devel]doc
    docs/dev/pmc_freeze.pod                         [devel]doc
    examples/sdl/anim_image.pir                     [devel]
    examples/sdl/anim_image_dblbuf.pir              [devel]
    examples/sdl/blue_font.pir                      [devel]
    examples/sdl/blue_rect.pir                      [devel]
    examples/sdl/bounce_parrot_logo.pir             [devel]
    examples/sdl/lcd/clock.pir                      [devel]
    examples/sdl/move_parrot_logo.pir               [devel]
    examples/sdl/parrot_small.png                   [devel]
    examples/sdl/raw_pixels.pir                     [devel]
    languages/t/harness                             []
    runtime/parrot/dynext/README                    [devel]doc
    runtime/parrot/include/DWIM.pir                 [devel]doc
    runtime/parrot/include/README                   [devel]doc
    src/call_list.txt                               [devel]doc
    src/ops/ops.num                                 [devel]
    tools/build/ops2c.pl                            [devel]
    tools/build/ops2pm.pl                           [devel]
    tools/build/pbc2c.pl                            [devel]
    tools/build/revision_c.pl                       [devel]
    vtable.tbl                                      [devel]
);

open my $MANI, '>', 'MANIFEST';
print $MANI '# $' . 'Id' . '$' . "\n";  # confuse SVN
print $MANI "#\n"; 
print $MANI '# generated by tools/dev/mk_manifest_and_skip.pl ', scalar( gmtime() ), " UT\n";
print $MANI <<'END_HEADER';
#
# See tools/dev/install_files.pl for documentation on the
# format of this file.
# See docs/submissions.pod on how to recreate this file after SVN
# has been told about new or deleted files.
END_HEADER

open my $SKIP, '>', 'MANIFEST.SKIP';
print $SKIP '# $' . 'Id' . '$' . "\n";  # confuse SVN
print $SKIP "#\n"; 
print $SKIP '# generated by tools/dev/mk_manifest_and_skip.pl ', scalar( gmtime() ), " UT\n";
print $SKIP <<'END_HEADER';
#
# This file should contain a transcript of the svn:ignore properties
# of the directories in the Parrot subversion repository. (Needed for
# distributions or in general when svn is not available).
# See docs/submissions.pod on how to recreate this file after SVN
# has been told about new generated files.
#
# Ignore the SVN directories
\B\.svn\b

# debian/ should not go into release tarballs
^debian$
^debian/
END_HEADER

my @MANI = ();
find(\&wanted, '.');
print $MANI $_ for (sort @MANI);

my $svnignore = `svn propget svn:ignore @dirs`;
my %ignore;
my @ignore = split( /\n\n/, $svnignore );
foreach (@ignore) {
    my @cnt = m/( - )/g;
    if ($#cnt) {
        my @a = split /\n(?=(?:.*?) - )/, $_;
        foreach (@a) {
            m/^\s*(.*?) - (.+)/sm;
            $ignore{$1} = $2 if $2;
        }
    }
    else {
        m/^(.*) - (.+)/sm;
        $ignore{$1} = $2 if $2;
    }
}

foreach my $dir (sort keys %ignore) {
    print $SKIP "# generated from svn:ignore of '$dir/'\n";
    foreach (sort split /\n/, $ignore{$dir}) {
        s/\./\\./g; s/\*/.*/g;
        print $SKIP
            $dir ne '.' ?
            "^$dir/$_\$\n^$dir/$_/\n" :
            "^$_\$\n^$_/\n";
    }
}


sub wanted {

    return if $File::Find::name =~ m[/\.svn|blib|debian];

    # This is currently the only ignored directory    
    return if $File::Find::name =~ m{runtime.parrot.library.PAST};

    $File::Find::name =~ s[^\./][];
    -d and push @dirs, $File::Find::name;
    -f and -e ".svn/text-base/$_.svn-base" and MANIFEST();
}

sub MANIFEST {
    my $loc = '[]';
    for ($File::Find::name) {
        $loc =
        exists($special{$_}) ? $special{$_} :
        !m[/]             ? '[]' :
        m[^LICENSES/]     ? '[main]doc' :
        m[^docs/]         ? '[main]doc' :
        m[^editor/]       ? '[devel]' :
        m[^examples/]     ? '[main]doc' :
        m[^include/]      ? '[main]include' :
        (m[^languages/(\w+)/] and $1 ne 'conversion') ? "[$1]" :
        m[^lib/]          ? '[devel]' :
        m[^runtime/]      ? '[library]' :
        m[^tools/docs/]   ? '[devel]' :
        m[^tools/dev/]    ? '[devel]' :
        '[]';
    }
    push @MANI, sprintf("%- 59s %s\n", $File::Find::name, $loc);

    return;
}

close $MANI;
close $SKIP;
