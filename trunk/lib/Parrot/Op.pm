#! perl -w
#
# Op.pm
#
# A Perl class to represent Parrot Ops, as read from an .ops file via
# Parrot::OpsFile, or perhaps even generated by some other means.
#

use strict;

package Parrot::Op;


#
# new()
#

sub new
{
  my $class = shift;
  my ($code, $type, $name, @args) = @_;

  my $self = { CODE => $code, TYPE => $type, NAME => $name, ARGS => [ @args ], BODY => '' };

  return bless $self, $class;
}


#
# code()
#

sub code
{
  my $self = shift;
  return $self->{CODE};
}


#
# type()
#

sub type
{
  my $self = shift;
  return $self->{TYPE};
}


#
# name()
#

sub name
{
  my $self = shift;
  return $self->{NAME};
}


#
# full_name()
#

sub full_name
{
  my $self      = shift;
  my $name      = $self->name;
  my @arg_types = $self->arg_types;

  shift @arg_types; # Remove the 'op' type.

  $name .=  "_" . join("_", @arg_types)
    if @arg_types;

  return $name;
}


#
# func_name()
#

sub func_name
{
  my $self = shift;

  return "Parrot_" . $self->full_name;
}


#
# arg_types()
#

sub arg_types
{
  my $self = shift;
  return @{$self->{ARGS}};
}


#
# arg_type()
#

sub arg_type
{
  my $self = shift;
  return $self->{ARGS}[shift];
}


#
# body()
#

sub body
{
  my $self = shift;
  if (@_) {
    $self->{BODY} = shift;
  }

  return $self->{BODY};
}


#
# full_body()
#

sub full_body
{
  my $self = shift;

  my $body = $self->body;

  $body .= sprintf("  {{+=%d}};\n", $self->size)
    if $self->type eq 'auto';

  return $body;
}


#
# source()
#

sub source
{
  my ($self, $ret_sub_abs, $ret_sub_rel, $arg_sub, $res_sub_abs, $res_sub_rel) = @_;

  my $full_body = $self->full_body;

  $full_body =~ s/{{\@(.*?)}}/ &$arg_sub($self->arg_type($1), $1, $self); /mge;

  $full_body =~ s/{{=0,=(.*?)}}/   &$res_sub_abs($1)  . "; " . &$ret_sub_abs(0); /mge;
  $full_body =~ s/{{=0,\+=(.*?)}}/ &$res_sub_rel($1)  . "; " . &$ret_sub_abs(0); /mge;
  $full_body =~ s/{{=0,-=(.*?)}}/  &$res_sub_rel(-$1) . "; " . &$ret_sub_abs(0); /mge;

  $full_body =~ s/{{=(.*?)}}/   &$ret_sub_abs($1); /mge;
  $full_body =~ s/{{\+=(.*?)}}/ &$ret_sub_rel($1); /mge;
  $full_body =~ s/{{-=(.*?)}}/  &$ret_sub_rel(-$1); /mge;

  return $full_body;
}


#
# size()
#

sub size
{
  my $self = shift;

  return scalar($self->arg_types); 
}


1;

__END__

=head1 NAME

Parrot::Op

=head1 SYNOPSIS

  use Parrot::Op;

=head1 DESCRIPTION

Represents a Parrot operation (op, for short).

=head2 arg_type

Returns a particular argument type.

=head2 arg_types

Returns the entire argument type list.

=head2 body
=head2 body BODY

Sets or returns the op's code body. If no BODY is given, the body is returned.
If BODY is given, then the body is set.

=head2 full_body

For manual ops, full_body is the same as body. For auto ops, full_body
adds a final {{+=S}} line to the code to represent the auto-computed
return value (S is the op size).

=head2 full_name

For argumentless ops, its the same as name. For ops with arguments, an underscore
followed by underscore-separated argument types are appended to the name.

=head2 func_name

The same as full_name, but with "Parrot_" prefixed.

=head2 name

The (short or root) name of the op.

=head2 new TYPE, NAME, ARG_TYPE_LIST

Allocates a new bodyless op. A body must be provided eventually for the op to be
usable. See B<body>.

=head2 source RET_ABS_SUB RET_REL_SUB ARG_SUB RES_SUB

Returns the full_body of the op with substitutions made for the PC-modifying
and argument-access placeholders.

=head2 type

The type of the op, 'auto' or 'manual'. Manual ops are responsible for
having explicit next-op RETURNs, while Auto ops can count on an
automatically generated next-op to be appended. See also B<full_body>.

=head1 AUTHORS

Gregor N. Purdy E<lt>gregor@focusresearch.comE<gt>

=head1 LICENSE

This program is free software. It is subject to the same
license as Parrot itself.

=head1 COPYRIGHT

Copyright (C) 2001 Gregor N. Purdy. All rights reserved.

