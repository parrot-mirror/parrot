# Copyright (C) 2006-2007, The Perl Foundation.
# $Id$

=head1 NAME

Parrot::Harness::Options - Handle options and argument processing in F<t/harness>

=head1 DESCRIPTION


=cut

package Parrot::Harness::Options;
use strict;
use base qw( Exporter );
our @EXPORT = qw(
    get_test_prog_args
);

sub get_test_prog_args {
    my ($optsref, $gc_debug, $run_exec) = @_;
    my %opts = %{ $optsref };
    my $args = join(' ', map { "-$_" } keys %opts );
    $args =~ s/-O/-O$opts{O}/ if exists $opts{O};
    $args =~ s/-D/-D$opts{D}/;
    $args .= ' --gc-debug'    if $gc_debug;
    # XXX find better way for passing run_exec to Parrot::Test
    $args .= ' --run-exec'    if $run_exec;
    return $args;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

