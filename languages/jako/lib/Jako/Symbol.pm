#
# Symbol.pm
#
# Copyright (C) 2002-2003 Gregor N. Purdy. All rights reserved.
# This program is free software. It is subject to the same license
# as the Parrot interpreter.
#
# $Id$
#

use strict;
use warnings;

package Jako::Symbol;

use Carp;


#
# CONSTRUCTOR:
#

sub new
{
  my $class = shift;

  confess "Expected 8 args" unless @_ == 8;

  my ($block, $kind, $type, $name, $value, $props, $file, $line) = @_;

  confess("Undefined identifier block.")
    unless defined $block;

  confess "Block (" . ref($block) . ") is not!"  unless UNIVERSAL::isa($block, qw(Jako::Construct::Block));
  confess "Type (" . ref($type) . ") is not!"   if defined $type and not UNIVERSAL::isa($type, qw(Jako::Construct::Type));
  confess "Value (" . ref($value) . ") is not!"  if defined $value and not UNIVERSAL::isa($value, qw(Jako::Construct::Expression::Value));

  confess("Undefined identifier kind attribute.")
    unless defined $kind;
 
  confess("Unrecognized identifier kind attribute '%s'.", $kind)
    unless $kind eq 'sub' or $kind eq 'var' or $kind eq 'arg' or $kind eq 'const';

  my $self = bless {
    BLOCK  => $block,

    KIND   => $kind,
    TYPE   => $type,
    NAME   => $name,
    VALUE  => $value,  # For constants (undef for variables)
    PROPS  => $props,

    DEBUG  => 1,
    FILE   => $file,
    LINE   => $line
  }, $class;

  return $self;
}


#
# ACCESSORS:
#

sub block  { return shift->{BLOCK};    }

sub kind   { return shift->{KIND};     }
sub type   { return shift->{TYPE};     }
sub name   { return shift->{NAME};     }
sub value  { return shift->{VALUE};    }
sub props  { return %{shift->{PROPS}}; }

sub file   { return shift->{FILE};     }
sub line   { return shift->{LINE};     }

sub is_constant { return shift->kind eq 'const'; }
sub is_variable { my $self = shift; return $self->kind eq 'var' or $self->kind = 'arg'; }
sub is_sub      { my $self = shift; return $self->kind eq 'sub'; }

1;

