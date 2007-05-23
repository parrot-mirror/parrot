# Copyright (C) 2004-2006, The Perl Foundation.
# $Id: Parser.pm 18503 2007-05-11 07:39:22Z paultcochrane $
package Parrot::Pmc2c::Emitter;
use strict;
use warnings;
use base qw( Exporter );
our @EXPORT_OK = qw();
use Parrot::Pmc2c::UtilFunctions qw(spew);

sub new {
    my ( $class, $filename, $parent) = @_;
    my $self = { 
        filename => $filename,
        parent   => $parent,
    };
    bless $self, (ref($class) || $class);
    $self;
}

sub emit {
    my ( $self, $item, $file, $line ) = @_;
    unless ( ref($item) eq 'Parrot::Pmc2c::CodeFragment' ) {
        $file = $self->filename unless $file;
        $line = -1 unless $line;
        $item = Parrot::Pmc2c::CodeFragment->new($item, $file, $line)
    }
    $self->add_fragment($item);
}

sub add_fragment {
    my ( $self, $item) = @_;
    push @{ $self->{items} }, $item;
}

sub filename {
    my ( $self, $value ) = @_;
    $self->{filename} = $value if $value;
    return $self->{filename}
}

sub write_to_file {
    my ( $self) = @_;
    my $items = $self->{items};
    my $output = "";
    my $lines = 1;

    for my $item ( @$items ) {
        my ( $item_output, $item_lines ) = $item->annotate( $lines );
        $output .= $item_output;
        $lines += $item_lines;
    }

    spew($self->filename, $output);
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

