#! perl
# Copyright (C) 2001-2008, The Perl Foundation.
# $Id$

=head1 NAME

t/perl/Parrot_Test.t - Parrot::Test unit tests

=head1 SYNOPSIS

    % prove t/perl/Parrot_Test.t

=head1 DESCRIPTION

These tests cover the basic functionality of C<Parrot::Test>.

=cut

use strict;
use warnings;
use Test::More;
use File::Spec;
use lib qw( lib );
use Parrot::Config;
use IO::CaptureOutput qw| capture |;

BEGIN {
    eval "use Test::Builder::Tester;";
    if ($@) {
        plan( skip_all => "Test::Builder::Tester not installed\n" );
        exit 0;
    }
    plan( tests => 96 );
}

use lib qw( . lib ../lib ../../lib );

BEGIN {
    my $pre_env = exists $ENV{PARROT_TEST} ? $ENV{PARROT_TEST} : undef;
    use_ok('Parrot::Test') or die;

    my $post_env = exists $ENV{PARROT_TEST} ? $ENV{PARROT_TEST} : undef;
    if ( defined $pre_env ) {
        is( $post_env, $pre_env, 'PARROT_TEST env unchanged' );
    }
    else {
        is( $post_env, 1, 'PARROT_TEST env set' );
    }
}

can_ok( 'Parrot::Test', $_ ) for qw/
    c_output_is                     c_output_isnt
    c_output_like
    example_output_is               example_output_isnt
    example_output_like
    language_error_output_is        language_error_output_isnt
    language_error_output_like
    language_output_is              language_output_isnt
    language_output_like
    pasm_error_output_is            pasm_error_output_isnt
    pasm_error_output_like          pasm_error_output_unlike
    pasm_output_is                  pasm_output_isnt
    pasm_output_like                pasm_output_unlike
    pbc_error_output_is             pbc_error_output_isnt
    pbc_error_output_like           pbc_error_output_unlike
    pbc_output_is                   pbc_output_isnt
    pbc_output_like                 pbc_output_unlike
    pir_error_output_is             pir_error_output_isnt
    pir_error_output_like           pir_error_output_unlike
    pir_output_is                   pir_output_isnt
    pir_output_like                 pir_output_unlike
    pir_2_pasm_is                   pir_2_pasm_isnt
    pir_2_pasm_like                 pir_2_pasm_unlike
    generate_languages_functions
    per_test
    plan
    skip
    slurp_file
    run_command
    write_code_to_file
    /;

# RT#46891 test run_command()

# per_test
is( Parrot::Test::per_test(), undef, 'per_test() no args' );
is( Parrot::Test::per_test( undef, 0 ),     undef, 'per_test() invalid first arg' );
is( Parrot::Test::per_test( 0,     undef ), undef, 'per_test() invalid second arg' );
is( Parrot::Test::per_test( undef, undef ), undef, 'per_test() two invalid args' );

# RT#46893 test write_code_to_file(), plan(), skip(), slurp_file()

# test the test functions from Parrot::Test
# RT#46893: test the untested test functions
my ( $desc, $err, $line );

# PASM
$desc = 'pasm_output_is: success';
test_out("ok 1 - $desc");
pasm_output_is( <<'CODE', <<'OUTPUT', $desc );
    print "foo\n"
    end
CODE
foo
OUTPUT
test_test($desc);

$desc = 'pasm_output_is: failure';
test_out("not ok 1 - $desc");
test_fail(+9);
$err = <<"ERR";
#          got: 'foo
# '
#     expected: 'bar
# '
ERR
chomp $err;
test_err($err);
pasm_output_is( <<'CODE', <<"OUTPUT", $desc );
    print "foo\n"
    end
CODE
bar
OUTPUT
test_test($desc);

$desc = 'pasm_output_isnt: success';
test_out("ok 1 - $desc");
pasm_output_isnt( <<'CODE', <<"OUTPUT", $desc );
    print "foo\n"
    end
CODE
bar
OUTPUT
test_test($desc);


# The exact error output for pasm_output_isnt() depends on the version of Test::Builder.
# So, in order to avoid version dependent failures, be content with checking the
# standard output.
$desc = 'pasm_output_isnt: failure';
test_out("not ok 1 - $desc");
test_fail(+10);
$err = <<"ERR";
#     'foo
# '
#         ne
#     'foo
# '
ERR
chomp $err;
test_err( $err );
pasm_output_isnt( <<'CODE', <<'OUTPUT', $desc );
    print "foo\n"
    end
CODE
foo
OUTPUT
test_test(title => $desc, skip_err => 1);

$desc = 'pasm_output_like: success';
test_out("ok 1 - $desc");
pasm_output_like( <<'CODE', <<'OUTPUT', $desc );
    print "foo\n"
    end
