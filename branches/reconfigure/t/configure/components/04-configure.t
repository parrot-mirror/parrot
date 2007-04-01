#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 04-configure.t

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
$Data::Dumper::Indent=1;
use Parrot::BuildUtil;
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use_ok('Parrot::Configure::Step::List', qw|
    get_steps_list
| );

my $parrot_version = Parrot::BuildUtil::parrot_version();
like($parrot_version, qr/\d+\.\d+\.\d+/,
    "Parrot version is in 3-part format");

$| = 1;
is($|, 1, "output autoflush is set");

my $CC = "/usr/bin/gcc-3.3";
my $localargv = [ qq{--cc=$CC} ];
my $args = process_options( {
#    argv            => [ ],
    argv            => $localargv,
    script          => $0,
    parrot_version  => $parrot_version,
    svnid           => '$Id$',
} );
ok(defined $args, "process_options returned successfully");
my %args = %$args;

my $conf = Parrot::Configure->new;
ok(defined $conf, "Parrot::Configure->new() returned okay");

my $newconf = Parrot::Configure->new;
ok(defined $newconf, "Parrot::Configure->new() returned okay");
is($conf, $newconf, "Parrot::Configure object is a singleton");

# Since these tests peek into the Parrot::Configure object, they will break if
# the structure of that object changes.  We retain them for now to delineate
# our progress in testing the object.
foreach my $k (qw| steps options data |) {
    ok(defined $conf->$k, "Parrot::Configure object has $k key");
}
is(ref($conf->steps), q{ARRAY},
    "Parrot::Configure object 'steps' key is array reference");
is(scalar @{$conf->steps}, 0,
    "Parrot::Configure object 'steps' key holds empty array reference");
foreach my $k (qw| options data |) {
    isa_ok($conf->$k, "Parrot::Configure::Data");
}

$conf->add_steps(get_steps_list());
my @confsteps = @{$conf->steps};
isnt(scalar @confsteps, 0,
    "Parrot::Configure object 'steps' key holds non-empty array reference");
my $nontaskcount = 0;
foreach my $k (@confsteps) {
    $nontaskcount++ unless $k->isa("Parrot::Configure::Task");
}
is($nontaskcount, 0, "Each step is a Parrot::Configure::Task object");

# print STDERR Dumper ($conf->data, $conf->options);
$conf->options->set(%args);
# print STDERR Dumper ($conf->data, $conf->options);
is($conf->options->{c}->{cc}, $CC, "command-line option being stored in object");
is($conf->options->{c}->{debugging}, 1, "command-line option being stored in object");


pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

04-configure.t - test Parrot::Configure

=head1 SYNOPSIS

    % prove t/configure/components/04-configure.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by
Parrot::Configure.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure, F<Configure.pl>.

=cut
