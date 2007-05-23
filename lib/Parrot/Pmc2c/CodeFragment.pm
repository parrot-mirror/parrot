# Copyright (C) 2004-2006, The Perl Foundation.
# $Id: Parser.pm 18503 2007-05-11 07:39:22Z paultcochrane $
package Parrot::Pmc2c::CodeFragment;
use strict;
use warnings;
use base qw( Exporter );
our @EXPORT_OK = qw( );
use Data::Dumper;
use Parrot::Pmc2c::UtilFunctions qw(count_newlines);
use overload '""' => \&stringify;
sub new {
    my ( $class, $data, $file, $bline) = @_;
    my $self = {};
    bless $self, ref($class) || $class;
    $self->{data} = $data;
    $self->{file} = $file;
    $self->{bline} = $bline;
    $self->{eline} = $bline + count_newlines($data);
    $self;
}

sub stringify {
    my ( $self ) = @_;
    return $self->{data};
}

sub annotate {
    my ( $self, $current_line ) = @_;
    my $line = $self->{bline};
    $line = $current_line + 1 if $line == -1;;
    my $output = "#line $line \"$self->{file}\" \n" . $self->{data};
    return ( $output, count_newlines($output) );
}
1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