CODE
/foo/
OUTPUT
test_test($desc);

$desc = 'pasm_output_like: failure';
test_out("not ok 1 - $desc");
test_fail(+9);
$err = <<"ERR";
#                   'foo
# '
#     doesn't match '/bar/
# '
ERR
chomp $err;
test_err($err);
pasm_output_like( <<'CODE', <<"OUTPUT", $desc );
    print "foo\n"
    end
CODE
/bar/
OUTPUT
test_test($desc);

# PIR
$desc = 'pir_output_is: success';
test_out("ok 1 - $desc");
pir_output_is( <<'CODE', <<'OUTPUT', $desc );
.sub 'test' :main
    print "foo\n"
.end
CODE
foo
OUTPUT
test_test($desc);

$desc = 'pir_output_is: failure';
test_out("not ok 1 - $desc");
test_fail(+9);
$err = <<"ERR";
#          got: 'foo
# '
#     expected: 'bar
# '
ERR
chomp $err;
test_err($err);
pir_output_is( <<'CODE', <<"OUTPUT", $desc );
.sub 'test' :main
    print "foo\n"
.end
CODE
bar
OUTPUT
test_test($desc);

$desc = 'pir_output_isnt: success';
test_out("ok 1 - $desc");
pir_output_isnt( <<'CODE', <<"OUTPUT", $desc );
.sub 'test' :main
    print "foo\n"
.end
CODE
bar
OUTPUT
test_test($desc);

# The exact error output for pir_output_isnt() depends on the version of Test::Builder.
# So, in order to avoid version dependent failures, be content with checking the
# standard output.
$desc = 'pir_output_isnt: failure';
test_out("not ok 1 - $desc");
test_fail(+10);
$err = <<"ERR";
#     'foo
# '
#         ne
#     'foo
# '
ERR
chomp $err;
test_err($err);
pir_output_isnt( <<'CODE', <<'OUTPUT', $desc );
.sub 'test' :main
    print "foo\n"
.end
CODE
foo
OUTPUT
test_test(title => $desc, skip_err => 1);

$desc = 'pir_output_like: success';
test_out("ok 1 - $desc");
pir_output_like( <<'CODE', <<'OUTPUT', $desc );
.sub 'test' :main
    print "foo\n"
.end
CODE
/foo/
OUTPUT
test_test($desc);

$desc = 'pir_output_like: failure';
test_out("not ok 1 - $desc");
test_fail(+9);
$err = <<"ERR";
#                   'foo
# '
#     doesn't match '/bar/
# '
ERR
chomp $err;
test_err($err);
pir_output_like( <<'CODE', <<"OUTPUT", $desc );
.sub 'test' :main
    print "foo\n"
.end
CODE
/bar/
OUTPUT
test_test($desc);

$desc = 'pir_error_output_like: todo';
$line = line_num(+21);
my $location;
if ($Test::Builder::VERSION <= eval '0.33') {
    $location = "in $0 at line $line";
} else {
    $location = "at $0 line $line";
}
test_out("not ok 1 - $desc # TODO foo");
$err = <<"ERR";
#   Failed (TODO) test '$desc'
#   $location.
# Expected error but exited cleanly
# Received:
# foo
# 
# Expected:
# /bar/
# 
ERR
chomp $err;
test_err($err);
pir_error_output_like( <<'CODE', <<"OUTPUT", $desc, todo => 'foo' );
.sub 'test' :main
    print "foo\n"
.end
CODE
/bar/
OUTPUT
if($Test::Builder::VERSION == 0.84) {
    test_test(title => $desc, skip_err => 1);
} else {
    test_test($desc);
}

##### Tests for Parrot::Test internal subroutines #####

# _handle_test_options()
my ( $out, $chdir );
( $out, $err, $chdir ) = Parrot::Test::_handle_test_options( {
    STDOUT  => '/tmp/captureSTDOUT',
    STDERR  => '/tmp/captureSTDERR',
    CD      => '/tmp',
} );
is($out, '/tmp/captureSTDOUT', "Got expected value for STDOUT");
is($err, '/tmp/captureSTDERR', "Got expected value for STDERR");
is($chdir, '/tmp', "Got expected value for working directory");

( $out, $err, $chdir ) = Parrot::Test::_handle_test_options( {
    STDOUT  => '/tmp/captureSTDOUT',
    STDERR  => '',
    CD      => '/tmp',
} );
is($out, '/tmp/captureSTDOUT', "Got expected value for STDOUT");
is($err, '', "Got expected value for STDERR");
is($chdir, '/tmp', "Got expected value for working directory");

