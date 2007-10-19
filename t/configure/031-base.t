#!perl
# Copyright (C) 2001-2005, The Perl Foundation.
# $Id$

use strict;
use warnings;

use lib qw( lib );
use Test::More tests =>  8;

=head1 NAME

t/configure/031-base.t - tests Parrot::Configure::Step::Base

=head1 SYNOPSIS

    prove t/configure/031-base.t

=head1 DESCRIPTION

Regressions tests for the L<Parrote::Configure::Step::Base> abstract base
class.

=cut

BEGIN { use_ok('Parrot::Configure::Step::Base'); }

package Test::Parrot::Configure::Step::Base;

use base qw(Parrot::Configure::Step::Base);

sub _init {
    my $self = shift;
    my %data;
    $data{description} = q{foo};
    $data{args}        = [ qw( foo bar baz ) ];
    $data{result}      = q{};
    return \%data;
}

package main;

my $testpkg = 'Test::Parrot::Configure::Step::Base';

can_ok( $testpkg, qw(new description args result set_result) );
isa_ok( $testpkg->new, $testpkg );

# ->description() & ->args() work as object methods too
{
    my $teststep = $testpkg->new;

    is( $teststep->description, 'foo', "->description() returns the proper value" );
    is_deeply( [ $teststep->args ], [qw(foo bar baz)], "->args() returns the proper value" );
}

{
    my $teststep = $testpkg->new;

    is( $teststep->result('baz'), q{}, "->set_result() returns the class" );
    isa_ok( $teststep->set_result('baz'), $testpkg );
    is( $teststep->result, 'baz', "->set_result() changed the result value" );
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
