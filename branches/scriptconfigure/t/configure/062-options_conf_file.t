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
#use IO::CaptureOutput qw| capture |;


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