( $out, $err, $chdir ) = Parrot::Test::_handle_test_options( {
    STDOUT  => '',
    STDERR  => '',
    CD      => '',
} );
is($out, '', "Got expected value for STDOUT");
is($err, '', "Got expected value for STDERR");
is($chdir, '', "Got expected value for working directory");

eval {
    ( $out, $err, $chdir ) = Parrot::Test::_handle_test_options( {
        STDJ    => '',
        STDERR  => '',
        CD      => '',
    } );
};
like($@, qr/I don't know how to redirect 'STDJ' yet!/,
    "Got expected error message for bad option");

my $dn = File::Spec->devnull();
( $out, $err, $chdir ) = Parrot::Test::_handle_test_options( {
    STDOUT  => '',
    STDERR  => '/dev/null',
    CD      => '',
} );
is($out, '', "Got expected value for STDOUT");
is($err, $dn, "Got expected value for STDERR using /dev/null");
is($chdir, '', "Got expected value for working directory");

( $out, $err, $chdir ) = Parrot::Test::_handle_test_options( {
    STDOUT  => '/tmp/foobar',
    STDERR  => '/tmp/foobar',
    CD      => '',
} );
is($out, '/tmp/foobar', "Got expected value for STDOUT");
is($err, '&STDOUT', "Got expected value for STDERR when same as STDOUT");
is($chdir, '', "Got expected value for working directory");

{
    my $oldpath = $ENV{PATH};
    my $oldldrunpath = $ENV{LD_RUN_PATH};
    local $PConfig{build_dir} = 'foobar';
    my $blib_path = File::Spec->catfile( $PConfig{build_dir}, 'blib', 'lib' );
    {
        local $^O = 'cygwin';
        Parrot::Test::_handle_blib_path();
        is( $ENV{PATH}, $blib_path . ':' . $oldpath,
            "\$ENV{PATH} reset as expected for $^O");
        $ENV{PATH} = $oldpath;
    }
    {
        local $^O = 'MSWin32';
        Parrot::Test::_handle_blib_path();
        is( $ENV{PATH}, $blib_path . ';' . $oldpath,
            "\$ENV{PATH} reset as expected for $^O");
        $ENV{PATH} = $oldpath;
    }
    {
        local $^O = 'not_cygwin_not_MSWin32';
        Parrot::Test::_handle_blib_path();
        is( $ENV{LD_RUN_PATH}, $blib_path,
            "\$ENV{LD_RUN_PATH} reset as expected for $^O");
        $ENV{LD_RUN_PATH} = $oldldrunpath;
    }
}

my $command_orig;
$command_orig = 'ls';
is_deeply( Parrot::Test::_handle_command($command_orig), [ qw( ls ) ],
    "Scalar command transformed into array ref as expected");
$command_orig = [ qw( ls -l ) ];
is( Parrot::Test::_handle_command($command_orig), $command_orig,
    "Array ref holding multiple commands unchanged as expected");

{
    my $oldvalgrind = $ENV{VALGRIND};
    $command_orig = 'ls';
    my $foo = 'foobar';
    local $ENV{VALGRIND} = $foo;
    my $ret = Parrot::Test::_handle_command($command_orig);
    is( $ret->[0], "$foo $command_orig",
        "Got expected value in Valgrind environment");
    $ENV{VALGRIND} = $oldvalgrind;
}

{
    local $? = -1;
    my $exit_message = Parrot::Test::_prepare_exit_message();
    is( $exit_message, -1, "Got expected exit message" );
}

{
    local $? = 0;
    my $exit_message = Parrot::Test::_prepare_exit_message();
    is( $exit_message, 0, "Got expected exit message" );
}

{
    local $? = 1;
    my $exit_message = Parrot::Test::_prepare_exit_message();
    is( $exit_message, q{[SIGNAL 1]}, "Got expected exit message" );
}

{
    local $? = 255;
    my $exit_message = Parrot::Test::_prepare_exit_message();
    is( $exit_message, q{[SIGNAL 255]}, "Got expected exit message" );
}

{
    local $? = 256;
    my $exit_message = Parrot::Test::_prepare_exit_message();
    is( $exit_message, 1, "Got expected exit message" );
}

{
    local $? = 512;
    my $exit_message = Parrot::Test::_prepare_exit_message();
    is( $exit_message, 2, "Got expected exit message" );
}

{
    my $text = q{Hello, world};
    my $cmd = "$^X -e 'print qq{$text\n};'";
    my $exit_message;
    my ($stdout, $stderr);
    capture(
        sub {
            $exit_message = run_command(
            $cmd,
            'CD' => '',
        ); },
        \$stdout,
        \$stderr,
    );
    like($stdout, qr/$text/, "Captured STDOUT");
    is($exit_message, 0, "Got 0 as exit message");
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
