#! perl -w

use strict;
use lib qw(lib);

my $template = "tcl.imc_template";

open(TEMPLATE,$template) or die;
local $/ = undef;
my $contents = <TEMPLATE>;
close(TEMPLATE);

my $command_dir = "lib/commands";
opendir(CMDDIR,$command_dir);
my @cmd_files = readdir(CMDDIR);
closedir(CMDDIR);

my $macro_dir = "lib/macros";
opendir(CMDDIR,$macro_dir);
my @macro_files = readdir(CMDDIR);
closedir(CMDDIR);

my @cmd_includes = map {"$command_dir/$_"} grep {m/\.imc$/} @cmd_files;
my @macro_includes = map {"$macro_dir/$_"} grep {m/\.imc$/} @macro_files;

my @commands = grep {s/\.imc$//} @cmd_files;

my $lib_dir = "lib";
opendir(LIBDIR,$lib_dir) or die;
my @libs = map {"$lib_dir/$_"} grep {m/\.imc$/} grep {! m/^tcl(lib|word).imc$/} readdir(LIBDIR);
closedir(LIBDIR);

my $includes;
foreach my $file (@macro_includes, @cmd_includes, @libs) {
  $includes .= "  .include \"languages/tcl/$file\"\n";
}

$contents =~ s/\${INCLUDES}/$includes/g;
$contents =~ s/\${HEADER}/This file automatically generated, do not edit./g;
$contents =~s/\${XXX.*}//g;

print $contents;
