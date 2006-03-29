#! perl
# Copyright: 2001-2006 The Perl Foundation.  All Rights Reserved.
# $Id$

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
BEGIN {
    eval "use Test::Builder::Tester;";
    if ($@) {
        print "1..0 # Skip Test::Builder::Tester not installed\n";
        exit 0;
    }
} 
use Test::More;


=head1 NAME

t/perl/Parrot_Test.t - Parrot::Test unit tests

=head1 SYNOPSIS

    % prove t/perl/Parrot_Test.t

=head1 DESCRIPTION

These tests cover the basic functionality of C<Parrot::Test>.

=cut


BEGIN
{
    my $pre_env = exists $ENV{PARROT_TEST} ? $ENV{PARROT_TEST} : undef;
    use_ok('Parrot::Test') or die;
    my $post_env = exists $ENV{PARROT_TEST} ? $ENV{PARROT_TEST} : undef;
    if( defined $pre_env )
    { is( $post_env, $pre_env, 'PARROT_TEST env unchanged' ); }
    else
    { is( $post_env, 1, 'PARROT_TEST env set' ); }
}


can_ok('Parrot::Test', $_) for qw/
    language_output_is language_output_like language_output_isnt
    example_output_is
    pasm_output_is     pasm_output_like     pasm_output_isnt
    past_output_is     past_output_like     past_output_isnt
    pir_output_is      pir_output_like      pir_output_isnt
    pir_2_pasm_is      pir_2_pasm_like      pir_2_pasm_isnt
    pbc_output_is      pbc_output_like      pbc_output_isnt
    c_output_is        c_output_like        c_output_isnt
    plan
    skip
    slurp_file
    run_command
/;


## TODO run_command


## per_test
is( Parrot::Test::per_test(), undef, 'per_test() no args' );
is( Parrot::Test::per_test(undef, 0), undef, 'per_test() invalid first arg' );
is( Parrot::Test::per_test(0, undef), undef, 'per_test() invalid second arg' );
is( Parrot::Test::per_test(undef, undef), undef, 'per_test() two invalid args' );


### TODO write_code_to_file, plan, skip, slurp_file, _generate_functions, example_output_is


## test functions generated by Parrot::Test
my( $desc, $err, $line );

## PASM
$desc = 'pasm_output_is: success';
test_out "ok 1 - $desc";
pasm_output_is <<'CODE', <<'OUTPUT', $desc;
    print "ok\n"
    end
CODE
ok
OUTPUT
test_test $desc;

$desc = 'pasm_output_is: failure';
$line = line_num(+11);
test_out "not ok 1 - $desc";
$err = <<ERR;
#     Failed test ($0 at line $line)
#          got: 'ok
# '
#     expected: 'not ok
# '
ERR
chomp $err;
test_err $err;
pasm_output_is <<'CODE', <<"OUTPUT", $desc;
    print "ok\n"
    end
CODE
not ok
OUTPUT
test_test $desc;


$desc = 'pasm_output_isnt: success';
test_out "ok 1 - $desc";
pasm_output_isnt <<'CODE', <<"OUTPUT", $desc;
    print "ok\n"
    end
CODE
not ok
OUTPUT
test_test $desc;

$desc = 'pasm_output_isnt: failure';
$line = line_num(+12);
test_out "not ok 1 - $desc";
$err = <<ERR;
#     Failed test ($0 at line $line)
#     'ok
# '
#         ne
#     'ok
# '
ERR
chomp $err;
test_err $err;
pasm_output_isnt <<'CODE', <<'OUTPUT', $desc;
    print "ok\n"
    end
CODE
ok
OUTPUT
test_test $desc;


$desc = 'pasm_output_like: success';
test_out "ok 1 - $desc";
pasm_output_like <<'CODE', <<'OUTPUT', $desc;
    print "ok\n"
    end
CODE
/ok/
OUTPUT
test_test $desc;

$desc = 'pasm_output_like: failure';
$line = line_num(+11);
test_out "not ok 1 - $desc";
$err = <<ERR;
#     Failed test ($0 at line $line)
#                   'ok
# '
#     doesn't match '/not ok/
# '
ERR
chomp $err;
test_err $err;
pasm_output_like <<'CODE', <<"OUTPUT", $desc;
    print "ok\n"
    end
CODE
/not ok/
OUTPUT
test_test $desc;


## PIR
$desc = 'pir_output_is: success';
test_out "ok 1 - $desc";
pir_output_is <<'CODE', <<'OUTPUT', $desc;
.sub 'test' :main
    print "ok\n"
.end
CODE
ok
OUTPUT
test_test $desc;

$desc = 'pir_output_is: failure';
$line = line_num(+11);
test_out "not ok 1 - $desc";
$err = <<ERR;
#     Failed test ($0 at line $line)
#          got: 'ok
# '
#     expected: 'not ok
# '
ERR
chomp $err;
test_err $err;
pir_output_is <<'CODE', <<"OUTPUT", $desc;
.sub 'test' :main
    print "ok\n"
.end
CODE
not ok
OUTPUT
test_test $desc;


$desc = 'pir_output_isnt: success';
test_out "ok 1 - $desc";
pir_output_isnt <<'CODE', <<"OUTPUT", $desc;
.sub 'test' :main
    print "ok\n"
.end
CODE
not ok
OUTPUT
test_test $desc;

$desc = 'pir_output_isnt: failure';
$line = line_num(+12);
test_out "not ok 1 - $desc";
$err = <<ERR;
#     Failed test ($0 at line $line)
#     'ok
# '
#         ne
#     'ok
# '
ERR
chomp $err;
test_err $err;
pir_output_isnt <<'CODE', <<'OUTPUT', $desc;
.sub 'test' :main
    print "ok\n"
.end
CODE
ok
OUTPUT
test_test $desc;


$desc = 'pir_output_like: success';
test_out "ok 1 - $desc";
pir_output_like <<'CODE', <<'OUTPUT', $desc;
.sub 'test' :main
    print "ok\n"
.end
CODE
/ok/
OUTPUT
test_test $desc;

$desc = 'pir_output_like: failure';
$line = line_num(+11);
test_out "not ok 1 - $desc";
$err = <<ERR;
#     Failed test ($0 at line $line)
#                   'ok
# '
#     doesn't match '/not ok/
# '
ERR
chomp $err;
test_err $err;
pir_output_like <<'CODE', <<"OUTPUT", $desc;
.sub 'test' :main
    print "ok\n"
.end
CODE
/not ok/
OUTPUT
test_test $desc;


## vim: expandtab sw=4
## remember to change the number of tests :-)
BEGIN { plan tests => 42; }
