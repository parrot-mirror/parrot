# Copyright (C) 2004-2007, The Perl Foundation.
# $Id$

=head1 NAME

Parrot::Test - testing routines for Parrot and language implementations

=head1 SYNOPSIS

Set the number of tests to be run like this:

    use Parrot::Test tests => 8;

Write individual tests like this:

    pasm_output_is(<<'CODE', <<'OUTPUT', "description of test");
    print "this is ok\n"
    end
    CODE
    this is ok
    OUTPUT

=head1 DESCRIPTION

This module provides various Parrot-specific test functions.

=head2 Functions

The parameter C<$language> is the language of the code.
The parameter C<$code> is the code that should be executed or transformed.
The parameter C<$expected> is the expected result.
The parameter C<$unexpected> is the unexpected result.
The parameter C<$description> should describe the test.

Any optional parameters can follow.  For example, to mark a test as a TODO test
(where you know the implementation does not yet work), pass:

    todo => 'reason to consider this TODO'

at the end of the argument list.  Valid reasons include C<bug>,
C<unimplemented>, and so on.

B<Note:> you I<must> use a C<$description> with TODO tests.

=over 4

=item C<language_output_is( $language, $code, $expected, $description)>

Runs a language test and passes the test if a string comparison
of the output with the expected result it true.

=item C<language_output_like( $language, $code, $expected, $description)>

Runs a language test and passes the test if the output matches the expected
result.

=item C<language_output_isnt( $language, $code, $expected, $description)>

Runs a language test and passes the test if a string comparison
if a string comparison of the output with the unexpected result is false.

=item C<pasm_output_is($code, $expected, $description)>

Runs the Parrot Assembler code and passes the test if a string comparison of
the output with the expected result it true.

=item C<pasm_error_output_is($code, $expected, $description)>

Runs the Parrot Assembler code and passes the test if a string comparison of
the output with the expected result it true I<and> if Parrot exits with a
non-zero exit code.

=item C<pasm_output_like($code, $expected, $description)>

Runs the Parrot Assembler code and passes the test if the output matches the

=item C<pasm_error_output_like($code, $expected, $description)>

Runs the Parrot Assembler code and passes the test if the output the expected
result it true I<and> if Parrot exits with a non-zero exit code.

=item C<pasm_output_isnt($code, $unexpected, $description)>

Runs the Parrot Assembler code and passes the test if a string comparison of
the output with the unexpected result is false.

=item C<pasm_error_output_isnt($code, $unexpected, $description)>

Runs the Parrot Assembler code and passes the test if a string comparison of
the output with the unexpected result is false I<and> if Parrot exits with a
non-zero exit cod3.

=item C<pir_output_is($code, $expected, $description)>

Runs the PIR code and passes the test if a string comparison of output with the
expected result is true.

=item C<pir_error_output_is($code, $expected, $description)>

Runs the PIR code and passes the test if a string comparison of output with the
expected result is true I<and> if Parrot exits with a non-zero exit code.

=item C<pir_output_like($code, $expected, $description)>

Runs the PIR code and passes the test if output matches the expected result.

=item C<pir_error_output_like($code, $expected, $description)>

Runs the PIR code and passes the test if output matches the expected result
I<and> if Parrot exits with a non-zero exit code.

=item C<pir_output_isnt($code, $unexpected, $description)>

Runs the PIR code and passes the test if a string comparison of the output with
the unexpected result is false.

=item C<pir_error_output_isnt($code, $unexpected, $description)>

Runs the PIR code and passes the test if a string comparison of the output with
the unexpected result is false I<and> if Parrot exits with a non-zero exit
code.

=item C<pbc_output_is($code, $expected, $description)>

Runs the Parrot Bytecode and passes the test if a string comparison of output
with the expected result is true.

=item C<pbc_error_output_is($code, $expected, $description)>

Runs the Parrot Bytecode and passes the test if a string comparison of output
with the expected result is true I<and> if Parrot exits with a non-zero exit code.

