#! perl
# Copyright (C) 2007, Parrot Foundation.
# $Id$
# 049-options_test.t

use strict;
use warnings;
use Carp;
use Cwd;
use File::Basename qw( basename fileparse );
use File::Path qw( mkpath );
use File::Temp 0.13 qw| tempdir |;
use Test::More qw(no_plan); # tests => 12;
use lib qw( lib );
use IO::CaptureOutput qw| capture |;
use Parrot::Configure::Options::Test::Prepare ();

my $cwd = cwd();
{
    my $tdir = tempdir( CLEANUP => 1 );
    chdir $tdir or croak "Unable to change to temporary directory";
    my $good_test = q{001-sometest.t};
    my $bad_test  = q{someothertest.t};
    touch_in_this_dir($good_test);
    touch_in_this_dir($bad_test);
    my %tests_seen = map { basename($_), 1 }
        Parrot::Configure::Options::Test::Prepare::_get_framework_tests($tdir);
    ok($tests_seen{$good_test},
        "Correctly named test identified");
    ok(! $tests_seen{$bad_test},
        "Incorrectly named test excluded");

    ok( chdir $cwd, "Able to change back to starting directory");
}

{
    my $tdir = tempdir( CLEANUP => 1 );
    chdir $tdir or croak "Unable to change to temporary directory";
    my $init_test = q{init/sometest-01.t};
    my $init_hints_test = q{init/hints/sometest-01.t};
    my $inter_test = q{inter/sometest-01.t};
    my $auto_test = q{auto/sometest-01.t};
    my $gen_test = q{gen/sometest-01.t};
    my $bad_test  = q{bad/sometest-01.t};
    my $lack_number_test = q{init/test.t};
    touch($init_test);
    touch($init_hints_test);
    touch($inter_test);
    touch($auto_test);
    touch($gen_test);
    touch($bad_test);
    touch($lack_number_test);

    my ( $steps_tests_simple_ref, $steps_tests_complex_ref )  = ( {}, {} );
#    {
#        my ($stdout, $stderr);
#        capture (
#            sub {
#                ( $steps_tests_simple_ref, $steps_tests_complex_ref )  =
#                    Parrot::Configure::Options::Test::Prepare::_find_steps_tests($tdir)
#            },
#            \$stdout,
#            \$stderr,
#        );
#        like($stderr, qr/Unable to match $bad_test/,
#            "Warning about badly named test captured");
#        like($stderr, qr/Unable to match $lack_number_test/,
#            "Warning about badly named test captured");
#    }

#    my @tests_expected = qw(
#        init::sometest
#        inter::sometest
#        auto::sometest
#        gen::sometest
#        gen::missing
#    );
#    my %tests_seen = ();
#    {
#        my ($stdout, $stderr);
#        capture (
#            sub { %tests_seen = map { basename($_), 1}
#                Parrot::Configure::Options::Test::Prepare::_prepare_steps_tests_list(
#                    $tdir,
#                    $steps_tests_complex_ref,
#                    \@tests_expected,
#                ) },
#            \$stdout,
#            \$stderr,
#        );
#        like($stderr, qr/No tests exist for configure step gen::missing/,
#            "Warning about step class lacking test test captured");
#    }
#    foreach my $type ( qw| init inter auto gen | ) {
#        my $t = $type . q(_sometest-01.t);
#        ok($tests_seen{$t}, "Found needed test");
#    }

    ok( chdir $cwd, "Able to change back to starting directory");
}

pass("Completed all tests in $0");

#{
#    my $tdir = tempdir( CLEANUP => 1 );
#    chdir $tdir or croak "Unable to change to temporary directory";
#    my $init_test = q{init/sometest-01.t};
#    my $init_hints_test = q{init/hints/sometest-01.t};
#    touch($init_test);
#    touch($init_hints_test);
#    chdir $cwd or croak "Unable to change back to starting directory";
#}

sub touch {
    my $path = shift;
    my ($base, $dirs) = fileparse($path);
    my $cwd = cwd();
    unless ( -d $dirs ) {
        mkpath( [ $dirs ], 0, 0777 ) or croak "Unable to create dirs: $!";
    }
    chdir $dirs or croak "Unable to change dir: $!";
    touch_in_this_dir( $base );
    chdir $cwd or croak "Unable to change back dir: $!";
    ( -e $path ) or croak "Didn't create file: $!";
}

sub touch_in_this_dir {
    my $file = shift;
    open my $FH, '>', $file or croak "Unable to open $file for writing";
    print $FH "Hello, world\n";
    close $FH or croak "Unable to close $file after writing";
}

################### DOCUMENTATION ###################

=head1 NAME

049-options_test.t - test Parrot::Configure::Options::Test

=head1 SYNOPSIS

    % prove t/configure/049-options_test.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test Parrot::Configure::Options::Test methods.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure::Options, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
