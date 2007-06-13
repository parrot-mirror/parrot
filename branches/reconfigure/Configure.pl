#! perl

# Copyright (C) 2001-2007, The Perl Foundation.
# $Id$

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

=item C<--test>

Run certain tests along with F<Configure.pl>:

=over 4

=item C<--test=configure>

Run tests found in F<t/configure/> I<before> beginning configuration.  These
tests demonstrate that Parrot's configuration tools will work properly once
configuration has begun.

=item C<--test=build>

Run tests found in F<t/postconfigure/>, F<t/tools/pmc2cutils/>,
F<t/tools/ops2cutils/> and F<t/tools/ops2pmutils/> I<after> configuration has
completed.  These tests demonstrate (a) that certain of Parrot's configuration
tools are working properly post-configuration; and (b) that certain of
Parrot's build tools will work properly once you call F<make>.

=item C<--test>

Run the tests described in C<--test=configure>, conduct configuration, then
run the tests described in C<--test=build>.

=back

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

use 5.008;
use strict;
use warnings;

use Carp;
use Data::Dumper; $Data::Dumper::Indent = 1;

use File::Basename qw( basename );
use File::Spec::Functions qw( catdir catfile );
use FindBin qw( $Bin );

# used in tasks to find parrot libraries
use lib 'lib';


main( @ARGV ) unless caller;


sub main {
    ## data store for directory operations
    my $dirstack= [];

    ## data store
    ## TODO should this be backed by dbm::deep or something?
    my $DS= {
        DIRS       => $dirstack,
        PARROT     => {
            argv   => [ @ARGV ],
            script => $0,
            svnid  => '$Id$',
        },
        user       => {},
    };

    my $actions= {
        include      => \&read_config,
        define       => \&define_config_directive,
        _DEFAULT_    => \&no_such_directive,
        DUMP         => sub{ print Dumper \@_ },
    };

    my $ddir= catdir $Bin, 'config', 'directives';

    ## define io commands, which operate on the directory stack
    read_config( catfile( $ddir, 'io.op'), $actions, $dirstack );

    ## define commands which operate on the data store
    for my $f (qw/ core intro /)
    {
        read_config( catfile( $ddir, $f . '.op'), $actions, $DS );
    }

    ## process the list of configure directives
    ## TODO allow the --script=s option to override this
    read_config( catfile( $ddir, 'configure.op' ), $actions, $DS );
}



exit;



sub read_config
{
    my( $filename, $actions, $userparam )= @_;
    open my($CF) => $filename
        or carp $!;

    LINE: while(<$CF>)
    {
        chomp;
        ## skip blank lines and comments
        next if m/^\s*$/ || m/\s*#/;

        my( $directive, $rest )= split /\s+/ => $_, 2;

        ## deal with heredocs
        ## heredoc delimeters can be any non-space chars following '<<'
        ## and optional spaces (eg. '<< %END!' or '<<DESC')
        $rest= read_heredoc( $CF, $1, $filename )
            if( $rest && $rest =~ m/^<< \s* (\S*)$/x );

        ## resolve the action
        ## first try user-defined, otherwise default
        my $action= $actions->{$directive}
            || $actions->{_DEFAULT_};
        if( $action )
        {
            $action->( $directive, $rest, $actions, $userparam );
        }
        else
        {
            die "unrecognized directive '$directive'"
                . " at line $. of $filename; aborting";
        }
    }
    return 1;
}


sub read_heredoc
{
    my( $CF, $marker, $filename )= @_;
    my $line_num= $.;

    my $rest= '';
    while( my $buffer= <$CF>)
    {
        die "runaway heredoc on line $line_num of $filename; aborting"
            unless defined $buffer;
        last if $buffer =~ m/^$marker$/;
        $rest .= $buffer;
    }
    return $rest;
}


sub define_config_directive
{
    my( $directive, $rest, $dispatch )= @_;
    $rest =~ s/^\s+//;
    my( $new_directive, $def_text )= split /\s+/ => $rest, 2;

    if( exists $dispatch->{$new_directive} )
    {
        warn "$new_directive already defined; skipping.\n";
        return;
    }

    my $def= eval "sub { $def_text }";
    if( not defined $def )
    {
        warn "could not compile definition for '$new_directive':"
            . "$@; skipping.\n";
        return;
    }

    $dispatch->{$new_directive}= $def;
}


## handles missing directives
sub no_such_directive
{
    my( $directive )= @_;
    $directive ||= ''; $. ||= 0;
    warn "unrecognized directive '$directive' at line $.; ignoring.\n";
}


## XXX fix passed arguments processing... it defaults to space-sep which is wrong TODO
sub process_opts
{
    require Parrot::Configure::Options;

    my( $var, $val, undef, $stash )= @_;
    my $args = Parrot::Configure::Options::process_options( {
        argv            => [ defined $val ? $val : @ARGV ],
        script          => $0,
        parrot_version  => $stash->{PARROT}{parrot_version},
        svnid           => '$Id$',
    } );
    # XXX really? just exit? it should give a friendly message
    exit unless defined $args;

    set_parrot_var( args => $args, undef, $stash );
}


## sets a parrot variable to a value
sub set_parrot_var
{
    my( $var, $val, undef, $stash )= @_;
    $stash->{PARROT}{$var}= $val;
}


## sets a user variable to a value
sub set_user_var
{
    my( $var, $val, undef, $stash )= @_;
    $stash->{user}{$var}= $val;
}


## sets a configuration variable to a value
sub set_conf_var
{
    my( $var, $val, undef, $stash )= @_;
    $stash->{user}{conf}->data->set($var, $val);
}


## gets a parrot variable
sub get_parrot_var { $_[3]->{PARROT}{$_[0]} }


## gets a user variable
sub get_user_var { $_[3]->{user}{$_[0]} }


## gets a value from the configuration
sub get_conf_var { $_[3]->{user}{conf}->data->get($_[0]) }


## resets all parrot variables
sub reset_parrot_vars
{
    my( undef, undef, undef, $stash )= @_;
    delete $stash->{PARROT};
    $stash->{PARROT}= {};
}


## resets all user variables
sub reset_user_vars
{
    my( $var, undef, undef, $stash )= @_;
    delete $stash->{user};
    $stash->{user}= {};
}


## quit
sub quit { exit 0 }


$_ ^=~ { AUTHOR => 'particle' };



################### DOCUMENTATION ###################


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