=item C<pbc_output_like($code, $expected, $description)>

Runs the Parrot Bytecode and passes the test if output matches the expected
result.

=item C<pbc_error_output_like($code, $expected, $description)>

Runs the Parrot Bytecode and passes the test if output matches the expected
result I<and> if Parrot exits with a non-zero exit code.

=item C<pbc_output_isnt($code, $unexpected, $description)>

Runs the Parrot Bytecode and passes the test if a string comparison of output
with the unexpected result is false.

=item C<pbc_error_output_isnt($code, $unexpected, $description)>

Runs the Parrot Bytecode and passes the test if a string comparison of output
with the unexpected result is false I<and> if Parrot exits with a non-zero exit
code.

=item C<pir_2_pasm_is($code, $expected, $description)>

Compile the Parrot Intermediate Representation and generate Parrot Assembler Code.
Pass if the generated PASM is $expected.

=item C<pir_2_pasm_like($code, $expected, $description)>

Compile the Parrot Intermediate Representation and generate Parrot Assembler Code.
Pass if the generated PASM matches $expected.

=item C<pir_2_pasm_isnt($code, $unexpected, $description)>

Compile the Parrot Intermediate Representation and generate Parrot Assembler
Code.  Pass unless the generated PASM is $expected.

=item C<c_output_is($code, $expected, $description, %options)>

Compiles and runs the C code, passing the test if a string comparison of output
with the expected result it true.  Valid options are 'todo' => 'reason' to mark
a TODO test.

=item C<c_output_like($code, $expected, $description, %options)>

Compiles and runs the C code, passing the test if output matches the expected
result.  Valid options are 'todo' => 'reason' to mark a TODO test.

=item C<c_output_isnt($code, $unexpected, $description, %options)>

Compiles and runs the C code, passing the test if a string comparison of output
with the unexpected result is false.  Valid options are 'todo' => 'reason' to
mark a TODO test.

=item C<example_output_is( $example_f, $expected, @todo )>

Determine the language from the extension of C<$example_f> and runs
language_output_is().  This I<does> set a description for you, so don't pass
one.

=item C<example_output_like( $example_f, $expected, @todo )>

Determine the language from the extension of C<$example_f> and runs
language_output_like().  This I<does> set a description for you, so don't pass
one.

=item C<example_output_isnt( $example_f, $expected, @todo )>

Determine the language from the extension of C<$example_f> and runs
language_output_isnt().  This I<does> set a description for you, so don't pass
one.

=item C<skip($why, $how_many)>

Use within a C<SKIP: { ... }> block to indicate why and how many tests to skip,
just like in Test::More.

=item C<run_command($command, %options)>

Run the given $command in a cross-platform manner.

%options include...

    STDOUT    filehandle to redirect STDOUT to
    STDERR    filehandle to redirect STDERR to
    CD        directory to run the command in

For example:

    # equivalent to "cd some_dir && make test"
    run_command("make test", CD => "some_dir");

=item C<slurp_file($file_name)>

Read the whole file $file_name and return the content as a string.

=item C<convert_line_endings($text)>

Convert Win32 style line endins with Unix style line endings.

=item C<path_to_parrot()>

Construct a relative path from the current dir to the parrot root dir.

=back

=cut

package Parrot::Test;

use strict;
use warnings;

use Cwd;
use Data::Dumper;
use File::Basename;
use File::Spec;
use Parrot::Config;

require Exporter;
require Test::Builder;
require Test::More;

our @EXPORT = qw( plan run_command skip slurp_file );

use base qw( Exporter );

# tell parrot it's being tested--disables searching of installed libraries.
# (see Parrot_get_runtime_prefix in src/library.c).
$ENV{PARROT_TEST} = 1 unless defined $ENV{PARROT_TEST};

my $builder = Test::Builder->new();

