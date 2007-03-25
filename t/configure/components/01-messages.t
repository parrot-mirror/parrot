#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 01-messages.t

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
use Test::More tests => 10;
use Carp;
use_ok('Parrot::Configure::Messages', qw|
    print_introduction
    print_conclusion
| );
use_ok("Parrot::IO::Capture::Mini");

my $parrot_version = '0.4.10';
my $make_version = 'gnu make';

{
    my ($tie, $rv, $msg);
    $tie = tie *STDOUT, "Parrot::IO::Capture::Mini"
            or croak "Unable to tie";
    $rv = print_introduction($parrot_version);
    ok($rv, "print_introduction() returned true");
    $msg = $tie->READLINE;

    # Following test is definitive.
    like($msg, qr/$parrot_version/,
        "Message included Parrot version number supplied as argument");

    # Following tests are NOT definitive.  They will break if content of
    # strings printed by function is changed.
    like($msg, qr/Parrot\sVersion/i,
        "Message included string 'Parrot version'");
    like($msg, qr/Configure/i,
        "Message included string 'Configure'");
    like($msg, qr/Copyright/i,
        "Message included copyright notice");
    undef $tie;
}

{
    my ($tie, $rv, $msg);
    $tie = tie *STDOUT, "Parrot::IO::Capture::Mini"
            or croak "Unable to tie";
    $rv = print_conclusion($make_version);
    ok($rv, "print_conclusion() returned true");
    $msg = $tie->READLINE;

    # Following test is definitive.
    like($msg, qr/$make_version/,
        "Message included make version supplied as argument");

    undef $tie;
}

#    print_conclusion($make_version);

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

01-messages.t - test Parrot::Configure::Messages

=head1 SYNOPSIS

    % prove t/configure/components/01-messages.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by
Parrot::Configure::Messages.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure::Messages, F<Configure.pl>.

=cut
