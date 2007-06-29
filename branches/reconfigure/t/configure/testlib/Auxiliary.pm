# Copyright (C) 2007, The Perl Foundation.
# $Id: GenerateCore.pm 17576 2007-03-17 22:50:07Z paultcochrane $
package Auxiliary;
use strict;
use warnings;
our ( @ISA, @EXPORT_OK );
@ISA       = qw(Exporter);
@EXPORT_OK = qw(
    test_hint
);
use Carp;
*ok = *Test::More::ok;
*isa_ok = *Test::More::isa_ok;
use lib qw( . lib ../lib ../../lib );
use Parrot::Configure;

sub test_hint {
    my ($conf, $pkg, $args, $stepnum) = @_;
    my ($task, $step_name, @step_params, $step, $ret);
    
    $conf->add_steps($pkg);
    $conf->options->set(%{$args});

    $task = $conf->steps->[$stepnum];
    $step_name   = $task->step;
    @step_params = @{ $task->params };

    $step = $step_name->new();
    ok(defined $step, "$step_name constructor returned defined value");
    isa_ok($step, $step_name);
    ok($step->description(), "$step_name has description");
    $ret = $step->runstep($conf);
    ok(defined $ret, "$step_name runstep() returned defined value");
}

1;