sub import {
    my ( $class, $plan, @args ) = @_;

    $builder->plan( $plan, @args );

    __PACKAGE__->export_to_level( 2, __PACKAGE__ );
}

# this kludge is an hopefully portable way of having
# redirections ( tested on Linux and Win2k )
# An alternative is using Test::Output
sub run_command {
    my ( $command, %options ) = @_;

    # To run the command in a different directory.
    my $chdir = delete $options{CD};

    while ( my ( $key, $value ) = each %options ) {
        $key =~ m/^STD(OUT|ERR)$/
            or die "I don't know how to redirect '$key' yet!";
        $value = File::Spec->devnull
            if $value eq '/dev/null';
    }

    my $out = $options{'STDOUT'} || '';
    my $err = $options{'STDERR'} || '';

    if ( $out and $err and $out eq $err ) {
        $err = "&STDOUT";
    }

    local *OLDOUT if $out;
    local *OLDERR if $err;

    # Save the old filehandles; we must not let them get closed.
    open OLDOUT, '>&STDOUT' or die "Can't save     stdout" if $out;  ## no critic InputOutput::ProhibitBarewordFileHandles 
    open OLDERR, '>&STDERR' or die "Can't save     stderr" if $err;  ## no critic InputOutput::ProhibitBarewordFileHandles 

    open STDOUT, ">", "$out" or die "Can't redirect stdout to $out" if $out;
    open STDERR, ">$err" or die "Can't redirect stderr to $err" if $err;

    # If $command isn't already an arrayref (because of a multi-command
    # test), make it so now so the code below can treat everybody the
    # same.
    $command = [$command] unless ( ref $command );

    if ( defined $ENV{VALGRIND} ) {
        $_ = "$ENV{VALGRIND} $_" for (@$command);
    }

    my $orig_dir;
    if ($chdir) {
        $orig_dir = cwd;
        chdir $chdir;
    }

    # Execute all commands
    # [#42161] [BUG] Parrot::Test throws "Can't spawn" warning on windows
    # ...if a system call returns a negative value
    # removed exec warnings to prevent this warning from messing up test results
    {
        no warnings 'exec';
        system($_) for ( @{$command} );
    }

    if ($chdir) {
        chdir $orig_dir;
    }

    my $exit_code = $?;

    close STDOUT or die "Can't close    stdout" if $out;
    close STDERR or die "Can't close    stderr" if $err;

    open STDOUT, ">&", \*OLDOUT or die "Can't restore  stdout" if $out;
    open STDERR, ">&", \*OLDERR or die "Can't restore  stderr" if $err;

    return (
          ( $exit_code < 0 )    ? $exit_code
        : ( $exit_code & 0xFF ) ? "[SIGNAL $exit_code]"
        : ( $? >> 8 )
    );
}

sub handle_error_output {
    my ( $builder, $real_output, $expected, $desc ) = @_;

    $builder->ok( 0, $desc );
    $builder->diag( "Expected error but exited cleanly\n" .
    "Received:\n$real_output\nExpected:\n$expected\n" );

    return 0;
}

sub per_test {
    my ( $ext, $test_no ) = @_;

    return unless defined $ext and defined $test_no;

    my $t = $0;    # $0 is name of the test script
    $t =~ s/\.t$/_$test_no$ext/;

    return $t;
}

sub write_code_to_file {
    my ( $code, $code_f ) = @_;

    open my $CODE, '>', $code_f or die "Unable to open '$code_f'";
    binmode $CODE;
    print $CODE $code;
    close $CODE;

    return;
}

# We can inherit from Test::More, so we do it.
*plan = \&Test::More::plan;
*skip = \&Test::More::skip;

# What about File::Slurp?
sub slurp_file {
    my ($file_name) = @_;

    open( SLURP, '<', $file_name ) or die "open '$file_name': $!";
    local $/ = undef;
    my $file = <SLURP> . '';
    $file =~ s/\cM\cJ/\n/g;
    close SLURP;

    return $file;
}

