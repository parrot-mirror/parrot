#! perl
# Copyright (C) 2009, The Perl Foundation.
# $Id$

=head1 TITLE

tools/dev/mk_inno_language.pl - Create a script for Inno Setup

=head1 SYNOPSIS

    % perl tools/dev/mk_inno_language.pl lang

=head1 SEE ALSO

http://www.jrsoftware.org/

=cut

use strict;
use warnings;
use lib qw( lib ../lib ../../lib );
use Parrot::Config;

unless (@ARGV) {
    die "usage: $0 language\n";
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

my $license = (-f "languages/$lang/LICENSE")
            ? "languages\\$lang\\LICENSE"
            : '.\\LICENSE';

my $exe = <languages/$lang/*.exe>
        ? qq{Source: ".\\languages\\$lang\\*.exe"; DestDir: "{app}\\bin"; Flags:}
        : '; no .exe';
my $cmd = <languages/$lang/*.cmd>
        ? qq{Source: ".\\languages\\$lang\\*.cmd"; DestDir: "{app}\\bin"; Flags:}
        : '; no .cmd';
my $pmc = <languages/$lang/src/pmc/*.pmc>
        ? qq{Source: ".\\languages\\$lang\\src\\pmc\\*.dll"; DestDir: "{app}\\lib\\parrot\\dynext"; Flags:}
        : '; no pmc';
my $ops = <languages/$lang/src/ops/*.ops>
        ? qq{Source: ".\\languages\\$lang\\src\\ops\\*.dll"; DestDir: "{app}\\lib\\parrot\\dynext"; Flags:}
        : '; no ops';

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
LicenseFile=$license
OutputDir=.\\
OutputBaseFilename=setup-parrot-$version-$lclang-$date
Compression=lzma
SolidCompression=yes
Uninstallable=no

[Files]
Source: ".\\languages\\$lang\\*.pbc"; DestDir: "{app}\\languages\\$lang"; Flags:
$exe
$cmd
$pmc
$ops

};

close $OUT;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
