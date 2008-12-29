#! perl
# Copyright (C) 2007-2008, The Perl Foundation.
# $Id: pdump.t 34223 2008-12-22 03:24:34Z petdance $

=head1 NAME

t/tools/pdump.t - test the Parrot Dumper

=head1 SYNOPSIS

    % prove t/tools/pdump.t

=head1 DESCRIPTION

Tests the C<pdump> tool by providing it with a number of source
files, and running through it with various commands.

We never actually check the I<full> output of pdump.  We simply check
several smaller components to avoid a test file that is far too unwieldy.


=head1 REQUIREMENTS

This test script requires you to build pdump, by typing
"make parrot_utils" (using a suitable make tool for your platform).
If this requirement has not been met, all tests will be skipped.

=cut

use strict;
use warnings;
use lib qw(lib);

use Test::More;
use IO::File ();
use Parrot::Config;
use File::Spec;

my $path;
my $parrot = File::Spec->catfile( ".", $PConfig{test_prog} );

BEGIN {
    $path = File::Spec->catfile( ".", "pdump" );
    my $exefile = $path . $PConfig{exe};
    unless ( -f $exefile ) {
        plan skip_all => "pdump hasn't been built. Run make parrot_utils";
        exit(0);
    }
    plan tests => 2;
}

output_like( <<PIR, "pir", [qr/'PFC_STRING'/, qr/PFC_PMC/], '');
.sub main :main
    \$N3 = 3.14159
    print \$N3
    print "\\n"
.end
PIR

=head1 HELPER SUBROUTINES

=head2 output_like

    output_like(<<PASM, "pasm", "some output", "running $file");

Takes 3-4 arguments: a file to run,
the filename-extension of the file (probably "pir" or "pasm"),
an arrayref or single regex string to match within pdump's output,
and the optional test diagnostic.

=cut

my $testno = 0;

sub output_like {
    my ( $file, $ext, $check, $diag ) = @_;
    $testno++;
    my $codefn   = "$0.$testno.$ext";
    my $pbcfn    = "$0.$testno.pbc";
    my $stdoutfn = "$0.$testno.stdout";
    my $f        = IO::File->new(">$codefn");
    $f->print($file);
    $f->close();
    system("$parrot -o $pbcfn $codefn 2>&1");
    system("$path $pbcfn >$stdoutfn 2>&1");
    $f = IO::File->new($stdoutfn);

    my $output = join( '', <$f> );

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    unlink ($codefn, $pbcfn, $stdoutfn);
    if (ref $check eq 'ARRAY') {
	for my $chk (@$check) {
	    like( $output, $chk, $diag );
	    $testno++;
	}
    } else {
	like( $output, $check, $diag );
    }
}

=head1 TODO

=over 4

=item

Flesh it out.  This is a bare bones proof of concept.
Add tests for all of the commands.

=back

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