sub convert_line_endings {
    my ($text) = @_;

    $text =~ s/\cM\cJ/\n/g;
}

sub path_to_parrot {

    my $path = $INC{'Parrot/Config.pm'};
    $path =~ s{ /lib/Parrot/Config.pm \z}{}xms;
    if ( $path eq q{} ) {
        $path = File::Spec->curdir();
    }

    return $path;
}


# These functions are only used by various
# Parrot::Test::<lang> modules.
# See RT#43266
# This implementation is experimental and currently only works
# for languages/plumhead
sub generate_languages_functions {

    my %test_map = (
        output_is   => 'is_eq',
        output_like => 'like',
        output_isnt => 'isnt_eq'
    );

    foreach my $func ( keys %test_map ) {

        my $test_sub = sub {
            my $self = shift;
            my ( $code, $output, $desc, %options ) = @_;

            # set a TODO for Test::Builder to find
            my $call_pkg = $self->{builder}->exported_to() || '';

            no strict 'refs';

            local *{ $call_pkg . '::TODO' } = \$options{todo}
                if defined $options{todo};

            my $count = $self->{builder}->current_test() + 1;

            # These are the thing that depend on the actual language implementation
            my $out_fn    = $self->get_out_fn( $count,    \%options );
            my $lang_fn   = $self->get_lang_fn( $count,    \%options );
            my $cd        = $self->get_cd( \%options );
            my @test_prog = $self->get_test_prog( $count, \%options );

            Parrot::Test::write_code_to_file( $code, $lang_fn );

            # set a TODO for Test::Builder to find
            my $skip_why = $self->skip_why( \%options );
            if ($skip_why) {
                $self->{builder}->skip($skip_why);
            }
            else {

                # STDERR is written into same output file
                my $exit_code = Parrot::Test::run_command(
                    \@test_prog,
                    CD     => $cd,
                    STDOUT => $out_fn,
                    STDERR => $out_fn
                );

                my $meth = $test_map{$func};

                my $pass = $self->{builder}->$meth( Parrot::Test::slurp_file($out_fn), $output, $desc );
                if ( ! $pass) {
                    my $diag = '';
                    my $test_prog = join ' && ', @test_prog;
                    if ($exit_code) {
                        $diag .= "'$test_prog' failed with exit code $exit_code.";
                    }
                    if ($diag) {
                        $self->{builder}->diag($diag);
                    }
                }
            }

            # The generated files are left in the t/* directories.
            # Let 'make clean' and 'svn:ignore' take care of them.

            return;
        };

        my ( $package ) = caller();

        no strict 'refs';

        *{ $package . '::' . $func } = $test_sub;
    }
}

#
# private methods, should not be used by Modules inheriting from Parrot::Test
#

