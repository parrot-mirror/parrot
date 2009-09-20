#! perl
# Copyright (C) 2009, Parrot Foundation.
# $Id$

=head1 TITLE

tools/dev/mk_inno_language.pl - Create a script for Inno Setup

=head1 SYNOPSIS

    % cd languages/lang
    % perl ../../tools/dev/mk_inno_language.pl lang

=head1 SEE ALSO

http://www.jrsoftware.org/

=cut

use strict;
use warnings;
use lib qw( ../../lib );
use Parrot::Config;

unless (@ARGV) {
    die "usage: $0 lang\n";
}

##  determine the language we're trying to build
my $lang = $ARGV[0];
my $lclang = lc $lang;
my $uclang = ucfirst $lang;

my $version = $PConfig{VERSION} . $PConfig{DEVEL};

my $prefix = $PConfig{prefix};
$prefix =~ s/\//\\/g;

my @now = gmtime;
my $date = sprintf("%04d%02d%02d", 1900 + $now[5], 1 + $now[4], $now[3]);

my $license = -f 'LICENSE'
            ? qq{LicenseFile=LICENSE}
            : -f 'COPYING'
            ? qq{LicenseFile=COPYING}
            : -f 'COPYRIGHT'
            ? qq{LicenseFile=COPYRIGHT}
            : '; no LicenseFile';

my $exe = $lang eq 'rakudo'
        ? ( -f 'perl6.exe'
            ? qq{Source: ".\\perl6.exe"; DestDir: "{app}\\bin"; Flags:}
            : '; no perl6.exe'
        )
        : ( <parrot-*.exe>
            ? qq{Source: ".\\parrot-*.exe"; DestDir: "{app}\\bin"; Flags:}
            : '; no .exe'
        );
my $pbc = <*.pbc> && ! -d $lang
        ? qq{Source: ".\\*.pbc"; DestDir: "{app}\\lib\\parrot\\languages\\$lang"; Flags:}
        : '; no .pbc';
my $lng = -d $lang
        ? qq{Source: ".\\$lang\\*.pbc"; DestDir: "{app}\\lib\\parrot\\languages\\$lang"; Flags: ignoreversion recursesubdirs}
        : '; no lang';
my $pmc = <src/pmc/*.dll>
        ? qq{Source: ".\\src\\pmc\\*.dll"; DestDir: "{app}\\lib\\parrot\\dynext"; Flags:}
        : '; no pmc';
my $ops = <src/ops/*.dll>
        ? qq{Source: ".\\src\\ops\\*.dll"; DestDir: "{app}\\lib\\parrot\\dynext"; Flags:}
        : '; no ops';
my $dynext = <dynext/*.dll> && !<src/pmc/*.dll> && !<src/ops/*.dll>
           ? qq{Source: ".\\dynext\\*.dll"; DestDir: "{app}\\lib\\parrot\\dynext"; Flags:}
           : '; no dynext';
my $man = -d 'man'
        ? qq{Source: ".\\man\\*"; DestDir: "{app}\\man\\parrot"; Flags: ignoreversion recursesubdirs}
        : '; no man';
my $doc = -d 'doc'
        ? qq{Source: ".\\doc\\*"; DestDir: "{app}\\share\\doc\\parrot\\languages\\$lang"; Flags: ignoreversion recursesubdirs}
        : -d 'docs'
        ? qq{Source: ".\\docs\\*"; DestDir: "{app}\\share\\doc\\parrot\\languages\\$lang"; Flags: ignoreversion recursesubdirs}
        : '; no doc';
my $readme = -f 'README'
           ? qq{Source: ".\\README"; DestDir: "{app}\\share\\doc\\parrot\\languages\\$lang"; Flags:}
           : '; no README';

my $filename = 'parrot-' . $lclang . '.iss';
open my $OUT, '>', $filename
    or die "Can't open $filename ($!)";

print $OUT qq{
; generated by tools/dev/mk_inno_language.pl for the Inno Setup Script Compiler.

[Setup]
AppName=Parrot-$uclang
AppVerName=Parrot-$version-$uclang-$date
AppPublisher=Parrot Foundation
AppPublisherURL=http://www.parrot.org/
DefaultDirName={sd}$prefix
DefaultGroupName=Parrot
AllowNoIcons=yes
$license
OutputDir=.\\
OutputBaseFilename=setup-parrot-$version-$lclang-$date
Compression=lzma
SolidCompression=yes
Uninstallable=no

[Files]
$exe
$pbc
$lng
$pmc
$ops
$dynext
$man
$doc
$readme

};

close $OUT;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
