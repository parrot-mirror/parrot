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

my @dirs;    # will be filled in wanted

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

my $keyword = '$' . 'Id$';     # avoid an svn issue.
my $time    = scalar gmtime;
open my $MANI, '>', 'MANIFEST';
print {$MANI} <<"END_HEADER";
# ex: set ro:
# $keyword
#
# generated by $0 $time UT
#
# See tools/dev/install_files.pl for documentation on the
# format of this file.
# See docs/submissions.pod on how to recreate this file after SVN
# has been told about new or deleted files.
END_HEADER

open my $SKIP, '>', 'MANIFEST.SKIP';
print {$SKIP} <<"END_HEADER";
# ex: set ro: 
# $keyword
# generated by $0 $time UT
#
# This file should contain a transcript of the svn:ignore properties
# of the directories in the Parrot subversion repository. (Needed for
# distributions or in general when svn is not available).
# See docs/submissions.pod on how to recreate this file after SVN
# has been told about new generated files.
#
# Ignore the SVN directories
\\B\\.svn\\b

# debian/ should not go into release tarballs
^debian\$
^debian/
END_HEADER

my $cmd = -d '.svn' ? 'svn' : 'svk';

# get all files from sv[nk] status -v
my @status_output = qx($cmd status -v);

# now grab the versioned resources:
my @versioned_files = ();
my @versioned_output = grep !/^\?/, @status_output;
for my $line ( @versioned_output ) {
    my @line_info = split(/\s+/, $line);
    # the file is the 5th item in the @line_info array
    push @versioned_files, $line_info[4];
}

my @MANI = ();

for my $file ( @versioned_files ) {
    # ignore the debian directory
    next if $file =~ m[/\.svn|blib|debian];

    # don't want to keep directories
    if ( -d $file ) {
        push @dirs, $file;
        next;
    }

    # now get the manifest entry
    MANIFEST($file);
}

print $MANI $_ for ( sort @MANI );

my $svnignore = `$cmd propget svn:ignore @dirs`;
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

foreach my $dir ( sort keys %ignore ) {
    print $SKIP "# generated from svn:ignore of '$dir/'\n";
    foreach ( sort split /\n/, $ignore{$dir} ) {
        s/\./\\./g;
        s/\*/.*/g;
        print $SKIP $dir ne '.'
            ? "^$dir/$_\$\n^$dir/$_/\n"
            : "^$_\$\n^$_/\n";
    }
}

close $MANI;
close $SKIP;

sub wanted {

    return if $File::Find::name =~ m[/\.svn|blib|debian];

    # This is currently the only ignored directory
    return if $File::Find::name =~ m{runtime.parrot.library.PAST};

    $File::Find::name =~ s[^\./][];
    if ( -d $_ ) {
        push @dirs, $File::Find::name;
    }

    my $svnbase = ".svn/text-base/$_.svn-base";
    if ( -f $_ and -e $svnbase ) {
        MANIFEST();
    }

    return;    # ignored
}

sub MANIFEST {
    my $file = shift;
    my $loc = '[]';
    #for ($File::Find::name) {
    for ($file) {
        $loc =
              exists( $special{$_} ) ? $special{$_}
            : !m[/]                  ? '[]'
            : m[^LICENSES/]          ? '[main]doc'
            : m[^docs/]              ? '[main]doc'
            : m[^editor/]            ? '[devel]'
            : m[^examples/]          ? '[main]doc'
            : m[^include/]           ? '[main]include'
            : ( m[^languages/(\w+)/] and $1 ne 'conversion' ) ? "[$1]"
            : m[^lib/]        ? '[devel]'
            : m[^runtime/]    ? '[library]'
            : m[^tools/docs/] ? '[devel]'
            : m[^tools/dev/]  ? '[devel]'
            : m[^(apps/\w+)/] ? "[$1]"
            :                   '[]';
    }
    push @MANI, sprintf( "%- 59s %s\n", $file, $loc );

    return;
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