sub run_test_file
{
    local $SIG{__WARN__}                          = \&report_odd_hash;
    my ( $func, $code, $expected, $desc, %extra ) = @_;

    my $path_to_parrot   = path_to_parrot();
    my $parrot           = File::Spec->join(
        File::Spec->curdir(), 'parrot' . $PConfig{exe} );

    # Strange Win line endings
    convert_line_endings($expected);

    # set up default description
    unless ($desc)
    {
        ( undef, my $file, my $line ) = caller();
        $desc = "($file line $line)";
    }

    # $test_no will be part of temporary file
    my $test_no = $builder->current_test() + 1;

    # Name of the file where output is written.
    # Switch to a different extension when we are generating code.
    my $out_f = per_test( '.out', $test_no );

    # Name of the file with test code.
    # This depends on which kind of code we are testing.
    my $code_f;
    if ( $func =~ m/^pir_.*?output/ )
    {
        $code_f = per_test( '.pir', $test_no );
    }
    elsif ( $func =~ m/^pasm_.*?output_/ )
    {
        $code_f = per_test( '.pasm', $test_no );
    }
    elsif ( $func =~ m/^pbc_.*?output_/ )
    {
        $code_f = per_test( '.pbc', $test_no );
    }
    else
    {
        die "Unknown test function: $func";
    }
    $code_f = File::Spec->rel2abs($code_f);

    # native tests are just run, others need to write code first
    if ( $code_f !~ /\.pbc$/ )
    {
        write_code_to_file( $code, $code_f );
    }

    # honor opt* filename to actually run code with -Ox
    my $args = $ENV{TEST_PROG_ARGS} || '';
    my $opt = $code_f =~ m!opt(.)! ? "-O$1" : "";
    $args .= " $opt";

    my $run_exec = 0;
    if ( $args =~ s/--run-exec// )
    {
        $run_exec = 1;
        my $pbc_f = per_test( '.pbc', $test_no );
        my $o_f = per_test( '_pbcexe' . $PConfig{o}, $test_no );
        my $exe_f =
            per_test( '_pbcexe' . $PConfig{exe}, $test_no )
            ;    # Make cleanup and svn:ignore more simple
        my $exec_f =
            per_test( '_pbcexe', $test_no )
            ;    # Make cleanup and svn:ignore more simple
        $exe_f =~ s@[\\/:]@$PConfig{slash}@g;

        # XXX put this into sub generate_pbc()
        run_command(
            qq{$parrot $args -o $pbc_f "$code_f"},
            CD     => $path_to_parrot,
            STDOUT => $out_f,
            STDERR => $out_f
        );
        if ( -e $pbc_f )
        {
            run_command(
                qq{$parrot $args -o $o_f "$pbc_f"},
                CD     => $path_to_parrot,
                STDOUT => $out_f,
                STDERR => $out_f
            );
            if ( -e $o_f )
            {
                run_command(
                    qq{$PConfig{make} EXEC=$exec_f exec},
                    CD     => $path_to_parrot,
                    STDOUT => $out_f,
                    STDERR => $out_f
                );
                if ( -e $exe_f )
                {
                    run_command(
                        $exe_f,
                        CD     => $path_to_parrot,
                        STDOUT => $out_f,
                        STDERR => $out_f
                    );
                }
            }
        }
    }

    if ( $func =~ /^pbc_output_/ && $args =~ /-r / )
    {

        # native tests with --run-pbc don't make sense
        return $builder->skip("no native tests with -r");
    }

    my ( $exit_code, $cmd );
    unless ($run_exec)
    {
        if ( $args =~ s/--run-pbc// || $args =~ s/-r // )
        {
            my $pbc_f = per_test( '.pbc', $test_no );
            $args = qq{$args -o "$pbc_f"};

            # In this case, we need to execute more than one command. Instead
            # of a single scalar, build an array of commands.
            $cmd = [ qq{$parrot $args "$code_f"}, qq{$parrot "$pbc_f"}, ];
        }
        else
        {
            $cmd = qq{$parrot $args "$code_f"};
        }
        $exit_code = run_command(
            $cmd,
            CD     => $path_to_parrot,
            STDOUT => $out_f,
            STDERR => $out_f
        );
    }

    return ( $out_f, $cmd, $exit_code );
}

sub _generate_functions {
    my $package = 'Parrot::Test';

    my $path_to_parrot = path_to_parrot();
    my $parrot = File::Spec->join( File::Spec->curdir(), 'parrot' . $PConfig{exe} );

    my %parrot_test_map = (
        pbc_output_is      => 'is_eq',
        pbc_output_isnt    => 'isnt_eq',
        pbc_output_like    => 'like',
        pbc_output_unlike  => 'unlike',
        pasm_output_is     => 'is_eq',
        pasm_output_isnt   => 'isnt_eq',
        pasm_output_like   => 'like',
        pasm_output_unlike => 'unlike',
        pir_output_is      => 'is_eq',
        pir_output_isnt    => 'isnt_eq',
        pir_output_like    => 'like',
        pir_output_unlike  => 'unlike',
    );

    for my $func ( keys %parrot_test_map ) {
        (my $error_func = $func) =~ s/_output/_error_output/;
        $parrot_test_map{ $error_func } = $parrot_test_map{ $func };
    }

    for my $func ( keys %parrot_test_map ) {
        push @EXPORT, $func;

        my $test_sub = sub {
            my ( $code, $expected, $desc, %extra ) = @_;
            my ( $out_f, $cmd, $exit_code )        = run_test_file( $func, @_ );

            my $meth        = $parrot_test_map{$func};
            my $real_output = slurp_file($out_f);

            unlink $out_f unless $ENV{POSTMORTEM};

            # set a TODO for Test::Builder to find
            my $call_pkg = $builder->exported_to() || '';

            no strict 'refs';
            local *{ $call_pkg . '::TODO' } = \$extra{todo}
                if defined $extra{todo};

            if ($func =~ /_error_/) {
                return handle_error_output(
                    $builder, $real_output, $expected, $desc
                ) unless $exit_code;
            }
            elsif ($exit_code) {
                $builder->ok( 0, $desc );
                $builder->diag( "Exited with error code: $exit_code\n" .
                    "Received:\n$real_output\nExpected:\n$expected\n" );
                return 0;
            }

            my $pass = $builder->$meth( $real_output, $expected, $desc );
            $builder->diag("'$cmd' failed with exit code $exit_code")
                if not $pass and $exit_code;

            return $pass;
        };

        no strict 'refs';

        *{ $package . '::' . $func } = $test_sub;
    }

    my %pir_2_pasm_test_map = (
        pir_2_pasm_is     => 'is_eq',
        pir_2_pasm_isnt   => 'isnt_eq',
        pir_2_pasm_like   => 'like',
        pir_2_pasm_unlike => 'unlike',
    );

    foreach my $func ( keys %pir_2_pasm_test_map ) {
        push @EXPORT, $func;
        no strict 'refs';

        my $test_sub = sub {
            my ( $code, $expected, $desc, %extra ) = @_;

            # Strange Win line endings
            convert_line_endings($expected);

            # set up default description
            unless ($desc) {
                ( undef, my $file, my $line ) = caller();
                $desc = "($file line $line)";
            }

            # $test_no will be part of temporary file
            my $test_no = $builder->current_test() + 1;

            # Name of the file with test code.
            my $code_f = File::Spec->rel2abs( per_test( '.pir', $test_no ) );

            # output file
            my $out_f = per_test( '.pasm', $test_no );

            my $opt = $code_f =~ m!opt(.)! ? "-O$1" : "-O1";
            my $args = $ENV{TEST_PROG_ARGS} || '';
            $args .= " $opt --output=$out_f";
            $args =~ s/--run-exec//;

            write_code_to_file( $code, $code_f );

            my $cmd       = qq{$parrot $args "$code_f"};
            my $exit_code = run_command(
                $cmd,
                CD     => $path_to_parrot,
                STDOUT => $out_f,
                STDERR => $out_f
            );

            my $meth        = $pir_2_pasm_test_map{$func};
            my $real_output = slurp_file($out_f);
            {

                # The parrot open '--outfile=file.pasm' seems to create unnecessary whitespace
                $real_output =~ s/^\s*$//gm;
                $real_output =~ s/[\t ]+/ /gm;
                $real_output =~ s/ +$//gm;

                $expected =~ s/[\t ]+/ /gm;
            }

            # set a TODO for Test::Builder to find
            my $call_pkg = $builder->exported_to() || '';

            local *{ $call_pkg . '::TODO' } = \$extra{todo}
                if defined $extra{todo};

            my $pass = $builder->$meth( $real_output, $expected, $desc );
            $builder->diag("'$cmd' failed with exit code $exit_code")
                if $exit_code and not $pass;

            if ( ! $ENV{POSTMORTEM} ) {
                unlink $out_f;
            }

            return $pass;
        };

        no strict 'refs';

        *{ $package . '::' . $func } = $test_sub;
    }

    my %builtin_language_prefix = (
        PIR_IMCC  => 'pir',
        PASM_IMCC => 'pasm',
    );

    my %language_test_map = (
        language_output_is   => 'output_is',
        language_output_like => 'output_like',
        language_output_isnt => 'output_isnt',
    );

    foreach my $func ( keys %language_test_map ) {
        push @EXPORT, $func;

        my $test_sub = sub {
            my ( $language, @remaining ) = @_;

            my $meth = $language_test_map{$func};
            if ( my $prefix = $builtin_language_prefix{$language} ) {

                # builtin languages are no tested with the example_output_xx() functions
                my $level = $builder->level();
                $builder->level( $level + 2 );
                my $test_func = "${package}::${prefix}_${meth}";

                no strict 'refs';

                $test_func->(@remaining);
                $builder->level($level);
            }
            else {

                # TODO: $language should be the name of the test Module
                #       that would open the door for Scheme::Test
                $language = ucfirst($language);

                # make sure TODO will work, by telling Test::Builder which
                # package the .t file is in (one more than usual, due to the
                # extra layer of package indirection
                my $level = $builder->level();
                $builder->level(2);

                # Load module that knows how to test the language implementation
                require "Parrot/Test/$language.pm";
                my $class = "Parrot::Test::${language}";

                # set the builder object, and parrot config.
                my $obj = $class->new();
                $obj->{builder} = $builder;
                $obj->{relpath} = $path_to_parrot;
                $obj->{parrot}  = $parrot;
                $obj->$meth(@remaining);

                # restore prior level, just in case.
                $builder->level($level);
            }
        };

        no strict 'refs';

        *{ $package . '::' . $func } = $test_sub;
    }

    # XXX this is broken WRT todo tests
    my %example_test_map = (
        example_output_is   => 'language_output_is',
        example_output_like => 'language_output_like',
        example_output_isnt => 'language_output_isnt',
    );

    foreach my $func ( keys %example_test_map ) {
        push @EXPORT, $func;

        my $test_sub = sub {
            my ( $example_f, $expected, @options ) = @_;

            my %lang_for_extension = (
                pasm => 'PASM_IMCC',
                pir  => 'PIR_IMCC',
            );

            my ($extension) = $example_f =~ m{ [.]                    # introducing extension
                                               ( pasm | pir )         # match and capture the extension
                                               \z                     # at end of string
                                             }ixms or Usage();
            if ( defined $extension ) {
                my $code      = slurp_file($example_f);
                my $test_func = join( '::', $package, $example_test_map{$func} );

                no strict 'refs';

                $test_func->(
                    $lang_for_extension{$extension},
                    $code, $expected, $example_f, @options
                );
            }
            else {
                fail( defined $extension, "no extension recognized for $example_f" );
            }
        };

        no strict 'refs';

        *{ $package . '::' . $func } = $test_sub;
    }

    my %c_test_map = (
        c_output_is   => 'is_eq',
        c_output_isnt => 'isnt_eq',
        c_output_like => 'like'
    );

    foreach my $func ( keys %c_test_map ) {
        push @EXPORT, $func;

        my $test_sub = sub {
            my ( $source, $expected, $desc, %options ) = @_;

            # $test_no will be part of temporary file
            my $test_no = $builder->current_test() + 1;

            $expected    =~ s/\cM\cJ/\n/g;
            my $source_f = per_test( '.c',          $test_no );
            my $obj_f    = per_test( $PConfig{o},   $test_no );
            my $exe_f    = per_test( $PConfig{exe}, $test_no );
            $exe_f       =~ s@[\\/:]@$PConfig{slash}@g;
            my $out_f    = per_test( '.out',   $test_no );
            my $build_f  = per_test( '.build', $test_no );
            my $pdb_f    = per_test( '.pdb',   $test_no );
            my $ilk_f    = per_test( '.ilk',   $test_no );

            open my $SOURCE, '>', $source_f or die "Unable to open '$source_f'";
            binmode $SOURCE;
            print $SOURCE "/* DO NOT EDIT - Autogenerated test file */\n";
            print $SOURCE $source;
            close $SOURCE;

            my $libparrot_shared = "$PConfig{rpath_blib} -L$PConfig{blib_dir} -lparrot";
            my $libparrot_static =
                $PConfig{blib_dir} . $PConfig{slash} . $PConfig{libparrot_static};

            my $libparrot = $PConfig{parrot_is_shared} ? $libparrot_shared : $libparrot_static;

            my $iculibs = "";
            if ( $PConfig{'has_icu'} ) {
                $iculibs = $PConfig{icu_shared};
            }

            # set TODO before trying to compile or link
            local *main::TODO;
            *main::TODO = \$options{todo} if $options{todo};

            my ( $cmd, $exit_code );
            $cmd =
                  "$PConfig{cc} $PConfig{ccflags} $PConfig{cc_debug} "
                . " -I./include -c "
                . "$PConfig{cc_o_out}$obj_f $source_f";
            $exit_code = run_command(
                $cmd,
                'STDOUT' => $build_f,
                'STDERR' => $build_f
            );
            $builder->diag("'$cmd' failed with exit code $exit_code")
                if $exit_code;

            if ( !-e $obj_f ) {
                $builder->diag( "Failed to build '$obj_f': " . slurp_file($build_f) );
                unlink $build_f;
                $builder->ok( 0, $desc );
                return 0;
            }

            my $cfg = "src$PConfig{slash}parrot_config$PConfig{o}";
            $cmd =
                  "$PConfig{link} $PConfig{linkflags} $PConfig{ld_debug} "
                . "$obj_f $cfg $PConfig{ld_out}$exe_f "
                . "$libparrot $iculibs $PConfig{libs}";
            $exit_code = run_command(
                $cmd,
                'STDOUT' => $build_f,
                'STDERR' => $build_f
            );
            $builder->diag("'$cmd' failed with exit code $exit_code")
                if $exit_code;

            if ( !-e $exe_f ) {
                $builder->diag( "Failed to build '$exe_f': " . slurp_file($build_f) );
                unlink $build_f;
                $builder->ok( 0, $desc );

                return 0;
            }

            $cmd       = ".$PConfig{slash}$exe_f";
            $exit_code = run_command( $cmd, 'STDOUT' => $out_f, 'STDERR' => $out_f );
            my $output = slurp_file($out_f);
            my $pass;

            if ($exit_code) {
                $pass = $builder->ok(0, $desc);
                $builder->diag("Exited with error code: $exit_code\n" .
                    "Received:\n$output\nExpected:\n$expected\n" );
            }
            else {
                my $meth = $c_test_map{$func};
                $pass    = $builder->$meth($output, $expected, $desc);
                $builder->diag("'$cmd' failed with exit code $exit_code")
                    unless $pass;
            }

            unless ( $ENV{POSTMORTEM} ) {
                unlink $out_f, $build_f, $exe_f, $obj_f, $pdb_f, $ilk_f;
            }

            return $pass;
        };

        no strict 'refs';

        *{ $package . '::' . $func } = $test_sub;
    }

    return;
}

Parrot::Test::_generate_functions();

=head1 SEE ALSO

=over 4

=item F<t/harness>

=item F<docs/tests.pod>

=item L<Test/More>

=item L<Test/Builder>

=back

=cut

sub report_odd_hash {
    my $warning = shift;
    if ( $warning =~ m/Odd number of elements in hash assignment/ ) {
        require Carp;
        my @args = DB::uplevel_args();
        shift @args;
        my $func = ( caller() )[2];

        Carp::carp("Odd $func invocation; probably missing description for TODO test");
    }
    else {
        warn $warning;
    }
}

package DB;

sub uplevel_args {
    my @foo = caller(2);

    return @DB::args;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
