#
# Unless.pm
#
# Copyright (C) 2002-2003 Gregor N. Purdy. All rights reserved.
# This program is free software. It is subject to the same license
# as the Parrot interpreter.
#
# $Id$
#

use strict;
use warnings;

package Jako::Construct::Block::Conditional::Unless;

use Carp;

use base qw(Jako::Construct::Block::Conditional);

#
# new()
#

sub new
{
  my $class = shift;
  my ($block, $left, $op, $right) = @_;

  confess "Block is not defined!" unless defined $block;
  confess "Left is not defined!" unless defined $left;
  confess "Op is not defined!" unless defined $op;
  confess "Right is not defined!" unless defined $right;

  confess "Block is not!" unless UNIVERSAL::isa($block, 'Jako::Construct::Block');
  confess "Left is not Value!" unless UNIVERSAL::isa($left, 'Jako::Construct::Expression::Value');
  confess "Op is not scalar!" if ref $op;
  confess "Right is not Value!" unless UNIVERSAL::isa($right, 'Jako::Construct::Expression::Value');

  my $index = ++$Jako::Compiler::block_count; # TODO: YUCK!

  my $prefix = "_UNLESS_$index";

  my $self = bless {
    BLOCK     => $block,
    KIND      => 'unless',
    PREFIX    => $prefix,
    NAMESPACE => $prefix,
    LEFT      => $left,
    OP        => $op,
    RIGHT     => $right,
    CONTENT   => [ ]
  }, $class;

  $block->push_content($self);

  return $self;
}

1;

