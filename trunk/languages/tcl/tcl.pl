#! perl -w

use strict;
use lib qw(lib);

my $template = "tcl.pir_template";

my $header = <<EOH;
# This file automatically generated by $0. Edit
# $template instead.

EOH

open(TEMPLATE,$template) or die;
local $/ = undef;
my $contents = $header . <TEMPLATE>;
close(TEMPLATE);

my $command_dir = "lib/commands";
opendir(CMDDIR,$command_dir);
my @cmd_files = readdir(CMDDIR);
closedir(CMDDIR);

my $macro_dir = "lib/macros";
opendir(CMDDIR,$macro_dir);
my @macro_files = readdir(CMDDIR);
closedir(CMDDIR);

my @cmd_includes = map {"$command_dir/$_"} grep {m/\.pir$/} @cmd_files;
my @macro_includes = map {"$macro_dir/$_"} grep {m/\.pir$/} @macro_files;

my @commands = grep {s/\.pir$//} @cmd_files;

my $lib_dir = "lib";
opendir(LIBDIR,$lib_dir) or die;
my @libs = map {"$lib_dir/$_"} grep {m/\.pir$/} grep {! m/^tcl(lib|word).pir$/} readdir(LIBDIR);
closedir(LIBDIR);

my $includes;
foreach my $file (@macro_includes, @cmd_includes, @libs) {
  $includes .= "  .include \"languages/tcl/$file\"\n";
}

=head2 rules

Generate the PIR code that matches the various rules we have.

=cut

my $rulefile = "lib/tcl.p6r";
my $rules;

open (RULES,$rulefile) or die "can't read rules file.\n";

$rules = <<'EOH';
# Read in any of the perl6-ian grammars that have been defined for Tcl

.sub "_load_grammar"
  .local pmc p6rule_compile
  p6rule_compile = find_global "PGE", "p6rule"
  
  .local string grammar 
  grammar = "_Tcl_Rules" #xxx should probably not hardcode this.
EOH

my $rule = join("",<RULES>);
$rule =~ s/\n//g;

while ($rule =~ m/rule\s+(\w+)\s*{(.*?)};/g) {
  my $rule_name = $1;
  my $rule_def = $2;
  $rule_def =~ s:\\:\\\\:g;
  $rule_def =~ s:":\\":g;

  $rules .= <<EORULE
  p6rule_compile("$rule_def", grammar, "$rule_name")
EORULE

};

$rules .= ".end\n";

$contents =~ s/\${INCLUDES}/$includes/g;
$contents =~ s/\${HEADER}/This file automatically generated, do not edit./g;
$contents =~ s/\${RULES}/$rules/g;
$contents =~s/\${XXX.*}//g;

print $contents;
