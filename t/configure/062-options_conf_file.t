#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 062-options_conf_file.t

use strict;
use warnings;
use Test::More qw(no_plan); # tests =>  9;
#use Carp;
#use Cwd;
#use Data::Dumper;
#use File::Temp qw( tempdir );
use lib qw( lib );
use Parrot::Configure::Options::Conf::File qw(
    @valid_options
    $script
    %options_components
    $parrot_version
    $svnid
);
use Parrot::Configure::Options::Conf::Shared qw(
    @shared_valid_options
);
#use IO::CaptureOutput qw| capture |;

my $variables = <<END;
CC=/usr/bin/gcc
#CX=/usr/bin/g++

ABC=abc
END

my $substitutions =
    Parrot::Configure::Options::Conf::File::_get_substitutions($variables);
is_deeply($substitutions,
    { CC => '/usr/bin/gcc', ABC => 'abc' },
    "Got expected substitutions"
);

my $general = <<END;
cc=\$CC
this=will not=work
#abc=abc

verbose
verbose-step=init::hints
configure_trace
END

my $data = shift;
$data->{debugging} = 1;
$data->{maintainer} = undef;
my %valid_step_options = map {$_ => 1} @shared_valid_options;
$data = Parrot::Configure::Options::Conf::File::_set_general($data, $substitutions, $general,
    \%valid_step_options);
my $cc = q{/usr/bin/gcc};
is_deeply($data,
    {
        debugging       => 1,
        maintainer      => undef,
        cc              => $cc,
        verbose         => 1,
        configure_trace => 1,
        'verbose-step'  => 'init::hints',
    },
    "Got expected return value for _set_general()"
);

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

062-options_conf_file.t - test Parrot::Configure::Options::Test

=head1 SYNOPSIS

    % prove t/configure/062-options_conf_file.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test Parrot::Configure::Options::Conf::File
subroutines.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure::Options, Parrot::Configure::Options::Conf::File,
F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
