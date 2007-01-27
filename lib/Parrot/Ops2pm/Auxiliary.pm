# Copyright (C) 2004-2006, The Perl Foundation.
# $Id$
package Parrot::Ops2pm::Auxiliary;
use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK);
@ISA = qw( Exporter );
@EXPORT_OK = qw( Usage getoptions );
use Getopt::Long;

sub Usage {
    print STDERR <<_EOF_;
usage: tools/build/ops2pm.pl [--help] [--no-lines] input.ops [input2.ops ...]
_EOF_
    return 1;
}

sub getoptions {
    my %flags;
    GetOptions(
        "no-lines" => \$flags{nolines},
        "help"     => \$flags{help},
        "renum"    => \$flags{renum},
    );
    return \%flags;
}

1;

