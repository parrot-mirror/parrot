#! perl -w

# Copyright: 2001-2006 The Perl Foundation.  All Rights Reserved.
# $Id$

=head1 NAME

Configure.pl - Parrot's Configuration Script

=head1 SYNOPSIS

    % perl Configure.pl [options]

=head1 DESCRIPTION

This is Parrot's configuration script. It should be run to create the necessary
system-specific files before building Parrot.

=head2 Command-line Options

General Options

=over

=item C<--help>

Prints out a description of the options and exits.

=item C<--version>

Prints out the version number of Configure.pl and exits.

=item C<--verbose>

Tells Configure.pl to output extra information about the configuration data it
is setting.

=item C<--verbose=2>

Tells Configure.pl to output information about i<every> setting added or
changed.

=item C<--verbose-step={N|regex}>

Run C<--verbose=2> for step number C<N> or matching description.

=item C<--nomanicheck>

Tells Configure.pl not to run the MANIFEST check.

=item C<--prefix>

Sets the location where parrot will be installed.

=item C<--ask>

This turns on the user prompts.

=back

Compile Options

=over

=item C<--debugging=0>

Debugging is turned on by default. Use this to disable it.

=item C<--parrot_is_shared>

Link parrot dynamically.

=item C<--profile>

Turn on profiled compile (gcc only for now)

=item C<--optimize>

Add perl5's $Config{optimize} to the compiler flags.

=item C<--optimize=flags>

Add C<flags> to the compiler flags.

=item C<--inline>

Tell Configure that the compiler supports C<inline>.

=item C<--cc=(compiler)>

Specify which compiler to use.

=item C<--ccflags=(flags)>

Use the given compiler flags.

=item C<--ccwarn=(flags)>

Use the given compiler warning flags.

=item C<--cxx=(compiler)>

Specify which C++ compiler to use (for ICU).

=item C<--libs=(libs)>

Use the given libraries.

=item C<--link=(linker)>

Specify which linker to use.

=item C<--linkflags=(flags)>

Use the given linker flags

=item C<--ld=(linker)>

Specify which loader to use for shared libraries.

=item C<--ldflags=(flags)>

Use the given loader flags for shared libraries

=item C<--lex=(lexer)>

Specify which lexer to use.

=item C<--yacc=(parser)>

Specify which parser to use.

=item C<--define=val1[,val2]>

Generate "#define PARROT_DEF_VAL1 1" ... entries in has_header.h. Currently
needed to use inet_aton for systems that lack inet_pton:

  --define=inet_aton

=back

Parrot Options

=over

=item C<--intval=(type)>

Use the given type for C<INTVAL>.

=item C<--floatval=(type)>

Use the given type for C<FLOATVAL>.

=item C<--opcode=(type)>

Use the given type for opcodes.

=item C<--ops=(files)>

Use the given ops files.

=item C<--pmc=(files)>

Use the given PMC files.

=item C<--cgoto=0>

Don't build cgoto core. This is recommended when you are short of memory.

=item C<--jitcapable>

Use JIT system.

=item C<--execcapable>

Use JIT to emit a native executable.

=item C<--gc=(type)>

Determine the type of garbage collection. The value for C<type> should be one
of: C<gc>, C<libc>, C<malloc> or C<malloc-trace>. The default is C<gc>.

=back

ICU Options

=over

=item C<--icu-config=/path/to/icu-config>

Use the specified icu-config script to determine the necessary ICU options.

Use --icu-config=none to disable the autodetect feature. Parrot will then be
build without ICU.

B<Note:> If you specify another ICU option than --icu-config, the autodetection
functionality will be disabled.

=item C<--icushared=(linkeroption)>

Linker command to link against ICU library.

E.g.

   --icushared='-L /opt/openoffice/program -licudata -licuuc'

(The libs in openoffice are actually version 2.2 and do not work)

=item C<--icuheaders=(header_dir)>

Location of ICU header files without the /unicode suffix.

E.g.

--icuheaders='/home/lt/icu/'

=back

Other Options

=over

=item C<--maintainer>

Use this option if you want imcc's parser and lexer files to be generated.
Needs a working parser and lexer.

=item C<--miniparrot>

Build parrot assuming only pure ANSI C is available.

=back

=head1 SEE ALSO

F<config/init/data.pl>, F<lib/Parrot/Configure/RunSteps.pm>,
F<lib/Parrot/Configure/Step.pm>, F<docs/configuration.pod>

=cut

use strict;
use warnings;
use lib 'lib';
use 5.006;

use English qw( -no_match_vars );
use Parrot::BuildUtil;
use Parrot::Configure;

# These globals are accessed in config/init/defaults.pm
our $parrot_version = Parrot::BuildUtil::parrot_version();
our @parrot_version = Parrot::BuildUtil::parrot_version();

$OUTPUT_AUTOFLUSH = 1;

