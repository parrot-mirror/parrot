#! perl
# Copyright (C) 2005-2009, Parrot Foundation.
# $Id$

=head1 TITLE

tools/dev/mk_inno.pl - Create a script for Inno Setup

=head1 SYNOPSIS

    % perl tools/dev/mk_inno.pl

=head1 DESCRIPTION

From L<http://www.jrsoftware.org/>:  Inno Setup is a free installer for
Windows programs.

=cut

use strict;
use warnings;
use lib qw( lib ../lib ../../lib );
use Parrot::Config;

my $version = $PConfig{VERSION} . $PConfig{DEVEL};

my $prefix = $PConfig{prefix};
$prefix =~ s/\//\\/g;

my $icu_section = q{};
$icu_section = qq{
Source: "$PConfig{icu_dir}\\license.html"; DestDir: "{app}\\icu"; Flags:
Source: "$PConfig{icu_dir}\\bin\\icu*.dll"; DestDir: "{app}\\bin"; Flags:
} if ($PConfig{has_icu});

my %dll = (
    HAS_GETTEXT  => [ 'libintl3.dll', 'libiconv2.dll' ],
    HAS_PCRE     => [ 'pcre3.dll' ],
    HAS_READLINE => [ 'readline5.dll' ],
);

my $dll_section = q{};
while (my ($flag, $dlls) = each %dll) {
    next unless ($PConfig{$flag});
    foreach my $dll (@{$dlls}) {
        my $path = `which $dll`;
        chomp $path;
        $path =~ s/\//\\/g;
        $dll_section .= "Source: \"$path\"; DestDir: \"{app}\\bin\"; Flags:\n"
            if ($path);
    }
}

my $filename = 'parrot.iss';
open my $OUT, '>', $filename
    or die "Can't open $filename ($!)";

print $OUT qq{
; generated by tools/dev/mk_inno.pl for the Inno Setup Script Compiler.

[Setup]
AppName=Parrot
AppVerName=Parrot-$version
AppPublisher=Parrot Foundation
AppPublisherURL=http://www.parrot.org/
AppSupportURL=http://www.parrot.org/
AppUpdatesURL=http://www.parrot.org/
DefaultDirName={sd}$prefix
DefaultGroupName=Parrot
AllowNoIcons=yes
LicenseFile=$prefix\\share\\doc\\parrot\\LICENSE
OutputDir=.\\
OutputBaseFilename=setup-parrot-$version
Compression=lzma
SolidCompression=yes
ChangesAssociations=yes
PrivilegesRequired=none
ChangesEnvironment=yes

[Files]
Source: "$prefix\\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs
${icu_section}
${dll_section}

[Icons]
Name: "{group}\\{cm:UninstallProgram,parrot}"; Filename: "{uninstallexe}"

[Registry]
Root: HKLM; SubKey: "SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\"; ValueType: string; ValueName: "Path"; ValueData: "{reg:HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\,Path};{app}\\bin"
};

close $OUT;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
