#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 008-file_based_configuration.t

use strict;
use warnings;

BEGIN {
    use FindBin qw($Bin);
    use Cwd qw(cwd realpath);
    our $topdir = realpath($Bin) . "/../..";
    unshift @INC, qq{$topdir/lib};
}
use Test::More qw(no_plan); # tests => 70;
use Carp;
use Parrot::Configure::Options qw| process_options |;
#use Parrot::Configure::Options::Conf::CLI ();
#use Parrot::Configure::Options::Conf::File ();
#use Parrot::Configure::Options::Reconf ();
#use IO::CaptureOutput qw| capture |;

{
    my $configfile = q{xconf/samples/testfoobar};
    local @ARGV = ( qq{--file=$configfile} );
    my ($args, $steps_list_ref) = process_options(
        {
            mode => (defined $ARGV[0]  and $ARGV[0] =~ /^--file=/)
                        ? 'file'
                        : 'configure',
            argv => [@ARGV],
        }
    );
    ok(! defined $args->{maintainer}, 
        "Configuring from testfoobar: 'maintainer' not defined, as expected");
    is($args->{'verbose-step'}, 'init::hints',
        "Configuring from testfoobar: 'init::hints' is verbose step");
    ok($args->{nomanicheck}, 
        "Configuring from testfoobar: will omit check of MANIFEST");
    is($args->{file}, $configfile,
        "Configuring from testfoobar: config file correctly stored");
    ok($args->{debugging}, 
        "Configuring from testfoobar: debugging turned on");
    my %steps_seen = map {$_ => 1} @{ $steps_list_ref };
    ok(exists $steps_seen{'init::manifest'},
        "Configuring from testfoobar: init::manifest is in list even though it will be skipped");
    ok(! exists $steps_seen{'auto::perldoc'},
        "Configuring from testfoobar: auto::perldoc not in list");
}

{
    my $configfile = q{xconf/samples/yourfoobar};
    local @ARGV = ( qq{--file=$configfile} );
    my ($args, $steps_list_ref) = process_options(
        {
            mode => (defined $ARGV[0]  and $ARGV[0] =~ /^--file=/)
                        ? 'file'
                        : 'configure',
            argv => [@ARGV],
        }
    );
    
    my $c_compiler = '/usr/bin/gcc';
    my $cplusplus_compiler = '/usr/bin/g++';
    ok(! defined $args->{maintainer}, 
        "Configuring from yourfoobar: 'maintainer' not defined as expected");
    is($args->{'verbose-step'}, 'init::hints',
        "Configuring from yourfoobar: 'init::hints' is verbose step");
    ok($args->{nomanicheck}, 
        "Configuring from yourfoobar: will omit check of MANIFEST");
    is($args->{file}, $configfile,
        "Configuring from yourfoobar: config file correctly stored");
    ok($args->{debugging}, 
        "Configuring from yourfoobar: debugging turned on");
    is($args->{cc}, $c_compiler,
        "Configuring from yourfoobar: C compiler is $c_compiler");
    is($args->{cxx}, $cplusplus_compiler,
        "Configuring from yourfoobar: C++ compiler is $cplusplus_compiler");
    is($args->{link}, $cplusplus_compiler,
        "Configuring from yourfoobar: linker is $cplusplus_compiler");
    is($args->{ld}, $cplusplus_compiler,
        "Configuring from yourfoobar: shared library loader is $cplusplus_compiler");

    my %steps_seen = map {$_ => 1} @{ $steps_list_ref };

    ok(exists $steps_seen{'init::manifest'},
        "Configuring from yourfoobar: init::manifest is in list even though it will be skipped");
    ok(! exists $steps_seen{'auto::perldoc'},
        "Configuring from yourfoobar: auto::perldoc not in list");
}

{
    my $configfile = q{t/configure/testlib/defectivefoobar};
    local @ARGV = ( qq{--file=$configfile} );
    eval {
        my ($args, $steps_list_ref) = process_options(
            {
                mode => (defined $ARGV[0]  and $ARGV[0] =~ /^--file=/)
                            ? 'file'
                            : 'configure',
                argv => [@ARGV],
            }
        );
    };
    like($@, qr/Configuration file $configfile did not parse correctly/,
        "Got expected failure message after using defective configuration file");
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

008-file_based_configuration.t - test components of Parrot's file-based interface to configuration

=head1 SYNOPSIS

    % prove t/configure/008-file_based_configuration.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by
Parrot::Configure::Options as it is used with
C<mode =E<gt> q{file}>.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure::Options, Parrot::Configure::Options::Conf,
Parrot::Configure::Options::Conf::CLI, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
