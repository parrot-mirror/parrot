#! perl
# Copyright (C) 2008, The Perl Foundation.
# $Id: parrot_config.t 30553 2008-08-26 01:31:47Z chromatic $

=head1 NAME

t/tools/parrot_config.t - test parrot_config and installable-parrot_config

=head1 SYNOPSIS

    % prove t/tools/parrot_config.t

=head1 DESCRIPTION

Tests the C<parrot_config> and C<installable_parrot_config> tools by
comparing some options to the config hash. Esp. the installable logic.

=head1 REQUIREMENTS

This test script requires you to build parrot_config and the installables,
by using "make parrot_utils" and "make installables" (using a suitable
make tool for your platform).
If this requirement has not been met, some tests will be skipped.

=cut

use strict;
use warnings;
use lib qw(lib);

use Test::More;
use IO::File;
use Parrot::Config;
use File::Spec;

my ($path_to_cfg, $path_to_parrot, $builddir);

BEGIN {
    $builddir = $PConfig{build_dir};
    $path_to_cfg = File::Spec->catfile( $builddir, "parrot_config");
    $path_to_parrot = File::Spec->catfile( $builddir, "parrot" . $PConfig{exe});
    unless ( -f $path_to_parrot ) {
        plan skip_all => "parrot hasn't been built. Run make";
        exit(0);
    }
    my $exefile = $path_to_cfg . $PConfig{exe};
    unless ( -f $exefile ) {
        plan skip_all => "parrot_config hasn't been built. Run make parrot_utils";
        exit(0);
    }
    plan tests => 5;
}

my $tests = 0;
my $prefix = $PConfig{prefix};

output_eq( $path_to_parrot, File::Spec->catfile( $builddir, "parrot_config.pbc") . " prefix",
	   $builddir, "./parrot parrot_config.pbc prefix => build_dir");
output_eq( $path_to_cfg, "prefix",
	   $builddir, "./parrot_config prefix => build_dir");
output_eq( $path_to_cfg, "installed",
	   "0", "./parrot_config installed => 0");

my $path_to_inst = File::Spec->catfile( $builddir, "installable_parrot_config" );
my $exefile = $path_to_inst . $PConfig{exe};
SKIP: {
    skip "installable_parrot_config hasn't been built. Run make installable", 2 unless -f $exefile;
    output_eq( $exefile, "prefix",
	       $prefix, "./installable_parrot_config prefix => prefix");
    output_eq( $exefile, "installed",
	       "1", "./installable_parrot_config installed => 1");
}

=head1 HELPER SUBROUTINES

=head2 output_like

    output_eq($path_to_cfg, "prefix",
              "/usr/local", "$path_to_cfg prefix => /usr/local");

Takes 3-4 arguments: a program to run, the arguments,
a regex string to match the the output,
and the optional test diagnostic.

=cut

my $testno = 0;

sub output_eq {
    my ( $prog, $args, $check, $diag ) = @_;
    $testno++;
    my $stdoutfn = "$0.$testno.stdout";
    system("$prog $args >$stdoutfn 2>&1");
    my $f = IO::File->new($stdoutfn);

    my $output = join( '', <$f> );
    $output =~ s/^\s+//g;
    $output =~ s/\s+$//g;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    $f->close;
    unlink ($stdoutfn);
    is( $output, $check, $diag );
}

=head1 TODO

=over 4

=item

Flesh it out.
This is a bare bones proof of concept just to check the --install logic.
Add tests for all of the commands.

=back

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
