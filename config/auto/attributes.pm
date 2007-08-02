# Copyright (C) 2007, The Perl Foundation.
# $Id$

=head1 NAME

config/auto/attributes.pm - Attributes detection

=head1 DESCRIPTION

Automagically detect what attributes, like HASATTRIBUTE_CONST, that
the compiler can support.

=cut

package auto::attributes;

use strict;
use warnings;
use vars qw($description @args);

use base qw(Parrot::Configure::Step::Base);

use Parrot::Configure::Step qw( cc_gen cc_run );


$description = 'Detecting compiler attributes (-DHASATTRIBUTE_xxx)';

@args = qw( cc verbose define );

our @potential_attributes = qw(
    HASATTRIBUTE_CONST
    HASATTRIBUTE_FORMAT
    HASATTRIBUTE_MALLOC
    HASATTRIBUTE_NONNULL
    HASATTRIBUTE_NORETURN
    HASATTRIBUTE_PURE
    HASATTRIBUTE_UNUSED
    HASATTRIBUTE_WARN_UNUSED_RESULT
    HASATTRIBUTE_NEVER_WORKS
);

our $verbose = 0;


sub _option_or_data {
    my $conf = shift;
    my $arg = shift;

    my $opt = $conf->options->get( $arg );
    return $opt ? $opt : $conf->data->get( $arg );
}

sub runstep {
    my ( $self, $conf ) = @_;

    my $verbose = _option_or_data( $conf, 'verbose' );
    print $/ if $verbose;

    for my $maybe_attr ( @potential_attributes ) {
        $self->try_attr( $conf, $maybe_attr );
    }
    return $self;
}

sub try_attr {
    my ( $self, $conf, $attr ) = @_;

    $verbose and print "trying attribute '$attr'$/";

    my $cc = _option_or_data( $conf, 'cc' );

    cc_gen('config/auto/gcc/test_c.in');

    my $ccflags = _option_or_data( $conf, 'ccflags');

    my $tryflags = "$ccflags -D$attr";

    # These are OK to fail, becuase we're trying them out.
    my $command_line = "$cc -o test -Iinclude $tryflags test.c";
    $verbose and print "  ", $command_line, $/;
    my $exit_code = Parrot::Configure::Step::_run_command( $command_line, 'test.cco', 'test.cco' );
    $verbose and print "  exit code: $exit_code$/";

    return if $exit_code;

    my %eval = eval cc_run();
    return if !%eval;

    $conf->data->set( ccflags => $tryflags );

    return;
}

sub blerugh {
    my ( $self, $conf, $attr ) = @_;

    my $verbose = $conf->options->get('verbose');
    if ( 0 ) {
        my $hints_used = 0;

        my $hints = "init::hints::" . lc($^O);

        print "[ $hints " if $verbose;

        eval "use $hints";
        die $@ if $@;

        # Call the runstep method if it exists.
        # Otherwise the step must have done
        # its work when it was loaded.
        $hints->runstep( $conf, @_ ) if $hints->can('runstep');
        $hints_used++;

        $hints = "init::hints::local";
        print "$hints " if $verbose;
        eval "use $hints";
        unless ($@) {
            $hints->runstep( $conf, @_ ) if $hints->can('runstep');
            $hints_used++;
        }

        if ( $hints_used == 0 ) {
            print "(no hints) " if $verbose;
        }

        print "]" if $verbose;
    }

    return $self;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
