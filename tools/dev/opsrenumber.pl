#! perl
# Copyright (C) 2001-2007, The Perl Foundation.
# $Id$

use strict;
use warnings;

use lib 'lib';
use Parrot::OpsRenumber;

my $self = Parrot::OpsRenumber->new(
    {
        argv    => [@ARGV],
        moddir  => "lib/Parrot/OpLib",
        module  => "core.pm",
        inc_dir => "include/parrot/oplib",
        inc_f   => "ops.h",
        script  => "tools/dev/opsrenumber.pl",
    }
);

$self->prepare_ops();
$self->renum_op_map_file();

exit 0;

################### DOCUMENTATION ####################

=head1 NAME

tools/dev/opsrenumber.pl - Renumber F<src/ops/ops.num>.

=head1 SYNOPSIS

    $ perl tools/dev/opsrenumber.pl

=head1 DESCRIPTION

This program shoul when adding or removing opcodes.

=head1 SEE ALSO

=over 4

=item F<tools/build/ops2c.pl>.

=item F<lib/Parrot/Ops2pm.pm>.

=item F<lib/Parrot/Ops2pm/Auxiliary.pm>.

=item F<tools/dev/ops_renum.mak>.

=back

=head1 AUTHOR

Over the years, the code now found in F<tools/dev/opsrenumber.pl> has been worked on by the following Parrot hackers:

  bernhard
  brentdax
  chip
  chromatic
  coke
  dan
  gregor
  jkeenan
  leo
  mikescott
  particle
  paultcochrane
  petdance
  robert
  simon
  tewk

Others who provided code cited in the version control logs include:

  Andy Dougherty
  Jeff Gof
  Steve Fink

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