# Handle options
my %args;
for (@ARGV) {
  my($key, $value) = m/--([-\w]+)(?:=(.*))?/;
  $key   = 'help' unless defined $key;
  $value = 1      unless defined $value;

  for ($key) {
    m/version/ && do {
      my $svnid = '$Id$';
      print <<"END";
Parrot Version $parrot_version Configure 2.0
$svnid
END
      exit;
    };

    m/help/    && do {
      print <<"EOT";
$0 - Parrot Configure 2.0

General Options:

   --help               Show this text
   --version            Show version information
   --verbose            Output extra information
   --verbose=2          Output every setting change
   --verbose-step=N     Set verbose for step N only
   --verbose-step=regex Set verbose for step matching description
   --nomanicheck        Don't check the MANIFEST
   --prefix             Set the installation prefix

   --ask                Have Configure ask for commonly-changed info

Compile Options:

   --debugging=0        Disable debugging, default = 1
   --inline             Compiler supports inline
   --optimize           Optimized compile
   --optimize=flags     Add given optimizer flags
   --parrot_is_shared   Link parrot dynamically
   --profile            Turn on profiled compile (gcc only for now)

   --cc=(compiler)      Use the given compiler
   --ccflags=(flags)    Use the given compiler flags
   --ccwarn=(flags)     Use the given compiler warning flags
   --cxx=(compiler)     Use the given C++ compiler
   --libs=(libs)        Use the given libraries
   --link=(linker)      Use the given linker
   --linkflags=(flags)  Use the given linker flags
   --ld=(linker)        Use the given loader for shared libraries
   --ldflags=(flags)    Use the given loader flags for shared libraries
   --lex=(lexer)        Use the given lexical analyzer generator
   --yacc=(parser)      Use the given parser generator

   --define=inet_aton   Quick hack to use inet_aton instead of inet_pton

Parrot Options:

   --intval=(type)      Use the given type for INTVAL
   --floatval=(type)    Use the given type for FLOATVAL
   --opcode=(type)      Use the given type for opcodes
   --ops=(files)        Use the given ops files
   --pmc=(files)        Use the given PMC files

   --cgoto=0            Don't build cgoto core - recommended when short of mem
   --jitcapable         Use JIT
   --execcapable        Use JIT to emit a native executable
   --gc=(type)          Determine the type of garbage collection
                        type=(gc|libc|malloc|malloc-trace) default is gc

ICU Options:

   For using a system ICU, these options can be used:

   --icu-config=/path/to/icu-config
                        Location of the script used for ICU autodetection.
                        You just need to specify this option if icu-config
                        is not in you PATH.

   --icu-config=none    can be used to disable the autodetection feature.
                        It will also be disabled if you specify any other
                        of the following ICU options.

   If you do not have a full ICU installation:

   --without-icu        Build parrot without ICU support
   --icuheaders=(path)  Location of ICU headers without /unicode
   --icushared=(flags)  Full linker command to create shared libraries
   --icudatadir=(path)  Directory to locate ICU's data file(s)

Other Options (may not be implemented):

   --maintainer         Create imcc's parser and lexer files. Needs a working
                        parser and lexer.
   --miniparrot         Build parrot assuming only pure ANSI C is available

EOT
      exit;
    };
    $args{$key} = $value;
  }
}

$args{debugging} = 1 unless ((exists $args{debugging}) && !$args{debugging});
$args{maintainer} = 1 if defined $args{lex} or defined $args{yacc};

print <<"END";
Parrot Version $parrot_version Configure 2.0
Copyright (C) 2001-2006 The Perl Foundation.  All Rights Reserved.

Hello, I'm Configure. My job is to poke and prod your system to figure out
how to build Parrot. The process is completely automated, unless you passed in
the `--ask' flag on the command line, in which case it'll prompt you for a few
pieces of info.

Since you're running this script, you obviously have Perl 5--I'll be pulling
some defaults from its configuration.
END

# EDIT HERE TO ADD NEW TESTS
my @steps = qw(
    init::manifest
    init::defaults
    init::miniparrot
    init::hints
    init::headers
    inter::progs
    inter::make
    inter::lex
    inter::yacc
    auto::gcc
    auto::msvc
    init::optimize
    inter::shlibs
    inter::libparrot
    inter::charset
    inter::encoding
    inter::types
    inter::ops
    inter::pmc
    auto::alignptrs
    auto::headers
    auto::sizes
    auto::byteorder
    auto::va_ptr
    auto::pack
    auto::format
    auto::isreg
    auto::jit
    gen::cpu
    auto::funcptr
    auto::cgoto
    auto::inline
    auto::gc
    auto::memalign
    auto::signal
    auto::socklen_t
    auto::env
    auto::aio
    auto::gmp
    auto::readline
    auto::gdbm
    auto::snprintf
    auto::perldoc
    auto::python
    auto::bc
    auto::m4
    gen::icu
    gen::revision
    gen::config_h
    gen::core_pmcs
    gen::parrot_include
    gen::makefiles
    gen::platform
    gen::config_pm
);

my $conf = Parrot::Configure->new;
{
    # XXX $Parrot::Configure::Step::conf is a temporty hack
    no warnings qw(once);
    $Parrot::Configure::Step::conf = $conf;
}
$conf->add_steps(@steps);
$conf->options->set(%args);
# Run the actual steps
$conf->runsteps or exit(1);

# tell users what to do next
my $make = $conf->data->get('make');

print <<"END";

Okay, we're done!

You can now use `$make' to build your Parrot.
(NOTE: do not use `$make -j <n>'!)
After that, you can use `$make test' to run the test suite.

Happy Hacking,
        The Parrot Team

END

exit(0);
