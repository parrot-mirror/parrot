#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id: 01-options.t 17739 2007-03-25 19:38:47Z jkeenan $
# 01-options.t

use strict;
use warnings;

BEGIN {
    use FindBin qw($Bin);
    use Cwd qw(cwd realpath);
    realpath($Bin) =~ m{^(.*\/parrot)\/[^/]*\/[^/]*\/[^/]*$};
    our $topdir = $1;
    if ( defined $topdir ) {
        print "\nOK:  Parrot top directory located\n";
    }
    else {
        $topdir = realpath($Bin) . "/../../..";
    }
    unshift @INC, qq{$topdir/lib};
}
use Test::More qw(no_plan); # tests => 10;
use Carp;
use Data::Dumper;
use_ok('Parrot::Configure::Options', qw| process_options | );
use_ok("Parrot::IO::Capture::Mini");

my $parrot_version = '0.4.10';
my $svnid = '$Id: Configure.pl 17734 2007-03-25 16:39:07Z jkeenan $';
my ($args);

$args = process_options( {
    argv            => [],
    script          => $0,
    parrot_version  => $parrot_version,
    svnid           => $svnid,
} );
ok(defined $args, "process_options() returned successfully");
ok($args->{debugging}, "debugging turned on by default");

eval {
    $args = process_options( {
        argv            => [],
        script          => $0,
        svnid           => $svnid,
    } );
};
like($@, qr/Must provide argument 'parrot_version'/,
    "process_options() failed due to lack of argument 'parrot_version'");

eval {
    $args = process_options( {
        argv            => [],
        script          => $0,
        parrot_version  => $parrot_version,
    } );
};
like($@, qr/Must provide argument 'svnid'/,
    "process_options() failed due to lack of argument 'svnid'");

$args = process_options( {
    script          => $0,
    parrot_version  => $parrot_version,
    svnid           => $svnid,
} );
ok(defined $args,
    "process_options() returned successfully even though no explicit 'argv' key was provided");

$args = process_options( {
    argv            => [],
    parrot_version  => $parrot_version,
    svnid           => $svnid,
} );
ok(defined $args,
    "process_options() returned successfully even though no explicit 'scripts' key was provided");

my $CC = "/usr/bin/gcc-3.3";
my $CX = "/usr/bin/g++-3.3";
$args = process_options( {
    argv            => [
        q{--cc=$CC},
        q{--cxx=$CX},
        q{--link=$CX},
        q{--ld=$CX},
        q{--without-icu},
        q{--without-gmp},
    ],
    script          => $0,
    parrot_version  => $parrot_version,
    svnid           => $svnid,
} );
ok(defined $args,
    "process_options() returned successfully when options were specified");

my $badoption = q{samsonanddelilah};
eval {
    $args = process_options( {
        argv            => [ qq<--${badoption}=72> ],
        script          => $0,
        parrot_version  => $parrot_version,
        svnid           => $svnid,
    } );
};
like($@, qr/^Invalid option $badoption/,
    "process_options() failed due to bad option '$badoption'");

{
    my ($tie, $rv, $msg);
    $tie = tie *STDOUT, "Parrot::IO::Capture::Mini"
            or croak "Unable to tie";
    $args = process_options( {
        argv            => [ q{--help} ],
        script          => $0,
        parrot_version  => $parrot_version,
        svnid           => $svnid,
    } );
    ok(! defined $args,
        "process_options() returned undef after 'help' option");
    $msg = $tie->READLINE;
    like($msg, qr/--help/i,
        "got correct message after 'version' option");
}

{
    my ($tie, $rv, $msg);
    $tie = tie *STDOUT, "Parrot::IO::Capture::Mini"
            or croak "Unable to tie";
    $args = process_options( {
        argv            => [ q{--} ],
        script          => $0,
        parrot_version  => $parrot_version,
        svnid           => $svnid,
    } );
    ok(! defined $args,
        "process_options() returned undef after 'help' option: case '--'");
    $msg = $tie->READLINE;
    like($msg, qr/--help/i,
        "got correct message after 'version' option");
}

{
    my ($tie, $rv, $msg);
    $tie = tie *STDOUT, "Parrot::IO::Capture::Mini"
            or croak "Unable to tie";
    $args = process_options( {
        argv            => [ q{--version} ],
        script          => $0,
        parrot_version  => $parrot_version,
        svnid           => $svnid,
    } );
    ok(! defined $args,
        "process_options() returned undef after 'version' option");
    $msg = $tie->READLINE;
    like($msg, qr/Parrot Version/i,
        "got correct message after 'version' option");
}

$args = process_options( {
    argv            => [ q{--lex}, ],
    script          => $0,
    parrot_version  => $parrot_version,
    svnid           => $svnid,
} );
ok(defined $args,
    "process_options() returned successfully after 'lex' option");
ok($args->{maintainer}, "'maintainer' attribute is true after 'lex' option");

$args = process_options( {
    argv            => [ q{--yacc}, ],
    script          => $0,
    parrot_version  => $parrot_version,
    svnid           => $svnid,
} );
ok(defined $args,
    "process_options() returned successfully after 'yacc' option");
ok($args->{maintainer}, "'maintainer' attribute is true after 'yacc' option");

$args = process_options( {
    argv            => [ q{--debugging=1} ],
    script          => $0,
    parrot_version  => $parrot_version,
    svnid           => $svnid,
} );
ok(defined $args, "process_options() returned successfully");
ok($args->{debugging}, "debugging turned on explicitly");

$args = process_options( {
    argv            => [ q{--debugging=0} ],
    script          => $0,
    parrot_version  => $parrot_version,
    svnid           => $svnid,
} );
ok(defined $args, "process_options() returned successfully");
ok(! $args->{debugging}, "debugging explicitly turned off");

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

01-options.t - test Parrot::Configure::Options

=head1 SYNOPSIS

    % prove t/configure/components/01-options.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by
Parrot::Configure::Options.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure::Options, F<Configure.pl>.

=cut
