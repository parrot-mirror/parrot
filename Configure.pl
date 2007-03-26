#! perl
# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$
use 5.006_001;
use strict;
use warnings;
use Data::Dumper;
$Data::Dumper::Indent = 1;
use lib 'lib';

use Parrot::BuildUtil;
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Messages qw(
    print_introduction
    print_conclusion
);
use Parrot::Configure::Step::List qw( get_steps_list );

my $parrot_version = Parrot::BuildUtil::parrot_version();

$| = 1; # $OUTPUT_AUTOFLUSH = 1;

# Install Option text was taken from:
#
# autoconf (GNU Autoconf) 2.59
# Written by David J. MacKenzie and Akim Demaille.
#
# Copyright (C) 2003 Free Software Foundation, Inc.
# This is free software; see the source for copying conditions.  There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# Installation directories:

my $args = process_options( {
    argv            => [ @ARGV ],
    script          => $0,
    parrot_version  => $parrot_version,
    svnid           => '$Id$',
} );
exit unless defined $args;

my %args = %$args;

print_introduction($parrot_version);

my $conf = Parrot::Configure->new;

$conf->add_steps(get_steps_list());

$conf->options->set(%args);

if ( exists $args{step} ) {
    $conf->data()->slurp();
    $conf->runstep( $args{step} );
    print "\n";
    exit(0);
}
else {

    # Run the actual steps
    $conf->runsteps or exit(1);
}

# tell users what to do next
print_conclusion($conf->data->get('make'));

exit(0);

################### DOCUMENTATION ###################

=head1 NAME

Configure.pl - Parrot's Configuration Script

=head1 SYNOPSIS

    % perl Configure.pl [options]

=head1 DESCRIPTION

This is Parrot's configuration program. It should be run to create
the necessary system-specific files before building Parrot.

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

=item C<--step==>

execute a single configure step

=item C<--ask>

This turns on the user prompts.

=back

Compile Options

=over

=item C<--debugging=0>

Debugging is turned on by default. Use this to disable it.

=item C<--parrot_is_shared>

Link parrot dynamically.

=item C<--m=32>

Create a 32-bit executable on 64-architectures like x86_64. This
option appends -m32 to compiler and linker programs and does
s/lib64/lib/g on link flags.

This option is experimental. See F<config/init/defaults.pm> for more.

=item C<--profile>

Turn on profiled compile (gcc only for now)

=item C<--cage>

[CAGE] compile includes many additional warnings

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

=item C<--flex_required=X.Y.Z>

Override the minimum acceptable flex version.

=item C<--yacc=(parser)>

Specify which parser to use.

=item C<--bison_required=X.Y>

Override the minimum acceptable bison version.

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

International Components For Unicode (ICU) Options

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


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
