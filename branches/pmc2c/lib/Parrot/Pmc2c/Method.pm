# Copyright (C) 2004-2006, The Perl Foundation.
# $Id$
package Parrot::Pmc2c::Method;
use strict;
use warnings;
use constant VTABLE_ENTRY => 'VTABLE_ENTRY';
use constant VTABLE => 'VTABLE';
use constant NON_VTABLE => 'NON_VTABLE';
use base qw( Exporter );
our @EXPORT_OK = qw();
use Carp;
use Parrot::Pmc2c::UtilFunctions qw(count_newlines);

sub new {
    my ( $class, $self_hash ) = @_;
    my $self = {(
        attrs => {},
        mmds => [],
        body => "",
        parameters => "",
        mmd_rights => [],
        %{ $self_hash || {} }
      )};
    bless $self, (ref($class) || $class);
    $self;
}

sub clone {
    my ( $self ) = @_;
    my $new = {( %{ $self } )};
    bless $new, ref($self);
    return $new;
}

sub add_mmd_rights {
    my ( $self, $value ) = @_;
    push @{ $self->{mmd_rights} }, $value;
}

sub mmd_rights {
    my ( $self ) = @_;
    return $self->{mmd_rights};
}

#getters/setters
for my $x qw( name type return_type body mmds symbol mmd_prefix mmd_table mmd_name right 
        attrs parameters ) {
    my $code = <<'EOC';
sub REPLACE {
    my ( $self, $value ) = @_;
    $self->{REPLACE} = $value if defined $value;
    return $self->{REPLACE}
}
EOC
    $code =~ s/REPLACE/$x/g;
    eval $code;
}


sub is_vtable {
    my ( $self ) = @_;
    my $type = $self->type;
    return $type eq VTABLE || $type eq VTABLE_ENTRY;
}

sub is_mmd {
    my ( $self ) = @_;

    return 1 if $self->{mmd_name};
    return 1 if $self->mmds and scalar @{ $self->mmds };
    return 0;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

