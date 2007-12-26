# Copyright (C) 2001-2003, The Perl Foundation.
# $Id$

=head1 NAME

config/auto/sizes.pm - Various Sizes

=head1 DESCRIPTION

Determines the sizes of various types.

=cut

package auto::sizes;

use strict;
use warnings;

use base qw(Parrot::Configure::Step::Base);

use Parrot::Configure::Step ':auto';


sub _init {
    my $self = shift;
    my %data;
    $data{description} = q{Determining some sizes};
    $data{args}        = [ qw( miniparrot ) ];
    $data{result}      = q{};
    return \%data;
}

sub runstep {
    my ( $self, $conf ) = @_;

    if ( defined $conf->options->get('miniparrot') ) {
        $conf->data->set(
            doublesize       => 8,
            numvalsize       => 8,
            nvsize           => 8,
            floatsize        => 4,
            opcode_t_size    => 4,
            ptrsize          => 4,
            intvalsize       => 4,
            intsize          => 4,
            longsize         => 4,
            shortsize        => 2,
            hugeintval       => 'long',
            hugeintvalsize   => 4,
            hugefloatval     => 'double',
            hugefloatvalsize => 8,
            int2_t           => 'int',
            int4_t           => 'int',
            float4_t         => 'double',
            float8_t         => 'double',
        );
        $self->set_result('using miniparrot defaults');
        return 1;
    }

    cc_gen('config/auto/sizes/test_c.in');
    cc_build();
    my %results = eval cc_run();
    cc_clean();

    for ( keys %results ) {
        $conf->data->set( $_ => $results{$_} );
    }

    _handle_intval_ptrsize_discrepancy(\%results);

    # set fixed sized types
    _set_int2($conf, \%results);

    _set_int4($conf, \%results);

    _set_float4($conf, \%results);

    _set_float8($conf, \%results);

    my %hugeintval;
    my $intval     = $conf->data->get('iv');
    my $intvalsize = $conf->data->get('intvalsize');

    # Get HUGEINTVAL, note that we prefer standard types
    foreach my $type ( 'long', 'int', 'long long', '__int64' ) {

        $conf->data->set( int8_t => $type );
        eval {
            cc_gen('config/auto/sizes/test2_c.in');
            cc_build();
            %hugeintval = eval cc_run();
            cc_clean();
        };

        # clear int8_t on error
        if ( $@ || !exists $hugeintval{hugeintval} ) {
            $conf->data->set( int8_t => undef );
            next;
        }

        if ( $hugeintval{hugeintvalsize} > $intvalsize ) {

            # We found something bigger than intval.
            $conf->data->set(%hugeintval);
            last;
        }
    }
    if ( !defined( $hugeintval{hugeintvalsize} )
        || $hugeintval{hugeintvalsize} == $intvalsize )
    {

        # Could not find anything bigger than intval.
        $conf->data->set(
            hugeintval     => $intval,
            hugeintvalsize => $intvalsize,
        );
    }

    cc_clean();

    #get HUGEFLOATVAL
    if (
        my $size = eval {
            open( my $TEST, ">", "test.c" ) or die "Can't open test.c: $!";
            print {$TEST} <<'END';
#include <stdio.h>

int main() {
    long double foo;
    printf("%u", sizeof(foo));
    return 0;
}
END
            close $TEST;

            cc_build();
            cc_run();
        }
        )
    {
        $conf->data->set(
            hugefloatval     => 'long double',
            hugefloatvalsize => $size
        );
    }
    else {
        $conf->data->set(
            hugefloatval     => 'double',
            hugefloatvalsize => $conf->data->get('doublesize')
        );
    }

    cc_clean();

    return 1;
}

sub _handle_intval_ptrsize_discrepancy {
    my $resultsref = shift;
    if ( $resultsref->{ptrsize} != $resultsref->{intvalsize} ) {
        print <<"END";

Hmm, I see your chosen INTVAL isn't the same size as your pointers.  Parrot
should still compile and run, but you may see a ton of warnings.
END
    }
}

sub _set_int2 {
    my ($conf, $resultsref) = @_;
    if ( $resultsref->{shortsize} == 2 ) {
        $conf->data->set( int2_t => 'short' );
    }
    else {
        $conf->data->set( int2_t => 'int' );
        print <<'END';

Can't find a int type with size 2, conversion ops might fail!

END
    }
}

sub _set_int4 {
    my ($conf, $resultsref) = @_;
    if ( $resultsref->{shortsize} == 4 ) {
        $conf->data->set( int4_t => 'short' );
    }
    elsif ( $resultsref->{intsize} == 4 ) {
        $conf->data->set( int4_t => 'int' );
    }
    elsif ( $resultsref->{longsize} == 4 ) {
        $conf->data->set( int4_t => 'long' );
    }
    else {
        $conf->data->set( int4_t => 'int' );
        print <<'END';

Can't find a int type with size 4, conversion ops might fail!

END
    }
}

sub _set_float4 {
    my ($conf, $resultsref) = @_;
    if ( $resultsref->{floatsize} == 4 ) {
        $conf->data->set( float4_t => 'float' );
    }
    else {
        $conf->data->set( float4_t => 'double' );
        print <<'END';

Can't find a float type with size 4, conversion ops might fail!

END
    }
}

sub _set_float8 {
    my ($conf, $resultsref) = @_;
    if ( $resultsref->{doublesize} == 8 ) {
        $conf->data->set( float8_t => 'double' );
    }
    else {
        $conf->data->set( float8_t => 'double' );
        print <<'END';

Can't find a float type with size 8, conversion ops might fail!

END
    }
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
