#!/usr/bin/perl -w
#
# Constant.pm
#
# Parrot Constants.
#
# Copyright (C) 2001 Gregor N. Purdy. All rights reserved.
# This program is free software. It is subject to the same
# license as Perl itself.
#
# $Id$
#

use strict;

package Parrot::PackFile::Constant;


#
# new()
#

sub new
{
  my $class = shift;
  my ($flags, $encoding, $type, $size, $data) = @_;

  my $self = bless {
    FLAGS    => $flags,
    ENCODING => $encoding,
    TYPE     => $type,
    SIZE     => $size,
    DATA     => $data
  }, $class;

  return $self;
}


#
# flags()
#

sub flags
{
  my $self = shift;
  if (@_) { $self->{FLAGS} = shift; }
  else    { return $self->{FLAGS};  }
}


#
# encoding()
#

sub encoding
{
  my $self = shift;
  if (@_) { $self->{ENCODING} = shift; }
  else    { return $self->{ENCODING};  }
}


#
# type()
#

sub type
{
  my $self = shift;
  if (@_) { $self->{TYPE} = shift; }
  else    { return $self->{TYPE};  }
}


#
# size()
#

sub size
{
  my $self = shift;
  if (@_) { $self->{SIZE} = shift; }
  else    { return $self->{SIZE};  }
}


#
# data()
#

sub data
{
  my $self = shift;
  if (@_) { $self->{DATA} = shift; }
  else    { return $self->{DATA};  }
}


#
# unpack()
#
# Unpack from the string and return the number of characters that should
# be removed from the packed string.
#

sub unpack
{
  my ($self, $string) = @_;

  my ($flags, $encoding, $type, $size) = unpack('l l l l', $string);

  my $block_size = $size + ($size % 4);
  my $data       = unpack("x16 a$block_size", $string);

  $self->{FLAGS}    = $flags;
  $self->{ENCODING} = $encoding;
  $self->{TYPE}     = $type;
  $self->{SIZE}     = $size;
  $self->{DATA}     = substr($data, 0, $size);

  return 16 + $block_size;
}


#
# pack()
#

sub pack
{
  my $self = shift;
  
  my $block = $self->data . ("\0" x ($self->size % 4));

  return pack('l l l l a*', $self->flags, $self->encoding, $self->type, $self->size,
    $block);
}


1;

__END__

=head1 NAME

Parrot::PackFile::Constant

=head1 SYNOPSIS

  use Parrot::PackFile::Constant;

=head1 DESCRIPTION

=head2 data DATA
=head2 data

=head2 encoding ENCODING
=head2 encoding

=head2 flags FLAGS
=head2 flags 

=head2 new FLAGS ENCODING TYPE SIZE DATA

=head2 pack

=head2 size SIZE
=head2 size

=head2 type TYPE
=head2 type

=head2 unpack STRING
=head2 unpack

=head1 AUTHOR

Gregor N. Purdy E<lt>gregor@focusresearch.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2001 Gregor N. Purdy. All rights reserved.

=head1 LICENSE

This program is free software. It is subject to the same
license as Perl itself.

